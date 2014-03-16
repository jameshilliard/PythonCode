#!/bin/bash
#---------------------------------
# Name: Alex
# Description: 
#   This script is used to configure tr069 settings based on Q2KH
#
#--------------------------------
# History       :
#   DATE        |   REV     | AUTH      | INFO
#27 Feb 2012    |   1.0.0   | Alex      | Inital Version
#16 Mar 2012    |   1.0.1   | Alex      | Add the function to check acs connect request url
#20 Mar 2012    |   1.0.2   | Alex      | improved the check point that DUT has registered to Motive Server
############################################################################################

REV="$0 version 1.0.2( 20 Mar 2012 )"
# print REV

echo "${REV}"

while [ -n "$1" ];
do
    case "$1" in
    -test)
        mode=test
        echo "mode : test mode"
        U_PATH_TBIN=./
        U_DUT_FW_VERSION=20.19.8
        post_file_loc=/root/automation/platform/2.0/Q2KH/config/20.19.8/tr069/Precondition/
        G_CURRENTLOG=./
        G_PROD_IP_BR0_0_0=192.168.1.1
        U_DUT_TELNET_USER=admin
        U_DUT_TELNET_PWD=admin1
        U_AUTO_CONF_BIN=playback_http
        U_AUTO_CONF_PARAM="-d 0"
        U_DUT_TYPE=BHR2
        G_HOST_USR1=root
        G_HOST_PWD1=actiontec
        G_HOST_TIP1_0_0=192.168.100.121
        G_HOST_IF1_1_0=eth1
        shift 1
        ;; 
    esac
done

wait_time=15
trytimes=20

function start_capture
{
    echo "Start to capture on WAN PC..."
    echo "perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v \"killall -s SIGINT tcpdump\" -v \"rm -rf /tmp/tr69CONF.cap\" -v \"nohup tcpdump -i $G_HOST_IF1_1_0 -s 0 -w /tmp/tr69CONF.cap > /dev/null 2>&1 &\"  -v \"sleep 3\""
    perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "killall -s SIGINT tcpdump" -v "rm -rf /tmp/tr69CONF.cap" -v "nohup tcpdump -i $G_HOST_IF1_1_0 -s 0 -w /tmp/tr69CONF.cap > /dev/null 2>&1 &"  -v "sleep 3"
    if [ $? -ne 0 ]; then
        echo "AT_ERROR : FAILED to capture on WAN PC!"
        stop_capture_and_exit 1
    fi
}

function stop_capture_and_exit
{
    ret=$1
    echo "Stop capture on WAN PC."
    echo "perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/stop_tshark.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v \"jobs;killall -s SIGINT tcpdump;sleep 3\" -v \"mv -f /tmp/tr69CONF.cap $G_CURRENTLOG/tr69CONF.cap ; sleep 3\""
    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/stop_tshark.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "jobs;killall -s SIGINT tcpdump;sleep 3" -v "mv -f /tmp/tr69CONF.cap $G_CURRENTLOG/tr69CONF.cap ; sleep 3"

    if [ $? -ne 0 ]; then
        echo "AT_ERROR : FAILED to capture on WAN PC!"
        exit 1
    fi

    exit $ret
}

function post_1st_file
{
    echo "CLI setting : set ACS_URL to http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 10 by post from CLI"
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "conf print cwmp/acs_url" -v "conf set cwmp/acs_url http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt" -v "conf set cwmp/periodic_inform/interval 10" -v "conf reconf 1"
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to execute DUTCmd.pl"
        stop_capture_and_exit 1
    fi
    echo "DUT reboot..."
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "system reboot"
}

