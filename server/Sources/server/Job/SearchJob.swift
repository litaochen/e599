//
//  SearchJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/27/19.
//

import Foundation

import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class SearchJob : Job {
    typealias ReturnType = String
    typealias ErrorType = RequestError
    var searchData : SearchData
    
    init(_ searchData:SearchData) {
        self.searchData = searchData
    }
    
    func execute(completion: @escaping (String?, RequestError?) -> Void) {
        // create query
        Log.error("Executing search job")
        let aggregatePipeline  = searchData.generateAggregatePipeline()
        
        let projection : MongoKitten.Document = [
            "run_id" : 1, "_id":0
        ]
        
        // first need to query results collection
        MongoDB.shared.aggregate(pipeline: aggregatePipeline,
                                 collection: MongoConstants.Collection.cellProfilerResultData,
                                 projection: projection)
        { (docs, err) in
            if let _e = err {
                Log.error("Failed to run aggregate pipeline:\(aggregatePipeline) with error:\(_e)")
                completion(nil, RequestError.failedDependency)
            } else {
                guard let docIds = docs, docIds.count > 0  else {
                    Log.info("Aggregate query returned blank:\(aggregatePipeline)")
                    completion("", nil)
                    return
                }
                
                var objectIds = Document(isArray: true)
                let _ = docIds.map({ (doc) -> Void in
                    if let runIdHex = doc[ScriptConfigConstants.runId] as? String,
                        let objId = try? ObjectId.init(runIdHex)
                    {
                        return objectIds.append(objId)
                    }
                })
                
                guard objectIds.count > 0 else {
                    Log.error("Could not translate run ids to object ids:\(docIds)")
                    completion("", nil)
                    return
                }
                
                // now we run query against $in
                let inQuery : Query = [ScriptConfigConstants.objectId:[MongoConstants.inOpr:objectIds]]
                
                MongoDB.shared.get(query: inQuery,
                                   collection: MongoConstants.Collection.runs)
                { (docs, err) in
                    if let _ = err {
                        Log.error("Error getting runs for in query:\(inQuery)")
                        completion(nil, RequestError.failedDependency)
                    } else {
                        Log.error("Success getting runs for in query:\(inQuery)")
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
    }
}
