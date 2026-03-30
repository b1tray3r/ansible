default:
    @just --list

export PATH := "$PWD/venv/bin:" + env_var('PATH')

[group('run')]
run FILE="site" LIMIT="localhost":
    ./venv/bin/ansible-playbook playbooks/{{ FILE }}.yml -i inventories -l {{ LIMIT }}

[group('development')]
install:
    sudo apt install python3-venv python3-pip -y
    python3 -m venv venv
    ./venv/bin/pip install --upgrade pip --break-system-packages
    ./venv/bin/pip install ansible ansible-lint --break-system-packages
    ./venv/bin/ansible-galaxy collection install -r requirements.yml

[group('development')]
syntax FILE="site":
    ./venv/bin/ansible-playbook playbooks/{{ FILE }}.yml --syntax-check

[group('development')]
lint:
    #!/usr/bin/env bash
    if ! command -v ansible-lint >/dev/null 2>&1; then
        echo "ansible-lint not installed. Install with: pip install ansible-lint"
        exit 1
    fi
    ./venv/bin/ansible-lint

[group('development')]
clean:
    ./venv/bin/ansible-inventory --list -i inventories/localhost/hosts.yml

    rm -rf /tmp/ansible_fact_cache/
    find . -type f -name "*.retry" -delete
    find . -type f -name "*.log" -delete

[group('vault')]
vault-create FILE:
    ./venv/bin/ansible-vault create {{FILE}}

[group('vault')]
vault-edit FILE:
    ./venv/bin/ansible-vault edit {{FILE}}

[group('vault')]
vault-view FILE:
    ./venv/bin/ansible-vault view {{FILE}}

[group('vault')]
vault-encrypt FILE:
    ./venv/bin/ansible-vault encrypt {{FILE}}

[group('vault')]
vault-decrypt FILE:
    ./venv/bin/ansible-vault decrypt {{FILE}}