//
//  CellProfilerPostScriptJob.swift
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

class CellProfilerPostScriptJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    var scriptData : CellProfilerScriptData?
    
    init(_ data:CellProfilerScriptData) {
        scriptData = data
    }
    
    func execute(completion: @escaping(String?, RequestError?) -> Void) {
        guard let sd = scriptData, let byteData = sd.data else {
            Log.error("could not get data from request")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // first we should save bits to disk
        // generate url
        guard let pathUrl = sd.generateFileUrl() else {
            Log.error("could not generate file url")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // try to write to url
        let result = SystemManager.saveToDisk(data: byteData, url: pathUrl)
        
        if result == false {
            Log.error("could not write to file")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        // generate bson doc
        let bson = sd.generateBSONDoc()
        
        // insert bson doc
        MongoDB.shared.insert(doc: bson,
                              collection: MongoConstants.Collection.scripts)
        { (success) in
            if success {
                // save record to mongo
                //tbd
                completion("success", nil)
            } else {
                completion(nil, RequestError.failedDependency)
            }
        }
    }
}
