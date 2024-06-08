install_sysmon
=========

This role installs `sysmonforlinux` from the Microsoft Linux package repositories, and starts the service.

Currently, this role ships a modified version of the [`main.xml`](https://github.com/microsoft/MSTIC-Sysmon/blob/main/linux/configs/main.xml) config (changed to log all of NetworkConnect Event ID 3 by default) from the MSTIC-Sysmon repo.

You can include your own, or use a template (see the links below) to build your own. The MSTIC (Microsoft Threat Intelligence Center) repo has a means of building a config file similar to how [Olaf Hartong's sysmon-modular](https://github.com/olafhartong/sysmon-modular) works, combining rules into a single config file based on MITRE ATT&CK detections.

- [MSTIC Sysmon Configuration Files (Linux)](https://github.com/microsoft/MSTIC-Sysmon/tree/main/linux)
  - [`main.xml`, includes all current detections](https://github.com/microsoft/MSTIC-Sysmon/blob/main/linux/configs/main.xml)
  - [`collect-all.xml`, logs everything (useful for testing)](https://github.com/microsoft/MSTIC-Sysmon/blob/main/linux/configs/collect-all.xml)
- [Azure Sentinel + Sysmon for Linux Environment](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/automating-the-deployment-of-sysmon-for-linux-and-azure-sentinel/ba-p/2847054)
- [olafhartong: Sysmon for Linux](https://medium.com/@olafhartong/sysmon-for-linux-57de7ca48575)

Follow (tail) logs with:

```bash
sudo tail -f /var/log/syslog | sudo /opt/sysmon/sysmonLogView
sudo journalctl -f | sudo /opt/sysmon/sysmonLogView
```

Requirements
------------

A [supported distribution](https://packages.microsoft.com/). Most Debian and RedHat family OS's are supported.

**IMPORTANT**: On recent versions of Fedora, `sysmonforlinux` and `powershell` are not available through Microsoft's feed for Fedora. However, both of these packages can be installed from Microsoft's feed for RHEL. USE THIS AT YOUR OWN RISK. Both packages were tested in a lab environment on Fedora 40, from RHEL 9's package feed.

If you plan to build your rules using the MSTIC-Sysmon repo, you will need PowerShell installed on the machine where you plan to build the config file. This can be Ubuntu or any supported Linux distro.

Role Variables
--------------

Default is set to `true`. To install your own, replace the `files/config.xml` file in this role.

- `config_file_present: "true"`

Dependencies
------------

This role depends on the `configure_microsoft_repos` role executing.

Example Playbook
----------------

Playbook file:

```yml
- name: "Default Playbook"
  hosts:
    all
  roles:
    - role: configure_microsoft_repos
    - role: install_sysmon
```

Run with:

```bash
ansible-playbook -i <inventory> --ask-become-pass -v ./playbook.yml
```

License
-------

- MIT (straysheep-dev)
- [MIT (Microsoft Corporation)](https://github.com/microsoft/MSTIC-Sysmon/blob/main/LICENSE)

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
