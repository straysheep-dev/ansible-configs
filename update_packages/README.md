update_packages
===============

A role to update system packages as part of regularly scheduled maintenance or patching.

Currently tested on:

- Ubuntu 20.04+

Requirements
------------

None.

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

```yml
- name: "Example Playbook"
  hosts:
    localhost
  roles:
    - role: "update_packages"
```

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

<https://github.com/straysheep-dev>
