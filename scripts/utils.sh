#!/bin/sh
set -e

get_os_type() {

    # Determine the operating system and architecture
    local OS_NAME=$(uname -s)
    local ARCH_NAME=$(uname -m)

    OS_TYPE=""
    # Check for ARM-based macOS
    if [ "$OS_NAME" = "Darwin" ] && [ "$ARCH_NAME" = "arm64" ]; then
        OS_TYPE="macos"
    # Check for RHEL 8 x86
    elif [ "$OS_NAME" = "Linux" ] && [ -f /etc/redhat-release ] && [ "$ARCH_NAME" = "x86_64" ]; then
        # Verify it's RHEL 8
        if grep -q "release 8" /etc/redhat-release; then
            OS_TYPE="rhel8"
        fi
    else
        >&2 echo "Unsupported OS or architecture."
        exit 1
    fi
    export OS_TYPE

}

get_install_root_prefix() {

    # root directory to install everything
    if [ -z "${INSTALL_ROOT_PREFIX}" ]; then
        echo "INSTALL_ROOT_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
        export INSTALL_ROOT_PREFIX='${HOME}/Softwares'
    fi

}

get_script_root_prefix() {

    # root directory of workspace setup scripts
    export SCRIPT_ROOT_PREFIX=$(dirname -- "$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")")

}

# Initialize environment
init_setup() {
    get_os_type
    get_install_root_prefix
    get_script_root_prefix
}
