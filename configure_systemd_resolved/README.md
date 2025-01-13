configure_systemd_resolved
=========

This role configures systemd-resolved to use DNS over TLS with the resolver(s) of your choice defined in `defaults/main.yml`. By default this includes Cloudflare and Quad9. Options for Google and NextDNS are also available. This role also disables LLMNR and MulticastDNS.


### DNS Setup

**Cloudflare**

- [Setup](https://developers.cloudflare.com/1.1.1.1/encryption/dns-over-tls/)
- [Verify](https://one.one.one.one/help)

**Quad9**

- [Setup](https://docs.quad9.net/services/)
- [Verify](https://docs.quad9.net/FAQs/)

**Google**

- [Setup](https://developers.google.com/speed/public-dns/docs/dns-over-tls)
- [Verify](https://developers.google.com/speed/public-dns/docs/using#testing)

**NextDNS**

- [Profile](https://nextdns.io/)
- [Setup](https://github.com/nextdns/nextdns/wiki/pfSense)
- [Verify](https://test.nextdns.io/)


### NetworkManager & auto-dns

You'll notice if you check your current DNS resolvers with:

```bash
resolvectl status
```

...that even if you set `ignore-auto-dns` using:

```bash
nmcli connection modify "$CONNECTION_NAME" ipv4.dns "127.0.0.53"
nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns "yes"
nmcli connection modify "$CONNECTION_NAME" ipv6.dns "::1"
nmcli connection modify "$CONNECTION_NAME" ipv6.ignore-auto-dns "yes"
```

...the DNS servers obtained from DHCP are still listed per-link. However, as long as this role runs and modifies `/etc/resolv.conf` to point to the stub resolver running locally, you should *only* see the servers specfied under `/etc/systemd/resolved.conf` listed in the global section of `resolvectl status`. **This seems to be the most important setting here**.

Review queries with tcpdump in one window:

```bash
sudo tcpdump -i eth0 -n -vv -Q out port 853
```

...and making the query in another window:

```bash
resolvectl query github.com
```

Interestingly, there will be a consistent "ping" to the DNS servers DHCP lists, and in the case of this role the ping will be trying to hit port 853/tcp of those servers. Ideally this isn't a problem, but this will need further investigation since this is still happening despite the settings to ignore and override these DNS servers have been made. It *appears* as though NetworkManger is just trying to check if they respond, rather than use them.

Requirements
------------

If installing in WSL, ensure you have [WSL2 with systemd](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#systemd-support).

```powershell
# Will install WSL2 by default
wsl --install
```

If upgrading an existing WSL install:

```powershell
wsl --update
wsl --shutdown
wsl --status
wsl
```

Create `/etc/wsl.conf` within you WSL instance if it's missing, add the following lines:

```
[boot]
systemd=true
```

Role Variables
--------------

You'll want to set these in your inventory files.

- `dns_resolvers: ["cloudflare", "quad9"]` List of DNS resolvers to use. NextDNS requires a profile string. Options: google, cloudflare, quad9, nextdns
- `nextdns_profile: null` Replace `null` with your NextDNS profile ID string in quotes.


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
    - role: "configure_systemd_resolved"
```

Have the `configure_systemd_resolved/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs