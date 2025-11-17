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
all:
  children:
    servers:
      hosts:
        server_group1:
          ansible_host: ""
          ansible_user: ""
          ansible_port: ""
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
# Session 2 
## Hardening SSH
* Restricts supported ciphers, MACs, and key exchange algorithms.
* Configures banner text, login grace period, and max authentication attempts.
* Validates changes with `sshd -t` before applying the configuration.

### SSH hardening (`roles/SSH_hardening`)

The SSH-specific role:

- Ensures `/run/sshd` exists and stops systemd socket activation (`ssh.socket`) so sshd runs as a traditional service.
- Deploys `templates/sshd_config.j2`, populated by defaults such as strong cipher/MAC/KEX suites, root login policy, session limits, and logging verbosity.
- Creates an empty revoked-keys list and guarantees the classic `ssh` service is enabled/restarted via the role handler.

Customize behavior through `defaults/main.yml` (e.g., `sshd_port`, crypto suites, login controls) or override per-host.

## What the roles do

* Creates /run/sshd with secure permissions so that the SSH daemon can start reliably. 

* Deploys a hardened sshd_config to /etc/ssh/sshd_config from the sshd_config.j2 template:

* Validates the configuration with sshd -t -f before applying it.

* Sets root ownership and 0600 permissions.

* Keeps a backup of the previous configuration.

* Notifies a handler to restart SSH when the configuration changes.

* Ensures a revoked keys file exists at the path defined by sshd_revoked_keys_file (default: /etc/ssh/revoked_keys) with appropriate permissions.

* Configuration is driven by variables, allowing you to tune SSH hardening:

* Basic settings

* sshd_port: SSH listening port (default: 22).

* sshd_host_keys: List of host key files (ed25519 & RSA).

* Authentication

* sshd_permit_root_login: Controls if root login is allowed.

* sshd_password_authentication: Disables password-based auth.

* sshd_kbd_interactive_authentication, sshd_challenge_response_authentication: Disable legacy interactive methods.

* sshd_pubkey_authentication: Enables public key authentication.

* Session & forwarding restrictions

* sshd_x11_forwarding, sshd_allow_agent_forwarding,

* sshd_allow_tcp_forwarding, sshd_permit_tunnel,

* sshd_allow_stream_local_forwarding, sshd_permit_user_environment:

* All disabled to reduce attack surface.

* Connection limits & timeouts

* sshd_client_alive_interval, sshd_client_alive_count_max: Idle session timeouts.

* sshd_login_grace_time: Time allowed for authentication.

* sshd_max_auth_tries: Limits failed auth attempts.

* sshd_max_sessions: Limits concurrent sessions per connection.

* PAM and login banners

* sshd_use_pam: Enables PAM integration.

* sshd_print_motd, sshd_print_last_log: Control MOTD and last login message.

* Networking & DNS

* sshd_use_dns: Disables reverse DNS lookups to speed up logins.

* Cryptography (aligned with DevSec recommendations)

* sshd_ciphers: Restricts SSH to modern, strong ciphers (chacha20, AES-GCM, AES-CTR).

* sshd_macs: Restricts MACs to SHA-2 based algorithms.

* sshd_kex: Restricts key exchange algorithms to strong, modern groups (curve25519, ECDH, strong DH groups).

* Logging and SFTP

* sshd_syslog_facility: Uses AUTHPRIV for sensitive auth logs.

* sshd_log_level: Uses VERBOSE to capture more detailed SSH activity.

* sshd_revoked_keys_file: Path to the file containing revoked public keys.

* sshd_subsystem_sftp: Uses the built-in internal-sftp subsystem.

---

### Run the baseline SSH hardening:

   ```bash
   ansible-playbook -i inventory/inventory.yml playbooks/SSH.yml
   ```
