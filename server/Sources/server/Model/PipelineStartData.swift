//
//  PipelineStartData.swift
//  Server
//
//  Created by Anton Pavlov on 4/13/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

struct PipelineStartData {
    let runObjectId = ObjectId()
    var runObjectIdString : String {
        return runObjectId.hexString
    }
    var pipelineId : String?
    var dataSetId : String?
    var username : String?
    var pipelineName : String?
    var pipelineDescription : String?
    let startDate = Utilities.stringFromDate(Date())
    
    init?(with requestParts:[Part]) {
        pipelineId = Utilities.extractText(key: ScriptConfigConstants.pipelineId, parts: requestParts)
        dataSetId = Utilities.extractText(key: ScriptConfigConstants.dataSetId, parts: requestParts)
        username = Utilities.extractText(key: ScriptConfigConstants.username, parts: requestParts)
        pipelineName = Utilities.extractText(key: ScriptConfigConstants.pipelineName, parts: requestParts)
        pipelineDescription = Utilities.extractText(key: ScriptConfigConstants.description, parts: requestParts)
    }
    
    func generateBSONDoc(status:String) -> Document {
        return [ ScriptConfigConstants.objectId : runObjectId,
                 ScriptConfigConstants.pipelineId : pipelineId,
                 ScriptConfigConstants.dataSetId : dataSetId,
                 ScriptConfigConstants.username : username,
                 ScriptConfigConstants.status : status,
                 ScriptConfigConstants.startDate : startDate,
                 ScriptConfigConstants.pipelineName : pipelineName ?? "",
                 ScriptConfigConstants.description : pipelineDescription ?? ""]
    }
}
