#!/bin/bash
######################################################################################
# Usage : lt_remove_rules.sh [-c] -p <postfile> -t <rule_type>
#         -v <rule1_param1=value1>[ -v rule1_param2=value2...] [-a]
#
# param : To test and check the script without testcase, use [-c] before all params.
#         If you specify the one or more paramter(s) by -i, then the matched rules
#         will be removed; the supported -t type value is "PFO, APF, ASC, SBL, STL, WBL,
#         LAN_DHCP, DNS_HOST, QOS, SROUT, WI_MAC_AUTH.
#         By default, the input parameters is enough to find the specified rules.
#
######################################################################################
# Author        : Messi
# Description   : This script is used to find out the matched rules index for
#                 specified function type, and then remove them.
#
#
# History       :
#   DATE        |   REV     |   AUTH    | INFO
#16 May 2012    |   1.0.0   |   Jerry   | Inital Version
#25 May 2012    |   1.0.1   |   Messi   | Extended Version
#

REV="$0 version 1.0.1 (25 May 2012)"
echo ""
echo "REV:${REV}"

usage="bash lt_remove_rules.sh [-c] -p <postfile> -t <rule_type > -v <rule1_param1=value1> [ -v <rule1_param2=value2>...] [-a]"

index=
FIT_RULE_INDEX=
rule_type=
flag_remove_all=0

end_exist_rule=(-10 -10 -10 -10 -10 -10 -10)
end_input_rule=(-10 -10 -10 -10 -10 -10 -10)

middle_exist_rule=(-10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 \
                   -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 \
                   -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 \
                   -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10)
middle_input_rule=(-10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 \
                   -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 \
                   -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 \
                   -10 -10 -10 -10 -10 -10 -10 -10 -10 -10 -10)

