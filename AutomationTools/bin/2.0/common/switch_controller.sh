#!/bin/bash
#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to call switch_controller
#
#--------------------------------
# History    :
#   DATE        |   REV  | AUTH   | INFO
#05 SEP 2012    |   1.0.0   | howard    | Inital Version

REV="$0 version 1.0.0 (05 SEP 2012 )"
# print REV
echo "${REV}"

while [ $# -gt 0 ]
do
    case "$1" in
    -line)
        line=$2
        echo "change phyx line to ${line}"
        shift 2
        ;;
    -alloff)
        alloff=1
        echo "off all lines"
        shift 1
        ;;
    -power)
        p_status=$2
        echo "change DUT power status to ${p_status}"
        shift 2
        ;;
    -u)
        u_status=$2
        echo "change usb port status to ${u_status}"
        shift 2
        ;;
    -w)
        w_status=$2
        echo "change usb port status to ${w_status}"
        shift 2
        ;;
    -e)
        e_status=$2
        echo "change usb port status to ${e_status}"
        shift 2
        ;;
    -change_line)
        change_line=$2
        echo "change switch board to ${change_line}"
        shift 2
        ;;
    -test)
        echo "test mode"
        export U_PATH_TOOLS=/root/automation/tools/2.0
        export U_PATH_TBIN=/root/automation/bin/2.0/common
        export G_CURRENTLOG=/tmp
        export U_CUSTOM_VLANAS=616
        export U_CUSTOM_VLANAB=620
        export G_HOST_IP1=192.168.100.121
        export G_HOST_USR1=root
        export G_HOST_PWD1=actiontec
        export U_CUSTOM_WECB_IP=192.168.8.35
        export U_CUSTOM_WECB_USR=root
        export U_CUSTOM_WECB_PSW=admin
        export U_CUSTOM_WECB_VER=1.0
        shift 1
        ;;

    *)
        echo "bash $0 -line <line mode>"
        exit 1
        ;;
    esac
done

if [ "$U_CUSTOM_WECB_VER" == "2.0" ];then
    echo "U_CUSTOM_WECB_VER=$U_CUSTOM_WECB_VER"
    append_para="-P 23 -y telnet"
else
    append_para=""
fi
#./switch_controller -h
#./switch_controller version 1.0.1 (28 Jun 2012)
#
#usage function!
#Usage:
#
#       -m/--line-mode:  ADSL or VDSL for WAN connection
#       -B/--Bonding:    1 or 0, 1 means Bonding enable and 0 is disable for WAN connection
#       -e/--Ethernet:   1 or 0, 1 means Ethernet connection ON
#       -l/--line-index: switch index to operate, from 1 to 12, switch 1/2 is for WAN connection
#       -u/--usb1:       1 or 0, set usb1 ON or OFF
#       -w/--usb2:       1 or 0, set usb2 ON or OFF
#       -p/--dut-power:  1 or 0, set dut power ON or OFF
#       -a/--ac-power1:  1 or 0, set AC power1 ON or OFF
#       -b/--ac-power2:  1 or 0, set AC power2 ON or OFF
#       -c/--ac-power3:  1 or 0, set AC power3 ON or OFF
#       -d/--ac-power4:  1 or 0, set AC power4 ON or OFF
#       -D/--delay-time: set a duration,if delay_time > 0,then line1 or line2(specify by line-index) will OFF first, and ON after the duration;
#                           the same action for other switches(specify by line-index)
#       -s/--serial-dev: serial_dev(ex. /dev/ttyS0) responding to switch controller in use
#       -n/--off-all:    off all line
#       -v/--verbose:    verbose

#-v U_CUSTOM_VLANAS          = 616
#-v U_CUSTOM_VLANVS          = 619
#-v U_CUSTOM_VLANAB          = 614
#-v U_CUSTOM_VLANVB          = 620
#-v U_CUSTOM_WECB_IP         = 192.168.100.123
#-v U_CUSTOM_WECB_USR        = root
#-v U_CUSTOM_WECB_PSW        = admin

#-v U_CUSTOM_ALIAS_AST       =
#-v U_CUSTOM_ALIAS_VST       =
#-v U_CUSTOM_ALIAS_ABT       =
#-v U_CUSTOM_ALIAS_VBT       =
#-v U_CUSTOM_VLANAST         =
#-v U_CUSTOM_VLANVST         =
#-v U_CUSTOM_VLANABT         =
#-v U_CUSTOM_VLANVBT         =
#-v U_CUSTOM_NO_WECB         = 1 no wecb , 0 wecb , undefined wecb

#   uw_status

