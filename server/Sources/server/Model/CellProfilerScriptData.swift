//
//  CellProfilerScriptData.swift
//  Server
//
//  Created by Anton Pavlov on 4/13/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

struct CellProfilerScriptData {
    var userName : String?
    var fileName : String?
    var description : String?
    var data : Data?
    var date : Date!
    
    init?(with requestParts:[Part]) {
        userName = Utilities.extractText(key: ScriptConfigConstants.username, parts: requestParts)
        fileName = Utilities.extractText(key: ScriptConfigConstants.filename, parts: requestParts)
        data = Utilities.extractData(key: ScriptConfigConstants.data, parts: requestParts)
        description = Utilities.extractText(key: ScriptConfigConstants.description, parts: requestParts)
        date = Date()
        if isValid() == false {
            Log.error("Could not generate valid CellProfilerScriptData model object from request parts:\(requestParts). Self: \(debugDescription())")
            return nil
        }
    }
    
    init?(with doc:Document) {
        Log.error("Creting script data model with doc: \(doc)")
        userName = doc[ScriptConfigConstants.username] as? String
        fileName = doc[ScriptConfigConstants.filename] as? String
        description = doc[ScriptConfigConstants.description] as? String
        if  let _dateStr = doc[ScriptConfigConstants.date] as? String,
            let _dt = Utilities.dateFromString(_dateStr) {
            date = _dt
        }
        
        if isValid() == false {
            Log.error("Could not generate valid CellProfilerScriptData model object from Document: \(doc). Self: \(debugDescription())")
            return nil
        }
    }
    
    func generateFileUrl() -> URL? {
        if let path = generateFilePath() {
            let strPath = "file://" + path
            return URL.init(string: strPath)
        }
        Log.error("Could not generate file url for: \(self)")
        return nil
    }
    
    func generateFilePath() -> String? {
        if let fn = generateFileName() {
            return LocalServerConfig.shared.scriptsDir + fn
        }
        Log.error("Could not generate file path for: \(self)")
        return nil
    }
    
    func generateFileName() -> String? {
        if let fn = fileName, let un = userName  {
            return un + "_" + fn + "_" +  Utilities.stringFromDate(date) + "." + ScriptConfigConstants.fileExtension
        }
        Log.error("Could not generate file name for: \(self)")
        return nil
    }
    
    func generateBSONDoc() -> Document {
        return [ ScriptConfigConstants.username : userName,
                 ScriptConfigConstants.filename : fileName,
                 ScriptConfigConstants.description: description,
                 ScriptConfigConstants.date:Utilities.stringFromDate(date)]
    }
    
    func isValid() -> Bool {
        return  userName != nil
            && fileName != nil
            && date != nil
    }
    
    func debugDescription() -> String {
        return "Username: \(String(describing: userName)), filename:\(String(describing: fileName)), description:\(String(describing: description)), data:\(String(describing: data)), date:\(String(describing: date))"
    }
}
