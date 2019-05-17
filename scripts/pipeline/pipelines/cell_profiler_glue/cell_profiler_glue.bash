#!/bin/bash

# Description
# This script is the top level glue script that executes the cell_profiler pipeline.
# Calls the get_file_list, cell_profiler, and TBD components to implement an
# end to end pipeline

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

# get the docker image name
cell_profiler_glue_image_name="$(basename ${project_dir})"

# get the input args
dataset_id=${1}
cppipe_file_name=${2}
output_dir=${3}
config_file_name=${4}
user_name=${5}
passwd=${6}

# source the common setup script
source ${project_dir}/../../scripts/container_common_setup.bash

# echo a startup msg
echo "Starting ${0}" &> ${log_file}
echo "component output dir: ${component_output_dir}" &>> ${log_file}
echo "dataset_id: ${dataset_id}" &>> ${log_file}
echo "cppipe_file_name: ${cppipe_file_name}" &>> ${log_file}
echo "output_dir: ${output_dir}" &>> ${log_file}
echo "config_file_name: ${config_file_name}" &>> ${log_file}
echo "user name: ${user_name}" &>> ${log_file}
echo "passwd: ${passwd}" &>> ${log_file}
echo ""

# run get_file_list
${get_file_list}/get_file_list.bash ${config_file_name} ${output_dir} ${dataset_id} ${user_name} ${passwd}

# run cell profiler
${cell_profiler}/cell_profiler.bash ${config_file_name} ${cppipe_file_name} ${output_dir} ${user_name} ${passwd}

# run the result parser
${parse_cp_output}/parse_cp_output.bash ${config_file_name} ${output_dir}
