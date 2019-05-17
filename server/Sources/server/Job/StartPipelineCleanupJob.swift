//
//  StartPipelineCleanupJob.swift
//  Server
//
//  Created by Anton Pavlov on 4/18/19.
//

import Foundation
import LoggerAPI

class StartPipelineCleanupJob : Job {
    typealias ReturnType = Bool
    typealias ErrorType = ServerError
    let runId : String
    let fileManager = FileManager()
    
    init(runId:String) {
        self.runId = runId
    }
    
    func execute(completion: @escaping (Bool?, ServerError?) -> Void) {
        /*
         runs directory contains output from pipeline in below dirs:
         
        // cell_profiler - contains pipeline csvs
        // cell_profiler_glue - cell profiler log
        // get_file_list - file list csv + log
        // parse_cp_output - json output + log
 
         we need to compress all these files and delete originals
         */
        // we can do this with dispatch group
        
        let archiveGroup = DispatchGroup()
        
        // start with cell_profiler dir tasks
        // it contains 3 files:
        //      MyExpt_Experiment.csv - this is unnecessary cppipe file   X
        //      MyExpt_IdentifyPrimaryObjects.csv - cellular summary
        //      MyExpt_Image.csv - wellular summary
        //      log - we need to fix naming
        
        // we can use run directory to store archives
        let runDir = "\(LocalServerConfig.shared.runsDir!)\(runId)"
        let cell_profiler_dir = "\(runDir)/\(ArchiveConstants.cellularProfiler)"
        let cell_profiler_glue_dir = "\(runDir)/\(ArchiveConstants.cellularProfilerGlue)"
        let get_file_list_dir = "\(runDir)/\(ArchiveConstants.getFileList)"
        let logDirPath = "\(runDir)/\(ArchiveConstants.logs)"
        
        // store errors
        var errors = [ServerError]()
        
        // we'll compress MyExpt_IdentifyPrimaryObjects.csv
        // we can dispatch this onto system queue
        archiveGroup.enter()
        Dispatcher.shared.systemQueue.async {
            // we need to create input path
            let inPath = Utilities.constructFilePath(dir: cell_profiler_dir,
                                                     fileNameComps: [ArchiveConstants.cellularIn],
                                                     fileExtension: ArchiveConstants.Extensions.csv)
            
            // we need to create output path
            let outPath = Utilities.constructFilePath(dir: runDir,
                                                    fileNameComps: [ArchiveConstants.cellularOut],
                                                    fileExtension: ArchiveConstants.Extensions.zip)
            
            if let error = self.zipItem(at: inPath, outPath: outPath, component: ArchiveConstants.cellularOut) {
                errors.append(error)
            }
            archiveGroup.leave()
        }
        archiveGroup.wait()
        
        // we'll compress MyExpt_Image.csv
        // we can dispatch this onto system queue
        archiveGroup.enter()
        Dispatcher.shared.systemQueue.async {
            // we need to create input path
            let inPath = Utilities.constructFilePath(dir: cell_profiler_dir,
                                                     fileNameComps: [ArchiveConstants.wellularIn],
                                                     fileExtension: ArchiveConstants.Extensions.csv)
            
            // we need to create output path
            let outPath = Utilities.constructFilePath(dir: runDir,
                                                      fileNameComps: [ArchiveConstants.wellularOut],
                                                      fileExtension: ArchiveConstants.Extensions.zip)
            
            if let error = self.zipItem(at: inPath, outPath: outPath, component: ArchiveConstants.wellularOut) {
                errors.append(error)
            }
            archiveGroup.leave()
        }
        archiveGroup.wait()
        
        // we'll compress file_list.csv from get_file_list dir
        // we can dispatch this onto system queue
        archiveGroup.enter()
        Dispatcher.shared.systemQueue.async {
            // we need to create input path
            let inPath = Utilities.constructFilePath(dir: get_file_list_dir,
                                                     fileNameComps: [ArchiveConstants.fileList],
                                                     fileExtension: ArchiveConstants.Extensions.csv)
            
            // we need to create output path
            let outPath = Utilities.constructFilePath(dir: runDir,
                                                      fileNameComps: [ArchiveConstants.fileList],
                                                      fileExtension: ArchiveConstants.Extensions.zip)
            
            if let error = self.zipItem(at: inPath, outPath: outPath, component: ArchiveConstants.fileList) {
                errors.append(error)
            }
            archiveGroup.leave()
        }
        archiveGroup.wait()
        
        // we'll have to move log files into one directory and compress it
        // there are 3 log files to archive:
        //      /cell_profiler/cell_profiler.log
        //      /cell_profiler_glue/cell_profiler_glue.log
        //      /get_file_list/get_file_list.log
        // we can dispatch this onto system queue
        archiveGroup.enter()
        Dispatcher.shared.systemQueue.async {
            // we need to create directory to house logs
            if let dirError = SystemManager.createDirAtPath(logDirPath) {
                // there is an error creating log dir
                // we can log it, we don't need to fail entire job
                Log.error(dirError.description)
            } else {
               // we created directory successfully
                // we need to create input paths for 3 log files
                // input files
                let inPathCP = Utilities.constructFilePath(dir: cell_profiler_dir,
                                                           fileNameComps: [ArchiveConstants.cellularProfiler],
                                                           fileExtension: ArchiveConstants.Extensions.log)
                
                let inPathCPG = Utilities.constructFilePath(dir: cell_profiler_glue_dir,
                                                            fileNameComps: [ArchiveConstants.cellularProfilerGlue],
                                                            fileExtension: ArchiveConstants.Extensions.log)
                
                let inPathGFL = Utilities.constructFilePath(dir: get_file_list_dir,
                                                            fileNameComps: [ArchiveConstants.getFileList],
                                                            fileExtension: ArchiveConstants.Extensions.log)
                
                // output files
                let outPathCP = Utilities.constructFilePath(dir: logDirPath,
                                                           fileNameComps: [ArchiveConstants.cellularProfiler],
                                                           fileExtension: ArchiveConstants.Extensions.log)
                
                let outPathCPG = Utilities.constructFilePath(dir: logDirPath,
                                                            fileNameComps: [ArchiveConstants.cellularProfilerGlue],
                                                            fileExtension: ArchiveConstants.Extensions.log)
                
                let outPathGFL = Utilities.constructFilePath(dir: logDirPath,
                                                            fileNameComps: [ArchiveConstants.getFileList],
                                                            fileExtension: ArchiveConstants.Extensions.log)
                let _ = zip([inPathCP, inPathCPG, inPathGFL], [outPathCP, outPathCPG, outPathGFL]).map({ (tuple) -> Void in
                    if let moveError = SystemManager.moveItem(from: tuple.0, to: tuple.1) {
                        // again we'll log but won't fail job
                        Log.error(moveError.description)
                    }
                })
                
                // we need to create output path
                let outPath = Utilities.constructFilePath(dir: runDir,
                                                          fileNameComps: [ArchiveConstants.logs],
                                                          fileExtension: ArchiveConstants.Extensions.zip)
                
                // zip log directory
                if let zipError = self.zipItem(at: logDirPath, outPath: outPath, component: ArchiveConstants.fileList) {
                    Log.error(zipError.description)
                }
            }
            archiveGroup.leave()
        }
        archiveGroup.wait()
        
        // all groups should be finished, notify
        archiveGroup.notify(queue: Dispatcher.shared.systemQueue) {
            if errors.count == 0 {
                // success
                Log.info("Group notified with no errors, runid: \(self.runId)")
                // delete original directories
                let dirsToDelete = [cell_profiler_dir,
                                    get_file_list_dir,
                                    "\(runDir)/\(ArchiveConstants.cellProfilerGlueDir)",
                                    "\(runDir)/\(ArchiveConstants.parsedOutputDir)",
                                    logDirPath]
                let res = SystemManager.removeItemsOnDisk(dirsToDelete)
                if let err = Utilities.flattenErrors(res) {
                    // there was error removing
                    Log.error("Could not remove directories for runid: \(self.runId), error:\(err)")
                    completion(false, err)
                } else {
                    Log.info("Group completed successfully for runid: \(self.runId)")
                   completion(true, nil)
                }
            } else {
                // something failed
                Log.error("Cleanup dispatch group failed for run id: \(self.runId), errors:\(errors)")
                completion(false, Utilities.flattenErrors(errors))
            }
        }
    }
    
    func zipItem(at inPath:String, outPath:String, component:String) -> ServerError? {
        if let error = SystemManager.zipFile(inPath: inPath, outPath: outPath) {
            Log.error("Failed to archive \(component) csv with error: \(error)")
            Log.error("Failed inpath: \(inPath), outpath: \(outPath)")
            return error
        } else {
            Log.info("Successfully archived \(component) csv to: \(outPath)")
            return nil
        }
    }
}
