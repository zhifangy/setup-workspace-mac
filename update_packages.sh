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
    "pyenv")
        uv pip install -r ${SCRIPT_DIR}/environment_spec/pyproject.toml -U --extra full
        ;;
    "pyenv_dryrun")
        uv pip install -r ${SCRIPT_DIR}/environment_spec/pyproject.toml -U --dry-run --extra full
        ;;
    "renv")
        Rscript -e "
        options(Ncpus=${N_CPUS})
        # Parse the TOML file and extract packages
        spec <- RcppTOML::parseTOML('${SCRIPT_DIR}/environment_spec/renv.toml');
        # Install packages
        pak::meta_update();
        pak::pkg_install(unlist(spec\$packages), lib=\"${R_LIBS}\", upgrade=TRUE);
        # Cleanup cache
        pak::cache_clean()
        "
        ;;
    "renv_dryrun")
        Rscript -e "
        old_pkgs <- old.packages(lib.loc=Sys.getenv('R_LIBS'), repos=Sys.getenv('CRAN'))
        if (!is.null(old_pkgs)) {
            print(old_pkgs)
        } else {
            cat('No package needs to be updated.\n');
        }
        "
        ;;
    "texlive")
        tlmgr update --self --all
        ;;
    "fsl")
        update_fsl_release
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
