#!/bin/bash
# Program
#      This tool is used to get DUT default infomation.
#
#
# History
#     DATE    |   REV   |   AUTH   |    INFO        |
#  2012/05/31 |  1.0.0  |  Prince  | Inital Version |
#  2012/07/20 |  1.0.1  |  Prince  | Get testbed standard info by dhclient |
#  2012/08/28 |  1.0.2  |  Prince  | add check wireless card on LAN PC 2   |
#  2012/09/03 |  1.0.3  |  Prince  | tool will error if exist warning.info   |

VER="1.0.0"
echo "$0 version : ${VER}"


USAGE()
{
    cat <<usge
USAGE
     
OPTIONS
    -dut  : get dut info
    -br0  : br0 info
    -b    : br0 ip
    -u    : telnet user name
    -p    : telnet password
    -port : telnet port

    -tbs  : get standard testbed info
    -tba  : get actual testbed info
    -wan  : wan ip,username,password
    -s    : eth interface sequence
    -wi   : wan ip
    -wu   : wan user name
    -wp   : wan password

    -o    : output file    
    -l    : output file path,just the path

    -d    : LAN or WAN
    -v    : update target file
    -ping : do ping test

EXAMPLES   
     bash $0 [--test] -dut -br0 192.168.0.1:admin:admin1
     bash $0 [--test] -tbs -wan 192.168.100.42:root:actiontec
     bash $0 [--test] -wan 192.168.100.42:root:actiontec -o output.log -l ./

NOTES 
     1.if you DON'T run this script in testcase , please put [--test] option in front of other options
     2.the [-l] and [-o] parameter can be omitted,in that case,the output file will be in \$G_CURRENTLOG

usge
}

function cecho(){
    case "$1" in
        "pass")
            #color is green
            echo -e "====== $2"
            ;;
        "warn")
            #color is yellow
            echo -e "====== $2"
            ;;
        "fail")
            #color is red
            echo -e "====== $2"
            ;;
        *)
            echo "====== $1"
            ;;
    esac
}

function get_dut_def_value(){
    cecho pass "Entry function get_dut_def_value : Start to Get DUT default value!"
    echo -e "\n########DUT">>${logpath}/${outlog}
    for i in ${array[*]}
    do
        operation=$i
        rm -f ${logpath}/${operation}.log
        cecho "bash ${U_PATH_TBIN}/cli_dut.sh -v ${operation} -o ${logpath}/${operation}.log"
        sleep 2/
        bash $U_PATH_TBIN/cli_dut.sh -v ${operation} -o ${logpath}/${operation}.log
        if [ "$?" -ne "0" ];then
                cecho fail "bash $U_PATH_TBIN/cli_dut.sh -v ${operation} -o ${logpath}/${operation}.log"
                cecho fail "AT_ERROR : Get DUT ${operation} Failed!"
                exit 1
        fi
        cat ${logpath}/${operation}.log|grep -v "^#"|grep -v "U_WIRELESSINTERFACE*="|grep -v "U_WIRELESSCARD_MAC*="|sed '/^$/d'|sed 's/^ *//g' >> ${logpath}/${outlog}
    done
    if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
        echo "U_WIRELESS_RADIUS_SERVER=$G_HOST_TIP1_2_0" >> ${logpath}/${outlog}
    else
        echo "U_WIRELESS_RADIUS_SERVER=`grep TMP_DUT_DEF_GW ${logpath}/wan.info.log|awk -F= '{print $2}'`" >> ${logpath}/${outlog}
    fi
}

function assembleInterface(){
    echo "Entry:assembleInterface" 
    pc=$1
    echo "pc:$pc"
    if [ "$pc" == "LAN1" ];then
        echo "LAN1"
        if [ -n "${sequence}" ];then
            seqlan1=`echo ${sequence}|awk -F: '{print $1}'`
            cecho "$pc PC Custom NIC Interface : $seqlan1"
            if [ -z "$seqlan1" ];then
                seqlan1=(${deflan1seq[*]})
            else
                seqlan10=`echo ${sequence}|awk -F: '{print $1}'|awk -F, '{print $1}'`
                if [ -z "$seqlan10" ];then
                    seqlan10=$G_HOST_IF0_0_0
                fi
                seqlan11=`echo ${sequence}|awk -F: '{print $1}'|awk -F, '{print $2}'`
                if [ -z "$seqlan11" ];then
                    seqlan11=$G_HOST_IF0_1_0
                fi
                seqlan12=`echo ${sequence}|awk -F: '{print $1}'|awk -F, '{print $3}'`
                if [ -z "$seqlan12" ];then
                    seqlan12=$G_HOST_IF0_2_0
                fi
                seqlan1=($seqlan10 $seqlan11 $seqlan12)
            fi
        else
            seqlan1=(${deflan1seq[*]})
        fi
        #if [ "${seqlan1[0]}" == "${seqlan1[1]}" ] || [ "${seqlan1[1]}" == "${seqlan1[2]}" ] || [ "${seqlan1[0]}" == "${seqlan1[2]}" ] || [ "${seqlan1[0]}" == "" ] || [ "${seqlan1[1]}" == "" ] || [ "${seqlan1[2]}" == "" ];then
        #    cecho fail "After assemble LAN PC 1 Interface : ${seqlan1[0]},${seqlan1[1]},${seqlan1[2]},  exist same name OR some vaule is NULl!"
            #USAGE
            #exit 1
        #fi
        #cecho pass "After assmeble LAN PC 1 Interface : ${seqlan1[0]},${seqlan1[1]},${seqlan1[2]},"
    elif [ "$pc" == "LAN2" ];then
        echo "LAN2"
        if [ -n "${sequence}" ];then
            seqlan2=`echo ${sequence}|awk -F: '{print $3}'`
            cecho "$pc PC Custom NIC Interface : $seqlan2"
            if [ -z "$seqlan2" ];then
                seqlan2=(${deflan2seq[*]})
            else
                seqlan20=`echo ${sequence}|awk -F: '{print $3}'|awk -F, '{print $1}'`
                if [ -z "$seqlan20" ];then
                    seqlan20=$G_HOST_IF2_0_0
                fi
                seqlan21=`echo ${sequence}|awk -F: '{print $3}'|awk -F, '{print $2}'`
                if [ -z "$seqlan21" ];then
                    seqlan21=$G_HOST_IF2_1_0
                fi
                seqlan22=`echo ${sequence}|awk -F: '{print $3}'|awk -F, '{print $3}'`
                if [ -z "$seqlan22" ];then
                    seqlan22=$G_HOST_IF2_2_0
                fi
                seqlan2=($seqlan20 $seqlan21 $seqlan22)
            fi
        else
            seqlan2=(${deflan2seq[*]})
        fi
        #if [ "${seqlan2[0]}" == "${seqlan2[1]}" ] || [ "${seqlan2[1]}" == "${seqlan2[2]}" ] || [ "${seqlan2[0]}" == "${seqlan2[2]}" ] || [ "${seqlan2[0]}" == "" ] || [ "${seqlan2[1]}" == "" ] || [ "${seqlan2[2]}" == "" ];then
        #    cecho fail "After assmeble LAN PC 2 Interface : ${seqlan2[0]},${seqlan2[1]},${seqlan2[2]}, exist same name OR some vaule is NULl!"
            #USAGE
            #exit 1
        #fi
        #cecho pass "After assmeble LAN PC 2 Interface : ${seqlan2[0]},${seqlan2[1]},${seqlan2[2]},"
    elif [ "$pc" == "WAN" ];then
        echo "WAN"
        if [ -n "${sequence}" ];then
            seqwan=`echo ${sequence}|awk -F: '{print $2}'`
            cecho "$pc  PC Custom NIC Interface : $seqwan"
            if [ -z "$seqwan" ];then
                seqwan=(${defwanseq[*]})
            else
                seqwan0=`echo ${sequence}|awk -F: '{print $2}'|awk -F, '{print $1}'`
                if [ -z "$seqwan0" ];then
                    seqwan0=$G_HOST_IF1_0_0
                fi
                if [ "$ThreeCard" -eq "0" ];then
                    seqwan1=`echo ${sequence}|awk -F: '{print $2}'|awk -F, '{print $2}'`
                    if [ -z "$seqwan1" ];then
                        seqwan1=$G_HOST_IF1_1_0
                    fi
                    seqwan2=`echo ${sequence}|awk -F: '{print $2}'|awk -F, '{print $2}'`
                    if [ -z "$seqwan2" ];then
                        seqwan2=$G_HOST_IF1_2_0
                    fi
                    seqwan=($seqwan0 $seqwan1 $seqwan2)
                else
                    seqwan1=`echo ${sequence}|awk -F: '{print $2}'|awk -F, '{print $2}'`
                    if [ -z "$seqwan1" ];then
                        seqwan1=$G_HOST_IF1_2_0
                    fi
                    seqwan=($seqwan0 $seqwan1)
                fi
                
            fi
        else
            seqwan=(${defwanseq[*]})
        fi
        #if [ "${seqwan[0]}" == "" ] || [ "${seqwan[1]}" == "" ];then
        #    cecho fail "After assemble WAN PC Interface : ${seqwan[0]},${seqwan[1]}, some vaule is NULl!"
        #    USAGE
        #    exit 1
        #fi
        #cecho pass "After assmeble WAN   PC Interface : ${seqwan[0]},${seqwan[1]},"
    fi
}

