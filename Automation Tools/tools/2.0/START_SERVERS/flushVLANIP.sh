for viface in `ifconfig -a|grep "Link encap:Ethernet"|awk '{print $1}'|grep ".*\..*"`; do ip -4 addr flush dev $viface; done
