#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
R_LIBS=${R_LIBS:-${SETUP_ROOT}/renv}

for FILE in ${R_LIBS}/littler/examples/*.r; do
    sed -i '' "s|#!/usr/bin/env r|#!${R_LIBS}/littler/bin/r|" ${FILE}
done
