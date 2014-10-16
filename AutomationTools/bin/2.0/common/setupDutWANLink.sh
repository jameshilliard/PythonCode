#! /bin/bash
#
# Author        :   Howard(hying@actiontec.com)
# Description   :
#   This tool is used to setup the DUT's WAN link .
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#16 Feb 2012    |   1.0.0   | Howard    | Inital Version
#17 Feb 2012    |   1.0.1   | Howard    | fetch Layer3 inf info from DUT cli output
#21 Feb 2012    |   1.0.2   | Howard    | added WAN setting part
#

REV="$0 version 1.0.2 (21 Feb 2012)"
# print REV

echo "${REV}"

# USAGE
USAGE()
{
    cat <<usge
USAGE :

    bash $0 -p < pppoe | ipoe >  -check [ -o <output file> ]

    OPTIONS:

    -p:         the WAN link type , such as PPPoE , IPoE and so on ...
    -o:         [optional] the script's output file
    -set:       [optional] if you want to do the broadband setting or not
    -bonding    [optional] line mode is single or bonding
usge
}

check_only=0
bonding=0
do_wan_setting=0
is_need_to_set=0
wan_link=""
wan_isp=""
check_result=""
post_file_loc=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition

# parse command line
while [ -n "$1" ];
do
    case "$1" in
        -p)
            link_type=$2
            echo "the WAN link type about to switch to is : ${link_type}"
            shift 2
            ;;
        -o)
            log_file=$2
            echo "the log file is ${log_file}"
            shift 2
            ;;
        -check)
            check_only=1
            echo "check only mode ."
            shift 1
            ;;
        -set)
            do_wan_setting=1
            echo "broadband setting will be executed !"
            shift 1
            ;;
        -bonding)
            bonding=1
            echo "enable bonding ..."
            shift 1
            ;;
        *)
            USAGE
            exit 1
    esac
done


broadband_setting(){
    echo "in function broadband_setting() ..."

    if [ $bonding -eq 0 ] ;then
        echo "non-bonding mode , going to disable it "

        if [ "$U_DUT_TYPE" == "TV2KH" ] ;then
            #if [ "$wan_link_pre" != "ETH" ] ;then
            $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-C001  $U_AUTO_CONF_PARAM

            bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

            bonding_result=$?

            if [ $bonding_result -gt 0 ] ;then
                echo "DUT un-reachable after bonding setting !"
                exit 1
            fi

            echo "sleep 30"
            sleep 30

            echo "  re-enable telnet after disable bonding ."

            $U_AUTO_CONF_BIN $U_DUT_TYPE $SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001

            #fi
        fi
    else
        echo "bonding mode , going to enable it "
        if [ "$U_DUT_TYPE" == "TV2KH" ] ;then
            #if [ "$wan_link_pre" != "ETH" ] ;then
            $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-C002  $U_AUTO_CONF_PARAM

            bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

            bonding_result=$?

            if [ $bonding_result -gt 0 ] ;then
                echo "DUT un-reachable after bonding setting !"
                exit 1
            fi

            echo "sleep 30"
            sleep 30

            echo "  re-enable telnet after disable bonding ."

            $U_AUTO_CONF_BIN $U_DUT_TYPE $SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/tr069/Precondition/B-GEN-ENV.PRE-DUT.TELNET-001-C001

            #fi
        fi
    fi

    bash $U_PATH_TBIN/cli_dut.sh -v wan.link -o $G_CURRENTLOG/wan.link.pre.log
    wan_link_pre=`cat $G_CURRENTLOG/wan.link.pre.log | grep "TMP_DUT_WAN_LINK" |awk -F = '{print $2}'`
    wan_isp_pre=`cat $G_CURRENTLOG/wan.link.pre.log | grep "TMP_DUT_WAN_ISP_PROTO" |awk -F = '{print $2}'`

    if [ "$U_DUT_TYPE" == "BHR2" ] ;then
        echo "  going to disable auto detect feature for BHR2"
        echo "  $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-${wan_link}-C004  $U_AUTO_CONF_PARAM"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-ETH-C004  $U_AUTO_CONF_PARAM

        disable_auto_detct=$?

        if [ $disable_auto_detct -gt 0 ] ;then
            echo "AT_ERROR : disable BHR2 auto detect failed ."
            exit 1
        fi
    fi

    echo "going to set broadband setting of $wan_link_pre ..."

    if [ "$U_DUT_TYPE" != "PK5K1A" ] ;then
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-$wan_link_pre-C002  $U_AUTO_CONF_PARAM

        broadband_result=$?

        if [ $broadband_result -gt 0 ] ;then
            echo "AT_Error : occured when doing broadband setting  !"
            exit 1
        fi
    else
        bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240

        wan_rc=$?

        if [ $wan_rc -gt 0 ] ;then
           echo "DUT un-reachable after restore !"
           exit 1
        fi
    fi

    #else
    #echo "  sleep 100"
    #sleep 300
    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 300

    setting_result=$?

    if [ $setting_result -gt 0 ] ;then
        echo "AT_ERROR : ping WAN failed after WAN checking."
        exit 1
    fi
    #fi
    }

