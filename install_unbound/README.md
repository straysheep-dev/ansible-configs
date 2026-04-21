install_unbound
=========

This role installs the Unboud DNS resolver with a hardened configuration file based on pfSense's defaults. It also enables DNS logging along with DNS over TLS to the DNS resolver(s) of your choice defined in `defaults/main.yml`. By default this includes Cloudflare and Quad9. Options for Google and NextDNS are also available.


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


### Reading Logs

You can follow logs with `tail` on Ubuntu:

```bash
sudo tail -f /var/log/syslog | grep 'unbound'
```

On systems without `/var/log/syslog` (like Kali or Rocky) you can follow unbound logs with `journalctl`:

```bash
sudo journalctl -u unbound -f
```

With the default apparmor profiles applied in both Ubuntu and Kali, you cannot change the logging destination to a file.

If apparmor is not enabled for unbound, you can change the following lines in `unbound.conf` to write logs to a file path:

```conf
	use-syslog: no
	logfile: "/var/log/unbound.log"
```

Then create the logfile:

```bash
sudo touch /var/log/unbound.log
sudo chown unbound:unbound /var/log/unbound.log
```

Finally restarting unbound:

```bash
sudo systemctl restart unbound
```


### MAC Enforcement

Debian/Ubuntu distros ship a dedicated AppArmor profile for Unbound. Rocky (10) on the other hand, seems to fall back to the default `named_t` policy on SELinux:

```bash
# Check what tags are assigned to the binary
ls -Z /usr/sbin/unbound

# Check what tags are assigned to unbound's process
ps -eZ | grep unbound
```

This is not huge issue, just worth noting.


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

Options: google, cloudflare, quad9, nextdns

```yaml
dns_resolvers: ["cloudflare", "quad9"]
```

Replace `null` with your `"<profile-string>"` (in quotes) and this role will point unbound's resolver to your NextDNS profile.

```yaml
nextdns_profile: null
```

OS-specific paths. Override in host_vars/group_vars if needed.

```yaml
unbound_confs_path: "{{ '/etc/unbound/unbound.conf.d' if ansible_os_family == 'Debian'
                         else '/etc/unbound/conf.d' if ansible_os_family == 'RedHat' }}"
```

OS-specific paths. Override in host_vars/group_vars if needed.

```yaml
unbound_tls_cert_bundle: "{{ '/etc/ssl/certs/ca-certificates.crt' if ansible_os_family == 'Debian'
                              else '/etc/pki/tls/certs/ca-bundle.crt' if ansible_os_family == 'RedHat' }}"
```

Same path on both Debian and RedHat families.

```yaml
unbound_root_key: "/var/lib/unbound/root.key"
```

Leave this blank if using AppArmor or SELinux. Most Debian and RedHat family distros use one or the other. Setting the chroot path to `""` effectively unsets it.

```yaml
unbound_chroot_path: '""'
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
  vars:
    dns_resolvers: ["nextdns"]
    nextdns_profile: "<my-profile-string>"
  roles:
    - role: "install_unbound"
```

Have the `install_unbound/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
