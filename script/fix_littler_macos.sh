#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
R_LIBS="${R_LIBS:-$(eval "echo ${SETUP_PREFIX}/renv")}"

for FILE in ${R_LIBS}/littler/examples/*.r; do
    sed -i '' "s|#!/usr/bin/env r|#!${R_LIBS}/littler/bin/r|" ${FILE}
done
