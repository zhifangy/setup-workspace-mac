#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${INSTALL_ROOT_PREFIX}/convert3d")"
ENV_PREFIX=${INSTALL_PREFIX}/env
C3D_VERSION=${C3D_VERSION:-1.4.2}


if [ "$OS_TYPE" == "macos" ]; then
# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing Convert3D from SourceForge..."
mkdir -p ${INSTALL_PREFIX}
wget -q https://downloads.sourceforge.net/project/c3d/c3d/Experimental/c3d-${C3D_VERSION}-MacOS-arm64.dmg \
    -P ${INSTALL_PREFIX}
7zz x ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64.dmg -o"${INSTALL_PREFIX}/" \
    c3d-${C3D_VERSION}-MacOS-arm64/Convert3DGUI.app > /dev/null
mv ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64/Convert3DGUI.app ${INSTALL_PREFIX}/Convert3DGUI.app

# Cleanup
rm ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64.dmg
rm -r ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Convert3D
export PATH=\"${INSTALL_ROOT_PREFIX}/convert3d/Convert3DGUI.app/Contents/bin:\${PATH}\"
"


elif [ "$OS_TYPE" == "rhel8" ]; then
# Cleanup old installation
command -v micromamba &> /dev/null || { echo "Error: micromamba is not installed." >&2; exit 1; }
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
export PATH=\"${INSTALL_ROOT_PREFIX}/convert3d/bin:\${PATH}\"
"
fi