function find_end_index
{
    prefix=$1
    array=$2
#    FIT_RULE_INDEX=
    total_num=${#end_input_rule[@]}

    echo "total num = $total_num"
    echo "input:: ${end_input_rule[@]}"

    for i in `grep -i "${prefix}STATUS" $G_CURRENTLOG/rules_info.log |awk -F= '{print $1}'|sed "s/${prefix}STATUS//g"`
    do
        index=${i}
        echo ""
        echo "index=$i"
        param_index=0

        #parse the parameters from logfile
        for param in `eval echo '$'{$array[@]}`
        do
            #echo "param_index = $param_index"
            if [ $param_index -lt $total_num ];then
                if ! [ "${end_input_rule[$param_index]}" = -10 ]; then
                    end_exist_rule[$((param_index++))]=`grep -i "$param$index" $G_CURRENTLOG/rules_info.log | awk -F= '{print $2}'|sed 's/\"//g'`
                else
                    echo "skipped to parse param$param_index: $param$index"
                    let "param_index=$param_index + 1"
                fi
            fi
        done
        echo "Get rule$index: ${end_exist_rule[@]}"

       #compare the parsed rules with input rules
        element_index=0
        while [ $total_num -gt $element_index ]
        do
            ${end_exist_rule[$element_index]}=`echo "${end_exist_rule[$element_index]}" |tr "[:upper:]" "[:lower:]"`
            ${end_input_rule[$element_index]}=`echo "${end_input_rule[$element_index]}" |tr "[:upper:]" "[:lower:]"`
            if ! [ "${end_exist_rule[$element_index]}" = "${end_input_rule[$element_index]}" ]
            then
                echo "The $element_index parameter not matched for index $index"
                break
            fi

            let "element_index=$element_index + 1"
        done

        echo "End element_index=$element_index"
        if [ $element_index -eq $total_num ]
        then
            echo "Found matched index $index: ${end_exist_rule[@]}"
            if [ -z "$FIT_RULE_INDEX" ]; then
                FIT_RULE_INDEX=$index
            else
                FIT_RULE_INDEX=$FIT_RULE_INDEX","$index
            fi
        fi
    done

    second_index=`echo $FIT_RULE_INDEX |awk -F, '{print $2}'`
    if [ -z $FIT_RULE_INDEX ]; then
        echo "Not find the matched rule"
        return 1
    elif ! [ -z $second_index ]; then
        echo "The matched index is:$FIT_RULE_INDEX, show that your input rule is not uniquely."
        return 1
    else
        echo "Find the matched index is:$FIT_RULE_INDEX"
        echo ""
        return 0
    fi
}

function find_all_end_index
{
#    FIT_RULE_INDEX=
    prefix=$1
    for i in `grep -i "${prefix}STATUS" $G_CURRENTLOG/rules_info.log | awk -F= '{print $1}'|sed 's/${prefix}STATUS//g'`
    do
        index=`echo ${i}|sed "s/.*STATUS//g"`
        if [ -z "$FIT_RULE_INDEX" ]; then
            FIT_RULE_INDEX=$index
        else
            FIT_RULE_INDEX=$FIT_RULE_INDEX","$index
        fi
    done

    echo "All the index to remove is: $FIT_RULE_INDEX"
    echo ""
    return 0
}

function find_middle_index
{
    prefix=$1
    array=$2
#    FIT_RULE_INDEX=
    total_num=${#middle_input_rule[@]}

    echo "total num = $total_num"
    echo "input:: ${middle_input_rule[@]}"

    for i in `grep -i "${prefix}[0-9]" $G_CURRENTLOG/rules_info.log |awk -F_ '{print $2}' |uniq`
    do
        index=${i}
        echo ""
        echo "index=$i"
        param_index=0

        #parse the parameters from logfile
        for param in `eval echo '$'{$array[@]}`
        do
            #echo "param_index = $param_index"
            if [ $param_index -lt $total_num ];then
                if ! [ "${middle_input_rule[$param_index]}" = -10 ]; then
                    paramcheck=`echo $param |sed "s/${prefix}/${prefix}${index}_/g"`
                    middle_exist_rule[$((param_index++))]=`grep -i "$paramcheck"  $G_CURRENTLOG/rules_info.log |awk -F= '{print $2}'|sed 's/\"//g'`
                else
                    echo "skipped to parse param: $param"
                    let "param_index=$param_index + 1"
                fi
            fi
        done
        echo "Get rule $index: ${middle_exist_rule[@]}"

       #compare the parsed rules with input rules
        element_index=0
        while [ $total_num -gt $element_index ]
        do
            ${middle_exist_rule[$element_index]}=`echo "${middle_exist_rule[$element_index]}" |tr "[:upper:]" "[:lower:]"`
            ${middle_input_rule[$element_index]}=`echo "${middle_input_rule[$element_index]}" |tr "[:upper:]" "[:lower:]"`
            if ! [ "${middle_exist_rule[$element_index]}" = "${middle_input_rule[$element_index]}" ]
            then
                echo "The $element_index parameter not matched for index $index"
                break
            fi

            let "element_index=$element_index + 1"

        done
        echo "End element_index=$element_index"
        if [ $element_index -eq $total_num ]
        then
            echo "Found matched index $index: ${end_exist_rule[@]}"
            if [ -z "$FIT_RULE_INDEX" ]; then
                FIT_RULE_INDEX=$index
            else
                FIT_RULE_INDEX=$FIT_RULE_INDEX","$index
            fi
        fi
    done

    second_index=`echo $FIT_RULE_INDEX |awk -F, '{print $2}'`
    if [ -z $FIT_RULE_INDEX ]; then
        echo "Not find the matched rule"
        return 1
    elif ! [ -z $second_index ]; then
        echo "The matched index is:$FIT_RULE_INDEX, show that your input rule is not uniquely."
        return 1
    else
        echo "Find the matched index is:$FIT_RULE_INDEX"
        echo ""
        return 0
    fi
}

function find_all_middle_index
{
    prefix=$1
#    FIT_RULE_INDEX=
    for i in `grep "${prefix}[0-9]" $G_CURRENTLOG/rules_info.log | awk -F_ '{print $2}' | uniq`
    do
        index=${i}
        if [ -z "$FIT_RULE_INDEX" ]; then
            FIT_RULE_INDEX=$index
        else
            FIT_RULE_INDEX=$FIT_RULE_INDEX","$index
        fi
    done

    echo "All the index to remove is: $FIT_RULE_INDEX"
    echo ""
    return 0
}

# Start to handle the rules
#Port forwarding
pfd_rule_param=(PFD_WAN_IPADDR \
                PFD_PROTOCOL \
                PFD_WAN_START \
                PFD_WAN_END \
                PFD_LAN_START \
                PFD_LAN_END \
                PFD_LAN_IPADDR)
function PFO
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep PFD /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep PFD /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1

    if [ ! -z $U_CUSTOM_PFO_SERVER_WANADDR ]; then
        end_input_rule[0]=$U_CUSTOM_PFO_SERVER_WANADDR
    fi
    if [ ! -z $U_CUSTOM_PFO_PROTO ]; then
        end_input_rule[1]=$U_CUSTOM_PFO_PROTO
    fi
    if [ ! -z $U_CUSTOM_PFO_EXTERNAL_START ]; then
        end_input_rule[2]=$U_CUSTOM_PFO_EXTERNAL_START
    fi
    if [ ! -z $U_CUSTOM_PFO_EXTERNAL_END ]; then
        end_input_rule[3]=$U_CUSTOM_PFO_EXTERNAL_END
    fi
    if [ ! -z $U_CUSTOM_PFO_INTERNAL_START ]; then
        end_input_rule[4]=$U_CUSTOM_PFO_INTERNAL_START
    fi
    if [ ! -z $U_CUSTOM_PFO_INTERNAL_END ]; then
        end_input_rule[5]=$U_CUSTOM_PFO_INTERNAL_END
    fi
    if [ ! -z $G_HOST_TIP0_1_0 ]; then
        end_input_rule[6]=$G_HOST_TIP0_1_0
    fi

    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_end_index PFD_ pfd_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_end_index PFD_
        find_all_end_index AFF_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove PFD rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v PFO_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "PFO_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove PFD rules by GUI failed"
        exit 1
    else
        echo "remove PFO rule by GUI succeeded"
    fi

}

#Application forwarding
apf_rule_param=(AAF_TYPENAME \
                AAF_NAME \
                AAF_PROTOCOL \
                AAF_START \
                AAF_END \
                AAF_MAP \
                AAF_IPADDR)
function APF
{
    echo "get application forwarding rules info"
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep AAF_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep AAF_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log  > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log  > /dev/null 2>&1

    if [ ! -z $U_CUSTOM_APF_TYPENAME ]; then
        end_input_rule[0]=$U_CUSTOM_APF_TYPENAME
    fi
    if [ ! -z $U_CUSTOM_APF_SERVICE_NAME ]; then
        end_input_rule[1]=$U_CUSTOM_APF_SERVICE_NAME
    fi
    if [ ! -z $U_CUSTOM_APF_PFO_PROTO ]; then
        end_input_rule[2]=$U_CUSTOM_APF_PFO_PROTO
    fi
    if [ ! -z $U_CUSTOM_APF_START ]; then
        end_input_rule[3]=$U_CUSTOM_APF_START
    fi
    if [ ! -z $U_CUSTOM_APF_END ]; then
        end_input_rule[4]=$U_CUSTOM_APF_END
    fi
    if [ ! -z $U_CUSTOM_APF_MAP ]; then
        end_input_rule[5]=$U_CUSTOM_APF_MAP
    fi
    if [ ! -z $U_CUSTOM_APF_IPADDR ]; then
        end_input_rule[6]=$U_CUSTOM_APF_IPADDR
    fi

    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_end_index AAF_ apf_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_end_index AAF_
    fi

    rc=$?

    if [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_WARNING : rule index is not existed"
        exit 0
    fi

    if [ $rc -ne 0 ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove APF rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        APF_SERVICE_NAME=`grep -i "AAF_NAME${i}" $G_CURRENTLOG/rules_info.log |awk -F= '{print $2}'|sed 's/\"//g'|sed 's/ /+/g'`
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v APF_RULE_INDEX=$i -v U_CUSTOM_APF_SERVICE_NAME=${APF_SERVICE_NAME}"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "APF_RULE_INDEX=$i" -v "U_CUSTOM_APF_SERVICE_NAME=${APF_SERVICE_NAME}"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove APF rules by GUI failed"
        exit 1
    else
        echo "remove APF rule by GUI succeeded"
    fi

}

#Access Scheduler
pc_rule_param=(PC_MACADDR \
               PC_DAYSELECTION \
               PC_TIMESTART \
               PC_TIMEEND)

mns2hrs(){
    time1=$1

    time=`eval echo '$'${time1}`

    hrs=`echo "$time/60"|bc`
    len_hrs=`echo $hrs|wc -m`

    if [ $len_hrs -eq 2 ] ;then
        hrs="0"$hrs
    fi

    mns=`echo "$time-($time/60)*60"|bc`
    len_mns=`echo $mns|wc -m`

    if [ $len_mns -eq 2 ] ;then
        mns="0"$mns
    fi

    eval $time1="$hrs:$mns"
    }

function ASC
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep PC_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep PC_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1

    if [ ! -z $U_CUSTOM_ASC_MAC ]; then
        end_input_rule[0]=`echo $U_CUSTOM_ASC_MAC |tr [A-Z] [a-z]`
    fi
    if [ ! -z $U_CUSTOM_ASC_DAYSELECTION ]; then
        end_input_rule[1]=$U_CUSTOM_ASC_DAYSELECTION
    fi
    if [ ! -z $U_CUSTOM_ASC_TIMESTART ]; then
        mns2hrs U_CUSTOM_ASC_TIMESTART
        end_input_rule[2]=$U_CUSTOM_ASC_TIMESTART
    fi
    if [ ! -z $U_CUSTOM_ASC_TIMEEND ]; then
        mns2hrs U_CUSTOM_ASC_TIMEEND
        end_input_rule[3]=$U_CUSTOM_ASC_TIMEEND
    fi

    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_end_index PC_ pc_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_end_index PC_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove Access Scheduler rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v ASC_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "ASC_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove Access Scheduler rules by GUI failed"
        exit 1
    else
        echo "remove Access Scheduler rule by GUI succeeded"
    fi

}

#firewall_st(Service Blocking)
st_rule_param=(ST_NAME \
               ST_PROTOCOL \
               ST_START \
               ST_END \
               ST_MAP \
               ST_IS_DEFAULT)
function STL
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep ST_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep ST_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1


    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_end_index ST_ st_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_end_index ST_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove Firewall_st rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v STL_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "STL_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove Firewall_st rules by GUI failed"
        exit 1
    else
        echo "remove Firewall_st rule by GUI succeeded"
    fi

}

#firewall_sb(Service Blocking)
sb_rule_param=(SB_IPADDR \
               SB_HOSTNAME \
               SB_SERVICETYPE)
function SBL
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep SB_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep SB_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1

    if [ ! -z $G_HOST_TIP0_1_0 ]; then
        end_input_rule[0]=$G_HOST_TIP0_1_0 
    fi
    if [ ! -z $U_CUSTOM_SBL_HOSTNAME ]; then
        end_input_rule[1]=$U_CUSTOM_SBL_HOSTNAME
    fi
    if [ ! -z $TMP_CURRENT_SBL_TYPE ]; then
        end_input_rule[2]=`echo $TMP_CURRENT_SBL_TYPE |sed 's/+/ /g'`
    fi

    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_end_index SB_ sb_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_end_index SB_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove Firewall_sb rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v SBL_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "SBL_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove Firewall_sb rules by GUI failed"
        exit 1
    else
        echo "remove Firewall_sb rule by GUI succeeded"
    fi

}

