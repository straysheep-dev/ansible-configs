build_kali_desktop
=========

Deploy a customizable desktop environment for [Kali Linux](https://www.kali.org/get-kali/).

This is meant to manage all things specific to Kali without getting in the way of more common system settings and services. Things such as DNS, logging, additional hardening, HIDS/IPS can (and should) be applied using other roles.

- Handles tools and packages by using a template task file based on the intended usage, choose and manage the tools in `vars/main.yml` ([see below](#role-variables))
  - Tasks pull from sources such as apt, pip, GitHub repos, GitHub release files, and individual URLs
- Enables apparmor (including for Firefox)
- Installs a custom Firefox policy
- Automatically exports and installs the Burpsuite and ZAProxy CA certifactes (learned from [IppSec/parrot-build](https://github.com/IppSec/parrot-build/blob/master/roles/customize-browser/files/getburpcert.sh))
- Enables UFW, allows SSH
- Refreshes the SSH host keys (useful if Kali was pre-installed)
- Adjusts proxychains timeout values for scanning
- Installs [GEF (GDB Enhanced Features)](https://github.com/hugsy/gef)

Requirements
------------

Just Kali Linux. Both real hardware and virtualized environments will work.

Role Variables
--------------

Use `vars/main.yml` to select toolsets to install. "core" is always present as the base set of packages for general usage.

***Currently only `core` is ready to use.***

- `wireless_tools: "false"` Set to true to include wireless tools
- `analysis_tools: "false"` Set to true to include analysis tools
- `development_tools: "false"` Set to true to include development tools

All of the tools and packages are maintained through `vars/main.yml`, and each `tools-*` task file shares the same structure to maintain its own toolset:

- apt packages
- pip / go / ruby / npm packages
- git release files
- git repos to clone
- any other individual files to download
- any additional changes or adjustments specific to this task file

For example, use `tasks/tools-TEMPLATE.yml` to create a `tools-forensics.yml` task file.

`apt_list_REPLACE_THIS` would change to `apt_list_forensics`, and `vars/main.yml` would contain the `apt_list_forensics` variable of apt packages related to forensics.

Populate the remaining areas with any necessary lists; `pip_list_forensics`, `author_repo_list_forensics`, and so on.

Dependencies
------------

None.

Example Playbook
----------------

Running locally (though this role works on remote machines as well):

```yml
- name: "Default Playbook"
  hosts: localhost
  connection: local
  roles:
    - role: "build_kali_desktop"
```

Execute with:

```bash
ansible-playbook --ask-become-pass -v ./playbook.yml
```

License
-------

MIT: All files unless otherwise noted are released under the MIT license.

[BSD-3-Clause](https://github.com/IppSec/parrot-build/tree/master/roles/customize-browser#license): The method for obtaining the Burpsuite CA was learned and taken from IppSec's parrot-build [getburpcert.sh](https://github.com/IppSec/parrot-build/blob/master/roles/customize-browser/files/getburpcert.sh). That task block here will remain under the BSD-3-Clause.

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)