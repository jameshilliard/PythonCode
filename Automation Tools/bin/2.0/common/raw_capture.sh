#!/bin/bash

# Author               :   
# Description          :
#   This tool is used for begin capturing packets and stop capturing packets.
#    For example:
#                begin capture on Lan PC : bash raw_capture.sh --begin --local -i eth1 -o 111.cap
#                stop  capture on Lan PC : bash raw_capture.sh --stop  --local -i eth1 -o 111.cap
#    Note:When you try to stop capture(bash raw_capture.sh --stop  --local -i eth1 -o 111.cap),it will kill the 'tshark process' whose outfile is 111.cap
#         other tshark process will not be killed.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#17 May 2012    |   1.0.0   | Prince    | Initial 
#16 Jul 2012    |   1.0.1   | Prince    | add --flush
##########################################################################################################################

REV="$0 version 1.0.0 (17 May 2012)"
# print REV
echo "${REV}"

usage="usage: bash $0 -i <Interface> -f <Capture filter> -t <duration> -s <sigle packet size> -o <Output file> -b <begin capture> -s <stop capture> -l <lan pc> -r <wan pc> -d <directory> --beacon [--test]\n"

begin_capture=0
stop_capture=0
capture_on_lan=0
capture_on_wan=0
capture_on_lan2=0
flush_IP_flag=0
block_mode=False
capture_beacon=False

while [ -n "$1" ];
do
    case "$1" in
    --test)
        U_PATH_TBIN=.
        U_PATH_TOOLS=/root/automation/tools/2.0
        G_CURRENTLOG=/root/automation
        G_HOST_IP1=192.168.173.2
        G_HOST_TIP1_0_0=192.168.173.2
        G_HOST_USR1=root
        G_HOST_PWD1=123qaz

        G_HOST_IP2=192.168.173.2
        G_HOST_USR2=root
        G_HOST_PWD2=123qaz        
        G_HOST_TIP2_0_0=192.168.173.2
        shift 1
        ;;
    -b)
        begin_capture=1
        shift 1
        ;;
    --begin)
        begin_capture=1
        shift 1
        ;;
    -s)
        stop_capture=1
        shift 1
        ;;
    --stop)
        stop_capture=1
        shift 1
        ;;
    -l)
        capture_on_lan=1
        shift 1
        ;;
    --local)
        capture_on_lan=1
        shift 1
        ;;
    -lan2)
        capture_on_lan2=1
        shift 1
        ;;
    -r)
        capture_on_wan=1
        shift 1
        ;;
    --remote)
        capture_on_wan=1
        shift 1
        ;;
    -i)
        interface=$2
        shift 2
        ;;          
    -f)
        capfilter="$2"
        shift 2
        ;;       
    -t)
        timeout=$2
        shift 2
        ;;
    -d)
        cur_directory=$2
        echo "cur_directory:$cur_directory"
        shift 2
        ;;
    -o)
        outfile=$2
        shift 2
        ;;   
    -s)
        sigle_size=$2
        shift 2
        ;;
    --flush)
        flush_IP_flag=1
        shift
        ;;
    --block)
        block_mode=True
        shift
        ;;
    --beacon)
        capture_beacon=True
        shift
        ;;

    *)
        echo $usage
        echo "AT_ERROR : parameters input error!"
        exit 1
        ;;
    esac
done

if [ -z "$timeout" ]; then
    timeout=900
fi

if [ -z "$sigle_size" ]; then
    sigle_size=0
fi
if [ -z "$outfile" ]; then
    outfile=raw.cap
fi
if [ -z "$cur_directory" ];then
    cur_directory=$G_CURRENTLOG
    echo "cur_directory:$cur_directory"
fi


#outfile="`date +%Y%m%d%H%M%S`_$outfile"
#TMP_CAP_FILE="/tmp/$outfile"    
TMP_CAP_FILE="$cur_directory/$outfile"

