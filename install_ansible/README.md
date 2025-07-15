Role Name
=========

A role to install Ansible across an inventory.

On newer systems, this typically means using `pipx`. With older systems, this typically means using `pip`. Currently, this role only supports installs via `pipx`. Any installs via Linux package managers are not used unless there seems to be a unique use case for this; that's because the Anisble documentation recommends installing from PyPi (regardless of whether you're using pipx or pip).

Requirements
------------

`pipx` or `pip`.

Role Variables
--------------

None.

Dependencies
------------

- [install_pipx](), if `pipx` is the recommended method to install PyPi packages for that system.

> ![NOTE]
> TO DO: The `install_pipx` role will need published to ansible-galaxy, and the `meta/main.yml` file should point to that.

Example Playbook
----------------

playbook.yml:

```yml
- name: "Example Playbook"
  hosts:
    all
  roles:
    - role: "install_ansible"
```

Run with: `ansible-playbook -i "<host>," --ask-become-pass -v playbook.yml`

License
-------

BSD-3-Clause

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs)
