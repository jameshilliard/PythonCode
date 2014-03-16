#!/bin/bash
#This tool is used to get testbed Info and br0 info

# History       :
#   DATE        |   REV     | AUTH      | INFO
# 2012-03-23    |   1.0.0   | Prince    | Inital Version

usage="usage: bash $0 <-test> -o <Output file> -l <G_CURRENTLOG> -v <target file> -s <Interface Squence> -d <lan or wan> -p <do ping test>"
output=autogettb.cfg
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        export U_PATH_TBIN=.
        export G_CURRENTLOG=.
        export G_HOST_TIP1_0_0=192.168.100.42
        export G_HOST_USR1=root
        export G_HOST_PWD1=123qaz
        export G_PROD_IP_BR0_0_0=192.168.1.1
        export U_DUT_TELNET_USER=root
        export U_DUT_TELNET_PWD=admin
        shift 1
        ;;
    -s)
        sequence=$2
        echo "parameter input : $sequence"
        shift 2
        ;;
    -d)
        pcname=$2
        echo "the pc you want to get : $pcname"
        shift 2
        ;;
    -v)
        target=$2
        shift 2
        ;;
    -p)
        pingtest=1
        shift 1
        ;;
    -o)
        output=$2
        shift 2
        ;;
    -l)
        export G_CURRENTLOG=$2
        shift 2
        ;;
    -h)
        echo -e $usage
        exit 1
        ;;
    *)
        echo -e $usage
        exit 1
        ;;
    esac
done
rm -f $G_CURRENTLOG/wan_ifconfig_a.log
rm -f $G_CURRENTLOG/wan_ifconfig_a.log
rm -f $G_CURRENTLOG/warning.log
ifconfig -a >$G_CURRENTLOG/lan_ifconfig_a.log
iwconfig >>$G_CURRENTLOG/lan_ifconfig_a.log
checketh(){
    echo -e "\033[32m "Step 1 : Check if exist 3 PCI Network Card named eth on $1" \033[0m"
    NicCount=`grep "^ *eth[0-9]" $2|awk '{print $1}'|wc -l`
    if [ $NicCount -lt 3 ];then
        echo -e "\033[31m "The number of PCI NetCard is less than 3pc on $1,Please Check it!" \033[0m"
        grep "^ *eth[0-9]" $2 
        exit 1
    fi
    grep "^ *eth[0-9]" $2
}
getNic(){
    echo -e "\033[32m "Step 2 : Get PCI Network Card Info of $1" \033[0m"
    num=0
    flag=0
    if [ "$1" == "WANPC" ];then
        flag=1
    fi
    let seqflag=flag+1
    echo "seqflag=$seqflag"

    defseq="`grep "^ *eth[0-9] *Link" $2|awk '{print $1}'|sort`"

    if [ -z "$sequence" ];then
        seq="$defseq"
    else
        seq=`echo $sequence|awk -F: '{print $'${seqflag}'}'|sed 's/,/ /g'`
        let cardnum=`echo "$seq"|awk '{print NF}'`
        echo "cardnum=$cardnum"
        if [ $cardnum -ne 3 ] && [ $cardnum -gt 0 ];then
            echo -e "\033[31m "You must define 3 Network Cards!" \033[0m"
            exit 1
        fi
        echo "seq=$seq"
        if [ -z "$seq" ];then
            seq=$defseq
        fi
        echo "seq=$seq"
    fi

    for var in $seq
    do
        grep "^ *${var} " $2
        if [ "$?" != "0" ];then
            echo -e "\033[31m "The NetWork Card ${var} on $1 not exist!" \033[0m"
            echo "sequence=$sequence"
            exit 1
        fi
        echo "G_HOST_IF${flag}_${num}_0=${var}" | tee -a $G_CURRENTLOG/$output
        echo "G_HOST_TIP${flag}_${num}_0=`grep -A 1 "^ *${var} " $2|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`" | tee -a $G_CURRENTLOG/$output
        echo "G_HOST_TMASK${flag}_${num}_0=`grep -A 1 "^ *${var} " $2|grep "Mask:"|awk -F: '{print $4}'`"  | tee -a $G_CURRENTLOG/$output
        echo "G_HOST_MAC${flag}_${num}_0=`grep -A 1 "^ *${var} " $2|grep HWaddr|awk '{print $5}'`"  | tee -a $G_CURRENTLOG/$output
        echo "G_HOST_GW${flag}_${num}_0="| tee -a $G_CURRENTLOG/$output
        echo ""   | tee -a $G_CURRENTLOG/$output
        let num=num+1
    done
}
getWL(){
    echo -e "\033[32m "Step 3 : Get wireless card Interface and MAC on $1" \033[0m"
    num=1
    flag=
    if [ "$1" == "WANPC" ];then
            flag=WAN_
    fi
    for var in `grep "IEEE 802.11" $2 |awk '{print $1}'|sort`
    do
        if [ $num -eq 1 ];then
            echo "U_${flag}WIRELESSINTERFACE=${var}"  | tee -a $G_CURRENTLOG/$output
            echo "U_${flag}WIRELESSCARD_MAC=`grep "^ *$var " $2|grep HWaddr|awk '{print $5}'`"  | tee -a $G_CURRENTLOG/$output
            echo ""  >>$G_CURRENTLOG/$output
        elif [ $num -gt 1 ];then
            echo "U_${flag}WIRELESSINTERFACE${num}=${var}"  | tee -a $G_CURRENTLOG/$output
            echo "U_${flag}WIRELESSCARD_MAC${num}=`grep "^ *$var " $2|grep HWaddr|awk '{print $5}'`"  | tee -a $G_CURRENTLOG/$output
            echo ""   | tee -a $G_CURRENTLOG/$output
        fi
        let num=num+1
    done
}

