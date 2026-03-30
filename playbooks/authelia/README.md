# Authelia playbooks

This directory contains playbooks to deploy Authelia service.

## setup.yml

Setup Authelia on a given host.

```
ansible-playbook -i inventories -l test.sdzecom-internal.de playbooks/docker/authelia/setup.yml --ask-vault-pass
```