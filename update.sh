#!/bin/sh
# update.sh

# Update script that tries to pull the training VM to the appropriate latest versions

# Improved robustness:
# - tries the first command line arg or "." as location for the collection
# - remaining command line args are passed through to ansible-playbook call

# - runs 'git pull --recurse-submodules' on the collection
# - runs ansible

collection_dir="."

if [ "$(id -u)" -eq 0 ]; then
  echo "This script must be run by a regular user (with sudo privileges)."
  exit 1
fi

if [ -d "${collection_dir}" ]; then
    shift
elif [ -d "./vm-setup/ansible" ]; then
    collection_dir="."
else
    echo "Directory not found: ${collection_dir}"
    exit 1
fi

if [ -e "/etc/epics-training" ]; then
    slug=$(</etc/epics-training)
else
    slug=""
fi

# Ensure necessary commands are available
for cmd in git ansible-galaxy ansible-playbook; do
    if ! command -v $cmd > /dev/null; then
        echo "Command not found: $cmd"
        exit 1
    fi
done

ansible-galaxy install -r "requirements.yml" || true
ansible-playbook -i "./ansible/hosts" "./ansible/playbook.yml" "$@"
