build_wireguard_server
===================

Deploy a wireguard server using a fork of [angristan/wireguard-install](https://github.com/straysheep-dev/wireguard-install) and generate one client configuration file. This server also has the following features:

- Record traffic over the `wg0` interface using [pcap-service](https://github.com/straysheep-dev/linux-configs/blob/main/pcap-service.sh) for later analysis with [RITA](https://github.com/activecm/rita)
- `ufw` is enabled by default with additional rules to work with wireguard
- Logging and monitoring with `auditd`, `aide`, and `rkhunter`/`chkrootkit`

### Retrieving Wireguard QR Codes

This can be done remotely by passing ssh the `qrencode` command to read the client config file:
```bash
ssh root@${SERVER_PUB_IP} "qrencode -t ansiutf8 -l L < ~/wg0-*.conf; cat ~/wg0-*.conf"
```

### Automating interactive scripts

This is achieved by [defining the variables typically assigned through user input, in the ansible task or shell script instead](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_environment.html), then calling the script. For example:

```
# For pcap-service.sh
- name: Start pcap-service network monitoring
  ansible.builtin.shell:
    cmd: /usr/local/bin/pcap-service.sh
  environment:
    PCAP_PATH: /var/log/pcaps
    CAP_IFACE_CHOICE: wg0
    DAYS: 90
  become: yes
  become_method: sudo
```

The `wireguard-install.sh` script needed a few modifications, but largely this is handled by adding a section that puts all of the default values into variables for us, similar to how [`openvpn-install.sh`](https://github.com/angristan/openvpn-install/blob/5a4b31bd0d711da5df5febc944167b3cdb0a28bf/openvpn-install.sh#L614) does this.

```bash
# For wireguard-install.sh
if [[ $AUTO_INSTALL == "y" ]]; then
	export DEBIAN_FRONTEND=noninteractive
	SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
	SERVER_WG_NIC='wg0'
	SERVER_WG_IPV4='10.66.66.1'
	SERVER_WG_IPV6='fd42:42:42::1'
	SERVER_PORT=$(shuf -i49152-65535 -n1)
	CLIENT_DNS_1="$SERVER_WG_IPV4"
	CLIENT_DNS_2="$CLIENT_DNS_1"
	ALLOWED_IPS="0.0.0.0/0,::/0"
	CLIENT_NAME='01'
fi
```

### DNS

If you're running your own DNS resolver on the server (such as `unbound` or `stubby`) be sure to use the `wg0` interface IP addresses as your DNS server and not localhost or a public server when specifying the DNS servers.

When using `unbound`, be sure the wireguard interface IP and subnet are allowed. The example file below is created under `/etc/unbound/unbound.conf.d/unbound-acl.conf` if `unbound` is enabled.

```conf
server:
        interface: 10.66.66.1
        interface: fd42:42:42::1
        access-control: 10.66.66.0/24 allow
        access-control: fd42:42:42::1/64 allow
```

### Firewall

`ufw` is often deployed in cloud environment by default, and it's easy to interact with. For this reason we'll prefer using `ufw` directly to make any additional allowances not already added by the PostUp / PostDown `iptables` commands in `/etc/wireguard/wg0.conf`.

The minimum set of additional rules required when `ufw` is in it's default enabled state are:

```bash
source /etc/wireguard/params
sudo ufw allow from any to any port "$SERVER_PORT" proto udp comment 'wg vpn'
sudo ufw allow in on wg0 to "$SERVER_WG_IPV4" from "$SERVER_WG_IPV4"/24 comment 'wg dns'
sudo ufw allow in on wg0 to "$SERVER_WG_IPV6" from "$SERVER_WG_IPV6"/64 comment 'wg dns'
```

Running `sudo ufw status verbose` we get (assuming ssh has already been added):

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
60265/udp                  ALLOW IN    Anywhere                   # wg vpn
10.66.66.1 on wg0          ALLOW IN    Anywhere                   # wg dns
22/tcp (v6)                ALLOW IN    Anywhere (v6)
60265/udp (v6)             ALLOW IN    Anywhere (v6)              # wg vpn
```

Requirements
------------

Any cloud provider will work. This role was built and tested using the following Digital Ocean and AWS images:

- `image = "ubuntu-22-04-x64"` (Digital Ocean)
- TO DO

You can provision as little as:

- `1vcpu`
- `1gb RAM`

Role Variables
--------------

The following components have environment variables that use default values in the scripts they call. Change them in these places if you need to.

- `tasks/build-wireguard-server.yml` Task name: "Start pcap-service network monitoring"
	- `PCAP_PATH: /var/log/pcaps` Where to write the pcap files, typically /var/log/ works best as a base path
	- `CAP_IFACE_CHOICE: wg0` The wireguard server interface, default is usually `wg0` if the server is only running one wireguard interface
	- `DAYS: 90` How long to maintain pcap files for, uses `find $PCAP_PATH -type f -mtime +$DAYS -delete` to delete files older than `$DAYS`
- `files/wireguard-install.sh` + `tasks/build-wireguard-server.yml` Task name: "Run wireguard automated install"
	- `AUTO_INSTALL: y` Enables the use of all default variables in `files/wireguard-install.sh`, these variables are noted in the `installQuestions` function
	- The dynamically generated variables are still dynamic (public IP address)
	- It will generate a vpn configuration for `wg0-client-01.conf`

Dependencies
------------

*This playbook assumes you've used terraform to setup the server and ansible is installed either locally or remotely, depending on how you want to run it.*

Example Playbook
----------------

In many cases you'll be provisioning cloud infrastructure as root. You can run without `-b` or `--ask-become-pass` since nearly all of these tasks require root permissions anyway.

Uncomment the following lines in `playbook.yml`:

- `#    - role: "install_unbound"`
- `#    - role: "build_wireguard_server"`

```bash
ansible-playbook -i inventory/inventory.ini -v playbook.yml
```

## Use Case: Windows Sandbox + Wireguard

Windows Sandbox is a highly configurable and lightweight virtual environment, but it doesn't have as many options for networking as a standard Hyper-V VM.

You could easily deploy a server (either as a standalone VPN or as part of a larger VPS network) and connect a Windows Sandbox instance to it using the automatically generated client details.

First run these commands from WSL to deploy the server:

```bash
git clone https://github.com/straysheep-dev/terraform-configs
git clone https://github.com/straysheep-dev/ansible-configs
cd terraform-configs/some-folder
terraform init
terraform plan -out=infra.plan
terraform apply "infra.plan"
cd ../../ansible-configs
# modify playbook.yml to unclude the necessary roles
# modify inventory/inventory.ini to point to your new server
ansible-playbook -i inventory/inventory.ini -v playbook.yml
ssh root@${SERVER_PUB_IP} "qrencode -t ansiutf8 -l L < ~/wg0-*.conf; cat ~/wg0-*.conf"
```

Then either put this into a `.wsb` configuration file or paste it into a PowerShell session in Windows Sandbox. From there you can add your client details and connect.

```powershell
cd $env:TEMP; iwr https://download.wireguard.com/windows-client/wireguard-installer.exe -OutFile wireguard-installer.exe; .\wireguard-installer.exe
```

License
-------

MIT

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)
