list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | \
		egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
ping:
	ansible -i inv -m ping all

uptime:
	ansible -i inv -m shell -a uptime all

apt-upgrade1:
	ansible -i inv -m shell -a "apt update; apt upgrade" -b all

apt-upgrade2:
	ansible-playbook -i inv -b update.yml

reboot-k8s:
	ansible -i inv -m shell -a reboot -b all -l k8s*