updatetbcfg(){
    echo -e "\033[32m "Step 4 : Start to update the $target" \033[0m"
    paralist=`grep -v "^#" $G_CURRENTLOG/$output`
    for para in $paralist
    do
        varname=`echo $para |awk -F= '{print $1}'`
        varvalue=`echo $para |awk -F= '{print $2}'`
        grep "$varname .*=" $target
        if [ $? -eq 0 ];then
            sed -i "s/$varname .*=.*/$varname = $varvalue/g" $target  
            #grep "$varname .*=" $target|sed -i "s/= .*/= $varvalue/g"  
        else
            echo -e "\033[31m "$varname not exist in $target" \033[0m" |tee -a $G_CURRENTLOG/warning.log
        fi
    done
}

get_env(){    
    echo -e "\033[32m "Step 5 : Start to get env var in $1" \033[0m"       
    paralist=`grep -v "^#" "$1"|sed 's/-v //g'|sed 's/ //g'|sed 's/^ *//g'|sed 's/ *$//g'`
    for para in $paralist
    do
        export $para
        curvar=`echo $para |awk -F= '{print $2}'`
        if [ -z "$curvar" ];then
           echo -e "\033[31m "$para \ \ \ \ is Null in $1" \033[0m" |tee -a $G_CURRENTLOG/warning.log
        fi
    done
}

checkinsamesubnet(){
    echo -e "\033[32m "Step 6 : Start to check eth1 eth2\'s IP and GW is in same subnet or not" \033[0m"
    eth1ipnet=`ipcalc -n $G_HOST_TIP0_1_0/24`
    eth1gwnet=`ipcalc -n $G_HOST_GW0_1_0/24`
    if [ "$eth1ipnet" != "$eth1gwnet" ];then
        echo "G_HOST_IF0_1_0=$G_HOST_IF0_1_0"
        echo "G_HOST_TIP0_1_0=$G_HOST_TIP0_1_0"
        echo "G_HOST_GW0_1_0=$G_HOST_GW0_1_0"
        echo -e "\033[31m "The $G_HOST_IF0_1_0 IP and GW not in same subnet on LAN PC!" \033[0m" |tee -a $G_CURRENTLOG/warning.log
    fi
    eth2ipnet=`ipcalc -n $G_HOST_TIP0_2_0/24`
    eth2gwnet=`ipcalc -n $G_HOST_GW0_2_0/24`
    if [ "$eth2ipnet" != "$eth2gwnet" ];then
        echo "G_HOST_IF0_2_0=$G_HOST_IF0_2_0"
        echo "G_HOST_TIP0_2_0=$G_HOST_TIP0_2_0"
        echo "G_HOST_GW0_2_0=$G_HOST_GW0_2_0"
        echo -e "\033[31m "The $G_HOST_IF0_2_0 IP and GW not in same subnet on LAN PC!" \033[0m" |tee -a $G_CURRENTLOG/warning.log
    fi
}

