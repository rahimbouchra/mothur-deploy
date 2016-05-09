#!/bin/bash -e
. /etc/profile.d/modules.sh
module avail
module add ci 
module add boost/1.59.0-gcc-5.1.0-mpi-1.8.8
module add readline/6.3 
module add ncurses/5.9

#current download link :https://github.com/mothur/mothur/archive/v1.37.3.tar.gz
SOURCE_FILE=${NAME}-${VERSION}.tar.gz

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "Seems that the latest version is not available under ${SRC_DIR} - downloading from github"
  wget https://github.com/${NAME}/${NAME}/archive/v${VERSION}.tar.gz -O  ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  # the tarball is there and has finished downlading
    echo "continuing from previous builds, using source at ${SRC_DIR}/${SOURCE_FILE}"
fi
tar xzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files

#mkdir -p ${WORKSPACE}/${NAME}-${VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}
echo "Running the build"
echo "mothur needs readline dev file ... disable  " 
export USEREADLINE=no
export BOOST_LIBRARY_DIR=$BOOST_DIR/lib
make 