function checkNIC(){
    pc=$1
    log=$2
    seq=$3
    cecho pass "Entry function checkNIC : Start to Check PCI Network Card of ${pc}"
    cecho "pc : $pc"
    cecho "log : $log "
    cecho "interface : $seq"
    for i in $seq
    do
        cecho "$i"
        grep "^ *$i" ${log}
        if [ "$?" != "0" ];then
            cecho fail "$i not exist on $1 PC" && exit 1
        fi
    done
}

getNic(){
    echo "$ThreeCard"
    echo "**************************************************************************************"
    pc=$1
    log=$2
    seq="$3"
    cecho pass "Entry function getNic : Start to Get NIC Info of $pc"
    cecho "pc : $pc"
    cecho "log : $log "
    cecho "interface : ($seq)"
    if [ "$pc" == "LAN1" ];then
        flag=0
    elif [ "$pc" == "WAN" ];then
        flag=1
    elif [ "$pc" == "LAN2" ];then
        flag=2
    fi
    
    num=0
    for var in $seq
    do
        echo "Interface:$var"
        echo "G_HOST_IF${flag}_${num}_0=${var}" | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TIP${flag}_${num}_0=`grep -A 1 "^ *${var} " ${log}|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`" | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TMASK${flag}_${num}_0=`grep -A 1 "^ *${var} " ${log}|grep "Mask:"|awk -F: '{print $4}'`"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_MAC${flag}_${num}_0=`grep -A 1 "^ *${var} " ${log}|grep HWaddr|awk '{print $5}'`"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_GW${flag}_${num}_0="| tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        if [ "$pc" == "WAN" ] && [ "$ThreeCard" -ne "0" ];then
            let num=num+2
        else
            let num=num+1
        fi
    done
}

function getWL(){
    cecho pass "Entry function getWL : Start to Get wireless card Info of $pc"
    pc=$1
    log=$2
    cecho "pc : $pc"
    cecho "log : $log "
    num=1
    flag=
    if [ "$pc" == "WAN" ];then
            flag=WAN_
    elif [ "$pc" == "LAN2" ];then
        flag=LAN2_
    fi

    #check if exist monitor interface and delete it
    grep "IEEE 802.11.*Mode *: *Monitor" $log
    if [ $? -eq 0 ];then
        cecho "Exist TPLINK monitor interface on $pc,we begin to delete it!"
        grep "IEEE 802.11" $log |grep -i "Mode *: *Monitor"|awk '{print $1}'|sort|uniq|tee ${logpath}/mon_interface_$pc
        for moniface in `cat ${logpath}/mon_interface_$pc`
        do
            if [ "$pc" == "LAN1" ];then
                echo "iw dev $moniface del"
                iw dev $moniface del
            elif [ "$pc" == "WAN" ];then
                echo "$U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_wan.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v \"iw dev $moniface del\""
                $U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_wan.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "iw dev $moniface del"
            elif [ "$pc" == "LAN2" ];then
                echo "$U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_lan2.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"iw dev $moniface del\""
                $U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_lan2.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "iw dev $moniface del"
            fi
        done
    else
        cecho "NOT Exist TPLINK monitor interface on $pc"
    fi

    grep -i "^ *prism[0-9]* *Link" $log
    if [ $? -eq 0 ];then
        cecho "Exist Netgear monitor interface on $pc,we begin to delete it!"
        if [ "$pc" == "LAN1" ];then
            echo "$U_PATH_TOOLS/netgear/wlx86 monitor 0"
            $U_PATH_TOOLS/netgear/wlx86 monitor 0
        elif [ "$pc" == "WAN" ];then
            echo "$U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_wan.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v \"$U_PATH_TOOLS/netgear/wlx86 monitor 0\""
            $U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_wan.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "$U_PATH_TOOLS/netgear/wlx86 monitor 0"
        elif [ "$pc" == "LAN2" ];then
            echo "$U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_lan2.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"$U_PATH_TOOLS/netgear/wlx86 monitor 0\""
            $U_PATH_TBIN/clicmd -o ${logpath}/del_mon_interface_lan2.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "$U_PATH_TOOLS/netgear/wlx86 monitor 0"
        fi
    else
        cecho "NOT Exist NETGEAR monitor interface on $pc"
    fi 

    cecho "wireless interface of $pc :"
    
    #if [ "$pc" == "LAN1" ] ;then

    #    echo "cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/"
    #    cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/
    #    sleep 5
    #    echo "depmod -a"
    #    depmod -a
    #    sleep 10
    #    echo "modprobe bcm_usbshim"
    #    modprobe bcm_usbshim
    #    sleep 10
    #    echo "modprobe wl"
    #    modprobe wl
    #    sleep 10
    #    lanwl=`ifconfig -a|grep -i "^ *wlan"`
    #    echo "wireless card : $lanwl"
    #    if [ "$lanwl" == "" ];then
    #        cecho fail "NO exist wireless interface on LAN PC 1!"
    #        exit 1
    #    else
    #        rm -f ${logpath}/lan1_ifconfig.log
    #        ifconfig -a|tee ${logpath}/lan1_ifconfig.log
    #        iwconfig   |tee -a ${logpath}/lan1_ifconfig.log
    #    fi
    #elif [ "$pc" == "LAN2" ];then
    #        echo "$U_PATH_TBIN/clicmd -o ${logpath}/load_driver.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/\" -v \"sleep 5\" -v \"depmod -a\" -v \"sleep 10\" -v \"modprobe bcm_usbshim\" -v \"sleep 10\" -v \"modprobe wl\" -v \"sleep 10\""
    #        $U_PATH_TBIN/clicmd -o ${logpath}/load_driver.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "cp $U_PATH_TOOLS/netgear/*  /lib/modules/2.6.38.6-26.rc1.fc15.i686.PAE/kernel/drivers/net/" -v "sleep 5" -v "depmod -a" -v "sleep 10" -v "modprobe bcm_usbshim" -v "sleep 10" -v "modprobe wl" -v "sleep 10"
    #        rm -f ${logpath}/lan2_ifconfig.log
    #        $U_PATH_TBIN/clicmd -o ${logpath}/lan2_ifconfig.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "ifconfig -a;iwconfig;route -n"
    #fi

    grep "^ *wlan" $log |grep -vi "Mode *: *Monitor"|awk '{print $1}'|sort|uniq|tee ${logpath}/wirelessinterface_$pc
    wlannum=`cat ${logpath}/wirelessinterface_$pc|wc -l`
    cecho "wireless card num : $wlannum"

    for var in `cat ${logpath}/wirelessinterface_$pc`
    do
        if [ ${num} -eq 1 ];then
            echo "U_${flag}WIRELESSINTERFACE=${var}"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "U_${flag}WIRELESSCARD_MAC=`grep "^ *$var " $log|grep HWaddr|awk '{print $5}'`"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        elif [ ${num} -gt 1 ];then
            echo "U_${flag}WIRELESSINTERFACE${num}=${var}"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "U_${flag}WIRELESSCARD_MAC${num}=`grep "^ *$var " $log|grep HWaddr|awk '{print $5}'`"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        fi
        let num=${num}+1
    done

    if [ "$pc" == "LAN1" ] ;then
        if [ $wlannum -eq 0 ];then
            cecho fail "NO exist wireless interface on LAN PC 1!"
            exit 1
        elif [ $wlannum -eq 1 ];then
            echo "U_${flag}WIRELESSINTERFACE2=wlan99"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "U_${flag}WIRELESSCARD_MAC2=AA:BB:CC:DD:EE:FF"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        fi

        #check wireless card type
        echo "lsusb|grep -i \"NetGear, Inc.* 802.11\""
        lsusb|grep -i "NetGear, Inc.*802.11"
        if [ $? -eq 0 ];then
            export U_TMP_USING_NTGR=1
            echo "U_TMP_USING_NTGR=1"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        fi

        echo "lsusb|grep -i \"Atheros Communications, Inc.*802.11\""
        lsusb|grep -i "Atheros Communications, Inc.*802.11"
        if [ $? -eq 0 ];then
            export U_TMP_USING_TPLINK=1
            echo "U_TMP_USING_TPLINK=1"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        fi
        
    elif [ "$pc" == "LAN2" ] ;then
        if [ $wlannum -eq 0 ];then
            cecho fail "NO exist wireless interface on LAN PC 2!"
            #exit 1
        elif [ $wlannum -eq 1 ];then
            echo "U_${flag}WIRELESSINTERFACE2=wlan98"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "U_${flag}WIRELESSCARD_MAC2=AA:BB:CC:CC:EE:FF"  | tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        fi
    fi
}

putENV(){
    cecho pass "Entry function putENV : Start to put var to ENV!"       
    paralist=`grep "=" "${logpath}/${outlog}"|grep -v "^#"|grep -v "G_HOST_GW[012]_0_0"|sed 's/-v //g'|sed 's/ //g'|sed 's/^ *//g'|sed 's/ *$//g'`
    for para in $paralist
    do
        export $para
        curvar=`echo $para |awk -F= '{print $2}'`
        if [ -z "$curvar" ];then
           cecho fail "$para is Null in ${logpath}/${outlog}" |tee -a ${logpath}/warning.log
        fi
    done
}

function updatetb(){
    cecho pass "Entry function updatetb : Start to update the ${target}"
    if [ ! -f "${target}" ];then 
        cecho fail "The target file ${target} not exist!" && exit 1
    fi
    paralist=`cat ${logpath}/testbed.cfg|grep -v "^#" |grep -v "^ *#"|grep -v "= *$"`
    for para in $paralist
    do
        varname=`echo $para |awk -F= '{print $1}'`
        varvalue=`echo $para |awk -F= '{print $2}'`
        grep "$varname .*=" $target
        if [ $? -eq 0 ];then
            sed -i "s/$varname .*=.*/$varname = $varvalue/g" $target  
        else
            cecho fail "\$${varname} not exist in ${target}!" |tee -a ${logpath}/warning.log
        fi
    done
}

function checkSegment(){
    cecho pass "Entry function checkSegment : Start to check NIC IP and GW!"
    
    eth1ipnet=`ipcalc -n $G_HOST_TIP0_1_0/24`
    eth1gwnet=`ipcalc -n $G_HOST_GW0_1_0/24`
    eth2ipnet=`ipcalc -n $G_HOST_TIP0_2_0/24`
    eth2gwnet=`ipcalc -n $G_HOST_GW0_2_0/24`

    if [ "$eth1ipnet" != "$eth1gwnet" ];then
        echo "G_HOST_IF0_1_0=$G_HOST_IF0_1_0"
        echo "G_HOST_TIP0_1_0=$G_HOST_TIP0_1_0"
        echo "G_HOST_GW0_1_0=$G_HOST_GW0_1_0"
        cecho fail "G_HOST_IF0_1_0($G_HOST_IF0_1_0) and G_HOST_GW0_1_0($G_HOST_GW0_1_0) NOT in same subnet of LAN PC 1 !" |tee -a ${logpath}/warning.log
        exit 1
    fi    
    if [ "$eth2ipnet" != "$eth2gwnet" ];then
        echo "G_HOST_IF0_2_0=$G_HOST_IF0_2_0"
        echo "G_HOST_TIP0_2_0=$G_HOST_TIP0_2_0"
        echo "G_HOST_GW0_2_0=$G_HOST_GW0_2_0"
        cecho fail "G_HOST_IF0_2_0($G_HOST_IF0_2_0) and G_HOST_GW0_2_0($G_HOST_GW0_2_0) NOT in same subnet of LAN PC 1 !" |tee -a ${logpath}/warning.log
        exit 1
    fi

    if [ -n "$G_HOST_IP2" ];then
        lan2eth1ipnet=`ipcalc -n $G_HOST_TIP2_1_0/24`
        lan2eth1gwnet=`ipcalc -n $G_HOST_GW2_1_0/24`
        lan2eth2ipnet=`ipcalc -n $G_HOST_TIP2_2_0/24`
        lan2eth2gwnet=`ipcalc -n $G_HOST_GW2_2_0/24`

        if [ "${lan2eth1ipnet}" != "${lan2eth1gwnet}" ];then
            echo "G_HOST_IF2_1_0=$G_HOST_IF2_1_0"
            echo "G_HOST_TIP2_1_0=$G_HOST_TIP2_1_0"
            echo "G_HOST_GW2_1_0=$G_HOST_GW2_1_0"
            cecho fail "G_HOST_IF2_1_0($G_HOST_IF2_1_0) and G_HOST_GW2_1_0($G_HOST_GW2_1_0) NOT in same subnet of LAN PC 2 !" |tee -a ${logpath}/warning.log
            exit 1
        fi    
        if [ "${lan2eth2ipnet}" != "${lan2eth2gwnet}" ];then
            echo "G_HOST_IF2_2_0=$G_HOST_IF2_2_0"
            echo "G_HOST_TIP2_2_0=$G_HOST_TIP2_2_0"
            echo "G_HOST_GW2_2_0=$G_HOST_GW2_2_0"
            cecho fail "G_HOST_IF2_2_0($G_HOST_IF2_2_0) and G_HOST_GW2_2_0($G_HOST_GW2_2_0) NOT in same subnet of LAN PC 2 !" |tee -a ${logpath}/warning.log
            exit 1
        fi
        if [ "$G_HOST_IP2" != "$G_HOST_TIP2_0_0" ];then
            cecho fail "G_HOST_IP2 ($G_HOST_IP2) != G_HOST_TIP2_0_0 ($G_HOST_TIP2_0_0)"|tee -a ${logpath}/warning.log
            exit 1
        fi
    fi

    if [ "$G_HOST_IP0" != "$G_HOST_TIP0_0_0" ];then
        cecho fail "G_HOST_IP0 :($G_HOST_IP0) != G_HOST_TIP0_0_0 ($G_HOST_TIP0_0_0) of LAN PC 1 !"|tee -a ${logpath}/warning.log
        exit 1
    fi
    if [ "$G_HOST_IP1" != "$G_HOST_TIP1_0_0" ];then
        cecho fail "G_HOST_IP1 ($G_HOST_IP1) != G_HOST_TIP1_0_0 ($G_HOST_TIP1_0_0) of WAN PC !"|tee -a ${logpath}/warning.log
        exit 1
    fi
}

