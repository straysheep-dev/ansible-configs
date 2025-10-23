# ansible-configs

![ansible-lint workflow](https://github.com/straysheep-dev/ansible-configs/actions/workflows/ansible-lint.yml/badge.svg) ![shellcheck workflow](https://github.com/straysheep-dev/ansible-configs/actions/workflows/shellcheck.yml/badge.svg)

A collection of ansible roles.

This repo was created after seeing [IppSec's parrot-build](https://github.com/IppSec/parrot-build) and wanting to make my own bash scripts more reliable and scalable.

> [!NOTE]
> The expanded notes previously in this README have moved to a dedicated post: [straysheep.dev/blog/ansible](https://straysheep.dev/blog/2023/08/20/simple-ansible-ansible/).


## Cloning

Each role is being split off into its own repo (submodule) for easier maintenance and CI with molecule.

> [!IMPORTANT]
> Using `--recursive` with submodules will operate on all nested submodules.

To clone just this repo and the roles without the nested Docker submodules over SSH:

```bash
# Using SSH authenticated to your GitHub account
git clone git@github.com:straysheep-dev/ansible-configs.git
cd ansible-configs
# Initialize all submodules, you'd do this to pull the latest changes as well
git submodule update --init --checkout
git submodule sync
```

To clone just this repo and the roles without the nested Docker submodules over HTTPS:

```bash
# Point to HTTPS instead of SSH, unauthenticated without a GitHub account
git clone https://github.com/straysheep-dev/ansible-configs.git
cd ansible-configs
git -c url.https://github.com/.insteadof=ssh://git@github.com/ \
    -c url.https://github.com/.insteadof=git@github.com: \
    submodule update --init --checkout \
    git submodule sync
# Set the change for each submodule at the project level after initializing
git submodule foreach \
    'git config url.https://github.com/.insteadof ssh://git@github.com/
    git config url.https://github.com/.insteadof git@github.com:'
```

When updating a (super)project's submodules to point to the latest changes:

```bash
# --remote will pull in the latest changes of submodules
git submodule update --remote [--recursive]
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
