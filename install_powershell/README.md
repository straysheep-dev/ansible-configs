install_powershell
=========

Installs the [latest PowerShell version](https://github.com/PowerShell/PowerShell/releases) for Linux and Windows.

- [Official Documentation](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.4)

Requirements
------------

Either Windows or a [supported Linux distribution](https://packages.microsoft.com/). Most Debian and RedHat family OS's are supported.

**IMPORTANT**: On recent versions of Fedora, `sysmonforlinux` and `powershell` are not available through Microsoft's feed for Fedora. However, both of these packages can be installed from Microsoft's feed for RHEL. USE THIS AT YOUR OWN RISK. Both packages were tested in a lab environment on Fedora 40, from RHEL 9's package feed.

Role Variables
--------------

None.

Dependencies
------------

This role depends on the `configure_microsoft_repos` role executing when the target system is Linux.

Example Playbook
----------------

Playbook file:

```yml
- name: "Default Playbook"
  hosts:
    all
  roles:
    - role: configure_microsoft_repos
    - role: install_powershell
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
