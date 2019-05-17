//
//  PipelineStartJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/13/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten
import BSON

class PipelineStartJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    var pipelineData : PipelineStartData?
    var keysUpdateJob : GlobalKeyUpdateJob!
    
    init(_ data:PipelineStartData) {
        pipelineData = data
    }
    
    func execute(completion: @escaping(String?, RequestError?) -> Void) {
        guard let pd = pipelineData, let pipelineId = pd.pipelineId else {
            Log.error("could not get pipeline id from request")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        MongoDB.shared.getRecord(recordId: pipelineId, collection: MongoConstants.Collection.scripts) { (doc, err) in
            if let _d = doc {
                self.startPipeline(data:pd, doc:_d, completion:completion)
            } else {
                Log.error("could not get pipeline doc from mongo")
                completion(nil, RequestError.failedDependency)
            }
        }
    }
    
    func startPipeline(data:PipelineStartData,
                       doc: Document,
                       completion: @escaping(String?, RequestError?) -> Void)
    {
        // generate model object from mongo data
        guard let _scriptData = CellProfilerScriptData(with: doc) else {
            Log.error("could not generate valid pipeline from doc")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // generate path path for pipeline config file
        guard let filePath = _scriptData.generateFilePath() else {
            Log.error("could not generate file path")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // check if file is on disk
        guard SystemManager.fileExistsAt(filePath) == true else {
            Log.error("file could not be found at path \(filePath)")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // insert run record into mongo
        // generate bson doc
        let bson = data.generateBSONDoc(status: RunJobStatus.Running.rawValue)
        
        // insert bson doc
        MongoDB.shared.insert(doc: bson,
                              collection: MongoConstants.Collection.runs)
        { (success) in
            if success {
                // run pipeline
                Log.info("successfully inserted run record into db")
                self.runPipeline(pdata: data, sdata: _scriptData)
                
                // at this point we can respond to client
                if let jdata = try? JSONEncoder().encode(bson),
                let jstr = String(data: jdata, encoding: String.Encoding.utf8)
                {
                    Log.info("successfully generated start pipeline response \(jstr)")
                    completion(jstr, nil)
                } else {
                    Log.error("Could not encode JSON response for start pipeline")
                    // we should still send success to clinet because pipeline goes on
                    completion("Success", nil)
                }
            } else {
                Log.error("could not insert run record into db")
                completion(nil, RequestError.failedDependency)
            }
        }
    }
    
    func runPipeline(pdata: PipelineStartData,
                     sdata: CellProfilerScriptData)
    {
        // run pipeline script
        /*
         # Args
         # $1 = config file name
         # $2 = Omero dataset number
         # $3 = cppipe file full path name
         # $4 = omero file list name
         # $5 = Name of component that created the omero file list
         # $6 = Full path name of cell profiler output dir
         # $7 = Unique Run Identifier
         # $8 = Parser ouptput dir
         */
        
        Log.info("Running pipeline script")
        guard let dsid = pdata.dataSetId,
            let cppPath = sdata.generateFilePath() else
        {
            Log.error("missing script parameters)")
            return
        }
        
        let dirPath = "\(LocalServerConfig.shared.runsDir!)\(pdata.runObjectIdString)/"
        
        // need to create dir for run
        if let _ = SystemManager.createDirAtPath(dirPath) {
            Log.error("Could not create output directory at path: \(dirPath)")
        }
        
        // run pipeline
        let args : [String]  = [ dsid,
                                 cppPath,
                                 dirPath,
                                 LocalServerConfig.shared.awsConfigPath,
                                 LocalServerConfig.shared.omeroUser,
                                 LocalServerConfig.shared.omeroPwd ]
        
        Dispatcher.shared.serverQueue.async {
            SystemManager.runScript(Scripts.pipelineGlue + args) { (err, result) in
                if let _ = err {
                    self.updateRunStatus(runObjectId: pdata.runObjectId, status: RunJobStatus.Failed.rawValue)
                } else {
                    self.finishPipeline(pdata: pdata, sdata: sdata)
                }
            }
        }
    }
    
//    func finishPipeline(pdata: PipelineStartData,
//                        sdata: CellProfilerScriptData,
//                        completion: @escaping(String?, RequestError?) -> Void)
//    {
//        let jsonPath = "\(LocalServerConfig.shared.runsDir!)\(pdata.runObjectId)/\(ScriptConfigConstants.jsonOutputDir)/\(pdata.runObjectId).json"
//        
//        guard let dataString = SystemManager.readJsonFromPath(jsonPath) else {
//            Log.error("Could not read in JSON file: \(jsonPath)")
//            completion(nil, RequestError.failedDependency)
//            self.updateRunStatus(runObjectId: pdata.runObjectId, status: RunJobStatus.Failed.rawValue)
//            return
//        }
//        Log.info("successfully loaded JSON file: \(jsonPath)")
//        self.updateRunStatus(runObjectId: pdata.runObjectId, status: RunJobStatus.Completed.rawValue)
//        completion(dataString, nil)
//        
//        // start cleanup job
//        Log.info("Starting cleanup job for run id: \(pdata.runObjectIdString)")
//        let cleanupJob = StartPipelineCleanupJob(runId: pdata.runObjectIdString)
//        cleanupJob.execute { (result, error) in
//            Log.info("Cleanup job completed for run id: \(pdata.runObjectIdString) with status: \(result == false ? 0 : 1)")
//            if let err = error {
//                Log.info("Cleanup job failed for run id: \(pdata.runObjectIdString), error: \(err.description)")
//            }
//        }
//    }
    
    
    
    func finishPipeline(pdata: PipelineStartData,
                        sdata: CellProfilerScriptData)
    {
        let jsonPath = "\(LocalServerConfig.shared.runsDir!)\(pdata.runObjectId)/\(ScriptConfigConstants.jsonOutputDir)/\(pdata.runObjectId).json"
        
        guard var jsonDoc : [String:Any] = SystemManager.getJsonFromPath(jsonPath) else {
            Log.error("Could not read in JSON file: \(jsonPath)")
            return
        }
        
        jsonDoc[ScriptConfigConstants.runId] = pdata.runObjectIdString
        guard let data = try? JSONSerialization.data(withJSONObject: jsonDoc, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            Log.error("Could not convert JSON to data: \(jsonPath)")
            return
        }
        
        // now we need to save to disk
        // need path url
        let jsonUpdatedPath = "\(LocalServerConfig.shared.runsDir!)\(pdata.runObjectId)/\(pdata.runObjectId).json"
        let res = SystemManager.saveToDisk(data: data, path: jsonUpdatedPath)
        if res == false {
            Log.error("Could not write out JSON data: \(jsonUpdatedPath)")
        }
        Log.info("Successfully wrote updated json string")
        
        // run pipeline
        let args : [String]  = MongoConstants.importCommand(db: LocalServerConfig.shared.mongoDbName,
                                                            collection: MongoConstants.Collection.cellProfilerResultData,
                                                            path: jsonUpdatedPath)
    
        Dispatcher.shared.serverQueue.async {
            SystemManager.runScript(args) { (err, result) in
                if let _ = err {
                    Log.error("Could not import JSON doc into mongo: \(jsonUpdatedPath)")
                    self.updateRunStatus(runObjectId: pdata.runObjectId, status: RunJobStatus.Failed.rawValue)
                } else {
                    Log.info("Successfully imported JSON doc into mongo: \(jsonUpdatedPath)")
                    self.updateRunStatus(runObjectId: pdata.runObjectId, status: RunJobStatus.Completed.rawValue)
                    
                    // here we can kick off global keys update
                    self.keysUpdateJob = GlobalKeyUpdateJob(pdata.runObjectIdString)
                    self.keysUpdateJob.dispatch(completion: { (success, err) in
                        Log.info("Update keys job completed for run id: \(pdata.runObjectIdString) with status: \(success == false ? 0 : 1), error:\(String(describing: err))")
                    })
                }
                
                // start cleanup job
                Log.info("Starting cleanup job for run id: \(pdata.runObjectIdString)")
                let cleanupJob = StartPipelineCleanupJob(runId: pdata.runObjectIdString)
                cleanupJob.execute { (result, error) in
                    Log.info("Cleanup job completed for run id: \(pdata.runObjectIdString) with status: \(result == false ? 0 : 1)")
                    if let err = error {
                        Log.info("Cleanup job failed for run id: \(pdata.runObjectIdString), error: \(err.description)")
                    }
                }
            }
        }
    }
    
   
    func updateRunStatus(runObjectId:ObjectId, status:String) {
        // update run status in db
        let query : MongoKitten.Query = [ScriptConfigConstants.objectId:runObjectId]
        
        let updatedKvp : [String : Primitive?] = [ScriptConfigConstants.status : RunJobStatus.Completed.rawValue,
                                                  ScriptConfigConstants.endDate : Utilities.stringFromDate(Date())]
        
        MongoDB.shared.updateRecord(query: query,
                                    collection: MongoConstants.Collection.runs,
                                    newKvp: updatedKvp)
        { (result) in
            if result == true {
                Log.info("successfully updated status for run id: \(runObjectId), status: \(status) ")
            } else {
                Log.error("could not update job status for run id: \(runObjectId)")
            }
        }
    }
}
