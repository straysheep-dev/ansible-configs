# ansible-configs

![ansible-lint workflow](https://github.com/straysheep-dev/ansible-configs/actions/workflows/ansible-lint.yml/badge.svg) ![shellcheck workflow](https://github.com/straysheep-dev/ansible-configs/actions/workflows/shellcheck.yml/badge.svg)

A collection of ansible roles.

> [!NOTE]
> This repo started after seeing [IppSec's parrot-build](https://github.com/IppSec/parrot-build) and wanting to make my own bash scripts more reliable and scalable.
>
> The notes that were previously below are now maintained on [my blog entry focused on Ansible usage in general](https://straysheep.dev/blog/2023/08/20/simple-ansible-ansible/), while this README will cover interacting with this repo specifically. That post will be updated regularly with new notes.


## Cloning

Each role is being split off into its own repo (submodule) for easier maintenance and CI with molecule.

To clone everything, recursively:

```bash
# Clone this monorepo
git clone git@github.com:straysheep-dev/ansible-configs.git

# Pull in the latest pinned commits from all submodules
git submodule update --init --recursive
```


## Modifying

In most cases all you need to change are the roles, groups, and vault information you're using. You can (and should) have multiple playbooks, inventories, and to a lesser extent, vaults, as a way to maintain states of various groups of machines.

> [!TIP]
> **Example Files**
> - [`playbook.yml`](./playbook.yml) is an example playbook with comments documenting usage
> - [`debug.yml`](./debug.yml) is for debugging and developing individual tasks in isolation
> - [`auth.yml`](./auth.yml) is a plaintext sample of a vault file
> - [`inventory/`](./inventory/) has `.ini` and `.yml` examples and documentation for building inventories


## OpenSCAP Utils

The [inventory_openscap_utils](./inventory_openscap_utils/) folder has it's own [README](./inventory_openscap_utils/README.md).

It's effectively a set of scripts that provide a way to download and customize the existing Ansible playbooks related to STIG, CIS benchmarks, PCI-DSS, (and more) for system hardening without reinventing or needing to maintain forks of them. The reason here is, applying them without any modification will completely break a system in most cases. They're meant to be modified on a case-by-case basis for the system and environment. Custom forks were tried originally, but these playbooks are complex enough that this was necessary and has been a much easier way to maintain ready-to-use custom playbooks.

This is only possible due to Ansible tags, as the OpenSCAP playbooks tag all of their tasks. This makes it easy to tune and customize the existing playbooks available in the [ComplianceAsCode/content](https://github.com/ComplianceAsCode/content) project.


## License

[MIT](./LICENSE)
