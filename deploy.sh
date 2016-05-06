#!/bin/bash -e
. /etc/profile.d/modules.sh

module add deploy
module add boost/1.59.0-gcc-5.1.0-mpi-1.8.8
module add readline/6.3 
module add ncurses/5.9
echo "making ${SOFT_DIR}"
mkdir -p ${SOFT_DIR}

cd ${WORKSPACE}/${NAME}_${VERSION}/
export USEREADLINE=no
export BOOST_LIBRARY_DIR=$BOOST_DIR/lib
make 

# copy generated exe to soft_dir
echo "making ${SOFT_DIR}"
mkdir -p ${SOFT_DIR}

cp -v mothur uchime ${SOFT_DIR}/

echo "Creating the modules file directory "
mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
   puts stderr "       This module does nothing but alert the user"
   puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION. "
setenv       MOTHUR_VERSION       $VERSION
setenv       MOTHUR_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                 $::env(MOTHUR_DIR)/
MODULE_FILE
) >  ${BIOINFORMATICS_MODULES}/${NAME}/${VERSION}
