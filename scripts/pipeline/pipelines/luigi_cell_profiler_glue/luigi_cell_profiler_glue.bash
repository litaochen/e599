#!/bin/bash

# Description
# This script is the top level glue script that executes the cell_profiler pipeline using luigi.

# Args
# $1 = Omero dataset id
# $2 = cppipe file full path name
# $3 = Full path top level outupt dir
# $4 = full path config file name
# $5 = omero user name
# $6 = omero passwd

# if num args received not equal to num expected args
num_expected_args=6
if [ ${#} -ne ${num_expected_args} ]
then
    # print an error and bail out
    echo "${0}: Error - expected ${num_expected_args} args but received ${#} args."
    echo "Usage: ${0} <dataset id> <cppipe file name> <output dir> <config file> <omero user name> <omero passwd>"
    exit 1
fi

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${project_dir}/../../scripts/setup.bash

# export the args as known environment variables for use by the luigi pipeline
export dataset_id=${1}
export cppipe_file=${2}
export output_dir=${3}
export config_file=${4}
export user_name=${5}
export passwd=${6}

# source the common setup script
source ${project_dir}/../../scripts/container_common_setup.bash

# echo a startup msg
echo "Starting ${0}" &> ${log_file}
echo "dataset_id: ${dataset_id}" &>> ${log_file}
echo "cppipe_file: ${cppipe_file}" &>> ${log_file}
echo "output_dir: ${output_dir}" &>> ${log_file}
echo "config_file: ${config_file}" &>> ${log_file}
echo "user_name: ${user_name}" &>> ${log_file}
echo "passwd: ${passwd}" &>> ${log_file}
echo ""

# add luigi python scripts to the python path
export PYTHONPATH=${luigip}

# run luigi pipelineg
luigi --module parse_cp_output ParseCpOutput &>> ${log_file}