u_status(){

    if [ "$u_status" == "1" ] ;then
        switch_param="-u 1"
    elif [ "$u_status" == "0" ] ;then
        switch_param="-u 0"
    else 
        echo "AT_ERROR : no supported"
        exit 1
    fi

    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "NO WECB using"

        $U_PATH_TOOLS/common/switch_controller $switch_param
    else
        rm -f $G_CURRENTLOG/WECB_SWLINE.log
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
-v "switch_controller $switch_param" ${append_para}

        grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_SWLINE.log

        rc_SWLINE=$?

        if [ $rc_SWLINE -eq 0 ] ;then
            echo "AT_INFO : changing usb1 status passed"
            exit 0
        else
            echo "AT_ERROR : changing usb1 status FAILED"
            exit 1
        fi
     
    fi


    }

e_status(){

    if [ "$e_status" == "1" ] ;then
        switch_param="-e 1"
    elif [ "$e_status" == "0" ] ;then
        switch_param="-e 0"
    else 
        echo "AT_ERROR : no supported"
        exit 1
    fi

    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "NO WECB using"

        $U_PATH_TOOLS/common/switch_controller $switch_param
    else
        rm -f $G_CURRENTLOG/WECB_SWLINE.log
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
-v "switch_controller $switch_param" ${append_para}

        grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_SWLINE.log

        rc_SWLINE=$?

        if [ $rc_SWLINE -eq 0 ] ;then
            echo "AT_INFO : changing eth status passed"
            exit 0
        else
            echo "AT_ERROR : changing eth status FAILED"
            exit 1
        fi
     
    fi


    }

w_status(){

    if [ "$w_status" == "1" ] ;then
        switch_param="-w 1"
    elif [ "$w_status" == "0" ] ;then
        switch_param="-w 0"
    else 
        echo "AT_ERROR : no supported"
        exit 1
    fi

    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "NO WECB using"

        $U_PATH_TOOLS/common/switch_controller $switch_param
    else
        rm -f $G_CURRENTLOG/WECB_SWLINE.log
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
-v "switch_controller $switch_param" ${append_para}

        grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_SWLINE.log

        rc_SWLINE=$?

        if [ $rc_SWLINE -eq 0 ] ;then
            echo "AT_INFO : changing usb2 status passed"
            exit 0
        else
            echo "AT_ERROR : changing usb2 status FAILED"
            exit 1
        fi
     
    fi


    }

DUT_power_down(){

    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "NO WECB using"

        $U_PATH_TOOLS/common/switch_controller -p 0
    else
        rm -f $G_CURRENTLOG/WECB_DUTP0.log
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_DUTP0.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
-v "switch_controller -p 0" ${append_para}

        grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_DUTP0.log

        rc_DUTP0=$?

        if [ $rc_DUTP0 -eq 0 ] ;then
            echo "AT_INFO : DUT power down OK"
        else
            echo "AT_INFO : DUT power down FAILED"
            exit 1
        fi
    fi



    }

DUT_power_up(){
    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "NO WECB using"

        $U_PATH_TOOLS/common/switch_controller -p 1
    else
        rm -f $G_CURRENTLOG/WECB_DUTP1.log
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_DUTP1.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
    -v "switch_controller -p 1" ${append_para}

        grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_DUTP1.log

        rc_DUTP1=$?

        if [ $rc_DUTP1 -eq 0 ] ;then
            echo "AT_INFO : DUT power on OK"
        else
            echo "AT_INFO : DUT power on FAILED"
            exit 1
        fi
    fi


    }

restart_WAN_server(){
    rm -f $G_CURRENTLOG/RESTART_WANSERVER.log
    $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/RESTART_WANSERVER.log -d $G_HOST_IP1 -P 22 -u $G_HOST_USR1 -p $G_HOST_PWD1 \
    -v "cd /root/START_SERVERS/;sed -i \"s/^VLAN_LIST.*/VLAN_LIST $VLAN_ID/g\" config_net.conf;./config_net.sh"

    rc_wan_server=$?

    if [ $rc_wan_server -eq 0 ] ;then
        echo "AT_INFO : restart WAN server OK"
    else
        echo "AT_INFO : restart WAN server FAILED"
        exit 1
    fi

    }

#   offallline

offallline(){

    if [ "x$U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE" == "x" -o "$U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE" == "1" ] ;then
        echo "AT_INFO : no switch board using"
        exit 0
    fi

    switch_param="-n"

    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "NO WECB using"

        $U_PATH_TOOLS/common/switch_controller $switch_param
    else
        rm -f $G_CURRENTLOG/WECB_SWLINE.log
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
-v "switch_controller $switch_param" ${append_para}

        grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_SWLINE.log

        rc_SWLINE=$?

        if [ $rc_SWLINE -eq 0 ] ;then
            echo "AT_INFO : off all lines OK"
            exit 0
        else
            echo "AT_INFO : off all lines FAILED"
            exit 1
        fi
    fi

    }

