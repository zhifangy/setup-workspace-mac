#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
FSLDIR=${SETUP_ROOT}/fsl

# FSL
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.3-macOS_64.tar.gz
mkdir ${FSLDIR} && tar -xzf fsl-6.0.3-macOS_64.tar.gz -C ${FSLDIR} --strip-components 1
rm fsl-6.0.3-macOS_64.tar.gz
# A quick and dirty fix for getting latest fsleyes
sed -i'.bak' 's/fsleyes.*/fsleyes/' ${FSLDIR}/etc/fslconf/fslpython_environment.yml
sed -i'.bak' 's/fslpy.*/fslpy/' ${FSLDIR}/etc/fslconf/fslpython_environment.yml
bash ${FSLDIR}/etc/fslconf/post_install.sh
${FSLDIR}/fslpython/bin/conda clean -apy
# Use newer version of MSM
wget https://github.com/ecr05/MSM_HOCR/releases/download/v3.0FSL/msm_mac_v3 && \
mv msm_mac_v3 ${FSLDIR}/bin/msm
chmod 755 ${FSLDIR}/bin/msm

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# FSL
export FSLDIR=\${FSLDIR}
export \\
    FSLOUTPUTTYPE=NIFTI_GZ \\
    FSLMULTIFILEQUIT=TRUE \\
    FSLTCLSH=\${FSLDIR}/bin/fsltclsh \\
    FSLWISH=\${FSLDIR}/bin/fslwish \\
    FSLGECUDAQ=cuda.q \\
    FSLLOCKDIR= \\
    FSLMACHINELIST= \\
    FSLREMOTECALL=
export PATH=\${FSLDIR}/bin:\${PATH}
"