down_mon_interface(){
    echo "Del monitor interface for wireless card $interface"
    num=`echo $interface|grep -o "[0-9][0-9]*$"`
    if [ -z "$num" ];then
        def_moniface="mon1"
    fi
    def_moniface="mon${num}"
    if [ "$capture_on_lan" == "1" ];then
        echo "lan1"
        ##del mon interface
        $U_PATH_TOOLS/netgear/wlx86 monitor 0
        ifconfig -a|tee ${cur_directory}/lan1_interface.log
        iwconfig   |tee -a ${cur_directory}/lan1_interface.log
        grep "IEEE 802.11.*Mode *: *Monitor" ${cur_directory}/lan1_interface.log
        if [ $? -eq 0 ];then
            echo "Exist TPLINK monitor interface on LAN PC 1,we begin to delete it!"
            grep "IEEE 802.11" ${cur_directory}/lan1_interface.log |grep -i "Mode *: *Monitor"|awk '{print $1}'|sort|uniq|tee ${cur_directory}/lan1_mon_interface
            for moniface in `cat ${cur_directory}/lan1_mon_interface`
            do
                    echo "iw dev $moniface del"
                    iw dev $moniface del
            done
        fi
    elif [ "$capture_on_wan" == "1" ];then
        ##del mon interface on LAN PC 2
        echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/wan_interface.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v \"$U_PATH_TOOLS/netgear/wlx86 monitor 0\" -v \"sleep 2\" -v \"ifconfig -a;iwconfig;route -n;lsusb\""
        $U_PATH_TBIN/clicmd -o ${cur_directory}/wan_interface.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "$U_PATH_TOOLS/netgear/wlx86 monitor 0" -v "sleep 2" -v "ifconfig -a;iwconfig;route -n;lsusb"
        if [ $? -ne 0 ];then
            return 1
        fi
        grep "IEEE 802.11.*Mode *: *Monitor" ${cur_directory}/wan_interface.log
        if [ $? -eq 0 ];then
            echo "Exist TPLINK monitor interface on WAN PC,we begin to delete it!"
            grep "IEEE 802.11" ${cur_directory}/wan_interface.log |grep -i "Mode *: *Monitor"|awk '{print $1}'|sort|uniq|tee ${cur_directory}/wan_mon_interface
            for moniface in `cat ${cur_directory}/wan_mon_interface`
            do
                echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/del_mon_interface_wan.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v \"iw dev $moniface del\""
                $U_PATH_TBIN/clicmd -o ${cur_directory}/del_mon_interface_wan.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "iw dev $moniface del"
                if [ $? -ne 0 ];then
                    return 1
                fi
            done
        fi
    elif [ "$capture_on_lan2" == "1" ];then
        ##del mon interface on LAN PC 2
        echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/lan2_interface.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"$U_PATH_TOOLS/netgear/wlx86 monitor 0\" -v \"sleep 2\" -v \"ifconfig -a;iwconfig;route -n;lsusb\""
        $U_PATH_TBIN/clicmd -o ${cur_directory}/lan2_interface.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "$U_PATH_TOOLS/netgear/wlx86 monitor 0" -v "sleep 2" -v "ifconfig -a;iwconfig;route -n;lsusb"
        if [ $? -ne 0 ];then
            return 1
        fi
        grep "IEEE 802.11.*Mode *: *Monitor" ${cur_directory}/lan2_interface.log
        if [ $? -eq 0 ];then
            echo "Exist TPLINK monitor interface on LAN PC 2,we begin to delete it!"
            grep "IEEE 802.11" ${cur_directory}/lan2_interface.log |grep -i "Mode *: *Monitor"|awk '{print $1}'|sort|uniq|tee ${cur_directory}/lan2_mon_interface
            for moniface in `cat ${cur_directory}/lan2_mon_interface`
            do
                echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/del_mon_interface_lan2.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"iw dev $moniface del\""
                $U_PATH_TBIN/clicmd -o ${cur_directory}/del_mon_interface_lan2.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "iw dev $moniface del"
                if [ $? -ne 0 ];then
                    return 1
                fi
            done
        fi
    else
        echo "AT_ERROR : Up monitor interface $moniface for wireless card $interface FAIL!"
        return 1
    fi


}

