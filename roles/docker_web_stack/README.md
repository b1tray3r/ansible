# Docker Web Stack Role

This role demonstrates how to deploy a multi-container Docker stack using Ansible without docker-compose.

## Description

This example role deploys a simple web application stack consisting of:
- PostgreSQL database container
- Nginx web server container
- Custom Docker network for container communication
- Named volumes for data persistence

## Requirements

- Docker must be installed (handled by the docker role)
- community.docker collection must be installed

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
# Network
web_stack_network: webstack_network

# Database
web_stack_db_image: postgres:15-alpine
web_stack_db_container: webstack_db
web_stack_db_name: webapp
web_stack_db_user: webapp
web_stack_db_password: changeme  # Use vault in production!

# Application
web_stack_app_image: nginx:alpine
web_stack_app_container: webstack_app
web_stack_app_port: 8080
```

## Dependencies

- docker role (installs and configures Docker)

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - role: docker_web_stack
      vars:
        web_stack_app_port: 8080
        web_stack_db_password: "{{ vault_db_password }}"
```

## Usage

This role serves as a template for creating your own Docker stacks. Customize it by:
1. Modifying the container images
2. Adjusting environment variables
3. Adding more containers to the stack
4. Configuring volume mounts
5. Setting up additional networks

## Security Notes

- **Always** use Ansible Vault for sensitive variables in production
- Never commit passwords or secrets to version control
- Use secure password generation for database credentials
