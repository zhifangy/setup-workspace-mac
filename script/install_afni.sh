#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
N_CPUS=${N_CPUS:-6}
AFNI_DIR=${SETUP_ROOT}/neurotools/afni
AFNI_BUILD_DIR=${SETUP_ROOT}/neurotools/afni_build
PKG_VERSION=macos_13_ARM_clang
PATH=${AFNI_DIR}:${PATH}
# r related
R_LIBS=${R_LIBS:-${SETUP_ROOT}/renv}
CRAN=${CRAN:-https://packagemanager.posit.co/cran/latest}
PATH=${PATH}:${R_LIBS}/littler/examples:${R_LIBS}/littler/bin

# Cleanup old installation
if [ -d ${AFNI_DIR} ]; then echo "Cleanup old AFNI installation..." && rm -rf ${AFNI_DIR}; fi
if [ -d ~/.afni/help ]; then echo "Cleanup old AFNI help files ..." && rm -rf ~/.afni/help; fi
if [ -f ~/.afnirc ]; then echo "Cleanup old AFNI rc files ..." && rm ~/.afnirc; fi
if [ -f ~/.sumarc ]; then echo "Cleanup old SUMA rc files ..." && rm ~/.sumarc; fi

# Install dependency via homebrew
# see https://github.com/afni/afni/blob/master/src/other_builds/OS_notes.macos_12_ARM_a_admin_pt1.zsh
brew install python netpbm cmake gfortran gcc@13
brew install --cask xquartz
brew install libpng jpeg expat freetype fontconfig openmotif  \
    libomp gsl glib pkg-config gcc libiconv autoconf \
    libxt mesa mesa-glu libxpm
# Install R package dependency (list from rPkgsInstall.R)
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    afex phia snow nlme lmerTest gamm4 data.table paran psych corrplot metafor

# Install AFNI
echo "Installing AFNI from source code (building for apple aarch64)..."
export PATH=${AFNI_DIR}:${PATH}
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