up_mon_interface(){
    rc=1
    down_mon_interface
    rcc=$?
    if [ $rcc -ne 0 ];then
        return 1
    fi
    echo "Up Monitor interface for wireless card $interface"
    if [ "$capture_on_lan" == "1" ];then
        echo "lan1"
        grep "^ *$interface " ${cur_directory}/lan1_interface.log
        if [ $? -ne 0 ];then
            echo "AT_ERROR : wireless card $interface not exist on LAN PC 1!"
            return 1
        fi
        ##up mon interface
        echo "ip link set $interface up"
        ip link set $interface up
        echo "lsusb|grep -i \"NetGear, Inc.* 802.11\""
        lsusb|grep -i "NetGear, Inc.*802.11"
        if [ $? -eq 0 ];then
            echo "${U_PATH_TOOLS}/netgear/wlx86 monitor 1"
            ${U_PATH_TOOLS}/netgear/wlx86 monitor 1
            moniface=`ifconfig -a|grep -o "^ *prism[0-9][0-9]*"`
        else
            moniface=$def_moniface
            echo "Monitor   interface : $moniface"
            echo "Put the wireless driver into Monitor Mode"
            echo "iw dev $interface interface add $moniface type monitor"
            iw dev $interface interface add $moniface type monitor
        fi
        sleep 2
        ip link set $moniface up
        rc=$?
    elif [ "$capture_on_wan" == "1" ];then
        grep "^ *$interface " ${cur_directory}/wan_interface.log
        if [ $? -ne 0 ];then
            echo "AT_ERROR : wireless card $interface not exist on WAN PC!"
            return 1
        fi
        ##up mon interface
        echo "grep -i \"NetGear, Inc.* 802.11\" ${cur_directory}/wan_interface.log"
        grep -i "NetGear, Inc.* 802.11" ${cur_directory}/wan_interface.log
        if [ $? -eq 0 ];then
            echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_wan -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v \"ip link set $interface up\" -v \"sleep 2\" -v \"${U_PATH_TOOLS}/netgear/wlx86 monitor 1\" -v \"sleep 2\" -v \"ifconfig -a\""
            $U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_wan -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "ip link set $interface up" -v "sleep 2" -v "${U_PATH_TOOLS}/netgear/wlx86 monitor 1" -v "sleep 2" -v "cat ${cur_directory}/add_mon_interface_wan|grep -o \"^ *prism[0-9][0-9]*\"|xargs -n1 -I % ip link set % up" -v "ifconfig"
            if [ $? -ne 0 ];then
                return 1
            fi
            moniface=`cat ${cur_directory}/add_mon_interface_wan|grep -o "^ *prism[0-9][0-9]*"`   
            rc=$?
        else
            moniface=$def_moniface
            echo "Monitor   interface : $moniface"
            echo "Put the wireless driver into Monitor Mode"
            echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_wan -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v \"iw dev $interface interface add $moniface type monitor\" -v \"sleep 2\" -v \"ip link set $moniface up\" -v \"ifconfig\""
            $U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_wan -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "iw dev $interface interface add $moniface type monitor" -v "sleep 2" -v "ip link set $moniface up" -v "ifconfig"
            rc=$?
        fi
    elif [ "$capture_on_lan2" == "1" ];then
        grep "^ *$interface " ${cur_directory}/lan2_interface.log
        if [ $? -ne 0 ];then
            echo "AT_ERROR : wireless card $interface not exist on LAN PC 2!"
            return 1
        fi
        ##up mon interface
        echo "grep -i \"NetGear, Inc.* 802.11\" ${cur_directory}/lan2_interface.log"
        grep -i "NetGear, Inc.* 802.11" ${cur_directory}/lan2_interface.log
        if [ $? -eq 0 ];then
            echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_lan2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"ip link set $interface up\" -v \"sleep 2\" -v \"${U_PATH_TOOLS}/netgear/wlx86 monitor 1\" -v \"sleep 2\" -v \"ifconfig -a\""
            $U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_lan2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "ip link set $interface up" -v "sleep 2" -v "${U_PATH_TOOLS}/netgear/wlx86 monitor 1" -v "sleep 2" -v "cat ${cur_directory}/add_mon_interface_lan2|grep -o \"^ *prism[0-9][0-9]*\"|xargs -n1 -I % ip link set % up" -v "ifconfig"
            if [ $? -ne 0 ];then
                return 1
            fi
            moniface=`cat ${cur_directory}/add_mon_interface_lan2|grep -o "^ *prism[0-9][0-9]*"`   
            rc=$?
        else
            moniface=$def_moniface
            echo "Monitor   interface : $moniface"
            echo "Put the wireless driver into Monitor Mode"
            echo "$U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_lan2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"iw dev $interface interface add $moniface type monitor\" -v \"sleep 2\" -v \"ip link set $moniface up\" -v \"ifconfig\""
            $U_PATH_TBIN/clicmd -o ${cur_directory}/add_mon_interface_lan2 -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "iw dev $interface interface add $moniface type monitor" -v "sleep 2" -v "ip link set $moniface up" -v "ifconfig"
            rc=$?
        fi
    else
        echo "AT_ERROR : Please define PC Name with -l,-r or -lan2"
        return 1
    fi
    if [ $rc == 0 ];then
        echo "AT_INFO : Up monitor interface $moniface for wireless card $interface PASS!"
        interface=$moniface
        return 0
    else
        echo "AT_ERROR : Up monitor interface $moniface for wireless card $interface FAIL!"
        return 1
    fi
}

