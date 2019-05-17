#!/bin/bash

# Description
# This script is a test script which executes the cell_profiler_glue.bash script with
# known good arguments.

# Args:
# $1: Dataset ID
# $2: omero user_name
# $3: omero passwd

# the expected number of args
num_expected_args=3

# if the number of args not equal to the number of expected args
if [ "${#}" -ne ${num_expected_args} ]; then
    echo "${0}: Error - Expected ${num_expected_args} args but received ${#} args."
    echo "Usage: ${0} <dataset id> <omero user name> <omero passwd>"
    exit 1
fi

# get the args
dataset_id=${1}
user_name=${2}
passwd=${3}

# get the project location
run_cell_profiler_glue_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${run_cell_profiler_glue_dir}/../../scripts/setup.bash

# cd to the scripts dir
scripts

# build the pipelines
./build_pipelines.bash

${run_cell_profiler_glue_dir}/cell_profiler_glue.bash \
  ${dataset_id} \
  ${cppipe}/4_chan_omero-test.cppipe \
  ${runs}/999 \
  ${config}/aws_config.json \
  ${user_name} \
  ${passwd}
