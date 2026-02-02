# Contributing Guide

Thank you for your interest in contributing to this Ansible project! This guide will help you get started.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Project Structure](#project-structure)
- [Creating New Roles](#creating-new-roles)
- [Testing](#testing)
- [Code Standards](#code-standards)
- [Submitting Changes](#submitting-changes)

## Getting Started

### Prerequisites

- Ansible 2.12 or higher
- Python 3.8 or higher
- [just](https://github.com/casey/just) command runner (recommended)
- Basic understanding of Ansible, YAML, and Docker

### Initial Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   just install
   ```
3. Verify setup:
   ```bash
   just syntax-all
   ```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/my-new-feature
```

### 2. Make Your Changes

Follow the [project structure](#project-structure) and [code standards](#code-standards).

### 3. Test Your Changes

```bash
# Check syntax
just syntax-all

# Run in check mode (dry-run)
just check

# Run linter
just lint

# Test on localhost
just setup
```

### 4. Document Your Changes

- Update README.md if adding new features
- Add comments to complex tasks
- Update role README.md files
- Add examples if applicable

### 5. Commit Your Changes

```bash
git add .
git commit -m "feat: add new docker stack role for MongoDB"
```

Use conventional commit messages:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test updates
- `chore:` - Maintenance tasks

## Project Structure

```
.
├── ansible.cfg              # Ansible configuration
├── justfile                 # Just command runner recipes
├── requirements.yml         # Ansible collections
├── inventories/            # Environment inventories
│   └── localhost/          # Default localhost config
│       ├── hosts.yml       # Host definitions
│       └── group_vars/     # Group variables
├── playbooks/              # Main playbooks
│   ├── site.yml           # Master playbook
│   ├── setup_software.yml # Software installation
│   └── deploy_stacks.yml  # Docker stack deployment
├── roles/                  # Reusable roles
│   ├── common/            # Base system setup
│   ├── docker/            # Docker installation
│   ├── docker_web_stack/  # Example web stack
│   └── stack_template/    # Template for new stacks
├── files/                  # Static files
├── templates/             # Jinja2 templates
└── examples/              # Example configurations
```

## Creating New Roles

### Using the Template (Recommended)

```bash
just new-role my_new_role
```

This creates a new role with the proper structure.

### Manual Creation

1. **Create role structure:**
   ```bash
   mkdir -p roles/my_role/{tasks,handlers,defaults,vars,meta,templates,files}
   ```

2. **Create main task file** (`roles/my_role/tasks/main.yml`):
   ```yaml
   ---
   - name: Descriptive task name
     module.name:
       param: value
     tags: [my_role]
   ```

3. **Add default variables** (`roles/my_role/defaults/main.yml`):
   ```yaml
   ---
   my_role_setting: default_value
   ```

4. **Add metadata** (`roles/my_role/meta/main.yml`):
   ```yaml
   ---
   galaxy_info:
     role_name: my_role
     description: Role description
     min_ansible_version: "2.12"
   dependencies: []
   ```

5. **Add README** (`roles/my_role/README.md`)

### Role Best Practices

- **Single Responsibility:** Each role should do one thing well
- **Idempotent:** Roles should be safe to run multiple times
- **Parameterized:** Use variables for configuration
- **Tagged:** Add tags for selective execution
- **Documented:** Include README with usage examples
- **Tested:** Test on clean system before submitting

## Testing

### Local Testing

```bash
# Syntax check
just syntax
just syntax-all

# Dry run (no changes)
just check

# Full run
just all

# Specific playbook
ansible-playbook playbooks/your_playbook.yml --check
```

### Role Testing

```bash
# Test a specific role
ansible-playbook playbooks/site.yml --tags "role_name"

# Check role syntax
ansible-playbook playbooks/site.yml --syntax-check
```

### Docker Testing

```bash
# Check Docker resources
just docker-ps
just docker-networks
just docker-volumes

# Clean up after testing
just docker-clean
```

## Code Standards

### YAML Formatting

- Use 2 spaces for indentation
- Use `---` at start of files
- Keep lines under 120 characters
- Use meaningful names for tasks, plays, and variables

**Good:**
```yaml
---
- name: Install Docker CE
  ansible.builtin.apt:
    name: docker-ce
    state: present
    update_cache: true
```

**Bad:**
```yaml
- name: install
  apt: name=docker-ce state=present
```

### Task Naming

- Always name your tasks
- Use descriptive, action-oriented names
- Start with capital letter
- Use present tense

**Examples:**
```yaml
- name: Install required packages
- name: Create Docker network
- name: Deploy application container
- name: Ensure service is running
```

### Variable Naming

- Use lowercase with underscores
- Prefix with role name to avoid conflicts
- Be descriptive

**Examples:**
```yaml
docker_install_version: "24.0"
web_stack_app_port: 8080
mysql_root_password: "{{ vault_mysql_password }}"
```

### Comments

Add comments for:
- Complex logic
- Non-obvious decisions
- Important configurations
- Security considerations

```yaml
---
# This task uses a specific Docker API version due to
# compatibility issues with older kernels
- name: Deploy container
  community.docker.docker_container:
    docker_api_version: "1.41"  # Required for kernel 4.x
    name: myapp
```

### Handlers

- Name handlers clearly
- Use handlers for service restarts
- Notify handlers from tasks

```yaml
# tasks/main.yml
- name: Update Docker daemon config
  template:
    src: daemon.json.j2
    dest: /etc/docker/daemon.json
  notify: restart docker

# handlers/main.yml
- name: restart docker
  service:
    name: docker
    state: restarted
```

### Security

- Use Ansible Vault for secrets
- Never commit unencrypted passwords
- Set proper file permissions
- Run containers as non-root when possible
- Keep images updated

```yaml
# Good - using vault
env:
  DB_PASSWORD: "{{ vault_db_password }}"

# Bad - hardcoded password
env:
  DB_PASSWORD: "password123"
```

## Submitting Changes

### Pull Request Process

1. **Update documentation:**
   - Update README.md if needed
   - Add to CHANGELOG if major changes
   - Update role documentation

2. **Test thoroughly:**
   ```bash
   just syntax-all
   just check
   just lint
   ```

3. **Create descriptive PR:**
   - Clear title
   - Description of changes
   - Testing performed
   - Related issues

4. **PR Template:**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] New feature
   - [ ] Bug fix
   - [ ] Documentation update
   - [ ] Refactoring

   ## Testing
   - [ ] Syntax check passed
   - [ ] Check mode passed
   - [ ] Tested on localhost
   - [ ] Linter passed

   ## Related Issues
   Fixes #123
   ```

### Review Process

- Maintainers will review your PR
- Address feedback promptly
- Keep PR focused and small
- One feature/fix per PR

## Common Tasks

### Adding a New Docker Stack

1. Create role: `just new-role my_stack`
2. Edit `roles/my_stack/defaults/main.yml`
3. Edit `roles/my_stack/tasks/main.yml`
4. Add to playbook
5. Test: `just check`
6. Document in role README

### Adding a New Inventory

1. Create inventory: `just new-inventory staging`
2. Edit `inventories/staging/hosts.yml`
3. Add group variables
4. Test: `just list-hosts`

### Adding Vault Variables

1. Create vault: `just vault-create inventories/localhost/group_vars/vault.yml`
2. Add variables
3. Reference in roles/playbooks
4. Test with: `ansible-playbook playbooks/site.yml --ask-vault-pass`

## Getting Help

- Check existing issues
- Review documentation in `/docs` and role READMEs
- Ask in discussions
- Review examples in `examples/` directory

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn
- Follow project guidelines

Thank you for contributing! 🎉