#Website Blocking
wb_rule_param=(WB_IPADDR \
               WB_HOSTNAME \
               WB_URL)
function WBL
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep WB_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep WB_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1

    if [ ! -z $U_CUSTOM_WBL_IPADDR ]; then
        end_input_rule[0]=$U_CUSTOM_WBL_IPADDR
    fi
    if [ ! -z $U_CUSTOM_WBL_HOSTNAME ]; then
        end_input_rule[1]=$U_CUSTOM_WBL_HOSTNAME
    fi
    if [ ! -z $U_CUSTOM_WBL_URL ]; then
        end_input_rule[2]=`echo $U_CUSTOM_WBL_URL |sed "s/http\:\/\///g"`
    fi

    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_end_index WB_ wb_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_end_index WB_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove WebsiteBlocking rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v WBL_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "WBL_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove Website Blocking rules by GUI failed"
        exit 1
    else
        echo "remove Website Blocking rule by GUI succeeded"
    fi

}

#Wireless Mac Auth
wlmacctrl_rule_param=(wlmacctrl_cpeId \
                      wlmacctrl_pcpeId \
                      wlmacctrl_macAddr)
function WI_MAC_AUTH
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep wlmacctrl_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep wlmacctrl_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1


    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_middle_index wlmacctrl_ wlmacctrl_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_middle_index wlmacctrl_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove wireless mac control rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v WI_MAC_AUTH_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "WI_MAC_AUTH_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove wireless mac control rules by GUI failed"
        exit 1
    else
        echo "remove wirless mac control rule by GUI succeeded"
    fi

}

