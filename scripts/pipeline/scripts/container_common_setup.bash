#!/bin/bash

# Description
# This script is used as a common script which is called to set up the
# environment for containers.

# get the docker image name
my_docker_image_name="$(basename ${project_dir})"

# verify that the output dir exists
if [ ! -d ${output_dir} ]
then
    echo "${0}: Error - output dir ${output_dir} does not exist"
    exit 1
fi

# if the DONT_CREATE_COMPONENT_SUB_DIR env var is set
if [[ ! -z "${DONT_CREATE_COMPONENT_SUB_DIR}" ]]; then
    # don't create the component sub directory
    component_output_dir=${output_dir}
else
    # create the component sub directory directory
    component_output_dir=${output_dir}/${my_docker_image_name}
    mkdir -p ${component_output_dir}
    chmod a+w ${component_output_dir}
fi

# create the log file name based on the current time
now=`date +%Y-%m-%d.%H:%M:%S`
log_file=${component_output_dir}/${my_docker_image_name}.log

# echo the start time to the log file
echo "Starting ${my_docker_image_name} ${now}" &> ${log_file}

# remove the docker image from the previous run
# not all components have docker images but that's okay
echo "Removing ${my_docker_image_name} container from previous run ..." &>> ${log_file}
docker rm ${my_docker_image_name} &>> ${log_file}
