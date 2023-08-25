#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
FREESURFER_DIR=${SETUP_ROOT}/neurotools/freesurfer
FREESURFER_VERSION=${FREESURFER_VERSION:-7.4.1}

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

# Install
echo "Installing FreeSurfer from offical website..."
mkdir -p ${FREESURFER_DIR}
wget -q https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${FREESURFER_VERSION}/freesurfer-macOS-darwin_x86_64-${FREESURFER_VERSION}.tar.gz \
    -P ${FREESURFER_DIR}
tar -xzf ${FREESURFER_DIR}/freesurfer-macOS-darwin_x86_64-${FREESURFER_VERSION}.tar.gz -C ${FREESURFER_DIR} --strip-components 2
rm ${FREESURFER_DIR}/freesurfer-macOS-darwin_x86_64-${FREESURFER_VERSION}.tar.gz

# Move previous license.txt to new FreeSurfer folder
if [ -f ${SETUP_ROOT}/license.txt ]
then
    echo "Move previous FreeSurfer license to new installation ..."
    mv ${SETUP_ROOT}/license.txt ${FREESURFER_DIR}/license.txt
else
    echo "Use default personal FreeSurfer license ..."
    base64 --decode <<<  emhpZmFuZy55ZS5mZ2htQGdtYWlsLmNvbQozMDgyNwogKkNBanR5YkNZNDByTQogRlM5dmVNeDhnbnVxUQo= > ${FREESURFER_DIR}/license.txt
fi

# Put app to /Applications folder
if [[ -d /Applications/Freeview.app || -L /Applications/Freeview.app ]]; then rm /Applications/Freeview.app; fi
ln -s ${FREESURFER_DIR}/Freeview.app /Applications/Freeview.app

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# FreeSurfer
export FREESURFER_HOME=${FREESURFER_DIR}
export \\
    OS=Linux \\
    FS_OVERRIDE=0 \\
    FSFAST_HOME=\${FREESURFER_HOME}/fsfast \\
    SUBJECTS_DIR=\${FREESURFER_HOME}/subjects \\
    FUNCTIONALS_DIR=\${FREESURFER_HOME}/sessions \\
    MINC_BIN_DIR=\${FREESURFER_HOME}/mni/bin \\
    MNI_DIR=\${FREESURFER_HOME}/mni \\
    MINC_LIB_DIR=\${FREESURFER_HOME}/mni/lib \\
    MNI_DATAPATH=\${FREESURFER_HOME}/mni/data \\
    FSL_DIR=\${FSLDIR} \\
    LOCAL_DIR=\${FREESURFER_HOME}/local \\
    FSF_OUTPUT_FORMAT=nii.gz \\
    FMRI_ANALYSIS_DIR=\${FREESURFER_HOME}/fsfast \\
    MNI_PERL5LIB=\${FREESURFER_HOME}/mni/Library/Perl/Updates/5.12.3 \\
    PERL5LIB=\${FREESURFER_HOME}/mni/Library/Perl/Updates/5.12.3 \\
    FSL_BIN=\${FSLDIR}/share/fsl/bin \\
    FREESURFER=\${FREESURFER_HOME} \\
    FIX_VERTEX_AREA= \\
    FS_LICENSE=\${FREESURFER_HOME}/license.txt
export PATH=\${FREESURFER_HOME}/bin:\${FSFAST_HOME}/bin:\${FREESURFER_HOME}/tktools:\${MINC_BIN_DIR}:\${PATH}
"
