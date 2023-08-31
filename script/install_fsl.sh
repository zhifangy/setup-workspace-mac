#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
FSL_DIR=${SETUP_ROOT}/neurotools/fsl
FSL_VERSION=${FSL_VERSION:-6.0.7.2}

# Cleanup old installation
if [ -d ${FSL_DIR} ]; then echo "Cleanup old FSL installation..." && rm -rf ${FSL_DIR}; fi

# Install
echo "Installing FSL from offical website..."
wget -q https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py -P ${SETUP_ROOT}
chmod +x ${SETUP_ROOT}/fslinstaller.py
${SETUP_ROOT}/fslinstaller.py -V ${FSL_VERSION} -d ${FSL_DIR} --no_env
mv ${SETUP_ROOT}/fslinstaller.py ${FSL_DIR}/fslinstaller.py

# Use newer version of MSM
wget https://github.com/ecr05/MSM_HOCR/releases/download/v3.0FSL/msm_mac_v3 -P ${FSL_DIR}
mv -fv ${FSL_DIR}/msm_mac_v3 ${FSL_DIR}/share/fsl/bin/msm
chmod 755 ${FSL_DIR}/share/fsl/bin/msm

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# FSL
export FSLDIR=${FSL_DIR}
export \\
    FSLOUTPUTTYPE=NIFTI_GZ \\
    FSLMULTIFILEQUIT=TRUE \\
    FSLTCLSH=\${FSLDIR}/bin/fsltclsh \\
    FSLWISH=\${FSLDIR}/bin/fslwish \\
    FSLGECUDAQ=cuda.q \\
    FSLLOCKDIR= \\
    FSLMACHINELIST= \\
    FSLREMOTECALL= \\
    FSL_LOAD_NIFTI_EXTENSIONS=0 \\
    FSL_SKIP_GLOBAL=0
export PATH=\${FSLDIR}/share/fsl/bin:\${PATH}
"
