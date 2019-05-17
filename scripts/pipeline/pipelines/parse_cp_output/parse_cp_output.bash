#!/bin/bash

# Description
# This script executes the parse_cp_output docker container

# Args
# $1: Full path to json config file containing environment config data.
# $2: output directory: output full path directory name

# the expected number of args
num_expected_args=2

# if the number of args not equal to the number of expected args
if [ "${#}" -ne ${num_expected_args} ]; then
    echo "${0}: Error - Expected ${num_expected_args} args but received ${#} args."
    echo "Usage: ${0} <json config file> <output dir>"
    exit 1
fi

# get the project location
project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# environment setup
source ${project_dir}/../../scripts/setup.bash

# get the args
config_file=${1}
output_dir=${2}

# source the common setup script
source ${project_dir}/../../scripts/container_common_setup.bash

# print the args to the log file
echo "config file: ${config_file}" &>> ${log_file}
echo "output dir: ${output_dir}" &>> ${log_file}
echo "component output dir: ${component_output_dir}" &>> ${log_file}

# get the run id from the output dir name
run_id="$(basename ${output_dir})"

# run the cell profiler docker image with the supplied args and
# redirect the output to the log directory
echo "Starting parse_cp_output docker image" &>> ${log_file}
docker run --name ${my_docker_image_name} \
-v ${shared_volume_dir}:${shared_volume_dir} ${my_docker_image_name} \
${run_id} ${output_dir}/cell_profiler ${component_output_dir} &>> ${log_file}

# write the end time to the log file
end_time=`date +%Y-%m-%d.%H:%M:%S`
echo "Ending ${my_docker_image_name} ${end_time}" &>> ${log_file}
