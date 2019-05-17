//
//  Utilities.swift
//  Server
//
//  Created by Anton Pavlov on 3/17/19.
//

import Foundation
import Kitura
import KituraContracts

class Utilities {
    class func converToURL(_ str:String) -> URL? {
        let appended = "file://\(str)"
        return URL(string: appended)
    }
    
    class func stringFromDate(_ inputDate:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = ScriptConfigConstants.dateFormat
        return formatter.string(from: inputDate)
    }
    
    class func dateFromString(_ str:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = ScriptConfigConstants.dateFormat
        return formatter.date(from: str)
    }
    
    class func extractText(key:String, parts:[Part])->String? {
        return parts.filter { (p) -> Bool in
            return p.name == key
        }.first?.body.asText
    }
    
    class func extractJson(key:String, parts:[Part])-> [String:Any]? {
        return parts.filter { (p) -> Bool in
            return p.name == key
            }.first?.body.asJSON
    }
    
    class func extractData(key:String, parts:[Part])->Data? {
        return parts.filter { (p) -> Bool in
            return p.name == key
            }.first?.body.asRaw
    }
    
    class func constructFilePath(dir:String, fileNameComps:[String], fileExtension:String) -> String {
        let filename = fileNameComps.joined(separator: ConfigConstants.fileComponentSeparator)
        return "\(dir)/\(filename).\(fileExtension)"
    }
    
    class func constructFileUrl(dir:String, fileNameComps:[String], fileExtension:String) -> URL? {
        let filename = fileNameComps.joined(separator: ConfigConstants.fileComponentSeparator)
        let fullPath = "\(dir)/\(filename).\(fileExtension)"
        return self.converToURL(fullPath)
    }
    
    class func flattenErrors(_ errors:[ServerError]) -> ServerError? {
        guard errors.count > 0 else {
            return nil
        }
        let reducedDescription = errors.reduce("Archiving error(s) occurred:", { (outString, err) -> String in
            return outString + err.description
        })
        return ServerError(reducedDescription)
    }
}
