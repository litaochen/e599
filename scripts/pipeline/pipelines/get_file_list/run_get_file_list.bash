#!/bin/bash

# Description
# This script is a test script which runs the get_file_list.bash script with known good args.

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
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# run the environment setup script
source ${project_dir}/../../scripts/setup.bash

# cd to the scripts dir
scripts

# build the pipelines
./build_pipelines.bash

# run the get_file_list_test
# get a sample file list for dataset 2 - Assumes dataset 2 exists
${project_dir}/get_file_list.bash \
              ${config}/aws_config.json \
              ${runs}/999 \
              ${dataset_id} \
              ${user_name} \
              ${passwd}
