# centos7_net-setup

Quick and dirty but handy network setup skript in bash for centOS 7 that i made to make it easyer to setup network in cluster nods.

## run:

`# bash ./centos7_net-setup/net-setup.sh -h`

or

`# ./centos7_net-setup/net-setup.sh -h`

if the .sh file is executable else run:

`# chmod +x ./centos7_net-setup/net-setup.sh`

then:

`# ./centos7_net-setup/net-setup-sh -h`

This will display all flags available.

`-n HOSTNAME` to set your hostname this is optional!

`-i IPADDRESS` to set your ip address. Just juse if you want to over wright your */etc/sysconfig/network-scripts/ifcfg-eth*

`-f INTERFACE` to set the interface the address will be sett on. Will defult to *eth0*

Optional. If none of this flags is ditected adefult value will be placed.

`-g GATEWAYADDRESS` to set your gateway address, will defult the first ip-address in network address.
Example if ip address is *192.168.1.10* it will defult to *192.168.1.1*.

`-d DOMAIN` to set domain in */etc/hosts*, just juse on first network setup.

`-d1 DNSADDRESS` to set DNS1, will defult to googles free DNS1 *8.8.8.8*

`-d2 DNSADDRESS` to set DNS2, will defult to googles free DNS2 *8.8.4.4*

Use only this flags below if you just want to add a new host in */etc/hosts*. If you just want to change the local host when setting up network, use *-d* for DOMAIN, *-n* for HOSTNAME, *-i* for IPADDRESS. **Remeber when you use -i it will overwright /etc/sysconfig/network-scripts/ifcfg-eth**. If you dont want to reset the */etc/sysconfig/network-scripts/ifcfg-eth* juse the flags below.

`-di IPADDRESS` to set ipaddress in */etc/hosts*

`-dh DOMAIN` to set hostname.domain in */etc/hosts*

`-da ALIAS` to set alias in hosts */etc/hosts*

## example 1

`# ./centos7_net-setup/net-setup.sh -n web01 -i 192.168.1.80 -d example.com`

Will resulte with a inteface file that look like this.

`# vim /etc/sysconfig/network-scripts/ifcfg-TEST1`

```txt
TYPE=Ethernet
BOOTPROTO=static
GATEWAY=192.168.1.1
IPADDR=192.168.1.80
NETMASK=255.255.255.0
DEVICE=TEST1
ONBOOT=yes
DNS1=8.8.8.8
DNS2=8.8.4.4
```
and a hostname that will be *web01* in */etc/hostname*.

This will also add *192.168.1.80 web01.example.com web01* in */etc/hosts*

If you aret happy chose some more flags!

## example 2

`# ./centos7_net-setup/net-setup.sh -i 192.168.10.20 -g 192.168.10.2 -d1 192.168.10.10`

`# vim /etc/sysconfig/network-scripts/ifcfg-eth0`

```txt
TYPE=Ethernet
BOOTPROTO=static
GATEWAY=192.168.10.2
IPADDR=192.168.10.20
NETMASK=255.255.255.0
DEVICE=eth0
ONBOOT=yes
DNS1=192.168.10.10
DNS2=8.8.4.4
```

## example 3

`# ./centos7_net-setup/net-setup.sh -di 192.168.1.10 -dh example.com -da web02`

This will add a new host to */etc/hosts*.

`# vim /etc/hosts`

```txt
...
192.168.1.10 web02.example.com web02
...
```