#LAN DHCP Rerveration
ldhcp_rule_param=(ldhcp_cpeId \
                  ldhcp_pcpeId \
                  ldhcp_enable \
                  ldhcp_ipAddr \
                  ldhcp_macAddr \
                  ldhcp_host)

function LAN_DHCP
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep ldhcp_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep ldhcp_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1

    if [ ! -z $U_CUSTOM_LDHCP_CPEID ]; then
        middle_input_rule[0]=$U_CUSTOM_LDHCP_CPEID
    fi
    if [ ! -z $U_CUSTOM_LDHCP_PCPEID ]; then
        middle_input_rule[1]=$U_CUSTOM_LDHCP_PCPEID
    fi
    if [ ! -z $U_CUSTOM_LDHCP_ENABLE ]; then
        middle_input_rule[2]=$U_CUSTOM_LDHCP_ENABLE
    fi
    if [ ! -z $U_CUSTOM_LDHCP_IPADDR ]; then
        middle_input_rule[3]=$U_CUSTOM_LDHCP_IPADDR 
    fi
    if [ ! -z $G_HOST_MAC0_1_0 ]; then
        middle_input_rule[4]=$G_HOST_MAC0_1_0 
    fi
    if [ ! -z $U_CUSTOM_LDHCP_HOST ]; then
        middle_input_rule[5]=$U_CUSTOM_LDHCP_HOST
    fi

    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_middle_index ldhcp_ ldhcp_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_middle_index ldhcp_
    fi

    rc=$?

    if [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_WARNING : rule index is not existed"
        exit 0
    fi

    if [ $rc -ne 0 ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove lan dhcps static lease rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        LAN_DHCP_CPEID=`grep -i "ldhcp_${i}_cpeId" $G_CURRENTLOG/rules_info.log |awk -F= '{print $2}'|sed 's/\"//g'`
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v LAN_DHCP_RESERVATION_CPEID=$LAN_DHCP_CPEID"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "LAN_DHCP_RESERVATION_CPEID=$LAN_DHCP_CPEID"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove lan dhcps static lease rules by GUI failed"
        exit 1
    else
        echo "remove lan dhcps static lease rule by GUI succeeded"
    fi

}

#DNS Host Mapping
hostmap_rule_param=(hostmap_cpeId \
                    hostmap_ip \
                    hostmap_hostname \
                    hostmap_name)
function DNS_HOST
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep hostmap_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep hostmap_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1


    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_middle_index hostmap_ hostmap_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_middle_index hostmap_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove  hostmap rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v DNS_HOST_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "DNS_HOST_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove hostmap rules by GUI failed"
        exit 1
    else
        echo "remove hostmap rule by GUI succeeded"
    fi

}

