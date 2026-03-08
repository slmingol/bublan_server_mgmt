# Bublan Server Management - Copilot Instructions

## Project Overview

**Purpose**: Ansible playbooks for automated Docker host and Raspberry Pi server management in the Bublan home lab environment

**Type**: Infrastructure-as-Code (Ansible)  
**Tech Stack**: Ansible 10.x (ansible-core 2.17+), Python 3.x, YAML  
**Deployment**: Ansible playbook execution against remote SSH hosts  
**Repository**: https://github.com/slmingol/bublan_server_mgmt

## Build & Validation

### Setup
```bash
make venv && source venv/bin/activate  # Create venv (recommended)
make install-deps                       # Or install to user directory
```
**Dependencies**: ansible, ansible-lint, yamllint, jmespath, pre-commit + Galaxy collections (community.general, community.docker, ansible.posix)

### Common Commands
```bash
make ping                          # Test connectivity (~1-2s)
make cfg-docker                    # Deploy config + update stacks
ansible-playbook -i inv main.yml --tags docker,stacks  # Selective run
make lint                          # Run yamllint + ansible-lint
```

**Linting**: yamllint (`.yamlint`), ansible-lint (production profile), pre-commit hooks (YAML/JSON validation, Black, detect-secrets)

## Project Layout

```
bublan_server_mgmt/
├── main.yml                    # Main playbook (Docker config + stack updates)
├── inv                         # Ansible inventory file (hosts/groups)
├── ansible.cfg                 # Ansible configuration
├── Makefile                    # Automation targets
├── requirements.txt            # Python dependencies
├── requirements.yml            # Ansible Galaxy collections
├── tasks/
│   ├── docker.yml              # Docker daemon configuration
│   ├── docker_stack_update.yml # Reusable stack deployment playbook
│   └── handlers.yml            # Service restart handlers
├── files/
│   └── docker_daemon.json      # Docker daemon.json template
└── mgmt/                       # Additional management playbooks
    ├── check_python.yml        # Python version verification
    ├── update.yml              # System update tasks
    └── python_ver.yml          # Python version management
```

**Key Files**:
- **inv**: Inventory with 10+ host groups (docker_hosts, piservers_*, servers_core)
- **main.yml**: Orchestrates Docker config + Hawser/Newt/Orb stack updates
- **tasks/docker.yml**: Manages `/etc/docker/daemon.json`, restarts Docker service
- **tasks/docker_stack_update.yml**: Reusable playbook for `docker compose up -d` stack deployment

## Inventory Groups

| Group | Purpose | User |
|-------|---------|------|
| `docker_hosts` | All Docker hosts | Various (slm, pi, orangepi, rock, root) |
| `docker_hosts_user_*` | By SSH user | Subgroups per user type |
| `newt_docker_hosts`/`orb_docker_hosts` | Stack-specific hosts | Stack targeting |
| `piservers_*` | Pi servers (pihole, piaware, k8s, misc) | pi user |
| `servers_core` | Core infrastructure | Mixed users |

```bash
ansible -i inv docker_hosts -m ping              # All Docker hosts
ansible -i inv all:!pikvms -m shell -a "uptime"  # Exclude PiKVMs
```

## Architecture & Workflows

### Docker Host Config: Validate → Deploy daemon.json → Restart Docker (3 retries, 5s delay) → Verify (`docker ps`)

### Stack Updates (via `tasks/docker_stack_update.yml`)
Variables: `target_hosts`, `stack_name`, `stack_path`  
Process: Check stack dir → Verify `docker-compose.yml` → `docker compose up -d` (retry on failure)

**Stacks**: Hawser (all docker_hosts), Newt (newt_docker_hosts), Orb (orb_docker_hosts, path: orb-net)

**Tags**: `--tags docker` (daemon config), `--tags stacks` (all stacks), `--tags hawser,newt,orb` (specific stacks)

## Development Workflow

**Testing**: `make lint` → `ansible-playbook --syntax-check main.yml` → `ansible-playbook -i inv main.yml --check --limit hostname.bub.lan` (dry run single host) → Deploy

**Adding Stacks**: Create inventory group → Ensure `~/stackname/docker-compose.yml` exists on hosts → Add import_playbook block to `main.yml` with vars (target_hosts, stack_name, stack_path)

## Known Issues

- **Stack Directory Not Found**: Ensure `~/stackname/docker-compose.yml` exists on target hosts before running stack updates
- **Docker Service Restart Hangs**: Retry logic handles most cases (3 retries, 5s delay). Manually check Docker if persistent.
- **Pre-commit Autofixes**: Run `make precommit-run` before commit to avoid repeated commit cycles

## Configuration

**ansible.cfg**: `nocows=True`, `inventory=./inv`, `interpreter_python=auto_silent`  
**Docker Daemon**: `files/docker_daemon.json` deployed to `/etc/docker/daemon.json` on all Docker hosts  
**Pre-commit**: YAML/JSON/Ansible linting, Black formatter, detect-secrets (see `.pre-commit-config.yaml`)

## Documentation

- **README.md**: Full project docs, inventory groups, playbook usage
- **IMPROVEMENTS.md**: Feb 2026 changelog (error handling, pre-commit, tags)
- **Makefile**: `make help` for all targets
- **Inspired by**: https://github.com/geerlingguy/internet-pi

## Trust Statement

This repository follows Ansible best practices with production-level linting. The codebase is actively maintained with recent improvements (Feb 2026) including enhanced error handling, pre-commit hooks, and comprehensive documentation. All playbooks use idempotent tasks and include retry logic for critical operations.

**Validation**: Run `make lint` before committing. All playbooks should pass `ansible-lint` with production profile and `yamllint` checks.
