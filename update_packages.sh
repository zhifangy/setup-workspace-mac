#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/envs
export SETUP_ROOT
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
N_CPUS=${N_CPUS:-6}

case "$1" in
    "basic"|"brew")
        brew upgrade && brew cleanup
        ;;
    "omz"|"zsh")
        zsh -ic "upgrade_oh_my_zsh_all"
        ;;
    "micromamba"|"mamba")
        micromamba self-update -c conda-forge
        ;;
    "poetry")
        poetry self update
        ;;
    "pyenv")
        cd ${SCRIPT_DIR}/environment_spec
        poetry update
        ;;
    "pyenv_dryrun")
        cd ${SCRIPT_DIR}/environment_spec
        poetry update --dry-run
        ;;
    "renv")
        update.r -r ${CRAN} -l ${R_LIBS} -n ${N_CPUS}
        bash ${SCRIPT_DIR}/script/fix_littler_macos.sh
        ;;
    "renv_dryrun")
        Rscript -e "R_LIBS<-Sys.getenv('R_LIBS')" \
            -e "CRAN<-Sys.getenv('CRAN')" \
            -e "old.packages(repos=CRAN)"
        ;;
    "pyenv_cache_cleanup")
        micromamba clean -apyq
        poetry cache clear PyPI --all -n
        poetry cache clear _default_cache --all -n
        ;;
    "fsleyes")
        FSLEYES_DIR=${FSLEYES_DIR:-${SETUP_ROOT}/neurotools/fsleyes}
        ENV_PREFIX=${FSLEYES_DIR}/env
        micromamba update fsleyes -p ${ENV_PREFIX} -c conda-forge
        ;;
    "ants")
        ANTS_DIR=${ANTS_DIR:-${SETUP_ROOT}/neurotools/ants}
        ENV_PREFIX=${ANTS_DIR}/env
        micromamba update ants -p ${ENV_PREFIX} -c conda-forge
        ;;
    "dcm2niix")
        DCM2NIIX_DIR=${DCM2NIIX_DIR:-${SETUP_ROOT}/neurotools/dcm2niix}
        ENV_PREFIX=${DCM2NIIX_DIR}/env
        micromamba update dcm2niix -p ${ENV_PREFIX} -c conda-forge
        ;;
    *)
        echo "Invalid installation option."
        exit 1
        ;;
esac
