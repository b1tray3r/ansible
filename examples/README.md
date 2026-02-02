# Examples Directory

This directory contains example configurations and playbooks to help you get started and understand how to use this Ansible project effectively.

## Available Examples

### 1. inventory_example.yml
**Purpose:** Shows how to create a multi-host inventory for production environments

**Features:**
- Multiple host groups (webservers, dbservers, docker_hosts)
- Group-specific variables
- Global variables

**Usage:**
```bash
# Copy and customize
cp examples/inventory_example.yml inventories/production/hosts.yml

# Use with playbooks
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml
```

### 2. custom_playbook_example.yml
**Purpose:** Demonstrates creating custom playbooks with multiple stacks

**Features:**
- Multiple plays targeting different host groups
- Inline Docker container definitions
- Variable overrides
- Custom monitoring stack (Prometheus + Grafana)

**Usage:**
```bash
# Run directly
ansible-playbook examples/custom_playbook_example.yml

# Or copy and customize
cp examples/custom_playbook_example.yml playbooks/monitoring.yml
```

### 3. vault_example.yml
**Purpose:** Shows how to structure sensitive data using Ansible Vault

**Features:**
- Database passwords
- Application secrets
- API keys
- SSH keys

**Usage:**
```bash
# Create an encrypted vault file
ansible-vault create inventories/localhost/group_vars/vault.yml

# Add variables (use vault_example.yml as reference)
# Then run playbooks with vault
ansible-playbook playbooks/site.yml --ask-vault-pass
```

## Common Patterns and Recipes

### Pattern 1: Multi-Environment Setup

Create separate inventories for each environment:

```
inventories/
├── development/
│   ├── hosts.yml
│   └── group_vars/
│       ├── all.yml
│       └── vault.yml
├── staging/
│   ├── hosts.yml
│   └── group_vars/
│       ├── all.yml
│       └── vault.yml
└── production/
    ├── hosts.yml
    └── group_vars/
        ├── all.yml
        └── vault.yml
```

Run for specific environment:
```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml
```

### Pattern 2: Selective Role Execution with Tags

Add tags to your playbook:

```yaml
- name: Setup Docker
  hosts: all
  become: true
  roles:
    - role: docker
  tags: [docker, setup]
```

Run only specific tags:
```bash
ansible-playbook playbooks/site.yml --tags docker
```

### Pattern 3: Docker Stack with Health Checks

```yaml
- name: Deploy application with health check
  community.docker.docker_container:
    name: myapp
    image: myapp:latest
    state: started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Pattern 4: Container Dependencies

```yaml
- name: Deploy database first
  community.docker.docker_container:
    name: postgres
    image: postgres:15
    state: started

- name: Wait for database
  ansible.builtin.wait_for:
    host: localhost
    port: 5432
    delay: 5
    timeout: 60

- name: Deploy application
  community.docker.docker_container:
    name: webapp
    image: webapp:latest
    state: started
    links:
      - postgres:db
```

### Pattern 5: Dynamic Port Assignment

```yaml
- name: Find available port
  ansible.builtin.set_fact:
    app_port: "{{ 8080 + (ansible_play_hosts.index(inventory_hostname) | int) }}"

- name: Deploy with dynamic port
  community.docker.docker_container:
    name: "app-{{ inventory_hostname }}"
    image: nginx:alpine
    ports:
      - "{{ app_port }}:80"
```

### Pattern 6: Container Cleanup

```yaml
- name: Stop and remove old containers
  community.docker.docker_container:
    name: "{{ item }}"
    state: absent
  loop:
    - old_app_v1
    - old_app_v2

- name: Remove unused images
  community.docker.docker_prune:
    images: true
    images_filters:
      dangling: true
```

### Pattern 7: Volume Backup

```yaml
- name: Backup volume data
  ansible.builtin.command:
    cmd: >
      docker run --rm
      -v {{ volume_name }}:/data
      -v /backup:/backup
      alpine tar czf /backup/{{ volume_name }}_{{ ansible_date_time.iso8601 }}.tar.gz -C /data .
```

## Real-World Examples

### Example 1: WordPress with MySQL

Create `roles/wordpress/defaults/main.yml`:
```yaml
wp_db_name: wordpress
wp_db_user: wpuser
wp_db_password: "{{ vault_wp_db_password }}"
wp_version: "6.4"
```

### Example 2: Redis Cache Cluster

Create `roles/redis_cluster/tasks/main.yml`:
```yaml
- name: Deploy Redis nodes
  community.docker.docker_container:
    name: "redis-{{ item }}"
    image: redis:7-alpine
    command: redis-server --cluster-enabled yes
    ports:
      - "{{ 6379 + item }}:6379"
  loop: "{{ range(0, 6) | list }}"
```

### Example 3: Nginx Reverse Proxy

Create `roles/nginx_proxy/tasks/main.yml`:
```yaml
- name: Create nginx config from template
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /tmp/nginx.conf

- name: Deploy Nginx
  community.docker.docker_container:
    name: nginx_proxy
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /tmp/nginx.conf:/etc/nginx/nginx.conf:ro
```

## Testing Examples

Before deploying to production, always test:

```bash
# Syntax check
ansible-playbook examples/custom_playbook_example.yml --syntax-check

# Dry run
ansible-playbook examples/custom_playbook_example.yml --check

# Run on test host only
ansible-playbook examples/custom_playbook_example.yml --limit test_host
```

## Getting Help

- Check the main [README.md](../README.md)
- Review [QUICKSTART.md](../QUICKSTART.md)
- Explore role documentation in `roles/*/README.md`
- Consult [Ansible documentation](https://docs.ansible.com/)

## Contributing

Have a useful example? Add it to this directory with:
1. Descriptive filename
2. Comments explaining the purpose
3. Update this README with the new example
