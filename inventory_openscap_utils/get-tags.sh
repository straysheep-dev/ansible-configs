#!/bin/bash

# GPL-3.0 License

# This script will locate the latest version of ComplianceAsCode/content's Ansible playbooks
# and extract all available tags into a single list, sorting that list into separate groups.

# shellcheck disable=SC2034,SC2086

DOWNLOAD_PATH=~/src
AUTHOR_REPO='ComplianceAsCode/content'
TAG_FILE='tags-all.txt'
PLAYBOOK_LIST_FILE='playbook-list.txt'

PLAYBOOK_REGEX="$1"
if [[ "$1" =~ ^(-h|--help)$ ]]; then
	# Show usage if $1 equals -h or --help
	echo "This script will locate the latest version of ComplianceAsCode/content's Ansible playbooks"
	echo "and extract all available tags into a single list, sorting that list into separate groups."
	echo ""
	echo "As an optional argument, $0 reads \$1 and tries to match it against an existing playbook using"
	echo "find's posix-extended regex parser."
	echo ""
	echo "	Exmaple usage: $0 pci"
	echo "	Example usage: $0 'ubuntu2.*standard'"
	echo "	Exmaple usage: $0 '2204.*(stig|cis_level[0-9]_workstation)'"
	exit 0
fi

# shellcheck source=/dev/null
source /etc/os-release

content_path=$(find "$DOWNLOAD_PATH"/"$AUTHOR_REPO"/scap-security-guide-* -maxdepth 0 -type d -print | sort -n | head -n 1)
echo "[*]Found $content_path"

if [[ "$1" != "" ]]; then
	# If $1 has an argumet, try to find a matching playbook
	# https://stackoverflow.com/questions/6844785/how-to-use-regex-with-find-command
	playbook_list=$(find "$content_path"/ansible/ -regextype posix-extended -iregex ".*/.*$1.*\.yml")
	if [[ $playbook_list == "" ]]; then
		# If regex can't find any playbooks, let user know, then quit.
		echo "[WARNING]No playbook matching \"$1\""
		exit 1
	fi
else
	# If $1 has no argument, check all available playbooks
	playbook_list="$content_path/ansible/*${ID}*.yml"
fi

rm "$PLAYBOOK_LIST_FILE" 2>/dev/null # Remove any previous list to start a new one
for playbook in $playbook_list;
do
    echo "[*]Obtaining tags in: $(echo $playbook | awk -F'/' '{print $NF}')..."
	echo $playbook | awk -F'/' '{print $NF}' | tee -a "$PLAYBOOK_LIST_FILE" > /dev/null # Track what playbooks were searched for tags
    ansible-playbook "$playbook" --list-tags 2>&1 | grep 'TASK TAGS' | sed -E 's/      TASK TAGS://g' | sed -E 's/, /,/g' | sed -E 's/ \[//g' | sed -E 's/\]$//g' | tr ',' '\n'  | tee -a tags.tmp >/dev/null
done

sort < tags.tmp | uniq | tee "$TAG_FILE" >/dev/null
rm tags.tmp
echo "[>]Wrote tags to $TAG_FILE."
echo "[>]Wrote playbooks used to $PLAYBOOK_LIST_FILE"

# Parse account related tags
tag_group_file='tags-accounts'
grep 'password' tags-all.txt | tee $tag_group_file.tmp > /dev/null
grep 'accounts' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
grep 'pam' tags-all.txt | grep -Pv "(sshd|audit_)"| tee -a $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse filesystem mount tags
tag_group_file='tags-mount-options'
grep -P '^mount_option_' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse service-enabled tags
tag_group_file='tags-services-enabled'
grep -P '^service_.*_enabled$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse service-disabled tags
tag_group_file='tags-services-disabled'
grep -P '^service_.*_disabled$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse package-installed tags
tag_group_file='tags-packages-installed'
grep -P '^package_.*_installed$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse package-removed tags
tag_group_file='tags-packages-removed'
grep -P '^package_.*_removed$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse filesystem tags
tag_group_file='tags-filesystem'
grep -P '^dir_.*$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
grep -P '^file_.*$' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse kernel related tags
tag_group_file='tags-kernel'
grep -P '^kernel_module_.*' tags-all.txt | tee $tag_group_file.tmp > /dev/null
grep -P '^sysctl_.*' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
grep -P 'disable_ctrlaltdel_.*$' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
grep 'disable_users_coredumps' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse sshd related tags
tag_group_file='tags-sshd'
grep 'sshd' tags-all.txt | tee $tag_group_file.tmp > /dev/null
grep 'banner' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
grep 'package_openssh-server_installed' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
grep 'disable_host_auth' tags-all.txt | tee -a $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse aide related tags
tag_group_file='tags-aide'
grep -P '^aide_.*$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse auditd related tags
tag_group_file='tags-auditd'
grep -P '^audit_.*$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Parse sudo related tags
tag_group_file='tags-sudo'
grep -P '^sudo_.*$' tags-all.txt | tee $tag_group_file.tmp > /dev/null
sort < $tag_group_file.tmp | tee $tag_group_file.txt > /dev/null
rm $tag_group_file.tmp
echo "[>]Created $tag_group_file.txt..."

# Get a line count in each file
print_line_count() {
	for tag_list in ./tags-*.txt; do
		echo "[*]Total: $(wc -l "$tag_list")"
	done
}
print_line_count | column -t