# Ansible Project - Software and Docker Stack Management

This repository contains a modular and flexible Ansible project for installing software on hosts and setting up Docker stacks (without docker-compose). The project follows best practices from the official Ansible documentation.

## Prerequisites

- Python 3.8+
- Ansible 2.12+
- [just](https://github.com/casey/just) command runner (optional but recommended)
- sudo privileges (for system-level changes)

## Quickstart

### Install just (with sudo)

Not C not make:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/sbin

# Assuming /usr/local/sbin is in your $PATH
❯ just --version
just 1.46.0
```

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Community Docker Collection](https://docs.ansible.com/ansible/latest/collections/community/docker/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
