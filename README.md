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

## Provisioning RPi's

**NOTE:** Reboots are required to pick up changes to the RPI firmware file: `config.txt`.

The RPi's that make use of PoE HATs require having their firmware configured so that the fans do not run so loud. These options have changed over the years in Raspian, and then Ubuntu 20.04 and now 22.04 LTS. ATM these options are like this on the RPi board:

```
root@k8s-02f:/boot/firmware# ls -l /boot/firmware/config.txt
-rwxr-xr-x 1 root root 1693 Jul  9 18:13 /boot/firmware/config.txt
```

```
[all]
# Place "config.txt" changes (dtparam, dtoverlay, disable_overscan, etc.) in
# this file. Please refer to the README file for a description of the various
# configuration files on the boot partition.
#dtoverlay=rpi-poe
#dtparam=poe_fan_temp0=65000,poe_fan_temp0_hyst=5000
#dtparam=poe_fan_temp1=67000,poe_fan_temp1_hyst=2000
dtoverlay=rpi-poe-plus
dtparam=poe_fan_temp0=73000,poe_fan_temp0_hyst=2000
dtparam=poe_fan_temp1=75000,poe_fan_temp1_hyst=3000
dtparam=poe_fan_temp2=78000,poe_fan_temp2_hyst=4000
dtparam=poe_fan_temp3=82000,poe_fan_temp3_hyst=5000
```

In previous setups Ubuntu had files `syscfg.txt` and `usercfg.txt` which were `included` like so:

```
ubuntu@k8s-02a:~$ tail -10 /boot/firmware/config.txt

# The following settings are "defaults" expected to be overridden by the
# included configuration. The only reason they are included is, again, to
# support old firmwares which don't understand the "include" command.

enable_uart=1
cmdline=cmdline.txt

include syscfg.txt
include usercfg.txt
```

But this setup has been phased out, apparently, by Ubuntu 22.04 LTS. 

To help manage these settings the `Makefile` in this repo includes a target to query all the RPi devices and show their current temperature and the state of the fan. The states of the fan can be [0-4], denoting which temperature mode they're in. You can see the state of the fan like so:

```
ubuntu@k8s-02a:~$ cat /sys/class/thermal/cooling_device0/cur_state
0
```

The options around `dtparm` are what control the thresholds when the POE's fan will engage at specific temperatures and at what speed of the fan:

```
dtoverlay=rpi-poe-plus
dtparam=poe_fan_temp0=73000,poe_fan_temp0_hyst=2000
dtparam=poe_fan_temp1=75000,poe_fan_temp1_hyst=3000
dtparam=poe_fan_temp2=78000,poe_fan_temp2_hyst=4000
dtparam=poe_fan_temp3=82000,poe_fan_temp3_hyst=5000
```

Output from the `Makefile` target `chk-poe-fans`:

```
 $ ▶ make chk-poe-fans
k8s-02a.bub.lan  |  CHANGED  |  rc=0  |  (stdout)  temp=68.6'C  cur_state:  0
k8s-02c.bub.lan  |  CHANGED  |  rc=0  |  (stdout)  temp=61.3'C  cur_state:  0
k8s-02e.bub.lan  |  CHANGED  |  rc=0  |  (stdout)  temp=69.6'C  cur_state:  0
k8s-02b.bub.lan  |  CHANGED  |  rc=0  |  (stdout)  temp=62.8'C  cur_state:  0
k8s-02d.bub.lan  |  CHANGED  |  rc=0  |  (stdout)  temp=65.7'C  cur_state:  0
k8s-02f.bub.lan  |  CHANGED  |  rc=0  |  (stdout)  temp=62.3'C  cur_state:  0
k8s-02g.bub.lan  |  CHANGED  |  rc=0  |  (stdout)  temp=69.1'C  cur_state:  0
pi-vpn.bub.lan   |  CHANGED  |  rc=0  |  (stdout)  temp=66.7'C  cur_state:  0
```

### References
- https://github.com/raspberrypi/firmware/issues/1607
- https://raspberrypi.stackexchange.com/questions/98078/poe-hat-fan-activation-on-os-other-than-raspbian
- https://forums.raspberrypi.com/viewtopic.php?t=316908
- https://github.com/raspberrypi/linux/blob/rpi-5.15.y/arch/arm/boot/dts/overlays/README#L3384
- https://forums.raspberrypi.com/viewtopic.php?p=2038767

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

### Tip #2
```
NEEDRESTART_MODE=a apt upgrade -y

-or-

NEEDRESTART_MODE=a apt-get dist-upgrade --yes

REF: https://askubuntu.com/questions/1367139/apt-get-upgrade-auto-restart-services
```
