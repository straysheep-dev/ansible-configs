build_tailscale_node
====================

Builds a tailscale node and adds it to a tailnet if an authkey encrypted variable is present.

- Check [github.com/tailscale](https://github.com/tailscale/tailscale/blob/main/scripts/installer.sh) for the latest installer file.

```bash
# Pull the latest installer script
cd ./ansible-configs/build_tailscale_node/files || exit 1
curl -Lf https://github.com/tailscale/tailscale/raw/refs/heads/main/scripts/installer.sh > tailscale-installer.sh
```

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

*NOTE: Currently, you cannot restrict which exit node is used when `autogroup:internet` is assigned, but the endpoint can choose which exit node to route all traffic over. In most cases, you'll need admin or GUI access on the endpoint to set or change this.  See [this issue](https://github.com/tailscale/tailscale/issues/1567) for details.*

Role Variables
--------------

Set these in your inventory file.

- `tailscale_authkey`: This should exist *per-host* in an encrypted ansible-vault file (e.g. auth.yml) to automatically enroll the node into your tailnet.
  - See [deploying tailscale to a large fleet of devices](https://tailscale.com/kb/1023/troubleshooting#how-do-i-deploy-tailscale-to-a-large-fleet-of-devices) for more details.
  - *The related task has `no_log: True` to prevent the auth keys from being written to logs and stdout.*
- `modify_firewall`: Set to `"true"` to ensure the firewall is up and SSH inbound is allowed, default is `"false"`
- `is_exit_node`: Set to `"true"` to enable packet forwarding in the kernel.
- `pcap_service`: Set values for the interface monitoring service on tailscale0.

```conf
pcap_service_enable: "true"               # True or False
pcap_service_retention_days: 90           # 90 days is a good default, pcaps are not capturing the data payload to save disk space
pcap_service_cap_iface: tailscale0        # Default tailscale interface
pcap_service_pcap_path: /var/log/pcaps    # Desired path *without a trailing slash*
```

Example vault:

```yml
client01_tsauthkey: "tskey-abcdef0123456789abcdef0123456789"
server01_tsauthkey: "tskey-abcdef0123456789abcdef0123456789"
```

Example inventory:

```yml
managed_group:
  hosts:
    172.16.20.20:
      ansible_port: 22
      ansible_user: user
      tailscale_authkey: "{{ client01_tsauthkey }}"
    172.16.20.21:
      ansible_port: 22
      ansible_user: server
      tailscale_authkey: "{{ server01_tsauthkey }}"
      is_exit_node: "true"
      pcap_service_enabled: "true"
      pcap_service_retention_days: 90
      pcap_service_cap_iface: tailscale0
      pcap_service_pcap_path: /var/log/pcaps
  vars:
      is_managed: "true"
```

Dependencies
------------

None.

Example Playbook
----------------

```yml
- name: "Default Playbook"
  hosts: managed_group
  roles:
    - role: "build_tailscale_node"
```

With unique authkey variables per-host in `auth.yml`:

```bash
ansible-playbook -i <inventory> -e "@auth.yml" --vault-pass-file <(cat <<<$ANSIBLE_VAULT_PASSWORD) -v ./playbook.yml
```

License
-------

- MIT
- [BSD-3-Clause](https://github.com/tailscale/tailscale/blob/main/scripts/installer.sh)

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)
