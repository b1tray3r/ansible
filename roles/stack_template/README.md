# Stack Template Role

This is a template role for creating your own Docker stacks with Ansible.

## How to Use This Template

1. **Copy this template:**
   ```bash
   cp -r roles/stack_template roles/my_custom_stack
   ```

2. **Update role name in `meta/main.yml`:**
   ```yaml
   galaxy_info:
     role_name: my_custom_stack
     description: Your stack description
   ```

3. **Define your containers in `defaults/main.yml`:**
   ```yaml
   stack_network: my_network
   
   stack_containers:
     - name: my_app
       image: myapp:latest
       ports:
         - "8080:80"
       env:
         DB_HOST: database
   ```

4. **Customize tasks in `tasks/main.yml` if needed:**
   - Add health checks
   - Add pre/post deployment tasks
   - Add custom configuration

5. **Create a playbook or add to existing one:**
   ```yaml
   - hosts: all
     become: true
     roles:
       - my_custom_stack
   ```

## Example Custom Stack

Here's an example of creating a WordPress stack:

```yaml
# roles/wordpress_stack/defaults/main.yml
stack_network: wordpress_network

stack_volumes:
  - wordpress_data
  - mysql_data

stack_images:
  - wordpress:latest
  - mysql:8.0

stack_containers:
  - name: wordpress_db
    image: mysql:8.0
    volumes:
      - mysql_data:/var/lib/mysql
    env:
      MYSQL_ROOT_PASSWORD: "{{ vault_mysql_root_password }}"
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: "{{ vault_mysql_password }}"
      
  - name: wordpress
    image: wordpress:latest
    ports:
      - "8080:80"
    volumes:
      - wordpress_data:/var/www/html
    env:
      WORDPRESS_DB_HOST: wordpress_db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: "{{ vault_mysql_password }}"
      WORDPRESS_DB_NAME: wordpress
```

## Best Practices

1. **Use Ansible Vault for secrets** - Never commit passwords in plain text
2. **Pin image versions** - Use specific tags instead of `latest` in production
3. **Define health checks** - Ensure containers are healthy before proceeding
4. **Use named volumes** - For data persistence
5. **Document variables** - Add comments explaining each variable
6. **Test thoroughly** - Use check mode before applying to production

## Variables

Default variables that can be customized:

| Variable | Description | Default |
|----------|-------------|---------|
| `stack_network` | Docker network name | `my_stack_network` |
| `stack_volumes` | List of volume names | `[]` |
| `stack_images` | List of images to pull | `[]` |
| `stack_containers` | Container definitions | `[]` |

## Container Definition Format

```yaml
stack_containers:
  - name: container_name          # Required
    image: image:tag              # Required
    ports:                        # Optional
      - "host:container"
    volumes:                      # Optional
      - volume:/path
      - /host/path:/container/path
    env:                          # Optional
      KEY: value
    command: ["cmd"]              # Optional
    restart_policy: always        # Optional, default: unless-stopped
```
