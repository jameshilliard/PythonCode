#! /usr/bin/bash -w
perl $U_COMMONBIN/clicfg.pl -c -d $G_HOST_IP1 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -m "sftp> " -v "rm  /tmp/mtuping.sh" -v "put  $SQAROOT/bin/1.0/vz_bin/mtuping.sh  /tmp/mtuping.sh" -v "rm  /tmp/*.process" -v "rm  /tmp/*.libcab"

#IP1=`echo ${G_HOST_TIP1_1_0%/*}`
#IP2=`echo ${G_HOST_TIP1_2_0%/*}`
#IP3=`echo ${G_HOST_TIP1_3_0%/*}`
#IP4=`echo ${G_HOST_TIP1_4_0%/*}`
#IP5=`echo ${G_HOST_TIP1_5_0%/*}`
#IP6=`echo ${G_HOST_TIP1_6_0%/*}`
#IP7=`echo ${G_HOST_TIP1_7_0%/*}`
#IP8=`echo ${G_HOST_TIP1_8_0%/*}`
#IP9=`echo ${G_HOST_TIP1_9_0%/*}`
#IP10=`echo ${G_HOST_TIP1_10_0%/*}`
#
#ping $IP1 -c 5 
#
#if [ $? != 0 ]; then
#    perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "ifdown $G_HOST_IF1_1_0" -v "ifup $G_HOST_IF1_1_0"
#
#    sleep 5
#
#    perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "ifconfig $G_HOST_IF1_2_0 $IP2" -v "ifconfig $G_HOST_IF1_3_0 $IP3" -v "ifconfig $G_HOST_IF1_4_0 $IP4" -v "ifconfig $G_HOST_IF1_5_0 $IP5" -v "ifconfig $G_HOST_IF1_6_0 $IP6" -v "ifconfig $G_HOST_IF1_7_0 $IP7" -v    "ifconfig $G_HOST_IF1_8_0 $IP8" -v "ifconfig $G_HOST_IF1_9_0 $IP9" -v "ifconfig $G_HOST_IF1_10_0 $IP10"
#fi
