list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
		| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
ping:
	ansible -i inv -m ping all -o

uptime:
	ansible -i inv -m shell -a uptime all -o

pikvm-upgrade-pb:
	ansible-playbook -i inv -b update.yml -l pikvms

apt-dnf-upgrade-pb:
	ansible-playbook -i inv -b update.yml

apt-upgrade-pb:
	ansible-playbook -i inv -b update.yml -l servers:piservers

dnf-upgrade-pb:
	ansible-playbook -i inv -b update.yml -l fedora_desktops

apt-upgrade-shell:
	ansible -i inv -m shell -a "apt update; apt upgrade" -b all

reboot-k8s:
	ansible -i inv -m shell -a reboot -b all -l k8s* -o

print-hwinfo:
	ansible -i inv -m shell -a 'sudo cat /sys/firmware/devicetree/base/model;echo' -l piservers -b all -o

print-python-ver:
	ansible-playbook -i inv -b python_ver.yml

.SILENT:
chk-poe-fans:
	ansible -i inv -m shell \
		-a 'vcgencmd measure_temp; echo "cur_state:" && cat /sys/class/thermal/cooling_device0/cur_state' \
		-b all -l k8s*,pi-vpn* -o \
		| sed 's/\\n/ /g' \
		| column -t
