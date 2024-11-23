#!/bin/bash
set -e

# see this repo for detailed steps and required packages
# https://github.com/rstudio/r-builds

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
R_ROOT_PREFIX=${R_ROOT_PREFIX:-$(eval "echo ${SETUP_PREFIX}/r")}
R_BUILD_DIR=${R_BUILD_DIR:-$(eval "echo ${SETUP_PREFIX}/r_build")}
R_VERSION=${R_VERSION:-4.4.2}
N_CPUS=${N_CPUS:-8}
OS_IDENTIFIER=${OS_IDENTIFIER:-"rhel-8.8"}

# Check if texlive is installed, print a warning if not
if ! command -v tex &> /dev/null; then
    echo "ERROR: 'tex' command not found. Please ensure that TexLive is installed correctly and the PATH is set."
    echo "After installing TexLive, please re-run this script."
    exit 1
fi

# Cleanup old compilation directory
if [ -d ${R_BUILD_DIR} ]; then echo "Cleanup old R compilation directory..." && rm -rf ${R_BUILD_DIR}; fi

# R compilation configuration
CONFIGURE_OPTIONS="\
    --build=x86_64-redhat-linux-gnu \
    --host=x86_64-redhat-linux-gnu \
    --libdir=${R_ROOT_PREFIX}/lib \
    --enable-R-shlib \
    --enable-memory-profiling \
    --with-blas \
    --with-lapack \
    --with-x \
    --with-tcltk \
    --with-tcl-config=${SYSTOOLS_DIR}/lib/tclConfig.sh \
    --with-tk-config=${SYSTOOLS_DIR}/lib/tkConfig.sh \
    --with-cairo \
    --enable-java"
# R compilation environment variable
export \
    R_BATCHSAVE="--no-save --no-restore" \
    CC="clang" \
    OBJC="clang" \
    CXX="clang++" \
    FC="gfortran"

# Download R source code
mkdir -p ${R_BUILD_DIR}
wget -q https://cloud.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz -P ${R_BUILD_DIR}
tar -xzf ${R_BUILD_DIR}/R-${R_VERSION}.tar.gz -C ${R_BUILD_DIR}
cd ${R_BUILD_DIR}/R-*/

# Build R from source
echo ${CONFIGURE_OPTIONS} | xargs ./configure --prefix=${R_ROOT_PREFIX}
make -j${N_CPUS}

# Install R
# remove old installation if existed
if [ -d ${R_ROOT_PREFIX} ]; then echo "Cleanup old R installation..." && rm -rf ${R_ROOT_PREFIX}; fi
# install to prefix directory
make install

# Add OS identifier to the default HTTP user agent.
# set this in the system Rprofile so it works when R is run with --vanilla.
# this allows R to use Posit hosted binary packages
# see details at https://github.com/rstudio/r-builds/blob/main/builder/build.sh
cat <<EOF >> ${R_ROOT_PREFIX}/lib/R/library/base/R/Rprofile
## Set the default HTTP user agent
local({
  os_identifier <- if (file.exists("/etc/os-release")) {
    os <- readLines("/etc/os-release")
    id <- gsub('^ID=|"', "", grep("^ID=", os, value = TRUE))
    version <- gsub('^VERSION_ID=|"', "", grep("^VERSION_ID=", os, value = TRUE))
    sprintf("%s-%s", id, version)
  } else {
    "${OS_IDENTIFIER}"
  }
  options(HTTPUserAgent = sprintf(
    "R/%s (%s) R (%s)", getRversion(), os_identifier,
    paste(getRversion(), R.version\$platform, R.version\$arch, R.version\$os)
  ))
})
EOF

# Cleanup
rm -r ${R_BUILD_DIR}

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# R
export R_ROOT_PREFIX=\"${SETUP_PREFIX}/r\"
export PATH=\"\${R_ROOT_PREFIX}/bin:\${PATH}\"
"
