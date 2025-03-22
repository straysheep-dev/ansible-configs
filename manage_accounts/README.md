manage_accounts
=========

This role will take a list of users and either create them, delete them, or expire their passwords.

Requirements
------------

None.

Role Variables
--------------

- `user_list: []`: Specify a list of users the tasks apply to
- `create_users: false`: Enable user creation
- `delete_users: false`: Enable user deletion
- `expire_passwords: false`: Expire users passwords on next login

Dependencies
------------

None

Example Playbook
----------------

```yml
- name: "Default Playbook"
  hosts: all
  roles:
    - role: "manage_accounts"
```

Execute with:

```bash
ansible-playbook -i ./inventory.ini -v ./playbook.yml
```

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
