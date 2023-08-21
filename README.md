# ansible-configs

A collection of ansible roles.

This repo is both a set of various roles to mirror my own bash scripts, and my notes on using Ansible for easy reference.

It's structured to be easy to clone, modify, and run only the roles you need. In most cases all you need to change is:

- `playbook.yml`'s roles
- Your preferred `inventory/` file's hosts + users

Use whichever inventory format works best for you. The `.ini` files allow specifying users as inline variables per host, which is useful if each host in a group has different users you'll be connecting as.

When you're done, run the playbook with:

```bash
ansible-playbook -i inventory/inventory.ini --ask-become-pass -v playbook.yml
```

- `--ask-become-pass` takes the sudo password for the remote user
- `-v` will show a useful amount of information without being too verbose

To do: how to specify different passwords for each remote host.


## Setup

Install Ansible, on Ubuntu:

- [Install Ansible via pip](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#ensuring-pip-is-available)
- [Ensure pip, setuptools, wheel are up to date](https://packaging.python.org/en/latest/tutorials/installing-packages/#ensure-pip-setuptools-and-wheel-are-up-to-date)
- [Install pip on Debian/Ubuntu](https://packaging.python.org/en/latest/guides/installing-using-linux-tools/#debian-ubuntu-and-derivatives)

If you're missing `pip`, the recommended way to install it on Ubuntu, or other Debian derivitives is through apt (Ansible's documentation also mentions the `python3-pip` package):

```bash
sudo apt update
sudo apt install python3-pip
```

Install Ansible using pip:

```bash
python3 -m pip install --user ansible
```

Upgrade Ansible:

```bash
python3 -m pip install --upgrade --user ansible
```


## References

This repo was inspired by, and created after learning from [IppSec's parrot-build](https://github.com/IppSec/parrot-build) repo and video.
