# ansible-configs

A collection of ansible roles.

This repo is both a set of various roles to mirror my own bash scripts, and my notes on using Ansible for easy reference.

It's structured to be easy to clone, modify, and run only the roles you need. In most cases all you need to change is:

- `playbook.yml`'s roles
- Your preferred `inventory/` file's hosts + users

Use whichever inventory format works best for you. The `.ini` files allow specifying users as inline variables per host, which is useful if each host in a group has different users you'll be connecting as.

Each inventory example connects to the ansible controller (the localhost of the machine you're running ansible from) by default. Modify these files to add your own remote connections.

When you're done, run the playbook with one of the following:

```bash
# For using sudo on the remote host, where you aren't using the root account
ansible-playbook -i inventory/inventory.ini [-b] --ask-become-pass -v playbook.yml

# For using the root account on the remote host, typically to deploy and provision cloud resources
ansible-playbook -i inventory/inventory.ini -v playbook.yml
```

- `-b` will automatically elevate all tasks so you don't need to specify "become sudo" across every task (don't do this unless you need to)
- `--ask-become-pass` takes the sudo password for the remote user
- `-v` will show a useful amount of information without being too verbose

To do: how to specify each remote user's password (if there are multiple remote users listed, each with a unique password).


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


## How Ansible Works

It's important to remember, for example, the `ansible.builtin.copy` module copies files *from* **the control node** *to* **managed nodes**, unless [`remote_src: yes`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html#parameter-remote_src) is set.

If `remote_src: yes` is set, `ansible.builtin.copy` will only use source paths on the remote host and not the control node.

Basically, *all tasks are typically executed on remote targets*. This means using `ansible.builtin.find` + registering a variable + `ansible.builtin.copy`, to copy arbitrary files *from* the control node won't work.

In that case, `ansible.builtin.find` will execute on the remote host, and not find the files. `ansible.builtin.copy` will attempt to use source paths on the remote host that don't exist instead of paths on the control node, causing this operation to fail.


## References

This repo was inspired by, and created after learning from [IppSec's parrot-build](https://github.com/IppSec/parrot-build) repo and video.
