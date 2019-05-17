//
//  GlobalKeyUpdateJob.swift
//  Server
//
//  Created by Anton Pavlov on 5/3/19.
//

import Foundation
import KituraContracts
import LoggerAPI
import MongoKitten

class GlobalKeyUpdateJob : Job {
    let cellComponent = "cell"
    let wellComponent = "well"
    let cellDocPath = "$documents.cell_level_summary"
    let wellDocPath = "$documents.well_level_summary"
    let cellArrPath = "$cell"
    let wellArrPath = "$well"
    typealias ReturnType = Bool
    typealias ErrorType = ServerError
    var runId : String
    
    // we need run id
    init(_ runId:String) {
        self.runId = runId
    }
    
    func execute(completion: @escaping (Bool?, ServerError?) -> Void) {
        // find record for id
        // need to create query
        // run id is contained in documents items
        // documents.run_id
        
        // we will need to do aggregate query
        // get collection
        guard let collection = MongoDB.shared.getCollection(MongoConstants.Collection.cellProfilerResultData) else {
            let error = ServerError("could not get collection:\(MongoConstants.Collection.cellProfilerResultData)")
            Log.error(error.description)
            completion(false, error)
            return
        }
        
        // get cursor
        let cursor = collection.aggregate()
        
        // first match on doc id
        let idQuery : Query = ["documents.run_id" : runId]
        Log.info("Match query is: \(idQuery)")
        cursor.match(idQuery)
        
        // project to get cell and well arrays
        let arrProjDoc : Document = [
            cellComponent: [MongoConstants.arrayElemAt: [cellDocPath, 0] as Document] as Document,
            wellComponent: [MongoConstants.arrayElemAt: [wellDocPath, 0] as Document] as Document
        ]

        let arrayProjection = Projection(document: arrProjDoc)
        Log.info("Array projection is: \(arrayProjection)")
        cursor.project(arrayProjection)

        // project to get first element of arrays
        let arrElemProj : Document = [
            cellComponent: [MongoConstants.arrayElemAt: [cellArrPath, 0] as Document] as Document,
            wellComponent: [MongoConstants.arrayElemAt: [wellArrPath, 0] as Document] as Document
        ]
        let elemProjection = Projection.init(document: arrElemProj)
        Log.info("Element projection is: \(elemProjection)")
        cursor.project(elemProjection)
        
        // run cursor
        MongoDB.shared.runAggregateCursor(cursor: cursor) { (docs, err) in
            if let e = err {
                // there's an error
                let serverErr = ServerError("Error fetching run data document for id: \(self.runId), error:\(e)")
                Log.error(serverErr.description)
                completion(false, serverErr)
            } else if let _d = docs {
                Log.info("Fetched doc: \(_d)")
                self.processDocumnet(document: _d[0], collection:collection, completion: completion)
            } else {
                Log.info("Fetch for doc id: \(self.runId) came back empty")
            }
        }
    }
    
    func processDocumnet(document:Document, collection:MongoKitten.Collection, completion:@escaping (Bool, ServerError?) -> Void) {
        // we need to extract all keys from cellular and wellular sections
        var cellKeys = Set<String>()
        var wellKeys = Set<String>()
        
        if let cellSection = document[cellComponent] as? Document {
            let _ = cellSection.map { (entry:(key:String, _:Primitive)) -> Void in
                cellKeys.insert(entry.key)
            }
        }
        
        if let wellSection = document[wellComponent] as? Document {
            let _ = wellSection.map { (entry:(key:String, _:Primitive)) -> Void in
                wellKeys.insert(entry.key)
            }
        }
        
        if cellKeys.isEmpty {
            let error = ServerError("Could not get cell keys")
            Log.error(error.description)
        }
        if wellKeys.isEmpty {
            let error = ServerError("Could not get well keys")
            Log.error(error.description)
        }
        
        // get cell profiler keys doc
        let query : Query = [ MongoConstants.Components.component : MongoConstants.Components.cellProfiler ]
        MongoDB.shared.findOne(query: query, collection: MongoConstants.Collection.globalKeys) { (doc, err) in
            if let e = err {
                // there's an error
                let serverErr = ServerError("Error fetching existing keys document for id: \(self.runId), error:\(e)")
                Log.error(serverErr.description)
                completion(false, serverErr)
            } else {
                var finalDoc : Document
                let updateCompletion: (Bool)-> Void = {
                    (success) in
                    if (success == true) {
                        Log.info("updated global keys successfully: \(self.runId)")
                        completion(true, nil)
                    } else {
                        let error = ServerError("Failed to update global keys: \(self.runId)")
                        Log.error(error.description)
                        completion(false, error)
                    }
                    
                }
                if let _d = doc {
                    Log.info("current keys doc is: \(_d)")
                    finalDoc = self.updateDocument(doc: _d, cellKeys: cellKeys, wellKeys: wellKeys)
                    Log.info("Final doc to be updated: \(finalDoc)")
                    MongoDB.shared.update(query: query, collection: MongoConstants.Collection.globalKeys,
                                          document: finalDoc,
                                          completion:updateCompletion)
                } else {
                    Log.info("Fetch for doc id: \(self.runId) came back empty")
                    finalDoc = self.generateNewDoc(cellKeys: cellKeys, wellKeys: wellKeys)
                    Log.info("Final doc to be updated: \(finalDoc)")
                    MongoDB.shared.insert(doc: finalDoc,
                                          collection: MongoConstants.Collection.globalKeys,
                                          completion:updateCompletion)
                }
            }
        }
    }
    
    func updateDocument(doc:Document, cellKeys:Set<String>, wellKeys:Set<String>) -> Document {
        var finalDoc = doc
        if let currentCell = doc[cellComponent] as? [String] {
            let finalCellSet = cellKeys.union(currentCell)
            finalDoc[cellComponent] = Document(array: Array<String>(finalCellSet))
        }
        if let currentWell = doc[wellComponent] as? [String] {
            let finalWellSet = cellKeys.union(currentWell)
            finalDoc[wellComponent] = Document(array: Array<String>(finalWellSet))
        }
        finalDoc[MongoConstants.Components.component] = MongoConstants.Components.cellProfiler
        return finalDoc
    }
    
    func generateNewDoc(cellKeys:Set<String>, wellKeys:Set<String>) -> Document {
        let doc : Document = [
            cellComponent : Document(array: Array<String>(cellKeys)),
            wellComponent : Document(array: Array<String>(wellKeys)),
            MongoConstants.Components.component : MongoConstants.Components.cellProfiler
        ]
        return doc
    }
}