checkConnect(){
    cecho pass "Entry function checkConnect : Start to Check Lan and Wan connection status!"

    ping $G_PROD_IP_BR0_0_0 -I $G_HOST_TIP0_1_0 -c 2
    test "$?" != "0" && cecho fail "ping $G_PROD_IP_BR0_0_0 -I $G_HOST_TIP0_1_0 Fail!"|tee -a ${logpath}/warning.log

    ping $G_HOST_TIP1_0_0 -I $G_HOST_TIP0_0_0 -c 2
    test "$?" != "0" && cecho fail "ping $G_HOST_TIP1_0_0 -I $G_HOST_TIP0_0_0 Fail!"|tee -a ${logpath}/warning.log

    ping $G_HOST_TIP1_2_0 -I $G_HOST_TIP0_1_0 -c 2
    test "$?" != "0" && cecho fail "ping $G_HOST_TIP1_2_0 -I $G_HOST_TIP0_1_0 Fail!"|tee -a ${logpath}/warning.log

    ping $G_HOST_TIP1_1_0 -I $G_HOST_IF0_1_0 -c 2
    test "$?" != "0" && cecho fail "ping $G_HOST_TIP1_1_0 -I $G_HOST_IF0_1_0 Fail!"|tee -a ${logpath}/warning.log
}

function chcekknownvar(){
    cecho pass "Entry function checkknownvar : Start to Check known variable!"
    #test -z "$G_HOST_DNS0" && cecho fail "G_HOST_DNS0 is NULL!" && exit 1
    #test -z "$G_HOST_DNS1" && cecho fail "G_HOST_DNS1 is NULL!" && exit 1
    
    test -z "$U_DUT_TELNET_USER" && cecho fail "U_DUT_TELNET_USER is NULL!" && exit 1
    test -z "$U_DUT_TELNET_PWD" && cecho fail "U_DUT_TELNET_PWD is NULL!" && exit 1
    test -z "$U_DUT_TELNET_PORT" && cecho fail "U_DUT_TELNET_PORT is NULL!" && exit 1
    
    test -z "$G_HOST_IP0" && cecho fail "G_HOST_IP0 is NULL!" && exit 1
    test -z "$G_HOST_USR0" && cecho fail "G_HOST_USR0 is NULL!" && exit 1
    test -z "$G_HOST_PWD0" && cecho fail "G_HOST_PWD0 is NULL!" && exit 1
    test -z "$G_HOST_IF0_0_0" && cecho fail "G_HOST_IF0_0_0 is NULL!" && exit 1
    #test -z "$G_HOST_GW0_0_0" && cecho fail "G_HOST_GW0_0_0 is NULL!" && exit 1
    test -z "$G_HOST_IF0_1_0" && cecho fail "G_HOST_IF0_1_0 is NULL!" && exit 1
    #test -z "$G_HOST_IF0_2_0" && cecho fail "G_HOST_IF0_2_0 is NULL!" && exit 1
    
    test -n "$G_HOST_IP2" -a -z "$G_HOST_USR2" && cecho fail "G_HOST_USR2 is NULL!" && exit 1
    test -n "$G_HOST_IP2" -a -z "$G_HOST_PWD2" && cecho fail "G_HOST_PWD2 is NULL!" && exit 1
    test -n "$G_HOST_IP2" -a -z "$G_HOST_IF2_0_0" && cecho fail "G_HOST_IF2_0_0 is NULL!" && exit 1
    test -n "$G_HOST_IP2" -a -z "$G_HOST_IF2_1_0" && cecho fail "G_HOST_IF2_1_0 is NULL!" && exit 1
    test -n "$G_HOST_IP2" -a -z "$G_HOST_IF2_2_0" && cecho fail "G_HOST_IF2_2_0 is NULL!" && exit 1
    
    test -z "$G_HOST_IP1" && cecho fail "G_HOST_IP1 is NULL!"
    test -z "$G_HOST_USR1" && cecho fail "G_HOST_USR1 is NULL!"
    test -z "$G_HOST_PWD1" && cecho fail "G_HOST_PWD1 is NULL!"
    test -z "$G_HOST_IF1_0_0" && cecho fail "G_HOST_IF1_0_0 is NULL!"
    #test -z "$G_HOST_IF1_1_0" && cecho fail "G_HOST_IF1_1_0 is NULL!"
    test -z "$G_HOST_IF1_2_0" && cecho fail "G_HOST_IF1_2_0 is NULL!"
}

function get_standard_tb_lan1(){
    cecho pass "Start to auto create tb.cfg about LAN PC 1"
    checkNIC LAN1 ${logpath}/lan1_ifconfig.log "${seqlan1[*]}"
    cecho pass "The Initial IP Status : ifconfig -a;route -n"
    ifconfig -a
    route -n
    echo "================================================================================================="
    if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
        $U_PATH_TBIN/clicmd -d "$G_HOST_IP1" -u "$G_HOST_USR1" -p "$G_HOST_PWD1" -m "#" -v "service dhcpd stop" -v "cd $G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/" -v "bash $G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/setup_dhcpd.sh" -v "service dhcpd restart" -v "service dhcpd status" -v "ps aux | grep -i dhcpd"
    fi
    i=1
    while true
    do
        echo "Times : $i"
        if [ $i -eq 4 ];then
            cecho fail "AT_ERROR : dhclient ${seqlan1[1]} -v -lf /tmp/auto_dect.lease"
            exit 1
        fi
        rm -f /var/lib/dhclient/*
        rm -f /tmp/auto_dect.lease

        cecho "dhclient -r ${seqlan1[1]}"
        dhclient -r ${seqlan1[1]}

        cecho "killall -9 dhclient"
        killall -9 dhclient

        cecho pass "dhclient ${seqlan1[1]} -v -lf /tmp/auto_dect.lease"        
        dhclient ${seqlan1[1]} -v -lf /tmp/auto_dect.lease
        cat /tmp/auto_dect.lease
        grep -i "option  *routers  *[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" /tmp/auto_dect.lease
        ret_code=$?
        cecho "killall -9 dhclient"
        killall -9 dhclient
        cecho $?
        if [ $ret_code -ne 0 ];then
            cecho fail "AT_ERROR : dhclient ${seqlan1[1]} -v -lf /tmp/auto_dect.lease"
        else
            ifconfig ${seqlan1[1]} |tee ${logpath}/ifconfig_${seqlan1[1]}.log
            eth1ipaddr=`cat ${logpath}/ifconfig_${seqlan1[1]}.log|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`
            echo "${seqlan1[1]} IP : $eth1ipaddr"
            rcdh=`echo "$eth1ipaddr"|grep "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"`            
            if [ "$rcdh" == "" ];then
                cecho fail "${seqlan1[1]} CAN NOT get valid IP by dhclient!"
            else
                if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
                    echo "WECB"
                    eth1segment=`echo "$eth1ipaddr"|awk -F. '{printf("%i.%i.%i."), $1,$2,$3}'`
                    cecho "nmap -sP ${eth1segment}0/24|tee ${logpath}/nmap.log"
                    nmap -sP ${eth1segment}0/24 |tee ${logpath}/nmap.log
                    cecho "cat ${logpath}/nmap.log|grep -B 2 -i \"MAC Address: ${G_PROD_MAC_BR0_0_0}\"|grep -i \"Nmap scan report for \"|grep -o \"[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\""
                    #cecho "cat ${logpath}/nmap.log|grep -B 2 -i \"MAC Address: ${G_PROD_MAC_BR0_0_0}\"|grep -i \"Nmap scan report for \"|awk '{print \$NF}'"
                    #br0_ipaddr=`cat ${logpath}/nmap.log|grep -B 2 -i "MAC Address: ${G_PROD_MAC_BR0_0_0}"|grep -i "Nmap scan report for "|awk '{print $NF}'`
                    br0_ipaddr=`cat ${logpath}/nmap.log|grep -B 2 -i "MAC Address: ${G_PROD_MAC_BR0_0_0}"|grep -i "Nmap scan report for "|grep -o "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"`
                elif [ "$U_DUT_TYPE" == "PK5K1A" ];then
                    echo "PK5K1A"
                    br0_ipaddr=`cat /tmp/auto_dect.lease | grep "option routers" | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|head -n1 2>/dev/null`

                else
                    echo "Common"
                    br0_ipaddr=`cat /tmp/auto_dect.lease | grep "option routers" | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" 2>/dev/null`
                fi
                echo "br0 IP addr : $br0_ipaddr"
                if [ "$br0_ipaddr" == "" ];then
                    cecho fail "Can not get DUT br0 IP after run \"dhclient ${seqlan1[1]} -v -lf /tmp/auto_dect.lease\"!"
                else
                    br0segment=`echo "$br0_ipaddr"|awk -F. '{printf("%i.%i.%i."), $1,$2,$3}'`
                    echo "br0 segment : $br0segment"
                    option_route=`cat /tmp/auto_dect.lease|grep "option routers"|awk '{print $3}'|sed 's/; *//g'`
                    route del default
                    route add default gw $option_route

                    rm -f /etc/resolv.conf
                    touch /etc/resolv.conf
                    #cecho pass "nameserver $br0_ipaddr"
                    #echo "nameserver $br0_ipaddr" > /etc/resolv.conf
                    #cecho pass "nameserver $br0_ipaddr"
                    #echo "nameserver $br0_ipaddr" >> /etc/resolv.conf
                    #if [ "$U_DUT_TYPE" == "WECB" ];then
                    #    option_route=`cat /tmp/auto_dect.lease|grep "option routers"|awk '{print $3}'|sed 's/; *//g'`
                        cecho pass "nameserver $option_route"
                        echo "nameserver $option_route" > /etc/resolv.conf
                        cecho pass "nameserver $option_route"
                        echo "nameserver $option_route" >> /etc/resolv.conf
                    #fi
                    cecho pass "cat /etc/resolv.conf"
                    cat /etc/resolv.conf
                    #cecho "killall -9 dhclient"
                    #killall -9 dhclient
                    break
                fi
            fi
        fi
        let i=$i+1
    done
    cecho pass "The IP status after \"dhclient ${seqlan1[1]} -v -lf /tmp/auto_dect.lease\";ifconfig -a;route -n"
    ifconfig -a
    route -n
    echo "===================================================================================================="
    #export G_PROD_IP_BR0_0_0=$br0_ipaddr
    #echo "G_PROD_IP_BR0_0_0=$br0_ipaddr"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_PROD_IP_BR0_0_0=$G_PROD_IP_BR0_0_0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_DNS0=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_DNS1=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    
    echo -e "\n########LAN PC 1">>${logpath}/${outlog}
    echo "G_HOST_IP0=$G_HOST_IP0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_USR0=$G_HOST_USR0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_PWD0=$G_HOST_PWD0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    #eth0
    echo "G_HOST_IF0_0_0=${seqlan1[0]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_TIP0_0_0=`ifconfig ${seqlan1[0]}|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_TMASK0_0_0=`ifconfig ${seqlan1[0]}|grep "Mask:"|awk -F: '{print $NF}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_MAC0_0_0=`ifconfig ${seqlan1[0]}|grep "HWaddr"|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_GW0_0_0=$G_HOST_GW0_0_0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    #eth1   
    echo "G_HOST_IF0_1_0=${seqlan1[1]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_TIP0_1_0=${br0segment}100"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_TMASK0_1_0=255.255.255.0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_MAC0_1_0=`ifconfig ${seqlan1[1]}|grep "HWaddr"|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_GW0_1_0=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    #eth2
    if [ -n "$G_HOST_IF0_2_0" ];then
        echo "$G_HOST_IF0_2_0" |grep -i "none"
        if [ $? -ne 0 ];then
            echo "G_HOST_IF0_2_0=${seqlan1[2]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "G_HOST_TIP0_2_0=${br0segment}200"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "G_HOST_TMASK0_2_0=255.255.255.0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "G_HOST_MAC0_2_0=`ifconfig ${seqlan1[2]}|grep "HWaddr"|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            echo "G_HOST_GW0_2_0=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        fi
    fi
    if [ -n "$G_HOST_IF0_3_0" ];then
        echo "G_HOST_IF0_3_0=${seqlan1[3]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TIP0_3_0=${br0segment}210"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TMASK0_3_0=255.255.255.0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_MAC0_3_0=`ifconfig ${seqlan1[3]}|grep "HWaddr"|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_GW0_3_0=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg

    fi
    if [ -n "$G_HOST_IF0_4_0" ];then
        echo "G_HOST_IF0_4_0=${seqlan1[4]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TIP0_4_0=${br0segment}220"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TMASK0_4_0=255.255.255.0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_MAC0_4_0=`ifconfig ${seqlan1[4]}|grep "HWaddr"|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_GW0_4_0=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg

    fi

    #wireless
    getWL LAN1 ${logpath}/lan1_ifconfig.log
}

function get_standard_tb_lan2(){
    cecho pass "LAN PC 2 : SSH to LAN PC 2 to get the NIC Info"
    
    echo "$U_PATH_TBIN/clicmd -o ${logpath}/lan2_ifconfig.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"ifconfig -a;iwconfig;route -n\""
    $U_PATH_TBIN/clicmd -o ${logpath}/lan2_ifconfig.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "ifconfig -a;iwconfig;route -n"
    rc=$?
    if [ $rc -eq 0 ];then     
        checkNIC LAN2 ${logpath}/lan2_ifconfig.log "${seqlan2[*]}"
        echo -e "\n########LAN PC 2" >>${logpath}/${outlog}
        echo "G_HOST_IP2=$G_HOST_IP2"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_USR2=$G_HOST_USR2"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_PWD2=$G_HOST_PWD2"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        #eth0
        echo "G_HOST_IF2_0_0=${seqlan2[0]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TIP2_0_0=`grep -A 1 "^${seqlan2[0]}" ${logpath}/lan2_ifconfig.log|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TMASK2_0_0=`grep -A 1 "^${seqlan2[0]}" ${logpath}/lan2_ifconfig.log|grep "Mask:"|awk -F: '{print $4}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_MAC2_0_0=`grep -A 1 "^${seqlan2[0]}" ${logpath}/lan2_ifconfig.log|grep HWaddr|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_GW2_0_0=$G_HOST_GW0_0_0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        #eth1
        echo "G_HOST_IF2_1_0=${seqlan2[1]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TIP2_1_0=${br0segment}150"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_TMASK2_1_0=255.255.255.0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_MAC2_1_0=`grep -A 1 "^${seqlan2[1]}"   ${logpath}/lan2_ifconfig.log|grep HWaddr|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_GW2_1_0=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        #eth2
        if [ -n "$G_HOST_IF2_2_0" ];then
            echo "$G_HOST_IF2_2_0" |grep -i "none"
            if [ $? -ne 0 ];then
                echo "G_HOST_IF2_2_0=${seqlan2[2]}"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
                echo "G_HOST_TIP2_2_0=${br0segment}160"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
                echo "G_HOST_TMASK2_2_0=255.255.255.0"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
                echo "G_HOST_MAC2_2_0=`grep -A 1 "^${seqlan2[2]}"   ${logpath}/lan2_ifconfig.log|grep HWaddr|awk '{print $5}'`"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
                echo "G_HOST_GW2_2_0=$option_route"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
            fi
        fi
        getWL LAN2 ${logpath}/lan2_ifconfig.log
    else
        cecho fail "SSH To LAN PC 2 Fail!" && exit 1
    fi    
}

function get_tb_wan(){
    cecho pass "WAN  PC : SSH to Wan PC to get the NIC Info"
    
    cecho "$U_PATH_TBIN/clicmd -o ${logpath}/wan_ifconfig.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v \"ifconfig -a;iwconfig;route -n\""
    $U_PATH_TBIN/clicmd -o ${logpath}/wan_ifconfig.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "ifconfig -a;iwconfig;route -n"
    rc=$?
    if [ $rc -eq 0 ];then
        checkNIC WAN ${logpath}/wan_ifconfig.log "${seqwan[*]}"
        echo -e "\n########WAN PC" >>${logpath}/${outlog}
        echo "G_HOST_IP1=$G_HOST_IP1"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_USR1=$G_HOST_USR1"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_PWD1=$G_HOST_PWD1"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        getNic WAN ${logpath}/wan_ifconfig.log "${seqwan[*]}"
        if [ "$ThreeCard" -eq "0" ];then
            wan_eth2_gw=`grep G_HOST_TIP1_1_0 ${logpath}/${outlog} |awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
            wan_eth1_gw=`grep "^0.0.0.0 " ${logpath}/wan_ifconfig.log |awk '{print $2}'`
            cecho "wan_eth1_gw : ${wan_eth1_gw}"
            cecho "wan_eth2_gw : ${wan_eth2_gw}"
            sed -i "s/^ *G_HOST_GW1_0_0 *=.*/G_HOST_GW1_0_0=$G_HOST_GW1_0_0/g" ${logpath}/${outlog} ${logpath}/testbed.cfg        
            sed -i "s/^ *G_HOST_GW1_1_0 *=.*/G_HOST_GW1_1_0=$wan_eth1_gw/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
            sed -i "s/^ *G_HOST_GW1_2_0 *=.*/G_HOST_GW1_2_0=$wan_eth2_gw/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
        else
            wan_eth2_gw=`grep G_HOST_TIP1_0_0 ${logpath}/${outlog} |awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
            cecho "wan_eth2_gw : ${wan_eth2_gw}"
            sed -i "s/^ *G_HOST_GW1_0_0 *=.*/G_HOST_GW1_0_0=$G_HOST_GW1_0_0/g" ${logpath}/${outlog} ${logpath}/testbed.cfg        
            sed -i "s/^ *G_HOST_GW1_2_0 *=.*/G_HOST_GW1_2_0=$wan_eth2_gw/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
        fi
        getWL WAN ${logpath}/wan_ifconfig.log
    else
        cecho fail "SSH To Wan PC Fail!" && exit 1
    fi
}

function get_actual_tb_lan1(){
    cecho pass "Start to Get LAN PC 1 testbed infomation"
    echo -e "\n########LAN PC 1">>${logpath}/${outlog}   
    checkNIC LAN1 ${logpath}/lan1_ifconfig.log "${seqlan1[*]}"
    echo "G_HOST_IP0=" |tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_USR0="|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    echo "G_HOST_PWD0="|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
    getNic LAN1 ${logpath}/lan1_ifconfig.log "${seqlan1[*]}"
    lan_mgm_ip=`grep G_HOST_TIP0_0_0 ${logpath}/${outlog} |awk -F= '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
    cecho pass "lan_mgm_ip : ${lan_mgm_ip}"
    sed -i "s/^ *G_HOST_IP0 *=.*/G_HOST_IP0=${lan_mgm_ip}/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
    sed -i "s/^ *G_HOST_GW0_1_0 *=.*/G_HOST_GW0_1_0=$G_PROD_IP_BR0_0_0/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
    sed -i "s/^ *G_HOST_GW0_2_0 *=.*/G_HOST_GW0_2_0=$G_PROD_IP_BR0_0_0/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
    getWL LAN1 ${logpath}/lan1_ifconfig.log
}

function get_actual_tb_lan2(){
    cecho pass "Start to Get LAN PC 2 testbed infomation"
    cecho "SSH to LAN PC 2 to get the NIC Info"
    echo -e "\n########LAN PC 2" >>${logpath}/${outlog}
    echo "$U_PATH_TBIN/clicmd -o ${logpath}/lan2_ifconfig.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v \"ifconfig -a;iwconfig;route -n\""
    $U_PATH_TBIN/clicmd -o ${logpath}/lan2_ifconfig.log -u $G_HOST_USR2 -p $G_HOST_PWD2 -d $G_HOST_IP2 -v "ifconfig -a;iwconfig;route -n"
    rc=$?
    if [ $rc -eq 0 ];then       
        checkNIC LAN2 ${logpath}/lan2_ifconfig.log "${seqlan2[*]}"
        echo "G_HOST_IP2=$G_HOST_IP2"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_USR2=$G_HOST_USR2"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        echo "G_HOST_PWD2=$G_HOST_PWD2"|tee -a ${logpath}/${outlog}|tee -a ${logpath}/testbed.cfg
        getNic LAN2 ${logpath}/lan2_ifconfig.log "${seqlan2[*]}"
        sed -i "s/^ *G_HOST_GW2_1_0 *=.*/G_HOST_GW2_1_0=$G_PROD_IP_BR0_0_0/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
        sed -i "s/^ *G_HOST_GW2_2_0 *=.*/G_HOST_GW2_2_0=$G_PROD_IP_BR0_0_0/g" ${logpath}/${outlog} ${logpath}/testbed.cfg
        getWL LAN2 ${logpath}/lan2_ifconfig.log
    else
        cecho fail "SSH To LAN PC 2 Fail!" && exit 1
    fi    
}

function check_clidut_var(){
    cecho pass "Start to check DUT Default Info"
    vartab=$G_SQAROOT/platform/$G_PFVERSION/common/config/auto_scan_rules
    if [ ! -f "$vartab" ];then
        cecho fail "AT_ERROR : $vartab Not exist!" && exit 1
    fi
    rm -f ${logpath}/warning.log
    cecho pass "1 : Can not be NUll!"
    cecho pass "0 : Can be NUll!"
    grep "^DUTTYPE .*$U_DUT_TYPE" $vartab
    if [ $? -eq 0 ];then
        cecho pass "Need to Check DUT Default Value for $U_DUT_TYPE"
        number=`grep "^DUTTYPE" $vartab|awk '{for(i=1;i<=NF;i++)if($i~/'${U_DUT_TYPE}'/)num=i}{print num}'`
        echo "number : $number"
        cat $vartab|grep -v "DUTTYPE"|grep -v "^#"|sed '/^$/d'|while read line
        do
            cvar=`echo "$line"|awk '{print $1}'`
            cflag=`echo "$line"|awk '{print $'${number}'}'`
            eval var="$"${cvar}
            cecho "$cflag ($cvar = $var)"
            if [ "$cflag" == "1" ];then
                if [ -z "$var" ];then
                   cecho fail "AT_ERROR : $cvar is Null in ${logpath}/${outlog}" |tee -a ${logpath}/warning.log 
                fi
            elif [ "$cflag" == "0" ];then
                cecho pass "$cvar is not required and can be NULL!"
            else
                cecho fail "AT_ERROR : Error flag"
            fi
        done
    else
        cecho pass "Don't Need to Check DUT Default Value for $U_DUT_TYPE"
    fi
}

