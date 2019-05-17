#!/bin/bash

# Description
# This script executes the cell_profiler docker container
# that implements the cell_profiler pipeline component.

# Args
# $1: Full path to json config file containing environment config data.
# $2: cppipe file full path name.
# $3: output directory: output full path directory name
# $4: Omero User Name
# $5: Omero passwd

# the expected number of args
num_expected_args=5

# if the number of args not equal to the number of expected args
if [ "${#}" -ne ${num_expected_args} ]; then
    echo "${0}: Error - Expected ${num_expected_args} args but received ${#} args."
    echo "Usage: ${0} <json config file> <cppipe file> <output dir> <omero user name> <omero passwd>"
    exit 1
fi

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${project_dir}/../../scripts/setup.bash

# get the input args
config_file=${1}
cppipe_file=${2}
output_dir=${3}
user_name=${4}
passwd=${5}

# source the common setup script
source ${project_dir}/../../scripts/container_common_setup.bash

# print the args to the log file
echo "config file name: ${config_file}" &>> ${log_file}
echo "cppipe file name: ${cppipe_file}" &>> ${log_file}
echo "output_dir: ${output_dir}" &>> ${log_file}
echo "component output dir: ${component_output_dir}" &>> ${log_file}
echo "user name: ${user_name}" &>> ${log_file}

# The omero url input file is located in the get_file_list component's output dir
omero_url_input_file=${output_dir}/get_file_list/${get_file_list_file_name}
echo "omero_url_input_file: ${omero_url_input_file}" &>> ${log_file}

# run the cell profiler docker image with the supplied args
# note that we pass 2 args to the docker image:
#   arg1: The config file name
#   arg2: The omero user name
#   arg3: The omero passwd
#   arg4: The cellprofiler command which the launcher needs to run
# Redirect the output to the log directory
echo "Starting cell profiler docker image" &>> ${log_file}
docker run --name ${my_docker_image_name} \
-v ${shared_volume_dir}:${shared_volume_dir} ${my_docker_image_name} \
${config_file} \
${user_name} \
${passwd} \
${component_output_dir} \
${cell_profiler_success_file_name} \
"cellprofiler -c -r \
--pipeline=${cppipe_file} \
--data-file=${omero_url_input_file} \
-o ${component_output_dir}" &>> ${log_file}

# write the end time to the log file
end_time=`date +%Y-%m-%d.%H:%M:%S`
echo "Ending ${my_docker_image_name} ${end_time}" &>> ${log_file}
