#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
AFNI_DIR=${SETUP_ROOT}/afni
PATH=${AFNI_DIR}:${PATH}

# Check and cleanup old installation
if [ -d ${AFNI_DIR} ]
then
    echo "Cleanup old AFNI installation ..."
    rm -rf ${AFNI_DIR}
fi
if [ -d ~/.afni/help ]
then
    echo "Cleanup old AFNI help files ..."
    rm -rf ~/.afni/help
fi
if [ -f ~/.afnirc ]
then
    echo "Cleanup old AFNI rc files ..."
    rm ~/.afnirc
fi
if [ -f ~/.sumarc ]
then
    echo "Cleanup old SUMA rc files ..."
    rm ~/.sumarc
fi

# AFNI
curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries
tcsh @update.afni.binaries -package macos_10.12_local -bindir ${AFNI_DIR} -apsearch yes
rm @update.afni.binaries
cp ${AFNI_DIR}/AFNI.afnirc ${HOME}/.afnirc
suma -update_env
apsearch -update_all_afni_help

# Post installation cleanup
if [ -f .R.Rout ]
then
    rm .R.Rout
fi

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# AFNI
export PATH=${AFNI_DIR}:\${PATH}
export DYLD_LIBRARY_PATH=\${DYLD_LIBRARY_PATH}:/opt/X11/lib/flat_namespace
"
