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

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${project_dir}/../../scripts/setup.bash

# get the args
dataset_id=${1}
user_name=${2}
passwd=${3}
output_dir=${runs}/999

# cd to the scripts dir
scripts

# build the pipelines
./build_pipelines.bash

# remove the output dir
rm -rf ${output_dir}
mkdir ${output_dir}

# get the component name
component_id="$(basename ${project_dir})"

${project_dir}/${component_id}.bash \
  ${dataset_id} \
  ${cppipe}/4_chan_omero-test.cppipe \
  ${runs}/999 \
  ${config}/aws_config.json \
  ${user_name} \
  ${passwd}
