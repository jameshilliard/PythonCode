#!/bin/bash
######################################################################################
# Author : Howard Yin                                                                #
# Date : 8-01-2011                                                                   #   
# Description : this script is used to test if the ports can be iperf thru           #
# Usage : iperf_test.sh [-test] -remote/[-local] -target <target ip>                 #
#         -proto <data type> -lport <local port> -rport <remote port>                #
#         -port <local and remote port> -block/[-unblock]                            #
# param : to test the script without testcase, use [-test] before all params.        #
#           [-local] [-unblock] and [-proto tcp] can be omitted                      #
#                                                                                    #
######################################################################################
usage="iperf_test.sh [-test] -remote/[-local] -target <target ip> -proto <data type> -lport <local port> -rport <remote port> -port <local and remote port> -block/[-unblock]"

serverSide="localside"

block=0

dtype="tcp"

timeout=30

while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        U_PATH_TBIN=/root/automation/bin/1.0/Q2K/
        U_PATH_SANITYCFG=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/testcases/sanity/config
        G_HOST_IP1=192.168.100.40 
        G_HOST_USR1=root 
        G_HOST_PWD1=actiontec 
        G_CURRENTLOG=/root/automation/logs/current
        shift 1
        ;;
    -remote)
        echo "mode : remote mode"
        serverSide="remoteside"
        shift 1
        ;;
    -local)
        echo "mode : local mode"
        serverSide="localside"
        shift 1
        ;;
    -target)
        echo "target ip : $2"
        target=$2
        shift 2
        ;;
    -proto)
        echo "data type : $2"
        dtype=$2
        shift 2
        ;;
    -port)
        echo "local port and remote both are : $2"
        lport=$2
        rport=$lport
        shift 2
        ;;
    -lport)
        echo "local port : $2"
        lport=$2
        shift 2
        ;;
    -rport)
        echo "remote port : $2"
        rport=$2
        shift 2
        ;;
    -block)
        echo "mode : block mode"
        block=1
        shift 1
        ;;
    -unblock)
        echo "mode : unblock mode"
        block=0
        shift 1
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done

echo "Begin $serverSide iperf test ..."

parseresult(){
    echo "entering function parseresult ..."

    bandwith=`cat $G_CURRENTLOG/iperftest.log |  grep "bits/sec" | awk '{print $7}'`

    bandwith_unit=`cat $G_CURRENTLOG/iperftest.log |  grep "bits/sec" | awk '{print $8}'`

    echo "The bandwidth of iperf test is : $bandwith $bandwith_unit" 

    declare -i band=`echo $bandwith|awk -F . '{print $1}'`
    #echo $band
    if [ $band -gt 0 ]; then

        #echo "the block type is : "$block
        #echo "the bandwith is : "$bandwith

        if [ $block -eq 0 ]; then
            echo "iperf unblocked test ok";
            exit 0;
        else
            echo "iperf blocked test ng";
            exit 1;
        fi

    else
        #when bandwith is 0
        echo "the block type is : "$block
        echo "the bandwith is : "$bandwith
        if [ $block -eq 1 ]; then
            echo "iperf blocked test ok";
            exit 0;
        else
            echo "iperf unblocked test ng";
            exit 1;
        fi

    fi
exit 0
}

localside(){
    echo "entering function local ..."

    tcp(){
        echo "entering function local -> tcp ..."
		echo "iperf -s -p $lport |tee $G_CURRENTLOG/iperftest.log &"
        iperf -s -p $lport |tee $G_CURRENTLOG/iperftest.log &
        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "iperf -c $target -p $rport"&
        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/stop_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "bash $U_PATH_TBIN/stop_iperf_client.sh -t $timeout"
    }

    udp(){
        echo "entering function local -> udp ..."

        iperf -s -p $lport -u  |tee $G_CURRENTLOG/iperftest.log &
        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "iperf -c $target -p $rport -u"&
        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/stop_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "bash $U_PATH_TBIN/stop_iperf_client.sh -t $timeout"
    }

    dtype=`echo "$dtype" | tr "[:upper:]" "[:lower:]"`
	$dtype

    killall iperf

    parseresult
}

remoteside(){
    echo "entering function remote ..."
# -v "echo 'iperf -s -p $rport > iperftest.log &' > /tmp/iperf_server.sh; chmod 777 /tmp/iperf_server.sh ; /tmp/iperf_server.sh"

    tcp(){
        echo "entering function remote -> tcp ..."

        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "echo 'iperf -s -p $rport > $G_CURRENTLOG/iperftest.log &' > /tmp/iperf_server.sh; chmod 777 /tmp/iperf_server.sh ; /tmp/iperf_server.sh"
        iperf -c $target -p $lport &
    }

    udp(){
        echo "entering function remote -> udp ..."

        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "echo 'iperf -s -p $rport -u > $G_CURRENTLOG/iperftest.log &' > /tmp/iperf_server.sh; chmod 777 /tmp/iperf_server.sh ; /tmp/iperf_server.sh"
        iperf -c $target -p $lport -u &
    }

    dtype=`echo "$dtype" | tr "[:upper:]" "[:lower:]"`
    $dtype
    
    bash $U_PATH_TBIN/stop_iperf_client.sh -t $timeout
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/stop_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "killall iperf"
    
    #killall iperf

    parseresult
}



$serverSide
