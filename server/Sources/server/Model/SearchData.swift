//
//  SearchData.swift
//  Server
//
//  Created by Anton Pavlov on 4/27/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten
import BSON

struct SearchData {
    let kvp : [String:Any]
    lazy var encoder = BSONEncoder.init()
    
    init(with requestKvp:[String:Any]) {
        kvp = requestKvp
        Log.info("Successfully generated valid search data model with kvp:\(requestKvp)")
    }
    
    mutating func generateAggregatePipeline() -> [Document] {
        Log.info("Generating query")
        // we need to iterate cellular and wellular params

        var aggregateQueryDoc = [Document]()
        if let cellularSection = kvp[SearchConstants.cellular] as? [[String:Any]] {
            // iterate and values to global query
            Log.info("Cellular section present in query: \(cellularSection)")

            let _ = cellularSection.map { (item:[String : Any]) -> Void in
                // first get the key
                guard let key = item[SearchConstants.key] as? String else {
                    Log.error("Corrupt data, key missing:\(item)")
                    return
                }
                
                Log.info("Processing key: \(key)")
                let compositeKey = "\(MongoConstants.Params.documents).\(SearchConstants.cellular).\(key)"
                Log.info("Processing composite key: \(compositeKey)")
                
                // figure out which kind of query it is, just value or min max
                if let value = primitiveForKey(key: SearchConstants.value, dictionary: item) {
                    Log.info("adding value item: \(value) for key: \(compositeKey)")
                    let valueSubDoc : Document = [ compositeKey : value ] as Document
                    Log.info("matching subdoc:\(valueSubDoc)")
                    aggregateQueryDoc.append(valueSubDoc)
                }  else if let min = primitiveForKey(key: SearchConstants.min, dictionary: item),
                    let max = primitiveForKey(key: SearchConstants.max, dictionary: item)
                {
                    // min max query
                    Log.info("min: \(min), max: \(max)")
                    let minSubdoc : Document = [compositeKey:[MongoConstants.gte:min]as Document]
                    let maxSubdoc : Document = [compositeKey:[MongoConstants.lte:max]as Document]
                    let composite = Document.init(array: [minSubdoc, maxSubdoc])
                    let minMaxSubdoc = [ "$and" : composite ] as Document
                    Log.info("matching subdoc:\(minMaxSubdoc)")
                    aggregateQueryDoc.append(minMaxSubdoc)
                } else {
                    Log.error("Corrupt data, structure incorrect. Missing value or min/max:\(item)")
                }
            }
        }
        
        if let wellularSection = kvp[SearchConstants.wellular] as? [[String:Any]] {
            // iterate and values to global query
            Log.info("Wellular section present in query: \(wellularSection)")
            
            let _ = wellularSection.map { (item:[String : Any]) -> Void in
                // first get the key
                guard let key = item[SearchConstants.key] as? String else {
                    Log.error("Corrupt data, key missing:\(item)")
                    return
                }
                
                Log.info("Processing key: \(key)")
                let compositeKey = "\(MongoConstants.Params.documents).\(SearchConstants.wellular).\(key)"
                Log.info("Processing composite key: \(compositeKey)")
                
                // figure out which kind of query it is, just value or min max
                if let value = primitiveForKey(key: SearchConstants.value, dictionary: item) {
                    Log.info("adding value item: \(value) for key: \(compositeKey)")
                    let valueSubDoc : Document = [ compositeKey : value ] as Document
                    Log.info("matching subdoc:\(valueSubDoc)")
                    aggregateQueryDoc.append(valueSubDoc)
                }  else if let min = primitiveForKey(key: SearchConstants.min, dictionary: item),
                    let max = primitiveForKey(key: SearchConstants.max, dictionary: item)
                {
                    // min max query
                    Log.info("min: \(min), max: \(max)")
                    let minSubdoc : Document = [compositeKey:[MongoConstants.gte:min]as Document]
                    let maxSubdoc : Document = [compositeKey:[MongoConstants.lte:max]as Document]
                    let composite = Document.init(array: [minSubdoc, maxSubdoc])
                    let minMaxSubdoc = [ "$and" : composite ] as Document
                    Log.info("matching subdoc:\(minMaxSubdoc)")
                    aggregateQueryDoc.append(minMaxSubdoc)
                } else {
                    Log.error("Corrupt data, structure incorrect. Missing value or min/max:\(item)")
                }
            }
        }
        
        Log.info("Finished generating aggregate document: \(aggregateQueryDoc)")
        return aggregateQueryDoc
    }
    
    mutating func primitiveForKey(key:String, dictionary:[String:Any]) -> Primitive? {
        // incoming value will either be string, int, or double
        if  let doubleValue = dictionary[key] as? Double ,
            let encodedVal = try? encoder.encodePrimitive(doubleValue) {
                return encodedVal
        }
        if  let intValue = dictionary[key] as? Int ,
            let encodedVal = try? encoder.encodePrimitive(intValue) {
            return encodedVal
        }
        if  let stringValue = dictionary[key] as? String ,
            let encodedVal = try? encoder.encodePrimitive(stringValue) {
            return encodedVal
        }
        Log.error("Could not generate primitive for \(key)")
        return nil
    }
}
