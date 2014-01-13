#!/bin/sh

$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/getipfrombhr2wan.log -d $G_HOST_TIP3_0_0 -u $G_HOST_USR3 -p $G_HOST_PWD3 -v "killall dhclient; ifdown $G_HOST_IF3_1_0; ifup $G_HOST_IF3_1_0"
