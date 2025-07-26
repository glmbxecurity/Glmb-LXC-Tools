# Glmb-LXC-Tools
Tools for managing LXC, such creating networks, creating lxc's and assigning networks

# LXC Container and Network Management Tools for Linux

This repository contains a set of scripts designed to simplify the creation, management, and deletion of LXC containers and their network bridges on Linux systems (tested on Linux Mint).

These tools aim to quickly and modularly build complex infrastructures and testing labs based on LXC containers, automating common administration tasks and network configuration.

---

## Included Scripts

| Script                  | Description                                                                                  |
|-------------------------|----------------------------------------------------------------------------------------------|
| `network-lxc-creator.sh`| Creates network bridge interfaces (`lxcbr1`, `lxcbr2`, etc.) with configured IPs for container networking. |
| `network-lxc-delete.sh` | Removes the created network bridge interfaces, except the default `lxcbr0`.                 |
| `lxc_creator.sh`        | Interactive script to create LXC containers by choosing distribution, version, and assigning network bridges. |
| `lxc_delete.sh`         | Lists existing containers and allows deleting them individually or all at once.             |

---

## Key Features

- Modular: Choose how many network bridges to create or delete.
- Flexible: Interactive selection of supported distributions and releases.
- Supports assigning multiple network bridges per container.
- Simple and safe container creation and deletion.
- Automates repetitive tasks for lab environments and testing setups.

---

## Requirements

- Linux system with LXC installed (tested on Linux Mint).
- Root privileges to create network interfaces and containers.
- Internet connection to download container templates.

---

## Basic Usage

Run the scripts with root privileges (`sudo`) to manage network bridges and containers:

```bash
sudo ./network-lxc-creator.sh    # Create network bridges
sudo ./lxc_creator.sh            # Create LXC containers
sudo ./lxc_delete.sh             # Delete LXC containers
sudo ./network-lxc-delete.sh    # Delete network bridges

