//
//  SystemManager.swift
//  Server
//
//  Created by Anton Pavlov on 3/13/19.
//

import Foundation
import LoggerAPI
import ZIPFoundation
import MongoKitten
import BSON

class SystemManager {
    
//    func runScript(_ args:String..., completion:(ServerError?, String?)->Void) {
//        runScript(args, completion: completion)
//    }
    
    class func runScript(_ script:ScriptExecutable,
                   args : [String] = [],
                   completion:(ServerError?, String?)->Void)
    {
        return runScript(script.getScript() + args, completion:completion)
    }
    
//    func runScript(_ args:[String]) -> String? {
//        Log.info("Executing script: " + "\(args)")
//        let task = Process()
//        task.launchPath = "/usr/bin/env"
//        task.arguments = args
//        let pipe = Pipe()
//        task.standardOutput = pipe
//        task.launch()
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        task.waitUntilExit()
//        Log.info("FINISHED Script: " + "\(args)")
//        return String(data: data, encoding: String.Encoding.utf8)
//    }
    
    class func runScript(_ args:[String], completion:(ServerError?, String?)->Void) {
        Log.info("Executing script: " + "\(args)")
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        let outPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errorPipe
        task.launch()
        task.waitUntilExit()
        if (task.terminationStatus == 0) {
            Log.info("FINISHED Executing script: " + "\(args)")
            let data = outPipe.fileHandleForReading.readDataToEndOfFile()
            completion(nil, String(data: data, encoding: String.Encoding.utf8))
        } else {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errStr = String(data: data, encoding: String.Encoding.utf8)
            Log.error("FAILED Executing script: \(args), error: \(String(describing: errStr))")
            completion(ServerError("Could not spawn process"), errStr)
        }
    }
    
    class func saveToDisk(data:Data, url:URL) -> Bool {
        do {
            try data.write(to: url)
            Log.info("Wrote successfully to: " + "\(url)")
            return true
        } catch let err {
            Log.error("Failed to write to url: " + "\(url)")
            Log.error("\(err)")
            return false
        }
    }
    
    class func saveToDisk(data:Data, path:String) -> Bool {
        guard let url = Utilities.converToURL(path) else {
            Log.error("Could not convert to url: " + "\(path)")
            return false
        }
        do {
            try data.write(to: url)
            Log.info("Wrote successfully to: " + "\(url)")
            return true
        } catch let err {
            Log.error("Failed to write to url: " + "\(url)")
            Log.error("\(err)")
            return false
        }
    }
    
    class func fileExistsAt(_ path:String) -> Bool {
        let fm = FileManager()
        return fm.fileExists(atPath: path)
    }
    
    class func removeItemAtPath(_ path:String) -> ServerError? {
        guard let itemUrl = Utilities.converToURL(path) else {
            return ServerError("Could not convert path to url: \(path)")
        }
        do {
            let fm = FileManager()
            try fm.removeItem(at: itemUrl)
            Log.info("Successfully removed item at path: " + "\(path)")
            return nil
        } catch {
            let errorStr = "Failed to remove item at path: " + "\(path), error:\(error.localizedDescription)"
            Log.error(errorStr)
            return ServerError(errorStr)
        }
    }
    
    class func removeItemsOnDisk(_ paths:[String]) -> [ServerError] {
        return paths.reduce([ServerError]()) { (arr, path) -> [ServerError] in
            if let _e = self.removeItemAtPath(path) {
                var mutableArr = arr
                mutableArr.append(_e)
                return mutableArr
            }
            return arr
        }
    }
    
    class func moveItem(from fromPath:String, to toPath:String) -> ServerError? {
        guard let fromUrl = Utilities.converToURL(fromPath),
              let toUrl = Utilities.converToURL(toPath) else {
                return ServerError("Could not convert fromOath to url: \(fromPath), toPath:\(toPath)")
        }
        do {
            let fm = FileManager()
            try fm.moveItem(at: fromUrl, to: toUrl)
            Log.info("Successfully moved item from path: " + "\(fromPath) to path:\(toPath)")
            return nil
        } catch {
            let errorStr = "Failed to move item from path: " + "\(fromPath) to path:\(toPath), error:\(error.localizedDescription)"
            Log.error(errorStr)
            return ServerError(errorStr)
        }
    }
    
    class func applicationPath() -> String {
        let fm = FileManager.default
        return fm.currentDirectoryPath
    }
    
    class func getJsonFromPath<T:Swift.Collection>(_ path:String) -> T? {
        guard let fileUrl = Utilities.converToURL(path) else {
            Log.error("could not create json file url for path: \(path)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileUrl) else {
            Log.error("Failed to load json file data: \(path)")
            return nil
        }
        
        Log.info("successfully loaded url json file data: \(path)")
        
        guard let dataObj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments), let mapped = dataObj as? T else {
            Log.error("Could not read in config JSON object: \(path)")
            return nil
        }
        Log.info("successfully loaded JSON at path: \(path)")
        return mapped
    }
    
    class func generateBsonFromPath(_ path:String) -> Document? {
        guard let fileUrl = Utilities.converToURL(path) else {
            Log.error("could not create bson file url for path: \(path)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileUrl) else {
            Log.error("Failed to load bson file data: \(path)")
            return nil
        }
        
        Log.info("successfully loaded url bson file data: \(path)")
        return Document.init(data: data)
    }
    
    class func getDataFromUrl(_ url:URL) -> Data? {
        do {
            let data = try Data.init(contentsOf: url)
            Log.info("Retrieved data successfully from url: \(url)")
            return data
        } catch {
            Log.error("Could not get data  from url: \(url), error:\(error)")
            return nil
        }
    }
    
    class func readJsonFromPath(_ path:String) -> String? {
        guard let pathUrl = Utilities.converToURL(path) else {
            Log.error("could not create json file url: \(path)")
            return nil
        }
        
        guard let dataString = try? String.init(contentsOf: pathUrl) else {
            Log.error("Could not read in JSON file at: \(path)")
            return nil
        }
        return dataString
    }
    
    class func zipFile(inPath:String, outPath:String) -> ServerError? {
        if let inurl = Utilities.converToURL(inPath),
            let outurl = Utilities.converToURL(outPath)
        {
            let fileManager = FileManager()
            do {
                try fileManager.zipItem(at: inurl, to: outurl)
                return nil
            } catch let e {
                let errStr = "Could not compress file at: \(inurl) to:\(outurl). Error: \(e)";
                Log.error(errStr)
                return ServerError.init(errStr, e.localizedDescription)
            }
        } else {
            return ServerError.init("Could not convert paths to urls: \(inPath) to:\(outPath)")
        }
    }
    
    class func createDirAtPath(_ path:String) -> ServerError? {
        let fileManager = FileManager()
        var sysError = ServerError.init("Could not create dir url at path: \(path)")
        guard let url = Utilities.converToURL(path) else {
            Log.error(sysError.description)
            return sysError
        }
        
        do {
            let perm = [FileAttributeKey.posixPermissions : 0o777]
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false, attributes: perm)
            Log.info("Successfully created dir at path: \(path)")
            return nil
        } catch {
            sysError.detailedDescription = error.localizedDescription
            return sysError
        }
    }
}
