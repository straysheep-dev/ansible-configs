install-unbound
=========

This role installs the unboud DNS resolver with a hardened configuration file based on pfSense's defaults. It also enables DNS logging along with  DNS over TLS to cloudflare and quad9 by default.

Requirements
------------

If installing in WSL, ensure you have WSL2 with systemd.

```powershell
wsl --update
wsl --shutdown
wsl
```

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
    - role: "install-unbound"
```

Have the `install-unbound/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] -b --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

