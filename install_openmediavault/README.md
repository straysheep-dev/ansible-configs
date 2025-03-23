install_openmediavault
=========

This role installs [openmediavault](https://www.openmediavault.org/) onto an existing minimal Debian server. This method was chosen so endpoint monitoring and networking utilities could be deployed on a NAS, and be part of a repeatable build.

- Automates all the provisioning steps to get a "default" install of openmediavault onto an existing machine
- Add's the `ansible_user_id` user to the `_ssh` group so this user can SSH back in after install
- Enables a base firewall policy with `ufw`, this is just a preference over using the Web UI to manage the firewall
- Is aware of tailscale, so the firewall will only allow tailnet traffic if `tailscale0` is detected
- Changes the default admin user's password after install to protect the web interface

> [!TIP]
> Think of openmediavault as way to administer and manage all the components of a NAS. This is slightly different than something like Dropbox or NextCloud that are both, storage solutions and ways to access and share your files, but neither are a NAS. This becomes clearer when seeing that the File Browser plugin (which spins up another network service so you can browse and preview the files on the system) is not installed by default. It's also not the most ideal way to replace something like a Google Drive or Dropbox. This makes openmediavault perhaps a great solution to manage the underlying system you're running the NAS on, and something like Dropbox or NextCloud the service that sync's your files and makes them accessible for editing and sharing.

After installing openmediavault with this role, here are some things you should do:

- Generate a CA to use with the web interface and other services
- Add widgets to the dashboard (adding them all isn't a bad idea)
- Modify any users and permissions
- [Create a btrfs RAID filesystem](https://docs.openmediavault.org/en/stable/administration/storage/filesystems.html) for redundant and performant storage, all achievable through the web interface
  - Storage > Disks: Select attached disks, mount or wipe them if necessary
  - Storage > File Systems: Create, choose the filesystem and RAID type, select all disks and apply
  - Storage > Shared Folders: Folder administration, ACLs, schedule btrfs snapshots, and more
- Install [official plugins](https://docs.openmediavault.org/en/stable/plugins.html) to extend the functions of the web interface
  - USB Backup: Sync data to and from connected USB storage devices
  - File Browser: Browse files from the web interface, for a more "Google Drive-like" experience
- Backup `/etc/openmediavault/config.xml` (there's no backup/restore function but you can restore using the `config.xml`)

The following resources were used to create this role:

- [openmediavault: Debian Install Instructions](https://docs.openmediavault.org/en/stable/installation/on_debian.html)
- [openmediavault: Administration](https://docs.openmediavault.org/en/stable/administration/index.html)
- [Ansible: Generate Encrypted Unix Passwords](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module)

Requirements
------------

A [minimal Debian server](https://cdimage.debian.org/mirror/cdimage/release/current/amd64/iso-cd/). Use the latest net installer ISO. The [debian-12-server packer template](https://github.com/straysheep-dev/packer-configs/tree/main/debian-12-server) was put together to use as a base.

Role Variables
--------------

All variables are under [defaults/main.yml](defaults/main.yml).

**`admin_pw_hash: <unix-password-hash>`**

This is a salted, sha512 unix password hash (they start with a `$6`). You can [create one with Ansible](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module). The default password in this role represents the password of 'mypassword' from the Ansible documentation. Change this to something unique so the web interface is protected after deployment. Ideally you'd have this hash value in an Ansible vault and reference it from your inventory file.

```bash
# Generate a password hash using ansible and passlib
pipx inject ansible passlib
ansible all -i localhost, -m debug -a "msg={{ 'mypassword' | password_hash('sha512', 'mysecretsalt') }}"

# Generate a password hash with mkpasswd
sudo apt update; sudo apt install -y whois
mkpasswd --method=sha-512
```

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
    - role: "install_openmediavault"
```

Have the `install_openmediavault/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs