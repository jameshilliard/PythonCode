#!/bin/bash
######################################################################################
# Usage : remove_rules.sh [-test] -p <postfile> -v <replace rule 1>
#         -v <replace rule 2> [-t <remove rule type>] [-all <remove all rules>]  
# param : to test the script without testcase, use [-test] before all params.    
#           [-all] [-t] can be omitted                      
#                                                                                
######################################################################################
# Author        : Alex 
# Description   : This script is used to remove the added rules
#
#
# History       :
#   DATE        |   REV     |   AUTH    | INFO
#14 May 2012    |   1.0.0   |   Alex    | Inital Version       
#21 May 2012    |   1.0.1   |   Alex    | modified the method of removing pfo rule through GUI
#23 May 2012    |   1.0.2   |   Alex    | add function of LAN_DHCP
#24 May 2012    |   1.0.3   |   Alex    | add function of WBL
#25 May 2012    |   1.0.4   |   Alex    | add function of SBL
#29 May 2012    |   1.0.5   |   Alex    | add function of APF
#

REV="$0 version 1.0.5 (29 May 2012)"
echo "REV:${REV}"
usage="bash remove_rules.sh [--test] -p <postfile> -v <replace rule> [-all <remove all rules>] [-t <remove rule type:PFO|APFO|LAN_DHCP|WBL|SBL>]"

flag_remove_all=0
#arr_itf=(wildcast eth10 ppp0)
arr_itf=(wildcast)

while [ $# -gt 0 ]
do
    case "$1" in
    --test)
        U_TR069_DEFAULT_CONNECTION_SERVICE=InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1
        U_AUTO_CONF_BIN=playback_http
        U_DUT_TYPE=FT
        U_AUTO_CONF_PARAM="-d 0"
        U_PATH_TBIN=.
        G_HOST_IF0_1_0=eth1
        G_HOST_TIP0_1_0=192.168.1.100
        G_PROD_IP_BR0_0_0=192.168.1.1
        G_CURRENTLOG="./"
        U_DUT_TELNET_USER=root
        U_DUT_TELNET_PWD=admin
        shift 1
        ;;
    -v)
        echo "$2"
        export "$2"
        shift 2
        ;;
    -p)
        postfile=$2
        echo "postfile : $postfile"
        shift 2
        ;;
    -t)
        rule_type=$2
        echo "remove_type : $rule_type"
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

if [ -z "$U_CUSTOM_PFO_SERVER" ]; then
    U_CUSTOM_PFO_SERVER=$G_HOST_TIP0_1_0
fi



