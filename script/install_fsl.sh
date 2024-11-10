#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
FSL_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/fsl")"
FSL_VERSION=${FSL_VERSION:-6.0.7.14}

# Cleanup old installation
if [ -d ${FSL_DIR} ]; then echo "Cleanup old FSL installation..." && rm -rf ${FSL_DIR}; fi

# Install
echo "Installing FSL from offical website..."
mkdir -p $FSL_DIR
wget -q https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py -P $FSL_DIR
chmod +x ${FSL_DIR}/fslinstaller.py
${FSL_DIR}/fslinstaller.py -V ${FSL_VERSION} -d ${FSL_DIR} --no_env --skip_registration

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
