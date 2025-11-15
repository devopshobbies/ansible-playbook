# Hardening Server — Ansible Role

A reusable, production-minded Ansible role that applies operating-system hardening: kernel/sysctl protections, PAM login safeguards (faillock/passwd quality), secure defaults for users/shell, SSH tightening, audit/logging hygiene, and locking down uncommon filesystems.

---

## Role Layout (what each directory is for)

- **defaults/**  
  Low-precedence variables that define the role’s sensible defaults.  
  Put `defaults/main.yml` here. These are safe to override from inventory or playbooks.

- **vars/**  
  Higher-precedence variables that are more “opinionated” for this role.  
  Put `vars/main.yml` here. Only use when a value should rarely be overridden.

- **tasks/**  
  The role’s execution logic.  
  `tasks/main.yml` is the entry point that can include task files like `sysctl.yml`, `pam.yml`, `audit.yml`, `ssh.yml`, etc.

- **handlers/**  
  Actions triggered by `notify` (e.g., “restart sshd”, “reload sysctl”).  
  Define them in `handlers/main.yml`.

- **templates/**  
  Jinja2 templates rendered on the target (e.g., `filesystems.conf.j2`, `faillock.conf.j2`, `login.defs.j2`).  
  Reference them from tasks via the `template` module.

- **meta/**  
  Role metadata in `meta/main.yml` (author, supported platforms, dependencies).  
  Useful for Galaxy and for documenting expectations.

- **tests/**  
  Lightweight scenarios, example inventories, or Molecule-style scaffolding to prove the role runs successfully.

---

## Requirements

- Ansible on the control node.
- Linux targets that match the hardening assumptions in this role (Debian/Ubuntu family by default).
- `become: true` during execution (the role changes system files).

---

## Variables

Review `defaults/main.yml` for all tunables (conservative by default).  
Override in `group_vars/` or `host_vars/` to fit your environment (e.g., SSH policy, faillock thresholds, umask, sysctl keys).

---

## Quick Start

Run the role with your own inventory and a simple playbook:

```bash
ansible-playbook -i INVENTORY_PATH hardening.yml
