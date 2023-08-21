#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/envs; fi
export SETUP_ROOT
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )

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
        cd ${SCRIPT_DIR}/script
        poetry update
        ;;
    "pyenv_dryrun")
        cd ${SCRIPT_DIR}/script
        poetry update --dry-run
        ;;
    "renv")
        export R_LIBS=${R_LIBS:-${SETUP_ROOT}/renv}
        export CRAN=${CRAN:-https://packagemanager.posit.co/cran/latest}
        Rscript -e "R_LIBS<-Sys.getenv('R_LIBS')" \
            -e "CRAN<-Sys.getenv('CRAN')" \
            -e "pacman::p_update(lib.loc=R_LIBS, repos=CRAN)"
        ;;
    *)
        echo "Invalid installation option."
        exit 1
        ;;
esac
