#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
N_CPUS=${N_CPUS:-8}
export R_LIBS=${SETUP_ROOT}/renv
CRAN=${CRAN:-https://packagemanager.posit.co/cran/latest}

# Cleanup old installation
if [ -d ${R_LIBS} ]; then echo "Cleanup old r environment..." && rm -rf ${R_LIBS}; fi

# Instal R packages
echo "R enviromenmet location: ${R_LIBS}"
mkdir -p ${R_LIBS}
# prerequisite package
Rscript -e "install.packages('docopt', lib='${R_LIBS}', repos='${CRAN}', clean=TRUE)"
Rscript -e "install.packages('littler', lib='${R_LIBS}', repos='${CRAN}', type='source', clean=TRUE)"
bash ${SCRIPT_DIR}/fix_littler_macos.sh
PATH=${PATH}:${R_LIBS}/littler/examples:${R_LIBS}/littler/bin

# Install R packages (from Github)
PKG_FILE="${SCRIPT_DIR}/../environment_spec/r_environment.txt"
PKG_LIST=""
PKG_NO_BIN_LIST=""=""
# read file line by line, filtering out lines that start with # or whitespace
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "${line}" =~ ^[^[:space:]#] ]]; then
        PKG_LIST+="${line} "
        echo ${line}
    fi
done < "${PKG_FILE}"
# install R packages using littler install2.r script
# if the preferred package type is binary, the packages without precompiled binaries
# will be captured and installed from source
echo -e "\n\nInstalling R packages:\n"
while IFS= read -r line; do
    echo "$line"
    # Check if line contains the "no binary available" message
    if [[ "${line}" == *"not available as a binary package for this version of R"* ]]; then
        PKG_NO_BIN_LIST=$(echo "$line" | grep -o "‘[^’]*’" | sed "s/[‘’]//g")
        # # Extract package name from the line
        # PKG=$(echo "${line}" | awk -F"‘|’" '{print $2}')
        # PKG_NO_BIN_LIST+="${PKG} "
    fi
done < <(install2.r -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s ${PKG_LIST} "$@" 2>&1)
# install packages from source
if [[ ! -z "${PKG_NO_BIN_LIST}" ]]; then
    install2.r -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -t "source" -s ${PKG_NO_BIN_LIST}
    echo -e "\nPackages installed from source:\n${PKG_NO_BIN_LIST}"
fi

# Install R packages (from Github)
PKG_GH_FILE="${SCRIPT_DIR}/../environment_spec/r_environment_github.txt"
PKG_GH_LIST=""
# read file line by line, filtering out lines that start with # or whitespace
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "${line}" =~ ^[^[:space:]#] ]]; then
        PKG_GH_LIST+="${line} "
    fi
done < "${PKG_GH_FILE}"
# install R packages using littler installGithub.r script
if [ ! -z "${PKG_GH_LIST}" ]; then
    echo -e "\n\nInstalling R packages (from Github):\n${PKG_GH_LIST}"
    installGithub.r -d TRUE -r ${CRAN} ${PKG_GH_LIST}
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
# cran
export CRAN=${CRAN}
# littler
export PATH=\${PATH}:\${R_LIBS}/littler/examples:\${R_LIBS}/littler/bin
"
