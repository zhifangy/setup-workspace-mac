#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
export FSLDIR=${SETUP_ROOT}/fsl
FSL_VERSION=6.0.7.1

# Check and cleanup old installation
if [ -d ${FSLDIR} ]; then
    echo "Cleanup old FSL installation..."
    rm -rf ${FSLDIR}
fi

# FSL
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py
chmod +x fslinstaller.py
./fslinstaller.py -V ${FSL_VERSION} -d ${FSLDIR} --no_env
mv fslinstaller.py ${FSLDIR}/fslinstaller.py
# Use newer version of MSM
wget https://github.com/ecr05/MSM_HOCR/releases/download/v3.0FSL/msm_mac_v3 && \
mv -fv msm_mac_v3 ${FSLDIR}/share/fsl/bin/msm
chmod 755 ${FSLDIR}/share/fsl/bin/msm

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# FSL
export FSLDIR=${FSLDIR}
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
