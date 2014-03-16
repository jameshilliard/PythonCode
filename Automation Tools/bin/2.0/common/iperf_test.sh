#!/bin/bash
######################################################################################
# Usage : iperf_test.sh [-test] -remote/[-local] -target <target ip>                 #
#         -proto <data type> -lport <local port> -rport <remote port>                #
#         -port <local and remote port> -block/[-unblock]                            #
# param : to test the script without testcase, use [-test] before all params.        #
#           [-local] [-unblock] and [-proto tcp] can be omitted                      #
#                                                                                    #
######################################################################################
# Author        :  Howard Yin
# Description   :
#   this script is used to test if the ports can be iperf thru
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   | howard    | Inital Version
#15 May 2013    |   2.0.0   | prince    | add capture packets

REV="$0 version 1.0.0 (31 Oct 2011)"
# print REV

echo "${REV}"
usage="iperf_test.sh [-test] -remote/[-local] -target <target ip> -proto <data type> -lport <local port> -rport <remote port> -port <local and remote port> -block/[-unblock]"

serverSide="localside"

#lanlan=0

block=0

dtype="tcp"

timeout=60

SLEEP_TIME_SEC=10

SLEEP_TIME_SEC_C=30

TRAFFIC_BYTES="1K"

retry_time=4
bidirectional=1
while [ -n "$1" ];
do
    case "$1" in
    -test)
        echo "mode : test mode"
        export U_PATH_TBIN=$SQAROOT/bin/2.0/common
        export U_PATH_SANITYCFG=$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/testcases/sanity/config
        #export G_HOST_IP1=192.168.100.42
        #export G_HOST_USR1=root
        #export G_HOST_PWD1=123qaz
        export G_CURRENTLOG=/root/automation
        export G_HOST_IF0_1_0=eth1
        export G_HOST_IF0_2_0=eth2
        export G_HOST_IF1_2_0=eth2
        export TMP_DUT_DEF_GW=10.100.100.254
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
    -remotehost)
        echo "mode : local mode with remote LAN"
        #serverSide="localside"
        #lanlan=1
        hostinfo=$2
        
        G_HOST_IP1=`echo $hostinfo|awk -F: '{print $1}'`
        G_HOST_USR1=`echo $hostinfo|awk -F: '{print $2}'`
        G_HOST_PWD1=`echo $hostinfo|awk -F: '{print $3}'`
        
        echo "remote host : -${G_HOST_IP1}-"
        echo "remote host username: -${G_HOST_USR1}-"
        echo "remote host password: -${G_HOST_PWD1}-"
        
        shift 2
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
    -bidirectional)
        echo "bi-directional : bi-directional test"
        bidirectional=0
        shift 1
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done

echo "Begin $serverSide iperf test ..."

# the max packet length used in iperf 
udp_pkt_len=1400

echo "  packet len : ${udp_pkt_len}"

checkresult()
{
    return 0
    echo "Entry function checkresult"
    echo "cat $G_CURRENTLOG/iperftest.log"
    cat $G_CURRENTLOG/iperftest.log
    conn_info=`cat $G_CURRENTLOG/iperftest.log  | grep "local"`
    
    if [ "$conn_info" != "" ] ;then
         echo $conn_info
         bandwith_info=`cat $G_CURRENTLOG/iperftest.log  | grep "bits/sec"`
         if [ "$bandwith_info" != "" ] ;then
            echo $bandwith_info
         else
            echo "retry 100 times for waiting iperf result"
            empty_retry=100
         fi

    else
        echo "iperf fail to connnect"
        empty_retry=1
    fi

    for foo in `seq 1 $empty_retry`
    do
        echo "cat iperf log time $foo"
        echo "cat $G_CURRENTLOG/iperftest.log"
        cat $G_CURRENTLOG/iperftest.log
        #bandwith=`cat $G_CURRENTLOG/iperftest.log |  grep "bits/sec" | awk '{print $7}'`
        bandwith_info=`cat $G_CURRENTLOG/iperftest.log  | grep "bits/sec"`

        if [ "$bandwith_info" != "" ] ;then
            bandwith_unit=`echo $bandwith_info |grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $2}'`
            bandwith=`echo $bandwith_info |grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $1}'`
            break
        else
            echo "Check iperf result is not ready yet ! try again"
        fi

        sleep 6
        #bandwith_unit=`cat $G_CURRENTLOG/iperftest.log |  grep "bits/sec" | awk '{print $8}'`
    done
}


