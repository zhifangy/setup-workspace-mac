#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
if [ "$OS_TYPE" == "macos" ]; then
    DEFAULT_CRAN="https://packagemanager.posit.co/cran/latest"
elif [ "$OS_TYPE" == "rhel8" ]; then
    DEFAULT_CRAN="https://packagemanager.rstudio.com/all/__linux__/centos8/latest"
fi
export \
    N_CPUS="${N_CPUS:-8}" \
    CRAN=${CRAN:-${DEFAULT_CRAN}} \
    R_LIBS="$(eval "echo ${INSTALL_ROOT_PREFIX}/renv")"
export \
    PKG_CRAN_MIRROR="$CRAN" \
    PKG_LIBRARY="$R_LIBS" \
    R_PKG_CACHE_DIR="${R_LIBS}/_pkgcache"

# Check if python environment is installed and in the PATH
if ! echo "$PATH" | tr ':' '\n' | grep -q "$(eval "echo ${INSTALL_ROOT_PREFIX}/pyenv")"; then
    echo "ERROR: Python environment (pyenv) is not installed or presents in the PATH (required by IRkernel)."
    exit 1
fi

# Cleanup old r environment
if [ -d ${R_LIBS} ]; then echo "Cleanup old r environment..." && rm -rf ${R_LIBS}; fi

# Prepare environment
echo "R enviromenmet location: ${R_LIBS}"
mkdir -p ${R_LIBS}
# prerequisite package
Rscript -e "install.packages(c('pak', 'RcppTOML'), lib='${R_LIBS}', repos='${CRAN}', clean=TRUE)"

# Install R package from TOML file
echo -e "\nUsing CRAN repo: ${CRAN}"
PKG_FILE="${SCRIPT_ROOT_PREFIX}/misc/renv.toml"
Rscript --no-environ --no-init-file -e "
options(Ncpus=${N_CPUS})
# Parse the TOML file and extract packages
spec <- RcppTOML::parseTOML('${PKG_FILE}');
# Install packages
cat('\nPackages to install from CRAN or other repositories:\n');
cat(unlist(spec\$packages), sep = '\\n', '\n');
pak::pkg_install(unlist(spec\$packages), lib=\"${R_LIBS}\");
# Cleanup cache
pak::cache_clean()
"

# Setup IRkernel for jupyter
Rscript -e "IRkernel::installspec()"

# Add default settings to .Renviron
RENVIRON_PATH="${HOME}/.Renviron"
RENVIRON=$(cat <<EOF
R_LIBS=\${R_LIBS:-${R_LIBS}}
CRAN=\${CRAN:-${DEFAULT_CRAN}}
# pak config
PKG_LIBRARY=\${PKG_LIBRARY:-\$R_LIBS}
PKG_CRAN_MIRROR=\${PKG_CRAN_MIRROR:-\$CRAN}
R_PKG_CACHE_DIR=\${R_PKG_CACHE_DIR:-${R_PKG_CACHE_DIR}}
EOF
)
# check if .Rprofile exists
if [ -f "$RENVIRON_PATH" ]; then
    # prompt the user for confirmation to overwrite
    read -p $'\n'"$RENVIRON_PATH exists. Do you want to overwrite it? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "$RENVIRON" > "$RENVIRON_PATH"
            echo "$RENVIRON_PATH has been overwritten with the defaults."
        ;;
        n|N )
            echo "No changes made to $RENVIRON_PATH."
        ;;
        * )
            echo "Invalid input. No changes made."
        ;;
    esac
else
    # if .Renviron doesn't exist, create it with the defaults
    echo -e "\n$RENVIRON_PATH created with the defaults."
    echo "$RENVIRON" > "$RENVIRON_PATH"
fi

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# R environment
export CRAN=\"$CRAN\"
export R_LIBS=\"${INSTALL_ROOT_PREFIX}/renv\"
# pak config
export \\
    PKG_LIBRARY=\"\$R_LIBS\" \\
    PKG_CRAN_MIRROR=\"\$CRAN\" \\
    R_PKG_CACHE_DIR=\"\${R_LIBS}/_pkgcache\"
"
