ifconfig eth0_rename down
ifconfig eth1 down
ifconfig eth0_rename 192.168.100.51/24 up
ifconfig eth1 192.168.0.200/24 up
rm /etc/resolv.conf -f
echo "nameserver 10.20.10.10" >> /etc/resolv.conf
echo "nameserver 192.168.0.1" >> /etc/resolv.conf
route add default gw 192.168.0.1
route -n
ping www.google.com -I eth1 -c 2
