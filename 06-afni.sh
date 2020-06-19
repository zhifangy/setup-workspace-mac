#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
AFNI_DIR=${SETUP_ROOT}/afni
PATH=${AFNI_DIR}:${PATH}

# AFNI
curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries
tcsh @update.afni.binaries -package macos_10.12_local -bindir ${AFNI_DIR} -apsearch yes
rm @update.afni.binaries
cp ${AFNI_DIR}/AFNI.afnirc ${HOME}/.afnirc
suma -update_env
apsearch -update_all_afni_help

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# AFNI
export PATH=${AFNI_DIR}:\${PATH}
export DYLD_LIBRARY_PATH=\${DYLD_LIBRARY_PATH}:/opt/X11/lib/flat_namespace
"
