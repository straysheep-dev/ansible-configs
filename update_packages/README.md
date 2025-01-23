update_packages
===============

A role to update system packages as part of regularly scheduled maintenance or patching.

Currently tested on:

- Ubuntu 20.04+
- Fedora 39+
- Kali 2024+

Requirements
------------

None.

Role Variables
--------------

Set this in your inventory file.

- `reboot_after_updates: false`: Set to `true` for assets that should reboot after updates are applied. Useful for virtual machine templates.
- `shutdown_after_updates: false`: Set to `true` for assets that should be shutdown after updates are applied. Useful for virtual machine templates.

Example inventory:

```yml
remote_servers:
  hosts:
    10.20.30.40:
      ansible_user: root
      ansible_port: 22

virtual_machine_templates:
  hosts:
    10.90.90.10:
      ansible_user: vagrant
      ansible_port: 22
      ansible_become_password: "{{ vagrant1_sudo_pass }}"
    10.90.90.11:
      ansible_user: vagrant
      ansible_port: 22
      ansible_become_password: "{{ vagrant2_sudo_pass }}"

  vars:
    shutdown_after_updates: "true"
```

Dependencies
------------

None.

Example Playbook
----------------

```yml
- name: "Example Playbook"
  hosts:
    all
  roles:
    - role: "update_packages"
```

Run with:

```bash
# Using a vault:
echo "Enter Vault Password"; read -s vault_pass; export ANSIBLE_VAULT_PASSWORD=$vault_pass
# [type / paste vault password here, then enter]
ansible-playbook -i <inventory> -e "@~/vault.yml" --vault-pass-file <(cat <<<$ANSIBLE_VAULT_PASSWORD) -v ./playbook.yml
```

License
-------

MIT

Author Information
------------------

<https://github.com/straysheep-dev>