parseresult(){
    echo "entering function parseresult ..."

#verify port in use
    grep -q "bind failed: Address already in use" $G_CURRENTLOG/iperftest.log

    if [ $? -eq 0 ] ;then
        stop_capture_packets
        echo "AT_ERROR : the iperf server port is in use"        
        exit 1
    fi
    
#verify port in 1-65535
#    log_port=`grep "Server listening on" $G_CURRENTLOG/iperftest.log | awk '{print $NF}'`
#    if [ "$current_port" != "$log_port" ] ;then
#        echo "AT_ERROR : the port in log is not match the port in test <test port : $current_port> -- <log port : $log_port>" | tee -a $output
#        return 1
#    fi

    empty_retry=5

    for foo in `seq 1 $empty_retry`
    do
        echo "cat $G_CURRENTLOG/iperftest.log"
        cat $G_CURRENTLOG/iperftest.log
        bandwidth=`cat $G_CURRENTLOG/iperftest.log |  grep "bits/sec"`

        if [ "$bandwidth" != "" ] ;then
            bandwith=`echo $bandwidth |grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $1}'`
            break
        else
            echo "iperf result no Bandwidth ! try again"
            sleep 6
        fi
    done
    declare -i band=`echo $bandwith|awk -F . '{print $1}'`
    echo "band : $band"
    if [ $block -eq 1 ]; then
        if [ "$bandwidth" == "" ]; then
            stop_capture_packets
            echo "iperf blocked test ok";            
            exit 0;
        else
            if [ $band -gt 0 ];then
                stop_capture_packets
                echo "iperf blocked test ng";            
                exit 1;
            else
                stop_capture_packets
                echo "iperf blocked test ok";            
                exit 0;
            fi
        fi
    else
        if [ $band -gt 0 ]; then
            stop_capture_packets
            echo "iperf unblocked test ok";
            echo "AT_INFO : iperf unblock test pass by Traffic"
            exit 0;
        else
            echo "AT_WARNING : iperf result no Bandwidth"
        fi
    fi
 
    for foo in `seq 1 $empty_retry`
    do
        #echo "cat iperf log time $foo"
        #bandwith=`cat $G_CURRENTLOG/iperftest.log |  grep "bits/sec" | awk '{print $7}'`
        echo "cat $G_CURRENTLOG/iperftest.log"
        cat $G_CURRENTLOG/iperftest.log
        bandwith_info=`cat $G_CURRENTLOG/iperftest.log  | grep "connected with"`

        if [ "$bandwith_info" != "" ] ;then
         #   bandwith_unit=`echo $bandwith_info |grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $2}'`
         #   bandwith=`echo $bandwith_info |grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $1}'`
            break
        else
            echo "iperf result no \"connected with\" ! try again"
            sleep 5
        fi
        #bandwith_unit=`cat $G_CURRENTLOG/iperftest.log |  grep "bits/sec" | awk '{print $8}'`
    done
    
    #echo "The bandwidth of iperf test is : $bandwith $bandwith_unit"

    #declare -i band=`echo $bandwith|awk -F . '{print $1}'`
    #echo $band
    if [ "$bandwith_info" != "" ]; then

        #echo "the block type is : "$block
        #echo "the bandwith is : "$bandwith

        #if [ $block -eq 0 ]; then
            stop_capture_packets
            echo "iperf unblocked test ok";
            echo "AT_WARNING : iperf unblock test pass by \"connected with\""
            exit 0;
        #else
        #    echo "iperf blocked test ng";
        #    exit 1;
        #fi

    else
        #when bandwith is 0
        #echo "the block type is : "$block
        #echo "the bandwith is : "$bandwith
        #if [ $block -eq 1 ]; then
        #    echo "iperf blocked test ok";
        #    exit 0;
        #else
            #echo "iperf unblocked test ng";
            echo "AT_WARNING : iperf result no \"connected with\""
            
        #fi
    fi
    stop_capture_packets
    sleep 5
    parse_packets
    if [ $? -eq 0 ];then
        echo "AT_WARNING : iperf unblock test pass by capture packets"
        exit 0
    else
        echo "AT_ERROR : \"${filter_rule}\" packets was NOT captured in ${cap_file}"
        echo "AT_ERROR : iperf unblocked test ng"        
        let retry_time=$retry_time-1
        if [ $retry_time -eq 0 ] ;then
            exit 1
        fi
        echo "Try again......"
        sleep 10
        start_capture_packets
        $serverSide
    fi
}
start_capture_packets(){
    echo "Entry function start_capture_packets"
    echo "serverSide : $serverSide"
    echo "target IP : $target"
    stop_cmd=''
    cap_file=''
    cap_interface=''
    rcode=1
    for i in `seq 1 2`
    do
        curdate=`date +%m%d%H%M%S`
        cap_interface=$G_HOST_IF0_1_0
        
        if [ "$serverSide" == "localside" ];then
            ifconfig
            route -n
            ipaddr=`ifconfig $G_HOST_IF0_1_0|grep -io "inet addr:[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
            if [ -n "$ipaddr" ];then
                echo "$G_HOST_IF0_1_0 has IP!"
                cap_interface=$G_HOST_IF0_1_0
            else
                ipaddr=`ifconfig $G_HOST_IF0_2_0|grep -io "inet addr:[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
                if [ -n "$ipaddr" ];then
                    echo "$G_HOST_IF0_2_0 has IP!"
                    cap_interface=$G_HOST_IF0_2_0
                else
                    ipaddr=`ifconfig $U_WIRELESSINTERFACE|grep -io "inet addr:[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
                    if [ -n "$ipaddr" ];then
                        echo "$U_WIRELESSINTERFACE has IP!"
                        cap_interface=$U_WIRELESSINTERFACE
                    else
                        cap_interface=`route -n|grep "^ *0.0.0.0"|awk '{print $8}'`
                        ipaddr=`ifconfig $cap_interface|grep -io "inet addr:[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/ *$//g'`
                    fi
                fi
            fi
            
            echo "cap_interface : $cap_interface"
            echo "$cap_interface IP : $ipaddr"
            cap_file=local_${cap_interface}_${curdate}.cap
            echo "bash $U_PATH_TBIN/raw_capture.sh -l -i $cap_interface -o $cap_file --begin"
            stop_cmd="bash $U_PATH_TBIN/raw_capture.sh -l -i $cap_interface -o $cap_file --stop"
            bash $U_PATH_TBIN/raw_capture.sh -l -i $cap_interface -o $cap_file --begin
            rcode=$?
        elif [ "$serverSide" == "remoteside" ];then
            cap_interface=$G_HOST_IF1_2_0
            ipaddr=$TMP_DUT_DEF_GW
            echo "cap_interface : $cap_interface"
            echo "$cap_interface IP : $ipaddr"
            cap_file=remote_${cap_interface}_${curdate}.cap
            echo "bash $U_PATH_TBIN/raw_capture.sh -r -i $cap_interface -o $cap_file --begin"
            stop_cmd="bash $U_PATH_TBIN/raw_capture.sh -r -i $cap_interface -o $cap_file --stop"
            bash $U_PATH_TBIN/raw_capture.sh -r -i $cap_interface -o $cap_file --begin
            rcode=$?
        else
            echo "AT_ERROR : Please assign serverside"
        fi
        if [ $rcode -eq 0 ];then
            echo "AT_INFO : Capture on $serverside $cap_interface Success"
            return 0
        else
            echo "AT_WARNING : Capture on $serverside $cap_interface Fail!"
        fi
    done
}
parse_packets(){
    echo "Entry function parse_packets"
    rule=''
    filter_rule=''
    if [ "$dtype" == "tcp" ];then
        rule="tcp.dstport=="
    else
        rule="udp.dstport=="
    fi
    if [ "$serverSide" == "localside" ];then
        filter_rule="${rule}${rport} and ip.dst==${ipaddr}"
        #filter_rule="${rule}${rport}"
        
    else
        filter_rule="${rule}${lport} and ip.dst==${ipaddr}"
    fi
    echo "filter_rule : $filter_rule"
    
    bash $U_PATH_TBIN/tshark_capture.sh -r $G_CURRENTLOG/${cap_file} -R "${filter_rule}" -o $G_CURRENTLOG/${cap_file}.log
    if [ $? -eq 0 ];then
        echo "AT_INFO : iperf server receive trafic from client by capture packets!"
        return 0
    else
        return 1
    fi
}
stop_capture_packets(){
    echo "Entry function stop_capture_packets"
    echo "$stop_cmd"
    $stop_cmd
}