beginCapture(){

    if [ -z "$interface" ];then
    echo "Please define the interface with \"-i\"!"&& echo $usage&& exit 1
    fi

    rm -f $cur_directory/$outfile

    if [ "$capture_on_lan" == "1" ] && [ "$capture_on_wan" == "0" ] && [ "$capture_on_lan2" == "0" ];then
        echo "Start to capture packets on LAN PC 1"
        echo "sleep 2"
        pid2kill=`ps aux|grep -v grep|grep tshark|grep "$cur_directory/$outfile"|awk '{print $2}'`
        kill -9 $pid2kill
        if [ "${flush_IP_flag}" == "1" ];then
            echo "ip -4 addr flush dev $interface"
            ip -4 addr flush dev $interface
        fi
        #Check need filter or not
        if [ -z "$capfilter" ];then
            if [ "$block_mode" == "True" ];then
                echo "No filter block mode"
                sleep 2
                echo "tshark -i $interface -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile"
                tshark -i $interface -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 1 Failed" && exit 1
                else
                    echo "AT_INFO : Capture packets on LAN PC 1 PASSED"
                fi
            else
                echo "No filter"
                sleep 2
                echo "tshark -i $interface -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile"
                nohup tshark -i $interface -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile >/dev/null 2>&1 &
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 1 Failed" && exit 1
                else
                    echo "Begin to Capture packets on LAN PC 1......."
                fi
            fi
        else
            if [ "$block_mode" == "True" ];then
                echo "Need filter:$capfilter block mode"
                sleep 2
                echo "tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile"
                tshark -i $interface -f "$capfilter" -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 1 Failed" && exit 1
                else
                    echo "AT_INFO : Capture packets on LAN PC 1 PASSED"
                fi
            else
                echo "Need filter:$capfilter"
                sleep 2
                echo "tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile"
                nohup tshark -i $interface -f "$capfilter" -a duration:$timeout -s $sigle_size -w $cur_directory/$outfile >/dev/null 2>&1 &
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 1 Failed" && exit 1
                else
                    echo "Begin to Capture packets on LAN PC 1 ......."
                fi
            fi
        fi
        echo "-------------------------------------------------------"
        echo "All tshark program on LAN PC 1: ps aux|grep -i tshark"
        ps aux|grep -i tshark
        echo "-------------------------------------------------------"

    elif [ "$capture_on_lan" == "0" ] && [ "$capture_on_wan" == "1" ] && [ "$capture_on_lan2" == "0" ];then
        echo "Start to capture packets on WAN PC"

        #Check need filter or not
        if [ -z "$capfilter" ];then
            if [ "$block_mode" == "True" ];then
                echo "No filter block mode"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"tshark -i $interface -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE\""
                perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "tshark -i $interface -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on WAN PC Failed!" && exit 1
                else
                    echo "AT_INFO : Capture packets on WAN PC PASSED"
                fi
            else
                echo "No filter"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"nohup tshark -i $interface -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE >/dev/null 2>&1 &\" -v \"sleep 5\""
                echo "sleep 2"
                sleep 2
                perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "nohup tshark -i $interface -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE >/dev/null 2>&1 &" -v "sleep 5"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on WAN PC Failed!" && exit 1
                else
                    echo "Begin to Capture packets on WAN PC......."
                fi
            fi
        else
            if [ "$block_mode" == "True" ];then
                echo "Need filter:$capfilter block mode"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE\""
                perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface"  -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on WAN PC Failed!" && exit 1
                else
                    echo "AT_INFO : Capture packets on WAN PC PASSED"
                fi
            else
                echo "Need filter:$capfilter"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"nohup tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE >/dev/null 2>&1 &\" -v \"sleep 5\""
                echo "sleep 2"
                sleep 2
                perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface"  -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "nohup tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -B 10 -w $TMP_CAP_FILE >/dev/null 2>&1 &" -v "sleep 5"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on WAN PC Failed!" && exit 1
                else
                    echo "Begin to Capture packets on WAN PC......."
                fi
            fi
        fi
    elif [ "$capture_on_lan2" == "1" ] && [ "$capture_on_wan" == "0" ] && [ "$capture_on_lan" == "0" ];then
        echo "Start to capture packets on LAN PC 2"

        #Check need filter or not
        if [ -z "$capfilter" ];then
            if [ "$block_mode" == "True" ];then
                echo "No filter block mode"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"tshark -i $interface -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE\""
                perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "tshark -i $interface -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 2 Failed!" && exit 1
                else
                    echo "AT_INFO : Capture packets on LAN PC 2 PASSED"
                fi
            else
                echo "No filter"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"nohup tshark -i $interface -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE >/dev/null 2>&1 &\" -v \"sleep 5\""
                echo "sleep 2"
                sleep 2
                perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "nohup tshark -i $interface -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE >/dev/null 2>&1 &" -v "sleep 5"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 2 Failed!" && exit 1
                else
                    echo "Begin to Capture packets on LAN PC 2......."
                fi
            fi
        else
            if [ "$block_mode" == "True" ];then
                echo "Need filter:$capfilter block mode"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE\""
                perl $U_PATH_TBIN/clicfg.pl -o 7200 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 2 Failed!" && exit 1
                else
                    echo "AT_INFO : Capture packets on LAN PC 2 PASSED"
                fi
            else
                echo "Need filter:$capfilter"
                echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v \"test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"rm -f $TMP_CAP_FILE\" -v \"nohup tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE >/dev/null 2>&1 &\" -v \"sleep 5\""
                echo "sleep 2"
                sleep 2
                perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22  -v "test \"${flush_IP_flag}\" = \"1\" && echo \"ip -4 addr flush dev $interface\" && ip -4 addr flush dev $interface" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "rm -f $TMP_CAP_FILE" -v "nohup tshark -i $interface -f \"$capfilter\" -a duration:$timeout -s $sigle_size -w $TMP_CAP_FILE >/dev/null 2>&1 &" -v "sleep 5"
                rc=$?
                echo $rc
                if [ $rc -ne 0 ] ;then
                    echo "AT_ERROR : Start capture on LAN PC 2 Failed!" && exit 1
                else
                    echo "Begin to Capture packets on LAN PC 2......."
                fi
            fi
        fi

    else
        echo "Not detect capture packets on LAN or WAN PC! Please define it with -l or -r or --local or --remote"&& echo $usage && exit 1
    fi
}

