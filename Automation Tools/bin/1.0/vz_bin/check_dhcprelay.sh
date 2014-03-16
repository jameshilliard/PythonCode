#!/bin/sh

HOST=`echo ${G_HOST_TIP2_0_0%/*}`
HOSTRM=`echo ${G_HOST_TIP1_1_0%/*}`
$U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/pingtoremote.log -d $HOST -u $G_HOST_USR2 -p $G_HOST_PWD2 -v "ping $HOSTRM -c 1"
