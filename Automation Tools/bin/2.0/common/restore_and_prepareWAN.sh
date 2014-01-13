#!/bin/bash
#---------------------------------
# Name: Andy liu
# Description:
# This script is used to restore factory default
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH      | INFO
#10 May 2012    |   1.0.0   | Andy      | Inital Version
#14 May 2012    |   1.0.1   | Andy      | fix function name
#27 Apr 2013    |   2.0.0   | Andy      | use new tool to config telnet and WAN link

REV="$0 version 2.0.0 (27 Apr 2013)"
echo "${REV}"

usage="$0"

#get_link_type(){
#	echo "in function get_wan_link() ..."
#	
#	bash $U_PATH_TBIN/cli_dut.sh -v wan.link -o $G_CURRENTLOG/wan.link.log
#	wan_link=`cat $G_CURRENTLOG/wan.link.log | grep "TMP_DUT_WAN_LINK" |awk -F = '{print $2}'`
#	link_type=`cat $G_CURRENTLOG/wan.link.log | grep "TMP_DUT_WAN_ISP_PROTO" |awk -F = '{print $2}'`
#	
#	if [ -z "$wan_link" ] ;then
#		echo "AT_ERROR : TMP_DUT_WAN_LINK  is empty !"
#		echo "	TMP_DUT_WAN_ISP_PROTO is ${link_type}"
#		exit 1
#	else
#		echo "	TMP_DUT_WAN_LINK is ${wan_link}"
#		echo "	TMP_DUT_WAN_ISP_PROTO is ${link_type}"
#	fi
#}

while [ -n "$1" ]
do
    case "$1" in
        --old_dut_br0_ip)
            old_dut_br0_ip=$2
            echo "the old DUT BR0 IP : ${old_dut_br0_ip}"
            shift 2
            ;;

        *)
            echo $usage
            exit 1
            ;;
    esac
done

split="-----------------------------------------------"

if [ "$old_dut_br0_ip" ] ;then
    TMP_DUT_BR0_IP=$G_PROD_IP_BR0_0_0
    G_PROD_IP_BR0_0_0=$old_dut_br0_ip
fi

#echo $split
#echo "get link type"
#if [ "$link_type" == "IPOE" -o "$link_type" == "PPPOE" ] ;then
#    echo "link type : $link_type"
#else
#    if [ -z "$link_type" ] ;then
#        if [ "$U_DUT_TYPE" != "PK5K1A" ];then
#            echo "Enable telnet"
#            #enable telnet
#            $U_AUTO_CONF_BIN $U_DUT_TYPE $SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001
#
#            #check telnet
#            perl $U_PATH_TBIN/DUTCmd.pl -o checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT
#            if [ $? -ne 0 ] ;then
#                exit 1
#            fi
#        else
#            echo "U_DUT_TYPE is ${U_DUT_TYPE},No need enable telnet!"
#        fi
#        
#        get_link_type
#    fi
#
#    if [ -z "$link_type" ] ;then
#        link_type="IPOE"
#    elif [ "$link_type" != "IPOE" -a "$link_type" != "PPPOE" ] ;then
#        link_type="IPOE"
#    fi
#fi
#
#echo "link type : $link_type"

#echo $split
#echo "check LAN"
#bash $U_PATH_TBIN/verifyDutLanConnected.sh
#if [ $? -ne 0 ] ;then
#    exit 1
#fi

echo $split
echo "restore DUT"
restoreDUT_retry=0

#############
if [ "$old_dut_br0_ip" ] ;then
    G_PROD_IP_BR0_0_0=$TMP_DUT_BR0_IP
fi
#############

while [ "$restoreDUT_retry" -lt 3 ] ;
do
    if [ "$old_dut_br0_ip" ] ;then
        bash $U_PATH_TBIN/restoreDUT.sh --old_dut_br0_ip $old_dut_br0_ip
    else
        bash $U_PATH_TBIN/restoreDUT.sh
    fi
    rc=$?
    if [ $rc -eq 0 ] ;then
        break
    else
        let "restoreDUT_retry=$restoreDUT_retry+1"
    fi
done
if [ "$rc" -ne 0 ] ;then
    exit 1
fi

echo $split
echo "enable telnet"
bash $U_PATH_TBIN/setup_local_telnet.sh
#$U_AUTO_CONF_BIN $U_DUT_TYPE $SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001
#
#echo $split
#echo "check telnet"
#perl $U_PATH_TBIN/DUTCmd.pl -o checkTelnet.log -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT
#if [ $? -ne 0 ] ;then
#    exit 1
#fi

echo $split
echo "config WAN"
python $U_PATH_TBIN/Configure_Required_DUT_WAN_Settings.py -c

#echo $split
#echo "check LAN"
#bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120
#if [ $? -ne 0 ] ;then
#    exit 1
#fi
#
#echo $split
#echo "set WAN type"
#bash $U_PATH_TBIN/setupDutWANLink.sh -p "$link_type" -set
#if [ $? -ne 0 ] ;then
#    exit 1
#fi
#
#echo $split
#echo "check WAN"
#bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240
#if [ $? -ne 0 ] ;then
#    exit 1
#fi
#
#echo $split
#echo "refrash WAN infomation"
#if [ "$U_CUSTOM_UPDATE_ENV_FILE" ] ; then
#    bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_info.log
#
#    rc=$?
#    if [ $rc -ne 0 ] ;then
#        echo "AT_ERROR : get WAN info failed"
#        exit 1
#    fi
#
#    echo "output WAN info to env!"
#    lines=`cat $G_CURRENTLOG/wan_info.log | wc -l`
#    for linenumber in `seq 1 $lines`
#    do
#        line=`sed -n "$linenumber"p $G_CURRENTLOG/wan_info.log`
#        echo $line >> $U_CUSTOM_UPDATE_ENV_FILE
#    done
#
#    bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/wan_dns.log
#
#    rc=$?
#    if [ $rc -ne 0 ] ;then
#        echo "AT_ERROR : get WAN info failed"
#        exit 1
#    fi
#
#    echo "output WAN DNS to env!"
#    lines=`cat $G_CURRENTLOG/wan_dns.log | wc -l`
#    for linenumber in `seq 1 $lines`
#    do
#        line=`sed -n "$linenumber"p $G_CURRENTLOG/wan_dns.log`
#        echo $line >> $U_CUSTOM_UPDATE_ENV_FILE
#    done
#fi
#
#echo $split
#echo "ckeck WAN type"
#bash $U_PATH_TBIN/setupDutWANLink.sh -p "$link_type" -check -o $G_CURRENTLOG/wan_link_info.log
#if [ $? -ne 0 ] ;then
#    exit 1
#fi
#
#echo $split
#echo "export variable"
#if [ -f "$G_CURRENTLOG/wan_link_info.log" ] ;then
#    cat $G_CURRENTLOG/wan_link_info.log > $G_CURRENTLOG/update_env
#else
#    echo "AT_ERROR : No such file <$G_CURRENTLOG/wan_link_info.log>"
#    exit 1
#fi
