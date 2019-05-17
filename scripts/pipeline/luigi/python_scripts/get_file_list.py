# imports
import luigi
import subprocess
import os
import env_vars
import time

class GetFileList(luigi.Task):
    """
    The GetFileList class is a luigi task that wraps the get_file_list pipeline component.
    This task does not depend on any other tasks and produces a file list as a target.
    """

    # override the method that tells luigi what this task depends on
    def requires(self):
        return []

    # override the method that tells luigu what the ouput of this task is
    def output(self):
        # build the full output path file name
        full_path_out_file_name = "%s/%s/%s" % (env_vars.output_dir,
                                                env_vars.get_file_list_component_name,
                                                env_vars.get_file_list_file_name)

        # return the output file name target
        return luigi.LocalTarget(full_path_out_file_name)

    # override the method that executes the luigi task
    def run(self):
        # time.sleep(30)

        # execute the get file list component
        completed_proc = subprocess.run([env_vars.get_file_list_component_runner,
                                         env_vars.config_file, env_vars.output_dir,
                                         env_vars.dataset_id, env_vars.user_name,
                                         env_vars.passwd])

        # throw an exception if the process returned a non 0 return code
        completed_proc.check_returncode()
