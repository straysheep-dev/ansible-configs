manage_accounts
=========

This role can manage and provision accounts on remote nodes in the following ways:

- Manage users
- Manage groups
- Delete users
- Delete groups
- Manage arbitrary files often useful to accounts (configs, authorized_keys, and more)
- Ensures `sudo` or `sudo-rs` is installed

> [!NOTE]
> **AI Usage**
>
> Claude Sonnet 4.6 was used interactively to help learn a few concepts regarding variable control, loops, and templating tasks within a role to extend them as far as possible. The main goal was creating a template for a "builder" user to be used on Proxmox locally to create VM images with packer ([based on the GOAD project guide](https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/)). The secondary goal was a role that could manage really any group, account, or relevant files on a system. A number of examples were drafted and the resulting files were written after reviewing each task, citing the documentation, and finally testing usage.
>
> While building this role, Claude was tasked with gathering and reviewing existing roles for reference. Of the most popular roles on Ansible Galaxy, the closest this role resembles are the current verison of the [arillso/users](https://galaxy.ansible.com/ui/standalone/roles/arillso/users/documentation/) role, which has migrated to [arillso/ansible.system/roles/access](https://github.com/arillso/ansible.system/blob/main/roles/access/tasks/users.yml) (also under the [MIT license](https://github.com/arillso/ansible.system/blob/main/LICENSE)), and [robertdebock/ansible-role-users](https://github.com/robertdebock/ansible-role-users). Both have similar patterns being used here, but a custom role was chosen for a few reasons:
>
> - Simplify and consolidate user, group, and arbitrary file management
> - Maintain control over the role and how it works
> - Learn all of the above concepts for my own use


Requirements
------------

None.

Role Variables
--------------

`group_list: []` defines a list of groups to add to the system.

```yaml
group_list:
  - name: docker
  - name: devops
    gid: 2001
  - name: buildsvc
    system: true

```

`user_list: []` is the full definition of any users or accounts to create or manage.

```yaml
user_list:
  - name: builder
    uid: 2001
    groups: [kvm,sudo]
    append: true       # default: true (add to, don't replace, existing groups)
    shell: /bin/bash
    create_home: true
    password: "!"

```

`delete_user_list: []` deletes all accounts listed.

```yaml
delete_user_list:
  - olduser
  - tempuser

```

`delete_group_list: []` deletes all groups listed.

```yaml
delete_group_list:
  - oldgroup
  - tempgroup

```

`expire_user_list: []` expires the password for any accounts listed.

```yaml
expire_user_list:
  - builder
  - deploy

```

`ssh_authorized_keys: []` is a list of users and key files, plus sources. [`key:` accepts multiple key strings if they're separated by a newline](https://docs.ansible.com/projects/ansible/latest/collections/ansible/posix/authorized_key_module.html#parameter-exclusive).

```yaml
ssh_authorized_keys:
  - user: user1
    key: "<PUBLIC_KEY_STRING>"                            # String
    state: present                                        # default: present
    exclusive: false                                      # Append to, don't replace existing keys (default: false)
  - user: user2
    key: https://github.com/user2.keys                    # Remote URL
    exclusive: true                                       # Replace instead of append keys
  - user: user3
    key: file:///home/user3/.ssh/id_rsa.pub               # This example is local to the controller node
  - user: user4
    state: absent                                         # Removes the authorized_keys file

```

`managed_files: []` includes any arbitrary files relevant to the accounts being managed.

```yaml
managed_files:
  - dest: /etc/sudoers.d/builder
    content: |
      builder ALL=(root) NOPASSWD: /usr/local/bin/pve-import
    owner: root
    group: root
    mode: "0440"
    validate: /usr/sbin/visudo -cf %s

  - dest: /usr/local/bin/pve-import
    src: files/pve-import.sh
    owner: root
    group: root
    mode: "0750"

```

`sudo_package: sudo` determines which sudo package to look for, or install. This is a choice since [`sudo-rs`](https://github.com/trifectatechfoundation/sudo-rs) [is replacing `sudo` by default starting in Ubuntu 25.10](https://discourse.ubuntu.com/t/adopting-sudo-rs-by-default-in-ubuntu-25-10/60583).

*Note: on some systems, like Proxmox, `sudo-rs` may not install a default `/etc/sudoers` file, or may be invoked via `sudo-rs` and `visudo-rs` instead.*

```yaml
sudo_package: sudo-rs
```

Dependencies
------------

None

Example Playbook
----------------

One example using all of the capabilities of this role is provisioning a "builder" user on a Proxmox hypervisor, like the one described in the [Game of AD](https://orange-cyberdefense.github.io/GOAD/providers/proxmox/) [proxmox + packer guide by mayfly277](https://mayfly277.github.io/posts/GOAD-on-proxmox-part2-packer/).

```yml
- name: Provision Proxmox builder account
  hosts: all
  become: true  # All tasks require root
  roles:
    - role: configure_hashicorp_repos
    - role: install_packer
    - role: manage_accounts
      vars:
        group_list:
          - name: sudo
            gid: 2001

        user_list:
          - name: builder
            uid: 2001
            groups: [kvm,sudo]
            append: true        # default: true (add to, don't replace, existing groups)
            shell: /bin/bash
            create_home: true
            password: "!"

        ssh_authorized_keys:
          - user: builder
            key: "<YOUR_PUBLIC_KEY_STRING>"
            exclusive: true

        managed_files:
          - dest: /etc/sudoers.d/builder
            content: |
              builder ALL=(root) NOPASSWD: /usr/local/bin/pve-import
            owner: root
            mode: "0440"
            validate: visudo -cf %s

          - dest: /usr/local/bin/pve-import
            src: files/pve-import.sh
            owner: root
            mode: "0750"

        sudo_package: sudo

```

Execute on Proxmox node with:

```bash
ansible-playbook -i "<proxmox-fqdn-or-ip>," --private-key ~/.ssh/id_ed25519 -u root ./playbook.yml
```

License
-------

[MIT](./LICENSE)

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
