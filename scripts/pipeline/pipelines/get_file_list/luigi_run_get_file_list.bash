#!/bin/bash

# Description
# This script tests teh get_file_list luigi component

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${project_dir}/../../scripts/setup.bash

# add luigi scripts to the python path
export PYTHONPATH=${luigip}

# run luigi pipeline
luigi --module get_file_list GetFileList --config-file-name ${config}/aws_config.json --output-dir ${runs}/999 --dataset-id 2 --user-name root --passwd omero --local-scheduler
