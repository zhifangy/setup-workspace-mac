#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
FREESURFER_DIR=${SETUP_ROOT}/freesurfer

# Backup license.txt from existed FreeSurfer folder
if [ -d ${FREESURFER_DIR} ]
then
    if [ -f ${FREESURFER_DIR}/license.txt ]
    then
        echo "Backup FreeSurfer license from existed installation ..."
        cp ${FREESURFER_DIR}/license.txt ${SETUP_ROOT}/license.txt
    fi
    echo "Cleanup old FreeSurfer installation ..."
    rm -rf ${FREESURFER_DIR}
fi

# FreeSurfer
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.3.2/freesurfer-darwin-macOS-7.3.2.tar.gz
mkdir ${FREESURFER_DIR} && tar -xzf freesurfer-darwin-macOS-7.3.2.tar.gz -C ${FREESURFER_DIR} --strip-components 1
rm freesurfer-darwin-macOS-7.3.2.tar.gz

# Move previous license.txt to new FreeSurfer folder
mkdir ${FREESURFER_DIR}
if [ -f ${SETUP_ROOT}/license.txt ]
then
    echo "Move previous FreeSurfer license to new installation ..."
    mv ${SETUP_ROOT}/license.txt ${FREESURFER_DIR}/license.txt
else
    echo "Use default personal FreeSurfer license ..."
    base64 --decode <<<  emhpZmFuZy55ZS5mZ2htQGdtYWlsLmNvbQozMDgyNwogKkNBanR5YkNZNDByTQogRlM5dmVNeDhnbnVxUQo= > ${FREESURFER_DIR}/license.txt
fi

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# FreeSurfer
export FREESURFER_HOME=${FREESURFER_DIR}
export SUBJECTS_DIR=\${FREESURFER_HOME}/subjects
export FUNCTIONALS_DIR=\${FREESURFER_HOME}/sessions
export FS_FREESURFERENV_NO_OUTPUT=1
source \${FREESURFER_HOME}/FreeSurferEnv.sh
"
