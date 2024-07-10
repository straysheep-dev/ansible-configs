#!/bin/bash

# GPL-3.0 License

# This script will apply all uncommented tags found in `pwd`/tags-*.txt files using the
# playbooks in `pwd`/playbook-list.txt file.
# It's meant to make combining policies and playbooks easier.

RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings
BLUE="\033[01;34m"     # Information
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

# Hardcoded variables based on the download path created with download-content.sh
DOWNLOAD_PATH=~/src
AUTHOR_REPO='ComplianceAsCode/content'
content_path=$(find "$DOWNLOAD_PATH"/"$AUTHOR_REPO"/scap-security-guide-* -maxdepth 0 -type d -print | sort -n | head -n 1)
TAGS_LIST=$(find ../ -maxdepth 2 -name "tags-*.txt" | awk -F'/' '{print $3}')
PLAYBOOK_LIST=$(cat playbook-list.txt)
# Initialize argument variables
CHECK_DIFF=''
INVENTORY_PATH=''
VAULT_PATH=''
BECOME_ARGS=''
LOCAL_CONNECT=''

# shellcheck source=/dev/null
source /etc/os-release

HelpMenu() {
    echo ""
    echo "[*]Usage: $0 -i <inventory>"
    echo ""
    echo "    [-d|--diff] Run playbook in -C check and -D diff mode"
    echo "    [-l|--local] Connect locally, -i must be 'localhost,'"
    echo "    [-v|--vault /path/to/vault.yml] Path to a vault file"
    echo "    [-b|--become] Elevate entire playbook to root"
	echo ""
	echo "Example: $0 -i \"localhost,\" --vault \"/home/fedora/src/vault.yml\" --local --diff"
	echo "Example: $0 -i ~/ansible/inventory.ini --vault \"~/ansible/vault.yml\" "
    echo ""
    exit 1
}

ExecutePlaybooks() {
    for playbook in $PLAYBOOK_LIST;
    do
        for tag_file in $TAGS_LIST;
        do
			active_tags=$(grep -Pv '^(#|$)' < "$tag_file" | tr '\n' ',')
			if [[ $(grep -Pv '^(#|$)' $tag_file | wc -l | awk '{print $1}') != '0' ]]; then
				echo -e "${BLUE}[*]Applying tags:$tag_file  playbook:$playbook...${RESET}"
				# Loops through the list of playbooks used to compile the tag lists, applies the set of tags from $1 using those playbooks

				# These vairables cannot be double quoted
				echo -e "${BLUE}"
				echo PLAYBOOK COMMAND: ansible-playbook ${INVENTORY_ARGS} ${LOCAL_CONNECT} "${VAULT_ARGS}" ${BECOME_ARGS} $content_path/ansible/$playbook --tags $active_tags ${CHECK_DIFF}
				echo -e "${RESET}"
				# This must be echo'd and piped to | bash
				echo ansible-playbook ${INVENTORY_ARGS} ${LOCAL_CONNECT} "${VAULT_ARGS}" ${BECOME_ARGS} $content_path/ansible/$playbook --tags $active_tags ${CHECK_DIFF} | bash || echo "[ERROR] Quitting."; exit 1
			else
				echo -e "${BLUE}[*]$tag_file has no active tags. Skipping...${RESET}"
			fi
        done
    done
}

# This is the easiest way to do this in bash, but it won't work in other shells
# See getopt-parse under /usr/share/doc/util-linux/examples
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
	case $1 in
		-b|--become)
			BECOME_ARGS="-b"
			shift # past argument
			#shift # Commented, since argument has no value to shift past
			;;
		-d|--diff)
			CHECK_DIFF="-C -D"
			shift # past argument
			#shift # Commented, since argument has no value to shift past
			;;
		-i|--inventory)
			INVENTORY_ARGS="-i $2"
			shift # past argument
			shift # past value
			;;
		-l|--local)
			LOCAL_CONNECT="-c local"
			shift # past argument
			#shift # Commented, since argument has no value to shift past
			;;
		-v|--vault)
			VAULT_ARGS="-e \"@$2\" --vault-pass-file <(cat <<<\$ANSIBLE_VAULT_PASSWORD)"
			shift # past argument
			shift # past value
			;;
		-h|--help)
			HelpMenu
			exit 0
			shift # past argument
			#shift # Commented, since argument has no value to shift past
			;;
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1") # save positional arg
			shift # past argument
			;;
	esac
done

echo ""
echo -e "${BLUE}INVENTORY_ARGS: $INVENTORY_ARGS${RESET}"
echo -e "${BLUE}VAULT_ARGS: $VAULT_ARGS${RESET}"
echo -e "${BLUE}BECOME_ARGS: $BECOME_ARGS${RESET}"
echo -e "${BLUE}LOCAL_CONNECT: $LOCAL_CONNECT${RESET}"
echo -e "${BLUE}CHECK_DIFF: $CHECK_DIFF${RESET}"
echo ""

# Get the vault password if using a vault
if [[ "$ANSIBLE_VAULT_PASSWORD" == '' ]]; then
	echo "Enter Vault Password (or [enter] if not using a vault)"; read -s vault_pass; export ANSIBLE_VAULT_PASSWORD=$vault_pass
fi

ExecutePlaybooks