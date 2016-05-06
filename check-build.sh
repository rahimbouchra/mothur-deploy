#!/bin/bash
. /etc/profile.d/modules.sh

module add ci

echo "copy  generated exe to $SOFT_DIR"
cd ${WORKSPACE}/${NAME}-${VERSION}/
ls
echo $?
cp -v mothur uchime $SOFT_DIR/

echo "About to make the modules"
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
   puts stderr "       This module does nothing but alert the user"
   puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION. See https://github.com/SouthAfricaDigitalScience/mothur-deploy"
setenv       MOTHUR_VERSION       $VERSION
setenv       MOTHUR_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(MOTHUR_DIR)/
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
cp modules/${VERSION} ${BIOINFORMATICS_MODULES}/${NAME}

module avail
module list
module add ${NAME}/${VERSION}
which mothur
