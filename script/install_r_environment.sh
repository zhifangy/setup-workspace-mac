#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
N_CPUS=${N_CPUS:-8}
export R_LIBS=${SETUP_ROOT}/renv
CRAN=${CRAN:-https://packagemanager.posit.co/cran/latest}

# Install packages used by R packages
brew install tbb harfbuzz fribidi mariadb-connector-c glpk libxml2 gmp
# set tbb related environment variable (for brms dependency RcppParallel)
export TBB_INC=$(ls -d ${HOMEBREW_ROOT}/Cellar/tbb/*)/include
export TBB_LIB=$(ls -d ${HOMEBREW_ROOT}/Cellar/tbb/*)/lib

# Cleanup old installation
if [ -d ${R_LIBS} ]; then echo "Cleanup old r environment..." && rm -rf ${R_LIBS}; fi

# Instal R packages
echo "R enviromenmet location: ${R_LIBS}"
mkdir -p ${R_LIBS}
# prerequisite package
Rscript -e "install.packages(c('littler', 'docopt'), lib='${R_LIBS}', repos='${CRAN}', clean=TRUE, quiet=TRUE)"
bash ${SCRIPT_DIR}/fix_littler_macos.sh
PATH=${R_LIBS}/littler/examples:${R_LIBS}/littler/bin:${PATH}

# Read R packages list (CRAN)
R_PKG_FILE="${SCRIPT_DIR}/../environment_spec/r_environment.txt"
# read the file line by line and filter out lines starting with # or whitespace
R_PKG_LIST=""
echo -e "\n\nInstalling R packages:\n"
while IFS= read -r line; do
    if [[ "${line}" =~ ^[^[:space:]#] && ! -z "${line}" ]]; then
        R_PKG_LIST="${R_PKG_LIST}${line} "
        echo ${line}
    fi
done < "${R_PKG_FILE}"
# deal with bad last line (without a newline in the end)
if [[ "${line}" =~ ^[^[:space:]#] && ! -z "${line}" ]]; then
    R_PKG_LIST="${R_PKG_LIST}${line} "
    echo ${line}
fi
# Install R packages
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s ${R_PKG_LIST}

# Read R packages list (Github)
R_PKG_FILE="${SCRIPT_DIR}/../environment_spec/r_environment_github.txt"
# read the file line by line and filter out lines starting with # or whitespace
R_PKG_LIST=""
while IFS= read -r line; do
    if [[ "${line}" =~ ^[^[:space:]#] && ! -z "${line}" ]]; then
        R_PKG_LIST="${R_PKG_LIST}${line} "
    fi
done < "${R_PKG_FILE}"
# deal with bad last line (without a newline in the end)
if [[ "${line}" =~ ^[^[:space:]#] && ! -z "${line}" ]]; then
    R_PKG_LIST="${R_PKG_LIST}${line} "
fi
# Install R packages (from Github)
if [ ! -z "${R_PKG_LIST}" ]; then
    echo -e "\n\nInstalling R packages (from Github):\n"
    echo ${R_PKG_LIST}
    installGithub.r -d TRUE -r ${CRAN} ${R_PKG_LIST}
fi

# Setup IRkernel for jupyter
Rscript -e "IRkernel::installspec()"

# Write ~/.Renviron
cat >~/.Renviron <<EOL
R_LIBS=${R_LIBS}
EOL

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# R environment
export R_LIBS=${R_LIBS}
# littler
export PATH=\${R_LIBS}/littler/examples:\${R_LIBS}/littler/bin:\${PATH}
# cran
export CRAN=${CRAN}
# for RcppParallel (dependency of brms)
export TBB_INC=\$(ls -d \${HOMEBREW_ROOT}/Cellar/tbb/*)/include
export TBB_LIB=\$(ls -d \${HOMEBREW_ROOT}/Cellar/tbb/*)/lib
"
