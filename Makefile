.PHONY: help list ping ping-docker cfg-docker uptime install-deps venv lint lint-yaml lint-ansible setup-precommit precommit-run

# Default target - show help
help:
	@echo "Bublan Server Management - Available targets:"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  venv               Create virtual environment (recommended)"
	@echo "  install-deps       Install dependencies to user directory"
	@echo "  setup-precommit    Install and configure pre-commit hooks"
	@echo ""
	@echo "Connectivity Tests:"
	@echo "  ping               Ping all hosts (excluding pikvms)"
	@echo "  ping-docker        Ping Docker hosts only"
	@echo "  uptime             Check uptime on all hosts"
	@echo ""
	@echo "Configuration:"
	@echo "  cfg-docker         Configure Docker hosts (run main playbook)"
	@echo ""
	@echo "Linting & Validation:"
	@echo "  lint               Run all linting checks"
	@echo "  lint-yaml          Run YAML linting"
	@echo "  lint-ansible       Run Ansible linting"
	@echo "  precommit-run      Run pre-commit on all files"
	@echo ""
	@echo "Utilities:"
	@echo "  list               List all Makefile targets"
	@echo "  help               Show this help message"
	@echo ""
	@echo "For system updates, see mgmt/Makefile"

# List all targets in Makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
	| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
	| sort \
	| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Install Python dependencies (user-level installation)
install-deps:
	@echo "Installing Python dependencies..."
	pip3 install --user -r requirements.txt
	@echo "Installing Ansible Galaxy collections..."
	ansible-galaxy collection install -r requirements.yml
	@echo "Dependencies installed successfully!"
	@echo ""
	@echo "Note: Packages installed to user directory (~/.local/bin)"
	@echo "Ensure ~/.local/bin is in your PATH"

# Create and setup virtual environment (recommended)
venv:
	@echo "Creating virtual environment..."
	python3 -m venv venv
	@echo "Installing dependencies in virtual environment..."
	./venv/bin/pip install --upgrade pip
	./venv/bin/pip install -r requirements.txt
	./venv/bin/ansible-galaxy collection install -r requirements.yml
	@echo ""
	@echo "Virtual environment created successfully!"
	@echo "Activate it with: source venv/bin/activate"

# Ping all hosts (excluding pikvms)
ping:
	ansible -i inv all:!pikvms -m ping

# Ping Docker hosts only
ping-docker:
	ansible -i inv docker_hosts -m ping

# Check uptime on all hosts
uptime:
	ansible -i inv all:!pikvms -m shell -a "uptime"

# Configure Docker hosts
cfg-docker:
	ansible-playbook -i inv main.yml

# Run all linting checks
lint: lint-yaml lint-ansible

# Run YAML linting (project files only, excludes venv)
lint-yaml:
	yamllint *.yml tasks/ files/ .github/ .*.y*ml 2>/dev/null || true

# Run Ansible linting
lint-ansible:
	ansible-lint main.yml tasks/*.yml

# Setup pre-commit hooks
setup-precommit:
	@echo "Setting up pre-commit hooks..."
	pre-commit install
	@echo "Creating secrets baseline..."
	detect-secrets scan > .secrets.baseline || true
	@echo "Pre-commit hooks installed successfully!"

# Run pre-commit on all files
precommit-run:
	pre-commit run --all-files
