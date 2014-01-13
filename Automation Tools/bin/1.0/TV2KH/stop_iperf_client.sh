#!/bin/bash
#this little script is used to kill iperf client after a determined time
#if there is a iperf client running ,it will will until the deadline or till the iperf
#client stops,when times up,it will kill all iperf client 
usage="stop_iperf_client.sh -t <time remain>"
while [ -n "$1" ];
do
    case "$1" in

    -t)
        timetolive=$2
        echo "time for iperf clients to live : ${timetolive}"
        shift 2
        ;;
        
    *)
        echo $usage
        exit 1
        ;;
    esac
done
countdown(){
    timetolive=$1
    flag=0 
    for i in `seq 1 $timetolive`
    do
        flag=0
        temp=`ps aux|grep 'iperf -c'|grep -v 'grep'|awk '{print $2}'`
        for foo in $temp
        do
            let "flag=$flag+$foo"
        done
        #echo "flag is :"$flag
        if [ $flag -eq 0 ]; then
            echo "no iperf client running.."
            break 2
        else
            let "i=$timetolive-$i"
            echo -e -n "\riperf clients have "$i" seconds to live..."
            sleep 1
        fi
    done
}

killiperf(){
    for i in `ps aux|grep 'iperf -c'|grep -v 'grep'|awk '{print $2}'`
    do
        kill -9 $i
    done
}
ps aux |grep 'iperf -c'|grep -v 'grep'
countdown $timetolive
killiperf
echo -e "\ncheck if there's any iperf process remained below :"
ps aux |grep 'iperf -c'|grep -v 'grep'
