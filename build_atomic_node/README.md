build_atomic_node
=========

This role automates the following items:

- Deploys the [Atomic Red Team PowerShell testing framework](https://github.com/redcanaryco/invoke-atomicredteam/wiki) to a "tester" node
- Configures "target" nodes to run tests against

This is achieved using [PSRemoting over SSH](https://github.com/redcanaryco/invoke-atomicredteam/wiki/Execute-Atomic-Tests-(Remote)#configure-powershell-remoting-over-ssh), so the "tester" node hosting the framework can run tests across Windows, macOS, and Linux targets (where PowerShell 7.X+ is available).

This role was tested using a combination of Linux and Windows nodes.

*NOTE: This role uses an absolute path to `pwsh.exe` on Windows. This will need revised when PowerShell's major version number changes. `pwsh.exe` should be added to your `$env:PATH` by default, but sometimes it's missing.*

### Usage

With the resources provisioned, create an SSH keypair just for testing if you already haven't.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/atomic_testing.key -q -N ""
```

Copy the private and public keys into `manage_keys/files/` of the [manage_keys](https://github.com/straysheep-dev/ansible-configs/tree/main/manage_keys) role directory.

Set `is_manager="true"` for "tester" nodes and `is_managed="true"` for the "target" nodes groups (see the example inventory file below under Requirements).

Once the keys are distributed, SSH into the tester node.

[Import the module](https://github.com/redcanaryco/invoke-atomicredteam/wiki/Import-the-Module#import-the-module) (on a Linux tester node):

```powershell
Import-Module "/root/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1" -Force
```

In case your `ssh-agent` isn't running in your current session, you can start it and add your private key with:

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/atomic_testing.key
```

[Open a PSRemoting Session from the "tester" node *to* the "target" node(s)](https://github.com/redcanaryco/invoke-atomicredteam/wiki/Execute-Atomic-Tests-(Remote)#establish-a-ps-session-from-windows-to-windows):

```powershell
$sess = New-PSSession -HostName <target-ip> -Username root -KeyFilePath ~/.ssh/atomic_testing.key
```

To execute all Linux rootkit tests against the remote target:

```powershell
Invoke-AtomicTest T1014 -ShowDetailsBrief -Session $sess
Invoke-AtomicTest T1014 -GetPrereqs -Session $sess
Invoke-AtomicTest T1014 -CheckPrereqs -Session $sess
Invoke-AtomicTest T1014 -Session $sess
```

Requirements
------------

PowerShell 7.X or later must be installed on ALL nodes. This role lists [install_powershell](https://github.com/straysheep-dev/ansible-configs/tree/main/install_powershell) as a dependancy, which will ensure each endpoint has the latest PowerShell version.

Ensure Windows endpoints are using the latest OpenSSH package. If you installed OpenSSH Sever through Windows Optional Features and are having issues restarting sshd after adding the line enabling the subsystem for PowerShell to sshd_config, try the OpenSSH package from winget. You can do this with [Manage-OpenSSHServer.ps1](https://github.com/straysheep-dev/windows-configs/blob/main/Manage-OpenSSHServer.ps1).

Role Variables
--------------

Use your inventory file to define these either per-host or per-group.

- `is_tester: "false"`: Set to `"true"` to install the Invoke-AtomicRedTeam execution framework **and all atomic tests** onto the node.
- `is_target: "false"`: Set to `"true"` to configure PSRemoting over SSH, to use the node as a target.

Example inventory with example group names:

```ini
[tester_nodes]
192.168.0.20:22 ansible_user=root

[tester_nodes:vars]
is_tester="true"
is_manager="true"

[target_nodes]
10.10.10.70:22 ansible_user=root
10.10.10.71:22 ansible_user=root
10.10.10.72:22 ansible_user=root

[target_nodes:vars]
is_target="true"
is_managed="true"
```

Dependencies
------------

This role depends on the [install_powershell](https://github.com/straysheep-dev/ansible-configs/tree/main/install_powershell) and [configure_microsoft_repos](https://github.com/straysheep-dev/ansible-configs/tree/main/configure_microsoft_repos) roles.

To summarize:

`configure_microsoft_repos` obtains the Microsoft package signing key, checks its fingerprint, and sets the package manager's priority for either your system's default repos or Microsoft's repos depending on what you configure for `prioritize_microsoft_feed="true|false"`. You can safely leave this at the default of `"false"` for this use case.

`install_powershell` does just that, the latest version will be pulled from Microsoft's Linux repo or winget on Windows.

Example Playbook
----------------

```yml
- name: "Default Playbook"
  hosts: all
    #tester_nodes
    #target_nodes
  roles:
    - role: "build_atomic_node"
```

Execute with:

```bash
ansible-playbook -i ./inventory.ini -v ./playbook.yml
```

License
-------

- MIT (straysheep-dev)
- [MIT (redcanaryco)](https://github.com/redcanaryco/invoke-atomicredteam/blob/master/LICENSE.txt)

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs