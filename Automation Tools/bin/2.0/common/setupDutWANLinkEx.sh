#! /bin/bash
#
# Author        :   Andy(aliu@actiontec.com)
# Description   :
#   This tool is used to setup the DUT's WAN link .
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#03 Jul 2012    |   1.0.0   | Andy      | Inital Version

REV="$0 version 1.0.0 (03 Jul 2012)"

echo "${REV}"

# USAGE
USAGE()
{
    cat <<usge
USAGE :

    bash $0 -linenum <line1/line2> -linemode <ADSL/VDSL/ETH> -bonding -waninfc <ATM/PTM> -tagged <tagge ID> -protocol <PPPOE/PPPOA/IPOE/STATIC/Bridging> [-set] [-check] [-test]

    OPTIONS:

    -linenum            Line index , default is line1
    -linemode           Line mode, default is ADSL
    -bonding            Bonding mode, if NOT set this parameter ,it's single mode
    -waninfc            WAN interface, default is ATM
    -tagged             tagged ID, default is None (untagged)
    -protocol           Protocol , default is IPOE

    -set                Do set WAN
    -check              Do check

    -test               Test mode
usge
}

NOTDEFINED='None'

linenum=line1
linemode=ADSL
bonding=0
waninfc=ATM
taggedid=$NOTDEFINED
protocol=IPOE
do_check=0
do_wan_setting=0

if [ "$U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE" == "1" ] ;then
    post_file_loc=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Precondition
else
    post_file_loc=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Precondition/NO-DETECT
fi

while [ -n "$1" ];
do
    case "$1" in
        -test)
            echo "Mode : Test mode"
            U_PATH_TBIN=/root/automation/bin/2.0/CTLC2KA
            shift 1
            ;;

        -linenum)
            echo "Line number : $2"
            linenum="$2"
            shift 2
            ;;

        -linemode)
            echo "Line mode : $2"
            linemode="$2"
            shift 2
            ;;

        -bonding)
            bonding=1
            echo "Bonding mode"
            shift 1
            ;;

        -waninfc)
            echo "WAN interface : $2"
            waninfc="$2"
            shift 2
            ;;

        -tagged)
            echo "Tagged ID : $2"
            taggedid="$2"
            shift 2
            ;;

        -protocol)
            echo "Protocol : $2"
            protocol="$2"
            shift 2
            ;;

        -check)
            do_check=1
            echo "Check mode !"
            shift 1
            ;;

        -set)
            do_wan_setting=1
            echo "Set mode !"
            shift 1
            ;;

        *)
            USAGE
            exit 1
            ;;
    esac
done

export_wan_info(){
    echo "AT_INFO : In function export_wan_info"

    if [ "$U_CUSTOM_UPDATE_ENV_FILE" ] ;then
        output=$U_CUSTOM_UPDATE_ENV_FILE
    else
        output=$G_CURRENTLOG/setDutWANLinkEx.log
    fi

    bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_link_info.tmp

    cat  $G_CURRENTLOG/wan_link_info.tmp | dos2unix | tee $output

    bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/wan_dns.tmp

    cat  $G_CURRENTLOG/wan_dns.tmp | dos2unix | tee -a $output

    exit 0
}

get_wan_link(){
    echo "AT_INFO : In function get_wan_link"

    bash $U_PATH_TBIN/cli_dut.sh -v wan.link -o $G_CURRENTLOG/wan_link.log
    wan_link=`cat $G_CURRENTLOG/wan_link.log | grep "TMP_DUT_WAN_LINK"      |awk -F = '{print $2}'`
    wan_isp=` cat $G_CURRENTLOG/wan_link.log | grep "TMP_DUT_WAN_ISP_PROTO" |awk -F = '{print $2}'`
    l3inf=`   cat $G_CURRENTLOG/wan_link.log | grep "TMP_CUSTOM_WANINF"     |awk -F = '{print $2}'`

    if [ -z "$wan_link" ] ;then
        echo "TMP_DUT_WAN_LINK  is empty !"
        echo "TMP_DUT_WAN_ISP_PROTO is ${wan_isp}"

        exit 1
    else
        echo "TMP_DUT_WAN_LINK is ${wan_link}"
        echo "TMP_DUT_WAN_ISP_PROTO is ${wan_isp}"
    fi
}

