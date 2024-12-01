#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
R_ROOT_PREFIX=${R_ROOT_PREFIX:-$(eval "echo ${INSTALL_ROOT_PREFIX}/r")}
R_BUILD_DIR=${R_BUILD_DIR:-$(eval "echo ${INSTALL_ROOT_PREFIX}/r_build")}
R_VERSION=${R_VERSION:-4.4.2}
N_CPUS=${N_CPUS:-8}
if [ "$OS_TYPE" == "rhel8" ]; then OS_IDENTIFIER=${OS_IDENTIFIER:-"rhel-8.8"}; fi

# Check if texlive is installed, print error message if not
if ! command -v tex &> /dev/null; then
    echo "ERROR: 'tex' command not found. Please ensure that TexLive is installed correctly and the PATH is set."
    echo "After installing TexLive, please re-run this script."
    exit 1
fi

# Cleanup old compilation directory
if [ -d ${R_BUILD_DIR} ]; then echo "Cleanup old R compilation directory..." && rm -rf ${R_BUILD_DIR}; fi


if [ "$OS_TYPE" == "macos" ]; then
packages=(
    "gcc" "pkg-config" "pcre2" "tcl-tk" "xz" "readline" "gettext" "bzip2" "zlib" "libdeflate" "openblas" "icu4c" "curl" \
    "libffi" "freetype" "fontconfig" "libxext" "libx11" "libxau" "libxcb" "libxdmcp" "libxrender" \
    "cairo" "jpeg-turbo" "libpng" "pixman" "openjdk" "texinfo"
)
packages_cask=("xquartz")
# Loop through the packages and install if not already installed
for package in "${packages[@]}"; do
    brew list --formula "${package}" &> /dev/null || brew install "${package}"
done
for cask in "${packages_cask[@]}"; do
    brew list --cask "${cask}" &> /dev/null || brew install --cask "${cask}"
done

# R compilation configuration
CONFIGURE_OPTIONS="\
    --enable-R-shlib \
    --enable-memory-profiling \
    --with-blas=\"-L$(brew --prefix openblas)/lib -lopenblas\" \
    --with-lapack \
    --with-aqua \
    --with-x \
    --with-tcltk=$(brew --prefix)/lib \
    --with-tcl-config=$(brew --prefix)/lib/tclConfig.sh \
    --with-tk-config=$(brew --prefix)/lib/tkConfig.sh \
    --with-cairo \
    --enable-java"
# R compilation environment variable
export \
    R_BATCHSAVE="--no-save --no-restore" \
    JAVA_HOME=$(brew --prefix)/opt/openjdk \
    CC=clang \
    OBJC=clang \
    CXX=clang++ \
    FC="$(brew --prefix gcc)/bin/gfortran" \
    CFLAGS="-g -O2 -march=native -mtune=native -falign-functions=8 -I$(brew --prefix)/include" \
    CPPFLAGS="-I$(brew --prefix)/include ${CPPFLAGS}" \
    LDFLAGS="-L$(brew --prefix)/lib ${LDFLAGS}" \
    FFLAGS="-g -O2 -mmacosx-version-min=11.0" \
    FCFLAGS="-g -O2 -mmacosx-version-min=11.0" \
    PKG_CONFIG_PATH=${R_ROOT_PREFIX}/lib/pkgconfig:/usr/lib/pkgconfig


elif [ "$OS_TYPE" == "rhel8" ]; then
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
fi

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


# Post installation configuration
if [ "$OS_TYPE" == "macos" ]; then
# replace gcc to version independent path in Makeconf file
sed -i '' "s|$(brew --cellar gcc)/$(ls -1 $(brew --cellar gcc))|$(brew --prefix gcc)|g" ${R_ROOT_PREFIX}/lib/R/etc/Makeconf
# add additional LD_LIBRARY_PATH (for precompiled packages)
sed -i '' "/## This is DYLD_FALLBACK_LIBRARY_PATH on Darwin (macOS) and/i\\
## Additional library from homebrew\\
export R_LD_LIBRARY_PATH=\"\${R_LD_LIBRARY_PATH}:$(brew --prefix)/lib:$(brew --prefix gcc)/lib/gcc/current\"
" ${R_ROOT_PREFIX}/lib/R/etc/ldpaths
# symlink homebrew installed openblas dylib to R/lib (for precompiled packages)
ln -s $(brew --prefix openblas)/lib/libopenblas.dylib ${R_ROOT_PREFIX}/lib/R/lib/libRblas.dylib
ln -s $(brew --prefix openblas)/lib/liblapack.dylib ${R_ROOT_PREFIX}/lib/R/lib/libRlapack.dylib
# set default package installation preference
# echo 'options(pkgType = "mac.binary.big-sur-arm64")' > ${R_ROOT_PREFIX}/lib/R/etc/Rprofile.site


elif [ "$OS_TYPE" == "rhel8" ]; then
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
fi

# Cleanup
rm -r ${R_BUILD_DIR}

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# R
export R_ROOT_PREFIX=\"${INSTALL_ROOT_PREFIX}/r\"
export PATH=\"\${R_ROOT_PREFIX}/bin:\${PATH}\"
"
