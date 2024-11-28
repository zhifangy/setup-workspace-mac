#!/bin/bash
set -e

# Init environment
source script/utils.sh && init_setup
# Set environment variables
N_CPUS=${N_CPUS:-8}

case "$1" in
    "systools")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_system_packages.sh
        ;;
    "omz"|"oh-my-zsh")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_oh_my_zsh.sh
        ;;
    "texlive")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_texlive.sh
        ;;
    "r")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_r_cran.sh
        ;;
    "pyenv")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_python_environment.sh
        ;;
    "renv")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_r_environment.sh
        ;;
    "freesurfer")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_freesurfer.sh
        ;;
    "afni")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_afni.sh
        ;;
    "fsl")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_fsl.sh
        ;;
    "other")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_ants.sh
        bash ${SCRIPT_ROOT_PREFIX}/script/install_fsleyes.sh
        bash ${SCRIPT_ROOT_PREFIX}/script/install_dcm2niix.sh
        bash ${SCRIPT_ROOT_PREFIX}/script/install_mricrogl.sh
        bash ${SCRIPT_ROOT_PREFIX}/script/install_surfice.sh
        bash ${SCRIPT_ROOT_PREFIX}/script/install_itksnap.sh
        bash ${SCRIPT_ROOT_PREFIX}/script/install_workbench.sh
        bash ${SCRIPT_ROOT_PREFIX}/script/install_convert3d.sh
        ;;
    "ants")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_ants.sh
        ;;
    "fsleyes")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_fsleyes.sh
        ;;
    "dcm2niix")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_dcm2niix.sh
        ;;
    "mricrogl")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_mricrogl.sh
        ;;
    "surfice")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_surfice.sh
        ;;
    "itksnap")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_itksnap.sh
        ;;
    "workbench")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_workbench.sh
        ;;
    "convert3d")
        bash ${SCRIPT_ROOT_PREFIX}/script/install_convert3d.sh
        ;;
    *)
        echo "Unsupported installation option."
        exit 1
        ;;
esac
