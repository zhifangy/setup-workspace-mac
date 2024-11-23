#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
SCRIPT_ROOT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
# Set environment variables
N_CPUS=${N_CPUS:-8}

case "$1" in
    "systools"|"systool")
        bash ${SCRIPT_ROOT_DIR}/script/install_system_tools.sh
        ;;
    "omz"|"oh_my_zsh")
        bash ${SCRIPT_ROOT_DIR}/script/install_oh_my_zsh.sh
        ;;
    "texlive"|"TexLive")
        bash ${SCRIPT_ROOT_DIR}/script/install_texlive.sh
        ;;
    "r"|"R")
        bash ${SCRIPT_ROOT_DIR}/script/install_r_source.sh
        ;;
    "pyenv")
        bash ${SCRIPT_ROOT_DIR}/script/install_python_environment.sh
        ;;
    "renv")
        bash ${SCRIPT_ROOT_DIR}/script/install_r_environment.sh
        ;;
    "freesurfer"|"FreeSurfer")
        bash ${SCRIPT_ROOT_DIR}/script/install_freesurfer.sh
        ;;
    "afni"|"AFNI")
        bash ${SCRIPT_ROOT_DIR}/script/install_afni.sh
        ;;
    "fsl"|"FSL")
        bash ${SCRIPT_ROOT_DIR}/script/install_fsl.sh
        ;;
    "other"|"Other")
        bash ${SCRIPT_ROOT_DIR}/script/install_ants.sh
        bash ${SCRIPT_ROOT_DIR}/script/install_fsleyes.sh
        bash ${SCRIPT_ROOT_DIR}/script/install_dcm2niix.sh
        bash ${SCRIPT_ROOT_DIR}/script/install_mricrogl.sh
        bash ${SCRIPT_ROOT_DIR}/script/install_surfice.sh
        bash ${SCRIPT_ROOT_DIR}/script/install_itksnap.sh
        bash ${SCRIPT_ROOT_DIR}/script/install_workbench.sh
        bash ${SCRIPT_ROOT_DIR}/script/install_convert3d.sh
        ;;
    "ants"|"ANTs")
        bash ${SCRIPT_ROOT_DIR}/script/install_ants.sh
        ;;
    "fsleyes"|"FSLeyes")
        bash ${SCRIPT_ROOT_DIR}/script/install_fsleyes.sh
        ;;
    "dcm2niix"|"Dcm2niix")
        bash ${SCRIPT_ROOT_DIR}/script/install_dcm2niix.sh
        ;;
    "mricrogl"|"MRIcroGL")
        bash ${SCRIPT_ROOT_DIR}/script/install_mricrogl.sh
        ;;
    "surfice"|"Surfice")
        bash ${SCRIPT_ROOT_DIR}/script/install_surfice.sh
        ;;
    "itksnap"|"ITKSNAP")
        bash ${SCRIPT_ROOT_DIR}/script/install_itksnap.sh
        ;;
    "workbench"|"Workbench")
        bash ${SCRIPT_ROOT_DIR}/script/install_workbench.sh
        ;;
    "convert3d"|"Convert3D")
        bash ${SCRIPT_ROOT_DIR}/script/install_convert3d.sh
        ;;
    *)
        echo "Invalid installation option."
        exit 1
        ;;
esac
