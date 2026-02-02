# Quick Start Guide

This guide will help you get started with the Ansible project in minutes.

## Prerequisites

- Linux or macOS system
- Python 3.8+ installed
- sudo/root access
- Internet connection

## Installation Steps

### Step 1: Install Ansible (if not already installed)

```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install ansible

# On macOS
brew install ansible

# Or using pip
pip install ansible
```

### Step 2: Clone the Repository (if needed)

```bash
git clone <repository-url>
cd ansible
```

### Step 3: Install Required Collections

```bash
ansible-galaxy collection install -r requirements.yml
```

Or using the Makefile:

```bash
make install
```

## Basic Usage

### Option 1: Run Everything (Recommended for first-time setup)

This will install Docker, common packages, and set up the system:

```bash
ansible-playbook playbooks/site.yml
```

Or using the Makefile:

```bash
make all
```

### Option 2: Step-by-Step Setup

**1. Install software and Docker only:**

```bash
ansible-playbook playbooks/setup_software.yml
```

Or:

```bash
make setup
```

**2. Deploy Docker stacks:**

```bash
ansible-playbook playbooks/deploy_stacks.yml
```

Or:

```bash
make deploy
```

## Testing Without Making Changes

Run in check mode (dry-run):

```bash
ansible-playbook playbooks/site.yml --check
```

Or:

```bash
make check
```

## Common Operations

### Check Syntax

```bash
make syntax
```

### List All Tasks

```bash
make list
```

### View Help

```bash
make help
```

## What Gets Installed

### Common Role
- Essential packages: curl, git, vim, htop, wget, unzip
- Python pip and setuptools
- Python Docker SDK for Ansible

### Docker Role
- Docker CE (Community Edition)
- Docker daemon configured and enabled
- User added to docker group
- Docker networks and volumes (as defined)

### Example Web Stack (if enabled)
- PostgreSQL database container
- Nginx web server container
- Custom network for container communication
- Named volumes for data persistence

## Customization

### Change Target Hosts

By default, everything runs on localhost. To target other hosts:

1. Create a new inventory file:

```bash
cp -r inventories/localhost inventories/production
```

2. Edit `inventories/production/hosts.yml`:

```yaml
---
all:
  children:
    webservers:
      hosts:
        web1.example.com:
          ansible_host: 192.168.1.10
        web2.example.com:
          ansible_host: 192.168.1.11
```

3. Run with the new inventory:

```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml
```

### Modify Variables

Variables can be changed in several places:

1. **Role defaults:** `roles/<role>/defaults/main.yml`
2. **Group variables:** `inventories/<env>/group_vars/`
3. **Command line:** `-e "variable=value"`

Example:

```bash
ansible-playbook playbooks/deploy_stacks.yml -e "web_stack_app_port=9090"
```

### Enable the Example Web Stack

Edit `playbooks/site.yml` and uncomment the web stack play:

```yaml
- name: Deploy Docker web stack
  hosts: all
  become: true
  roles:
    - docker_web_stack
```

Then run:

```bash
ansible-playbook playbooks/site.yml
```

Access the web application at: http://localhost:8080

## Create Your Own Docker Stack

### Method 1: Use the Template

```bash
# Copy the template
cp -r roles/stack_template roles/my_app

# Edit the defaults
nano roles/my_app/defaults/main.yml

# Add to a playbook
echo "    - my_app" >> playbooks/site.yml

# Deploy
ansible-playbook playbooks/site.yml
```

### Method 2: From Scratch

See `roles/stack_template/README.md` for detailed instructions.

## Troubleshooting

### Issue: "Permission denied" when running Docker commands

**Solution:** Log out and log back in after running the playbook, or run:

```bash
newgrp docker
```

### Issue: "Module not found" errors

**Solution:** Install the required collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

### Issue: Playbook fails with connection errors

**Solution:** Ensure you have proper SSH access or are using localhost correctly.

For localhost, verify in `inventories/localhost/hosts.yml`:

```yaml
localhost:
  ansible_connection: local
```

### Issue: Docker containers not starting

**Solution:** Check container logs:

```bash
docker logs <container_name>
```

Check if ports are already in use:

```bash
sudo netstat -tlnp | grep <port>
```

## Next Steps

1. **Explore the roles:** Check out `roles/` directory to understand the structure
2. **Read the documentation:** See `README.md` for comprehensive information
3. **Create custom stacks:** Use the template to build your own Docker stacks
4. **Add security:** Use Ansible Vault for sensitive data
5. **Set up multiple environments:** Create inventories for dev, staging, production

## Getting Help

- Check the main README.md
- View role-specific documentation in `roles/<role>/README.md`
- Review example configurations in `examples/`
- Check Ansible documentation: https://docs.ansible.com/

## Quick Reference

| Command | Description |
|---------|-------------|
| `make install` | Install Ansible collections |
| `make setup` | Install Docker and software |
| `make deploy` | Deploy Docker stacks |
| `make all` | Run everything |
| `make check` | Dry-run without changes |
| `make syntax` | Check syntax |
| `make list` | List all tasks |
| `make help` | Show all commands |

Happy automating! 🚀
