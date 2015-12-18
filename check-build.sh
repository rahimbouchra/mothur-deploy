#!/bin/bash -e
# My-First-Deploy
#
###############################################################################################
# This is the demo version of a build script for the CODE-RADE. Customise it for your needs.  #
###############################################################################################

# If you have gotten this far, congratulations ! the first test has passed - compilation
# Now you have to check whether the application has been _properly_ compiled and whether it can execute
# properly.
# Most Open Source projects provide built-in tests which you can run using the makefile, but it's also a
# good idea to try to execute the program itself with a trivial use case.

# you need the CI module to set up your environment.

module add ci

# we need to run make check in the build directory - it's still there from the previous step, since we're in the same job.
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
nice -n20 make -j2 check

# If this has passed, you can install the package
make install

# this should put things in $SOFT_DIR, which you recall is relative to /apprepo

###### MODULE FILE ########
# Now we have to create the modulefile so that we can use this application later
###########################

# this is the modulefile that will be used for integration.
mkdir -p modules/ci
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
set       GMP_VERSION       $VERSION
set       GMP_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$VERSION
setenv    GMP_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$VERSION
prepend-path LD_LIBRARY_PATH \$GMP_DIR/lib
prepend-path GCC_INCLUDE_DIR  \$GMP_DIR/include
setenv CFLAGS "-I\$GMP_DIR/include -L\$GMP_DIR/lib"
MODULE_FILE
) > modules/ci/${VERSION}

# LIBRARIES_MODULES is set by the CI module - it is a bit different for the deploy environment
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/ci/${VERSION} ${LIBRARIES_MODULES}/${NAME}

# Now we have to build the artifact. This is a tarball at the lowest directory level which we can use to re-deploy
# REPO_DIR is defined by the CI module
mkdir -p ${REPO_DIR}
tar cvfz ${REPO_DIR}/build-${BUILD_NUMBER}.tar.gz -C ${SOFT_DIR} .
# we are no ready to deploy.