function check_authorization
{
    echo "Check that ACS_URL has been set to https://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt by Motive"
    get_cwmp_enable=1
    try=0
    while [ $get_cwmp_enable -eq 1 ]
    do
        bash $U_PATH_TBIN/verifyDutLanConnected.sh
        if [ $? -eq 0 ]; then        
            if [ "$mode" = "test" ]; then    
                bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log -test        
            else            
                bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log        
            fi        
            if [ $? -ne 0 ]; then            
                echo "AT_ERROR : FAILED to execute bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log"            
                stop_capture_and_exit 1        
            fi
        else
            echo "Warning : FAILED to ping to DUT!"
        fi
        let "try=$try+1"
    
        ACS_URL=`grep "TMP_DUT_CWMP_ACS_URL=" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
        ACS_URL_USED=`grep "TMP_DUT_CWMP_ACS_URL_USED=" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
        REQ_URL=`grep "TMP_DUT_CWMP_CONN_REQ_URL" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
        echo "ACS_URL=$ACS_URL"
        echo "ACS_URL_USED=$ACS_URL_USED"
        head_url=`echo $ACS_URL | grep -o "https"`
        head_url_used=`echo $ACS_URL_USED | grep -o "https"`
        if [ "$head_url" = "https" -a "$head_url_used" = "https" -a "$head_url" = "$head_url_used" ]; then
#            sleep 60
            echo "ACS_URL and ACS_URL_USED has been changed by Motice"
            get_cwmp_enable=0
        else
            if [ $try -ge $trytimes ]; then
                echo "AT_ERROR : TR069 auto registration failed,exit!"
                stop_capture_and_exit 1
            else
                echo "Waitting for TR069 auto registration..."
                sleep $wait_time
            fi
        fi
    done
}

function post_2nd_file
{
    if [ "$U_CUSTOM_CWMP_FORCE_PERIODIC_INFORM" == "0" -a "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" == "$G_HOST_IP1" ] ;then
        echo "CLI setting : set ACS_URL to http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 86400 from CLI"
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "conf print cwmp/acs_url" -v "conf set cwmp/acs_url http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt" -v "conf set cwmp/periodic_inform/interval 86400" -v "conf reconf 1"
    else
        echo "CLI setting : set ACS_URL to http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 60 from CLI"
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "conf print cwmp/acs_url" -v "conf set cwmp/acs_url http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt" -v "conf set cwmp/periodic_inform/interval 60" -v "conf reconf 1"
    fi
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to execute DUTCmd.pl"
        stop_capture_and_exit 1
    fi
#    echo "DUT reboot..."
#    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "system reboot"
    
    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240
    
    setting_result=$?
    
    if [ $setting_result -gt 0 ] ;then
        echo "AT_ERROR : ping WAN failed after WAN setting."
        stop_capture_and_exit 1
    fi
}

function check_req_url
{
    echo "checking connection request url:"
    get_cwmp_enable=1
    try=0
    while [ $get_cwmp_enable -eq 1 ]
    do
        bash $U_PATH_TBIN/verifyDutLanConnected.sh
        if [ $? -eq 0 ]; then
            if [ "$mode" = "test" ]; then                
                bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/TR_cwmpInfo.log -test
            else            
                bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/TR_cwmpInfo.log
            fi        
            if [ $? -ne 0 ]; then            
                echo "AT_ERROR : FAILED to execute bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/TR_cwmpInfo.log"         
                stop_capture_and_exit 1
            fi
        else
            echo "Warning : FAILED to ping to DUT!"
        fi
        let "try=$try+1"
    
        ACS_REQ_URL=`grep "TMP_DUT_CWMP_CONN_REQ_URL" $G_CURRENTLOG/TR_cwmpInfo.log | awk -F= '{print $2}'`
        echo "CONN_REQ_URL before reboot = $REQ_URL"
        echo "CONN_REQ_URL after reboot = $ACS_REQ_URL"
        if [ "$ACS_REQ_URL" != "$REQ_URL" ]; then
            echo "REQ_URL has been changed"
            get_cwmp_enable=0
        else
            if [ $try -ge $trytimes ]; then
                echo "AT_ERROR : TR069 auto registration failed,exit!"
                stop_capture_and_exit 1
            else
                echo "Waitting for changement of connection request url"
                sleep $wait_time
            fi
        fi
    done
}

function post_1st_file_4
{
    echo "CLI setting : set ACS_URL to http://iiothdmw13.iot.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 10 by post from CLI"
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "conf print cwmp/acs_url" -v "conf set cwmp/acs_url http://iiothdmw13.iot.motive.com/cwmpWeb/CPEMgt" -v "conf set cwmp/periodic_inform/interval 10" -v "conf reconf 1"
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to execute DUTCmd.pl"
        stop_capture_and_exit 1
    fi
    echo "DUT reboot..."
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "system reboot"
}

function post_1st_file_5
{
	#	conf set cwmp/acs_url http://192.168.55.254:1234/acs
	#	conf set cwmp/conn_req_username actiontec
	#	conf set_obscure cwmp/conn_req_password actiontec

	#	conf set cwmp/periodic_inform/interval 10
    echo "CLI setting : set ACS_URL to http://192.168.55.254:1234/acs and change ACS_PeriodicInformInterval to 10 by post from CLI"
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "conf print cwmp/acs_url" -v "conf set cwmp/acs_url http://192.168.55.254:1234/acs" -v "conf set cwmp/periodic_inform/interval 10" -v "conf set cwmp/conn_req_username actiontec" -v "conf set_obscure cwmp/conn_req_password actiontec" -v "conf reconf 1"
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to execute DUTCmd.pl"
        stop_capture_and_exit 1
    fi
    echo "DUT reboot..."
    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "system reboot"
}

function check_authorization_5
{
    echo "just do ping LAN"
    
    #try=0
    #while [ $get_cwmp_enable -eq 1 ]
    #do
	bash $U_PATH_TBIN/verifyDutLanConnected.sh
        
    #done

}

function post_2nd_file_5
{
    echo "just do ping WAN"
    
    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240
    
    setting_result=$?
    
    if [ $setting_result -gt 0 ] ;then
        echo "AT_ERROR : ping WAN failed after WAN setting."
        stop_capture_and_exit 1
    fi
    
}

function check_authorization_4
{
     echo "Check that ACS_URL has been set to http://iiothdm13.iot.motive.com/cwmpWeb/CPEMgt by Motive"
    get_cwmp_enable=1
    try=0
    while [ $get_cwmp_enable -eq 1 ]
    do
        bash $U_PATH_TBIN/verifyDutLanConnected.sh
        if [ $? -eq 0 ]; then        
            if [ "$mode" = "test" ]; then    
                bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log -test        
            else            
                bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log        
            fi        
            if [ $? -ne 0 ]; then            
                echo "AT_ERROR : FAILED to execute bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log"            
                stop_capture_and_exit 1        
            fi
        else
            echo "Warning : FAILED to ping to DUT!"
        fi
        let "try=$try+1"
    
        ACS_URL=`grep "TMP_DUT_CWMP_ACS_URL=" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
        ACS_URL_USED=`grep "TMP_DUT_CWMP_ACS_URL_USED=" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
        REQ_URL=`grep "TMP_DUT_CWMP_CONN_REQ_URL" $G_CURRENTLOG/cwmpInfo.log | awk -F= '{print $2}'`
        echo "ACS_URL=$ACS_URL"
        echo "ACS_URL_USED=$ACS_URL_USED"
        head_url=`echo $ACS_URL | grep -o "iiothdm13"`
        head_url_used=`echo $ACS_URL_USED | grep -o "iiothdm13"`
        if [ "$head_url" = "iiothdm13" -a "$head_url_used" = "iiothdm13" -a "$head_url" = "$head_url_used" ]; then
#            sleep 60
            echo "ACS_URL and ACS_URL_USED has been changed by Motice"
            get_cwmp_enable=0
        else
            if [ $try -ge $trytimes ]; then
                echo "AT_ERROR : TR069 auto registration failed,exit!"
                stop_capture_and_exit 1
            else
                echo "Waitting for TR069 auto registration..."
                sleep $wait_time
            fi
        fi
    done

}

function post_2nd_file_4
{
    if [ "$U_CUSTOM_CWMP_FORCE_PERIODIC_INFORM" == "0" -a "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" == "$G_HOST_IP1" ] ;then
        echo "CLI setting : set ACS_URL to http://iiothdm13.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 86400 from CLI"
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "conf print cwmp/acs_url" -v "conf set cwmp/acs_url http://iiothdm13.iot.motive.com/cwmpWeb/CPEMgt" -v "conf set cwmp/periodic_inform/interval 86400" -v "conf reconf 1"
    else
        echo "CLI setting : set ACS_URL to http://iiothdm13.xdev.motive.com/cwmpWeb/CPEMgt and change ACS_PeriodicInformInterval to 60 from CLI"
        perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "conf print cwmp/acs_url" -v "conf set cwmp/acs_url http://iiothdm13.iot.motive.com/cwmpWeb/CPEMgt" -v "conf set cwmp/periodic_inform/interval 60" -v "conf reconf 1"
    fi
    if [ $? -ne 0 ] ;then
        echo "AT_ERROR : FAILED to execute DUTCmd.pl"
        stop_capture_and_exit 1
    fi
#    echo "DUT reboot..."
#    perl $U_PATH_TBIN/DUTCmd.pl -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -l $G_CURRENTLOG -v "system reboot"
    
    bash $U_PATH_TBIN/verifyDutWanConnected.sh -t 240
    
    setting_result=$?
    
    if [ $setting_result -gt 0 ] ;then
        echo "AT_ERROR : ping WAN failed after WAN setting."
        stop_capture_and_exit 1
    fi
    
}

#main:
start_capture

if [ "$U_CUSTOM_MOTIVE_CLIENT_VER" == "3.0" ] ;then
    post_1st_file

    check_authorization

    post_2nd_file
elif [ "$U_CUSTOM_MOTIVE_CLIENT_VER" == "4.0" ] ;then
    post_1st_file_4

    check_authorization_4

    post_2nd_file_4
elif [ "$U_CUSTOM_MOTIVE_CLIENT_VER" == "5.0" ] ;then
    post_1st_file_5

    check_authorization_5

    post_2nd_file_5
else
    echo "AT_ERROR : Invaild motive client version : <$U_CUSTOM_MOTIVE_CLIENT_VER>"
    exit 1
fi

stop_capture_and_exit 0
