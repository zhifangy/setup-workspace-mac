#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
SCRIPT_ROOT_DIR=$(dirname "$(dirname "$(realpath -- "$0")")")
# Set environment variables
export \
    MAMBA_ROOT_PREFIX="$(eval "echo ${SETUP_PREFIX}")/micromamba" \
    UV_ROOT_DIR="$(eval "echo ${SETUP_PREFIX}")/uv"
export \
    UV_PYTHON_INSTALL_DIR="${UV_ROOT_DIR}/python" \
    UV_TOOL_DIR="${UV_ROOT_DIR}/tool" \
    UV_CACHE_DIR="${UV_ROOT_DIR}/cache"
export PY_LIBS="$(eval "echo ${SETUP_PREFIX}/pyenv")"
export PYTHON_VERSION="3.12"

# Install packages
formula_packages=("micromamba" "uv" "ruff")
for package in "${formula_packages[@]}"; do
    brew list --formula "${package}" &> /dev/null || brew install "${package}"
done

# Cleanup old python environment
if [ $(micromamba env list | grep -c ${PY_LIBS}) -ne 0 ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    micromamba env remove -p ${PY_LIBS} -yq
elif [ -d ${PY_LIBS} ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    rm -rf ${PY_LIBS}
fi

# Install uv-managed python
uv python install ${PYTHON_VERSION}

# Create python environment
micromamba create -yq -p ${PY_LIBS}
eval "$(micromamba shell hook --shell bash --root-prefix ${MAMBA_ROOT_PREFIX})"
micromamba activate ${PY_LIBS}
# create venv (PEP 405 compliant) via UV in the environment directory
uv venv --allow-existing --seed --python ${PYTHON_VERSION} ${PY_LIBS}

# Install packages in venv via UV
uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml --extra full
# special treatment for brainstat
uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml --extra brainstat_deps
uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml --extra brainstat_nodeps --no-deps

# Cleanup
micromamba clean -apyq
uv cache clean

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Micromamba
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE=\"\$(brew --prefix micromamba)/bin/micromamba\";
export MAMBA_ROOT_PREFIX=\"${SETUP_PREFIX}/micromamba\";
__mamba_setup=\"\$(\"\$MAMBA_EXE\" shell hook --shell zsh --root-prefix \"\$MAMBA_ROOT_PREFIX\" 2> /dev/null)\"
if [ \$? -eq 0 ]; then
    eval \"\$__mamba_setup\"
else
    alias micromamba=\"\$MAMBA_EXE\"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# UV
export UV_ROOT_DIR=\"${SETUP_PREFIX}/uv\"
export \\
    UV_PYTHON_INSTALL_DIR=\"\${UV_ROOT_DIR}/python\" \\
    UV_TOOL_DIR=\"\${UV_ROOT_DIR}/tool\" \\
    UV_CACHE_DIR=\"\${UV_ROOT_DIR}/cache\"

# Python environment
export PY_LIBS=\"${SETUP_PREFIX}/pyenv\"
micromamba activate \$PY_LIBS

Execute following lines:
source ~/.zshrc
"
