//
//  ServerRoutes.swift
//  Server
//
//  Created by Anton Pavlov on 3/9/19.
//

import Foundation
import Kitura
import KituraContracts
import LoggerAPI
import KituraCORS

class ServerRouter {
    let router = Router()

    func setupRoutes() {
        setupCORS()
        router.post(middleware: BodyParser())
        setupScriptGet()
        setupScriptUploadPost()
        setupPipelineStartPost()
        setupPipelineRunsGet()
        setupCellProfilerCellularGet()
        setupCellProfilerWellularGet()
        setupCellProfilerFileListGet()
        setupCellProfilerLogsGet()
        setupScriptDownloadGet()
        setupRunsSearchPost()
        setupScriptDelete()
        setupRunDelete()
        testUpdateKeysJob()
        setupGlobalKeysGet()
        setupDataSetIdGet()
    }
    
    private func setupCORS() {
        let cors = CORS(options: Options())
        router.all(middleware: cors)
    }
    
    private func setupScriptUploadPost() {
        router.post("/v1/script/upload/") { request, response, next in
            Log.info("Processing script upload request")
            if let reqParts = request.body?.asMultiPart {
                if let cpData = CellProfilerScriptData(with: reqParts) {
                    let cpJob = CellProfilerPostScriptJob(cpData)
                    cpJob.dispatch(completion: { (res, err) in
                        if let _ = err {
                           response.status(.internalServerError).send("Failed to upload script")
                        } else {
                            response.status(.OK).send("Script uploaded successfully")
                        }
                    })
                }
            }
        }
    }
    
    private func setupPipelineStartPost() {
        router.post("/v1/pipeline/start/") { request, response, next in
            Log.info("Processing pipeline start request")
            if let reqParts = request.body?.asMultiPart {
                if let spData = PipelineStartData(with: reqParts) {
                    let cpJob = PipelineStartJob(spData)
                    cpJob.dispatch(completion: { (res, err) in
                        if let _ = err {
                            response.status(.internalServerError).send("Failed to start pipeline script")
                        } else {
                            response.headers.append("Access-Control-Allow-Origin", value: "*")
                            response.status(.OK).send(res)
                        }
                    })
                }
            }
        }
    }
    
    private func setupScriptGet() {
        router.get("/v1/script/") { request, response, next in
            Log.info("Processing script get request")
            if let username = request.queryParameters[ScriptConfigConstants.username] {
                let getJob = CellProfilerGetScriptJob.init(username)
                getJob.dispatch(completion: { (result, err) in
                    if let _ = err {
                        response.status(.internalServerError).send("Failed to get script cppipe file")
                    } else {
                        response.status(.OK).send(result)
                    }
                })
            } else {
                response.status(.internalServerError).send("Username parameter missing")
            }
        }
    }
    
    private func setupPipelineRunsGet() {
        router.get("/v1/runs/") { request, response, next in
            Log.info("Processing runs get request")
            let getJob = PipelineRunsGetJob.init(request.queryParameters[ScriptConfigConstants.username])
            getJob.dispatch(completion: { (result, err) in
                if let _ = err {
                    response.status(.internalServerError).send("Failed to get pipeline runs")
                } else {
                    response.status(.OK).send(result)
                }
            })
        }
    }

    private func setupCellProfilerCellularGet() {
        router.get("/v1/cellprofiler/cellular/") { request, response, next in
            Log.info("Processing cell profiler cellular get request")
            if let runId = request.queryParameters[ScriptConfigConstants.runId] {
                let filePath = CellProfilerCellularGetJob.filePath(runId: runId)
                do {
                    try response.status(.OK).send(fileName: filePath)
                } catch {
                    Log.error("Could not send file for run id: \(runId)")
                    response.status(.internalServerError).send("Failed to get cellular data file")
                }
            } else {
                response.status(.internalServerError).send("Could not create cellular download job for run id")
            }
        }
    }
    
    private func setupCellProfilerWellularGet() {
        router.get("/v1/cellprofiler/wellular/") { request, response, next in
            Log.info("Processing cell profiler wellular get request")
            if let runId = request.queryParameters[ScriptConfigConstants.runId] {
                let filePath =  Utilities.constructFilePath(dir: "\(LocalServerConfig.shared.runsDir!)\(runId)",
                                                  fileNameComps: [ArchiveConstants.wellularOut],
                                                  fileExtension: ArchiveConstants.Extensions.zip)
                do {
                    try response.status(.OK).send(fileName: filePath)
                } catch {
                    Log.error("Could not send file for run id: \(runId)")
                    response.status(.internalServerError).send("Failed to get wellular data file")
                }
            } else {
                response.status(.internalServerError).send("Could not create wellular download job for run id")
            }
        }
    }
    
    private func setupCellProfilerFileListGet() {
        router.get("/v1/cellprofiler/filelist/") { request, response, next in
            Log.info("Processing cell profiler filelist get request")
            if let runId = request.queryParameters[ScriptConfigConstants.runId] {
                let filePath =  Utilities.constructFilePath(dir: "\(LocalServerConfig.shared.runsDir!)\(runId)",
                    fileNameComps: [ArchiveConstants.fileList],
                    fileExtension: ArchiveConstants.Extensions.zip)
                do {
                    try response.status(.OK).send(fileName: filePath)
                } catch {
                    Log.error("Could not send file for run id: \(runId)")
                    response.status(.internalServerError).send("Failed to get filelist data file")
                }
            } else {
                response.status(.internalServerError).send("Could not create filelist download job for run id")
            }
        }
    }
    
