# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Ansible project managing personal infrastructure: bare-metal/VM host setup and Docker-based service stacks (no docker-compose CLI — stacks are deployed via `community.docker.docker_compose_v2`, not `docker-compose` binary). No custom roles — each service lives as a self-contained playbook directory under `playbooks/`.

## Setup

```bash
just install    # creates venv/, installs ansible + ansible-lint, installs galaxy collections from requirements.yml
```

All ansible commands run from `venv/bin/` (justfile prepends it to PATH).

## Common commands

```bash
just run [FILE] [LIMIT]   # ansible-playbook playbooks/{FILE}.yml -i inventories -l {LIMIT}; FILE defaults to "site", LIMIT to "localhost"
just syntax [FILE]        # --syntax-check, FILE defaults to "site"
just lint                 # ansible-lint over the repo
just clean                # dump inventory, wipe fact cache + *.retry/*.log

just vault-create FILE
just vault-edit FILE
just vault-view FILE
just vault-encrypt FILE
just vault-decrypt FILE
```

To target a specific playbook/host directly (no just):

```bash
./venv/bin/ansible-playbook -i inventories -l <host_or_group> playbooks/<name>.yml --ask-vault-pass
```

`--syntax-check` (via `just syntax <name>`) is the fastest sanity check before a real run — no target infra needed.

## Architecture

- **`inventories/`** is a git submodule (private repo `ansible-inventories`) — holds `hosts.yml` and `host_vars/*.yml` (including vaulted secrets). Not visible/editable from this repo checkout beyond what's committed as the submodule pointer; also gitignored at this level to prevent accidental partial commits. Ask before assuming its contents.
- **`playbooks/<service>/`** — one directory per deployed service (traefik, authelia, nextcloud, paperless, forgejo, vaultwarden, ntfy, koffan, ...). Each typically has:
  - `setup.yml` (sometimes `teardown.yml`, `restore.yml`, `runner.yml`) targeting a `<service>_group` host group from inventory
  - `templates/` — Jinja2 templates (usually `compose.yml` + service config) rendered to the remote host, commonly notifying a `restart <service>` handler
  - occasionally `files/` for static copies and a `README.md` with example invocation
- **Top-level `*.yml` playbooks** (`apps.yml`, `authentik.yml`, `harden.yml`, `matrix.yml`, `webserver.yml`) either `import_playbook` a set of sub-playbooks (see `apps.yml` → `playbooks/apps/*.yml`) or are standalone plays; `playbooks/apps/` holds per-app installers targeting `workstation_group`.
- Deploy pattern per service: ensure data dir → template configs/env (secrets via `ansible_vault`-encrypted vars, e.g. `TRAEFIK_IONOS_API_KEY`) → bring compose stack up/restarted via `community.docker.docker_compose_v2`. Vars follow `<SERVICE>_<NAME>` naming (e.g. `TRAEFIK_DATA_PATH`, `PAPERLESS_DATA_PATH`), sourced from inventory `host_vars`.
- No `roles/` directory currently exists despite `ansible.cfg` declaring `roles_path = roles` — everything is flat playbooks + templates.
- Collections required: `community.docker`, `community.general` (see `requirements.yml`).
