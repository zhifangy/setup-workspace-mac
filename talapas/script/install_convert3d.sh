#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/convert3d")"
ENV_PREFIX=${INSTALL_PREFIX}/env
# Check micromamba
if ! command -v micromamba &> /dev/null; then
    echo "Error: micromamba is not installed." >&2
    exit 1
fi

# Cleanup old installation
if [ $(micromamba env list | grep -c ${ENV_PREFIX}) -ne 0 ]; then
    echo "Cleanup old environment ${ENV_PREFIX}..."
    micromamba env remove -p ${ENV_PREFIX} -yq
fi
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing convert3d from conda-forge..."
micromamba create -p ${ENV_PREFIX} -c conda-forge -yq convert3d

# Symlink binary files
# to avoid environment conflict (e.g., zlib, clang), all binaries will be symlinked to separate directories
mkdir -p ${INSTALL_PREFIX}/bin
FILE_LIST=$(grep -v "_path" $(ls ${ENV_PREFIX}/conda-meta/convert3d*) | grep -o "bin/.*[A-Z|a-z|0-9]")
while IFS='' read -r p; do
    ln -s ${ENV_PREFIX}/${p} ${INSTALL_PREFIX}/${p}
done < <(printf '%s\n' "$FILE_LIST")

# Cleanup
micromamba clean -yaq

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Convert3d
export PATH=\"${SETUP_PREFIX}/convert3d/bin:\${PATH}\"
"
