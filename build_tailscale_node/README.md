build_tailscale_node
====================

Builds a tailscale node and adds it to a tailnet if an authkey encrypted variable is present.

Options:

- Set as an exit node (VPN)
- Recording filtered pcap data on `tailscale0`
- If `unbound` DNS is running, adds the tailnet and interface to its ACL list (TO DO)

Requirements
------------

An existing tailnet. [Create one free for personal use](https://login.tailscale.com/start).

If you plan on deploying an exit node, ensure your ACL file contains something [like the following](https://tailscale.com/kb/1337/acl-syntax#subnet-routers-and-exit-nodes) using the `"autogroup:internet:*"` ACL assignment:

```json
  "acls": [
    // all employees can use exit nodes
    { "action": "accept", "src": ["group:employees"], "dst": ["autogroup:internet:*"] },
  ],
```

*NOTE: Currently, you cannot restrict which exit node is used when `autogroup:internet` is assigned. See [this issue](https://github.com/tailscale/tailscale/issues/1567) for details.*

Role Variables
--------------

Adjust the values in `./vars/main.yml` to fit your requirements.

- `tailscale_authkey`: This should exist in an encrypted ansible-vault file (e.g. auth.yml) to automatically enroll the node into your tailnet.
  - See [deploying tailscale to a large fleet of devices](https://tailscale.com/kb/1023/troubleshooting#how-do-i-deploy-tailscale-to-a-large-fleet-of-devices) for more details.
  - *The related task has `no_log: True` to prevent the auth keys from being written to logs and stdout.*
- `is_exit_node`: Set to `True` to enable packet forwarding in the kernel.
- `pcap_service`: Set values for the interface monitoring service on tailscale0.

```conf
pcap_service_enable: "True"               # True or False
pcap_service_retention_days: 90           # 90 days is a good default, pcaps are not capturing the data payload to save disk space
pcap_service_cap_iface: tailscale0        # Default tailscale interface
pcap_service_pcap_path: /var/log/pcaps    # Desired path *without a trailing slash*
```

Dependencies
------------

None.

Example Playbook
----------------

With an authkey variable in `auth.yml`:

```bash
ansible-playbook -i inventory.ini --ask-vault-pass --extra-vars "@auth.yml" -v playbook.yml
```

Without an authkey:

```bash
ansible-playbook -i inventory.ini -v playbook.yml
```

License
-------

- MIT
- [BSD-3-Clause](https://github.com/tailscale/tailscale/blob/main/scripts/installer.sh)

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)