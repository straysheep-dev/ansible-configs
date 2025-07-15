install_pipx
=========

Installs [`pipx`](https://github.com/pypa/pipx) using the instructions detailed in the [project's documentation](https://pipx.pypa.io/stable/installation/).

In most cases, all you need is `python3` and `python3-pip` installed on the target hosts. Only Fedora and Kali being rolling distributions appear to consistently have the latest version of `pipx` in their archives. Otherwise, it's often only the latest version of Debian or Ubuntu that will have the most up-to-date `pipx` available through apt.

Tested on:

- Ubuntu 22.04
- Debian 12
- Rocky 9

Requirements
------------

Either `python` and `pip` or `apt` / `dnf` installed on the target host(s).

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
