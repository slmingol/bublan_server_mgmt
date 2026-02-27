.PHONY: help list ping ping-docker uptime apt-dnf-upgrade-pb apt-upgrade-pb dnf-upgrade-pb apt-upgrade-shell pikvm-upgrade-pb k8s-upgrade-pb reboot-k8s list-hosts-inventory print-hwinfo python-ver chk-pi-throttle

# Default target - show help
help:
	@echo "Bublan Server Management - Management Tasks"
	@echo ""
	@echo "Connectivity Tests:"
	@echo "  ping                    Ping all hosts (excluding pikvms)"
	@echo "  ping-docker             Ping Docker hosts only"
	@echo "  uptime                  Check uptime on all hosts"
	@echo ""
	@echo "System Updates:"
	@echo "  apt-dnf-upgrade-pb      Update all systems (APT & DNF)"
	@echo "  apt-upgrade-pb          Update Debian/Ubuntu systems only"
	@echo "  dnf-upgrade-pb          Update Fedora systems only"
	@echo "  apt-upgrade-shell       Quick apt update via shell (not recommended)"
	@echo ""
	@echo "Specific System Updates:"
	@echo "  pikvm-upgrade-pb        Update PiKVM systems"
	@echo "  k8s-upgrade-pb          Update Kubernetes nodes"
	@echo "  reboot-k8s              Reboot Kubernetes nodes"
	@echo ""
	@echo "Information & Diagnostics:"
	@echo "  list-hosts-inventory    List all hosts in inventory"
	@echo "  print-hwinfo            Print Raspberry Pi hardware info"
	@echo "  python-ver              Check Python versions"
	@echo "  chk-pi-throttle         Check Pi throttle state"
	@echo ""
	@echo "Utilities:"
	@echo "  list                    List all Makefile targets"
	@echo "  help                    Show this help message"

# List all targets in Makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
	| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
	| sort \
	| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Connectivity tests
ping:
	ansible -i ../inv -m ping all -l '!pikvms' -o

ping-docker:
	ansible -i ../inv -m ping all -l 'docker_hosts' -o

uptime:
	ansible -i ../inv -m shell -a uptime all -o

# System updates via playbooks
apt-dnf-upgrade-pb:
	ansible-playbook -i ../inv -b update.yml

apt-upgrade-pb:
	ansible-playbook -i ../inv -b update.yml -l '!fedora_desktops'

dnf-upgrade-pb:
	ansible-playbook -i ../inv -b update.yml -l 'fedora_desktops'

pikvm-upgrade-pb:
	ansible-playbook -i ../inv -b update.yml -l 'pikvms'

k8s-upgrade-pb:
	ansible-playbook -i ../inv -b update.yml -l 'piservers_k8s'

# Quick apt update via shell (not recommended for production)
apt-upgrade-shell:
	ansible -i ../inv -m shell -a "apt update; date; apt upgrade" -b all

# Kubernetes management
reboot-k8s:
	ansible -i ../inv -m shell -a reboot -b all -l k8s* -o

# Information gathering
list-hosts-inventory:
	ansible-playbook -i ../inv -b update.yml --list-hosts

print-hwinfo:
	ansible -i ../inv -m shell -a 'sudo cat /sys/firmware/devicetree/base/model; echo' -l piservers_* -b all -o \
	| awk -F'|' '{print $$1 "|" $$4}' | column -t -s '|'

python-ver:
	ansible-playbook -i ../inv -b python_version.yml

chk-pi-throttle:
	ansible -i ../inv -m shell -a 'vcgencmd get_throttled && echo "Throttle State:" && cat /sys/class/thermal/cooling_device0/cur_state' \
	-b all -l k8s*,pi-vpn* -o \
	| sed 's/\\n/ /g' \
	| column -t
