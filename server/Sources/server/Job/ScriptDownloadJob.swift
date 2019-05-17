//
//  ScriptDownloadJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/24/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class ScriptDownloadJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    let scriptId : String
    
    init(scriptId:String) {
        self.scriptId = scriptId
    }
    
    func execute(completion: @escaping (String?, RequestError?) -> Void) {
        // first we have to fetch script record from mongo
        
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
                    completion(filePath, nil)
                } else {
                    Log.error("could not generate file path")
                    completion(nil, RequestError.failedDependency)
                    return
                }
            } else {
                Log.error("could not get pipeline doc from mongo")
                completion(nil, RequestError.failedDependency)
            }
        }
    }
}
