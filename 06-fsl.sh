#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
export FSLDIR=${SETUP_ROOT}/fsl
FSL_VERSION=6.0.6.1

# FSL
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py
chmod +x fslinstaller.py
./fslinstaller.py -V ${FSL_VERSION} -d ${FSLDIR} --no_env
mv fslinstaller.py ${FSLDIR}/fslinstaller.py
# Update FSLeyes
$FSLDIR/condabin/conda update -yq -p ${FSLDIR} -c conda-forge fsleyes
$FSLDIR/condabin/conda clean -apy
# Use newer version of MSM
wget https://github.com/ecr05/MSM_HOCR/releases/download/v3.0FSL/msm_mac_v3 && \
mv -fv msm_mac_v3 ${FSLDIR}/bin/msm
chmod 755 ${FSLDIR}/bin/msm

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
    FSLREMOTECALL=
export PATH=\${FSLDIR}/bin:\${PATH}

Put this part before conda related configuration in order to use fsleyes installed by conda!
"
