#!/bin/bash

# SPDX-License-Identifier: MIT

# Script to allow a "builder" user to import a packer image on Proxmox. It's meant to be
# deployed with a sudo exception, so the builder user can run it without root privileges.
# This is a draft that will need tested and updated over time.
#
# sudo /usr/local/bin/pve-import 102 ubuntu-server-24.04 build/ubuntu-server.qcow2 local-lvm

set -euo pipefail

# Requires 4 arguments
[[ $# -eq 4 ]] || { echo "Usage: pve-import <vmid> <name> <disk> <storage>"; exit 1; }

VMID="$1"
VMNAME="$2"
DISK="$3"
STORAGE="$4"

# Validate VMID string
[[ "$VMID" =~ ^[0-9]{3,6}$ ]] || { echo "Invalid VMID"; exit 1; }

# Validate VM name
[[ "$VMNAME" =~ ^[a-zA-Z0-9_.-]{1,32}$ ]] || { echo "Invalid VM name"; exit 1; }

# Validate DISK exists and is a regular file
[[ -f "$DISK" ]] || { echo "Disk image not found"; exit 1; }

# Allow-list STORAGE
[[ "$STORAGE" =~ ^(local|local[0-9]?-lvm|local[0-9]?-zfs|luks[0-9]?-lvm)$ ]] || { echo "Invalid storage"; exit 1; }

# Specify the ovmf BIOS for UEFI / SecureBoot options
qm create "$VMID" \
  --name "$VMNAME" \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --memory 4096 \
  --cores 4 \
  --kvm \
  --balloon 0 \
  --net0 virtio,bridge=vmbr0

qm importdisk "$VMID" "$DISK" "$STORAGE"

# Includes UEFI vars and TPM for SecureBoot
# Defaults to virtio driver, TODO: make this a variable
qm set "$VMID" \
  --efidisk0 "$STORAGE:1,efitype=4m,pre-enrolled-keys=1" \
  --tpmstate0 "$STORAGE:1,version=v2.0" \
  --virtio0 "$STORAGE:vm-$VMID-disk-0" \
  --boot order=virtio0

# qm template "$VMID"
