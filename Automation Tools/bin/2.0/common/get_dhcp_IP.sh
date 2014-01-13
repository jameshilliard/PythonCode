#!/bin/bash
#---------------------------------
#G_CURRENTLOG=/root/automation/logs/logs140/B-GEN-TR98-BA.LANIPINTFA-004.xml_3
# Author        :   
# Description   :
#   This tool is using to used to get IP with dhclient.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | Andy      | Inital Version
#22 Dec 2011    |   2.0.0   | Andy      | copy leases file to G_CURRENTLOG,chang paser dhcp ipaddress method.
# 9 Jan 2012    |   2.0.1   | Alex      | modified the option of command 'dhclient',add '-pf' option.
#10 Jan 2012    |   2.0.2   | Alex      | modified bug,when using dhclient release card,should apply the specified interface passed in.
#20 Mar 2012    |   2.0.3   | Alex      | add function to disable all clients when connect a new client to DUT by dhcp 
#16 May 2012    |   2.0.4   | Ares      | add function to  negtive test and support specified dhclient lease file

REV="$0 version 2.0.4 (16 May 2012)"
# print REV
echo "${REV}"

createlogname(){
    lognamex=$1
    echo "ls $G_CURRENTLOG/$lognamex*"
    ls $G_CURRENTLOG/$lognamex* 2> /dev/null
    if [  $? -gt 0 ]; then
        echo "file not exists"
        echo -e " so the current file to be created is : "$lognamex""
        currlogfilename=$lognamex
    else
        echo "file exists"
        curr=`ls $G_CURRENTLOG/$lognamex*|wc -l`
        let "next=$curr"
        echo -e " so the current file to be created is : "${lognamex}_$next""
        currlogfilename="${lognamex}_$next"
    fi
}

get_network(){
    ipaddr=$1
    _sys1=`head -n 1 /etc/issue | grep Ubuntu`
    isUbuntu=$?
    _sys2=`head -n 1 /etc/issue | grep Fedora`
    isFC=$?
    if [ "$isUbuntu" == "0" ];then
        #echo "System : $_sys1"
        #echo "ipcalc -n $ipaddr"
        #ipcalc -n $ipaddr
        rc="$(/usr/bin/ipcalc -n $ipaddr|grep Network|awk '{print $2}' ) "
    elif [ "$isFC" == "0" ];then
        #echo "System : $_sys2"
        #echo "ipcalc -n $ipaddr"
        #ipcalc -n $ipaddr
        rc="$(ipcalc -n $ipaddr)"
    fi
    #echo "subnet : $rc"
}

is_in_same_subnet(){
    IP1=$1
    IP2=$2
    get_network $IP1
    subnet1=`echo $rc | tr -d ' '`
    get_network $IP2
    subnet2=`echo $rc | tr -d ' '`
    #echo "IP($IP1) in network : $subnet1"
    #echo "IP($IP2) in network : $subnet2"
    if [ -z "$subnet1" ];then
        rc=1
        #echo "$rc : ($subnet1) is empty"
    else
        if [ "${subnet1}" == "${subnet2}" ];then
            rc=0
            #echo "0"
        else
            rc=1
            #echo "$rc : ($subnet1) is not equal to ($subnet2)"
        fi
    fi
}