localside(){
    echo "entering function local ..."

    tcp(){
        echo "====================================================================="
        sleep $SLEEP_TIME_SEC
        echo "entering function local -> tcp ..."
        echo "iperf -s -p $lport"

        echo "-----> try to stop service who is using port to listen"
        cmd='netstat -lnpt  | grep :'$lport"| awk  '{print \$NF}' | awk -F'/' '{print \$NF}' | xargs -i service {}  stop"
        echo "$cmd" | bash

        iperf -s -p $lport |tee $G_CURRENTLOG/iperftest.log &

        echo "sleep $SLEEP_TIME_SEC"
        sleep $SLEEP_TIME_SEC

        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "sleep $SLEEP_TIME_SEC" -v "iperf -c $target -p $rport -n $TRAFFIC_BYTES "&

        echo "sleep $SLEEP_TIME_SEC_C for waiting iperf result"
        sleep $SLEEP_TIME_SEC_C
        checkresult

        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/stop_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "sleep $SLEEP_TIME_SEC" -v "bash $U_PATH_TBIN/stop_iperf_client.sh -t $timeout"
    }

    udp(){
        echo "entering function local -> udp ..."
        echo "iperf -s -p $lport -u"

        echo "-----> try to stop service who is using port to listen"
        cmd='netstat -lnpu  | grep :'$lport"| awk  '{print \$NF}' | awk -F'/' '{print \$NF}' | xargs -i service {}  stop"
        echo "$cmd" | bash

        iperf -s -p $lport -u  |tee $G_CURRENTLOG/iperftest.log &

        echo "sleep $SLEEP_TIME_SEC"
        sleep $SLEEP_TIME_SEC

        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "sleep $SLEEP_TIME_SEC" -v "iperf -c $target -l $udp_pkt_len -p $rport -u -n $TRAFFIC_BYTES "&

        echo "sleep $SLEEP_TIME_SEC_C for waiting iperf result"
        sleep $SLEEP_TIME_SEC_C
        checkresult

        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/stop_iperf_c.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "sleep $SLEEP_TIME_SEC" -v "bash $U_PATH_TBIN/stop_iperf_client.sh -t $timeout"
    }

    $dtype

    killall -9 iperf

    parseresult
}

