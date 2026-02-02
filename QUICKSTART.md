# Quick Start Guide

This guide will help you get started with the Ansible project in minutes.

## Prerequisites

- Linux or macOS system
- Python 3.8+ installed
- sudo/root access
- Internet connection
- [just](https://github.com/casey/just) command runner (optional but recommended)

## Installation Steps

### Step 1: Install just (optional but recommended)

```bash
# On Ubuntu/Debian
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

# On macOS
brew install just

# Verify installation
just --version
```

### Step 2: Install Ansible (if not already installed)

```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install ansible

# On macOS
brew install ansible

# Or using pip
pip install ansible
```

### Step 3: Clone the Repository (if needed)

```bash
git clone <repository-url>
cd ansible
```

### Step 4: Install Required Collections

**Using just (recommended):**
```bash
just install
```

**Manual:**
```bash
ansible-galaxy collection install -r requirements.yml
```

## Basic Usage

### Quick Start (Everything in One Command)

```bash
just quickstart
```

This will:
1. Install Ansible collections
2. Set up the system and install Docker

### Option 1: Run Everything

This will install Docker, common packages, and set up the system:

**Using just:**
```bash
just all
```

**Manual:**
```bash
ansible-playbook playbooks/site.yml
```

### Option 2: Step-by-Step Setup

**1. Install software and Docker:**

```bash
just setup
# Or: ansible-playbook playbooks/setup_software.yml
```

**2. Deploy Docker stacks:**

```bash
just deploy
# Or: ansible-playbook playbooks/deploy_stacks.yml
```

## Testing Without Making Changes

Run in check mode (dry-run):

```bash
just check
# Or: ansible-playbook playbooks/site.yml --check
```

## Common Operations with just

View all available commands:
```bash
just
# Or: just --list
```

### Setup & Installation
```bash
just install          # Install Ansible collections
just quickstart       # Install and run setup
```

### Deployment
```bash
just setup            # Install software only
just deploy           # Deploy Docker stacks
just all              # Run complete setup
just deploy-env prod  # Deploy to specific environment
```

### Testing & Validation
```bash
just check            # Dry-run
just syntax           # Check syntax
just syntax-all       # Check all playbooks
just lint             # Run ansible-lint
```

### Information
```bash
just list             # List all tasks
just list-hosts       # List inventory hosts
just config           # Show Ansible config
just version          # Show Ansible version
```

### Docker Management
```bash
just docker-ps        # Show running containers
just docker-ps-all    # Show all containers
just docker-networks  # Show networks
just docker-volumes   # Show volumes
just docker-stop      # Stop all containers
just docker-clean     # Clean stopped containers
```

### Development
```bash
just new-role myapp   # Create new role from template
just new-inventory prod  # Create new inventory
just clean            # Clean temp files
just reset            # Full reset (stop containers, clean)
```

### Vault Management
```bash
just vault-create FILE    # Create encrypted file
just vault-edit FILE      # Edit encrypted file
just vault-view FILE      # View encrypted file
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

**Using just:**
```bash
just new-inventory production
# Edit inventories/production/hosts.yml
just deploy-env production
```

**Manual:**

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
# Or: just deploy-env production
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
just all
# Or: ansible-playbook playbooks/site.yml
```

Access the web application at: http://localhost:8080

## Create Your Own Docker Stack

### Method 1: Use just (Quick & Easy)

```bash
# Create from template
just new-role my_app

# Edit the defaults
nano roles/my_app/defaults/main.yml

# Add to a playbook
echo "    - my_app" >> playbooks/site.yml

# Deploy
just all
```

### Method 2: Manual

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

### Method 3: From Scratch

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
just install
# Or: ansible-galaxy collection install -r requirements.yml
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
# Or: just docker-ps-all
```

Check if ports are already in use:

```bash
sudo netstat -tlnp | grep <port>
```

View Docker resources:
```bash
just docker-ps        # Running containers
just docker-networks  # Networks
just docker-volumes   # Volumes
```

## Next Steps

1. **Explore the roles:** Check out `roles/` directory to understand the structure
2. **Read the documentation:** See `README.md` for comprehensive information
3. **Create custom stacks:** Use `just new-role <name>` to build your own Docker stacks
4. **Add security:** Use `just vault-create` for sensitive data
5. **Set up multiple environments:** Use `just new-inventory <env>` for dev, staging, production

## Getting Help

- Check the main README.md
- View role-specific documentation in `roles/<role>/README.md`
- Review example configurations in `examples/`
- Run `just` to see all available commands
- Check Ansible documentation: https://docs.ansible.com/

## Quick Reference

| Command | Description |
|---------|-------------|
| `just` | Show all available commands |
| `just quickstart` | Install collections and setup |
| `just install` | Install Ansible collections |
| `just setup` | Install Docker and software |
| `just deploy` | Deploy Docker stacks |
| `just all` | Run everything |
| `just check` | Dry-run without changes |
| `just syntax` | Check syntax |
| `just list` | List all tasks |
| `just new-role NAME` | Create new role |
| `just new-inventory ENV` | Create new inventory |
| `just vault-create FILE` | Create encrypted file |
| `just docker-ps` | Show running containers |
| `just reset` | Full reset and cleanup |

Happy automating! 🚀
