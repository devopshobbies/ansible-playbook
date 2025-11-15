# Session 1
## Hardening_Server — Ansible playbooks for opinionated Linux hardening

`Hardening_Sever` is an Ansible codebase that applies a baseline security posture to Debian/Ubuntu hosts. It exposes a reusable roles:

- **`hardening`** — OS-level lockdown covering sysctl, PAM, auditd, cron, authentication defaults, filesystem blacklisting, and legacy service removal.

Use the provided playbooks to roll out the baseline to fresh hosts or incorporate the roles into your own automation.

---

## Repository layout

| Path | Description |
| ---- | ----------- |
| `ansible.cfg` | Opinionated Ansible defaults (local inventory path, pipelining, host key checking disabled) for faster ad-hoc runs. |
| `inventory/inventory.yml` | Example inventory targeting the `servers` group. Replace host definitions with your infrastructure. |
| `playbooks/hardening.yml` | Entry point that applies the full operating-system hardening role to the `servers` group. |
| `roles/hardening/` | Reusable OS hardening role (tasks, templates, defaults, handlers). |


---

## Prerequisites

1. **Control node**
   - Create virtual env 
   - Ansible 2.12+ (tested with modern releases).
   - Python 3.x with `ansible-galaxy` available.
   - Create roles with ansible galaxy 

2. **Managed hosts**
   - Debian/Ubuntu family (the defaults assume APT, `/etc/login.defs`, PAM profiles, etc.).
   - SSH connectivity with an account that can `become: true` (role touches system files).
   - Package repositories reachable to install baseline packages (e.g., `auditd`, `libpam-passwdqc`).

---

## Quick start

1. Update the example inventory:

   ```yaml
   # inventory/inventory.yml
   all:
     children:
       servers:
         hosts:
           web01:
             ansible_host: 192.0.2.10
             ansible_user: root
             ansible_port: 22
   ```

2. (Optional) Test connectivity:

   ```bash
   ansible -i inventory/inventory.yml servers -m ping
   ```

3. Run the baseline OS hardening:

   ```bash
   ansible-playbook -i inventory/inventory.yml playbooks/hardening.yml
   ```


---

## What the roles do

### OS hardening (`roles/hardening`)

Key actions include:

- Refresh package cache, install baseline security packages (`openssh-server`, `auditd`, `libpam-modules`, `libpam-passwdqc`), and purge legacy daemons such as `telnetd`/`rsh`/`xinetd`.
- Apply kernel/network sysctl defaults sourced from `defaults/main.yml` via `templates/sysctl-hardening.j2`, then trigger `sysctl --system` reloads.
- Lock down scheduled task infrastructure: secure `/etc/cron.*` directories, set restrictive permissions on `/etc/crontab`, remove `cron.deny`/`at.deny`, and maintain `cron.allow`/`at.allow` lists.
- Normalize permissions on `/etc/passwd`, `/etc/group`, `/etc/shadow`, `/etc/gshadow`.
- Configure auditd with opinionated defaults (`templates/auditd.conf.j2`) and restart the service when needed.
- Enforce PAM password complexity (`templates/pam_passwdqc.j2`) and faillock policies (`faillock` defaults and `community.general.pamd` edits).
- Manage `/etc/login.defs` guardrails (password rotation, retries, UMASK) and disable core dumps through `/etc/security/limits.d/hardening.conf`.
- Set a global `umask 027` profile, blacklist uncommon filesystems (`templates/filesystems.conf.j2`), and ensure handlers reload/restart services as appropriate.

All tunables are exposed in `defaults/main.yml`; override them in inventory/group vars to adapt to your policy.

---
