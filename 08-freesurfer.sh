#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
FREESURFER_DIR=${SETUP_ROOT}/freesurfer

# FreeSurfer
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.1.1/freesurfer-darwin-macOS-7.1.1.tar.gz
mkdir ${FREESURFER_DIR} && tar -xzf freesurfer-darwin-macOS-7.1.1.tar.gz -C ${FREESURFER_DIR} --strip-components 1
rm freesurfer-darwin-macOS-7.1.1.tar.gz

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
