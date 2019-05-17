//
//  RunDeleteJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/30/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class RunDeleteJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    let runId : String
    
    init(runId:String) {
        self.runId = runId
    }
    
    func execute(completion: @escaping (String?, RequestError?) -> Void) {
        // we first need to delete run directory on disk
        // comprise directory path
        let runDir = "\(LocalServerConfig.shared.runsDir!)\(runId)"
        
        if let _e = SystemManager.removeItemAtPath(runDir) {
            Log.error("could not delete dir at path: \(runDir), error: \(_e)")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // now delete mongo record
        // create query
        guard let query : MongoKitten.Query = try? [ScriptConfigConstants.objectId:ObjectId(self.runId)] else {
            Log.error("could not get generate run id query")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // delete mongo record
        MongoDB.shared.delete(query: query, collection: MongoConstants.Collection.runs, completion: { (success, err) in
            if success == false {
                Log.error("could not delete mongo record for query: \(query)")
                completion(nil, RequestError.failedDependency)
            } else {
                completion("successfully deleted script: \(self.runId)", nil)
            }
        })
    }
}
