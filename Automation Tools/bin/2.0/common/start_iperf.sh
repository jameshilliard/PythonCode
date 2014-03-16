#!/bin/bash
#---------------------------------
# Name: Andy liu
# Description:
# This script is used to create iperf log
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH      | INFO
#03 May 2012    |   1.0.0   | Andy      | Inital Version

REV="$0 version 1.0.0 (03 May 2012)"
echo "${REV}"

usage="$0 [-test] -remote/[-local] [-u] -d <target> -p <port> -i <Index> -o <output>"

if [ -z $U_PATH_TBIN ] ;then
    source resolve_CONFIG_LOAD.sh
else
    source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi

echo "$traffic_type" | grep -i "in"
if [ $? -eq 0 ] ;then
    server_side="localside"
fi

echo "$traffic_type" | grep -i "out"
if [ $? -eq 0 ] ;then
    server_side="remoteside"
fi

server_side=${server_side:-"localside"}

# the max packet length used in iperf 
udp_pkt_len=1400

proto="tcp"

index=1

timeout_s=10
timeout=60
client_interval=10
TRAFFIC_BYTES="1K"

localside(){
    echo "iperf server is local"

    echo "killall -s SIGINT iperf"
    killall -s SIGINT iperf

    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/iperf_ssh.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "killall -s SIGINT iperf"

    tcp(){
#start server
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`

            echo "iperf -s -p $current_port > ${output}/${current_port}.log 2>&1 &"
            
            echo "-----> try to stop service who is using port to listen"
            cmd="netstat -lnpt  | grep \":$current_port \" | awk  '{print \$NF}' | awk -F'/' '{print \$NF}' | xargs -i service {}  stop"
            echo "$cmd" | bash

            iperf -s -p $current_port > ${output}/${current_port}.log 2>&1 &
        done

#start client
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`

            perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "nohup iperf -c $target -p $current_port -n $TRAFFIC_BYTES > /dev/null 2>&1 &"
        done
    }

    udp(){
#start server
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`

            echo "iperf -s -p $current_port -u > ${output}/${current_port}.log 2>&1 &"
            
            echo "-----> try to stop service who is using port to listen"
            cmd="netstat -lnpu  | grep \":$current_port \"| awk  '{print \$NF}' | awk -F'/' '{print \$NF}' | xargs -i service {}  stop"
            echo "$cmd" | bash

            iperf -s -p $current_port -u > ${output}/${current_port}.log 2>&1 &
        done

#start client
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`

            perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "nohup iperf -c $target -p $current_port -l $udp_pkt_len -u -n $TRAFFIC_BYTES > /dev/null 2>&1 &"
        done
    }

    $proto

    echo "sleep $timeout"
    sleep $timeout

    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/iperf_ssh.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "killall -s SIGINT iperf"

    echo "killall -s SIGINT iperf"
    killall -s SIGINT iperf
}

remoteside(){
    echo "iperf server is remote"

    echo "killall -s SIGINT iperf"
    killall -s SIGINT iperf

    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/iperf_ssh.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "killall -s SIGINT iperf"

    tcp(){
#start server
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`

            cmd="netstat -lnpt  | grep \":$current_port \" | awk  '{print \$NF}' | awk -F'/' '{print \$NF}' | xargs -i service {}  stop"
            perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "$cmd" -v "nohup iperf -s -p $current_port > ${output}/${current_port}.log 2>&1 &"
        done
    
        echo "sleep $timeout_s"
        sleep $timeout_s

#start client
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`

            echo "iperf -c $target -p $current_port -n $TRAFFIC_BYTES > /dev/null 2>&1 &"
            iperf -c $target -p $current_port -n $TRAFFIC_BYTES > /dev/null 2>&1 &
            sleep $client_interval
        done
    }

    udp(){
#start server
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`
            
            cmd="netstat -lnpu  | grep \":$current_port \" | awk  '{print \$NF}' | awk -F'/' '{print \$NF}' | xargs -i service {}  stop"
            perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "$cmd" -v "nohup iperf -s -p $current_port -u > ${output}/${current_port}.log 2>&1 &"
        done

        echo "sleep $timeout_s"
        sleep $timeout_s
    
#start client
        for ((i=0;i<`eval echo '$'{#$arrayName[@]}`;i++));
        do
            current_port=`eval echo '$'{$arrayName[i]}`

            echo "iperf -c $target -p $current_port -u -n $TRAFFIC_BYTES > /dev/null 2>&1 &"
            iperf -c $target -p $current_port -l $udp_pkt_len -u -n $TRAFFIC_BYTES > /dev/null 2>&1 &
            sleep $client_interval
        done
    }

    $proto

    echo "sleep $timeout"
    sleep $timeout

    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/iperf_ssh.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "killall -s SIGINT iperf"

    echo "killall -s SIGINT iperf"
    killall -s SIGINT iperf
}

while [ -n "$1" ];
do
    case "$1" in
        -test)
            echo "Mode : Test mode"
            U_PATH_TBIN=/root/automation/bin/2.0/FT/
            G_HOST_USR1=root
            G_HOST_PWD1=actiontec
            G_CURRENTLOG=/tmp/iperf
            G_HOST_TIP1_0_0=192.168.100.40
            G_HOST_TIP0_1_0=192.168.0.100
            TMP_DUT_DEF_GW=192.168.55.254
            iperf_port1=(5000 6000)
            shift 1
            ;;

        -remote)
            echo "Mode : Remote mode"
            server_side="remoteside"
            shift 1
            ;;

        -local)
            echo "Mode : Local mode"
            server_side="localside"
            shift 1
            ;;

        -u)
            echo "Proto : UDP"
            proto="udp"
            shift 1
            ;;

        -d)
            echo "target : $2"
            target=$2
            shift 2
            ;;

        -p)
            echo "Port : $2"
            port=$2
            shift 2
            ;;

        -o)
            echo "Output : $2"
            output=$2
            shift 2
            ;;

        -i)
            echo "Index : $2"
            index=$2
            shift 2
            ;;

        *)
            echo $usage
            exit 1
            ;;
    esac
done

if [ -z "$output" ] ;then
    output=$G_CURRENTLOG/"iperf_"$index
else
    output=${output}"_"$index
fi

mkdir $output

echo "Output : $output"

arrayName="iperf_port"$index

if [ "$server_side" == "localside" ] ;then
    if [ -z "$target" ] ;then
        target=$G_HOST_TIP0_1_0
    fi
elif [ "$server_side" == "remoteside" ] ;then
    if [ -z "$target" ] ;then
        target=$TMP_DUT_DEF_GW
    fi
else
    echo "AT_ERROR : undefine server side!"
    exit 1
fi

$server_side
exit 0
