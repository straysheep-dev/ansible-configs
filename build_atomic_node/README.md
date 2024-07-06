build_atomic_node
=========

This role automates the following items:

- Deploys the [Atomic Red Team testing framework](https://github.com/redcanaryco/invoke-atomicredteam/wiki) to a "tester" node
- Configures "target" nodes to run tests against

This is achieved using [PSRemoting over SSH](https://github.com/redcanaryco/invoke-atomicredteam/wiki/Execute-Atomic-Tests-(Remote)#configure-powershell-remoting-over-ssh), so the framework can run tests across Windows, macOS, and Linux targets (with PowerShell 7.X+ available), from a single "tester" node where the framework files exist.

This role was tested using a combination of Linux and Windows nodes.

### Usage

[Import the module](https://github.com/redcanaryco/invoke-atomicredteam/wiki/Import-the-Module#import-the-module) (on a Linux tester node):

```powershell
Import-Module "/root/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1" -Force
```

Create an SSH key and distribute the public key to each target node.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""

# Append this to ~/.bashrc
if [ -f $HOME/.ssh/id_ed25519 ]; then
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_ed25519
fi

cat ~/.ssh/id_ed25519.pub
```

Copy the public key content to each target node's authorized_keys file.

*TIP: You could do this with the [manage_keys](https://github.com/straysheep-dev/ansible-configs/tree/main/manage_keys) role.*

Open a PSRemoting Session from the "tester" node on the "target" node(s):

```powershell
$sess = New-PSSession -HostName <target-ip> -Username root -KeyFilePath ~/.ssh/id_ed25519
```

To execute all Linux rootkit tests againts the remote target:

```powershell
Invoke-AtomicTest T1014 -ShowDetailsBrief -Session $sess
Invoke-AtomicTest T1014 -GetPrereqs -Session $sess
Invoke-AtomicTest T1014 -CheckPrereqs -Session $sess
Invoke-AtomicTest T1014 -Session $sess
```

Requirements
------------

PowerShell 7.X or later must be installed on ALL nodes.

Role Variables
--------------

Use your inventory file to define these.

- `is_tester: "false"`: Set to `"true"` to install the Invoke-AtomicRedTeam execution framework and all atomic tests onto the node.
- `is_target: "false"`: Set to `"true"` to configure PSRemoting over SSH, to use the node as a target.

Example inventory with example group names:

```ini
[tester_nodes]
192.168.0.20:22 ansible_user=root

[tester_nodes:vars]
is_tester="true"

[target_nodes]
10.10.10.70:22 ansible_user=root
10.10.10.71:22 ansible_user=root
10.10.10.72:22 ansible_user=root

[target_nodes:vars]
is_target="true"
```

Dependencies
------------

This role depends on the `install_powershell` and `configure_microsoft_repos` roles.

To summarize:

`configure_microsoft_repos` obtains the Microsoft package signing key, checks its fingerprint, and sets the package manager's priority for either your system's default repos or Microsoft's repos depending on what you configure for `prioritize_microsoft_feed="true|false"`.

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