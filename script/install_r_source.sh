#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
N_CPUS=${N_CPUS:-6}
# R
R_VERSION=${R_VERSION:-4.4.1}
R_ROOT_PREFIX=${R_ROOT_PREFIX:-$(eval "echo ${SETUP_PREFIX}/r")}
R_BUILD_DIR=${R_BUILD_DIR:-$(eval "echo ${SETUP_PREFIX}/r_build")}

# Cleanup old compilation directory
if [ -d ${R_BUILD_DIR} ]; then echo "Cleanup old R compilation directory..." && rm -rf ${R_BUILD_DIR}; fi

# Install dependency via homebrew
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
# post installation configuration
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
echo 'options(pkgType = "mac.binary.big-sur-arm64")' > ${R_ROOT_PREFIX}/lib/R/etc/Rprofile.site

# Cleanup
rm -r ${R_BUILD_DIR}

# Check if the 'tex' command is available, print a warning if not
if ! command -v tex &> /dev/null; then
    echo "WARNING: 'tex' command not found. Please ensure that TexLive is installed correctly and the path is set."
    echo "After installing TexLive, please re-run this script to re-compile R."
fi

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# R
export R_ROOT_PREFIX=${R_ROOT_PREFIX}
export R_HOME=\${R_ROOT_PREFIX}/lib/R
export PATH=\${R_ROOT_PREFIX}/bin:\${PATH}
"
