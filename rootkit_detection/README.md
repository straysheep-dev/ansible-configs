rootkit_detection
=========

Installs, runs, and maintains tools for rootkit detection. Currently this includes the following:

- `rkhunter`
- `chkrootkit`

During scans and while initializing or updating the rkhunter database, results often go to stderr. The related tasks safely ignore these errors, and print the results using the debug module.

Requirements
------------

None.

Role Variables
--------------

Set this per-host or per-group in your inventory file.

- `run_scans: "false"`: Will initialize or **update the existing database** (default)
- `run_scans: "true"`: Scans the system **without updating the database**

*NOTE: Be sure the system is clean before updating the database.*

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

MIT

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)
