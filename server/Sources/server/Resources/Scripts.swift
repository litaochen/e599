//
//  Scripts.swift
//  Server
//
//  Created by Anton Pavlov on 3/13/19.
//

import Foundation

protocol ScriptExecutable {
    var baseComponents : [String] { get }
    func getScript() -> [String]
}

struct CellProfilerScript : ScriptExecutable {
    internal var baseComponents = ["docker", "run", "--rm", "--name",
                          "-v", "/home/ubuntu/CellProfiler/runs:/cellprofiler/runs",
                          "-e", "input_dir=run6/input",
                          "-e", "output_dir=run6/output",
                          "-e", "omero_server=18.191.112.169",
                          "-e", "omero_port=4064",
                          "-e", "omero_user=root",
                          "-e", "omero_passwd=omero", "cellprofiler:1.0"]
    
    init(jobId:String) {
        baseComponents.insert(jobId, at: 4)
    }
    
    func getScript() -> [String] {
        return baseComponents
    }
}

struct Scripts {
    static let date = "date"
    static let manPwd = ["man", "pwd"]
    static let rev = ["rev"]
    static let curl = ["curl", "www.google.com"]
    static let CellProfiler = ["docker", "run", "--rm", "--name", "cellprofiler_run6",
                               "-v", "/home/ubuntu/CellProfiler/runs:/cellprofiler/runs",
                               "-e", "input_dir=run6/input",
                               "-e", "output_dir=run6/output",
                               "-e", "omero_server=18.191.112.169",
                               "-e", "omero_port=4064",
                               "-e", "omero_user=root",
                               "-e", "omero_passwd=omero", "cellprofiler:1.0"]
    static let dockerPS = ["docker", "ps"]
    static let getFileList = ["\(LocalServerConfig.shared.pipelineBaseDir)pipelines/get_file_list/run_get_file_list.bash"]
    static let runCellProfiler = ["\(LocalServerConfig.shared.pipelineBaseDir)pipelines/cell_profiler/run_cell_profiler.bash"]
    static let pipelineGlue = ["\(LocalServerConfig.shared.pipelineBaseDir)pipelines/cell_profiler_glue/cell_profiler_glue.bash"]
    static let getDataSetId = ["\(LocalServerConfig.shared.pipelineBaseDir)pipelines/get_dataset_list/get_dataset_list.bash"]
}
