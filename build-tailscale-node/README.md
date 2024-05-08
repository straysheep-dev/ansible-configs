build-tailscale-node
====================

Builds a tailscale node and adds it to a tailnet if an authkey encrypted variable is present.

Additonal options include:

- Building an exit node (vpn)
- Recording essential data of `tailscale0` interface to pcap files for IDS, IPS, or IR
- If `unbound` DNS is running, adds the tailnet and interface to its ACL list (TO DO)

Requirements
------------

An existing tailnet. Create one (free for personal use) at https://login.tailscale.com/start.

If you plan on deploying an exit node, ensure your ACL file contains something [like the following](https://tailscale.com/kb/1337/acl-syntax#subnet-routers-and-exit-nodes) using the `"autogroup:internet:*"` ACL assignment:

```json
<SNIP>
  "acls": [
    // all employees can use exit nodes
    { "action": "accept", "src": ["group:employees"], "dst": ["autogroup:internet:*"] },
  ],
<SNIP>
```

*NOTE: Currently, you cannot restrict which exit node is used when `autogroup:internet` is assigned. See [this issue](https://github.com/tailscale/tailscale/issues/1567) for details.*

Role Variables
--------------

### tailscale_authkey

This variable should exist in an encrypted ansible-vault file (e.g. auth.yml). Set a value to automatically enroll the node into your tailnet. See [deploying tailscale to a large fleet of devices](https://tailscale.com/kb/1023/troubleshooting#how-do-i-deploy-tailscale-to-a-large-fleet-of-devices) for more details.

```conf
tailscale_authkey: "tskey-abcdef0123456789"
```

### is_exit_node

Set `is_exit_node` to `True` to enable packet forwarding in the kernel.

```conf
is_exit_node: "True"
```

### pcap_service Settings

Set values for the interface monitoring service to do IDS, IPS, or IR on tailscale traffic.

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