#!/bin/bash

# GPL-3.0 License

# This script will apply the tags in $1 to the playbook list. It's meant to make
# combining policies and playbooks easier.
# Change the Ansible command in the for loop to match your site's needs. By default it
# executes everything locally, with -C and -D to show a diff without applying changes.

DOWNLOAD_PATH=~/src
AUTHOR_REPO='ComplianceAsCode/content'
content_path=$(find "$DOWNLOAD_PATH"/"$AUTHOR_REPO"/scap-security-guide-* -maxdepth 0 -type d -print | sort -n | head -n 1)
TAG_FILE="$1"
PLAYBOOK_LIST_FILE='playbook-list.txt'

if [[ "$1" == '' ]]; then
    echo "[*]Usage: $0 [<tag-file>.txt]"
    exit 1
fi

if [[ ! -e "$1" ]]; then
    echo "[*]Tag file not found. Quitting."
    exit 1
fi

# shellcheck source=/dev/null
source /etc/os-release

for playbook in $(cat "$PLAYBOOK_LIST_FILE");
do
    echo "[*]Applying tags:$1  playbook:$(echo $playbook | awk -F'/' '{print $NF}')..."
    # Loops through the list of playbooks used to compile the tag lists, applies the set of tags from $1 using those playbooks
    ansible-playbook -i "localhost," -c local -b --ask-become-pass "$content_path"/ansible/"$playbook" --tags $(grep -Pv "^#" < "$1" | tr '\n' ',') -C -D
    #ansible-playbook -i inventory.ini -b -e "@auth.yml --ask-vault-pass "$content_path"/ansible/"$playbook" --tags $(grep -Pv "^#" < "$1" | tr '\n' ',') -C -D
done