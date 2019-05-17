//
//  GetGlobalKeysJob.swift
//  Server
//
//  Created by Anton Pavlov on 5/4/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class GetGlobalKeysJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    
    func execute(completion: @escaping(String?, RequestError?) -> Void) {
        // create query
        let query : MongoKitten.Query = [MongoConstants.Components.component : MongoConstants.Components.cellProfiler]
        
        MongoDB.shared.get(query: query,
                           collection: MongoConstants.Collection.globalKeys)
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
