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

# Update Freeview to latest dev version
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/freeview/freesurfer-darwin-macOS-dev-freeview.tar.gz
rm -r ${FREESURFER_DIR}/Freeview.app && tar -xzf freesurfer-darwin-macOS-dev-freeview.tar.gz -C ${FREESURFER_DIR}
rm freesurfer-darwin-macOS-dev-freeview.tar.gz

# Apply post-release patch (v7.3.2)
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.3.2-patch/core.py
mv core.py ${FREESURFER_DIR}/python/packages/freesurfer/subregions/
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.3.2-patch/mri_sclimbic_seg
mv mri_sclimbic_seg ${FREESURFER_DIR}/python/scripts/mri_sclimbic_seg
chmod +x ${FREESURFER_DIR}/python/scripts/mri_sclimbic_seg

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
