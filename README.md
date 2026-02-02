# Ansible Project - Software and Docker Stack Management

This repository contains a modular and flexible Ansible project for installing software on hosts and setting up Docker stacks (without docker-compose). The project follows best practices from the official Ansible documentation.

## Project Structure

```
.
├── ansible.cfg              # Ansible configuration
├── requirements.yml         # Ansible Galaxy dependencies
├── inventories/            # Inventory files for different environments
│   └── localhost/          # Localhost inventory (default)
│       ├── hosts.yml       # Host definitions
│       └── group_vars/     # Group-specific variables
├── playbooks/              # Main playbooks
│   ├── site.yml           # Master playbook
│   ├── setup_software.yml # Software installation playbook
│   └── deploy_stacks.yml  # Docker stack deployment playbook
├── roles/                  # Reusable roles
│   ├── common/            # Base system configuration
│   ├── docker/            # Docker installation and setup
│   └── docker_web_stack/  # Example Docker stack
├── files/                  # Static files
└── templates/             # Jinja2 templates
```

## Prerequisites

- Python 3.8+
- Ansible 2.12+
- [just](https://github.com/casey/just) command runner (optional but recommended)
- sudo privileges (for system-level changes)

## Quick Start

### 1. Install just (optional but recommended)

```bash
# On macOS
brew install just

# On Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

# Or use the built-in installer
just install-just
```

### 2. Install Ansible Collections

```bash
just install
# Or manually: ansible-galaxy collection install -r requirements.yml
```

### 3. Run the Setup

```bash
just quickstart  # Install collections and run setup
# Or step by step:
just setup      # Install software and Docker
just deploy     # Deploy Docker stacks
# Or all at once:
just all        # Run complete site playbook
```

### Without just

```bash
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/site.yml
```

## Available Roles

### common
Base system configuration and common package installation.
- Updates package cache
- Installs essential packages (curl, git, vim, htop, etc.)
- Installs Python dependencies for Ansible Docker modules

### docker
Installs and configures Docker CE.
- Adds Docker repository
- Installs Docker Engine
- Configures Docker daemon
- Manages Docker users, networks, and volumes

### docker_web_stack (Example)
Example role demonstrating how to deploy a multi-container stack without docker-compose.
- Creates Docker network
- Deploys PostgreSQL database container
- Deploys Nginx web server container
- Manages volumes for data persistence

## Creating Your Own Docker Stacks

### Quick Method (using just)

```bash
just new-role my_stack
# Edit the generated files in roles/my_stack/
```

### Manual Method

1. Create a new role in `roles/` directory:
   ```bash
   mkdir -p roles/my_stack/{tasks,defaults,meta}
   ```

2. Define your containers in `roles/my_stack/tasks/main.yml`:
   ```yaml
   ---
   - name: Create network
     community.docker.docker_network:
       name: my_network
       state: present

   - name: Deploy container
     community.docker.docker_container:
       name: my_container
       image: my_image:latest
       state: started
       networks:
         - name: my_network
   ```

3. Set default variables in `roles/my_stack/defaults/main.yml`

4. Add the role to a playbook or `playbooks/site.yml`

## Configuration

### Inventory

The default inventory targets `localhost`. To target other hosts:

**Using just:**
```bash
just new-inventory production
# Edit inventories/production/hosts.yml
just deploy-env production
```

**Manual:**
1. Create a new inventory file in `inventories/`
2. Update `ansible.cfg` or specify with `-i` flag:
   ```bash
   ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml
   ```

### Variables

Variables can be set at multiple levels:

- **Role defaults**: `roles/<role>/defaults/main.yml`
- **Group variables**: `inventories/<env>/group_vars/`
- **Host variables**: `inventories/<env>/host_vars/`
- **Playbook variables**: In the playbook file or via `-e` flag

Example:
```bash
ansible-playbook playbooks/deploy_stacks.yml -e "web_stack_app_port=9090"
```

### Secrets Management

For sensitive data, use Ansible Vault:

**Using just:**
```bash
just vault-create inventories/localhost/group_vars/vault.yml
# Add your encrypted variables
# Run playbooks with: ansible-playbook playbooks/site.yml --ask-vault-pass
```

**Available vault commands:**
- `just vault-create <file>` - Create new encrypted file
- `just vault-edit <file>` - Edit encrypted file
- `just vault-view <file>` - View encrypted file
- `just vault-encrypt <file>` - Encrypt existing file
- `just vault-decrypt <file>` - Decrypt file

**Manual:**
1. Create a vault file:
   ```bash
   ansible-vault create inventories/localhost/group_vars/vault.yml
   ```

2. Add encrypted variables:
   ```yaml
   vault_db_password: your_secure_password
   ```

3. Run playbooks with vault:
   ```bash
   ansible-playbook playbooks/site.yml --ask-vault-pass
   ```

## Best Practices Implemented

This project follows Ansible best practices:

✅ **Modular structure** - Roles for reusability and maintainability  
✅ **Idempotent playbooks** - Safe to run multiple times  
✅ **Variable hierarchy** - Clear variable precedence  
✅ **No docker-compose** - Pure Ansible Docker orchestration  
✅ **Named tasks** - Clear descriptions for all tasks  
✅ **Tagged tasks** - Selective execution support  
✅ **Handlers** - Efficient service management  
✅ **Documentation** - README files for roles and project  
✅ **Version control** - Proper .gitignore for Ansible projects  

## Testing

**Using just:**
```bash
just syntax        # Check syntax of site.yml
just syntax-all    # Check all playbooks
just check         # Dry run without changes
just list          # List all tasks
just lint          # Run ansible-lint
```

**Manual:**
```bash
ansible-playbook playbooks/site.yml --syntax-check  # Check syntax
ansible-playbook playbooks/site.yml --check         # Dry run
ansible-playbook playbooks/site.yml --list-tasks    # List tasks
```

## Available Just Commands

Run `just` or `just --list` to see all available commands grouped by category:

**Setup & Installation:** `install`, `install-just`, `quickstart`  
**Deployment:** `all`, `setup`, `deploy`, `deploy-env`  
**Testing:** `check`, `syntax`, `syntax-all`, `lint`  
**Information:** `list`, `list-hosts`, `config`, `version`  
**Docker Management:** `docker-ps`, `docker-networks`, `docker-volumes`, `docker-stop`, `docker-clean`  
**Vault Management:** `vault-create`, `vault-edit`, `vault-view`, `vault-encrypt`, `vault-decrypt`  
**Development:** `clean`, `new-role`, `new-inventory`, `reset`

## Troubleshooting

**Using just:**
```bash
just docker-ps          # Check running containers
just docker-ps-all      # Check all containers
just docker-networks    # View Docker networks
just docker-volumes     # View Docker volumes
just config             # View Ansible configuration
just version            # Check Ansible version
```

### Issue: Docker containers not starting
- Check logs: `docker logs <container_name>` or `just docker-ps-all`
- Verify network: `docker network ls` or `just docker-networks`
- Check container status: `docker ps -a` or `just docker-ps-all`

### Issue: Permission denied
- Ensure user is in docker group: `sudo usermod -aG docker $USER`
- Log out and back in for group changes to take effect

### Issue: Ansible module not found
- Install required collections: `just install` or manually with `ansible-galaxy collection install -r requirements.yml`

## Contributing

When adding new roles or playbooks:

1. Follow the existing directory structure
2. Document all variables in `defaults/main.yml`
3. Add a README.md for complex roles
4. Test your changes with `--check` mode first
5. Use meaningful task names
6. Keep roles focused and single-purpose

## License

MIT

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Community Docker Collection](https://docs.ansible.com/ansible/latest/collections/community/docker/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
