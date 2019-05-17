# imports
import luigi
import subprocess
import os
import get_file_list
import env_vars
import time

class CellProfiler(luigi.Task):
    """
    The CellProfiler class is a luigi task that wraps the cell_profiler pipeline component.
    This task depends on the GetFileList task.
    """

    # override the method that tells luigi what this task depends on
    def requires(self):
        return get_file_list.GetFileList()

    # override the method that tells luigu what the ouput of this task is
    def output(self):
        # build the full path output dir name
        target = "%s/%s/%s" % (env_vars.output_dir, \
                               env_vars.cell_profiler_component_name, \
                               env_vars.cell_profiler_success_file_name)

        # return the target dir target
        return luigi.LocalTarget(target)

    # override the method that executes the luigi task
    def run(self):
        # time.sleep(30)

        # execute the cell profiler component
        completed_proc = subprocess.run([env_vars.cell_profiler_component_runner,
                                         env_vars.config_file, env_vars.cppipe,
                                         env_vars.output_dir, env_vars.user_name,
                                         env_vars.passwd])

        # throw an exception if the process returned a non 0 return code
        completed_proc.check_returncode()
