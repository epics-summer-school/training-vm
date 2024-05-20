#!/bin/sh
# bootstrap.sh

# Simple bootstrap script for Ubuntu systems
# - installs prerequisites: git, ansible
# - clones training-collection repo into ./training
# - sets soft link bootstrap -> training/vm-setup

# $1 = repo (default: GitHub)

BOOTSTRAP_DIR="bootstrap"
COLLECTION_DIR="training"
COLLECTION_REPO=${1:-"https://github.com/epics-summer-school/training-vm"}

if [ "$(whoami)" = "root" ]; then
    echo "This script must be run by a regular user (with sudo privileges)."
    exit 1
fi

if [ ! -e "/etc/epics-training" ]; then
    echo "Please specify the slug (short name) of the training course that you"
    echo "want to configure this machine for."
    echo "See https://github.com/epics-summer-school/training-vm for valid strings."
    echo "Leaving it empty will use the latest versions of all available training modules."
    echo "(This is recommended for development of the training environment.)"
    read -p "Training course name []: " slug
    TMP_FILE=$(mktemp -q /tmp/epics.XXXXXX)
    echo "$slug" > $TMP_FILE
    sudo cp $TMP_FILE /etc/epics-training
    sudo chmod 644 /etc/epics-training
fi

slug=$(</etc/epics-training)

# Install prerequisites: Git, Ansible
packages=""
if ! command -v git >/dev/null; then
    packages="git"
fi
if ! command -v ansible >/dev/null; then
    packages="${packages} ansible"
fi
if [ "${packages}" ]; then    
    echo "Installing prerequisites: ${packages}..."
    sudo apt update
    sudo apt install -y ${packages}
else
    echo "All prerequisites are installed."
fi

# Clone the training-collection
if [ ! -e "${COLLECTION_DIR}" ]; then
    echo "Cloning training-collection ($slug) into ./${COLLECTION_DIR}..."
    git clone --recursive ${COLLECTION_REPO} ${COLLECTION_DIR}
    if [ "$slug" ]; then
        ( cd ${COLLECTION_DIR}; git checkout --recurse-submodules ${slug} )
    fi
else
    echo "Update the existing training-vm configuration by running 'git pull' in ./${COLLECTION_DIR}."
    echo "Switch the training setup with 'git checkout \$(</etc/epics-training)' in ./${COLLECTION_DIR}."
fi

# Set bootstrap soft link
if [ ! -e "${BOOTSTRAP_DIR}" ]; then
    ln -s "${COLLECTION_DIR}/vm-setup" "${BOOTSTRAP_DIR}"
fi

# Point out missing local.yml configuration
if [ ! -e "${COLLECTION_DIR}/vm-setup/ansible/group_vars/local.yml" ]; then
    ln -s "../../../local.yml" "${COLLECTION_DIR}/vm-setup/ansible/group_vars/local.yml"
else
    echo "Verify your existing local configuration in ${BOOTSTRAP_DIR}/ansible/group_vars/local.yml"
fi

echo "Run ${BOOTSTRAP_DIR}/update.sh at any time to update your installation."
