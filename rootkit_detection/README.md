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

One variable exists in `vars/main.yml` to set whether this role should scan nodes for rootkits *instead* of updating the database for `rkhunter`.

- `run_scans: "true|false"`, Set to true to just scan the system

Without setting `run_scans` to `"true"`, this role will *always* update the `rkhunter` database.

If `run_scans` is set to `"true"`, this role will not update the `rkhunter` database.

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
