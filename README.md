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
        ansible-playbook -i inv -b update.yml

apt-upgrade2:
        ansible -i inv -m shell -a "apt update; apt upgrade" -b all

reboot-k8s:
        ansible -i inv -m shell -a reboot -b all -l k8s*
```

## Example
```
$ make apt-upgrade1
```

## Troubleshooting Tips

### Tip #1
#### Error Msg:
```
root@rockpi-4cplus:~# apt update
Get:1 http://apt.radxa.com/focal-stable focal InRelease [2359 B]
Hit:2 http://ports.ubuntu.com/ubuntu-ports focal InRelease
Err:1 http://apt.radxa.com/focal-stable focal InRelease
  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 9B98116C9AA302C7
Hit:3 http://ports.ubuntu.com/ubuntu-ports focal-security InRelease
Get:4 http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease [114 kB]
Hit:5 http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease
Get:6 http://ports.ubuntu.com/ubuntu-ports focal-updates/main arm64 Packages [1690 kB]
Get:7 http://ports.ubuntu.com/ubuntu-ports focal-updates/universe arm64 Packages [945 kB]
Fetched 2749 kB in 3s (1095 kB/s)
Reading package lists... Done
Building dependency tree
Reading state information... Done
35 packages can be upgraded. Run 'apt list --upgradable' to see them.
W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://apt.radxa.com/focal-stable focal InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 9B98116C9AA302C7
W: Failed to fetch http://apt.radxa.com/focal-stable/dists/focal/InRelease  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 9B98116C9AA302C7
W: Some index files failed to download. They have been ignored, or old ones used instead.
```

#### Fix
```
# Please use the following command to refresh the public key

export DISTRO=focal-stable
wget -O - apt.radxa.com/$DISTRO/public.key | sudo apt-key add -
```

REF: https://forum.radxa.com/t/sudo-apt-update-get-error/13061/3