PFO(){
    #U_TR069_DEFAULT_CONNECTION_SERVICE\.PortMapping\.
    #true|192.168.1.100||TCP|0|1000|2000|NULL|false|12
    #true|192.168.1.100|192.168.55.254|TCP|0|1000-2000|6000-6005|NULL|false|15

    if [ $flag_remove_all = 0 ]; then

        if [ -z "$U_CUSTOM_PFO_EXTERNAL_END" ]; then
            U_CUSTOM_PFO_EXTERNAL_PORT=$U_CUSTOM_PFO_EXTERNAL_START
        #elif [ "$U_CUSTOM_PFO_EXTERNAL_START" == "$U_CUSTOM_PFO_EXTERNAL_END" ]; then
        #    U_CUSTOM_PFO_EXTERNAL_PORT=$U_CUSTOM_PFO_EXTERNAL_START
        else
            U_CUSTOM_PFO_EXTERNAL_PORT=$U_CUSTOM_PFO_EXTERNAL_START"-"$U_CUSTOM_PFO_EXTERNAL_END
        fi
        echo "U_CUSTOM_PFO_EXTERNAL_PORT : $U_CUSTOM_PFO_EXTERNAL_PORT"

        if [ -z "$U_CUSTOM_PFO_INTERNAL_END" ]; then
            U_CUSTOM_PFO_INTERNAL_PORT=$U_CUSTOM_PFO_INTERNAL_START
        elif [ "$U_CUSTOM_PFO_INTERNAL_START" == "$U_CUSTOM_PFO_INTERNAL_END" ]; then
            U_CUSTOM_PFO_INTERNAL_PORT=$U_CUSTOM_PFO_INTERNAL_START
        else
            U_CUSTOM_PFO_INTERNAL_PORT=$U_CUSTOM_PFO_INTERNAL_START"-"$U_CUSTOM_PFO_INTERNAL_END
        fi
        echo "U_CUSTOM_PFO_INTERNAL_PORT : $U_CUSTOM_PFO_INTERNAL_PORT"

        if [ -z "$U_CUSTOM_PFO_EXTERNAL_PORT" ]; then
            echo "AT_ERROR : remove one PFO rule, BUT not specify parameter U_CUSTOM_PFO_EXTERNAL_PORT!"
            exit 1
        fi
        
        for itf in "${arr_itf[@]}"
        do
            echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c fw get_pmap $itf\" -t PFO_rules_info_$itf.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
            perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c fw get_pmap $itf" -t PFO_rules_info_$itf.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
    
            if [ $? -ne 0 ]; then
                echo "AT_WARNNING : failed to excute -v \"cli -c fw get_pmap $itf\" by $U_PATH_TBIN/clicfg.pl"
                continue
            fi
            dos2unix $G_CURRENTLOG/PFO_rules_info_$itf.log  > /dev/null 2>&1

            #true|192.168.1.100||TCP|0|1000|2000|NULL|false|12
            for pfo_rule in `grep -E "^\@(true|false)" $G_CURRENTLOG/PFO_rules_info_$itf.log| grep "|$U_CUSTOM_PFO_SERVER|" `
            do
                REMOTE_DST_PORT=`echo $pfo_rule | awk -F '|' '{print $6}'`
            echo "REMOTE_DST_PORT=$REMOTE_DST_PORT"
#                echo "REMOTE_DST_PORT : $REMOTE_DST_PORT"
               # if [ "$REMOTE_DST_PORT" == "$U_CUSTOM_PFO_EXTERNAL_PORT" ]; then
                    rule_idx=`echo $pfo_rule | awk -F '|' '{print $10}'`
            	 	echo "rule_idx=$rule_idx"
                    break
               # fi
            done

            if [ ! -z "$rule_idx" ]; then                        
                rule_idx=$rule_idx"_"$itf                        
                break
            fi

        done

        if [ -z "$rule_idx" ]; then
            echo "AT_ERROR : AT_ERROR : cannot find PFO rule index for U_CUSTOM_PFO_EXTERNAL_PORT=$U_CUSTOM_PFO_EXTERNAL_PORT"
            exit 1
        fi
        
        PFO_RULE_INDEX=$rule_idx
        echo -e "\nPFO_RULE_INDEX : $PFO_RULE_INDEX"

    elif [ $flag_remove_all = 1 ]; then   
        for itf in "${arr_itf[@]}"            
        do
            echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c fw get_pmap $itf\" -t PFO_rules_info_$itf.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
            perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c fw get_pmap $itf" -t PFO_rules_info_$itf.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
    
            if [ $? -ne 0 ]; then
                echo "AT_WARNNING : failed to excute -v \"cli -c fw get_pmap $itf\" by $U_PATH_TBIN/clicfg.pl"
                continue
            fi
            dos2unix $G_CURRENTLOG/PFO_rules_info_$itf.log  > /dev/null 2>&1

            #true|192.168.1.100||TCP|0|1000|2000|NULL|false|12
            for rule_idx in `grep -E "^\@(true|false)" $G_CURRENTLOG/PFO_rules_info_$itf.log | awk -F '|' '{print $10}'`
            do
#                echo "rule_idx: $rule_idx"
                if [ ! -z "$rule_idx" ]; then
                    rule_idx=$rule_idx"_"$itf
                    if [ -z "$PFO_RULE_INDEX" ]; then
                        PFO_RULE_INDEX=$rule_idx
                    else
                        PFO_RULE_INDEX=$PFO_RULE_INDEX"."$rule_idx
                    fi
                fi
            done

        done

        if [ -z "$PFO_RULE_INDEX" ]; then
            echo "AT_ERROR : AT_ERROR : cannot find PFO rule index needed to remove!"
            exit 1
        else
            echo -e "\nPFO_RULE_INDEX : $PFO_RULE_INDEX"
        fi
    fi
    
    echo -e "start to remove PFO rule by GUI..."
    for PFO_RULE_INDEX_ALL in $PFO_RULE_INDEX
        do
            echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM"
            $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "PFO_RULE_INDEX=$PFO_RULE_INDEX_ALL"
        
            if [ $? -ne 0 ] ;then
                echo "AT_ERROR : remove PFO rule by GUI failed"
                exit 1
            else
                echo "remove PFO rule by GUI succeeded"
                exit 0
            fi
        done
}