stopCapture(){
    if [ "$capture_on_lan" == "1" ] && [ "$capture_on_wan" == "0" ] && [ "$capture_on_lan2" == "0" ];then
        echo "Stop to capture packets on LAN PC 1"
        echo "sleep 2"
        sleep 2
        ps aux|grep tshark
        echo -e "\nThe tshark will be killed : \"ps aux|grep -v grep|grep tshark|grep \"$cur_directory/$outfile\"|awk '{print \$2}'\""
        pid2kill=`ps aux|grep -v grep|grep tshark|grep "$cur_directory/$outfile"|awk '{print $2}'`
        echo "pid2kill:$pid2kill"
        if [ "$pid2kill" == "" ];then
            echo "Not exist the match tshak process on LAN PC 1!" && exit 1
        else
            kill -9 $pid2kill
            rc=$?
            echo $rc
            if [ $rc -ne 0 ] ;then
                echo "AT_ERROR : Stop capture on LAN PC 1 Failed!" && exit 1
            else
                echo "Stop capture on LAN PC 1 Success......."
            fi
        fi
        
    elif [ "$capture_on_wan" == "1" ] && [ "$capture_on_lan" == "0" ] && [ "$capture_on_lan2" == "0" ];then

        echo "Stop to capture packets on WAN PC"
        echo "sleep 2"
        echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v \"sleep 2\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"sleep 2\" -v \"mv -f $TMP_CAP_FILE $cur_directory\" -v \"sleep 3\""
        sleep 2
        perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "sleep 2" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "sleep 2" -v "mv -f $TMP_CAP_FILE $cur_directory" -v "sleep 3"

        rc=$?
        echo $rc
        if [ $rc -ne 0 ] ;then
            echo "AT_ERROR : Stop capture on WAN PC Failed!" && exit 1
        else
            echo "Stop capture on WAN PC success!"
        fi

        let i=0
        while [ ! -e "$cur_directory/$outfile" ]
        do
            if [ $i -eq 3 ];then
                echo "Try 3 times ,but Copy capture files on WAN PC Fail!" && exit 1
            fi
            echo "Copy capture files on WAN PC Fail!"
            echo "$i times:Try to Copy capture files again!"
            echo "sleep 3"
            sleep 3
            perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "sleep 2" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "sleep 2" -v "mv -f $TMP_CAP_FILE $cur_directory" -v "sleep 3"
            let i=$i+1
        done
    elif [ "$capture_on_lan2" == "1" ] && [ "$capture_on_lan" == "0" ] && [ "$capture_on_wan" == "0" ];then

        echo "Stop to capture packets on LAN PC 2"
        echo "sleep 2"
        echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22 -v \"sleep 2\" -v \"ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9\" -v \"sleep 2\" -v \"mv -f $TMP_CAP_FILE $cur_directory\" -v \"sleep 3\""
        sleep 2
        perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22 -v "sleep 2" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "sleep 2" -v "mv -f $TMP_CAP_FILE $cur_directory" -v "sleep 3"

        rc=$?
        echo $rc
        if [ $rc -ne 0 ] ;then
            echo "AT_ERROR : Stop capture on LAN PC 2 Failed!" && exit 1
        else
            echo "Stop capture on LAN PC 2 success!"
        fi

        let i=0
        while [ ! -e "$cur_directory/$outfile" ]
        do
            if [ $i -eq 3 ];then
                echo "Try 3 times ,but Copy capture files on lAN PC 2 Fail!" && exit 1
            fi
            echo "Copy capture files on LAN PC 2 Fail!"
            echo "$i times:Try to Copy capture files again!"
            echo "sleep 3"
            sleep 3
            perl $U_PATH_TBIN/clicfg.pl -o 15 -l $cur_directory -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_TIP2_0_0 -i 22 -v "sleep 2" -v "ps aux|grep -v grep|grep tshark|grep \"$TMP_CAP_FILE\"|awk '{print \$2}' | xargs -n1 kill -9" -v "sleep 2" -v "mv -f $TMP_CAP_FILE $cur_directory" -v "sleep 3"
            let i=$i+1
        done
    else
        echo "Not detect capture packets on LAN or WAN PC! Please define it with -l or -r"&& echo $usage && exit 1
    fi
}


if [ "$begin_capture" == "1" ] && [ "$stop_capture" == "0" ];then
    if [ "$capture_beacon" == "True" ];then
        up_mon_interface
        if [ $? -ne 0 ];then
            exit 1
        fi
    fi
    beginCapture
elif [ "$begin_capture" == "0" ] && [ "$stop_capture" == "1" ];then
    echo "Stop to Capture packets"
    stopCapture
    if [ "$capture_beacon" == "True" ];then
        down_mon_interface
        if [ $? -ne 0 ];then
            exit 1
        fi
    fi
else
    echo "Start capture or Stop capture?I dont know,Please define it with -b or -s or --begin or --stop!" && echo $usage && exit 1
fi
