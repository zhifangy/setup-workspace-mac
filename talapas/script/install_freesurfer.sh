#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/freesurfer")"
FREESURFER_VERSION=${FREESURFER_VERSION:-7.4.1}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then
    # backup license.txt from existed FreeSurfer folder
    if [ -f ${INSTALL_PREFIX}/license.txt ]; then
        echo "Backup FreeSurfer license from existed installation ..."
        cp ${INSTALL_PREFIX}/license.txt $(eval "echo ${SETUP_PREFIX}")/license.txt
    fi
    echo "Cleanup old FreeSurfer installation ..."
    rm -rf ${INSTALL_PREFIX}
fi

# Install
echo "Installing FreeSurfer from offical website..."
mkdir -p ${INSTALL_PREFIX}
wget -q https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${FREESURFER_VERSION}/freesurfer-linux-centos8_x86_64-${FREESURFER_VERSION}.tar.gz \
    -P ${INSTALL_PREFIX}
tar -xzf ${INSTALL_PREFIX}/freesurfer-linux-centos8_x86_64-${FREESURFER_VERSION}.tar.gz -C ${INSTALL_PREFIX} --strip-components 2
rm ${INSTALL_PREFIX}/freesurfer-linux-centos8_x86_64-${FREESURFER_VERSION}.tar.gz

# Move previous license.txt to new FreeSurfer folder
if [ -f $(eval "echo ${SETUP_PREFIX}")/license.txt ]; then
    echo "Move previous FreeSurfer license to new installation ..."
    mv $(eval "echo ${SETUP_PREFIX}")/license.txt ${INSTALL_PREFIX}/license.txt
else
    echo "Use default personal FreeSurfer license ..."
    base64 --decode <<<  emhpZmFuZy55ZS5mZ2htQGdtYWlsLmNvbQozMDgyNwogKkNBanR5YkNZNDByTQogRlM5dmVNeDhnbnVxUQo= > ${INSTALL_PREFIX}/license.txt
fi

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# FreeSurfer
export FREESURFER_HOME=\"${SETUP_PREFIX}/freesurfer\"
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
export PATH=\"\${FREESURFER_HOME}/bin:\${FSFAST_HOME}/bin:\${FREESURFER_HOME}/tktools:\${MINC_BIN_DIR}:\${PATH}\"
"
