# Bublan Server Management

Ansible playbooks for managing Docker hosts and various servers in the Bublan home lab environment.

## Overview

This project provides automated configuration and management for:
- **Docker Hosts**: Multiple Docker hosts with different user configurations
- **Pi Servers**: Raspberry Pi devices running various services (PiHole, PiAware, K8s, etc.)
- **Docker Stacks**: Automated deployment and updates for Hawser, Newt, and Orb stacks

## Prerequisites

- Python 3.x
- Ansible 2.9+
- SSH access to target hosts
- Appropriate sudo privileges on target hosts

## Quick Start

### 1. Install Dependencies

```bash
make install-deps
```

This installs:
- Python dependencies from `requirements.txt`
- Ansible Galaxy collections from `requirements.yml`

### 2. Test Connectivity

```bash
# Ping all hosts
make ping

# Ping Docker hosts only
make ping-docker

# Check uptime on all hosts
make uptime
```

### 3. Configure Docker Hosts

```bash
make cfg-docker
```

## Project Structure

```
.
├── main.yml                    # Main playbook for Docker host configuration
├── inv                         # Ansible inventory file
├── ansible.cfg                 # Ansible configuration
├── Makefile                    # Common tasks and commands
├── requirements.txt            # Python dependencies
├── requirements.yml            # Ansible Galaxy dependencies
├── tasks/                      # Ansible task files
│   ├── docker.yml              # Docker daemon configuration
│   ├── docker_stack_update.yml # Reusable stack update playbook
│   └── handlers.yml            # Service handlers
├── files/                      # Static files for deployment
└── mgmt/                       # Additional management scripts
```

## Inventory Groups

### Server Groups
- `servers_core`: Core infrastructure servers (watcher, XCP-ng, Docker hosts)
- `piservers_misc`: Miscellaneous Raspberry Pi servers
- `piservers_pihole`: PiHole DNS servers
- `piservers_piaware`: Flight tracking servers
- `piservers_k8s`: Kubernetes cluster nodes
- `pikvms`: PiKVM devices

### Docker Host Groups
- `docker_hosts`: All Docker hosts (parent group)
- `docker_hosts_user_slm`: Docker hosts with user 'slm'
- `docker_hosts_user_pi`: Docker hosts with user 'pi'
- `docker_hosts_user_orangepi`: Docker hosts with user 'orangepi'
- `docker_hosts_user_rock`: Docker hosts with user 'rock'
- `docker_hosts_user_root`: Docker hosts with user 'root'

### Stack-Specific Groups
- `newt_docker_hosts`: Hosts running the Newt stack
- `orb_docker_hosts`: Hosts running the Orb stack

## Playbooks

### Main Playbook (`main.yml`)

The main playbook performs:
1. Docker daemon configuration on all Docker hosts
2. Updates to the Hawser stack
3. Updates to the Newt stack
4. Updates to the Orb stack

Run with:
```bash
ansible-playbook -i inv main.yml
```

Or use the Makefile:
```bash
make cfg-docker
```

### Docker Stack Updates

The `docker_stack_update.yml` playbook is a reusable playbook for updating Docker Compose stacks. It:
- Pulls latest images
- Rebuilds containers
- Recreates services with changes

Example usage in `main.yml`:
```yaml
- name: Update Hawser Stack
  ansible.builtin.import_playbook: tasks/docker_stack_update.yml
  vars:
    target_hosts: docker_hosts
    stack_name: hawser
    stack_path: hawser
```

## Configuration Files

### Ansible Configuration (`ansible.cfg`)

Key settings:
- Inventory file: `inv`
- Host key checking disabled
- SSH connection persistence
- Custom callbacks and output formatting

### Linting

The project includes configurations for:
- **ansible-lint**: `.ansible-lint`
- **yamllint**: `.yamlint`

Run linting:
```bash
# All linting checks
make lint

# Ansible linting only
make lint-ansible

# YAML linting only
make lint-yaml
```

### Pre-commit Hooks

The project includes pre-commit hooks to automatically check code quality before commits. This helps catch issues early and maintain consistent code standards.

**Setup pre-commit:**
```bash
make setup-precommit
```

This will:
- Install pre-commit hooks in your local git repository
- Create a secrets baseline for security scanning

**Run pre-commit manually:**
```bash
make precommit-run
```

The pre-commit configuration includes:
- Trailing whitespace removal
- End-of-file fixing
- YAML validation and linting
- Ansible playbook linting
- JSON formatting
- Python code formatting (Black)
- Python linting (Flake8)
- Secret detection

### Playbook Tags

All playbooks support tags for selective execution:

**Main tags:**
- `docker` - All Docker-related tasks
- `config` - Configuration tasks
- `stacks` - Docker stack updates
- `hawser` - Hawser stack tasks
- `newt` - Newt stack tasks
- `orb` - Orb stack tasks
- `validation` - Validation and verification tasks

**Run specific tags:**
```bash
# Only run Docker configuration (skip stack updates)
ansible-playbook -i inv main.yml --tags docker-setup

# Only update stacks (skip Docker config)
ansible-playbook -i inv main.yml --tags stacks

# Only update Hawser stack
ansible-playbook -i inv main.yml --tags hawser
```

## Common Tasks

### Check connectivity
```bash
ansible -i inv all -m ping
```

### Run ad-hoc commands
```bash
# Check uptime
ansible -i inv all -m shell -a "uptime"

# Check Docker status
ansible -i inv docker_hosts -m shell -a "docker ps"
```

### Update specific stack
```bash
ansible-playbook -i inv tasks/docker_stack_update.yml \
  -e "target_hosts=docker_hosts" \
  -e "stack_name=hawser" \
  -e "stack_path=hawser"
```

### Run on specific hosts
```bash
ansible-playbook -i inv main.yml --limit docker-host-01.bub.lan
```

## Docker Daemon Configuration

The playbook configures the Docker daemon using a custom `daemon.json` file located in `files/docker_daemon.json`. The configuration:
- Is deployed to `/etc/docker/daemon.json`
- Triggers a Docker service restart when changed
- Ensures Docker service is enabled and running

## Troubleshooting

### SSH connection issues
- Verify SSH keys are configured correctly
- Check the `ansible_ssh_user` for each host in the inventory
- Ensure you can manually SSH to the target hosts

### Docker service issues
- Check Docker service status: `systemctl status docker`
- Review Docker logs: `journalctl -u docker`
- Verify Docker daemon configuration: `cat /etc/docker/daemon.json`

### Playbook failures
- Run with increased verbosity: `ansible-playbook -vvv ...`
- Check host connectivity: `make ping`
- Review task-specific error messages

## Security Notes

- SSH keys should be used instead of passwords
- Sensitive data should use Ansible Vault
- Review sudo privileges required on target hosts
- Regularly update Ansible and dependencies

## Contributing

When making changes:
1. Test playbooks in a non-production environment first
2. Run linting before committing: `ansible-lint` and `yamllint`
3. Document any new playbooks or significant changes
4. Follow Ansible best practices

## License

See `LICENSE` file for details.

## References

- Inspired by [geerlingguy/internet-pi](https://github.com/geerlingguy/internet-pi)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Documentation](https://docs.docker.com/)
