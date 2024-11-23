#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
SYSTOOLS_DIR="$(eval "echo ${SETUP_PREFIX}/systools")"
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/afni")"
PKG_VERSION=linux_rocky_8
R_LIBS="${R_LIBS:-$(eval "echo ${SETUP_PREFIX}/renv")}"
N_CPUS=${N_CPUS:-8}
export PATH="${INSTALL_PREFIX}:${PATH}"

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then echo "Cleanup old AFNI installation..." && rm -rf ${INSTALL_PREFIX}; fi
if [ -d ~/.afni/help ]; then echo "Cleanup old AFNI help files ..." && rm -rf ~/.afni/help; fi
if [ -f ~/.afnirc ]; then echo "Cleanup old AFNI rc files ..." && rm ~/.afnirc; fi
if [ -f ~/.sumarc ]; then echo "Cleanup old SUMA rc files ..." && rm ~/.sumarc; fi

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
echo "Installing AFNI from offical binary package..."
curl -s https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries | tcsh -s - -no_recur -package ${PKG_VERSION} -bindir ${INSTALL_PREFIX}
# post installation setup
cp ${INSTALL_PREFIX}/AFNI.afnirc ${HOME}/.afnirc
suma -update_env
apsearch -update_all_afni_help
afni_system_check.py -check_all

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# AFNI
export AFNI_DIR=\"${SETUP_PREFIX}/afni\"
export PATH=\"\${AFNI_DIR}:\${PATH}\"
# command completion
if [ -f \${HOME}/.afni/help/all_progs.COMP.zsh ]; then source \${HOME}/.afni/help/all_progs.COMP.zsh; fi
# add jpeg-9e in LD_LIBRARY_PATH
export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:${SETUP_PREFIX}/afni/jpeg-9e/lib\"
# do not log commands
export AFNI_DONT_LOGFILE=YES
"
