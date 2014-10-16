#!/bin/bash

# Author               :   
# Description          :
#   This tool is used to get IP by domain name resolution.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#29 Nov 2011    |   1.0.0   | Alex      | Inital Version       
# 5 Dec 2011    |   1.0.1   | Alex      | add option -v <output param name>
#28 Dec 2011    |   1.0.2   | Alex      | modified error check
# 9 Jan 2012    |   1.0.3   | Alex      | modified the option of command 'dhclient',add '-pf' option
#20 Mar 2012    |   1.0.4   | Alex      | support input ip

REV="$0 version 1.0.4 (20 Mar 2012)"
# print REV
echo "${REV}"

#colour echo
cecho() {
    case $1 in
        error)
            echo -e " $2 "
            ;;
        debug)
            echo -e " $2 "
            ;;
    esac
}

usage="usage: bash $0 -i <Domain name> -v <output param name> -o <Output file> -r <SSH_IP:USER:PSWD> [-test]\n"
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
        -test)
            echo "mode : test mode"
            U_PATH_TBIN=./
            G_CURRENTLOG=./
            G_HOST_IF0_1_0=eth1
            shift 1
            ;;        
        -i)
            DName=$2
            shift 2
            ;;        
        -v)
            PName=$2
            shift 2
            ;;
        -r)
            SSH_INFO=$2
            echo "remote ssh mode"
            SSH_IP=`echo "$SSH_INFO" | awk -F':' '{print $1}'`
            SSH_USER=`echo "$SSH_INFO" | awk -F':' '{print $2}'`
            SSH_PSWD=`echo "$SSH_INFO" | awk -F':' '{print $3}'`

            echo "SSH_IP = $SSH_IP"
            echo "SSH_USER = $SSH_USER"
            echo "SSH_PSWD = $SSH_PSWD"

            shift 2
            ;;
        -o)
            outfile=$2
            shift 2
            ;; 
        -src)
            srcip=1
            shift
            ;;
        *)
            echo -e $usage
            exit 1
            ;;
    esac
done

if [ -z "$PName" ]; then
    PName=TMP_NTP_SERVER_IP
fi

isip=`echo "$DName"|grep -o [1-9][0-9]*\.[1-9][0-9]*\.[1-9][0-9]*\.[1-9][0-9]*`
if [ "$isip" != "" ]; then
    #if [  "$srcip" == "1" ];then
    #    echo "========ip.src"
    #    echo "$PName=\"ip.src==$DName\"" | tee $outfile
    #else
    #    echo "========ip.dst"
        echo "${PName}=${DName}" | tee $outfile
    #fi
    exit 0
fi

#ps aux|grep dhclient|grep $G_HOST_IF0_1_0|grep -o "dhclient .*"|sed "s/dhclient/dhclient -r/g" |while read cmd
#do
#    echo "command :$cmd"
#    $cmd
#done
function valid_ip()
{
    local  ip=$1
    local  stat=1
    if [[ $ip =~ ^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function local_nslookup()
{
    echo "cat /etc/resolv.conf"
    cat /etc/resolv.conf
    ifconfig
    route -n
    for i in `seq 1 10`
    do  
        if [ $i -eq 10 ];then
            echo "ping $G_PROD_IP_BR0_0_0 -c 5"
            ping $G_PROD_IP_BR0_0_0 -c 5

            echo "ping $TMP_DUT_DEF_GW -c 5"
            ping $TMP_DUT_DEF_GW -c 5

            bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/cli_dut_wan_info.log
            bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/cli_dut_wan_dns.log
            exit 1
        fi
        echo "nslookup $DName"
        sleep 5
        nslookup $DName |tee $G_CURRENTLOG/nslookup.log
        cat $G_CURRENTLOG/nslookup.log
        grep -i "Address:" $G_CURRENTLOG/nslookup.log
        if [ $? -eq 0 ];then
            echo "AT_INFO : nslookup $DName Success!"
            break
        else
            echo "AT_ERROR : nslookup $DName Fail!"
        fi
    done
    echo "------------------------------------------------------------"
    awk '/Name/{p=1;x=NR}p&&NR-x<=1&&NR-x>0' $G_CURRENTLOG/nslookup.log |grep "Address:"|sed "s/Address: //g">$G_CURRENTLOG/nslookup_test.log

    TMP_NTP_SERVER_IP="`head -1 $G_CURRENTLOG/nslookup_test.log`"
    temp_ip=`head -1 $G_CURRENTLOG/nslookup_test.log`
    for line in `tail -n +2 $G_CURRENTLOG/nslookup_test.log`
    do
        temp_ip=$temp_ip"-"$line
        TMP_NTP_SERVER_IP="$TMP_NTP_SERVER_IP"" or ""ip.dst==$line"
        #    cecho debug "ip=$temp_ip"
        #    echo "##$TMP_NTP_SERVER_IP"
    done
    TMP_NTP_SERVER_IP="\"""$TMP_NTP_SERVER_IP""\""

    echo "$PName=$TMP_NTP_SERVER_IP" |tee $outfile

    if [  "$srcip" == "1" ];then
        echo "========ip.src"
        sed -i 's/\.dst=/\.src=/g' $outfile
        cat $outfile
    fi


    if [ -z "$temp_ip" ]; then
        cecho error "get \"$DName\" IP failed"
        exit 1
    else
        exit 0
    fi
}

function ssh_nslookup()
{
    ofile="/tmp/nslookup_"`date  +%Y_%m_%d_%H_%M_%S`".log"
    echo "output to file : $ofile"
    clicmd -d "$SSH_IP" -u "$SSH_USER" -p "$SSH_PSWD" -v "nslookup $DName" -o "$ofile"
    if [ $? -eq 0 ] ;then
        cat "$ofile" | grep "server can't find"
        if [ $? -eq 0 ] ;then
            echo "can not parse $DName"
            exit 1
        else
            DEST_IP=`cat "$ofile" | grep -A2 Name | grep Address | awk  '{print $2}'`
            echo "$PName=\"$DEST_IP\"" |tee $outfile

            echo "Done"
            exit 0
        fi
    else
        echo "ssh to $SSH_IP failed!"
        exit 1
    fi


}


function main()
{
    # return IP directly
    if valid_ip $DName; then
        echo "$PName=$DName" |tee $outfile
        exit 0
    fi

    # 
    if [ -z "$SSH_IP" ] ;then
        local_nslookup
    else
        ssh_nslookup
    fi


}


##
main