#qos class
qcl_rule_param=(qcl_cpeId \
                qcl_pcpeId \
                qcl_tcId \
                qcl_qId \
                qcl_pId \
                qcl_type \
                qcl_classifType \
                qcl_ifType \
                qcl_proto \
                qcl_srcPort \
                qcl_srcPortEnd \
                qcl_dstPort \
                qcl_dstPortEnd \
                qcl_inDscp \
                qcl_dscpMark \
                qcl_inPBits \
                qcl_PBitsMark \
                qcl_vlanId \
                qcl_rateLmt \
                qcl_order \
                qcl_fwPolicy \
                qcl_enable \
                qcl_srcIpExcl \
                qcl_dstIpExcl \
                qcl_protoExcl \
                qcl_srcPortExcl \
                qcl_dstPortExcl \
                qcl_srcMacExcl \
                qcl_dstMacExcl \
                qcl_inDscpExcl \
                qcl_inPBitsExcl \
                qcl_vlanIdExcl \
                qcl_rateCtrlEnbl \
                qcl_className \
                qcl_ifname \
                qcl_srcIp \
                qcl_srcIpMask \
                qcl_dstIp \
                qcl_dstIpMask \
                qcl_srcMac \
                qcl_srcMacMask \
                qcl_dstMac \
                qcl_dstMacMask \
                qcl_specIf)
