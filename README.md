# Born2beRoot

A 42 School system administration project: setting up a virtual machine from scratch, hardened according to strict security rules, using either Debian or Rocky Linux.

This implementation uses **Debian**, with the mandatory LVM partitioning scheme.

## Table of Contents

- [Overview](#overview)
- [Virtual Machine Setup](#virtual-machine-setup)
- [Partitioning (LVM)](#partitioning-lvm)
- [Security Configuration](#security-configuration)
  - [Password Policy](#password-policy)
  - [sudo Configuration](#sudo-configuration)
  - [SSH Configuration](#ssh-configuration)
  - [Firewall (UFW)](#firewall-ufw)
- [User and Group Management](#user-and-group-management)
- [Monitoring Script](#monitoring-script)
- [Usage](#usage)
- [Defense Tips](#defense-tips)

## Overview

Born2beRoot's goal is to introduce the basics of system administration by building a secure virtual machine environment. The setup covers:

- Installing and configuring a Debian VM under VirtualBox (or UTM/other hypervisor)
- Using LVM (Logical Volume Manager) for disk partitioning
- Enforcing a strict password and sudo policy
- Hardening SSH access
- Configuring a firewall (UFW)
- Writing a custom bash script (`monitoring.sh`) that reports system status on a cron schedule

## Virtual Machine Setup

- **OS**: Debian (minimal/no-GUI install)
- **Hostname**: set to `<your_login>42` (adjust as required by your defense)
- **Disk encryption**: full disk encrypted (LVM on LUKS)
- **Hypervisor**: VirtualBox (or equivalent)

Basic install choices:
- No graphical environment
- Manual partitioning with encrypted LVM
- SSH server installed during setup

## Partitioning (LVM)

The mandatory partitioning scheme splits the disk into an encrypted physical volume containing a volume group, with the following logical volumes:

| Mount Point | Purpose |
|---|---|
| `/` | Root filesystem |
| `/boot` | Kept outside LVM (unencrypted, needed to boot) |
| `swap` | Swap space |
| `/home` | User home directories |
| `/var` | Variable data |
| `/var/log` | Logs, isolated to prevent log-filling attacks from affecting other partitions |
| `/srv` | Service data |
| `/tmp` | Temporary files |

Check the setup with:

```bash
lsblk
df -h
sudo vgdisplay
sudo lvdisplay
sudo pvdisplay
```

## Security Configuration

### Password Policy

Configured via `/etc/login.defs` and `libpam-pwquality`:

- Maximum password age: 30 days
- Minimum password age: 2 days
- Warning before expiration: 7 days
- Minimum length: 10 characters
- Must contain at least one uppercase, one lowercase, one digit
- At least 7 characters different from the previous password
- Cannot contain the username
- No more than 3 consecutive identical characters

Key files:
- `/etc/login.defs`
- `/etc/pam.d/common-password`
- `/etc/security/pwquality.conf`

### sudo Configuration

Configured via `/etc/sudoers.d/`:

- A limit of **3 password attempts** before failure
- A custom, explicit error message shown on authentication failure
- All sudo commands (successful and failed) logged to `/var/log/sudo/sudo.log`
- TTY mode enabled (`sudo` requires a real terminal, cannot be piped)
- The secure path is restricted to standard system binary directories

Example rules in `/etc/sudoers.d/born2beroot`:

```
Defaults        passwd_tries=3
Defaults        badpass_message="Wrong password, please try again."
Defaults        logfile="/var/log/sudo/sudo.log"
Defaults        log_input,log_output
Defaults        requiretty
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

### SSH Configuration

Configured via `/etc/ssh/sshd_config`:

- Listening **port changed to 4242** (never left on the default port 22)
- Root login disabled (`PermitRootLogin no`)
- Only non-default, restricted access allowed

```
Port 4242
PermitRootLogin no
```

Restart the service after editing:

```bash
sudo systemctl restart ssh
```

Connect from the host machine with:

```bash
ssh <username>@<VM_IP> -p 4242
```

### Firewall (UFW)

UFW (Uncomplicated Firewall) is installed and configured to only allow the SSH port:

```bash
sudo ufw enable
sudo ufw allow 4242
sudo ufw status verbose
```

## User and Group Management

- A user was created for the project login, added to a dedicated group (e.g. `user42`)
- Every user must belong to both the `sudo` group and this dedicated group
- Password policy above applies to all users

```bash
sudo adduser <username>
sudo addgroup user42
sudo usermod -aG sudo,user42 <username>
groups <username>
```

## Monitoring Script

A bash script, `monitoring.sh`, runs every 10 minutes via `cron` and broadcasts a system summary to all connected sessions using `wall`. It reports:

- Architecture and kernel version
- Number of physical CPUs and virtual CPUs (vCPU)
- RAM usage (used / total, percentage)
- Disk usage (used / total, percentage)
- CPU load percentage
- Last boot date and time
- LVM status (active or not)
- Number of active TCP connections
- Number of users currently logged in
- IPv4 address and MAC address
- Number of commands executed with sudo since the server started

The cron job is configured in `/etc/cron.d/monitoring` or via `crontab -e` for root:

```
*/10 * * * * root /usr/local/bin/monitoring.sh
```

## Usage

1. Clone or copy this repository's script(s) onto the VM.
2. Place `monitoring.sh` in `/usr/local/bin/` and make it executable:
   ```bash
   sudo chmod +x /usr/local/bin/monitoring.sh
   ```
3. Add the cron job as shown above.
4. Verify the script output manually:
   ```bash
   sudo /usr/local/bin/monitoring.sh
   ```

## Defense Tips

- Be ready to explain **every** configuration choice: partitioning, sudo policy, SSH hardening, firewall rules.
- Know the difference between UFW and iptables, and how UFW manages rules under the hood.
- Be able to justify LVM and disk encryption choices, and demonstrate resizing a logical volume if asked.
- Have the password policy files and sudo log ready to show live during the defense.
- Understand exactly what each field of `monitoring.sh`'s output represents and how it's gathered (`/proc`, `lscpu`, `free`, `vgdisplay`, etc.).

---

*42 School — Born2beRoot project*
