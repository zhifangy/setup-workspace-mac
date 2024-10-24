#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/envs
export SETUP_ROOT
export HOMEBREW_ROOT
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )

case "$1" in
    "basic"|"Basic")
        bash ${SCRIPT_DIR}/script/install_basic_packages.sh
        ;;
    "omz"|"oh_my_zsh")
        bash ${SCRIPT_DIR}/script/install_oh_my_zsh.sh
        ;;
    "pyenv")
        bash ${SCRIPT_DIR}/script/install_python_environment.sh
        ;;
    "r")
        bash ${SCRIPT_DIR}/script/install_r_source.sh
        ;;
    "renv")
        bash ${SCRIPT_DIR}/script/install_r_environment.sh
        ;;
    "quarto")
        bash ${SCRIPT_DIR}/script/install_quarto.sh
        ;;
    "texlive")
        bash ${SCRIPT_DIR}/script/install_texlive.sh
        ;;
    "freesurfer"|"FreeSurfer")
        bash ${SCRIPT_DIR}/script/install_freesurfer.sh
        ;;
    "afni"|"AFNI")
        bash ${SCRIPT_DIR}/script/install_afni.sh
        ;;
    "fsl"|"FSL")
        bash ${SCRIPT_DIR}/script/install_fsl.sh
        ;;
    "other"|"Other")
        bash ${SCRIPT_DIR}/script/install_ants.sh
        bash ${SCRIPT_DIR}/script/install_fsleyes.sh
        bash ${SCRIPT_DIR}/script/install_dcm2niix.sh
        bash ${SCRIPT_DIR}/script/install_mricrogl.sh
        bash ${SCRIPT_DIR}/script/install_surfice.sh
        bash ${SCRIPT_DIR}/script/install_itksnap.sh
        bash ${SCRIPT_DIR}/script/install_workbench.sh
        bash ${SCRIPT_DIR}/script/install_convert3d.sh
        ;;
    "ants"|"ANTs")
        bash ${SCRIPT_DIR}/script/install_ants.sh
        ;;
    "fsleyes"|"FSLeyes")
        bash ${SCRIPT_DIR}/script/install_fsleyes.sh
        ;;
    "dcm2niix"|"Dcm2niix")
        bash ${SCRIPT_DIR}/script/install_dcm2niix.sh
        ;;
    "mricrogl"|"MRIcroGL")
        bash ${SCRIPT_DIR}/script/install_mricrogl.sh
        ;;
    "surfice"|"Surfice")
        bash ${SCRIPT_DIR}/script/install_surfice.sh
        ;;
    "itksnap"|"ITKSNAP")
        bash ${SCRIPT_DIR}/script/install_itksnap.sh
        ;;
    "workbench"|"Workbench")
        bash ${SCRIPT_DIR}/script/install_workbench.sh
        ;;
    "convert3d"|"Convert3D")
        bash ${SCRIPT_DIR}/script/install_convert3d.sh
        ;;
    *)
        echo "Invalid installation option."
        exit 1
        ;;
esac
