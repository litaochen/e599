#!/bin/bash

# set the shell flag to expand aliases
shopt -s expand_aliases

# the project dir is the location of this setup script
export scripts_project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# a list of pipelines
export pipeline_list="get_file_list cell_profiler parse_cp_output get_dataset_list"

# environment vars
export base=${scripts_project_dir}/..
export shared_volume_dir=${base}
export shared_config_dir_name=config
export shared_config_dir=${base}/${shared_config_dir_name}
export shared_pipelines_dir_name=pipelines
export shared_pipelines_dir=${base}/${shared_pipelines_dir_name}
export container_config_file_name=${shared_config_dir}/config.json
export dev_container_config_file_name=${shared_config_dir}/dev_config.json
export shared_scripts_dir_name=scripts
export shared_scripts_dir=${base}/${shared_scripts_dir_name}
export pipelines=${base}/pipelines
export get_file_list=${pipelines}/get_file_list
export cell_profiler=${pipelines}/cell_profiler
export scripts=${base}/scripts
export config=${base}/${shared_config_dir_name}
export results=${shared_results_dir}
export cell_profiler_glue=${pipelines}/cell_profiler_glue
export glue=${cell_profiler_glue}
export parse_cp_output=${pipelines}/parse_cp_output
export parser=${parse_cp_output}
export get_dataset_list=${pipelines}/get_dataset_list
export get_file_list_file_name=file_list.csv
export runs=${base}/runs
export cppipe=${base}/cppipe
export luigip=${base}/luigi/python_scripts
export get_file_list_component_runner=${get_file_list}/get_file_list.bash
export cell_profiler_component_runner=${cell_profiler}/cell_profiler.bash
export parse_cp_output_component_runner=${parse_cp_output}/parse_cp_output.bash
export get_dataset_list_component_runner=${get_dataset_list}/get_dataset_list.bash
export get_file_list_component_name="$(basename ${get_file_list})"
export cell_profiler_component_name="$(basename ${cell_profiler})"
export get_dataset_list_component_name="$(basename ${get_dataset_list})"
export parse_cp_output_component_name="$(basename ${parse_cp_output})"
export cell_profiler_success_file_name="cell_profiler_success.txt"
export luigi_glue=${pipelines}/luigi_cell_profiler_glue
export install_scripts=${base}/../../installation_and_run

# aliases
alias base='cd ${base}'
alias pipelines='cd ${pipelines}'
alias get_file_list='cd ${get_file_list}'
alias scripts='cd ${scripts}'
alias config='cd ${config}'
alias shared_vol='cd ${base}'
alias results='cd ${shared_results_dir}'
alias pipelines='cd ${pipelines}'
alias get_file_list='cd ${get_file_list}'
alias cell_profiler='cd ${cell_profiler}'
alias glue='cd ${cell_profiler_glue}'
alias parse_cp_output='cd ${parse_cp_output}'
alias parser='cd ${parse_cp_output}'
alias base='cd ${base}'
alias build='sudo ${scripts}/build_pipelines.bash'
alias get_dataset_list='cd ${get_dataset_list}'
alias runs='cd ${runs}'
alias cppipe='cd ${cppipe}'
alias luigip='cd ${luigip}'
alias luigi_glue='cd ${luigi_glue}'
alias install_scripts='cd ${install_scripts}'
