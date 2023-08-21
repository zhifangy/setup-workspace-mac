#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
MAMBA_DIR=${SETUP_ROOT}/micromamba
PATH=${MAMBA_DIR}/bin:${PATH}
POETRY_HOME=${SETUP_ROOT}/poetry
ENV_PREFIX=${SETUP_ROOT}/pyenv
# Cleanup old installation
if [ ! -z $(command -v micromamba) ]; then
    if [ $(micromamba env list | grep -c ${ENV_PREFIX}) -ne 0 ]; then
        echo "Cleanup old environment ${ENV_PREFIX}..."
        micromamba env remove -p ${ENV_PREFIX} -yq
    fi
fi
if [ -d ${MAMBA_DIR} ]; then echo "Cleanup old micromamba installation..." && rm -rf ${MAMBA_DIR}; fi
if [ -d ${POETRY_HOME} ]; then echo "Cleanup old poetry installation..." && rm -rf ${POETRY_HOME}; fi

# Install Micromamba
mkdir -p ${MAMBA_DIR} && curl -Ls https://micro.mamba.pm/api/micromamba/osx-64/latest | \
    tar -C ${MAMBA_DIR} -xvj bin/micromamba
echo "Current mamba: $(which mamba)"
# Install Poetry
export POETRY_HOME
export POETRY_CACHE_DIR=${POETRY_HOME}
export POETRY_CONFIG_DIR=${POETRY_HOME}
curl -sSL https://install.python-poetry.org | python3 -

# Create python environment
echo "Python enviromenmet location: ${ENV_PREFIX}"
cd "$(dirname "$0")"
micromamba create -p ${ENV_PREFIX} -f python_environment.yml -y
# Use environment for following steps
eval "$(micromamba shell hook --shell bash)"
micromamba activate ${ENV_PREFIX}
# Install packages using poetry
POETRY_CACHE_DIR=${POETRY_HOME}
# remove old poetry.lock file
if [ -f poetry.lock ]; then rm poetry.lock; fi
# install
poetry install -v

# Cleanup
micromamba clean -apy
poetry cache clear PyPI --all -n
poetry cache clear _default_cache --all -n
unset POETRY_HOME
unset POETRY_CACHE_DIR
unset POETRY_CONFIG_DIR

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

export MAMBA_DIR=${MAMBA_DIR}
export PATH=\${MAMBA_DIR}/bin:\${PATH}
alias mamba=micromamba
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE=\${MAMBA_DIR}/bin/micromamba;
export MAMBA_ROOT_PREFIX=\${MAMBA_DIR};
__mamba_setup=\"\$(\"\$MAMBA_EXE\" shell hook --shell zsh --root-prefix \"\$MAMBA_ROOT_PREFIX\" 2> /dev/null)\"
if [ \$? -eq 0 ]; then
    eval \"\$__mamba_setup\"
else
    alias micromamba=\"\$MAMBA_EXE\"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<


export POETRY_HOME=${SETUP_ROOT}/poetry
export POETRY_CACHE_DIR=\${POETRY_HOME}
export POETRY_CONFIG_DIR=\${POETRY_HOME}
export PATH=\${POETRY_HOME}/bin:\${PATH}
plugins(poetry)

Execute following lines:
source ~/.zshrc
mkdir -p \${ZSH_CUSTOM}/plugins/poetry
poetry completions zsh > \${ZSH_CUSTOM}/plugins/poetry/_poetry
"

echo "Installation completed!"