standard_tb_flag=0
actual_tb_flag=0
get_dut_flag=0
get_all_flag=1
while [ -n "$1" ]
do
    case "$1" in
        --test)
            cecho pass "Test Mode : Test Mode!"
            testflag=1
            export U_PATH_TBIN=.
            export G_CURRENTLOG=.
            curpath=`pwd`
            C_DUT_TYPE=`echo "$curpath"|awk -F/ '{print $NF}'`

            export G_PROD_IP_BR0_0_0=192.168.1.254
            export U_DUT_TELNET_USER=admin
            export U_DUT_TELNET_PWD=1
            export U_DUT_TELNET_PORT=23
            
            #LAN PC 1
            export G_HOST_IP0=192.168.100.41
            export G_HOST_USR0=root
            export G_HOST_PWD0=123qaz
            export G_HOST_IF0_0_0=eth0
            export G_HOST_GW0_0_0=192.168.100.1
            export G_HOST_IF0_1_0=eth1
            export G_HOST_IF0_2_0=eth2            
                        
            #LAN PC 2
            export G_HOST_IP2=
            export G_HOST_USR2=root
            export G_HOST_PWD2=123qaz
            export G_HOST_IF2_0_0=eth0
            export G_HOST_IF2_1_0=eth1
            export G_HOST_IF2_2_0=eth2

            #WAN PC
            export G_HOST_IP1=192.168.100.42
            export G_HOST_USR1=root
            export G_HOST_PWD1=123qaz
            export G_HOST_IF1_0_0=eth0
            #export G_HOST_IF1_1_0=eth1
            export G_HOST_IF1_2_0=eth2

            shift
            ;;
        -s)
            sequence=$2
            cecho "sequence : ${sequence}"
            shift 2
            ;;
        -v)
            target=$2
            cecho pass "target file : ${target}"
            if [ ! -f "${target}" ];then 
            cecho fail "The target file ${target} not exist!" && exit 1
            fi
            shift 2
            ;;
        --ping)
            pingtest=1
            cecho "Do Ping Test!"
            shift 1
            ;;
        -tbs)
            cecho pass "Get standard Testbed Infomation!"
            standard_tb_flag=1
            actual_tb_flag=0
            get_all_flag=0
            shift
            ;;
        -tba)
            cecho pass "Get actual Testbed Infomation!"
            actual_tb_flag=1
            standard_tb_flag=0
            get_all_flag=0
            shift
            ;;
        -dut)
            cecho pass "Get DUT default value!"
            get_dut_flag=1
            get_all_flag=0
            shift
            ;;
        -o)
            outlog=$2
            cecho pass "The output file  : $outlog"
            shift 2
            ;;
        -l)
            logpath=$2
            cecho pass "The output path  : ${logpath}"
            shift 2
            ;;
        -d)
            pcname=$2
            cecho "PC name : $pcname"
            shift 2
            ;;
        -br0)
            br0info=$2
            cecho "br0 info : $br0info"
            shift 2
            ;;
        -b)
            export G_PROD_IP_BR0_0_0=$2
            cecho "G_PROD_IP_BR0_0_0 : $G_PROD_IP_BR0_0_0"
            shift 2
            ;;
        -u)
            export U_DUT_TELNET_USER=$2
            cecho "telnet username : $U_DUT_TELNET_USER"
            shift 2
            ;;
        -p)
            export U_DUT_TELNET_PWD=$2
            cecho "telnet password : $U_DUT_TELNET_PWD"
            shift 2
            ;;
        -port)
            export U_DUT_TELNET_PORT=$2
            cecho "telent port : $U_DUT_TELNET_PORT"
            shift 2
            ;;
        -wan)
            waninfo=$2
            cecho "WAN PC info : $waninfo"
            shift 2
            ;;
        -wi)
            export G_HOST_TIP1_0_0=$2
            cecho "wan ip : $G_HOST_TIP1_0_0"
            shift 2
            ;;
        -wu)
            export G_HOST_USR1=$2
            cecho "wan pc user name : $G_HOST_USR1"
            shift 2
            ;;
        -wp)
            export G_HOST_PWD1=$2
            cecho "wan pc password : $G_HOST_PWD1"
            shift 2
            ;;
        -t)
            export C_DUT_TYPE=$2
            cecho "DUT Type : $U_DUT_TYPE"
            shift 2
            ;;

        *)
            USAGE
            exit 1
    esac
done

cecho pass "get_dut_flag     : ${get_dut_flag}"
cecho pass "actual_tb_flag   : ${actual_tb_flag}"
cecho pass "standard_tb_flag : ${standard_tb_flag}"
cecho pass "get_all_flag     : ${get_all_flag}"

if [ "$C_DUT_TYPE" == "BAR1KH" ];then
    export G_PROD_IP_BR0_0_0=192.168.2.1
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=admin1
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "BHR2" ];then
    export G_PROD_IP_BR0_0_0=192.168.1.1
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=admin1
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "CTLC2KA" ];then
    export G_PROD_IP_BR0_0_0=192.168.0.1
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=1
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "CTLC1KA" ];then
    export G_PROD_IP_BR0_0_0=192.168.0.1
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=1
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "FT" ];then
    export G_PROD_IP_BR0_0_0=192.168.1.1
    export U_DUT_TELNET_USER=root
    export U_DUT_TELNET_PWD=admin
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "PK51KA" ];then
    export G_PROD_IP_BR0_0_0=192.168.0.1
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=1
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "TV2KH" ];then
    export G_PROD_IP_BR0_0_0=192.168.1.254
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=admin
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "TV1KH" ];then
    export G_PROD_IP_BR0_0_0=192.168.1.254
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=admin
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "SV1KH" ];then
    export G_PROD_IP_BR0_0_0=192.168.0.1
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD="!brun3ll0"
    export U_DUT_TELNET_PORT=23

elif [ "$C_DUT_TYPE" == "Q2KH" ];then
    export G_PROD_IP_BR0_0_0=192.168.0.1
    export U_DUT_TELNET_USER=admin
    export U_DUT_TELNET_PWD=QwestM0dem
    export U_DUT_TELNET_PORT=23
fi

if [ -z "${outlog}" ];then
    outlog=personal.cfg
    cecho pass "The output file  : $outlog"
fi

if [ -z "${logpath}" ];then
    logpath=${G_CURRENTLOG}
    cecho pass "The output path  : ${logpath}"
fi

if [ -n "$waninfo" ];then
    ip1_0_0=`echo "$waninfo" |awk -F: '{print $1}'`
    user1_0_0=`echo "$waninfo" |awk -F: '{print $2}'`
    pwd1_0_0=`echo "$waninfo" |awk -F: '{print $3}'`
    if [ -z "$ip1_0_0" ] || [ -z "$user1_0_0" ] || [ -z "$pwd1_0_0" ];then
        cecho fail "WAN PC ip,username,password can't be null!"
        USAGE
        exit 1
    fi
    export G_HOST_TIP1_0_0=$ip1_0_0
    export G_HOST_USR1=$user1_0_0
    export G_HOST_PWD1=$pwd1_0_0
    cecho "G_HOST_TIP1_0_0 : $G_HOST_TIP1_0_0"
    cecho "G_HOST_USR1     : $G_HOST_USR1"
    cecho "G_HOST_USR1     : $G_HOST_PWD1"
fi

if [ -n "$br0info" ];then
    br0ip1_0_0=`echo "$br0info" |awk -F: '{print $1}'`
    br0user1_0_0=`echo "$br0info" |awk -F: '{print $2}'`
    br0pwd1_0_0=`echo "$br0info" |awk -F: '{print $3}'`
    br0port_0_0=`echo "$br0info" |awk -F: '{print $4}'`
    if [ -z "$br0ip1_0_0" ] || [ -z "$br0user1_0_0" ] || [ -z "$br0pwd1_0_0" ];then
        cecho fail "DUT telnet ip,username,password can't be null!"
        USAGE
        exit 1
    fi
    export G_PROD_IP_BR0_0_0=$br0ip1_0_0
    export U_DUT_TELNET_USER=$br0user1_0_0
    export U_DUT_TELNET_PWD=$br0pwd1_0_0
    if [ -n "$br0port_0_0" ];then
        export U_DUT_TELNET_PORT=$br0port_0_0
    fi
    cecho "G_PROD_IP_BR0_0_0 : $G_PROD_IP_BR0_0_0"
    cecho "U_DUT_TELNET_USER : $U_DUT_TELNET_USER"
    cecho "U_DUT_TELNET_PWD  : $U_DUT_TELNET_PWD"
    cecho "U_DUT_TELNET_PORT  : $U_DUT_TELNET_PORT"
fi

if [ -n "${sequence}" ];then
    rc1=`echo $sequence|sed 's/ *//g'| grep "^[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*$"`
    rc2=`echo $sequence|sed 's/ *//g'| grep "^[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*:$"`
    rc3=`echo $sequence|sed 's/ *//g'| grep "^[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*:[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*$"`
    rc4=`echo $sequence|sed 's/ *//g'| grep "^[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*:[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*:$"`
    rc5=`echo $sequence|sed 's/ *//g'| grep "^[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*::[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*$"`
    rc6=`echo $sequence|sed 's/ *//g'| grep "^[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*:[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*:[[:alnum:]]*,[[:alnum:]]*,[[:alnum:]]*$"`
    if [ "$rc1" == "" -a "$rc2" == "" -a "$rc3" == "" -a "$rc4" == "" -a "$rc5" == "" -a "$rc6" == "" ];then
        cecho fail "$sequence format is Invalid!"
        USAGE
        exit 1
    fi
