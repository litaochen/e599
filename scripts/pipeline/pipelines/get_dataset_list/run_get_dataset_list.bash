#!/bin/bash

# Description
# This script is a test script which runs the get_file_list.bash script with known good args.

# Args:
# $1: omero user_name
# $2: omero passwd

# the expected number of args
num_expected_args=2

# if the number of args not equal to the number of expected args
if [ "${#}" -ne ${num_expected_args} ]; then
    echo "${0}: Error - Expected ${num_expected_args} args but received ${#} args."
    echo "Usage: ${0} <omero user name> <omero passwd>"
    exit 1
fi

# get the args
user_name=${1}
passwd=${2}

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# run the environment setup script
source ${project_dir}/../../scripts/setup.bash

# get the project location
run_get_file_list_project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# cd to the scripts dir
scripts

# build the pipelines
./build_pipelines.bash

# run the get_dataset_list component with hard coded known good params
${project_dir}/get_dataset_list.bash \
              ${config}/aws_config.json \
              ${user_name} \
              ${passwd} \
              ${runs}
