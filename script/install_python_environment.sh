#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
# python related
export MAMBA_ROOT_PREFIX=${SETUP_ROOT}/micromamba
export UV_BASE_DIR=${SETUP_ROOT}/uv
export UV_PYTHON_INSTALL_DIR=${UV_BASE_DIR}/python
export UV_TOOL_DIR=${UV_BASE_DIR}/tool
export UV_CACHE_DIR=${UV_BASE_DIR}/cache
PY_LIBS=${SETUP_ROOT}/pyenv

# Install packages
brew install micromamba uv ruff

# Cleanup old python environment
if [ $(micromamba env list | grep -c ${PY_LIBS}) -ne 0 ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    micromamba env remove -p ${PY_LIBS} -yq
elif [ -d ${PY_LIBS} ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    rm -rf ${PY_LIBS}
fi

# Create environment
echo "Python enviromenmet location: ${PY_LIBS}"
cd "$(dirname "$0")"
# create empty environment via micromamba
micromamba create -yq -p ${PY_LIBS}
# activate environment
eval "$(micromamba shell hook --shell bash --root-prefix ${MAMBA_ROOT_PREFIX})"
micromamba activate ${PY_LIBS}
# create venv (PEP 405 compliant) via UV in the environment directory
uv venv --allow-existing --seed ${PY_LIBS}

# Install packages in venv via UV
uv pip install -r ${SCRIPT_DIR}/../environment_spec/pyproject.toml --extra full
# special treatment for brainstat
uv pip install -r ${SCRIPT_DIR}/../environment_spec/pyproject.toml --extra brainstat_deps
uv pip install -r ${SCRIPT_DIR}/../environment_spec/pyproject.toml --extra brainstat_nodeps --no-deps

# Cleanup
micromamba clean -apyq
uv cache clean

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Micromamba
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE=${HOMEBREW_ROOT}/bin/micromamba;
export MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX};
__mamba_setup=\"\$(\"\$MAMBA_EXE\" shell hook --shell zsh --root-prefix \"\$MAMBA_ROOT_PREFIX\" 2> /dev/null)\"
if [ \$? -eq 0 ]; then
    eval \"\$__mamba_setup\"
else
    alias micromamba=\"\$MAMBA_EXE\"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# Activate python environment
export PY_LIBS=${PY_LIBS}
micromamba activate \${PY_LIBS}

# UV
export UV_BASE_DIR=${UV_BASE_DIR}
export UV_PYTHON_INSTALL_DIR=\${UV_BASE_DIR}/python
export UV_TOOL_DIR=\${UV_BASE_DIR}/tool
export UV_CACHE_DIR=\${UV_BASE_DIR}/cache

Add below to alias section
alias mamba=\"micromamba\"

Execute following lines:
source ~/.zshrc
"
