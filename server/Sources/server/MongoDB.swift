//
//  MongoDB.swift
//  CHTTPParser
//
//  Created by Anton Pavlov on 3/20/19.
//

import Foundation
import MongoKitten
import LoggerAPI
import Kitura
import KituraContracts

class MongoDB {
    static let shared = MongoDB()
    private var database : Database?
    
    func initDB() {
        do {
            database = try Database.synchronousConnect("mongodb://\(LocalServerConfig.shared.mongoUsr):\(LocalServerConfig.shared.mongoPwd)@localhost/\(LocalServerConfig.shared.mongoDbName)")
            Log.info("Connected to mongo db successfully")
        } catch _ {
            Log.error("Failed to connect to db")
        }
    }
    
    func testFind(completion: @escaping (String?)->Void ) {
        if let db = database {
            let dataCollection = db["data"]
            dataCollection.findOne("image_id" == 1).whenSuccess { (document) in
                Log.info("Fetched doc:" + "\(String(describing: document))")
                if let doc = document {
                    completion(doc.debugDescription)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func insert(doc:Document,
                collection:String,
                completion: @escaping (Bool) -> Void)
    {
        Log.info("Performing insert operation with doc: \(doc), collection: \(collection)")
        if let _c = getCollection(collection) {
            let future = _c.insert(doc)
            future.whenSuccess { (reply) in
                Log.info("Inserted record: " + "\(doc)"
                    + " into colletion: " + "\(collection), reply: \(reply)")
                completion(true)
            }
            future.whenFailure({ (e) in
                Log.error("Failed to inserted record: " + "\(doc)"
                        + " into colletion: " + "\(collection)")
                Log.error("\(e)")
                completion(false)
            })
        }
    }
    
    func get(query:Query,
                collection:String,
                completion: @escaping ([Document]?, Error?) -> Void)
    {
        return self.get(query: query, collection: collection, projection: nil, completion: completion)
    }
    
    func get(query:Query,
             collection:String,
             projection:Document? = nil,
             completion: @escaping ([Document]?, Error?) -> Void)
    {
        Log.info("Performing get operation with query: \(query), collection: \(collection), projection: \(String(describing: projection))")
        if let _c = getCollection(collection) {
            let future = projection != nil
                                    ? _c.find(query).project(Projection(document: projection!)).getAllResults()
                                    : _c.find(query).getAllResults()
            future.whenSuccess { (docs) in
                Log.info("Fetched records for query: " + "\(query)")
                completion(docs, nil)
            }
            future.whenFailure({ (e) in
                Log.error("Failed to fetch  records: " + "\(query)"
                    + " into colletion: " + "\(collection)")
                Log.error("\(e)")
                completion(nil, e)
            })
        }
    }
    
    func aggregate(pipeline:[Document],
                   collection:String,
                   projection:Document? = nil,
                   completion: @escaping ([Document]?, Error?) -> Void)
    {
        Log.info("Performing aggregate operation with pipeline: \(pipeline), collection: \(collection), projection: \(String(describing: projection))")
        if let _c = getCollection(collection) {
            let aggCursor = _c.aggregate()
            let _ = pipeline.map { (subdoc) -> Void in
                aggCursor.match(Query.custom(subdoc))
            }
            if let projDoc = projection { aggCursor.project(Projection(document: projDoc)) }
            self.runAggregateCursor(cursor: aggCursor, completion: completion)
        }
    }
    
    func runAggregateCursor(cursor:AggregateCursor<Document>,
                            completion: @escaping ([Document]?, Error?) -> Void)
    {
        let future = cursor.getAllResults()
        future.whenSuccess { (_docs) in
            Log.info("Fetched records for aggregate query: " + "\(_docs)")
            completion(_docs, nil)
        }
        
        future.whenFailure { (e) in
            Log.error("Failed to aggregate  regords")
            Log.error("\(e)")
            completion(nil, e)
        }
    }
    
    func findOne(query:Query,
             collection:String,
             projection:Document? = nil,
             completion: @escaping (Document?, Error?) -> Void)
    {
        Log.info("Performing findOne operation with query: \(query), collection: \(collection), projection: \(String(describing: projection))")
        if let _c = getCollection(collection) {
            let future = projection != nil
                ? _c.find(query).project(Projection(document: projection!)).getFirstResult()
                : _c.find(query).getFirstResult()
            future.whenSuccess { (docs) in
                Log.info("Fetched records for query: " + "\(query)")
                completion(docs, nil)
            }
            future.whenFailure({ (e) in
                Log.error("Failed to fetch  records: " + "\(query)"
                    + " into colletion: " + "\(collection)")
                Log.error("\(e)")
                completion(nil, e)
            })
        }
    }
    
    func findOne(query:Query,
                 collection:String,
                 completion: @escaping (Document?, Error?) -> Void)
    {
        findOne(query: query, collection: collection, projection: nil, completion: completion)
    }
    
    func delete(query:Query,
                collection:String,
                completion: @escaping (Bool, Error?) -> Void)
    {
        Log.info("Performing delete operation with query: \(query), collection: \(collection)")
        if let _c = getCollection(collection) {
            let future = _c.deleteAll(where: query)
            future.whenSuccess { (res) in
                Log.info("Successfully deleted records for query: " + "\(query)")
                completion(true, nil)
            }
            future.whenFailure({ (e) in
                Log.error("Failed to delete  records: " + "\(query)"
                    + " into colletion: " + "\(collection)")
                Log.error("\(e)")
                completion(false, e)
            })
        }
    }
    
    func getCollection(_ name:String) -> MongoKitten.Collection? {
        return database?[name]
    }
    
    func updateRecord(query:Query,
                      collection:String,
                      newKvp:[String:Primitive?],
                      completion:@escaping (Bool) -> Void)
    {
        Log.info("Performing updateRecord with query: \(query), collection: \(collection), kvps:\(newKvp)")
        if let _c = getCollection(collection) {
            let future = _c.update(where: query, setting: newKvp, multiple: true)
            future.whenSuccess { (doc) in
                Log.info("Successfully updated record for query: " + "\(query), doc:\(doc)")
                completion(true)
            }
            future.whenFailure({ (e) in
                Log.error("Failed to update record: " + "\(query)"
                    + " in colletion: " + "\(collection)")
                Log.error("\(e)")
                completion(false)
            })
        }
    }
    
    func update(query:Query,
                      collection:String,
                      document:Document,
                      completion:@escaping (Bool) -> Void)
    {
        Log.info("Performing updateRecord with query: \(query), collection: \(collection), document:\(document)")
        if let _c = getCollection(collection) {
            let future = _c.update(where: query, to: document)
            future.whenSuccess { (doc) in
                Log.info("Successfully updated record for query: " + "\(query), doc:\(doc)")
                completion(true)
            }
            future.whenFailure({ (e) in
                Log.error("Failed to update record: " + "\(query)"
                    + " in colletion: " + "\(collection)")
                Log.error("\(e)")
                completion(false)
            })
        }
    }
}

// Cell Profiler
extension MongoDB {
    func getRecord(recordId:String, collection:String, completion: @escaping (Document?, Error?) -> Void)
    {
        // we need to go into mongo and fetch pipeline info
        // create query
        guard let query : MongoKitten.Query = try? [ScriptConfigConstants.objectId:ObjectId(recordId)] else {
            Log.error("could not get generate record id query")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        MongoDB.shared.findOne(query: query,
                               collection: collection)
        { (doc, err) in
            if let e = err {
                Log.error("error getting doc from mongo: \(e), query:\(query)")
                completion(nil, RequestError.failedDependency)
            } else {
                if let _d = doc {
                    completion(_d, nil)
                } else {
                    Log.error("could not get document from mongo for query: \(query)")
                    completion(nil, RequestError.failedDependency)
                }
            }
        }
    }
}
