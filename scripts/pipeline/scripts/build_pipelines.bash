#!/bin/bash

# Description:
# This file builds all pipelines contained in the
# pipelines directory.  The pipeline_list env var defined in
# setup.bash is used to define the pipeline components which need to
# be built.

# get the project location
build_pipelines_project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# run setup
source ${build_pipelines_project_dir}/setup.bash

# for each pipeline that needs to be built
for pipeline in ${pipeline_list}
do
    # build the pipeline docker image
    echo "Building piepline: ${pipeline}"
    pipeline_to_build=${pipelines}/${pipeline}
    pipeline_build_script=${pipelines}/${pipeline}/build_${pipeline}.bash

    # if this pipeline component has a build script
    if [ -f ${pipeline_build_script} ]; then
        # build the pipeline
        # echo "${pipeline_build_script} ${pipeline} ${pipeline_to_build}/Dockerfile ${pipeline_to_build}"
        ${pipeline_build_script} ${pipeline} ${pipeline_to_build}/Dockerfile ${pipeline_to_build}
    fi
done
