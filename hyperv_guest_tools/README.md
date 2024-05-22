hyperv_guest_tools
=========

Installs the necessary components to use enhanced session features on Hyper-V Linux guest VMs that were not created using the Quick Create Gallery.

Scripts currently exist for:

- [Ubuntu 18.04+](https://github.com/straysheep-dev/linux-vm-tools/blob/master/ubuntu/22.04/install.sh)
- Arch (TO DO)
- Fedora (TO DO)
- Debian (TO DO)

These scripts include small adjustments from [the original (now archived) versions](https://github.com/microsoft/linux-vm-tools).

*NOTE: This role is not necessary for Kali, it will automatically detect Hyper-V during install. If not, enable the features using `kali-tweaks`.*

- [microsoft/linux-vm-tools: Project Wiki](https://github.com/microsoft/linux-vm-tools/wiki)
- [Kali Hyper-V Enhanced Session Mode](https://gitlab.com/kalilinux/packages/kali-tweaks/-/blob/kali/master/helpers/hyperv-enhanced-mode)

Requirements
------------

Target node must be a Hyper-V guest, with a GUI desktop environment.

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

Using a vault:

```bash
ansible-playbook -i inventory.ini --ask-vault-pass --extra-vars "@auth.yml" -v playbook.yml
```

Without a vault:

```bash
ansible-playbook -i inventory.ini --ask-become-pass -v playbook.yml
```

License
-------

[MIT](https://github.com/microsoft/linux-vm-tools/blob/master/LICENSE)

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)