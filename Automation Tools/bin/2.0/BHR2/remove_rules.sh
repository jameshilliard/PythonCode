#!/bin/bash
######################################################################################
# Usage : remove_rules.sh [-c] -p <postfile> -t <remove rule type> -v <replace rule1>
#         [-v <replace rule2>] [-s <APF service name>] [-a <remove all rules>]  
# param : to check the script without testcase, use [-c] before all params.    
#         [-a] can be omitted;  -t must be specified before the 1st -v.                     
#                                                                                
######################################################################################
# Author        : Jerry
# Description   : This script is used to remove the specified rules
#
#
# History       :
#   DATE        |   REV     |   AUTH    | INFO
#23 May 2012    |   1.0.0   |   Jerry   | Inital Version  
#28 May 2012    |   1.0.1   |   Jerry   | Add function to support DMZ/WI_MAC_AUTH/ASC/DNS_HOST/SROUT
#

REV="$0 version 1.0.1 (28 May 2012)"
echo "REV:${REV}"
echo ""
usage="bash remove_rules.sh [-c] -p <postfile> -t <remove rule type> -v <replace rule1> [-v <replace rule2>] [-s <APF service name>] [-a <remove all rules>]"

#
#
#
######### LAN_DHCP START #############
dhcp_input_param=(U_CUSTOM_LAN_DEV_VISIBLE_TO_DNS \
  U_DUT_CUSTOM_LAN_MIN_ADDRESS \
  U_CUSTOM_LAN_DEV_START_TIME \
  U_CUSTOM_LAN_DEV_END_TIME \
  U_CUSTOM_LAN_DEV_HARDWARE_MAC \
  U_CUSTOM_LAN_DEV_IS_DYNAMIC \
  U_CUSTOM_LAN_DEV_VALID_TIME \
  U_CUSTOM_LAN_DEV_IS_MS_NULL_TERMINATED \
  U_CUSTOM_LAN_DEV_IS_ABANDONED \
  U_CUSTOM_LAN_DEV_STABILITY \
  U_CUSTOM_LAN_DEV_IS_EVER_ACKED \
  U_CUSTOM_LAN_DEV_IS_HOSTNAME_FIXED \
  U_CUSTOM_LAN_DEV_IS_DETECTED \
  U_CUSTOM_LAN_DEV_PORT \
  U_CUSTOM_LAN_DEV_DEV \
  U_CUSTOM_LAN_DEV_HOSTNAME \
  U_CUSTOM_LAN_DEV_UID \
  U_CUSTOM_LAN_DEV_VENDOR_ID \
)

dhcp_rule_param=(visible_to_dns \
    ip \
    start_time \
    end_time \
    hardware_mac \
    is_dynamic \
    valid_time \
    is_ms_null_terminated \
    is_abandoned \
    stability \
    is_ever_acked \
    is_hostname_fixed \
    is_detected \
    port \
    dev \
    hostname \
    uid \
    vendor_id \
)

#used to locate the parameter from the first char(including SPACE) in that line
dhcp_param_locate=( "^    " \
    "^      " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
    "^    " \
)

dhcp_input_rule=(NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL)
dhcp_exist_rule=(NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL)
######### LAN_DHCP END ###############

######### WBL START #############
wbl_input_param=(U_CUSTOM_WBL_IPADDR\
  U_CUSTOM_WBL_HOSTNAME \
  U_CUSTOM_WBL_URL \
)

wbl_rule_param=(host_src \
    host_src \
    web_sites \
)
wbl_input_rule=(NULL NULL NULL)
wbl_exist_rule=(NULL NULL NULL)
######### WBL END ###############

######### SBL START #############
#  U_CUSTOM_SBL_SRV_ID \
sbl_input_param=(G_HOST_TIP0_1_0\
  U_CUSTOM_SBL_MAC \
  TMP_CURRENT_SBL_TYPE \
  U_CUSTOM_SBL_NAME \
  U_CUSTOM_SBL_PROTOCOL \
)

sbl_rule_param=(ip \
    mac \
    service_id \
    name \
    protocol \
)
sbl_input_rule=(NULL NULL NULL NULL NULL)
sbl_exist_rule=(NULL NULL NULL NULL NULL)
######### SBL END ###############

######### PFO START #############
pfo_input_param=(U_CUSTOM_PFO_NAME \
    U_CUSTOM_PFO_EXTERNAL_START \
    U_CUSTOM_PFO_EXTERNAL_END \
    U_CUSTOM_PFO_EXTERNAL_HOSTNAME\
)

pfo_rule_param=(name \
    name \
    name \
    hostname \
)
pfo_input_rule=(NULL NULL NULL NULL)
pfo_exist_rule=(NULL NULL NULL NULL)
pfo_param_offset=(0 8 9 0)
######### PFO END ###############

######### APF START #############
apf_input_param=(U_CUSTOM_APF_NAME \
    U_CUSTOM_APF_SRV_ID \
)

apf_rule_param=(name \
    service_id \
)
apf_input_rule=(NULL NULL)
apf_exist_rule=(NULL NULL)
######### APF END ###############

######### DMZ START #############
dmz_input_param=(U_CUSTOM_DMZ_HOSTNAME \
    U_CUSTOM_DMZ_ENABLED \
)

dmz_rule_param=(hostname \
    enabled \
)
dmz_input_rule=(NULL NULL)
dmz_exist_rule=(NULL NULL)
######### DMZ END ###############

######### WI_MAC_AUTH START #############
wiMACauth_input_param=(U_CUSTOM_WI_MAC_AUTH_MAC \
)

wiMACauth_rule_param=(mac \
)
wiMACauth_input_rule=(NULL)
wiMACauth_exist_rule=(NULL)
######### WI_MAC_AUTH END ###############

######### ASC START #############
asc_input_param=(U_CUSTOM_ASC_DESCRIPTION \
    U_CUSTOM_ASC_IS_DISABLING \
)

asc_rule_param=(mac \
    is_disabling \
)
asc_input_rule=(NULL NULL)
asc_exist_rule=(NULL NULL)
######### ASC END ###############

######### DNS_HOST START #############
dnsHost_input_param=(U_CUSTOM_DNS_HOST_HOSTNAME \
    U_CUSTOM_DNS_HOST_IP \
)

dnsHost_rule_param=(hostname \
    ip \
)
dnsHost_input_rule=(NULL NULL)
dnsHost_exist_rule=(NULL NULL)
######### DNS_HOST END ###############

######### SROUT START #############
srout_input_param=(U_CUSTOM_SROUT_DEV \
    U_CUSTOM_SROUT_ADDR \
    U_CUSTOM_SROUT_NETMASK \
    U_CUSTOM_SROUT_GATEWAY \
    U_CUSTOM_SROUT_METRIC \
)

srout_rule_param=(dev \
    addr \
    netmask \
    gateway \
    metric \
)
srout_input_rule=(NULL NULL NULL NULL NULL)
srout_exist_rule=(NULL NULL NULL NULL NULL)
######### SROUT END ###############

######### QOS START #############
qos_input_param=(U_CUSTOM_QOS_NAME \
    U_CUSTOM_QOS_SRV_ID \
    U_CUSTOM_QOS_ENABLED \
    U_CUSTOM_QOS_TYPE \
    U_CUSTOM_QOS_SET_PRIORITY \
)

qos_rule_param=(name \
    service_id \
    enabled \
    type \
    set_priority \
)
qos_input_rule=(NULL NULL NULL NULL NULL)
qos_exist_rule=(NULL NULL NULL NULL NULL)
######### QOS END ###############
#
#
#

flag_remove_all=0

function find_index
{
    # init variables
    input_rule=$1
    rule_param=$2
    exist_rule=$3
    RULE_INDEX=$4
    LOG_FILE=$5
    param_locate=$6
    param_offset=$7
    echo "find_index Input ARGs:: input_rule=$input_rule rule_param=$rule_param exist_rule=$exist_rule RULE_INDEX=$RULE_INDEX LOG_FILE=$LOG_FILE"

    total_num=`eval echo '$'{#$input_rule[@]}`
    echo "total num = $total_num"
    #echo "input:: `eval echo '$'{$input_rule[@]}`"

    for i in `grep -i "^  (" $LOG_FILE | awk -F\( '{print $2}'`
    do
        index=${i}
        echo ""
        echo "index=$i"
        param_index=0

        #parse the parameters from logfile
        for param in `eval echo '$'{$rule_param[@]}`
        do
            #echo "param_index = $param_index"
            if [ $param_index -lt $total_num ];then
                if ! [ `eval echo '$'{$input_rule[$param_index]}` = NULL ]; then
                    echo "Under index$index, parsing param$param_index by: $param"
                    space=`eval echo \"'$'{$param_locate[$param_index]}\"`
                    offset=0
                    offset=`eval echo \"'$'{$param_offset[$param_index]}\"`
                    echo "To find offset($offset) parameter after: $space($param("
                    temp=`awk "/^  \($index/{p=1;next}/^  \)/{p=0}p" $LOG_FILE | grep -i -A $offset "$space($param(" | tail -1 | sed 's/.*(//g'|sed 's/).*//g'`
                    #find the space in value and replace with "#"
                    #echo "#########$temp"
                    temp=`echo $temp | sed 's/  */#/g'`
                    #echo "#########$temp"
                    eval $exist_rule[$((param_index++))]="$temp"
                else
                   # echo "Under index$index, skipped to parse param$param_index: $param "
                    let "param_index=$param_index + 1"
                fi
            fi
        done
        echo "Get rule`eval echo $index: '$'{$exist_rule[@]}`"

       #compare the parsed rules with input rules
        element_index=0
        while [ $total_num -gt $element_index ]
        do
            if [ `eval echo '$'{$exist_rule[$element_index]}` ]; then
                if ! [ `eval echo '$'{$exist_rule[$element_index]}` = `eval echo '$'{$input_rule[$element_index]}` ]
                then
                    echo "The parameter `eval echo '$'{$rule_param[$element_index]}` not matched for index $index"
                    break
                fi
            else
                echo "The parameter `eval echo '$'{$rule_param[$element_index]}` not exist for index $index"
            fi

            #suppose the non-exist parameter equal to the input rule value
            echo "To increase 1 for element_index($element_index)"
            let "element_index=$element_index + 1"

        done
        echo "End element_index=$element_index"

        if [ $element_index -eq $total_num ]
        then
            echo ""
            echo "Found matched index $index: `eval echo '$'{$exist_rule[@]}`"
            echo ""
            eval $RULE_INDEX=$index
            return 0
        fi
    done

    echo "Not find matched rules"
    echo ""
    return 1
}

function find_all_index
{
    RULE_INDEX=$1
    LOG_FILE=$2
    echo "find_all_index Input ARGs:: RULE_INDEX=$RULE_INDEX LOG_FILE=$LOG_FILE"

    for i in `grep -i "^  (" $LOG_FILE | awk -F\( '{print $2}'`
    do
        index=${i}
        if [ -z `eval echo '$'{$RULE_INDEX}` ]; then
            eval $RULE_INDEX=$index
        else
            eval $RULE_INDEX=`eval echo '$'{$RULE_INDEX}`","$index
        fi
    done

    echo "All the index to remove is: `eval echo '$'{$RULE_INDEX}`"
    echo ""
    return 0
}

function init_v
{
    param="$1"
    echo "init_v: $param"

    # replace space in input value to "#"
    #echo "#########$param"
    param=`echo $param | sed 's/  */#/g'`
    #echo "#########$param"

    max_input_v=${#input_v[@]}
    #???save input parameter=value???
    input_v[$max_input_v]="$param"
    #echo "init_v: input_v is \"${input_v[@]}\""
}

function prepare_param 
{
    local_arr=$1

    case "$rule_type" in
        LAN_DHCP)
            if [ `eval echo '$'{$local_arr[1]}` = NULL ]; then
                eval $local_arr[1]=$G_PROD_DHCPSTART_BR0_0_0
            elif [ `eval echo '$'{$local_arr[4]}` = NULL ]; then
                eval $local_arr[4]=$G_HOST_MAC0_1_0
            fi
            echo "local_arr[1]= `eval echo '$'{$local_arr[1]}` local_arr[4]= `eval echo '$'{$local_arr[4]}`"
            ;;
        WBL)
            eval $local_arr[0]=NULL
            eval $local_arr[1]=NULL
            #eval $local_arr[2]=NULL
            ;;
        SBL)
	    if [ `eval echo '$'{$local_arr[0]}` = NULL ]; then
		eval $local_arr[0]=$G_HOST_TIP0_1_0
	    fi

            if [ `eval echo '$'{$local_arr[2]}` = FTP ]; then
                eval $local_arr[2]=2
            elif [ `eval echo '$'{$local_arr[2]}` = HTTP ]; then
                eval $local_arr[2]=3
            elif [ `eval echo '$'{$local_arr[2]}` = Telnet ]; then
                eval $local_arr[2]=14
            elif [ `eval echo '$'{$local_arr[2]}` = PPTP ]; then
                eval $local_arr[2]=23
            elif [ `eval echo '$'{$local_arr[2]}` = IPSec ]; then
                eval $local_arr[2]=24
            elif [ `eval echo '$'{$local_arr[2]}` = L2TP ]; then
                eval $local_arr[2]=25
            elif [ `eval echo '$'{$local_arr[2]}` = "MSN+Gaming+Zone" ]; then
                eval $local_arr[2]=138
            elif [ `eval echo '$'{$local_arr[2]}` = "Doom+I/II/III" ]; then
                eval $local_arr[2]=181
            elif [ `eval echo '$'{$local_arr[2]}` = "Call+of+Duty+2" ]; then
                eval $local_arr[2]=218
            elif [ `eval echo '$'{$local_arr[2]}` = "World+of+Warcraft" ]; then
                eval $local_arr[2]=222
            elif [ `eval echo '$'{$local_arr[2]}` = "NetMeeting" ]; then
                eval $local_arr[2]=223
            elif [ `eval echo '$'{$local_arr[2]}` = H323 ]; then
                eval $local_arr[2]=258
            else
		echo "local_arr[2] not mathed!"
            fi
	    echo "local_arr[0]= `eval echo '$'{$local_arr[0]}` local_arr[2]= `eval echo '$'{$local_arr[2]}`"
            ;;
        PFO)
            if [ `eval echo '$'{$local_arr[2]}` = NULL ]; then
                external_port=`eval echo '$'{$local_arr[1]}`
            elif [ `eval echo '$'{$local_arr[1]}` = `eval echo '$'{$local_arr[2]}` ]; then
                external_port=`eval echo '$'{$local_arr[1]}`
            else
                external_port=`eval echo '$'{$local_arr[1]}`"-"`eval echo '$'{$local_arr[2]}`
            fi
            echo "external_port: $external_port"
            eval $local_arr[0]="Destination#Ports#""$external_port"
            echo "local_arr[0]= `eval echo '$'{$local_arr[0]}`"
            ;;
        APF)
            ;;
        DMZ)
            ;;
        WI_MAC_AUTH)
            ;;
        ASC)
            ;;
        DNS_HOST)
            ;;
        SROUT)
            ;;
        QOS)
            ;;
        WAN_DEV)
            echo "Not support for $rule_type by now..."
            exit 1
            ;;
        UPNP)
            echo "Not support for $rule_type by now..."
            exit 1
            ;;
        LAN_DEV)
            echo "Not support for $rule_type by now..."
            exit 1
            ;;
        *)
            echo "$usage"
            exit 1
            ;;
    esac

}

function value_init
{
    param="$1"
    input_rule=$2
    input_pm=$3
    echo "$param"
    input_param=`echo "$param" | awk -F= '{print $1}'`
    echo "input_param : $input_param"
    param_index=0
    max_input_num=`eval echo '$'{#$input_rule[@]}`
    echo "max_input_num = $max_input_num"

    for pm in `eval echo '$'{$input_pm[@]}`
    do
        #echo "$pm = $input_param"
        if [ $pm = $input_param ];then
            echo "param_index=$param_index"
            eval $input_rule[$((param_index))]=`echo "$param" | awk -F = '{print $2}'`
            break
        fi

        echo "param_index=$param_index"
        let "param_index=$param_index + 1"

    done

#    if [ $param_index -ge $max_input_num ]; then
#        echo "param_index($param_index) exceeded max_input_num($max_input_num), unknown parameter: $input_param"
#        return 1
#    fi

    echo "$input_rule=`eval echo '$'{$input_rule[@]}`"
    return 0
}


function RUN_MAIN
{
    RUN_CMD=$1
    RUN_CMD2=$2
    RUN_RULE_ID=$3
    RUN_INPUT_RULE=$4
    RUN_RULE_PM=$5
    RUN_EXIST_RULE=$6
    LOG_FILE=$7
    RUN_PARAM_LOCATE=$8
    RUN_PARAM_OFFSET=$9

    echo "RUN Input ARGs:: RUN_CMD=\"$RUN_CMD\" RUN_CMD2=\"$RUN_CMD2\" RUN_RULE_ID=$RUN_RULE_ID RUN_INPUT_RULE=$RUN_INPUT_RULE RUN_RULE_PM=$RUN_RULE_PM RUN_EXIST_RULE=$RUN_EXIST_RULE LOG_FILE=$LOG_FILE"

    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"$RUN_CMD\" -v \"$RUN_CMD2\" -o $LOG_FILE"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "$RUN_CMD" -v "$RUN_CMD2" -o $LOG_FILE 
    echo ""
    if [ $? -ne 0 ]; then 
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi    
    dos2unix $G_CURRENTLOG/$LOG_FILE> /dev/null 2>&1
    dos2unix $G_CURRENTLOG/$LOG_FILE  > /dev/null 2>&1

    if [ $flag_remove_all = 0 ]; then
        find_index $RUN_INPUT_RULE $RUN_RULE_PM $RUN_EXIST_RULE $RUN_RULE_ID $G_CURRENTLOG/$LOG_FILE $RUN_PARAM_LOCATE $RUN_PARAM_OFFSET
    elif [ $flag_remove_all = 1 ]; then
        find_all_index $RUN_RULE_ID $G_CURRENTLOG/$LOG_FILE
    fi
    
    if [ $? -ne 0 ]; then 
        echo "AT_ERROR : failed to find request rule index"
        exit 1
    fi    

    echo -e "start to remove $rule_type rule by GUI..."
    echo "$RUN_RULE_ID=`eval echo '$'{$RUN_RULE_ID}`"

    #### LOG_FILE=$G_CURRENTLOG/$LOG_FILE only after find_index or find_all_index is called ####
    if [ $flag_remove_all = 1 ]; then
        if [ $RUN_RULE_ID = "LAN_DHCP_RULE_INDEX" ]; then
            TMP_DEV_IP=`grep "(ip(" $LOG_FILE | sed 's/.*(//g'|sed 's/).*//g'`
            for index in $TMP_DEV_IP
            do
                echo "To remove rule ip = $index"
                echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v U_DUT_CUSTOM_LAN_MIN_ADDRESS_1=$index"
                $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "U_DUT_CUSTOM_LAN_MIN_ADDRESS_1=$index"
            done
        else
            for index in `eval echo '$'{$RUN_RULE_ID} | sed 's/,/ /g'`
            do
                echo "To remove rule index $index"
                echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v $RUN_RULE_ID=$index"
                $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "$RUN_RULE_ID=$index"
            done
        fi
    else
        for index in `eval echo '$'{$RUN_RULE_ID} | sed 's/,/ /g'`
        do
            echo "To remove rule index $index"
            echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v $RUN_RULE_ID=$index"
            $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "$RUN_RULE_ID=$index"
        done
    fi

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove $rule_type rule by GUI failed"
        exit 1
    else
        echo "remove $rule_type rule by GUI succeeded"
    fi
}



while [ $# -gt 0 ]
do
    case "$1" in
    -c)
        U_AUTO_CONF_BIN=playback_http
        U_DUT_TYPE=BHR2
        U_AUTO_CONF_PARAM="-d 0"
        U_PATH_TBIN=.
        G_HOST_IF0_1_0=eth1
        G_HOST_TIP0_1_0=192.168.1.100
        G_PROD_IP_BR0_0_0=192.168.1.1
        G_CURRENTLOG="./"
        U_DUT_TELNET_USER=admin
        U_DUT_TELNET_PWD=admin1
        shift 1
        ;;
    -t)
        rule_type=$2
        echo "remove_type : $rule_type"
        shift 2
        ;;
    -v)
   #     echo "$2"
#        export "$2"
        init_v "$2"
        shift 2
        ;;
    -p)
        postfile=$2
        echo "postfile : $postfile"
        shift 2
        ;;
    -s)
        APF_name=$2
        echo "APF service name : $APF_name"
        shift 2
        ;;
    -a)
        flag_remove_all=1
        echo "remove all added rules!"
        shift 1
        ;;
    -i)
        not_use_index=$2
        echo "not use index $2"
        shift 2
        ;;
    *)
        echo "$usage"
        exit 1
        ;;
    esac
done

#if [ -z "$U_CUSTOM_PFO_SERVER" ]; then
#    U_CUSTOM_PFO_SERVER=$G_HOST_TIP0_1_0
#fi

if [ -z "$rule_type" ]; then
    echo "AT_ERROR : please specify rule type!"
    exit 1
