install_pipx
=========

Installs [`pipx`](https://github.com/pypa/pipx) using the instructions detailed in the [GitHub project's README](https://github.com/pypa/pipx?tab=readme-ov-file#install-pipx).

Works on Debian-based distributions using `apt`, and RedHat family distributions (such as Fedora) using `dnf`. The logic could be updated to work on any platform, since Ubuntu versions 22.10 and earlier will default to using `pip install` to install `pipx`. In these cases, all you need is python and pip.

Tested on Ubuntu.

Requirements
------------

Either `apt`, `dnf`, or `pip` installed on the target host(s).

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

playbook.yml:

```yml
- name: "Example Playbook"
  hosts:
    all
  roles:
    - role: "install_pipx"
```

Run with: `ansible-playbook -i "<host>," --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