function QOS
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep qcl_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep qcl_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1


    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_middle_index qcl_ qcl_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_middle_index qcl_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove qos class rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v QOS_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "QOS_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove qos class rules by GUI failed"
        exit 1
    else
        echo "remove qos class rule by GUI succeeded"
    fi

}

#Static routing
route_rule_param=(route_cpeId \
                  route_pcpeId \
                  route_isPR \
                  route_srcIp \
                  route_srcMask \
                  route_srcStartPort \
                  route_srcEndPort \
                  route_dstIp \
                  route_dstMask \
                  route_dstStartPort \
                  route_dstEndPort \
                  route_gw \
                  route_routeIf \
                  route_routeProto \
                  route_diffserv \
                  route_metric \
                  route_fEnable \
                  route_mtuSize \
                  route_type)
function SROUT
{
    #Get the current configuration and covert it to be unix format
    echo "perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep route_ /etc/rc.conf" -o rules_info.log"
    perl $U_PATH_TBIN/DUTCmd.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "grep route_ /etc/rc.conf" -o rules_info.log
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : failed to excute $U_PATH_TBIN/DUTCmd.pl"
        exit 1
    fi
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1
    dos2unix $G_CURRENTLOG/rules_info.log > /dev/null 2>&1


    #Find the index for the input rules or all indexes to remove
    echo ""
    if [ $flag_remove_all = 0 ]; then
        find_middle_index route_ route_rule_param
    elif [ $flag_remove_all = 1 ]; then
        find_all_middle_index route_
    fi

    if [ $? -ne 0 ] || [ -z "$FIT_RULE_INDEX" ]; then
        echo "AT_ERROR : failed to find rule index"
        exit 1
    fi

    # remove the matched rules
    echo -e "Start to remove static routing rules by GUI..."

    #for i in `echo "$FIT_RULE_INDEX" | awk -F, '{print $1}'`
    for i in `echo "$FIT_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v SROUT_RULE_INDEX=$i"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "SROUT_RULE_INDEX=$i"
    done

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove static routing rules by GUI failed"
        exit 1
    else
        echo "remove static routing rule by GUI succeeded"
    fi

}

# Get the input options
while [ $# -gt 0 ]
do
    case "$1" in
    -c)
        U_AUTO_CONF_BIN=playback_http
        U_DUT_TYPE=PK5K1A
        U_AUTO_CONF_PARAM="-d 0"
        U_PATH_TBIN=.
        G_HOST_IF0_1_0=eth1
        G_PROD_IP_BR0_0_0=192.168.0.1
        G_HOST_TIP0_1_0=192.168.0.110
        G_CURRENTLOG="."
        U_DUT_TELNET_USER=root
        U_DUT_TELNET_PWD=admin

        #init end_input_rule by G_HOST_TIP0_1_0
        end_input_rule[6]=$G_HOST_TIP0_1_0
        echo "init:: ${end_input_rule[@]}"

        shift 1
        ;;
    -t)
        rule_type=$2
        echo "rule_type = $rule_type"
        shift 2
        ;;
    -v)
        export "$2"
        shift 2
        ;;
    -p)
        postfile=$2
        echo "postfile : $postfile"
        shift 2
        ;;
    -a)
        flag_remove_all=1
        echo "remove all added rules!"
        shift 1
        ;;
    *)
        echo "$usage"
        exit 1
        ;;
    esac
done


# Handle the remove action of this rule type
if [ -z "$rule_type" ]; then
    echo "AT_ERROR : please specify rule type!"
    echo "$usage"
    exit 1
else
    echo "Start to handle remove action"
    $rule_type
fi

echo "Remove action End"
exit 0

