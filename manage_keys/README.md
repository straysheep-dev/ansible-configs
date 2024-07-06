manage_keys
=========

This role performs the following key related tasks across an inventory:

- Deploy public SSH keys to `authorized_keys` files
- Deploy private SSH keys
- Revoke public SSH keys from `authorized_keys` files
- Backup and recreate `authoirzed_keys` files

To accomplish this, place the following under this role's `files/` directory, one line / key per file:

- `<file>.pub` for public keys to distribute to `authorized_keys` files
- `<file>.rm` for keys to revoke
- `<file>.key` for private keys to distribute

Example:

```
files/id_rsa_straysheep-dev.pub
files/id_ed25519_another-key.pub
files/leaked_key.rm
files/ephemeral-dev.key
```

Tested on Windows and Linux endpoints.

Requirements
------------

SSH server running on each machine. For easy deployment of OpenSSH Server on Windows, use [Manage-OpenSSHServer.ps1](https://github.com/straysheep-dev/windows-configs/blob/main/Manage-OpenSSHServer.ps1).

Role Variables
--------------

Set the following per-host or per-group in your inventory.

- `is_managed: "false"`: Set to `"true"` to add or remove content from each endpoint's `authorized_keys` files.
- `is_manager: "false"`: Set to `"true"` to copy private keys to the remote machine(s).
- `backup_authorized_keys: "false"`: Set to `"true"` to backup the current `authorized_keys` files and replace them.

Example:

```ini
[manager_nodes]
192.168.0.20:22 ansible_user=root

[manager_nodes:vars]
is_manager="true"

[managed_nodes]
10.10.10.70:22 ansible_user=root
10.10.10.71:22 ansible_user=root
10.10.10.72:22 ansible_user=root

[managed_nodes:vars]
is_managed="true"
```

Dependencies
------------

None.

Example Playbook
----------------

```yml
- name: "Default Playbook"
  hosts: all
    #manager_nodes
    #managed_nodes
  roles:
    - role: "manage_keys"
```

Execute with:

```bash
ansible-playbook -i ./inventory.ini -v ./playbook.yml
```

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs