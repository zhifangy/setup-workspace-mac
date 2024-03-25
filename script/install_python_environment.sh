#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
# python related
MAMBA_ROOT_PREFIX=${SETUP_ROOT}/micromamba
POETRY_HOME=${SETUP_ROOT}/poetry
PY_LIBS=${SETUP_ROOT}/pyenv

# Install Micromamba, Poetry
brew install micromamba poetry
echo "Current micromamba: $(which micromamba)"
echo "Current poetry: $(which poetry)"
export MAMBA_ROOT_PREFIX
export POETRY_HOME
export POETRY_CACHE_DIR=${POETRY_HOME}
export POETRY_CONFIG_DIR=${POETRY_HOME}

# Cleanup old python environment
if [ $(micromamba env list | grep -c ${PY_LIBS}) -ne 0 ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    micromamba env remove -p ${PY_LIBS} -yq
elif [ -d ${PY_LIBS} ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    rm -rf ${PY_LIBS}
fi

# Create python environment
echo "Python enviromenmet location: ${PY_LIBS}"
cd "$(dirname "$0")"
micromamba create -yq -p ${PY_LIBS} -f ${SCRIPT_DIR}/../environment_spec/python_environment.yml
# Use environment for following steps
eval "$(micromamba shell hook --shell bash --root-prefix ${MAMBA_ROOT_PREFIX})"
micromamba activate ${PY_LIBS}

# Install packages using poetry
cd "${SCRIPT_DIR}/../environment_spec"
# remove old poetry.lock file
if [ -f poetry.lock ]; then rm poetry.lock; fi
# install
poetry install -v

# Cleanup
micromamba clean -apyq
poetry cache clear PyPI --all -n
poetry cache clear _default_cache --all -n

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

# Poetry
export POETRY_HOME=${SETUP_ROOT}/poetry
export POETRY_CACHE_DIR=\${POETRY_HOME}
export POETRY_CONFIG_DIR=\${POETRY_HOME}

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
