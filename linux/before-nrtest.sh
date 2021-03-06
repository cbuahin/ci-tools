#! /bin/bash
# 
#  before-test.sh - Prepares Travis CI worker to run swmm regression tests
#
#  Date Created: 04/05/2018
#
#  Authors:      Michael E. Tryby
#                US EPA - ORD/NRMRL
#
#                Caleb A. Buahin
#                Xylem Inc.
#
#  Dependencies:
#    curl
#    tar
#
#  Environment Variables:
#    PROJECT
#    BUILD_HOME - relative path
#    PLATFORM
#
#  Arguments:
#    1 - (RELEASE_TAG)  - Release tag
#    2 - (BENCHMARK_VER) - Optional benchmark version
#
#  Note: 
#    Tests and benchmark files are stored in the swmm-example-networks repo.
#    This script retreives them using a stable URL associated with a release on 
#    GitHub and stages the files for nrtest to run. The script assumes that 
#    before-test.sh and app-config.sh are located together in the same folder. 


export TEST_HOME="nrtests"


# check that env variables are set
REQUIRED_VARS=('PROJECT' 'BUILD_HOME' 'PLATFORM')
for i in ${REQUIRED_VARS[@]}
do
    if [[ -v i ]]; then
      echo "ERROR: $i must be defined"; exit 1; 
    fi
done

# determine project directory
CUR_DIR=${PWD}
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${SCRIPT_HOME}/../../


# set URL to github repo with nrtest files
NRTESTS_URL="https://github.com/OpenWaterAnalytics/${PROJECT}-example-networks"
LATEST_URL="${NRTESTS_URL}/releases/latest"


# use release tag arg else determine latest
if [[ ! -z "$1" ]]
then
    RELEASE_TAG=$1
else
    RELEASE_TAG=$( curl -sI "${LATEST_URL}" | grep -Po 'tag\/\K(v\S+)' )
    RELEASE_TAG=$( basename ${RELEASE_TAG} ) # unnecessary 
fi


# check benchmark version 
if [[ ! -z "$2" ]]
then
    BENCHMARK_VER=$2
fi


# build URLs for test and benchmark files; need to standardize urls or change into argument
if [[ -v RELEASE_TAG ]]
then
  TESTFILES_URL="${NRTESTS_URL}/archive/${RELEASE_TAG}.tar.gz"

  if [[ -v BENCHMARK_VER ]]
  then
    BENCHFILES_URL="${NRTESTS_URL}/releases/download/${RELEASE_TAG}/$PROJECT-benchmark-${BENCHMARK_VER}.tar.gz"
  else
    echo "ERROR: tag %BENCHMARK_VER% is invalid" ; exit 1

else
  echo "ERROR: tag %RELEASE_TAG% is invalid" ; exit 1
fi

echo INFO: Staging files for regression testing

# create a clean directory for staging regression tests
if [ -d ${TEST_HOME} ]; then
  rm -rf ${TEST_HOME}
fi

mkdir ${TEST_HOME}
cd ${TEST_HOME}

# retrieve swmm-examples for regression testing
curl -fsSL -o nrtestfiles.tar.gz ${TESTFILES_URL}
# retrieve swmm benchmark results
curl -fsSL -o benchmark.tar.gz ${BENCHFILES_URL}

# extract tests and benchmarks
tar xzf nrtestfiles.tar.gz
ln -s swmm-example-networks-${EXAMPLES_VER}/swmm-tests tests

mkdir benchmark
tar xzf benchmark.tar.gz -C benchmark


# determine REF_BUILD_ID from manifest file
export REF_BUILD_ID="local"

# return user to current dir
cd ${CUR_DIR}