APF(){
#   PFO
 #  exit 0
#    if [ -z "$U_CUSTOM_APF_SERVICE_NAME" ]; then
#        echo "AT_ERROR : remove APF rule, BUT not specify parameter U_CUSTOM_APF_SERVICE_NAME!"
#        exit 1
#    fi

    echo "in functin APF"
   # echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c adv get_port_fwd\" -t PFO_service_list.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
   # perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c adv get_port_fwd" -t PFO_service_list.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

   # if [ $? -ne 0 ]; then
   #     echo "AT_WARNNING : failed to excute -v \"cli -c adv get_port_fwd\" by $U_PATH_TBIN/clicfg.pl"
   #     continue
   # fi
   # dos2unix $G_CURRENTLOG/PFO_service_list.log  > /dev/null 2>&1

   # service_ID=`grep "^\@$U_CUSTOM_APF_SERVICE_NAME" $G_CURRENTLOG/PFO_service_list.log | awk 'BEGIN{FS="|"}{print $NF}'`

    echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c fw get_pmap wildcast\" -t PFO_rules_info_wildcast.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c fw get_pmap wildcast" -t PFO_rules_info_wildcast.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
   # 
    if [ $? -ne 0 ]; then
        echo "AT_WARNNING : failed to excute -v \"cli -c fw get_pmap wildcast\" by $U_PATH_TBIN/clicfg.pl"
        continue
    fi
    dos2unix $G_CURRENTLOG/PFO_rules_info_wildcast.log > /dev/null 2>&1

    if [ $flag_remove_all = 0 ]; then
      PFO_RULE_INDEX=`grep "^\@true" $G_CURRENTLOG/PFO_rules_info_wildcast.log|awk -F '|' '{print $10}'`

      echo -e "\nPFO_RULE_INDEX : $PFO_RULE_INDEX"

      echo -e "start to remove APF rule by GUI..."
      echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM"
      $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "PFO_RULE_INDEX=$PFO_RULE_INDEX"

      if [ $? -ne 0 ] ;then
          echo "AT_ERROR : remove APF rule by GUI failed"
          exit 1
      else
          echo "remove APF rule by GUI succeeded"
      fi

   elif [ $flag_remove_all = 1 ]; then
           for rule_idx in `grep -E "^\@(true|false)" $G_CURRENTLOG/PFO_rules_info_wildcast.log | awk -F '|' '{print $10}'`
            do
#                echo "rule_idx: $rule_idx"
                if [ ! -z "$rule_idx" ]; then
                    rule_idx=$rule_idx"_"$itf
                    if [ -z "$PFO_RULE_INDEX" ]; then
                        PFO_RULE_INDEX=$rule_idx
                    else
                        PFO_RULE_INDEX=$PFO_RULE_INDEX"."$rule_idx
                    fi
                fi
             done
        if [ -z "$PFO_RULE_INDEX" ]; then
            echo "AT_ERROR : AT_ERROR : cannot find APF rule index needed to remove!"
            exit 1
        else
            echo -e "\nPFO_RULE_INDEX : $PFO_RULE_INDEX"
        fi
    
    
    echo -e "start to remove APF rule by GUI..."
    for PFO_RULE_INDEX_ALL in $PFO_RULE_INDEX
        do
            echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM"
            $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "PFO_RULE_INDEX=$PFO_RULE_INDEX_ALL"
        
            if [ $? -ne 0 ] ;then
                echo "AT_ERROR : remove APF rule by GUI failed"
                exit 1
            else
                echo "remove APF rule by GUI succeeded"
                exit 0
            fi
        done
 
   fi
   exit 0
}


