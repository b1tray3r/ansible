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
- sudo privileges (for system-level changes)

## Quick Start

### 1. Install Ansible Collections

First, install the required Ansible collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

### 2. Run the Main Playbook

To set up everything (software + Docker):

```bash
ansible-playbook playbooks/site.yml
```

### 3. Or Run Specific Playbooks

Install software only:

```bash
ansible-playbook playbooks/setup_software.yml
```

Deploy Docker stacks:

```bash
ansible-playbook playbooks/deploy_stacks.yml
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

To create a new Docker stack:

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

Check Ansible syntax:
```bash
ansible-playbook playbooks/site.yml --syntax-check
```

Dry run (check mode):
```bash
ansible-playbook playbooks/site.yml --check
```

List all tasks:
```bash
ansible-playbook playbooks/site.yml --list-tasks
```

## Troubleshooting

### Issue: Docker containers not starting
- Check logs: `docker logs <container_name>`
- Verify network: `docker network ls`
- Check container status: `docker ps -a`

### Issue: Permission denied
- Ensure user is in docker group: `sudo usermod -aG docker $USER`
- Log out and back in for group changes to take effect

### Issue: Ansible module not found
- Install required collections: `ansible-galaxy collection install -r requirements.yml`

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