get_wan_link(){
    echo "in function get_wan_link() ..."
    
    bash $U_PATH_TBIN/cli_dut.sh -v wan.link -o $G_CURRENTLOG/wan.link.log
    
    wan_isp=`cat $G_CURRENTLOG/wan.link.log | grep "TMP_DUT_WAN_ISP_PROTO" |awk -F = '{print $2}'`
    
    echo " TMP_DUT_WAN_ISP_PROTO is : $wan_isp"
    
    if [ "$wan_isp" == "Unknown" ] || [ "$wan_isp" == "" ] ;then
          nmap -p 23 $G_PROD_IP_BR0_0_0 | tee $G_CURRENTLOG/nmap.output.log | grep "23/tcp open  telnet" > $G_CURRENTLOG/telnet.nmap.log
          telnet_status = `cat $G_CURRENTLOG/telnet.nmap.log`
          try_time=10
          count=0
          while [ "$telnet_status" != "23/tcp open  telnet" ]
          do
              echo "telnet server does not standby"
              cat $G_CURRENTLOG/nmap.output.log
              sleep 5
              echo "wait for 5 second telnet standby"
              nmap -p 23 $G_PROD_IP_BR0_0_0 | tee $G_CURRENTLOG/nmap.output.log | grep "23/tcp open  telnet" > $G_CURRENTLOG/telnet.nmap.log
              telnet_status=`cat $G_CURRENTLOG/telnet.nmap.log`
              echo $telnet_status
              count=`echo "$count+1" | bc`
              if [ $count == $try_time ] ;then
                  echo "telnet is denyed by server"
                  exit 1
              fi
          done
          bash $U_PATH_TBIN/cli_dut.sh -v wan.link -o $G_CURRENTLOG/wan.link.log
    fi
    
    echo "telnet server is standby"
    
    wan_link=`cat $G_CURRENTLOG/wan.link.log | grep "TMP_DUT_WAN_LINK" |awk -F = '{print $2}'`
    wan_isp=`cat $G_CURRENTLOG/wan.link.log | grep "TMP_DUT_WAN_ISP_PROTO" |awk -F = '{print $2}'`
    l3inf=`cat $G_CURRENTLOG/wan.link.log | grep "TMP_CUSTOM_WANINF" |awk -F = '{print $2}'`

    #echo " TMP_CUSTOM_WANINF is : $l3inf"

    if [ "$wan_link" == "" ] ;then
        echo "TMP_DUT_WAN_LINK  is empty !"
        echo "  TMP_DUT_WAN_LINK is ${wan_link}"
        echo "  TMP_DUT_WAN_ISP_PROTO is ${wan_isp}"

        exit 1
    else
        echo "  TMP_DUT_WAN_LINK is ${wan_link}"
        echo "  TMP_DUT_WAN_ISP_PROTO is ${wan_isp}"
    fi
    }

check_wan_link(){
    echo "in function check_wan_link() ..."

    get_wan_link

    echo "current wan isp is : ${wan_isp}"
    echo "dest wan isp is : ${link_type}"

    if [ "$wan_isp" == "$link_type" ] || [ "$link_type" == "STATIC" -a  "$wan_isp" == "IPOE" ] ;then
        if [ $check_only -eq 0 ] ;then
            echo "the current link is already ${link_type} , no need to change it ."
        fi
        check_result="true"
    else
        if [ $check_only -eq 0 ] ;then
            echo "going to change to wan link to ${link_type} .."
        fi
        is_need_to_set=1
        check_result="false"
    fi
    }

#   $U_AUTO_CONF_BIN $U_DUT_TYPE $U_PATH_TR069CFG/$TMP_DUT_WAN_LINK/B-GEN-TR98-LINK-C-FUN-002 $U_AUTO_CONF_PARAM
#   bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120
#   B-GEN-ENV.PRE-DUT.WANCONF-001-$wan_link_pre-C002

