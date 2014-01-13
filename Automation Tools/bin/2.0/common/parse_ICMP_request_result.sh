#!/bin/bash -w
#---------------------------------
# Name: Prince Wang
# Description:
# This script is used to check the captured packets if contain the expected packet
#
#--------------------------------
# History    :
#   DATE        |   REV  | AUTH   | INFO
#2012-05-02     |   1.0.0   | Prince    | Inital Version

if [ -z $U_PATH_TBIN ] ;then
    echo "source resolve_CONFIG_LOAD.sh"
	source resolve_CONFIG_LOAD.sh
else
    echo "source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh"
	source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi
nega=$flag_icmp_negative

REV="$0 version 1.0.0 (2012-05-02)"
# print REV
echo "${REV}"

out_files=parse_ICMP_result.log

while [ $# -gt 0 ]
do
    case "$1" in
        -n)
            nega=1
            echo "negative mode"
            shift 1
            ;;
        -f)
            raw_cap_file=$2
            echo "Input file : ${raw_cap_file}"
            shift 2
            ;;
        -r)
            expected_packet_read_filter=$2
            echo "read filter : ${expected_packet_read_filter}"
            shift 2
            ;;
        -o)
            out_files=$2
            echo "output file:$out_files"
            shift 2
            ;; 
        -t)
            traffic_type=$2
            echo "traffic_type:$traffic_type"
            shift 2
            ;;
        -test)
            G_CURRENTLOG=.
            U_PATH_TBIN=.
            G_HOST_USR1=root
            G_HOST_PWD1=123qaz
            G_HOST_TIP1_0_0=192.168.100.42
            shift 1
            ;;
        *)
            echo "bash $0 -f <raw_cap_file> -r <read_filter>"
            exit 1
            ;;
    esac
done

if [ -z "${nega}" ] ;then
    nega=0
fi

#if [ "${traffic_type}" == "in" ];then
#    jobs
#    echo "killall -s SIGINT tcpdump"
#    killall -s SIGINT tcpdump
#    echo "sleep 2......"
#    sleep 2
#    echo "killall -9 tshark"
#    killall -9 tshark
#    echo "sleep 2......"
#    sleep 2
#
#elif [ "${traffic_type}" == "out" ];then
#    perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "jobs" -v "killall -s SIGINT tcpdump" -v "sleep 2" -v "killall -9 tshark"  -v "sleep 2"
#
#elif [ "${traffic_type}" == "" ];then
#    echo -e "\nThe var \$trfffic_type not be defined!" && exit 1
#fi


test "${raw_cap_file}" == "" && echo -e "\nThe var \$raw_cap_file not be defined!" && exit 1
test "${expected_packet_read_filter}" == "" && echo -e "\nThe var \$expected_packet_read_filter not be defined!" && exit 1
echo "bash $U_PATH_TBIN/tshark_capture.sh -r ${raw_cap_file} -R $expected_packet_read_filter -V -o $G_CURRENTLOG/$out_files"
bash $U_PATH_TBIN/tshark_capture.sh -r ${raw_cap_file} -R "$expected_packet_read_filter" -V -o $G_CURRENTLOG/$out_files
rc=$?
echo "rc=$rc"
echo "nega=$nega"
if [ "${nega}" -eq "1" ];then
    echo "Negative Test Mode......"
    if [ "$rc" -eq "0" ] ;then
        echo -e "\nNegative Test Fail!"
        exit 1
    else
        echo -e "\nNegative Test Pass!"
        exit 0
    fi
elif [ "${nega}" -eq "0" ];then
    echo "Positive Test Mode......"
    if [ "$rc" -eq "0" ] ;then
        echo -e "\nPositive Test Pass!"
        exit 0
    else
        echo -e "\nPositive Test Fail!"
        exit 1
    fi
else
    echo -e "\nUnknown do positive test or negative test!"
    exit 1
fi