remoteside(){
    echo "entering function remote ..."
# -v "echo 'iperf -s -p $rport > iperftest.log &' > /tmp/iperf_server.sh; chmod 777 /tmp/iperf_server.sh ; /tmp/iperf_server.sh"
    tcp(){
        echo "entering function remote -> tcp ..."
        
        echo "Try nmap the remote port first : TCP $target:$lport"
        cmd="nmap -sT -v -p $lport $target"
        echo "$cmd"
        echo "$cmd" | bash

        cmd="netstat -lnpt  | grep :$rport | awk  '{print \\\$NF}' | awk -F'/' '{print \\\$NF}' | xargs -i service {}  stop"
        #perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "$cmd" -v "echo 'iperf -s -p $rport > $G_CURRENTLOG/iperftest.log &' > /tmp/iperf_server.sh; chmod 777 /tmp/iperf_server.sh ; /tmp/iperf_server.sh"
        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "$cmd" -v "nohup iperf -s -p $rport > $G_CURRENTLOG/iperftest.log  2>&1 &"

        echo "sleep $SLEEP_TIME_SEC"
        sleep $SLEEP_TIME_SEC
        echo "iperf -c $target -p $lport -n $TRAFFIC_BYTES"
        iperf -c $target -p $lport -n $TRAFFIC_BYTES &
    }

    udp(){
        echo "entering function remote -> udp ..."
        
        echo "Try nmap the remote port first : UDP $target:$lport"
        cmd="nmap -sU -v -p $lport $target"
        echo "$cmd"
        echo "$cmd" | bash

        cmd="netstat -lnpu  | grep :$rport | awk  '{print \\\$NF}' | awk -F'/' '{print \\\$NF}' | xargs -i service {}  stop"
        #perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "$cmd" -v "echo 'iperf -s -p $rport -u > $G_CURRENTLOG/iperftest.log &' > /tmp/iperf_server.sh; chmod 777 /tmp/iperf_server.sh ; /tmp/iperf_server.sh"
        perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "$cmd" -v "nohup iperf -s -p $rport -u > $G_CURRENTLOG/iperftest.log  2>&1 & "
        echo "sleep $SLEEP_TIME_SEC"
        sleep $SLEEP_TIME_SEC
        echo "iperf -c $target -p $lport -u -n $TRAFFIC_BYTES"
        iperf -c $target -l $udp_pkt_len -p $lport -u -n $TRAFFIC_BYTES &
    }

    $dtype

    echo "sleep $SLEEP_TIME_SEC_C for waiting iperf result"
    sleep $SLEEP_TIME_SEC_C
    checkresult
    
    bash $U_PATH_TBIN/stop_iperf_client.sh -t $timeout
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/stop_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "killall iperf"

    #killall iperf

    parseresult
}

