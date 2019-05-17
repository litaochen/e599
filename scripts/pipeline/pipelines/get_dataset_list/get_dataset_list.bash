#!/bin/bash

# Description
# This script executes the get_dataset_list docker container
# that implements the get_dataset_list pipeline component.

# Args
# arg1: Full path config file name.
# arg2: OMERO user name
# arg3: OMERO passwd
# arg4: Full path output directory

# the expected number of args
num_expected_args=4

# if the number of args not equal to the number of expected args
if [ "${#}" -ne ${num_expected_args} ]; then
    echo "${0}: Error - Expected ${num_expected_args} args but received ${#} args."
    echo "Usage: ${0} <json config file> <omero user name> <omero passwd> <output dir>"
    exit 1
fi

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${project_dir}/../../scripts/setup.bash

# get the input args
config_file=${1}
user_name=${2}
passwd=${3}
output_dir=${4}

# source the common setup script
DONT_CREATE_COMPONENT_SUB_DIR="True"
source ${project_dir}/../../scripts/container_common_setup.bash

# create the output file name
out_file_name=${output_dir}/${user_name}_dataset_list.json

echo "config file: ${config_file}" &>> ${log_file}
echo "user name: ${user_name}" &>> ${log_file}
echo "output dir: ${output_dir}" &>> ${log_file}
echo "output file name: ${out_file_name}" &>> ${log_file}

# run the get_dataset_list docker image with the supplied args and redirect
# the output to the log directory
echo "Running get_dataset_list docker image" &>> ${log_file}
docker run -t -i --name ${my_docker_image_name} \
       -v ${shared_volume_dir}:${shared_volume_dir} \
       ${my_docker_image_name} \
       ${config_file} \
       ${user_name} \
       ${passwd} \
       ${out_file_name} \
       &>> ${log_file}

# write the end time to the log file
end_time=`date +%Y-%m-%d.%H:%M:%S`
echo "Ending ${my_docker_image_name} ${end_time}" &>> ${log_file}
