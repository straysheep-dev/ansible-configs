install_vscode
=========

Installs Visual Studio Code on Linux.

This will default to the `code-oss` package that ships with Kali. On all other distros it will use the Microsoft package feed to as its source to install `code`.

Tested on Ubuntu, Kali, Fedora.

Requirements
------------

This role depends on the `configure_microsoft_repos` role executing.

Role Variables
--------------

Configures whether to use the `snap` package manager, mainly for Ubuntu. Default is set to `false`.

- `prefer_snap: "false"`

Dependencies
------------

None.

Example Playbook
----------------


Playbook file:

```yml
- name: "Default Playbook"
  hosts:
    all
  roles:
    - role: configure_microsoft_repos
```

Run with:

```bash
ansible-playbook -i <inventory> --ask-become-pass -v ./playbook.yml
```

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
