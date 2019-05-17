//
//  PipelineRunsGetJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/18/19.
//

import Foundation

import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class PipelineRunsGetJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    let username : String?
    
    init(_ username:String?) {
        self.username = username
    }
    
    func execute(completion: @escaping(String?, RequestError?) -> Void) {
        // create query
        var query : MongoKitten.Query
        if let _usr = self.username {
            query = [ScriptConfigConstants.username:_usr]
        } else {
            query = MongoKitten.Query.nothing
        }
        
        MongoDB.shared.get(query: query,
                           collection: MongoConstants.Collection.runs)
        { (docs, err) in
            if let _ = err {
                completion(nil, RequestError.failedDependency)
            } else {
                if let _d = docs,
                    let jdata = try? JSONEncoder().encode(_d),
                    let jstr = String(data: jdata, encoding: String.Encoding.utf8)
                {
                    completion(jstr, nil)
                } else {
                    Log.error("Could not encode JSON file and convert to string")
                    completion(nil, RequestError.failedDependency)
                }
            }
        }
    }
}
