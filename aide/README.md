aide
=========

This role can manage `aide` across an inventory with the following functionality:

- Install aide (advanced intrusion detection environment)
- Initialize a database if one does not exist
- Check existing systems for integrity
- Update a database if one exists

Without setting anything in `defaults/main.yml`, it will ensure `aide` is installed with a config file matching the version of `aide` available on the system, and initialize the first database on each node.

Depending on which variable is set in `defaults/main.yml`, this role will either check the integrity of all nodes, or update their databases.

Each time a database operation occurs, ansible will print the resulting hashes for your records to stdout. **Save these to a password manager** or some type of vault for future integrity checking if it's ever needed.

*TO DO: Find a way to write / log all inventory database hashes to a file on the control node in some format. See: <https://docs.ansible.com/ansible/latest/reference_appendices/logging.html>*

### Mail Applications

Ubuntu installs `postfix` as a recommended package through `aide-common`. Similarly `bsd-mailx` is often installed on Debian / Kali. Preseeding options are available for `postfix` in `defaults/main.yml`. `bsd-mailx` does not appear to require this to install unattended.

Requirements
------------

None. Tested on Debian / Ubuntu, WSL, Fedora, and Kali.

Role Variables
--------------

Set these per-host or per-group in your inventory file.

- `check_db: true` Will only check the existing database(s) and print their hashes
- `update_db: true` Will update the existing database(s), this operation still prints the previous database's hash with the new one

Additionally this is where variables to "preseed" the installation of `postfix` exist. `postfix` is installed as a recommended package on Ubuntu. This role has it set to "Local only" by default.

See `defaults/main.yml` for more details. You will need to add additional questions to `Preseed Postfix configuration (Ubuntu)` in `install-aide.yml` if you need postfix configured differently.

- `postfix_main_mailer_type: "Local only"`, Options: `No configuration`, `Internet Site`, `Internet with smarhost`, `Satellite system`, `Local only`
- `postfix_mailname: "{{ ansible_hostname }}.local"`, The FQDN to your system, in other words, the hostname. Left as `{{ ansible_hostname }}.local` for "Local only"


Dependencies
------------

None.

Example Playbook
----------------

Using a vault:

```bash
ansible-playbook -i inventory.ini --ask-vault-pass --extra-vars "@auth.yml" -v playbook.yml
```

Without a vault:

```bash
ansible-playbook -i inventory.ini --ask-become-pass -v playbook.yml
```

License
-------

MIT

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)