check_wan_link(){
    echo "AT_INFO : In function check_wan_link"

    get_wan_link

    echo "Current wan isp is : $wan_isp"
    echo "Dest wan isp is : $protocol"

    if [ "$wan_isp" == "$protocol" ] || [ "$protocol" == "STATIC" -a  "$wan_isp" == "IPOE" ] || [ "$protocol" == "PPPOA" -a  "$wan_isp" == "PPPOE" ] ;then
        echo "AT_INFO : The current link is already $protocol"

        bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240

        if [ $? -ne 0 ] ;then
            echo "AT_ERROR : Ping WAN failed after WAN checking."
            exit 1
        fi

        export_wan_info
    else
        echo "AT_ERROR : The current link is not dest wan isp $protocol"
        exit 1
    fi
}

restart_WAN_server(){

    if [ "$swboard_cmd" == "as" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAS

    elif [ "$swboard_cmd" == "ab" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAB

    elif [ "$swboard_cmd" == "vs" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVS

    elif [ "$swboard_cmd" == "vb" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVB

        ######## TAGGED #######
    elif [ "$swboard_cmd" == "ast" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAST

    elif [ "$swboard_cmd" == "abt" ] ;then
        VLAN_ID=$U_CUSTOM_VLANABT

    elif [ "$swboard_cmd" == "vst" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVST

    elif [ "$swboard_cmd" == "vbt" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVBT

    fi

    $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/RESTART_WANSERVER.log -d $G_HOST_IP1 -p 22 -u $G_HOST_USR1 -p $G_HOST_PWD1 \
    -v "cd /root/START_SERVERS/;sed -i \"s/^VLAN_LIST.*/VLAN_LIST $VLAN_ID/g\" config_net.conf;./config_net.sh"

    rc_wan_server=$?

    if [ $rc_wan_server -eq 0 ] ;then
        echo "AT_INFO : restart WAN server OK"
    else
        echo "AT_INFO : restart WAN server FAILED"
        exit 1
    fi

    }
set_physical_line(){
    echo "AT_INFO : IN function set_physical_line"

    phyx_line_status=$1

    if [ "$phyx_line_status" == "down" ] ;then
        swb_cmd=" -n"
    elif [ "$phyx_line_status" == "reboot" ] ;then
        swb_cmd=" -p 0"

        if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
            echo "$U_PATH_TOOLS/common/switch_controller $swb_cmd"

            $U_PATH_TOOLS/common/switch_controller $swb_cmd
        else
            echo "$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -p 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW -v \"switch_controller $swb_cmd\""

            $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -p 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
    -v "switch_controller $swb_cmd"

            grep "ExitCode 0" $G_CURRENTLOG/WECB_SWLINE.log

            rc_SWLINE=$?

            if [ $rc_SWLINE -eq 0 ] ;then
                echo "AT_INFO : switch phyx line OK"
            else
                echo "AT_INFO : switch phyx line FAILED"
                exit 1
            fi
        fi

        swb_cmd=" -p 1"
    elif [ "$phyx_line_status" == "as" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAS
        swb_cmd="-m ADSL -B 0 -l 1"
    elif [ "$phyx_line_status" == "ab" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAB
        swb_cmd="-m ADSL -B 1"
    elif [ "$phyx_line_status" == "vs" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVS
        swb_cmd="-m VDSL -B 0 -l 1"
    elif [ "$phyx_line_status" == "vb" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVB
        swb_cmd="-m VDSL -B 1"
        ######## TAGGED #######
    elif [ "$phyx_line_status" == "ast" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAST
        swb_cmd="-m $U_CUSTOM_ALIAS_AST"
    elif [ "$phyx_line_status" == "abt" ] ;then
        VLAN_ID=$U_CUSTOM_VLANABT
        swb_cmd="-m $U_CUSTOM_ALIAS_ABT"
    elif [ "$phyx_line_status" == "vst" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVST
        swb_cmd="-m $U_CUSTOM_ALIAS_VST"
    elif [ "$phyx_line_status" == "vbt" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVBT
        swb_cmd="-m $U_CUSTOM_ALIAS_VBT"

    fi

    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "$U_PATH_TOOLS/common/switch_controller $swb_cmd"

        $U_PATH_TOOLS/common/switch_controller $swb_cmd
    else
        echo "$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -p 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW -v \"switch_controller $swb_cmd\""

        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -p 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
-v "switch_controller $swb_cmd"

        grep "ExitCode 0" $G_CURRENTLOG/WECB_SWLINE.log

        rc_SWLINE=$?

        if [ $rc_SWLINE -eq 0 ] ;then
            echo "AT_INFO : switch phyx line OK"
        else
            echo "AT_INFO : switch phyx line FAILED"
            exit 1
        fi
    fi
}

dsl_bonding_setting(){
    echo "AT_INFO : In function dsl_bonding_setting"

    if [ "$U_DUT_TYPE" == "TV2KH" ] ;then
        get_wan_link

        if [ $bonding -eq 0 ] ;then
            echo "AT_INFO : Single line mode , going to disable it"

            if [ "$wan_link" == "ADSL" ] ;then
                echo "AT_INFO : Single line ADSL"
                echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-ADSL-SINGLE $U_AUTO_CONF_PARAM"
                $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-ADSL-SINGLE $U_AUTO_CONF_PARAM
            elif [ "$wan_link" == "VDSL" ] ;then
                echo "AT_INFO : Single line VDSL"
                echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-VDSL-SINGLE $U_AUTO_CONF_PARAM"
                $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-VDSL-SINGLE $U_AUTO_CONF_PARAM
            fi

            bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

            if [ $? -ne 0 ] ;then
                echo "AT_ERROR : DUT un-reachable after bonding setting"
                exit 1
            fi
        else
            echo "AT_INFO : Bonding mode , going to enable it"

            if [ "$wan_link" == "ADSL" ] ;then
                echo "AT_INFO : Bonding ADSL"
                echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-ADSL-BONDING $U_AUTO_CONF_PARAM"
                $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-ADSL-BONDING $U_AUTO_CONF_PARAM
            elif [ "$wan_link" == "VDSL" ] ;then
                echo "AT_INFO : Bonding VDSL"
                echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-VDSL-BONDING $U_AUTO_CONF_PARAM"
                $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-VDSL-BONDING $U_AUTO_CONF_PARAM
            fi

            bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

            if [ $? -ne 0 ] ;then
                echo "AT_ERROR : DUT un-reachable after bonding setting"
                exit 1
            fi
        fi
        echo "sleep 240"
        sleep 240
    else
        echo "AT_INFO : Skipped dsl_bonding_setting"
        return 0
    fi

    #### GUI check
    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-GUI-CHECK $U_AUTO_CONF_PARA -l $G_CURRENTLOG/GUI-CKECK-BONDING-SETTING
}

broadband_setting(){
    echo "AT_INFO : In function broadband_setting"

    if [ "$U_DUT_TYPE" == "PK5K1A" ] ;then
        bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 300

        echo "AT_INFO : DUT type is PK5K1A"
        if [ $? -ne 0 ] ;then
            echo "AT_ERROR : DUT un-reachable after restore"
            exit 1
        else
            echo "AT_INFO : DUT reachable after restore"
            return 0
        fi
    elif [ "$U_DUT_TYPE" == "BHR2" ] ;then
        echo "AT_INFO : DUT type is BHR2"
        echo "AT_INFO : Going to disable auto detect feature for BHR2"

        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-DISABLE-AUTO-DETECT $U_AUTO_CONF_PARAM"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-DISABLE-AUTO-DETECT $U_AUTO_CONF_PARAM

        if [ $? -ne 0 ] ;then
            echo "AT_ERROR : Disable BHR2 auto detect failed"
            exit 1
        else
            echo "AT_INFO : Disable BHR2 auto detect passed"
            return 0
        fi
    else
        if [ "$U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE" == "0" ] ;then
            echo "using switch board"

            swboard_cmd=""

            if [ $bonding -eq 0 ] ;then
                echo "AT_INFO : Single line mode"

                if [ "$taggedid" == "$NOTDEFINED" ] ;then
                    echo "AT_INFO : untagged mode"

                    if [ "$linemode" == "ADSL" ] ;then
                        echo "AT_INFO : Single line ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM"

                        swboard_cmd="as"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM
                    elif [ "$linemode" == "VDSL" ] ;then
                        echo "AT_INFO : Single line VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM"

                        swboard_cmd="vs"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM
                    elif [ "$linemode" == "ETH" ] ;then
                        echo "AT_INFO : Ethernet"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-SINGLE-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM"

                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM
                    fi
                else
                    echo "AT_INFO : tagged mode"

                    if [ "$linemode" == "ADSL" ] ;then
                        echo "AT_INFO : Single line ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-TAGGED-NO-DETECT -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        swboard_cmd="ast"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-TAGGED-NO-DETECT -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    elif [ "$linemode" == "VDSL" ] ;then
                        echo "AT_INFO : Single line VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-TAGGED-NO-DETECT -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        swboard_cmd="vst"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-TAGGED-NO-DETECT -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    elif [ "$linemode" == "ETH" ] ;then
                        echo "AT_INFO : Ethernet"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-TAGGED-NO-DETECT -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-TAGGED-NO-DETECT -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    fi
                fi

                bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

                if [ $? -ne 0 ] ;then
                    echo "AT_ERROR : DUT un-reachable after broadband setting"
                    exit 1
                fi
            else
                echo "AT_INFO : Bonding mode"

                if [ "$taggedid" == "$NOTDEFINED" ] ;then
                    echo "AT_INFO : untagged mode"

                    if [ "$linemode" == "ADSL" ] ;then
                        echo "AT_INFO : Bonding ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-UNTAGGED-NO-DETECT  $U_AUTO_CONF_PARAM"

                        swboard_cmd="ab"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-UNTAGGED-NO-DETECT  $U_AUTO_CONF_PARAM
                    elif [ "$linemode" == "VDSL" ] ;then
                        echo "AT_INFO : Bonding VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-UNTAGGED-NO-DETECT  $U_AUTO_CONF_PARAM"

                        swboard_cmd="vb"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-UNTAGGED-NO-DETECT  $U_AUTO_CONF_PARAM
                    fi
                else
                    echo "AT_INFO : tagged mode"

                    if [ "$linemode" == "ADSL" ] ;then
                        echo "AT_INFO : Bonding ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-TAGGED-NO-DETECT -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        swboard_cmd="abt"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-TAGGED-NO-DETECT -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    elif [ "$linemode" == "VDSL" ] ;then
                        echo "AT_INFO : Bonding VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-TAGGED-NO-DETECT -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        swboard_cmd="vbt"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-TAGGED-NO-DETECT -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    fi
                fi

                bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

                if [ $? -ne 0 ] ;then
                    echo "AT_ERROR : DUT un-reachable after broadband setting"
                    exit 1
                fi
            fi
        else
            echo "no switch board"

            get_wan_link

            if [ $bonding -eq 0 ] ;then
                echo "AT_INFO : Single line mode"

                if [ "$taggedid" == "$NOTDEFINED" ] ;then
                    echo "AT_INFO : untagged mode"

                    if [ "$wan_link" == "ADSL" ] ;then
                        echo "AT_INFO : Single line ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-UNTAGGED $U_AUTO_CONF_PARAM"

                        #swboard_cmd="as"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-UNTAGGED $U_AUTO_CONF_PARAM
                    elif [ "$wan_link" == "VDSL" ] ;then
                        echo "AT_INFO : Single line VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-UNTAGGED $U_AUTO_CONF_PARAM"

                        #swboard_cmd="vs"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-UNTAGGED $U_AUTO_CONF_PARAM
                    elif [ "$wan_link" == "ETH" ] ;then
                        echo "AT_INFO : Ethernet"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-SINGLE-UNTAGGED $U_AUTO_CONF_PARAM"

                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-UNTAGGED $U_AUTO_CONF_PARAM
                    fi
                else
                    echo "AT_INFO : tagged mode"

                    if [ "$wan_link" == "ADSL" ] ;then
                        echo "AT_INFO : Single line ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-TAGGED -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        #swboard_cmd="ast"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-SINGLE-TAGGED -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    elif [ "$wan_link" == "VDSL" ] ;then
                        echo "AT_INFO : Single line VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-TAGGED -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        #swboard_cmd="vst"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-SINGLE-TAGGED -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    elif [ "$wan_link" == "ETH" ] ;then
                        echo "AT_INFO : Ethernet"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-TAGGED -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ETH-TAGGED -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    fi
                fi

                bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

                if [ $? -ne 0 ] ;then
                    echo "AT_ERROR : DUT un-reachable after broadband setting"
                    exit 1
                fi
            else
                echo "AT_INFO : Bonding mode"

                if [ "$taggedid" == "$NOTDEFINED" ] ;then
                    echo "AT_INFO : untagged mode"

                    if [ "$wan_link" == "ADSL" ] ;then
                        echo "AT_INFO : Bonding ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-UNTAGGED  $U_AUTO_CONF_PARAM"

                        #swboard_cmd="ab"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-UNTAGGED  $U_AUTO_CONF_PARAM
                    elif [ "$wan_link" == "VDSL" ] ;then
                        echo "AT_INFO : Bonding VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-UNTAGGED  $U_AUTO_CONF_PARAM"

                        #swboard_cmd="vb"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-UNTAGGED  $U_AUTO_CONF_PARAM
                    fi
                else
                    echo "AT_INFO : tagged mode"

                    if [ "$wan_link" == "ADSL" ] ;then
                        echo "AT_INFO : Bonding ADSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-TAGGED -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        #swboard_cmd="abt"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-ADSL-BONDING-TAGGED -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    elif [ "$wan_link" == "VDSL" ] ;then
                        echo "AT_INFO : Bonding VDSL"
                        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-TAGGED -v TMP_CUSTOM_TAGGED_ID=$taggedid $U_AUTO_CONF_PARAM"

                        #swboard_cmd="vbt"
                        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-VDSL-BONDING-TAGGED -v "TMP_CUSTOM_TAGGED_ID=$taggedid" $U_AUTO_CONF_PARAM
                    fi
                fi

                bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

                if [ $? -ne 0 ] ;then
                    echo "AT_ERROR : DUT un-reachable after broadband setting"
                    exit 1
                fi
            fi
        fi


        echo "sleep 60"
        sleep 60
    fi

    #### GUI check
    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-GUI-CHECK $U_AUTO_CONF_PARA -l $G_CURRENTLOG/GUI-CHECK-BROADBAND-SETTING
}

wan_setting(){
    echo "AT_INFO : In function wan_setting"

    #get_wan_link

    if [ "$U_DUT_TYPE" == "BAR1KH" ] ;then
        get_wan_link

        echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${wan_link}-${protocol} -v \"TMP_CUSTOM_WANINF=$l3inf\" $U_AUTO_CONF_PARAM"
        $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${wan_link}-${protocol} -v "TMP_CUSTOM_WANINF=$l3inf" $U_AUTO_CONF_PARAM
    else
        if [ "$U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE" == "0" ] ;then
            echo "using switch board"



            if [ $bonding -eq 1 ] ;then
                if [ "$taggedid" == "$NOTDEFINED" ] ;then
                    echo "AT_INFO : WAN setting for untagged mode"

                    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-BONDING-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM"
                    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-BONDING-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM
                else
                    echo "AT_INFO : WAN setting for tagged mode"

                    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-BONDING-TAGGED-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM"
                    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-BONDING-TAGGED-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM
                fi
            else
                if [ "$taggedid" == "$NOTDEFINED" ] ;then
                    echo "AT_INFO : WAN setting for untagged mode"

                    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM"
                    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM
                else
                    echo "AT_INFO : WAN setting for tagged mode"

                    echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-TAGGED-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM"
                    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-TAGGED-${protocol}-NO-DETECT $U_AUTO_CONF_PARAM
                fi
            fi


            #echo "going to reboot DUT"

            #set_physical_line reboot



            if [ "x$swboard_cmd" != "x" ] ;then

                restart_WAN_server

                set_physical_line $swboard_cmd

                #sleep 120

            fi

            bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 120

            if [ $? -ne 0 ] ;then
                echo "AT_ERROR : Ping DUT failed after rebooting"
                exit 1
            fi
        else
            echo "no switch board"

            get_wan_link

            echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${linemode}-${protocol} $U_AUTO_CONF_PARAM"
            $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-${wan_link}-${protocol} $U_AUTO_CONF_PARAM
        fi
    fi

    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 300

    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : Ping WAN failed after WAN setting."
        exit 1
    else
        if [ "$U_DUT_TYPE" == "BHR2" ] ;then
            echo "AT_INFO : DUT type is BHR2"
            echo "AT_INFO : Going to disable auto detect feature for BHR2"
            echo "$U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-DISABLE-AUTO-DETECT $U_AUTO_CONF_PARAM"
            $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-DISABLE-AUTO-DETECT $U_AUTO_CONF_PARAM

            if [ $? -ne 0 ] ;then
                echo "AT_ERROR : Disable BHR2 auto detect failed"
                exit 1
            fi
        fi

        if [ "$do_check" == "0" ] ;then
            exit 0
        fi
    fi

    #### GUI check
    $U_AUTO_CONF_BIN $U_DUT_TYPE $post_file_loc/B-GEN-ENV.PRE-DUT.WANCONF-GUI-CHECK $U_AUTO_CONF_PARA -l $G_CURRENTLOG/GUI-CHECK-WAN-SETTING
}

main(){
    if [ "$U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE" == "1" ] ;then
        echo 'AT_INFO : You set $U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE to 1'
        echo "AT_INFO : Skipped set_physical_line"
    else
        set_physical_line down

        set_physical_line reboot

        bash $U_PATH_TBIN/verifyDutLanConnected.sh -t 240

        if [ $? -ne 0 ] ;then
            echo "AT_ERROR : Ping DUT failed after power off & on."
            exit 1
        fi
    fi

    if [ "$do_wan_setting" == "1" ] ;then
        dsl_bonding_setting
        broadband_setting
        wan_setting
    fi

    if [ "$do_check" == "1" ] ;then
        check_wan_link
    fi
}

main
