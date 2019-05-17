#!/bin/bash

# Description
# This script executes the get_file_list docker container
# that implements the get_file_list pipeline component.

# Args
# arg1: Full path to json config file containing environment config data.
# arg2: Full path to output directory in which to save data
# arg3: Omero dataset ID to create the file list from. This is an integer like 103.
# arg4: Omero User Name
# arg5: Omero passwd

# the expected number of args
num_expected_args=5

# if the number of args not equal to the number of expected args
if [ "${#}" -ne ${num_expected_args} ]; then
    echo "${0}: Error - Expected ${num_expected_args} args but received ${#} args."
    echo "Usage: ${0} <json config file> <output dir> <dataset id> <omero user name> <omero passwd>"
    exit 1
fi

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${project_dir}/../../scripts/setup.bash

# get the input args
config_file=${1}
output_dir=${2}
dataset_id=${3}
user_name=${4}
passwd=${5}

# source the common setup script
source ${project_dir}/../../scripts/container_common_setup.bash

echo "config file: ${config_file}" &>> ${log_file}
echo "output dir: ${output_dir}" &>> ${log_file}
echo "component output dir: ${component_output_dir}" &>> ${log_file}
echo "dataset ID: ${dataset_id}" &>> ${log_file}
echo "user_name: ${user_name}" &>> ${log_file}

# note: the get_file_list_file_name env var comes from setup.bash
echo "output file list name: ${get_file_list_file_name}" &>> ${log_file}

# run the get_file_list docker image with the supplied args and redirect
# the output to the log directory
echo "Starting get_file_list docker image" &>> ${log_file}
docker run -t -i --name ${my_docker_image_name} \
       -v ${shared_volume_dir}:${shared_volume_dir} \
       ${my_docker_image_name} ${config_file} \
       ${dataset_id} \
       ${output_dir}/${my_docker_image_name}/${get_file_list_file_name} \
       ${user_name} \
       ${passwd} &>> ${log_file}

# write the end time to the log file
end_time=`date +%Y-%m-%d.%H:%M:%S`
echo "Ending ${my_docker_image_name} ${end_time}" &>> ${log_file}
