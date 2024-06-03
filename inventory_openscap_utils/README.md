# OpenSCAP Utilities

Scripts and files to apply OpenSCAP policies using Ansible tags.

- <https://straysheep.dev/blog/2024/05/29/openscap-practical-usage/#ansible-tags>

***IMPORTANT:** This should be used as **one** method to get your systems into a desired state. Some policy rules do not have Ansible tasks for them, and will need manually applied via a shell script. Additionally, not all tags are sorted and grouped out of each policy. This is why the tags-all.txt file is created, so you can add anything that's missing. Identify these items with the `oscap` scanner.*


## Using Tag Lists

Tags are as specific as individual policy rule names, types of changes (`high-disruption`, `low_complexity`), or the policy itself (DISA-STIG-UBTU-20-010013).

A list of "meta" tags is available for reference to start with. These cover *types* of changes rather than rules or policies. Building your own lists by specifying policies with `get-tags.sh` is the best way to organize, maintain, and control the testing and deployment of system states through Ansible.

To get started, follow these steps:

1. Run `download-content.sh`
2. Choose what policies you want to pull tags from
3. Run `get-tags.sh [regex]` where `regex` could be a policy (policies) or OS version
    - Example: `2204.*(cis_level1_server|stig)` would match the CIS L1 and STIG benchmarks for Ubuntu Server 2204.
4. Determine what tags to apply, comment out any you want to omit in each list
5. Test and apply tags with the following command, or use `apply-tags.sh`

```bash
ansible-playbook -i <inventory> [-b --ask-become-pass] /path/to/scap-security-guide-0.1.73/ansible/<playbook.yml> --tags $(grep -Pv "^#" < tags.txt | tr '\n' ',') [-C -D]
```

- Replace `tags.txt` with the list of tags you want to use
- Commented lines in each tag list will be ignored
- Use `-C -D` to "check" and "diff" without making any changes
- Any playbooks used are tracked in `playbook-list.txt`

Once you have a set of working tags, you can use those to maintain your machine states. Archive and organize them in a way that makes sense for you, for example by folder structure, or file name.

```
ubuntu-latest/
    |_tags-accounts.txt
    |_tags-all.txt
    |_tags-kernel.txt
    |_...
```

These scripts use built in variables with the default paths set to be under `~/src/ComplianceAsCode/content/...`. This is so they're all ready-to-run as is, but these variables can be changed by editing them at the top of each script as needed.


## Applying Tags

`apply-tags.sh` is a wrapper script to run the specified list of tags using each playbook those tags were pulled from. This works because if a tag in the list is present in a playbook, it's executed. Otherwise it's just ignored. You can extend this with another loop on the command line to run multiple tag lists against your playbook list:

```bash
for tags in tags-accounts.txt tags-filesystem.txt; do ./apply-tags.sh "$tags"; done
```

You will need to adjust the `ansible-playbook` line at the bottom of `apply-tags.sh`. By default it will run the changes in `-C` (`--check`) `-D` (`--diff`) mode, against the local machine. A commented example is below that line for using an Ansible vault on an inventory file instead.

This will help you build and test policies on the fly that fit your needs using everything available in the OpenSCAP content.