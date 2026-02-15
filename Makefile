list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
		| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
ping:
	ansible -i inv -m ping all -l '!pikvms' -o

ping-docker:
	ansible -i inv -m ping all -l 'docker_hosts' -o

cfg-docker:
	ansible-playbook -i inv main.yml

uptime:
	ansible -i inv -m shell -a uptime all -o