else
    echo "Get input_v: \"${input_v[@]}\""
    echo ""
    print_cfg_cmd2=
    case "$rule_type" in
        LAN_DHCP)
            arr_prefix="dhcp"
            print_cfg_cmd="conf print dev/br0/dhcps/lease"
            remove_index="LAN_DHCP_RULE_INDEX"
            ;;
        WBL)
            arr_prefix="wbl"
            print_cfg_cmd="conf print filter/http/policy"
            remove_index="WBL_RULE_INDEX"
            ;;
        SBL)
            arr_prefix="sbl"
            print_cfg_cmd="conf print fw/policy/0/chain/fw_eth1_out/rule"
            remove_index="SBL_RULE_INDEX"
            ;;
        PFO)
            arr_prefix="pfo"
            print_cfg_cmd="conf print fw/rule/loc_srv"
            remove_index="PFO_RULE_INDEX"
            ;;
        APF)
            arr_prefix="apf"
            print_cfg_cmd="conf print service"
            remove_index="APF_RULE_INDEX"
            ;;
        DMZ)
            arr_prefix="dmz"
            print_cfg_cmd="conf print fw/rule/dmz_host"
            remove_index="DMZ_RULE_INDEX"
            ;;
        WI_MAC_AUTH)
            arr_prefix="wiMACauth"
            print_cfg_cmd="conf print dev/ath0/wl_ap/wl_mac_filter"
            remove_index="WI_MAC_AUTH_RULE_INDEX"
            ;;
        ASC)
            arr_prefix="asc"
            print_cfg_cmd="conf print time_rule"
            remove_index="ASC_RULE_INDEX"
            ;;
        DNS_HOST)
            arr_prefix="dnsHost"
            print_cfg_cmd="conf print dns/entry"
            remove_index="DNS_HOST_RULE_INDEX"
            ;;
        SROUT)
            arr_prefix="srout"
            print_cfg_cmd="conf print route/static"
            remove_index="SROUT_RULE_INDEX"
            ;;
        QOS)
            arr_prefix="qos"
            print_cfg_cmd="conf print qos/chain/qos_classless_eth1_in/rule"
            print_cfg_cmd2="conf print qos/chain/qos_classless_eth1_out/rule"
            remove_index="QOS_RULE_INDEX"
            ;;
        WAN_DEV)
            echo "Not support for $rule_type by now..."
            exit 1
            arr_prefix=""
            print_cfg_cmd="conf print "
            remove_index="_RULE_INDEX"
            ;;
        UPNP)
            echo "Not support for $rule_type by now..."
            exit 1
            arr_prefix=""
            print_cfg_cmd="conf print "
            remove_index="_RULE_INDEX"
            ;;
        LAN_DEV)
            echo "Not support for $rule_type by now..."
            exit 1
            arr_prefix=""
            print_cfg_cmd="conf print "
            remove_index="_RULE_INDEX"
            ;;
	    #$G_PROD_DHCPSTART_BR0_0_0|$G_HOST_MAC0_1_0
        *)
            echo "$usage"
            exit 1
            ;;
    esac

    echo ""
    echo "$rule_type params:: value_input=\"$value_input\" print_cfg_cmd=\"$print_cfg_cmd\" print_cfg_cmd2=\"$print_cfg_cmd2\" remove_param=\"$remove_param\""
    #run find and remove actions
    for pm in `echo ${input_v[@]}`
    do
        echo value_init "$pm" $arr_prefix"_input_rule" $arr_prefix"_input_param"
        value_init "$pm" $arr_prefix"_input_rule" $arr_prefix"_input_param"
        if [ $? -ne 0 ] ;then
            echo "AT_ERROR : $rule_type input rule init failed"
            exit 1
        fi
    done

    echo ""
    echo "before `eval echo '$'{$arr_prefix"_input_rule"[@]}`"
    prepare_param $arr_prefix"_input_rule"
    echo "after `eval echo '$'{$arr_prefix"_input_rule"[@]}`"

    echo ""
    echo RUN_MAIN "$print_cfg_cmd" "$print_cfg_cmd2" $remove_index $arr_prefix"_input_rule" $arr_prefix"_rule_param" $arr_prefix"_exist_rule" $rule_type"_rules_info.log" $arr_prefix"_param_locate" $arr_prefix"_param_offset"
    #RUN_MAIN "$print_cfg_cmd" "$print_cfg_cmd2" $remove_index $arr_prefix"_input_rule" $arr_prefix"_rule_param" $arr_prefix"_exist_rule" 2 $arr_prefix"_param_locate" $arr_prefix"_param_offset"
    RUN_MAIN "$print_cfg_cmd" "$print_cfg_cmd2" $remove_index $arr_prefix"_input_rule" $arr_prefix"_rule_param" $arr_prefix"_exist_rule" $rule_type"_rules_info.log" $arr_prefix"_param_locate" $arr_prefix"_param_offset"

fi

exit 0
