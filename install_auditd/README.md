install_auditd
=========

Installs and configures `auditd` to adhear to a specified policy on Debian / RedHat family systems.

Optionally installs [`laurel`](https://github.com/threathunters-io/laurel) to post-process logs into JSON.

This role is designed to be run multiple times during the install process, in the event policies need revised when rules fail to load.

If you do not supply your own rule file(s), then one of the premade compliance rulesets that ship with auditd can be specified in the `./vars/main.yml` file.

Requirements
------------

- root / sudo access to the remote hosts.
- Your own `40-[policy].rules` file(s) if you have your own policy to install

*If you do supply your own rule file(s), they must contain the following:*

[10-base-config.rules](https://github.com/linux-audit/audit-userspace/blob/master/rules/10-base-config.rules):
```conf
## First rule - delete all
-D

## Increase the buffers to survive stress events.
## Make this bigger for busy systems
-b 8192

## This determine how long to wait in burst of events
--backlog_wait_time 60000

## Set failure mode to syslog
-f 1
```

[99-finalize.rules](https://github.com/linux-audit/audit-userspace/blob/master/rules/99-finalize.rules):
```conf
## Make the configuration immutable - reboot is required to change audit rules
#-e 2
```

*NOTE: This role will uncomment the `#-e 2` line automatically in any files it finds under /etc/audit/rules.d/ that have the line present. It does not modify the source files.*

The variable `install_ruleset_plus_base` in `./vars/main.yml` can be set to `enabled` if your custom rule files do not include these lines and you want this ansible role to install them using the premade copies that ship with auditd.

Role Variables
--------------

Adjust the values in `./vars/main.yml` to fit your requirements.

- `install_ruleset: "local|stig|pci|ospp"`: Choose one. Change this to "local" if you have your own 40-*.rules file(s), otherwise choose a premade set
- `install_ruleset_plus_base: "enabled|disabled"`: If you're supplying your own "local" rules but they're missing the [10-base-config.rules](https://github.com/linux-audit/audit-userspace/blob/master/rules/10-base-config.rules) and [99-finalize.rules](https://github.com/linux-audit/audit-userspace/blob/master/rules/99-finalize.rules) lines, set this to "enabled"
- `default_rules_path: /etc/audit/rules.d/`: Change this if yours is different
- `log_format: "ENRICHED"`: ENRICHED or RAW, ENRICHED writes logs to be human readable, but consumes more disk space
- `max_log_file: "8"`: File size in MB, 8 is good - higher sizes result in slow read times
- `num_logs: "10"`: Number of log files, 10 is fine if shipping logs to a SIEM, use 50 or more if storing them locally


### Laurel Options

- `install_laurel: "true|false"`: Set to true to install laurel
- `laurel_binary_type: "musl|glibc"`: Choose between the statically linked musl version, or the dynamically linked glibc version

Dependencies
------------

None.

Example Playbook
----------------

Uncomment the following lines in `playbook.yml`:

- `#    - role: "install_auditd"`

```bash
ansible-playbook -i inventory/inventory.ini --ask-become-pass -v playbook.yml
```

If `augenrules --check; augenrules --load` has any issues, the play will fail with a non-zero return code.

If this happens investigate manually:

- Run `augenrules --check; augenrules --load` (running the playbook with `-v` also works here)
- Review the lines in `/etc/audit/audit.rules`
- **Make revisions to the files in `/etc/audit/rules.d/` or your local rule files**
- Run `ansible-playbook -i inventory/inventory.ini --ask-become-pass -v playbook.yml` again and check for additional errors

License
-------

MIT
[BSD](https://github.com/IppSec/parrot-build/tree/master/roles/configure-logging#license)

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)
