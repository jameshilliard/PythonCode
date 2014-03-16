#!/bin/bash
######################################################################################
# Usage : remove_rules.sh [-test] -p <postfile> -v <replace rule 1>
#         -v <replace rule 2> -t <remove rule type> [-a <remove all rules>]  
# param : to test the script without testcase, use [-test] before all params.    
#           [-a] [-t] can be omitted                      
#                                                                                
######################################################################################
# Author        :  Prince Wang
# Description   :  This script is used to remove the added rules
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#14 May 2012    |   1.0.0   | prince    | Inital Version       
#

REV="$0 version 1.0.0 (14 May 2012)"
echo "REV:${REV}"
usage="bash remove_rules.sh [-test] -p <postfile> -v <replace rule> -t <remove rule type> [-a <remove all rules>]"

rule=""
i=1
while [ $# -gt 0 ]
do
    case "$1" in
    -test)
        U_AUTO_CONF_BIN=playback_http
        U_DUT_TYPE=Q2KH
        U_AUTO_CONF_PARAM="-d 0"
        U_PATH_TBIN=.
        export G_HOST_IF0_1_0=eth1
        export G_HOST_TIP0_1_0=192.168.0.100
        export G_PROD_IP_BR0_0_0=192.168.0.1
        shift 1
        ;;
    -v)
        param=$2
        echo "replace rule ${i}: $param"
        rule="${rule} -v $param"
        let i=$i+1
        shift 2
        ;;
    -p)
        postfile=$2
        echo "postfile : $postfile"
        shift 2
        ;;
    -i)
        index=$2
        echo "No need delindex for Brandcom"
        shift 2
        ;;
    -s)
        appf_name=$2
        ;;
    -t)
        rule_type=$2
        echo "remove_type : $rule_type"
        shift 2
        ;;
    -a)
        remove_all_flag=1
        echo "remove all added rules!"
        shift 1
        ;;
    -a)
        remove_all_flag=1
        echo "remove all added rules!"
        shift 1
        ;;
    *)
        echo "$usage"
        exit 1
        ;;
    esac
done

if [ -z "$param" ];then
    echo "No need replace rule!"
else
    echo "Need replase rule!"
    echo "Replace  rule:$rule"
fi


if [ -z "$remove_all_flag" ];then
    remove_all_flag=0
fi

if [ -z "$postfile" -a "$remove_all_flag" == "0"  ];then
    echo "postfile $postfile not define!"&& exit 1
fi

if [ -z "$rule_type" -a "$remove_all_flag" == "0" ];then
    echo "Rule Type not defined!" && exit 1
fi


common(){
    echo "------------------------------------------------------------------------------------------------"
    cur_type=$1
    echo "cur_type=$cur_type"
    echo "Start to $cur_type GUI Setup ..."
    sleep 2
    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM $rule"
    $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM $rule
    gui_rc=$?        
    if [ $gui_rc -gt 0 ] ;then
        echo "AT_ERROR : $cur_type GUI Setup failed"
        exit 1
    else
        echo "$cur_type GUI Setup succeed"
        exit 0
    fi
}


restorefirewall(){
    echo "------------------------------------------------------------------------------------------------"
    echo "Start to Restore Firewall ..."
    sleep 2
    restore_fw_postfile=$G_SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Security/firewall/B-GEN-SEC.FW-005-C001
    test ! -e $restore_fw_postfile && echo "Restore firewall Postfile not exist!" && exit 1
    echo "Restore firewall Postfile : $restore_fw_postfile"
    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $restore_fw_postfile $U_AUTO_CONF_PARAM"
    $U_AUTO_CONF_BIN $U_DUT_TYPE $restore_fw_postfile $U_AUTO_CONF_PARAM
    gui_rc=$?        
    if [ $gui_rc -gt 0 ] ;then
        echo "AT_ERROR : Restore Firewall Fail!"
        exit 1
    else
        echo "Restore Firewall succeed!"
        exit 0
    fi
}


bash $U_PATH_TBIN/verifyDutLanConnected.sh

lan_rc=$?

if [ $lan_rc -gt 0 ] ;then
    echo "AT_ERROR : lan connection error !"
    exit 1
fi

if [ "$remove_all_flag" == "1" -a "$rule_type" == "APF" ];then
    echo "=======Restore firewall!"
    restorefirewall
elif [ "$rule_type" == "LAN_DHCP" -o "$rule_type" == "APF" -o "$rule_type" == "PFO" -o "$rule_type" == "LAN_DHCP" -o "$rule_type" == "WBL" -o "$rule_type" == "SBL" -o "$rule_type" == "ASC" -a "$remove_all_flag" == "0" ];then
    common $rule_type
else
    echo "special"
fi
