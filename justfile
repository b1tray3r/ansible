# Ansible Project - Justfile
# Use 'just' command runner: https://github.com/casey/just

# Default recipe - show help
default:
    @just --list

# ============================================================================
# Setup & Installation
# ============================================================================

# Install Ansible collections and dependencies
install:
    ansible-galaxy collection install -r requirements.yml

# Install just command runner (if not already installed)
install-just:
    #!/usr/bin/env bash
    if command -v just >/dev/null 2>&1; then
        echo "just is already installed"
        just --version
    else
        echo "Installing just..."
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin
        echo "Please add ~/bin to your PATH"
    fi

# ============================================================================
# Deployment
# ============================================================================

# Run the complete site playbook (setup + deploy)
all:
    ansible-playbook playbooks/site.yml

# Run software setup playbook (install Docker and common packages)
setup:
    ansible-playbook playbooks/setup_software.yml

# Deploy Docker stacks
deploy:
    ansible-playbook playbooks/deploy_stacks.yml

# Deploy to specific environment (usage: just deploy-env production)
deploy-env ENV:
    ansible-playbook -i inventories/{{ENV}}/hosts.yml playbooks/site.yml

# ============================================================================
# Testing & Validation
# ============================================================================

# Run playbook in check mode (dry-run)
check:
    ansible-playbook playbooks/site.yml --check

# Check playbook syntax
syntax:
    ansible-playbook playbooks/site.yml --syntax-check

# Check syntax of all playbooks
syntax-all:
    #!/usr/bin/env bash
    echo "Checking site.yml..."
    ansible-playbook playbooks/site.yml --syntax-check
    echo "Checking setup_software.yml..."
    ansible-playbook playbooks/setup_software.yml --syntax-check
    echo "Checking deploy_stacks.yml..."
    ansible-playbook playbooks/deploy_stacks.yml --syntax-check
    echo "✓ All playbooks syntax OK"

# Lint all playbooks and roles (requires ansible-lint)
lint:
    #!/usr/bin/env bash
    if ! command -v ansible-lint >/dev/null 2>&1; then
        echo "ansible-lint not installed. Install with: pip install ansible-lint"
        exit 1
    fi
    ansible-lint

# ============================================================================
# Information & Debugging
# ============================================================================

# List all tasks in site playbook
list:
    ansible-playbook playbooks/site.yml --list-tasks

# List all hosts in inventory
list-hosts:
    ansible-inventory --list -i inventories/localhost/hosts.yml

# Show Ansible configuration
config:
    ansible-config dump --only-changed

# Show Ansible version
version:
    ansible --version

# ============================================================================
# Docker Management
# ============================================================================

# Show all running Docker containers
docker-ps:
    docker ps

# Show all Docker containers (including stopped)
docker-ps-all:
    docker ps -a

# Show Docker networks
docker-networks:
    docker network ls

# Show Docker volumes
docker-volumes:
    docker volume ls

# Stop all running containers
docker-stop:
    docker stop $(docker ps -q)

# Remove all stopped containers
docker-clean:
    docker container prune -f

# Full Docker cleanup (containers, images, volumes, networks)
docker-clean-all:
    #!/usr/bin/env bash
    echo "This will remove all stopped containers, unused networks, dangling images, and unused volumes."
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker system prune -a --volumes -f
    fi

# ============================================================================
# Development & Maintenance
# ============================================================================

# Clean temporary files and caches
clean:
    rm -rf /tmp/ansible_fact_cache/
    find . -type f -name "*.retry" -delete
    find . -type f -name "*.log" -delete
    @echo "✓ Cleaned temporary files"

# Create a new role from template (usage: just new-role my_role)
new-role NAME:
    #!/usr/bin/env bash
    if [ -d "roles/{{NAME}}" ]; then
        echo "Error: Role 'roles/{{NAME}}' already exists"
        exit 1
    fi
    cp -r roles/stack_template "roles/{{NAME}}"
    echo "✓ Created new role: roles/{{NAME}}"
    echo "Next steps:"
    echo "  1. Edit roles/{{NAME}}/defaults/main.yml"
    echo "  2. Edit roles/{{NAME}}/tasks/main.yml"
    echo "  3. Update roles/{{NAME}}/meta/main.yml"
    echo "  4. Add to a playbook"

# Create a new inventory (usage: just new-inventory production)
new-inventory ENV:
    #!/usr/bin/env bash
    if [ -d "inventories/{{ENV}}" ]; then
        echo "Error: Inventory 'inventories/{{ENV}}' already exists"
        exit 1
    fi
    mkdir -p "inventories/{{ENV}}"/{group_vars,host_vars}
    cp examples/inventory_example.yml "inventories/{{ENV}}/hosts.yml"
    echo "✓ Created new inventory: inventories/{{ENV}}"
    echo "Next step: Edit inventories/{{ENV}}/hosts.yml"

# ============================================================================
# Vault Management
# ============================================================================

# Create a new vault file (usage: just vault-create myfile)
vault-create FILE:
    ansible-vault create {{FILE}}

# Edit an existing vault file (usage: just vault-edit myfile)
vault-edit FILE:
    ansible-vault edit {{FILE}}

# View a vault file (usage: just vault-view myfile)
vault-view FILE:
    ansible-vault view {{FILE}}

# Encrypt an existing file (usage: just vault-encrypt myfile)
vault-encrypt FILE:
    ansible-vault encrypt {{FILE}}

# Decrypt a vault file (usage: just vault-decrypt myfile)
vault-decrypt FILE:
    ansible-vault decrypt {{FILE}}

# ============================================================================
# Quick Actions
# ============================================================================

# Quick start: install collections and run setup
quickstart:
    @echo "==> Installing Ansible collections..."
    just install
    @echo ""
    @echo "==> Running setup playbook..."
    just setup
    @echo ""
    @echo "✓ Quickstart complete!"
    @echo "Next step: Run 'just deploy' to deploy Docker stacks"

# Full reset: stop containers, clean Docker, and remove caches
reset:
    @echo "==> Stopping containers..."
    -just docker-stop
    @echo "==> Cleaning Docker..."
    -just docker-clean
    @echo "==> Cleaning caches..."
    just clean
    @echo "✓ Reset complete!"