checkConnect(){
    echo -e "\033[32m "Step 7 : Start to Check Lan and Wan connection status" \033[0m"
    ping $G_PROD_IP_BR0_0_0 -I $G_HOST_TIP0_1_0 -c 2
    test "$?" != "0" && echo -e "\033[31m "ping $G_PROD_IP_BR0_0_0 -I $G_HOST_TIP0_1_0 Fail!" \033[0m" |tee -a $G_CURRENTLOG/warning.log

    ping $G_HOST_TIP1_0_0 -I $G_HOST_TIP0_0_0 -c 2
    test "$?" != "0" && echo -e "\033[31m "ping $G_HOST_TIP1_0_0 -I $G_HOST_TIP0_0_0 Fail!" \033[0m" |tee -a $G_CURRENTLOG/warning.log

    ping $G_HOST_TIP1_2_0 -I $G_HOST_TIP0_1_0 -c 2
    test "$?" != "0" && echo -e "\033[31m "ping $G_HOST_TIP1_2_0 -I $G_HOST_TIP0_1_0 Fail!" \033[0m" |tee -a $G_CURRENTLOG/warning.log

    ping $G_HOST_TIP1_1_0 -I $G_HOST_IF0_1_0 -c 2
    test "$?" != "0" && echo -e "\033[31m "ping $G_HOST_TIP1_1_0 -I $G_HOST_IF0_1_0 Fail!" \033[0m" |tee -a $G_CURRENTLOG/warning.log
}


bash $U_PATH_TBIN/cli_dut.sh -v br0.info -o $G_CURRENTLOG/$output

lpc=`echo $pcname |grep '[lL][Aa][Nn]'`
wpc=`echo $pcname |grep '[Ww][Aa][Nn]'`
echo "lpc=$lpc"
echo "wpc=$wpc"
if [ -z "$pcname" ] || [ -n "$lpc" ];then
    echo -e "\n########LAN PC">>$G_CURRENTLOG/$output
    checketh LANPC $G_CURRENTLOG/lan_ifconfig_a.log
    echo "G_HOST_IP0="|tee -a $G_CURRENTLOG/$output
    echo "G_HOST_USR0="|tee -a $G_CURRENTLOG/$output
    echo "G_HOST_PWD0="|tee -a $G_CURRENTLOG/$output
    echo "" |tee -a $G_CURRENTLOG/$output
    getNic LANPC $G_CURRENTLOG/lan_ifconfig_a.log
    aaaa=`grep G_HOST_TIP0_0_0 $G_CURRENTLOG/$output |awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    sed -i "s/^ *G_HOST_IP0 *=.*/G_HOST_IP0=$aaaa/g" $G_CURRENTLOG/$output
    sed -i "s/^ *G_HOST_GW0_1_0 *=.*/G_HOST_GW0_1_0=$G_PROD_IP_BR0_0_0/g" $G_CURRENTLOG/$output
    sed -i "s/^ *G_HOST_GW0_2_0 *=.*/G_HOST_GW0_2_0=$G_PROD_IP_BR0_0_0/g" $G_CURRENTLOG/$output
    getWL LANPC $G_CURRENTLOG/lan_ifconfig_a.log
fi

if [ -z "$pcname" ] || [ -n "$wpc" ];then

    echo -e "\n\033[32m "SSH to Wan PC to get the NIC Info..." \033[0m"
    perl sshcli.pl -o $G_CURRENTLOG/wan_ifconfig_a.log $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "ifconfig -a;iwconfig"
    rc=$?
    if [ $rc -eq 0 ];then
        echo -e "\n########WAN PC" >>$G_CURRENTLOG/$output
        checketh WANPC $G_CURRENTLOG/wan_ifconfig_a.log
        echo "G_HOST_IP1=$G_HOST_TIP1_0_0"|tee -a $G_CURRENTLOG/$output
        echo "G_HOST_USR1=$G_HOST_USR1"|tee -a $G_CURRENTLOG/$output
        echo "G_HOST_PWD1=$G_HOST_PWD1"|tee -a $G_CURRENTLOG/$output
        echo "" |tee -a $G_CURRENTLOG/$output
        getNic WANPC $G_CURRENTLOG/wan_ifconfig_a.log
        getWL WANPC $G_CURRENTLOG/wan_ifconfig_a.log
    else
        echo -e "\n\033[31m "SSH To Wan PC Fail!" \033[0m" && exit 1
    fi
fi

echo "target file=$target"
if [ -n "$target" ];then
    updatetbcfg
    get_env $target
    checkinsamesubnet
else
    get_env $G_CURRENTLOG/$output
    checkinsamesubnet
fi

if [ "$pingtest" == "1" ];then
    checkConnect
else
    echo -e "\033[33m "Step 7 : Not do ping testing" \033[0m"
fi

if [ -n "$target" ];then
    cat "$target"
else
    cat $G_CURRENTLOG/$output
fi

echo -e "\n\n\n\033[33m "All Warning Info,Please check them!" \033[0m"
cat $G_CURRENTLOG/warning.log
