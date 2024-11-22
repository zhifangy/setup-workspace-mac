#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/afni")"
BUILD_DIR="$(eval "echo ${SETUP_PREFIX}/afni_build")"
PKG_VERSION=macos_13_ARM
R_LIBS="${R_LIBS:-$(eval "echo ${SETUP_PREFIX}/renv")}"
N_CPUS=${N_CPUS:-8}
export PATH="${INSTALL_PREFIX}:${PATH}"

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then echo "Cleanup old AFNI installation..." && rm -rf ${INSTALL_PREFIX}; fi
if [ -d ${BUILD_DIR} ]; then echo "Cleanup old AFNI build directory..." && rm -rf ${BUILD_DIR}; fi
if [ -d ~/.afni/help ]; then echo "Cleanup old AFNI help files ..." && rm -rf ~/.afni/help; fi
if [ -f ~/.afnirc ]; then echo "Cleanup old AFNI rc files ..." && rm ~/.afnirc; fi
if [ -f ~/.sumarc ]; then echo "Cleanup old SUMA rc files ..." && rm ~/.sumarc; fi

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

# Install AFNI
echo "Installing AFNI from source code (building for apple aarch64)..."
curl -s https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries | tcsh -s - -no_recur -package anyos_text_atlas -bindir ${INSTALL_PREFIX}
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
export AFNI_DIR=\"${SETUP_PREFIX}/afni\"
export PATH=\"\${AFNI_DIR}:\${PATH}\"
# command completion
if [ -f \${HOME}/.afni/help/all_progs.COMP.zsh ]; then source \${HOME}/.afni/help/all_progs.COMP.zsh; fi
# look for shared libraries under flat_namespace
export DYLD_LIBRARY_PATH=\"\${DYLD_LIBRARY_PATH}:/opt/X11/lib/flat_namespace\"
# do not log commands
export AFNI_DONT_LOGFILE=YES
"