change_line(){
    if [ "$change_line" == "ab" ] ;then
        switch_param="-m ADSL -B 1"
    elif [ "$change_line" == "vb" ] ;then
        switch_param="-m VDSL -B 1"
    elif [ "$change_line" == "eth" ] ;then
        switch_param="-e 1"
    fi

    if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
        echo "NO WECB using"

        $U_PATH_TOOLS/common/switch_controller $switch_param
    else
        rm -f $G_CURRENTLOG/WECB_SWLINE.log
        $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
    -v "switch_controller $switch_param" ${append_para}

        grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_SWLINE.log

        rc_SWLINE=$?

        if [ $rc_SWLINE -eq 0 ] ;then
            echo "AT_INFO : switch phyx line OK"
            exit 0
        else
            echo "AT_INFO : switch phyx line FAILED"
            exit 1
        fi
    fi

}
switch_line(){

    #   as -- adsl single 1
    #   ab -- adsl bonding
    #   vs -- vdsl single 1
    #   vb -- vdsl bonding

    #   ast -- adsl single tagged 1
    #   abt -- adsl bonded tagged
    #   vst -- vdsl single tagged 1
    #   vbt -- vdsl bonded tagged

    if [ "$line" == "as" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAS
        switch_param="-m ADSL -B 0 -l 1"
    elif [ "$line" == "ab" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAB
        switch_param="-m ADSL -B 1"
    elif [ "$line" == "vs" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVS
        switch_param="-m VDSL -B 0 -l 1"
    elif [ "$line" == "vb" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVB
        switch_param="-m VDSL -B 1"
        ######## TAGGED #######
    elif [ "$line" == "ast" ] ;then
        VLAN_ID=$U_CUSTOM_VLANAST
        switch_param="-m $U_CUSTOM_ALIAS_AST -B 0 -l 1"
    elif [ "$line" == "abt" ] ;then
        VLAN_ID=$U_CUSTOM_VLANABT
        switch_param="-m $U_CUSTOM_ALIAS_ABT -B 1"
    elif [ "$line" == "vst" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVST
        switch_param="-m $U_CUSTOM_ALIAS_VST -B 0 -l 1"
    elif [ "$line" == "vbt" ] ;then
        VLAN_ID=$U_CUSTOM_VLANVBT
        switch_param="-m $U_CUSTOM_ALIAS_VBT -B 1"
    fi

    if [ -z $VLAN_ID ] ;then
        echo "AT_ERROR : must specify a VLAN ID to use"
        exit 1
    else
        # to shut down DUT first
        DUT_power_down

        if [ "$U_CUSTOM_NO_WECB" == "1" ] ;then
            echo "NO WECB using"

            $U_PATH_TOOLS/common/switch_controller $switch_param
        else
            rm -f $G_CURRENTLOG/WECB_SWLINE.log
            $U_PATH_TBIN/clicmd -o $G_CURRENTLOG/WECB_SWLINE.log -d $U_CUSTOM_WECB_IP -P 22 -u $U_CUSTOM_WECB_USR -p $U_CUSTOM_WECB_PSW \
    -v "switch_controller $switch_param" ${append_para}

            grep "last_cmd_return_code:0" $G_CURRENTLOG/WECB_SWLINE.log

            rc_SWLINE=$?

            if [ $rc_SWLINE -eq 0 ] ;then
                echo "AT_INFO : switch phyx line OK"
            else
                echo "AT_INFO : switch phyx line FAILED"
                exit 1
            fi
        fi



        # to restart WAN servers
        restart_WAN_server

        # turn DUT on AGAIN
        DUT_power_up

        sleep 5m

        exit 0

    fi


    }

if [ "x$change_line" != "x" ] ;then
    change_line
fi


if [ "x$line" != "x" ] ;then
    switch_line
fi

if [ "x$alloff" != "x" ] ;then
    offallline
fi


#   uw_status

if [ "x$u_status" != "x" ] ;then
    u_status
fi

if [ "x$w_status" != "x" ] ;then
    w_status
fi

if [ "x$e_status" != "x" ] ;then
    e_status
fi

if [ "$p_status" == "0" ] ;then
    DUT_power_down
fi

if [ "$p_status" == "1" ] ;then
    DUT_power_up
fi



