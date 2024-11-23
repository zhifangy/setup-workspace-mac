#!/bin/bash

if [ -z "${SYSTOOLS_DIR}" ]; then
  echo "SYSTOOLS_DIR is not set."
  exit 1
fi

# Switch CONDA_PREFIX
CONDA_PREFIX_OLD=${CONDA_PREFIX}
CONDA_PREFIX=${SYSTOOLS_DIR}

# Execute scripts inside activate.d folder
for FILE in ${SYSTOOLS_DIR}/etc/conda/activate.d/*.sh; do;
    source ${FILE}
done

# Switch back CONDA_PREFIX
CONDA_PREFIX=${CONDA_PREFIX_OLD}
