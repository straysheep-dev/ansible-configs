Role Name
=========

Installs the ykman CLI utilty (yubikey-manager) from the yubico PPA.

This may be changed in the future to use the [pip install instructions](https://github.com/Yubico/yubikey-manager/#installation). As of Ubuntu 22.04:

```bash
sudo apt install -y libpcsclite-dev swig
python3 -m pip install --user yubikey-manager
```

Requirements
------------

None.

Role Variables
--------------

None.

Dependencies
------------

This task installs and starts pcscd and scdaemon.

Example Playbook
----------------

playbook.yml:

```yml
- name: "Example Playbook"
  hosts:
    localhost
  roles:
    - role: "install-ykman"
```

Have the `install-ykman/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] -b --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