    private func setupCellProfilerLogsGet() {
        router.get("/v1/cellprofiler/logs/") { request, response, next in
            Log.info("Processing cell profiler logs get request")
            if let runId = request.queryParameters[ScriptConfigConstants.runId] {
                let filePath =  Utilities.constructFilePath(dir: "\(LocalServerConfig.shared.runsDir!)\(runId)",
                    fileNameComps: [ArchiveConstants.logs],
                    fileExtension: ArchiveConstants.Extensions.zip)
                do {
                    try response.status(.OK).send(fileName: filePath)
                } catch {
                    Log.error("Could not send file for run id: \(runId)")
                    response.status(.internalServerError).send("Failed to get log data file")
                }
            } else {
                response.status(.internalServerError).send("Could not create logs download job for run id")
            }
        }
    }
    
    private func setupScriptDownloadGet() {
        router.get("/v1/script/download/") { request, response, next in
            Log.info("Processing script download get request")
            if let scriptId = request.queryParameters[ScriptConfigConstants.pipelineId] {
                // create script download job
                let scriptDlJob = ScriptDownloadJob.init(scriptId: scriptId)
                scriptDlJob.dispatch(completion: { (path, err) in
                    if let p = path {
                        Log.info("Successfully got path for script id: \(scriptId)")
                        do {
                            try response.status(.OK).send(fileName: p)
                        } catch {
                            Log.error("Could not send file for script id: \(scriptDlJob)")
                            response.status(.internalServerError).send("Failed to get script data file")
                        }
                    } else {
                        Log.error("Could not get path for script id: \(scriptId)")
                        response.status(.internalServerError).send("Could not get path for script id: \(scriptId)")
                    }
                })
            } else {
                response.status(.internalServerError).send("Could not create script download job for run id")
            }
        }
    }
    
    
    private func setupRunsSearchPost() {
        router.post("/v1/runs/search/") { request, response, next in
            Log.info("Processing pipeline search request")
            if let requestKvp = request.body?.asJSON {
                Log.info("Got request body")
                let searchData = SearchData(with: requestKvp)
                let searchJob = SearchJob(searchData)
                searchJob.dispatch(completion: { (res, err) in
                    if let _ = err {
                        Log.info("Successfully performed search")
                        response.status(.internalServerError).send("Failed to perform search")
                    } else {
                        response.headers.append("Access-Control-Allow-Origin", value: "*")
                        response.status(.OK).send(res)
                    }
                })
            }
        }
    }
    
    private func setupScriptDelete() {
        router.delete("/v1/script/delete/") { request, response, next in
            Log.info("Processing script delete request")
            if let scriptId = request.queryParameters[ScriptConfigConstants.scriptId] {
                // create script delete job
                let scriptDeleteJob = ScriptDeleteJob(scriptId: scriptId)
                scriptDeleteJob.dispatch(completion: { (res, err) in
                    if let _e = err {
                        Log.error("Could not delete script with id: \(scriptId), error: \(_e)")
                        response.status(.internalServerError).send("Failed to delete script data")
                    } else {
                        response.status(.OK).send("Script deleted successfully")
                    }
                })
            } else {
                response.status(.internalServerError).send("Could not create script delete job for script id")
            }
        }
    }
    
    private func setupRunDelete() {
        router.delete("/v1/run/delete/") { request, response, next in
            Log.info("Processing script delete request")
            if let runId = request.queryParameters[ScriptConfigConstants.runId] {
                // create script delete job
                let runDeleteJon = RunDeleteJob(runId: runId)
                runDeleteJon.dispatch(completion: { (res, err) in
                    if let _e = err {
                        Log.error("Could not delete run with id: \(runId), error: \(_e)")
                        response.status(.internalServerError).send("Failed to delete run data")
                    } else {
                        response.status(.OK).send("Run deleted successfully")
                    }
                })
            } else {
                response.status(.internalServerError).send("Could not create run delete job for run id")
            }
        }
    }
    
    private func testUpdateKeysJob() {
        router.get("/v1/run/updatekeys/") { request, response, next in
            Log.info("Processing keys update request")
            if let runId = request.queryParameters[ScriptConfigConstants.runId] {
                // create script delete job
                // here we can kick off global keys update
                let keysUpdateJob = GlobalKeyUpdateJob(runId)
                keysUpdateJob.dispatch(completion: { (success, err) in
                    if success == false {
                        Log.error("failed to update keys: \(runId)")
                        response.status(.internalServerError).send("failed to update keys")
                    } else {
                        response.status(.OK).send("Keys updated successfully")
                    }
                })
            } else {
                response.status(.internalServerError).send("Could not create update keys job for run id")
            }
        }
    }
    
    private func setupGlobalKeysGet() {
        router.get("/v1/globalkeys/") { request, response, next in
            Log.info("Processing global keys get request")
            let getJob = GetGlobalKeysJob()
            getJob.dispatch(completion: { (result, err) in
                if let _ = err {
                    let err = ServerError("Failed to get global keys")
                    Log.error(err.description)
                    response.status(.internalServerError).send(err.description)
                } else {
                    Log.info("Got global keys successfully")
                    response.status(.OK).send(result)
                }
            })
        }
    }
    
    private func setupDataSetIdGet() {
        router.get("/v1/omero/datasetid/") { request, response, next in
            Log.info("Processing data set id get request")
            let getJob = GetDataSetIdsJob()
            getJob.dispatch(completion: { (result, err) in
                if let _ = err {
                    let err = ServerError("Failed to get data set ids")
                    Log.error(err.description)
                    response.status(.internalServerError).send(err.description)
                } else {
                    Log.info("Got data set ids successfully")
                    response.status(.OK).send(result)
                }
            })
        }
    }
}