#function LAN_DHCP
#{         
#    echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c adv get_conn\" -t dhcp_conn_list.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
#    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c adv get_conn" -t dhcp_conn_list.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD                
#
#    if [ $? -ne 0 ]; then
#        echo "AT_WARNNING : failed to excute -v \"cli -c fw get_pmap $itf\" by $U_PATH_TBIN/clicfg.pl"
#        continue
#    fi
#    dos2unix $G_CURRENTLOG/dhcp_conn_list.log  > /dev/null 2>&1
#
#    if [ $flag_remove_all = 0 ]; then
#       if [ -z "$G_PROD_DHCPSTART_BR0_0_0" -a -z "$G_HOST_MAC0_1_0" ]; then
#          echo "AT_ERROR : not defined parameter G_PROD_DHCPSTART_BR0_0_0 or G_HOST_MAC0_1_0"
#          exit 1
#       fi
#
#       echo "grep -i \"|$G_PROD_DHCPSTART_BR0_0_0|$G_HOST_MAC0_1_0|\" $G_CURRENTLOG/dhcp_conn_list.log | awk 'BEGIN{FS=\"|\"}{print $NF}'"
#       LAN_DHCP_RULE_INDEX=`grep -i "|$G_PROD_DHCPSTART_BR0_0_0|$G_HOST_MAC0_1_0|" $G_CURRENTLOG/dhcp_conn_list.log | awk 'BEGIN{FS="|"}{print $NF}'`
#    elif [ $flag_remove_all = 1 ]; then
#       for dhcp_rule_index in `grep "^\@.*|.*|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}|.*|.*|.*|.*|.*|.*$" $G_CURRENTLOG/dhcp_conn_list.log | awk 'BEGIN{FS="|"}{print $NF}'`
#        do
#            if [ -z "$LAN_DHCP_RULE_INDEX" ]; then
#                LAN_DHCP_RULE_INDEX=$dhcp_rule_index
#            else
#                LAN_DHCP_RULE_INDEX=$LAN_DHCP_RULE_INDEX","$dhcp_rule_index
#            fi
#        done
#    fi     
#
#    echo "LAN_DHCP_RULE_INDEX : $LAN_DHCP_RULE_INDEX"
#     
#    echo -e "start to remove LAN DHCP rule by GUI..."
#    
#    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v \"LAN_DHCP_RULE_INDEX=$LAN_DHCP_RULE_INDEX\""
#    $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "LAN_DHCP_RULE_INDEX=$LAN_DHCP_RULE_INDEX"
#
#    if [ $? -ne 0 ] ;then
#        echo "AT_ERROR : remove LAN DHCP rule by GUI failed"
#        exit 1
#    else
#        echo "remove LAN DHCP rule by GUI succeeded"
#    fi
#}

