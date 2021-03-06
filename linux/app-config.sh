#! /bin/bash

#
#  app-config.sh - Generates nrtest app configuration file for test executable
#
#  Date Created: 11/15/2017
#
#  Authors:      Michael E. Tryby
#                US EPA - ORD/NRMRL
#                
#                Caleb A. Buahin
#                Xylem Inc.
#
#  Requires:
#    git
#
#  Environment Variables:
#    PROJECT
#    PLATFORM
#                  
#  Arguments:
#    1 - absolute path to test executable
#    2 - (SUT build it)
#

# Check requirements 
type git >/dev/null 2>&1 || { echo "ERROR: git not installed"; exit 1; }


# check that env variables are set
if [[ ! -v PROJECT ]]; then echo "ERROR: PROJECT must be defined"; exit 1; fi
if [[ ! -v PLATFORM ]]; then echo "ERROR: PLATFORM must be defined"; exit 1; fi

# check if project is swmm otherwise EPANET
if [[ ${PROJECT} == *"swmm"* ]]; then
    TEST_CMD="run-${PROJECT}"
else
    TEST_CMD="run${PROJECT}"
fi

# path to executable in cmake build tree
ABS_BUILD_PATH=$1

# process optional arguments
if [ ! -z "$2" ]; then
    BUILD_ID=$2
else
    BUILD_ID="unknown"
fi

# determine version
VERSION=$( git rev-parse --short HEAD )
if [ -z ${VERSION} ]; then echo "ERROR: VERSION must be determined"; exit 1; fi;

build_description="${PLATFORM} ${BUILD_ID}"

cat<<EOF
{
    "name" : "${PROJECT}",
    "version" : "${VERSION}",
    "description" : "${build_description}",
    "setup_script" : "",
    "exe" : "${abs_build_path}/${test_cmd}"
}
EOF