biDirectional(){
    echo "entering function biDirectional ..."
        
    #echo "Try nmap the remote port first : TCP $target:$lport"
    #cmd="nmap -sT -v -p $lport $target"
    #echo "$cmd"
    #echo "$cmd" | bash

    #cmd="netstat -lnpt  | grep :$rport | awk  '{print \\\$NF}' | awk -F'/' '{print \\\$NF}' | xargs -i service {}  stop"
    #perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "$cmd" -v "echo 'iperf -s -p $rport > $G_CURRENTLOG/iperftest.log &' > /tmp/iperf_server.sh; chmod 777 /tmp/iperf_server.sh ; /tmp/iperf_server.sh"
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/start_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "nohup iperf -s> $G_CURRENTLOG/iperftest.log  2>&1 &"

    echo "sleep $SLEEP_TIME_SEC"
    sleep $SLEEP_TIME_SEC
    echo "iperf -c $TMP_DUT_DEF_GW -d"
    iperf -c $TMP_DUT_DEF_GW -d &
    echo "sleep $SLEEP_TIME_SEC_C for waiting iperf result"
    sleep $SLEEP_TIME_SEC_C
    checkresult
    
    bash $U_PATH_TBIN/stop_iperf_client.sh -t $timeout
    perl $U_PATH_TBIN/sshcli.pl -l $G_CURRENTLOG -o $G_CURRENTLOG/stop_iperf_s.log -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "killall iperf"

    #killall iperf

    parseresult

}
if [ "$bidirectional" == "0" ];then
    biDirectional
fi
if [ "$dtype" == "TCP" -o "$dtype" == "tcp" ] ;then
    dtype=tcp
elif [ "$dtype" == "UDP" -o "$dtype" == "udp" ] ;then
    dtype=udp
else
    echo "--| ERROR : data type incorrect !"
    exit 1
fi

route -n
start_capture_packets
$serverSide
ps aux |grep iperf
echo "=============================================================="
