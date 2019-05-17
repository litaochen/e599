#!/bin/bash

# Description
# This is the top level build script for the cell profiler docker image.

# Args
# arg1: Docker image name:tag (tag is optional)
# arg2: Path to Dockerfile (typically in this dir)
# arg3: Path to directory in which to build the Docker image (typically this dir)

# Build the docker image
docker build -t ${1} -f ${2} ${3}
