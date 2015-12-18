#!/bin/bash -e
# My-First-Deploy
#
###############################################################################################
# This is the demo version of a build script for the CODE-RADE. Customise it for your needs.  #
###############################################################################################

# This script has check that the application that you want can be built on the build slaves.
# There are very few libraries installed by default on the sites, so you have to assume the lowest
# common denominator.

# If you are building from tarball, such as code obtained from sourceforge or github releases, you can use the
# NAME and VERSION variables defined in the Jenkins job to get the right package for you.
# Be careful of capitalisation and semantic versioning differences
# E.g. ApplicationName-v.1.2.3 is different from application-name-1.2.3 and so on.

SOURCE_FILE=${NAME}-${VERSION}.tar.gz

# We provide the base module which all jobs need to get their environment on the build slaves
# this module provides certain environment variables which are needed to configure the job's
# build environment and directories, as well as targets.
# You get
# MODULES /repo/modules - the directory where other modules are
# SOFT_DIR /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$::env(VERSION)
#          - the directory relative to which the application will be installed
# REPO_DIR /repo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$::env(VERSION)
#          - a directory to store build artifacts in.
# SRC_DIR                /repo/src/$::env(NAME)/$::env(VERSION)


module load ci
# In order to get started, we need to ensure that the following directories are available
# This may not be the first build, so you need to perform this check.

# Workspace is the "home" directory of the jenkins job into which the project itself will be created and built.
mkdir -p ${WORKSPACE}
# SRC_DIR is the local directory to which all of the source code tarballs are downloaded. We cache them locally.
mkdir -p ${SRC_DIR}
# SOFT_DIR is the directory into which the application will be "installed" in the integration phase.
# installation to the /cvmfs target takes place later in the build flow.
mkdir -p ${SOFT_DIR}

#  Download the source file if it's not available locally.
# note that there may be parallel downloads, which is not great, so we need to
# place a lock on the download to the SRC directory and wait until it's released if Someone
# else is doing it.


# We will use GMP - the GNU Multiprecision library as an example
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
# use local mirrors if you can. Remember - UFS has to pay for the bandwidth!
  wget http://mirror.ufs.ac.za/gnu/gnu/gmp/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

# now unpack it into the workspace - be sure to skip old files un case the tarball has already been unpacked.
tar -xzf ${SRC_DIR}/${SOURCE_FILE} -C ${{WORKSPACE} --skip-old-files

#  generally tarballs will unpack into the NAME-VERSION directory structure. If this is not the case for your application
#  ie, if it unpacks into a different default directory, either use the relevant tar commands, or change
#  the next lines

# Most projects do not allow in-source building, so we create a build directory
# We will be running configure and make in this directory, which can be cleaned if the build is successful.
# The BUILD_NUMBER variable is passed by Jenkins and increments with every execution of the job.


mkdir -p ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/${NAME}-${VERSION}
# Note that $SOFT_DIR is used as the target installation directory.
./configure --prefix ${SOFT_DIR}

# The build nodes have 8 cores, but jobs can be scheduled on them in parallel. There are 4 slots, so choose at most
# a build paralellism of 2.
make -j 2

# At this point your job has been built. If this phase has been successful, Jenkins will move on to the next phase : check-build.
