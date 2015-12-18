#!/bin/bash -e
# this should be run after check-build finishes.
# Deploy.sh is the script which is used to reconfigure and install the application to the fastrepo.
# We need to do this in order to keep the symbolic links in the deployed libraries correct.
# IE when we do integration, we install to /apprepo locally, but
# When applications are in the repo, they will be referred to by /cvmfs/<repo-name>
# So, especially if we are linking against things already in the repo, we need to recompile against these
# libraries in /cvmfs instead of /apprepo
. /etc/profile.d/modules.sh
# We now add the deploy module, which changes the path of $SOFT_DIR
module add deploy
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
#  Remove the previous configuration
rm -rf *
# Be sure to use the same config as in build.sh
CFLAGS=-fPIC ../configure --prefix ${SOFT_DIR} \
--enable-fft \
--enable-static \
--enable-cxx \
--enable-shared \
--enable-old-fft-full \
--enable-assert
make -j2
echo "Making install to $SOFT_DIR"
make install
# We are making the module for fastrepo
echo "Creating the modules file directory ${LIBRARIES_MODULES}/fastrepo/"
mkdir -p ${LIBRARIES_MODULES}/fastrepo/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/gmp-deploy"
set GMP_VERSION   $VERSION
## We need to add this to the environment as well, else other modules won't pick it up.
setenv GMP_VERSION $::env(VERSION)
set GMP_DIR        $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$GMP_VERSION
setenv GMP_DIR     $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$GMP_VERSION
prepend-path LD_LIBRARY_PATH   \$GMP_DIR/lib
prepend-path GCC_INCLUDE_DIR   \$GMP_DIR/include
setenv CFLAGS "$::env(CFLAGS) -I\$GMP_DIR/include -L\$GMP_DIR/lib"
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}
