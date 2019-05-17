//
//  ScriptDeleteJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/30/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class ScriptDeleteJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    let scriptId : String
    
    init(scriptId:String) {
        self.scriptId = scriptId
    }
    
    func execute(completion: @escaping (String?, RequestError?) -> Void) {
        MongoDB.shared.getRecord(recordId: scriptId, collection: MongoConstants.Collection.scripts) { (doc, err) in
            if let _d = doc {
                // once we have doc, we can create path to file
                // first we need to create script data object
                
                // generate model object from mongo data
                guard let _scriptData = CellProfilerScriptData(with: _d) else {
                    Log.error("could not generate valid pipeline from doc")
                    completion(nil, RequestError.failedDependency)
                    return
                }
                
                // generate path path for pipeline config file
                if let filePath = _scriptData.generateFilePath() {
                    Log.error("Successfully generated script file path for script id:\(self.scriptId), path: \(filePath)")
                    
                    // now we need to delete file
                    if let err = SystemManager.removeItemAtPath(filePath) {
                        Log.error("could not delete file at path: \(filePath), error: \(err)")
                        completion(nil, RequestError.failedDependency)
                        return
                    }
                    
                    // create query
                    // we need to go into mongo and fetch pipeline info
                    // create query
                    guard let query : MongoKitten.Query = try? [ScriptConfigConstants.objectId:ObjectId(self.scriptId)] else {
                        Log.error("could not get generate pipeline id query")
                        completion(nil, RequestError.failedDependency)
                        return
                    }
                    
                    // delete mongo record
                    MongoDB.shared.delete(query: query, collection: MongoConstants.Collection.scripts, completion: { (success, err) in
                        if success == false {
                            Log.error("could not delete mongo record for query: \(query)")
                            completion(nil, RequestError.failedDependency)
                        } else {
                            completion("successfully deleted script: \(self.scriptId)", nil)
                        }
                    })
                    
                } else {
                    Log.error("could not generate file path")
                    completion(nil, RequestError.failedDependency)
                }
            } else {
                Log.error("could not get pipeline doc from mongo")
                completion(nil, RequestError.failedDependency)
            }
        }
    }
}
