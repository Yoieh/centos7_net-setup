# centos7_net-setup

Quick and dirty but handy network setup skript in bash for centOS 7 that i made to make it easyer to setup network in cluster nods.

run:

`# net-setup.sh`

This will display all flags available.

`-n HOSTNAME` to set your hostname this is optional!

`-i IPADDRESS` to set your ip address.

`-f INTERFACE` to set the interface the address will be sett on. Will defult to *eth0*

Optional. If none of this flags is ditected adefult value will be placed.

`-g GATEWAYADDRESS` to set your gateway address, will defult the first ip-address in network address.
Example if ip address is *192.168.1.10* it will defult to *192.168.1.1*.

`-d1 DNSADDRESS` to set DNS1, will defult to googles free DNS1 *8.8.8.8*

`-d2 DNSADDRESS` to set DNS2, will defult to googles free DNS2 *8.8.4.4*

