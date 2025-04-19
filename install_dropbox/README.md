install_dropbox
=========

- <https://www.dropbox.com/install-linux>
- <https://help.dropbox.com/installs/linux-commands>
- [Dropbox Package Repo](https://linux.dropbox.com/) (pull `.deb`, `.rpm`, and `.py` files directly from here)
- [dropbox.py](https://linux.dropbox.com/packages/dropbox.py) (this is essentially the only thing needed, it installs the `dropboxd` binary)
- <https://github.com/dropbox/nautilus-dropbox>
- [Dropbox Public Key](https://linux.dropbox.com/fedora/rpm-public-key.asc) (also embedded within `Dropbox.py`)

Dropbox is officially supported on Ubuntu, Fedora, and Debian.

> [!TIP]
> You'll need `python3-gpg` for the Dropbox daemon to verify binary signatures. No matter how you install Dropbox, it first installs the [dropbox.py](https://linux.dropbox.com/packages/dropbox.py) CLI utility, which is used to install and manage the `dropboxd` binary separet from `apt` or `dnf`. `dropboxd` always gets installed in the user's `$HOME` folder. Once `python3-gpg` is installed `dropbox.py` won't warn you about this anymore.

You'll also need to run the following after installing the `.deb` package initially (which targets Ubuntu desktop environments):

```bash
nautilus --quit
```

This is [the public signing key for Dropbox](https://linux.dropbox.com/fedora/rpm-public-key.asc):

```txt
pub   rsa2048/0xFC918B335044912E 2010-02-11 [SC]
      Key fingerprint = 1C61 A265 6FB5 7B7E 4DE0  F4C1 FC91 8B33 5044 912E
uid                   [ unknown] Dropbox Automatic Signing Key <linux@dropbox.com>
```

Pull it from a keyserver for cross-verification, like this: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x1c61a2656fb57b7e4de0f4c1fc918b335044912e


## Deb Package Install

The `.deb` package configures `apt` to install and manage updates for the [`dropbox.py` script](https://linux.dropbox.com/packages/dropbox.py). Here's how you can discover this information:

- Obtain the [Dropbox signing key directly from Dropbox](https://linux.dropbox.com/fedora/rpm-public-key.asc)
- Install the `.deb` package
- Review the additions to `apt` to obtain the Dropbox repo information, and ultimately replicate it using Ansible

These are the files the `.deb` package installs to configure `apt`:

First, `/etc/apt/sources.list.d/dropbox.list`.

```txt
deb [arch=i386,amd64 signed-by=/etc/apt/keyrings/dropbox.asc] http://linux.dropbox.com/ubuntu noble main
```

Next, `/etc/apt/keyrings/dropbox.asc`.

```txt
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.9 (GNU/Linux)

mQENBEt0ibEBCACv4hZRPqwtpU6z8+BB5YZU1a3yjEvg2W68+a6hEwxtCa2U++4d
zQ+7EqaUq5ybQnwtbDdpFpsOi9x31J+PCpufPUfIG694/0rlEpmzl2GWzY8NqfdB
FGGm/SPSSwvKbeNcFMRLu5neo7W9kwvfMbGjHmvUbzBUVpCVKD0OEEf1q/Ii0Qce
kx9CMoLvWq7ZwNHEbNnij7ecnvwNlE2MxNsOSJj+hwZGK+tM19kuYGSKw4b5mR8I
yThlgiSLIfpSBh1n2KX+TDdk9GR+57TYvlRu6nTPu98P05IlrrCP+KF0hYZYOaMv
Qs9Rmc09tc/eoQlN0kkaBWw9Rv/dvLVc0aUXABEBAAG0MURyb3Bib3ggQXV0b21h
dGljIFNpZ25pbmcgS2V5IDxsaW51eEBkcm9wYm94LmNvbT6JATYEEwECACAFAkt0
ibECGwMGCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRD8kYszUESRLi/zB/wMscEa
15rS+0mIpsORknD7kawKwyda+LHdtZc0hD/73QGFINR2P23UTol/R4nyAFEuYNsF
0C4IAD6y4pL49eZ72IktPrr4H27Q9eXhNZfJhD7BvQMBx75L0F5gSQwuC7GdYNlw
SlCD0AAhQbi70VBwzeIgITBkMQcJIhLvllYo/AKD7Gv9huy4RLaIoSeofp+2Q0zU
HNPl/7zymOqu+5Oxe1ltuJT/kd/8hU+N5WNxJTSaOK0sF1/wWFM6rWd6XQUP03Vy
NosAevX5tBo++iD1WY2/lFVUJkvAvge2WFk3c6tAwZT/tKxspFy4M/tNbDKeyvr6
85XKJw9ei6GcOGHD
=5rWG
-----END PGP PUBLIC KEY BLOCK-----
```


## Headless Install

> [!NOTE]
> These instrustions are copied directly from: https://www.dropbox.com/install-linux. Remember, no matter how you installed dropbox.py, `dropboxd` is always installed in the user's `$HOME` folder. **This method doesn't have a way for you to verify the signatures of what you're downloading before running it.**

Dropbox Headless Install via command line. The Dropbox daemon is only compatible with 64-bit Linux servers. To install, run the following command in your Linux terminal.

```bash
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
```

Next, run the Dropbox daemon from the newly created `.dropbox-dist` folder.

```bash
~/.dropbox-dist/dropboxd
```


## Ansible Install

What this role was built to do. It adds the Dropbox repo information to `apt`, so you can install the Dropbox utilities on both desktops and servers using Dropbox's public key to verify the package before installing it.


## Authentication

> If you're running Dropbox on your server for the first time, you'll be asked to copy and paste a link in a working browser to create a new account or add your server to an existing account. Once you do, your Dropbox folder will be created in your home directory. Download the [Python script](https://linux.dropbox.com/packages/dropbox.py) to control Dropbox from the command line. For easy access, put a symlink to the script anywhere in your `$PATH`.

This role will print the authentication URL to the console when it's finished executing.

Requirements
------------

A recent version of Ubuntu, Fedora, and Debian.

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

playbook.yml:

```yml
- name: "Example Playbook"
  hosts:
    all
  roles:
    - role: "install_dropbox"
```

Have the `install_dropbox/` folder in the same directory as the `playbook.yml` file.

Run with: `ansible-playbook -i inventory.yml --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
