#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
SCRIPT_ROOT_DIR=$(dirname "$(dirname "$(realpath -- "$0")")")
# Set environment variables
export MAMBA_ROOT_PREFIX="$(eval "echo ${SETUP_PREFIX}/micromamba")"
export \
    CONDA_ENVS_DIRS="${MAMBA_ROOT_PREFIX}/envs" \
    CONDA_PKGS_DIRS="${MAMBA_ROOT_PREFIX}/pkgs" \
    CONDA_CHANNELS="conda-forge,HCC"
SYSTOOLS_DIR="$(eval "echo ${SETUP_PREFIX}/systools")"

# Install Micromamba
if command -v micromamba &> /dev/null || [ -d $MAMBA_ROOT_PREFIX ]; then
    echo "Micromamba is already installed."
else
    echo "Installing Micromamba ..."
    mkdir -p ${MAMBA_ROOT_PREFIX} && curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | \
    tar -C ${MAMBA_ROOT_PREFIX} -xj bin/micromamba
fi
# check if MAMBA_ROOT_PREFIX is in the PATH
if ! echo "$PATH" | grep -q $MAMBA_ROOT_PREFIX; then
    echo "However, $MAMBA_ROOT_PREFIX is not in the \$PATH."
    echo "Temporarily add it to \$PATH. Please modify the Shell profile file to make it persistent."
    PATH="${MAMBA_ROOT_PREFIX}/bin:$PATH"
fi

# Cleanup old installation
if [ $(micromamba env list | grep -c ${SYSTOOLS_DIR}) -ne 0 ]; then
    echo "Cleanup old environment ${SYSTOOLS_DIR}..."
    micromamba env remove -p ${SYSTOOLS_DIR} -yq
elif [ -d ${SYSTOOLS_DIR} ]; then
    echo "Cleanup old environment ${SYSTOOLS_DIR}..."
    rm -rf ${SYSTOOLS_DIR}
fi

# Create systools environment
echo "System tools enviromenmet location: ${SYSTOOLS_DIR}"
micromamba create -yq -p ${SYSTOOLS_DIR} -f ${SCRIPT_ROOT_DIR}/misc/systools.yml
# copy activate and deactivate script
cp ${SCRIPT_ROOT_DIR}/script/activate_systools.sh ${SYSTOOLS_DIR}/.
cp ${SCRIPT_ROOT_DIR}/script/deactivate_systools.sh ${SYSTOOLS_DIR}/.

# Fix zsh directory permission
chmod 755 ${SYSTOOLS_DIR}/share/zsh
chmod 755 $(ls -d ${SYSTOOLS_DIR}/share/zsh/*)
chmod 755 $(ls -d ${SYSTOOLS_DIR}/share/zsh/*)/functions

# Cleanup
micromamba clean -yaq

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# Micromamba
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE=\"${SETUP_PREFIX}/micromamba/bin/micromamba\";
export MAMBA_ROOT_PREFIX=\"${SETUP_PREFIX}/micromamba\";
__mamba_setup=\"\$(\"\$MAMBA_EXE\" shell hook --shell zsh --root-prefix \"\$MAMBA_ROOT_PREFIX\" 2> /dev/null)\"
if [ \$? -eq 0 ]; then
    eval \"\$__mamba_setup\"
else
    alias micromamba=\"\$MAMBA_EXE\"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
export PATH=\"${SETUP_PREFIX}/micromamba/bin:\${PATH}\"
# configuration
export \\
    CONDA_ENVS_DIRS=\"\${MAMBA_ROOT_PREFIX}/envs\" \\
    CONDA_PKGS_DIRS=\"\${MAMBA_ROOT_PREFIX}/pkgs\" \\
    CONDA_CHANNELS=\"conda-forge,HCC\"

# Systools
export SYSTOOLS_DIR=\"${SETUP_PREFIX}/systools\"
export PATH=\"\${SYSTOOLS_DIR}/bin:\${SYSTOOLS_DIR}/x86_64-conda-linux-gnu/sysroot/usr/bin:\${PATH}\"

# Compiler configuration
source \${SYSTOOLS_DIR}/activate_systools.sh
export LD_LIBRARY_PATH=\"\${SYSTOOLS_DIR}/lib:\${SYSTOOLS_DIR}/x86_64-conda-linux-gnu/sysroot/usr/lib64:\${LD_LIBRARY_PATH}\"
export PKG_CONFIG_PATH=\"\${SYSTOOLS_DIR}/lib/pkgconfig:\${PKG_CONFIG_PATH}\"

# bat
export BAT_THEME=\"Dracula\"

# fzf
# set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Direnv
eval \"\$(direnv hook zsh)\"

# Alias
# lsd
alias ll=\"lsd -l\"
alias la=\"lsd -a\"
alias lla=\"lsd -la\"
alias lt=\"lsd --tree\"
alias llsize=\"lsd -l --total-size\"
# fzf
alias preview=\"fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'\"
"
