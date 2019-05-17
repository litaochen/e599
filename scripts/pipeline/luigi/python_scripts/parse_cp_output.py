# imports
import luigi
import subprocess
import os
import cell_profiler
import env_vars
import time

class ParseCpOutput(luigi.Task):
    """
    The ParseCpOutput class is a luigi task that wraps the parse_cp_output pipeline component.
    This task depends on the CellProfiler task.
    """

    # override the method that tells luigi what this task depends on
    def requires(self):
        return cell_profiler.CellProfiler()

    # override the method that tells luigu what the ouput of this task is
    def output(self):
        # get the output run ID
        run_id = os.path.basename(env_vars.output_dir)

        # build the full path output dir name
        target = "%s/%s/%s.json" % (env_vars.output_dir, \
                                    env_vars.parse_cp_output_component_name, \
                                    run_id)

        # return the target dir target
        return luigi.LocalTarget(target)

    # override the method that executes the luigi task
    def run(self):
        # time.sleep(30)

        # execute the parse cp output component
        completed_proc = subprocess.run([env_vars.cell_profiler_parser_component_runner,
                                         env_vars.config_file, env_vars.output_dir])

        # throw an exception if the process returned a non 0 return code
        completed_proc.check_returncode()