set_wan_link(){
    echo "in function set_wan_link() ..."

    #check_wan_link
    get_wan_link
    # B-GEN-TR98-LINK-VDSL-PPPOE-C001
    is_need_to_set=1

    if [ $is_need_to_set -eq 1 ] ;then
        echo "setting ..."
        if [ "$U_DUT_TYPE" == "BAR1KH" ] ;then
            $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-${wan_link}-${link_type}-C003 -v "TMP_CUSTOM_WANINF=$l3inf"  $U_AUTO_CONF_PARAM
        else
            $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-${wan_link}-${link_type}-C003  $U_AUTO_CONF_PARAM
        fi

        bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 120

        #sleep 30

        setting_result=$?

        if [ $setting_result -gt 0 ] ;then
            echo "AT_ERROR : ping WAN failed after WAN setting."
            set_wan_result=1
            #fi
        else
            #exit 1
            if [ "$U_DUT_TYPE" == "BHR2" ] ;then
                echo "  going to disable auto detect feature for BHR2"
                echo "  $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-${wan_link}-C004  $U_AUTO_CONF_PARAM"
                #$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-001-${wan_link}-C004  $U_AUTO_CONF_PARAM

                disable_auto_detct=$?

                if [ $disable_auto_detct -gt 0 ] ;then
                    echo "AT_ERROR : disable BHR2 auto detect failed ."
                    exit 1
                fi
            fi
        fi
    else
        echo "quiting ..."
        set_wan_result=0
    fi
    }


if [ "$U_DUT_TYPE" == "TV2KH" -o "$U_DUT_TYPE" == "BAR1KH" -o "$U_DUT_TYPE" == "FT" -o "$U_DUT_TYPE" == "TDSV2200H" ] && [ "$link_type" != "IPOE" ] || [ "$link_type" == "STATIC" -a "$do_wan_setting" == "1" ] || [ "$U_DUT_TYPE" == "BCV1200" -a "$do_wan_setting" == "1" ] ;then

    if [ $do_wan_setting -eq 1 ] ;then
        broadband_setting
    fi

    if [ $check_only -eq 1 ] ;then
        check_wan_link

        if [ "$check_result" == "true" ] ;then
            echo " check link type passed"

            bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240

            setting_result=$?

            if [ $setting_result -gt 0 ] ;then
                echo "AT_ERROR : ping WAN failed after WAN checking."
                exit 1
            fi

            if [ "$log_file" == "" ] ;then
                log_file=$G_CURRENTLOG/wan_link_info.log
            fi

            bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_link_info.tmp

            cat  $G_CURRENTLOG/wan_link_info.tmp | dos2unix | awk '{printf("%s "),$0}' |tee $log_file

            bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/wan_dns.tmp

            cat  $G_CURRENTLOG/wan_dns.tmp | dos2unix | awk '{printf("%s "),$0}' |tee -a $log_file

            exit 0
        elif [ "$check_result" == "false" ] ;then
            echo " check link type failed"
            exit 1
        fi

    elif [ $check_only -eq 0 ] ;then
        set_wan_link
        echo $check_only
        echo $set_wan_result
        exit $set_wan_result
    fi

else
    #echo "  sleep 100"
    #sleep 30
    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 300

    setting_result=$?

    if [ $setting_result -gt 0 ] ;then
        echo "AT_ERROR : ping WAN failed after WAN checking."
        exit 1
    fi

    check_wan_link

    if [ "$check_result" == "true" ] ;then
        echo " check link type passed"

        bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240

        setting_result=$?

        if [ $setting_result -gt 0 ] ;then
            echo "AT_ERROR : ping WAN failed after WAN checking."
            exit 1
        fi

        if [ "$log_file" == "" ] ;then
            log_file=$G_CURRENTLOG/wan_link_info.log
        fi

        bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_link_info.tmp

        cat  $G_CURRENTLOG/wan_link_info.tmp | dos2unix | awk '{printf("%s "),$0}' |tee $log_file

        bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/wan_dns.tmp

        cat  $G_CURRENTLOG/wan_dns.tmp | dos2unix | awk '{printf("%s "),$0}' |tee -a $log_file

        exit 0
    elif [ "$check_result" == "false" ] ;then
        echo " check link type failed"
        exit 1
    fi 
fi

