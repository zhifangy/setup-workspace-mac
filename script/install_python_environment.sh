#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
# python related
MAMBA_DIR=${SETUP_ROOT}/micromamba
POETRY_HOME=${SETUP_ROOT}/poetry
PY_LIBS=${SETUP_ROOT}/pyenv

# Cleanup old installation
if [ ! -z "$(command -v micromamba)" ]; then
    if [ $(micromamba env list | grep -c ${PY_LIBS}) -ne 0 ]; then
        echo "Cleanup old environment ${PY_LIBS}..."
        micromamba env remove -p ${PY_LIBS} -yq
    fi
else
    rm -rf ${PY_LIBS}
fi
if [ -d ${MAMBA_DIR} ]; then echo "Cleanup old micromamba installation..." && rm -rf ${MAMBA_DIR}; fi
if [ -d ${POETRY_HOME} ]; then echo "Cleanup old poetry installation..." && rm -rf ${POETRY_HOME}; fi

# Install Micromamba
mkdir -p ${MAMBA_DIR} && curl -Ls https://micro.mamba.pm/api/micromamba/osx-64/latest | \
    tar -C ${MAMBA_DIR} -xvj bin/micromamba
echo "Current mamba: $(which mamba)"
export PATH=${MAMBA_DIR}/bin:${PATH}
echo "Current mamba: $(which micromamba)"

# Install Poetry
export POETRY_HOME
export POETRY_CACHE_DIR=${POETRY_HOME}
export POETRY_CONFIG_DIR=${POETRY_HOME}
curl -sSL https://install.python-poetry.org | python3 -
export PATH=${POETRY_HOME}/bin:${PATH}

# Create python environment
echo "Python enviromenmet location: ${PY_LIBS}"
cd "$(dirname "$0")"
micromamba create -yq -p ${PY_LIBS} -f ${SCRIPT_DIR}/../environment_spec/python_environment.yml
# Use environment for following steps
eval "$(micromamba shell hook --shell bash)"
micromamba activate ${PY_LIBS}

# Install packages using poetry
cd "${SCRIPT_DIR}/../environment_spec"
# remove old poetry.lock file
if [ -f poetry.lock ]; then rm poetry.lock; fi
# install
poetry install --no-root -v

# Cleanup
micromamba clean -apyq
poetry cache clear PyPI --all -n
poetry cache clear _default_cache --all -n

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Micromamba
export MAMBA_DIR=${MAMBA_DIR}
export PATH=\${MAMBA_DIR}/bin:\${PATH}
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

# Poetry
export POETRY_HOME=${SETUP_ROOT}/poetry
export POETRY_CACHE_DIR=\${POETRY_HOME}
export POETRY_CONFIG_DIR=\${POETRY_HOME}
export PATH=\${POETRY_HOME}/bin:\${PATH}

# Activate python environment
export PY_LIBS=${PY_LIBS}
micromamba activate \${PY_LIBS}

Add below to alias section
alias mamba=\"micromamba\"

Execute following lines:
source ~/.zshrc
mkdir -p \${ZSH_CUSTOM}/plugins/poetry
poetry completions zsh > \${ZSH_CUSTOM}/plugins/poetry/_poetry

Add below to oh-my-zsh plugin
plugins(poetry)
"