fi
##default is three card on wan pc
export ThreeCard=0

if [ -z "$G_HOST_IF1_1_0" ] || [ "$G_HOST_IF1_1_0" == "None" ] || [ "$G_HOST_IF1_1_0" == "NONE" ] || [ "$G_HOST_IF1_1_0" == "none" ];then
    #G_HOST_IF1_1_0 not define means wan has two interface
    export ThreeCard=1
    echo "AT_WARNING : G_HOST_IF1_1_0 $G_HOST_IF1_1_0 is Null,WAN PC have 2 Network Card!"
else
    python $U_PATH_TBIN/clicmd -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "ifconfig $G_HOST_IF1_1_0"|grep "last_cmd_return_code:0"
    export ThreeCard=$?
    if [ "$ThreeCard" -eq "0" ];then
        echo "AT_WARNING : G_HOST_IF1_1_0 $G_HOST_IF1_1_0 is EXIST,WAN PC have 3 Network Card!"
    else
        echo "AT_WARNING : G_HOST_IF1_1_0 $G_HOST_IF1_1_0 is NOT EXIST,WAN PC have 2 Network Card!"
    fi
fi
echo "ThreeCard:$ThreeCard"

rm -f ${logpath}/${outlog}
rm -f ${logpath}/wan_ifconfig.log
rm -f ${logpath}/lan1_ifconfig.log
rm -f ${logpath}/lan2_ifconfig.log
rm -f ${logpath}/warning.log
rm -f ${logpath}/testbed.cfg
rm -f ${logpath}/personal.cfg

array=(wifi.info br0.info dev.info wan.info)
if [ "$U_DUT_TYPE" == "WECB" ] || [ "$U_DUT_TYPE" == "NcsWecb3000" ] || [ "$U_DUT_TYPE" == "TelusWecb3000"] || ["$U_DUT_TYPE" == "ComcastWecb3000"] || [ "$U_DUT_TYPE" == "VerizonWecb3000"];then
    array=(wifi.info br0.info dev.info)
fi
ifconfig -a|tee ${logpath}/lan1_ifconfig.log
iwconfig   |tee -a ${logpath}/lan1_ifconfig.log

#cecho pass "Start to assemble NIC Interface sequence"

deflan1seq=(${G_HOST_IF0_0_0} ${G_HOST_IF0_1_0} ${G_HOST_IF0_2_0})
if [ -n "${G_HOST_IF0_3_0}" ];then
    deflan1seq=(${G_HOST_IF0_0_0} ${G_HOST_IF0_1_0} ${G_HOST_IF0_2_0} ${G_HOST_IF0_3_0})
    if [ -n "${G_HOST_IF0_4_0}" ];then
        deflan1seq=(${G_HOST_IF0_0_0} ${G_HOST_IF0_1_0} ${G_HOST_IF0_2_0} ${G_HOST_IF0_3_0} ${G_HOST_IF0_4_0})
    fi
fi
if [ -z "${G_HOST_IF0_2_0}" ] || [ "$G_HOST_IF0_2_0" == "None" ] || [ "$G_HOST_IF0_2_0" == "NONE" ] || [ "$G_HOST_IF0_2_0" == "none" ];then
    deflan1seq=(${G_HOST_IF0_0_0} ${G_HOST_IF0_1_0})
fi

deflan2seq=(${G_HOST_IF2_0_0} ${G_HOST_IF2_1_0} ${G_HOST_IF2_2_0})

if [ -z "${G_HOST_IF2_2_0}" ] || [ "$G_HOST_IF2_2_0" == "None" ] || [ "$G_HOST_IF2_2_0" == "NONE" ] || [ "$G_HOST_IF2_2_0" == "none" ];then
    deflan2seq=(${G_HOST_IF2_0_0} ${G_HOST_IF2_1_0})
fi

if [ "$ThreeCard" -eq "0" ];then
    defwanseq=(${G_HOST_IF1_0_0} ${G_HOST_IF1_1_0} ${G_HOST_IF1_2_0})
else
    defwanseq=(${G_HOST_IF1_0_0} ${G_HOST_IF1_2_0})
fi

#do NIC Interface check
if [ "${actual_tb_flag}" == "1" -o "${standard_tb_flag}" == "1" -o "${get_all_flag}" == "1" ];then
   # cecho "deflan1seq=(${G_HOST_IF0_0_0} ${G_HOST_IF0_1_0} ${G_HOST_IF0_2_0} ${G_HOST_IF0_3_0} ${G_HOST_IF0_4_0})"
   # cecho "deflan2seq=(${G_HOST_IF2_0_0} ${G_HOST_IF2_1_0} ${G_HOST_IF2_2_0})"
   # if [ "$ThreeCard" -eq "0" ];then
   #     cecho "defwanseq=(${G_HOST_IF1_0_0} ${G_HOST_IF1_1_0} ${G_HOST_IF1_2_0})"
   # else
   #     cecho "defwanseq=(${G_HOST_IF1_0_0} ${G_HOST_IF1_2_0})"
   # fi
    chcekknownvar
    assembleInterface LAN1
    if [ -n "$G_HOST_IP2" ];then
        assembleInterface LAN2
    fi
    assembleInterface WAN
    sleep 2
fi

#get standard testbed info
if [ "${standard_tb_flag}" == "1" -o "${get_all_flag}" == "1" ];then
    get_standard_tb_lan1
    get_tb_wan
    echo "G_HOST_IP2: $G_HOST_IP2"
    if [ -n "$G_HOST_IP2" ];then
        get_standard_tb_lan2
    else
        cecho pass "G_HOST_IP2 is NULL! No need to get LAN PC 2 variable!"
    fi
fi

#get dut default info
if [ "${get_dut_flag}" == "1" -o "${get_all_flag}" == "1" ];then    
    get_dut_def_value
    putENV
    echo "U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL=$U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL"
    if [ "$U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL" == "NONE" ];then
        echo "AT_INFO : U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL=NONE,No need check variable!"
    else
        check_clidut_var
    fi
fi

#get actual testbed info
if [ "${actual_tb_flag}" == "1" ];then
    get_actual_tb_lan1
    get_tb_wan
    echo "G_HOST_IP2: $G_HOST_IP2"
    if [ -n "$G_HOST_IP2" ];then
        get_actual_tb_lan2
    else
        cecho pass "G_HOST_IP2 is NULL! No need to get LAN PC 2 variable!"
    fi
fi

#check testbed info
if [ "${actual_tb_flag}" == "1" -o "${standard_tb_flag}" == "1" -o "${get_all_flag}" == "1" ];then
    if [ -n "$target" ];then
        echo "target file : $target"
        updatetb
    fi
    putENV
    cat ${logpath}/${outlog}
    checkSegment
    
    if [ "$pingtest" == "1" ];then
        checkConnect
    fi
fi

#edit output file
cp ${logpath}/${outlog} ${logpath}/${outlog}_V
sed -i '/^[a-zA-Z].*=/ s/^ */-v /g' ${logpath}/${outlog}_V
sed -i 's/^ *#.*$//g' ${logpath}/${outlog}
sed -i "s/=/=\"/g" ${logpath}/${outlog} ${logpath}/${outlog}_V
sed -i "/=/ s/ *$/\"/g" ${logpath}/${outlog} ${logpath}/${outlog}_V
echo ""
cecho pass "cat ${logpath}/${outlog}"
cat ${logpath}/${outlog}

#output warning info
echo ""
echo "U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL=$U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL"
if [ "$U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL" == "NONE" ];then
    echo "AT_INFO : U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL=NONE,No need check variable!"
else
    if [ -f "${logpath}/warning.log" ];then
        cecho fail "All Warning Info,Please check them!\n"
        cat ${logpath}/warning.log
        exit 1
    fi
fi