disable_others_same_subnet(){
    SRC_IF=$1
    SRC_IPADDR=$2
    if [ -z "$SRC_IPADDR" ]; then
        SRC_IPADDR=`ip addr show scope global | grep global| grep $1 |awk '{print $2}'`
    fi
    echo "source ipaddr is : $SRC_IPADDR"
    if [ -z "$SRC_IPADDR" ]; then
        return
    fi
    ss=`ip addr show scope global | grep global | awk '{ if($7) {if (ifname!=$7) print $7":"$2 } }' ifname=$SRC_IF`
    echo -e "----------\nall NICs : \n$ss\n-----------------"
    for line in $ss;do
        #echo "Line : $line"
        _itf=`echo $line | cut -d: -f 1`
        _itf_ip=`echo $line | cut -d: -f 2`
        is_in_same_subnet $SRC_IPADDR $_itf_ip
        if [ "$rc" == "0" ];then
            echo "$_itf($_itf_ip) is in the same subnet with $SRC_IF($SRC_IPADDR)"
            echo "release ip for $_itf"
            ip -4 addr flush dev $_itf
        else
            echo "$_itf($_itf_ip) is not in the same subnet with $SRC_IF($SRC_IPADDR)"
        fi
    done

}
disable_all_in_subnet(){
    SRC_IPADDR=$1

    echo "source ipaddr is : $SRC_IPADDR"
    if [ -z "$SRC_IPADDR" ]; then
        echo "AT_ERROR : subnet ip is required "
        return
    fi
    ss=`ip addr show scope global | grep global | awk '{ if($7) { print $7":"$2 } }'`
    echo -e "----------\nall NICs : \n$ss\n-----------------"
    for line in $ss;do
        #echo "Line : $line"
        _itf=`echo $line | cut -d: -f 1`
        _itf_ip=`echo $line | cut -d: -f 2`
        is_in_same_subnet $SRC_IPADDR $_itf_ip
        if [ "$rc" == "0" ];then
            echo "$_itf($_itf_ip) is in the same subnet with $SRC_IF($SRC_IPADDR)"
            echo "release ip for $_itf"
            ip -4 addr flush dev $_itf
        else
            echo "$_itf($_itf_ip) is not in the same subnet with $SRC_IF($SRC_IPADDR)"
        fi
    done
}

kill_dhclient_only(){
    echo -e "Kill all dhclient ps before do dhclient"
    dhc_ps_list=`ps aux |grep dhclient|grep -v "grep"|awk '{print $2}'`
    echo 'dhc_ps_list is:'$dhc_ps_list
    if [ "$dhc_ps_list" == "" ] ;then
        echo "No dhclient process running"
    else
        for dhclient_ps in  $dhc_ps_list
        do
            process_detail=`ps aux |grep $dhclient_ps|grep -v "grep"`
            echo -e "kill dhclient process:$process_detail"
            kill -9 $dhclient_ps
        done

    fi
    process_detail_after_kill=`ps aux |grep $dhclient_ps|grep -v "grep"`
    echo "process_detail_after_kill is :"$process_detail_after_kill
    if [ "$process_detail_after_kill" == "" ];then
        echo "kill dhclient process passed!"
    fi
}


usage="Usage: $0 -i <interface> -o <dhcp ip file> -l <dhclient lease file> [-n: negtive test ] [-k: kill dhclient only] [-h]\nexpample:\n$0 -i eth1 -o DHCPIP.log\n"
Need_Negtive_test=no
Need_kill_dhclient_only=no
while getopts ":i:l:o:htnk" opt ;
do
    case $opt in
        i)
            interface=$OPTARG
            echo "Interface : ${interface}"
            ;;
        o)
            output=$OPTARG
            echo "ouputfile : ${output}"
            ;;
        h)
            echo -e $usage
            exit 0
            ;;
        t)
            G_CURRENTLOG=/root/tmp
            ;;
        l)  
            echo -e "Specify dhclient lease file"
            dhclient_lease_file=$OPTARG
            ;;
        n)
            echo -e "Negtive test,the dhclient should return error message \"No working leases in persistent database\""
            Need_Negtive_test=yes
            ;;
        k)
            echo -e "Kill dhclient only,default is release dhclient first before do dhclient"
            Need_kill_dhclient_only=yes
            ;;
        ?)
            paralist=-1
            echo "ERROT: '-$OPTARG' not supported."
            echo -e $usage
            exit 1
            ;;
    esac
done

