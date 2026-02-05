default:
    @just --list

export PATH := "./venv/bin:" + env_var('PATH')

[group('run')]
run FILE="site":
    ansible-playbook playbooks/{{ FILE }}.yml -i inventories/localhost/hosts.yml --ask-become-pass

[group('run')]
taskwarrior:
    ansible-playbook playbooks/task_timewarrior.yml -i inventories/localhost/hosts.yml --ask-become-pass

[group('development')]
install:
    sudo apt install python3-venv python3-pip -y
    python3 -m venv venv
    pip install --upgrade pip --break-system-packages
    pip install ansible ansible-lint --break-system-packages
    ansible-galaxy collection install -r requirements.yml

[group('development')]
syntax FILE="site":
    ansible-playbook playbooks/{{ FILE }}.yml --syntax-check

[group('development')]
lint:
    #!/usr/bin/env bash
    if ! command -v ansible-lint >/dev/null 2>&1; then
        echo "ansible-lint not installed. Install with: pip install ansible-lint"
        exit 1
    fi
    ansible-lint

[group('development')]
clean:
    ansible-inventory --list -i inventories/localhost/hosts.yml

    rm -rf /tmp/ansible_fact_cache/
    find . -type f -name "*.retry" -delete
    find . -type f -name "*.log" -delete

[group('vault')]
vault-create FILE:
    ansible-vault create {{FILE}}

[group('vault')]
vault-edit FILE:
    ansible-vault edit {{FILE}}

[group('vault')]
vault-view FILE:
    ansible-vault view {{FILE}}

[group('vault')]
vault-encrypt FILE:
    ansible-vault encrypt {{FILE}}

[group('vault')]
vault-decrypt FILE:
    ansible-vault decrypt {{FILE}}