WBL(){
    echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c fw get_parent\" -t web_block.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c fw get_parent" -t web_block.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD                

    if [ $? -ne 0 ]; then
        echo "AT_WARNNING : failed to excute -v \"cli -c fw get_parent\" by $U_PATH_TBIN/clicfg.pl"
        continue
    fi
    dos2unix $G_CURRENTLOG/web_block.log  > /dev/null 2>&1

    if [ $flag_remove_all = 0 ]; then
        if [ -z "$U_CUSTOM_HTTP_HOST" -a -z "$G_HOST_TIP0_1_0" ]; then
           echo "AT_ERROR : not defined parameter U_CUSTOM_HTTP_HOST or G_HOST_TIP0_1_0"
           exit 1
        fi

        echo "grep \"|$G_HOST_TIP0_1_0;|Website:$U_CUSTOM_HTTP_HOST;|\" $G_CURRENTLOG/web_block.log | awk 'BEGIN{FS=\"|\"}{print $2}'"
        WBL_RULE_INDEX=`grep "|$G_HOST_TIP0_1_0;|Website:$U_CUSTOM_HTTP_HOST;|" $G_CURRENTLOG/web_block.log | awk 'BEGIN{FS="|"}{print $2}'`
    elif [ $flag_remove_all = 1 ]; then
        for wbl_rule_index in `grep "^\@[a-zA-Z]*|[0-9]*|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\};" $G_CURRENTLOG/web_block.log | awk 'BEGIN{FS="|"}{print $2}'`
        do
            if [ -z "$WBL_RULE_INDEX" ]; then
                WBL_RULE_INDEX=$wbl_rule_index
            else
                WBL_RULE_INDEX=$WBL_RULE_INDEX","$wbl_rule_index
            fi
        done
    fi

    echo "WBL_RULE_INDEX : $WBL_RULE_INDEX"
     
    echo -e "start to remove Website Blocking rule by GUI..."
    
    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v \"WBL_RULE_INDEX=$WBL_RULE_INDEX\""
    $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "WBL_RULE_INDEX=$WBL_RULE_INDEX"

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove Website Blocking rule by GUI failed"
        exit 1
    else
        echo "remove Website Blocking rule by GUI succeeded"
        exit 0
    fi
}

SBL(){
    echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c fw get_access block\" -t service_block.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c fw get_access block" -t service_block.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    if [ $? -ne 0 ]; then
        echo "AT_WARNNING : failed to excute -v \"cli -c fw get_parent\" by $U_PATH_TBIN/clicfg.pl"
        continue
    fi
    dos2unix $G_CURRENTLOG/service_block.log  > /dev/null 2>&1

    if [ $flag_remove_all = 0 ]; then
        if [ -z "$TMP_CURRENT_SBL_TYPE" -a -z "$G_HOST_TIP0_1_0" ]; then
           echo "AT_ERROR : not defined parameter TMP_CURRENT_SBL_TYPE or G_HOST_TIP0_1_0"
           exit 1
        fi

        #true|192.168.1.100|255.255.255.255|0.0.0.0|255.255.255.255|ALL|NULL|NULL|false|0|false|0|false|0|0|Drop|false|true|FTP|false||eth10|15


        #echo "grep \"^\@|.*|$G_HOST_TIP0_1_0|.*|.*|.*|.*|.*|.*|.*|.*|.*|.*|.*|.*|.*|.*|.*|.*|$TMP_CURRENT_SBL_TYPE|.*|.*|eth10|.*$\" $G_CURRENTLOG/service_block.log | awk 'BEGIN{FS=\"|\"}{print $NF}'"
        if [ "$TMP_CURRENT_SBL_TYPE" == "FTP" ]; then
           SBL_RULE_INDEX=`grep "^\@[a-zA-Z]*|$G_HOST_TIP0_1_0|.*|$TMP_CURRENT_SBL_TYPE" $G_CURRENTLOG/service_block.log | awk 'BEGIN{FS="|"}{print $7}'`
        else
           
           SBL_RULE_INDEX=`grep "^\@[a-zA-Z]*|$G_HOST_TIP0_1_0|.*|$TMP_CURRENT_SBL_TYPE" $G_CURRENTLOG/service_block.log | awk 'BEGIN{FS="|"}{print $NF}'`
        fi   
    elif [ $flag_remove_all = 1 ]; then
        for sbl_rule_index in `grep "^\@[a-zA-Z]*|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}|.*" $G_CURRENTLOG/service_block.log | awk 'BEGIN{FS="|"}{print $NF}'`
        do
            if [ -z "$SBL_RULE_INDEX" ]; then
                SBL_RULE_INDEX=$sbl_rule_index
            else
                SBL_RULE_INDEX=$SBL_RULE_INDEX","$sbl_rule_index
            fi
        done
    fi

   PFO_RULE_INDEX=$SBL_RULE_INDEX
    echo "PFO_RULE_INDEX : $PFO_RULE_INDEX"
     
    echo -e "start to remove Service Blocking rule by GUI..."
    
    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v \"PFO_RULE_INDEX=$PFO_RULE_INDEX\""
    $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "PFO_RULE_INDEX=$PFO_RULE_INDEX"

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove Service Blocking rule by GUI failed"
        exit 1
    else
        echo "remove Service Blocking rule by GUI succeeded"
        exit 0
    fi
}

