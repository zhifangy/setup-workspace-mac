#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
N_CPUS=${N_CPUS:-6}
AFNI_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/afni")"
AFNI_BUILD_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/afni_build")"
PKG_VERSION=macos_13_ARM_clang
# r related
R_LIBS="${R_LIBS:-$(eval "echo ${SETUP_PREFIX}/renv")}"

# Cleanup old installation
if [ -d ${AFNI_DIR} ]; then echo "Cleanup old AFNI installation..." && rm -rf ${AFNI_DIR}; fi
if [ -d ~/.afni/help ]; then echo "Cleanup old AFNI help files ..." && rm -rf ~/.afni/help; fi
if [ -f ~/.afnirc ]; then echo "Cleanup old AFNI rc files ..." && rm ~/.afnirc; fi
if [ -f ~/.sumarc ]; then echo "Cleanup old SUMA rc files ..." && rm ~/.sumarc; fi

# Install system dependencies via homebrew
# see https://github.com/afni/afni/blob/master/src/other_builds/OS_notes.macos_12_ARM_a_admin_pt1.zsh
formula_packages=(
    "python" "netpbm" "cmake" "gfortran" "libpng" "jpeg" "expat" "freetype" "fontconfig" \
    "openmotif" "libomp" "gsl" "glib" "pkg-config" "gcc" "libiconv" "autoconf" "libxt" \
    "mesa" "mesa-glu" "libxpm"
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
# Install R dependencies
Rscript --no-environ --no-init-file -e "
options(Ncpus=${N_CPUS})
# Install packages
pkgs_list <- c(
    'afex', 'phia', 'snow', 'nlme', 'lmerTest', 'gamm4', 'data.table',
    'paran', 'psych', 'corrplot', 'metafor'
)
pak::pkg_install(pkgs_list, lib=\"${R_LIBS}\");
# Cleanup cache
pak::cache_clean()
"

# Install AFNI
echo "Installing AFNI from source code (building for apple aarch64)..."
# download @update.afni.binaries and do basic setup
mkdir -p ${AFNI_DIR}
wget -q https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries -P ${AFNI_DIR}
tcsh ${AFNI_DIR}/@update.afni.binaries -no_recur -package anyos_text_atlas -bindir ${AFNI_DIR}
# prepare for building
build_afni.py -build_root ${AFNI_BUILD_DIR} -package ${PKG_VERSION} -prep_only
# do actual compiling
mkdir -p ${AFNI_BUILD_DIR}/prev
build_afni.py -build_root ${AFNI_BUILD_DIR} -package ${PKG_VERSION} -clean_root no -do_backup no
# post installation setup
cp ${AFNI_DIR}/AFNI.afnirc ${HOME}/.afnirc
suma -update_env
apsearch -update_all_afni_help

# Cleanup
if [ -f .R.Rout ]; then rm .R.Rout; fi
rm -rf ${AFNI_BUILD_DIR}

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# AFNI
export PATH=${AFNI_DIR}:\${PATH}
# auto-inserted by @update.afni.binaries :
#    set up tab completion for AFNI programs
if [ -f \$HOME/.afni/help/all_progs.COMP.zsh ]
then
    autoload -U +X bashcompinit && bashcompinit
    autoload -U +X compinit && compinit -i \\
    && source \$HOME/.afni/help/all_progs.COMP.zsh
fi
# look for shared libraries under flat_namespace
export DYLD_LIBRARY_PATH=\${DYLD_LIBRARY_PATH}:/opt/X11/lib/flat_namespace
# do not log commands
export AFNI_DONT_LOGFILE=YES
"
