#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${INSTALL_ROOT_PREFIX}/afni")"
R_LIBS="${R_LIBS:-$(eval "echo ${INSTALL_ROOT_PREFIX}/renv")}"
N_CPUS=${N_CPUS:-8}
if [ "$OS_TYPE" == "macos" ]; then
    PKG_VERSION=macos_13_ARM
    BUILD_DIR="$(eval "echo ${INSTALL_ROOT_PREFIX}/afni_build")"
elif [ "$OS_TYPE" == "rhel8" ]; then
    PKG_VERSION=linux_rocky_8
    SYSTOOLS_DIR="$(eval "echo ${INSTALL_ROOT_PREFIX}/systools")"
fi
export PATH="${INSTALL_PREFIX}:${PATH}"

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then echo "Cleanup old AFNI installation..." && rm -rf ${INSTALL_PREFIX}; fi
if [ -d ${BUILD_DIR} ]; then echo "Cleanup old AFNI build directory..." && rm -rf ${BUILD_DIR}; fi
if [ -d ~/.afni/help ]; then echo "Cleanup old AFNI help files ..." && rm -rf ~/.afni/help; fi
if [ -f ~/.afnirc ]; then echo "Cleanup old AFNI rc files ..." && rm ~/.afnirc; fi
if [ -f ~/.sumarc ]; then echo "Cleanup old SUMA rc files ..." && rm ~/.sumarc; fi

# Install R dependencies
Rscript -e "
options(Ncpus=${N_CPUS})
# Install packages
deps <- c('afex', 'phia', 'snow', 'nlme', 'lmerTest', 'gamm4', 'data.table', 'paran', 'psych', 'corrplot', 'metafor')
missing_pkgs <- setdiff(deps, rownames(installed.packages()))
if (length(missing_pkgs) > 0) {
  pak::pkg_install(missing_pkgs, lib=\"${R_LIBS}\");
}
# Cleanup cache
pak::cache_clean()
"


if [ "$OS_TYPE" == "macos" ]; then
# Install system dependencies via homebrew
# see https://github.com/afni/afni/blob/master/src/other_builds/OS_notes.macos_12_ARM_a_admin_pt1.zsh
formula_packages=(
    "libpng" "jpeg" "expat" "freetype" "fontconfig" "openmotif" "libomp" "gsl" "glib" "pkg-config" \
    "gcc" "libiconv" "autoconf" "libxt" "mesa" "mesa-glu" "libxpm"
)
# List of cask packages
cask_packages=(
    "xquartz"
)
for package in "${formula_packages[@]}"; do
    brew list --formula "${package}" &> /dev/null || brew install "${package}"
done
for cask in "${cask_packages[@]}"; do
    brew list --cask "${cask}" &> /dev/null || brew install --cask "${cask}"
done

# Install AFNI
echo "Installing AFNI from source code (building for apple aarch64)..."
curl -s https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries | \
    tcsh -s - -no_recur -package anyos_text_atlas -bindir ${INSTALL_PREFIX}
build_afni.py -abin ${INSTALL_PREFIX} -build_root ${BUILD_DIR} -package ${PKG_VERSION} -do_backup no
# post installation setup
cp ${INSTALL_PREFIX}/AFNI.afnirc ${HOME}/.afnirc
suma -update_env
apsearch -update_all_afni_help
afni_system_check.py -check_all

# Cleanup
if [ -f .R.Rout ]; then rm .R.Rout; fi
rm -rf ${AFNI_BUILD_DIR}

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# AFNI
export AFNI_DIR=\"${INSTALL_ROOT_PREFIX}/afni\"
export PATH=\"\${AFNI_DIR}:\${PATH}\"
# command completion
if [ -f \${HOME}/.afni/help/all_progs.COMP.zsh ]; then source \${HOME}/.afni/help/all_progs.COMP.zsh; fi
# look for shared libraries under flat_namespace
export DYLD_LIBRARY_PATH=\"\${DYLD_LIBRARY_PATH}:/opt/X11/lib/flat_namespace\"
# do not log commands
export AFNI_DONT_LOGFILE=YES
"


elif [ "$OS_TYPE" == "rhel8" ]; then
# Install dependency package into systools environment
deps=("openmotif" "gsl" "netpbm" "libjpeg-turbo" "libpng" "libglu" "xorg-libxpm" "xorg-libxi" "glib2-cos7-x86_64" "mesa-libglw-devel-cos7-x86_64")
installed_pkgs=$(micromamba list -p ${SYSTOOLS_DIR} --json | jq -r '.[].name')
missing_pkgs=()
for p in "${deps[@]}"; do
    if ! echo "$installed_pkgs" | grep -q "^$p$"; then
        missing_pkgs+=("$p")
    fi
done
if [ ${#missing_pkgs[@]} -ne 0 ]; then
    echo "Installing missing dependencies: ${missing_pkgs[*]} ..."
    micromamba install -yq -p "${SYSTOOLS_DIR}" "${missing_pkgs[@]}"
    micromamba clean -yaq
fi
# build jpeg-9e from source
# it is a dependency of openmotif package. but the conda-forge version of
# jpeg9e conflicts with many other packages. here we build jpeg-9e from
# source and add it to the LD_LIBRARY_PATH
mkdir -p ${INSTALL_PREFIX}
curl -L http://www.ijg.org/files/jpegsrc.v9e.tar.gz | tar -xz -C "${INSTALL_PREFIX}"
cd ${INSTALL_PREFIX}/jpeg-9e
./configure --prefix=${INSTALL_PREFIX}/jpeg-9e --build=x86_64-redhat-linux-gnu --host=x86_64-redhat-linux-gnu
make -j${N_CPUS}
make install
export LD_LIBRARY_PATH="${INSTALL_PREFIX}/jpeg-9e/lib:${LD_LIBRARY_PATH}"
# symlink shared libraries
ln -sf ${SYSTOOLS_DIR}/lib/libicui18n.so ${SYSTOOLS_DIR}/lib/libicui18n.so.58
ln -sf ${SYSTOOLS_DIR}/lib/libicuuc.so ${SYSTOOLS_DIR}/lib/libicuuc.so.58
ln -sf ${SYSTOOLS_DIR}/lib/libicudata.so ${SYSTOOLS_DIR}/lib/libicudata.so.58

# Install AFNI
echo "Installing AFNI from offical binary package..."
curl -s https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries | \
    tcsh -s - -no_recur -package ${PKG_VERSION} -bindir ${INSTALL_PREFIX}
# post installation setup
cp ${INSTALL_PREFIX}/AFNI.afnirc ${HOME}/.afnirc
suma -update_env
apsearch -update_all_afni_help
afni_system_check.py -check_all

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# AFNI
export AFNI_DIR=\"${INSTALL_ROOT_PREFIX}/afni\"
export PATH=\"\${AFNI_DIR}:\${PATH}\"
# command completion
if [ -f \${HOME}/.afni/help/all_progs.COMP.zsh ]; then source \${HOME}/.afni/help/all_progs.COMP.zsh; fi
# add jpeg-9e in LD_LIBRARY_PATH
export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:${INSTALL_ROOT_PREFIX}/afni/jpeg-9e/lib\"
# do not log commands
export AFNI_DONT_LOGFILE=YES
"
fi