LAN_DHCP(){

    ## refrash revervation list
    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_CFG/No-8903-c004 $U_AUTO_CONF_PARAM"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_CFG/No-8903-c004 $U_AUTO_CONF_PARAM

    echo "perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cli -c adv get_conn\" -t lan_dhcp.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
    perl $U_PATH_TBIN/clicfg.pl  -l $G_CURRENTLOG -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cli -c adv get_conn" -t lan_dhcp.log -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD

    if [ $? -ne 0 ]; then
        echo "AT_WARNNING : failed to excute -v \"cli -c adv get_conn\" by $U_PATH_TBIN/clicfg.pl"
        continue
    fi
    dos2unix $G_CURRENTLOG/lan_dhcp.log  > /dev/null 2>&1

    if [ $flag_remove_all = 0 ]; then
        if [ -z "$G_HOST_MAC0_1_0" ]; then
            echo "AT_ERROR : not defined parameter G_HOST_MAC0_1_0"
            exit 1
        else
            LAN_DHCP_RULE_INDEX=`grep "^\@Network.*|.*|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" $G_CURRENTLOG/lan_dhcp.log | grep -i "$G_HOST_MAC0_1_0" | awk 'BEGIN{FS="|"}{print $NF}'`
        fi
    elif [ $flag_remove_all = 1 ]; then
        for lan_dhcp_rule_index in `grep "^\@Network.*|.*|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" $G_CURRENTLOG/lan_dhcp.log | awk 'BEGIN{FS="|"}{print $NF}'`
        do
            if [ -z "$LAN_DHCP_RULE_INDEX" ]; then
                LAN_DHCP_RULE_INDEX=$lan_dhcp_rule_index
            else
                LAN_DHCP_RULE_INDEX=$LAN_DHCP_RULE_INDEX","$lan_dhcp_rule_index
            fi
        done
    fi

    echo "LAN_DHCP_RULE_INDEX : $LAN_DHCP_RULE_INDEX"
     
    echo -e "start to remove lan dhcp rule by GUI..."
    for i in `echo "$LAN_DHCP_RULE_INDEX" | sed 's/,/ /g'`
    do
        echo "To remove rule index $i"
        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v \"LAN_DHCP_RULE_INDEX=$i\""
        $U_AUTO_CONF_BIN $U_DUT_TYPE $postfile $U_AUTO_CONF_PARAM -v "LAN_DHCP_RULE_INDEX=$i"
    done 
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : remove lan dhcp rule by GUI failed"
        exit 1
    else
        echo "remove lan dhcp rule by GUI succeeded"
        exit 0
    fi
}



#if [ -z "$rule_type" ]; then
#    echo "AT_ERROR : please specify rule type!"
#    exit 1
#else
#    $rule_type
#    exit 0
#fi
# main entry
$rule_type 2> /dev/null

execute_result=$?

if [ $execute_result -eq 0 ] ;then
        echo "passed"
        exit 0
else
    echo "ERROR occured !"
    echo -e $usage
    exit 1
fi


