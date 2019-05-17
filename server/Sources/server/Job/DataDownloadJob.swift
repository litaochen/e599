//
//  DataDownloadJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/21/19.
//

import Foundation

import Kitura
import KituraContracts
import LoggerAPI
import MongoKitten

class DataDownloadJob : Job {
    typealias ReturnType = Data
    typealias ErrorType = RequestError
    let fileUrl : URL
    
    init(fileUrl:URL) {
        self.fileUrl = fileUrl
    }
    
    func execute(completion: @escaping(Data?, RequestError?) -> Void) {
        // try to get data from url
        guard let fileData = SystemManager.getDataFromUrl(fileUrl) else {
            Log.error("Could not get data from file url: \(fileUrl)")
            completion(nil, RequestError.failedDependency)
            return
        }
        
        Log.info("Loaded data succcesfully for file url: \(fileUrl)")
        completion(fileData, nil)
    }
}

class CellProfilerCellularGetJob : DataDownloadJob {
    init?(_ runId:String) {
        // we need to formulate URL for file retrieval
        guard let fileUrl = CellProfilerCellularGetJob.fileUrl(runId: runId) else  {
            Log.error("Could not generate cellular file url for run id: \(runId)")
            return nil
        }
        super.init(fileUrl: fileUrl)
    }
    
    class func fileUrl(runId:String) -> URL? {
        guard let fileUrl = Utilities.constructFileUrl(dir: "\(LocalServerConfig.shared.runsDir!)\(runId)",
            fileNameComps: [ArchiveConstants.cellularOut],
            fileExtension: ArchiveConstants.Extensions.zip) else
        {
            Log.error("Could not generate cellular file url for run id: \(runId)")
            return nil
        }
        return fileUrl
    }
    
    class func filePath(runId:String) -> String {
        return Utilities.constructFilePath(dir: "\(LocalServerConfig.shared.runsDir!)\(runId)",
            fileNameComps: [ArchiveConstants.cellularOut],
            fileExtension: ArchiveConstants.Extensions.zip)
    }
}
