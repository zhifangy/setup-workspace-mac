#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
AFNI_DIR=${SETUP_ROOT}/neurotools/afni
PATH=${AFNI_DIR}:${PATH}
# r related
R_LIBS=${R_LIBS:-${SETUP_ROOT}/renv}
CRAN=${CRAN:-https://packagemanager.posit.co/cran/latest}
N_CPUS=${N_CPUS:-4}
PATH=${R_LIBS}/littler/examples:${R_LIBS}/littler/bin:${PATH}
# set tbb related environment variable (for brms dependency RcppParallel)
export TBB_INC=$(ls -d /usr/local/Cellar/tbb/*)/include
export TBB_LIB=$(ls -d /usr/local/Cellar/tbb/*)/lib

# Cleanup old installation
if [ -d ${AFNI_DIR} ]; then echo "Cleanup old AFNI installation..." && rm -rf ${AFNI_DIR}; fi
if [ -d ~/.afni/help ]; then echo "Cleanup old AFNI help files ..." && rm -rf ~/.afni/help; fi
if [ -f ~/.afnirc ]; then echo "Cleanup old AFNI rc files ..." && rm ~/.afnirc; fi
if [ -f ~/.sumarc ]; then echo "Cleanup old SUMA rc files ..." && rm ~/.sumarc; fi

# Install dependency via homebrew
brew install netpbm cmake gfortran
brew install --cask xquartz
# Install R package dependency (list from rPkgsInstall.R)
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    afex phia snow nlme lmerTest paran psych brms corrplot metafor

# Install AFNI
echo "Installing AFNI from offical website..."
mkdir -p ${AFNI_DIR}
wget -q https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries -P ${AFNI_DIR}
# curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries
tcsh ${AFNI_DIR}/@update.afni.binaries -package macos_10.12_local -bindir ${AFNI_DIR} -apsearch yes
rm ${AFNI_DIR}/@update.afni.binaries
cp ${AFNI_DIR}/AFNI.afnirc ${HOME}/.afnirc
suma -update_env
apsearch -update_all_afni_help
# set options for X11
defaults write org.macosforge.xquartz.X11 wm_ffm -bool true
defaults write org.x.X11 wm_ffm -bool true
defaults write com.apple.Terminal FocusFollowsMouse -string YES

# Cleanup
if [ -f .R.Rout ]; then rm .R.Rout; fi
if [ -f ml_index_label.txt ]; then rm ml_index_label.txt; fi
if [ -f mllabelsonly.txt ]; then rm mllabelsonly.txt; fi

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# AFNI
export PATH=${AFNI_DIR}:\${PATH}

# for RcppParallel (dependency of brms)
export TBB_INC=\$(ls -d /usr/local/Cellar/tbb/*)/include
export TBB_LIB=\$(ls -d /usr/local/Cellar/tbb/*)/lib
"
