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
    "systools")
        eval "$(micromamba shell hook --shell bash)"
        micromamba update -ya -p ${SYSTOOLS_DIR}
        micromamba clean -yaq
        ;;
    "systools_dryrun")
        micromamba update -a -p ${SYSTOOLS_DIR} --dry-run
        ;;
    "omz"|"zsh")
        zsh -ic "upgrade_oh_my_zsh_all"
        ;;
    "micromamba"|"mamba")
        micromamba self-update
        ;;
    "pyenv")
        uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml -U --extra full
        uv cache clean
        ;;
    "pyenv_dryrun")
        uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml -U --dry-run --extra full
        ;;
    "renv")
        Rscript -e "
        options(Ncpus=${N_CPUS})
        old_pkgs <- old.packages(lib.loc=Sys.getenv('R_LIBS'), repos=Sys.getenv('CRAN'))
        if (!is.null(old_pkgs)) {
            pak::meta_update();
            pak::pkg_install(rownames(old_pkgs), lib=\"${R_LIBS}\", upgrade=TRUE);
            pak::cache_clean()
        } else {
            cat('No package needs to be updated.\n');
        }
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
    "fsl")
        update_fsl_release
        ;;
    "fsleyes")
        micromamba update fsleyes -p "$(eval "echo ${SETUP_PREFIX}/fsleyes/env")" -c conda-forge
        ;;
    "ants")
        micromamba update ants -p "$(eval "echo ${SETUP_PREFIX}/ants/env")" -c conda-forge
        ;;
    "dcm2niix")
        micromamba update dcm2niix -p "$(eval "echo ${SETUP_PREFIX}/dcm2niix/env")" -c conda-forge
        ;;
    *)
        echo "Invalid installation option."
        exit 1
        ;;
esac
