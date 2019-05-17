#!/bin/bash

# Description
# This script is a test script which runs the parse_cp_output.bash script with known good args.

# Args: None - Passes known good hard coded args to get_file_list.bash.

# get the project location
run_parse_cp_output_project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${run_parse_cp_output_project_dir}/../../scripts/setup.bash

# cd to the scripts dir
scripts

# build the pipelines
./build_pipelines.bash

# get the cell profiler output dir
cell_profiler_output=${run_parse_cp_output_project_dir}/../cell_profiler/output/999999

# run the get_file_list_test
# get a sample file list for dataset 2 - Assumes dataset 2 exists
${run_parse_cp_output_project_dir}/parse_cp_output.bash \
                                  ${config}/aws_config.json \
                                  ${runs}/999
