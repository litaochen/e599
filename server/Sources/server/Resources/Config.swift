//
//  Config.swift
//  Server
//
//  Created by Anton Pavlov on 3/26/19.
//

import Foundation
import LoggerAPI

struct ConfigConstants {
    static let configFileName = "serverconfig.json"
    static let scriptsUploadDir = "scripts_directory"
    static let runsDir = "runs_directory"
    static let pipelineDir = "pipeline_directory"
    static let cellProfDir = "cell_profiler_directory"
    static let fileComponentSeparator = "_"
    static let awsConfig = "aws_config"
    static let pipelineBaseDir = "pipeline_base_dir"
    
    struct Omero {
        static let username = "omero_username"
        static let password = "omero_password"
        static let getDataSetDir = "get_dataset_dir"
    }
}

enum RunJobStatus : String {
    case Running = "Running"
    case Failed = "Failed"
    case Completed = "Completed"
}

struct ScriptConfigConstants {
    static let objectId = "_id"
    static let pipelineId = "pipeline_id"
    static let scriptId = "script_id"
    static let fileExtension = "cppipe"
    static let username = "username"
    static let filename = "filename"
    static let pipelineName = "name"
    static let data = "data"
    static let description = "description"
    static let date = "date"
    static let startDate = "start_date"
    static let endDate = "end_date"
    static let status = "status"
    static let dataSetId = "data_set_id"
    static let dateFormat = "yyyyMMddHHmmss"
    static let runId = "run_id"
    static let jsonOutputDir = "parse_cp_output"
}

struct SearchConstants {
    static let kvp = "kvp"
    static let cellular = "cell_level_summary"
    static let wellular = "well_level_summary"
    static let value = "value"
    static let min = "min"
    static let max = "max"
    static let key = "key"
}

struct MongoConstants {
    static let lte = "$lte"
    static let gte = "$gte"
    static let match = "$match"
    static let inOpr = "$in"
    static let arrayElemAt = "$arrayElemAt"
    
    struct Collection {
        static let runs = "runs"
        static let cellProfilerResultData = "result_data_cell_profiler"
        static let scripts = "scripts"
        static let globalKeys = "global_keys"
    }
    
    static func importCommand(db:String, collection:String, path:String) -> [String] {
        return ["mongoimport",
                "-u", LocalServerConfig.shared.mongoUsr,
                "-p", LocalServerConfig.shared.mongoPwd,
                "--db", db,
                "--collection",  collection,
                "--file", path]
    }
    
    struct Config {
        static let username = "mongo_username"
        static let pwd = "mongo_password"
        static let dnName = "mongo_db_name"
    }
    
    struct Params {
        static let documents = "documents"
    }
    
    struct Components {
        static let component = "component"
        static let cellProfiler = "cell_profiler"
    }
}

struct ArchiveConstants {
    static let cellularProfiler = "cell_profiler"
    static let cellularProfilerGlue = "cell_profiler_glue"
    static let getFileList = "get_file_list"
    static let cellProfilerGlueDir = "cell_profiler_glue"
    static let logs = "logs"
    static let parsedOutputDir = "parse_cp_output"
    static let cellularIn = "MyExpt_IdentifyPrimaryObjects"
    static let cellularOut = "cellular"
    static let wellularIn = "MyExpt_Image"
    static let wellularOut = "wellular"
    static let fileList = "file_list"
   
    struct Extensions {
        static let zip = "zip"
        static let csv = "csv"
        static let log = "log"
    }
}

class LocalServerConfig {
    static let shared = LocalServerConfig()
    var scriptsDir : String!
    var runsDir : String!
    var pipelineDir : String!
    var cellProfilerDir : String!
    var awsConfigPath : String!
    var getDataSetDir : String!
    var pipelineBaseDir = ""
    var mongoUsr = ""
    var mongoPwd = ""
    var omeroUser = ""
    var omeroPwd = ""
    var mongoDbName = ""
    
    func setup() -> ServerError? {
        let serverPath = SystemManager.applicationPath()
        let configFilePath = serverPath + "/\(ConfigConstants.configFileName)"
        
        guard let dataDict : [String:String] = SystemManager.getJsonFromPath(configFilePath) else {
            return ServerError("Could not read in config JSON object: \(configFilePath)")
        }
        Log.info("successfully loaded local config JSON")
        
        guard let _sd = dataDict[ConfigConstants.scriptsUploadDir] else {
            return ServerError("\(ConfigConstants.scriptsUploadDir) param missing")
        }
        scriptsDir = _sd
        Log.info("successfully loaded \(ConfigConstants.scriptsUploadDir)")
        
        guard let _rd = dataDict[ConfigConstants.runsDir] else {
            return ServerError("\(ConfigConstants.runsDir) param missing")
        }
        runsDir = _rd
        Log.info("successfully loaded \(ConfigConstants.runsDir)")
        
        guard let _pd = dataDict[ConfigConstants.pipelineDir] else {
            return ServerError("\(ConfigConstants.pipelineDir) param missing")
        }
        pipelineDir = _pd
        Log.info("successfully loaded \(ConfigConstants.pipelineDir)")
        
        guard let _cpd = dataDict[ConfigConstants.cellProfDir] else {
            return ServerError("\(ConfigConstants.cellProfDir) param missing")
        }
        cellProfilerDir = _cpd
        Log.info("successfully loaded \(ConfigConstants.cellProfDir)")
        
        guard let awdc = dataDict[ConfigConstants.awsConfig] else {
            return ServerError("\(ConfigConstants.awsConfig) param missing")
        }
        awsConfigPath = awdc
        Log.info("successfully loaded \(ConfigConstants.awsConfig)")
        
        guard let gdsdir = dataDict[ConfigConstants.Omero.getDataSetDir] else {
            return ServerError("\(ConfigConstants.Omero.getDataSetDir) param missing")
        }
        getDataSetDir = gdsdir
        Log.info("successfully loaded \(ConfigConstants.Omero.getDataSetDir)")
        
        guard let baseDir = dataDict[ConfigConstants.pipelineBaseDir] else {
            return ServerError("\(ConfigConstants.pipelineBaseDir) param missing")
        }
        pipelineBaseDir = baseDir
        Log.info("successfully loaded \(ConfigConstants.pipelineBaseDir)")
        
        guard let muser = dataDict[MongoConstants.Config.username] else {
            return ServerError("\(MongoConstants.Config.username) param missing")
        }
        mongoUsr = muser
        Log.info("successfully loaded \(MongoConstants.Config.username)")
        
        guard let mpwd = dataDict[MongoConstants.Config.pwd] else {
            return ServerError("\(MongoConstants.Config.pwd) param missing")
        }
        mongoPwd = mpwd
        Log.info("successfully loaded \(MongoConstants.Config.pwd)")
        
        guard let mdbname = dataDict[MongoConstants.Config.dnName] else {
            return ServerError("\(MongoConstants.Config.dnName) param missing")
        }
        mongoDbName = mdbname
        Log.info("successfully loaded \(MongoConstants.Config.dnName)")
        
        // OMERO
        guard let oUser = dataDict[ConfigConstants.Omero.username] else {
            return ServerError("\(ConfigConstants.Omero.username) param missing")
        }
        omeroUser = oUser
        Log.info("successfully loaded \(ConfigConstants.Omero.username)")
        
        guard let oPwd = dataDict[ConfigConstants.Omero.password] else {
            return ServerError("\(ConfigConstants.Omero.password) param missing")
        }
        omeroPwd = oPwd
        Log.info("successfully loaded \(ConfigConstants.Omero.password)")
        
        Log.info("Local server config loaded successfully")
        return nil
    }
}
