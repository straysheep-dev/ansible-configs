# OpenSCAP Utilities

Scripts and files to apply OpenSCAP policies using Ansible tags. This mirrors what's covered in the post [OpenSCAP Practical Usage](https://straysheep.dev/blog/2024/05/29/openscap-practical-usage/#quickstart-demo), which has a demo with screenshots of the steps below.

***IMPORTANT:** This should be used as **one** method to get your systems into a desired state. Some policy rules do not have Ansible tasks for them, and will need manually applied via a shell script. Additionally, not all tags are sorted and grouped out of each policy. This is why the tags-all.txt file is created, so you can add anything that's missing. Identify these items with the `oscap` scanner.*

1. Run `./download-content.sh` to pull the latest OpenSCAP policy release from GitHub.
2. It will automatically `unzip` policy files matching the current OS. To specify another OS, use `./get-tags.sh -u <os-name>`.
3. You can list all available policy files with `./get-tags.sh -l`.
4. The `get-tags.sh` wrapper script is written to interpret posix-extended regex. Combine rules from multiple policies like this.

```bash
# Combine all tags from cis_level2_server and stig
./get-tags.sh 'ubuntu.*(cis.*2.*server|stig)'
```

5. Comment out any rules in the tags-*.txt files you don't want to apply, or find break the deployment.

```md
<SNIP>
accounts_password_pam_minclass
accounts_password_pam_minlen
accounts_password_pam_ocredit
#accounts_password_pam_pwquality_password_auth
#accounts_password_pam_pwquality_system_auth
#accounts_password_pam_retry
accounts_password_pam_ucredit
accounts_password_pam_unix_remember
<SNIP>
```

6. The `apply-tags.sh` wrapper script has built in `-h|--help` information. You can pass it all the arguments you will usually need to either test a policy on the localhost, or use an inventory + vault.

```bash
./apply-tags.sh -i "localhost," -l -v ~/vault.yml -d -b
```

*When the script executes a playbook, the raw command with all of the tags listed will be printed to your screen. This is copy / paste-able to repeat manually if necessary.*

There are also folders in the same directory of premade tag sets that will apply as many rules as possible without breaking a system, exceptions being `aide` and `auditd` rules. The reason being these rules often endlessly loop, need tuned to your environment, or break the deployment. Use the [`aide`](https://github.com/straysheep-dev/ansible-configs/tree/main/aide) and [`install_auditd`](https://github.com/straysheep-dev/ansible-configs/tree/main/install_auditd) roles instead.