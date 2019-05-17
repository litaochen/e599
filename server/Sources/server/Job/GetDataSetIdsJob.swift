//
//  GetDataSetIdsJob.swift
//  Server
//
//  Created by Anton Pavlov on 5/5/19.


import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class GetDataSetIdsJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError

    func execute(completion: @escaping(String?, RequestError?) -> Void) {
        /*
             # arg1: Full path config file name.
             # arg2: OMERO user name
             # arg3: OMERO passwd
             # arg4: Full path output directory
         */
        let tempUUID = UUID.init().uuidString
        let outputPath =  "\(LocalServerConfig.shared.getDataSetDir!)\(tempUUID)"
       
        // need to create dir for this
        if let _ = SystemManager.createDirAtPath(outputPath) {
            Log.error("Could not create output directory at path: \(outputPath)")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // run pipeline
        let args : [String]  = [ LocalServerConfig.shared.awsConfigPath,
                                 LocalServerConfig.shared.omeroUser,
                                 LocalServerConfig.shared.omeroPwd,
                                 outputPath]

        Dispatcher.shared.serverQueue.async {
            SystemManager.runScript(Scripts.getDataSetId + args) { (err, result) in
                if let e = err {
                    Log.error("Failed to run data set id script: \(e)")
                    completion(nil, RequestError.failedDependency)
                } else {
                    Log.info("Successfully ran data set id script")
                    self.completeRequest(dirPath: outputPath, completion: completion)
                }
            }
        }
    }
    
    func completeRequest(dirPath:String,
                         completion: @escaping(String?, RequestError?) -> Void)
    {
        // we need to read json from path
        let jsonFilePath = "\(dirPath)/\(LocalServerConfig.shared.omeroUser)_dataset_list.json"
        if let json = SystemManager.readJsonFromPath(jsonFilePath) {
            Log.info("Successfully read in data set json from path:\(jsonFilePath), json:\(json)")
            completion(json, nil)
            
            // now delete file
            if let e = SystemManager.removeItemAtPath(dirPath) {
                Log.error("could not delete dir at path: \(dirPath), error: \(e)")
            } else {
                Log.info("Succesfully deleted dir at path:\(dirPath)")
            }
        } else {
            Log.error("Failed to read in data set json from path:\(dirPath)")
            completion(nil, RequestError.failedDependency)
        }
    }
}