if [ -z "$interface" ]; then
    echo -e " Haven't specified interface,use default interface: eth1 "
    interface=eth1
fi

# create leases file path
echo  -e "interface:"$interface
if [ -z $dhclient_lease_file ];then
    createlogname ${interface}.leases
else
    createlogname `basename $dhclient_lease_file`
fi

leasesfile=/tmp/$currlogfilename
rm -f $leasesfile

echo -e "Need_kill_dhclient_only="$Need_kill_dhclient_only
if [ "$Need_kill_dhclient_only" == "yes" ];then
    kill_dhclient_only
else
    echo "dhclient -r $interface"
    ps aux|grep dhclient|grep $interface|grep -o "dhclient .*"|sed "s/dhclient /dhclient -r /g" |while read cmd
do
    echo "command :$cmd"
    $cmd
done
    echo "rm -f /tmp/${interface}.pid"
    rm -f /tmp/${interface}.pid
fi

disable_all_in_subnet $G_PROD_GW_BR0_0_0/24
echo "Need_Negtive_test is:"$Need_Negtive_test

if [ "$Need_Negtive_test" == "no" ];then
    echo "dhclient -v $interface -lf $leasesfile -pf /tmp/${interface}.pid"
    dhclient -v $interface -lf $leasesfile -pf /tmp/${interface}.pid
    cat $leasesfile
    grep -i "option  *routers  *[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" $leasesfile 
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to get ip by dhcp"
        exit 1
    else
        dhclient_pid=`ps aux | grep "dhclient \-v $interface \-lf $leasesfile \-pf \/tmp\/${interface}\.pid" | grep -v "grep" | awk '{print $2}'`

        if [ "$dhclient_pid" ] ;then
            echo "kill -9 $dhclient_pid"
            kill -9 "$dhclient_pid"
        fi
    fi

    # copy leases file to current log
    if [ -f "$leasesfile" ] ;then
        echo "cp $leasesfile $G_CURRENTLOG/$currlogfilename"
        mv $leasesfile $G_CURRENTLOG/$currlogfilename
    else
        echo "AT_ERROR : failed create $leasesfile"
        exit 1
    fi

    ifconfig $interface 
    route -n

    ipcount=`grep -ic "fixed-address" $G_CURRENTLOG/$currlogfilename`
    if [ $ipcount -eq 1 ] ;then
        if [ -n "$output" ]; then
            echo "create $output !"
            ifconfig $interface | grep "inet addr" | awk '{print $2}' | awk -F: '{print "TMP_TR069_LANDHCP_DHCP_IP=" $2}' | tee $G_CURRENTLOG/$output
        fi
    else
        echo "AT_ERROR : bad dhclient leases file,failed to get ip by dhcp"
        exit 1
    fi
    exit 0
fi
if  [ "$Need_Negtive_test" == "yes" ];then
    echo -e "Need negtive test!"
    echo "dhclient -v $interface -lf $leasesfile -pf /tmp/${interface}.pid" 
    dhclient -v $interface -lf $leasesfile  -pf /tmp/${interface}.pid
    echo -e "Currentlog is :"$G_CURRENTLOG/$currlogfilename
    ifconfig $interface |tee $G_CURRENTLOG/$currlogfilename 
    result=`grep "inet addr" $G_CURRENTLOG/$currlogfilename`
    echo $result
    if [ -z "$result" ];then
        echo -e "Negtive test Passed! "
        exit 0
    else
        echo -e "AT_ERROR :Negtive test filed,the interface\:$interface has got ip from dhcp!  "
        dhclient_pid=`ps aux | grep "dhclient \-v $interface \-lf $leasesfile \-pf \/tmp\/${interface}\.pid" | grep -v "grep" | awk '{print $2}'`
        if [ "$dhclient_pid" ] ;then
            echo "kill -9 $dhclient_pid"
            kill -9 "$dhclient_pid"
        fi
        exit 1
    fi
fi
