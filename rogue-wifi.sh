#!/bin/bash
##
# Nicolas THIBAUT
# http://dev2lead.com
##

WLAN="wlan0"
MON="mon0"
AT="at0"

airmon-ng stop "$MON" && airmon-ng start "$WLAN"
airbase-ng --channel 11 --essid "FREEWIFI" "$MON" > airbase-ng.dump &

echo "$!" > airbase-ng.pid && sleep 10

ifconfig "$AT" up
ifconfig "$AT" 10.0.0.1 netmask 255.255.255.0

dhcpd -cf dhcpd.conf -pf dhcpd.pid "$AT"

echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
echo 1 > /proc/sys/net/ipv4/conf/default/forwarding
echo 1 > /proc/sys/net/ipv6/conf/default/forwarding
echo 1 > /proc/sys/net/ipv4/conf/eth0/forwarding
echo 1 > /proc/sys/net/ipv6/conf/eth0/forwarding
echo 1 > /proc/sys/net/ipv4/conf/lo/forwarding
echo 1 > /proc/sys/net/ipv6/conf/lo/forwarding

iptables --table nat --append POSTROUTING --out-interface eth0 --jump MASQUERADE
iptables --table mangle --append POSTROUTING --out-interface eth0 --protocol tcp --syn --jump TCPMSS --clamp-mss-to-pmtu
