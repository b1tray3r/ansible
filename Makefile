.PHONY: help install setup deploy check lint clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Install Ansible collections and dependencies
	ansible-galaxy collection install -r requirements.yml

setup: ## Run software setup playbook (install Docker and common packages)
	ansible-playbook playbooks/setup_software.yml

deploy: ## Deploy Docker stacks
	ansible-playbook playbooks/deploy_stacks.yml

all: ## Run the complete site playbook
	ansible-playbook playbooks/site.yml

check: ## Run playbook in check mode (dry-run)
	ansible-playbook playbooks/site.yml --check

syntax: ## Check playbook syntax
	ansible-playbook playbooks/site.yml --syntax-check

list: ## List all tasks in site playbook
	ansible-playbook playbooks/site.yml --list-tasks

lint: ## Lint all playbooks and roles (requires ansible-lint)
	@command -v ansible-lint >/dev/null 2>&1 || { echo "ansible-lint not installed. Install with: pip install ansible-lint"; exit 1; }
	ansible-lint

clean: ## Clean temporary files and caches
	rm -rf /tmp/ansible_fact_cache/
	find . -type f -name "*.retry" -delete
	find . -type f -name "*.log" -delete

.DEFAULT_GOAL := help
