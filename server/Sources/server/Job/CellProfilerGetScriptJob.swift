//
//  CellProfilerGetScriptJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/13/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class CellProfilerGetScriptJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    let username : String
    
    init(_ username:String) {
        self.username = username
    }
    
    func execute(completion: @escaping(String?, RequestError?) -> Void) {
        // create query
        let query : MongoKitten.Query = [ScriptConfigConstants.username:username]
        
        MongoDB.shared.get(query: query,
                           collection: MongoConstants.Collection.scripts)
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
                }
            }
        }
    }
}
