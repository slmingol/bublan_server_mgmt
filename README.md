# Server Mgmt

## Contents

```
$ tree
.
├── LICENSE
├── Makefile
├── README.md
├── inv
├── rack_equipment_info
│   ├── hw_dimensions.txt
│   └── navepoint_9u_rack.txt
└── update.yml

1 directory, 7 files
```

## Options to drive
```
$ more Makefile
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
```
