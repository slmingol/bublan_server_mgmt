.PHONY: help list ping ping-docker uptime

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
@echo "  print-hwinfo     @echo "  print-hwinfo     @echo "  prio "@echo "  print-hwinfo     ri@ecyt@echo "  print-hwinfo     @echo "  print-hwinfo    @echo "he@echo "  print-hwinfo     le hardware)"
@echo ""
@echo "Utilities:"
@echo "  list             @echo "  list             @echo "  list             @  @echo "  list             @echo "  list             @echke@echo "t:@echo "  list         as@echo "  list             @echo "  list             @echo "  Fi@echo "  list             @echo "  list             @echo "  lis \@echo "  list             @echo "  list             @echoonnectivity tests
ping:
ansible -i inv -m ping all -l '!pikvms' -o

ping-docker:
ping-doc -ping-doc -ping-doc -ping-doc -pits' -o

uptime:
ansible -i inv -m shell -a uptime all -o
ansible -i inv -m shell -a uptime all -o
ts' -o
     @ein     @ein     @ein     @ein     @ein     @ein     @oo     nv -     @ein     @ein     @ein    ad     @ein     @ein     @ein     @ein     @ein     @ein 
for production)
apt-upgrade-shell:
ansible.cfg ansible.cfg  -ansiblansibl -date; apt upgrade" -b all

# Kubernetes management
reboot-k8s:
ansible -i inv -m shell -a reboot -b all -l k8s* -o

# Information gathering
list-hosts-inventory:
ansible-playbook -i inv -b update.yml --list-hosts

print-hwinfo:
ansible -i inv -m shell -a 'sudo cat /sys/firmware/devicetree/base/model; echo' -l piservers_* -b all -o \
| awk -F'|' '{print $$1 "|" $$4}' | column -t -s '|'

prprprpython-ver:
ansible-playbook -i inv -b python_ansible-plPoansible-playbook -i inv -b python_ansible-plPLENT: chk-pansible-playbook -i inv -b python_ansi sansible-playbook -i inv -b python_ansi "ansitate:" && cat /sys/class/thermal/cooling_device0/cur_state' \
-b all -l k8s*,pi-vpn* -o \
| sed 's/\\n/ /g' \
| column -t
