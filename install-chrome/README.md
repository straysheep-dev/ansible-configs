Role Name
=========

Installs Google Chrome directly from Google's Linux repository, and includes a hardened policy file.

- https://www.google.com/linuxrepositories/
- [Latest Signing Key](https://keyserver.ubuntu.com/pks/lookup?search=EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796&fingerprint=on&op=index)
- [Policy File](https://github.com/straysheep-dev/linux-configs/tree/main/web-browsers/chromium)

Requirements
------------

This role uses apt. It has only been tested on Debian-based systems.

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
    localhost
  roles:
    - role: "install-chrome"
```

Have the `install-chrome/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------
