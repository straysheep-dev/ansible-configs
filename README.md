# ansible-configs

A collection of ansible roles.

This repo is both a set of various roles to mirror my own bash scripts, and my notes on using Ansible for easy reference.

It's structured to be easy to clone, modify, and run only the roles you need. In most cases all you need to change is:

- `playbook.yml`'s roles
- Your preferred `inventory/` file's hosts + users

Use whichever inventory format works best for you. The `.ini` files allow specifying users as inline variables per host, which is useful if each host in a group has different users you'll be connecting as.

Each inventory example connects to the ansible controller (the localhost of the machine you're running ansible from) by default. Modify these files to add your own remote connections.

When you're done, run the playbook with one of the following:

```bash
# For using sudo on the remote host, where you aren't using the root account
ansible-playbook -i inventory/inventory.ini [-b] --ask-become-pass -v playbook.yml

# For using the root account on the remote host, typically to deploy and provision cloud resources
ansible-playbook -i inventory/inventory.ini -v playbook.yml
```

- `-b` will automatically elevate all tasks so you don't need to specify "become sudo" across every task (don't do this unless you need to)
- `--ask-become-pass` takes the sudo password for the remote user
- `-v` will show a useful amount of information without being too verbose

To do: how to specify each remote user's password (if there are multiple remote users listed, each with a unique password).


## Setup

Install Ansible:

- [Install Ansible via pipx](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pipx)
- [pipx: Install](https://pipx.pypa.io/stable/#install-pipx)
- [Install Ansible via pip](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#ensuring-pip-is-available)
- [Ensure pip, setuptools, wheel are up to date](https://packaging.python.org/en/latest/tutorials/installing-packages/#ensure-pip-setuptools-and-wheel-are-up-to-date)
- [Install pip on Debian/Ubuntu](https://packaging.python.org/en/latest/guides/installing-using-linux-tools/#debian-ubuntu-and-derivatives)


### Ubuntu 23.10+, Fedora:

It's recommended to use `pipx`.

```bash
# Ubuntu
sudo apt update
sudo apt install pipx

# Fedora
sudo dnf install pipx

pipx ensurepath
sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
```

Install Ansible using pipx:

```bash
pipx install --include-deps ansible
```

Upgrade Ansible:

```bash
pipx upgrade --include-injected ansible
```


### Ubuntu 22.04 and Older

If you're missing `pip`, the recommended way to install it on Ubuntu, or other Debian derivitives is through apt (Ansible's documentation also mentions the `python3-pip` package):

```bash
sudo apt update
sudo apt install python3-pip
```

Install Ansible using pip:

```bash
python3 -m pip install --user ansible
```

Upgrade Ansible:

```bash
python3 -m pip install --upgrade --user ansible
```


## Quick Start: Testing Plays

[Creating a playbook](https://docs.ansible.com/ansible/latest/getting_started/get_started_playbook.html)

Use this yaml block as a copy-and-paste starting point when developing and testing plays on a single machine "locally" with ansible installed.

This is useful to run only certain parts of a playbook or isolate certain tasks to debug them.

```yaml
# Write as: playbook.yml
# Run with: ansible-playbook ./playbook.yml
# https://docs.ansible.com/ansible/latest/getting_started/get_started_playbook.html
# https://docs.ansible.com/ansible/latest/inventory_guide/connection_details.html#running-against-localhost
# https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html
- name: Debug Playbook
  hosts: localhost
  connection: local
  vars:
    user_defined_var: True
  tasks:
    - name: Prints message only if user_defined_var variable is set to True
      ansible.builtin.debug:
        msg: "User defined variable set to: {{ user_defined_var }}"
      when: user_defined_var == True
    - name: Ping localhost
      ansible.builtin.ping:
```

## How Ansible Works

It's important to remember, for example, the `ansible.builtin.copy` module copies files *from* **the control node** *to* **managed nodes**, unless [`remote_src: yes`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html#parameter-remote_src) is set.

If `remote_src: yes` is set, `ansible.builtin.copy` will only use source paths on the remote host and not the control node.

Basically, *all tasks are typically executed on remote targets*. This means using `ansible.builtin.find` + registering a variable + `ansible.builtin.copy`, to copy arbitrary files *from* the control node won't work.

In that case, `ansible.builtin.find` will execute on the remote host, and not find the files. `ansible.builtin.copy` will attempt to use source paths on the remote host that don't exist instead of paths on the control node, causing this operation to fail.


## Variables and Inventories

*Currently, most roles in this repo have variables defined in `vars/main.yml`. This file takes precedence in most cases. Using `defaults/main.yml` for variables instead allows you to define the default there, and override those defaults in your inventory file(s) on a per-host or per-group level. This note will be removed and changed when all current roles are revised to reflect this.*

Example default value for a variable in `defaults/main.yml`:

```yml
some_var: "false"
```

Ansible has modular ways of approaching and maintaining both, variables and an inventory at the same time.

- [Assign variables per-machine](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#assigning-a-variable-to-one-machine-host-variables)
- [Assign variables to machine groups](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#assigning-a-variable-to-many-machines-group-variables)

Change `some_var` to `"true"` for just one host in your inventory:

```ini
10.0.0.40:22 ansible_user=user some_var="true"
```

Change `some_var` to `"true"` for all hosts in a specific inventory group:

```ini
[remotegroup]
10.0.0.41:22 ansible_user=user
10.0.0.42:22 ansible_user=user
10.0.0.43:22 ansible_user=user

[remotegroup:vars]
some_var="true"
```

Finally, be sure your `playbook.yml` file allows for either `all` groups, or the groups defined in your inventory file(s). If using `all`, you must ensure each inventory file has unique definitions to avoid collisions.

```yml
- name: "Default Playbook"
  hosts:
    # List groups from your inventory here
    # You could also use the built in "all" or "ungrouped"
    # "all" is necessary when Vagrant is auto-generating the inventory
    all
    #localgroup
    #remotegroup
    #tester_nodes
    #target_nodes
  roles:
  <SNIP>
```

See the following reference:

- [Playbook Variables: Tips on where to set variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#tips-on-where-to-set-variables)


## Windows Provisioning

You effectively have two options for opening Windows endpoints to Ansible provisioning:

- WinRM (Domain-Joined, ideally with Kerberos auth, [otherwise there's a less secure work around](https://github.com/ansible/ansible-documentation/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1))
- [SSH (Best for non-domain-joined endpoints)](https://github.com/straysheep-dev/windows-configs/blob/main/Manage-OpenSSHServer.ps1)

*[There's also PSRemoting over SSH, available to Windows, Linux, and macOS. The PowerShell version installed must be 7.X or later](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/ssh-remoting-in-powershell?view=powershell-7.4).*

Update your `inventory.ini` file by appending the following options to your Windows endpoints:

- `cmd` is the default shell for SSH on Windows
- Change this to `powershell` if you've defined PowerShell as the default SSH login shell
- `ansible_become_user` is better to be specified per host in the inventory file
- `ansible_become_password` may be necessary (with LAPS), use an ansible-vault to store these values
- `ansible_become_method: runas` can be specified per task just like `sudo`

```ini
[remotehosts]
# "Minimum" possible settings, if tasks specify `become_method: runas`
10.55.55.30:22 ansible_user=User ansible_become_user=User ansible_connection=ssh ansible_shell_type=cmd

# Additional settings for password, and become_method
10.55.55.31:22 ansible_user=User ansible_become_user=User ansible_become_password='{{ User_runas_pass }}' ansible_connection=ssh ansible_shell_type=cmd ansible_become_method=runas
```

Your tasks will have to reflect these kinds of settings as well, using `runas` instead of `sudo` when Windows is detected.

See the following references:

- [Ansible Privilege Escalation: `become` Connection Variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html#become-connection-variables)
- [Ansible Playbook Fails on Windows](https://devops.stackexchange.com/questions/16532/ansible-playbook-fails-on-windows-server)
- [Ansible Playbook Become Error](https://stackoverflow.com/questions/66671945/ansible-playbook-error-the-powershell-shell-family-is-incompatible-with-the-sud)

Execute with:

```bash
~/.local/bin/ansible-playbook -i inventory.ini -v ./playbook.yml
```


## Ansible-Vault

- [ansible-vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html)
- [become-connection-variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html#become-connection-variables)
- [playbooks-vault](https://docs.ansible.com/ansible/latest/vault_guide/vault_using_encrypted_content.html#playbooks-vault)

This utility is included with `ansible`, and allows you to create encyrpted ansible `.yml` files. It's primarily used for encrypting secrets used for plays, but can even be used to encrypt an entire role.

Create an encrypted file (called a vault):
```bash
ansible-vault create vault.yml
# Enter a password, then edit / write the file in the default text editor (vim)
```


### Vault Password File + Environment Variables

In cases where you're running multiple playbooks, it can be tedious to repeatedly enter the vault password. Ansible has a `--vault-pass-file` option that can read the password from a file. *Unfortunately, Ansible doesn't have a built in environment variable you can pass to it for this purpose.* Writing this secret in a plaintext file isn't the best idea, and interestingly enough **you can specify commands or scripts as the vault-pass-file**. This means you can use a similar trick to [configuring terraform environment variables](https://github.com/straysheep-dev/terraform-configs#quick-start-environment-variables) and read the vault password from an environment variable.

See these references for a full breakdown, they're summarized below:

- [Enter Vault Password Once for Multiple Playbooks](https://stackoverflow.com/questions/77622261/how-to-pass-a-password-to-the-vault-id-in-a-bash-script)
- [How to Pass an Ansible Vault a Password](https://stackoverflow.com/questions/62690097/how-to-pass-ansible-vault-password-as-an-extra-var/76236662)
- [Get Password from the Environment with `curl`](https://stackoverflow.com/questions/33794842/forcing-curl-to-get-a-password-from-the-environment/33818945#33818945)
- [Get Password from Shell Script without Echoing](https://stackoverflow.com/questions/3980668/how-to-get-a-password-from-a-shell-script-without-echoing#3980904)

First, enter the vault password with `read`:

```bash
echo "Enter Vault Password"; read -s vault_pass; export ANSIBLE_VAULT_PASSWORD=$vault_pass
```

- `-s` hides the text as you type
- The environment variable only appears in the `env` of that shell session
- It does not appear in the history of that shell
- Another shell running under the same user context cannot see that environment variable without a process dump

Execute with:

```bash
ansible-playbook -i <inventory> -e "@~/secrets/auth.yml" --vault-pass-file <(cat <<<$ANSIBLE_VAULT_PASSWORD) -v ./playbook.yml
```

- Uses `<(cat <<<$VARIABLE)` process substitution and creates a here-string
- The raw value will not appear in your process list
- Using [pspy](https://github.com/DominicBreuker/pspy) you can verify this
- Be sure `kernel.yama.ptrace_scope` is set to `1` or higher, as `0` will allow process dumping without root


### Use Case: Manage Remote Hosts with Unique Sudo Passwords

This covers the following scenario:

- You have two or more remote hosts with a normal user using `sudo` instead of root
- You need to update all of them weekly
- You do not want plain text passwords in yaml files
- Each remote host's `sudo` user has your ssh public key, and only accepts public key authentication

A clear way to manage this and illustrate how this works is by creating a new vault file (we'll call it `auth.yml`) containing all of the remote user passwords.

```bash
ansible-vault create auth.yml
# Specify a vault password, generate and save this to a password manager
```

The content of auth.yml could look like this:

```conf
admin_sudo_pass: 53Zbr3DPpfzGKSbWxNgWareBgNptKt5s
sql_admin_sudo_pass: 3KYRoAndmF53XDu33No7jfsNv2jrrpLi
```

Then the contents of `inventory/inventory.ini` could look like this:

```ini
10.20.30.40:2222 ansible_user=admin ansible_become_password='{{ admin_sudo_pass }}'
10.20.30.41:2222 ansible_user=sql_admin ansible_become_password='{{ sql_admin_sudo_pass }}'
```

To execute the playbook, specifying the `auth.yml` file with `-e "@auth.yml"`, and instead of `--ask-become-pass`, use `--ask-vault-pass`. Ansible will check the vaulted `auth.yml` file for the sudo passwords now instead of expecting them to be passed right after executing this command where typically it will only accept one input string for `become_pass`, which is the problem this solves.

```bash
ansible-playbook -i inventory/inventory.ini --ask-vault-pass --extra-vars "@auth.yml" -v playbook.yml
```

This can be taken further by also encrypting the usernames as variables in `auth.yml`.


## Ansible-Lint

For guidance on writing Ansible code, reference the [Ansible Lint Documentation](https://ansible.readthedocs.io/projects/lint/).

`ansible-lint` can be used on your playbooks, roles, or collections to check for common mistakes when writing ansible code.

- [Installing `ansible-lint`](https://ansible.readthedocs.io/projects/lint/installing/#installing-the-latest-version)

There are a number of ways to do this, but you can install `ansible-lint` just like `ansible`.

```bash
python3 -m pip install --user ansible-lint
```


## References

This repo was inspired by, and created after learning from [IppSec's parrot-build](https://github.com/IppSec/parrot-build) repo and video.
