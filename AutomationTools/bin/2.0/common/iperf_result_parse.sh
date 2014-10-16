#!/bin/bash
#---------------------------------
# Name: Andy liu
# Description:
# This script is used to parse the result of iperf
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH      | INFO
#04 May 2012    |   1.0.0   | Andy      | Inital Version
#11 May 2012    |   1.0.1   | Andy      | solve exception log

REV="$0 version 1.0.1 (11 May 2012)"
echo "${REV}"

usage="$0 [-test] -i <index> -o <output> -d <input>"

if [ -z $U_PATH_TBIN ] ;then
	source resolve_CONFIG_LOAD.sh
else
	source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
fi

echo "$traffic_type" | grep -i "in"
if [ $? -eq 0 ] ;then
    server_side="local"
    target=$G_HOST_TIP0_1_0
fi

echo "$traffic_type" | grep -i "out"
if [ $? -eq 0 ] ;then
    server_side="remote"
    target=$TMP_DUT_DEF_GW
fi
echo "server_side : $server_side"
echo "target : $target"
retry_time=1
retry_interval=30
retry_pass=0
unblock_fail_array=()

index=1

result=0

while [ -n "$1" ];
do
    case "$1" in
        -test)
            echo "Mode : Test mode"
            G_CURRENTLOG=/tmp/iperf
            unblocked_ports2=(5000 6000)
            blocked_ports1=(5000 6000)
            shift 1
            ;;

        -i)
            echo "Index : $2"
            index=$2
            shift 2
            ;;

        -d)
            echo "Input : $2"
            input=$2
            shift 2
            ;;

        -o)
            echo "Output : $2"
            output=$2
            shift 2
            ;;

        *)
            echo $usage
            exit 1
            ;;
    esac
done

if [ -z "$input" ] ;then
    input=$G_CURRENTLOG/"iperf_"$index
else
    input=${input}"_"$index
fi

if [ -z "$output" ] ;then
    output=$G_CURRENTLOG/"iperf_result_"$index
else
    output=$output$index
fi

unblocked_array="unblocked_ports"$index
blocked_array="blocked_ports"$index

#makesure the log is valid
check_log(){
#verify port in use
    grep -q "bind failed: Address already in use" ${input}/${current_port}.log

    if [ $? -eq 0 ] ;then
        echo "AT_ERROR : the iperf server port is in use" | tee -a $output
        return 1
    fi

#verify port in 1-65535
    log_port=`grep "Server listening on" ${input}/${current_port}.log | awk '{print $NF}'`
    if [ "$current_port" != "$log_port" ] ;then
        echo "AT_ERROR : the port in log is not match the port in test <test port : $current_port> -- <log port : $log_port>" | tee -a $output
        return 1
    fi
    return 0
}


#unblock parse result
for ((i=0;i<`eval echo '$'{#$unblocked_array[@]}`;i++));
do
    current_port=`eval echo '$'{$unblocked_array[i]}`

    echo "Unblocked port : $current_port" | tee -a $output

    if [ -f "${input}/${current_port}.log" ] ;then

        check_log

        if [ $? -eq 0 ] ;then

            date
            echo "=======iperf log=========="
            cat ${input}/${current_port}.log
            echo "=========================="

            bandwith_info=`grep "bits/sec" ${input}/${current_port}.log`

            if [ $? -eq 0 ] ;then

                bandwith=`     echo $bandwith_info | grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $1}'`
                bandwith_unit=`echo $bandwith_info | grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $2}'`

                echo "The bandwidth of iperf test is : $bandwith $bandwith_unit" | tee -a $output

                declare -i band=`echo $bandwith | awk -F . '{print $1}'`

                if [ "$band" -gt 0 ] ;then
                    echo "iperf unblocked test Passed!" | tee -a $output
                else
                    echo "AT_ERROR : iperf unblocked test Failed! bandwidth : <$bandwith> <$bandwith_unit>" | tee -a $output
                    let "result=$result+1"
                fi
            else
                echo "AT_ERROR : Can not get bandwidth information from iperf log <${input}/${current_port}.log>" | tee -a $output
                let "result=$result+1"
                len=${#unblock_fail_array[@]}
                unblock_fail_array[${len}]="${current_port}"
                echo "Fail port : ${unblock_fail_array[*]}"
            fi
        else
            let "result=$result+1"
        fi
    else
        echo "AT_ERROR : No such file <${input}/${current_port}.log>" | tee -a $output
        let "result=$result+1"
        len=${#unblock_fail_array[@]}
        unblock_fail_array[${len}]="${current_port}"
        echo "Fail port : ${unblock_fail_array[*]}"
    fi
    echo "--------------------------------" | tee -a $output
done

#block parse result
for ((i=0;i<`eval echo '$'{#$blocked_array[@]}`;i++));
do
    current_port=`eval echo '$'{$blocked_array[i]}`

    echo "Blocked port : $current_port" | tee -a $output

    if [ -f "${input}/${current_port}.log" ] ;then

#make sure the input files is iperf log
        grep "Server listening on [UDPTC]* port $current_port" ${input}/${current_port}.log

        if [ $? -eq 0 ] ;then

            check_log

            if [ $? -eq 0 ] ;then

                bandwith_info=`grep "bits/sec" ${input}/${current_port}.log`

                if [ "$bandwith_info" ] ;then

                    bandwith=`     echo $bandwith_info | grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $1}'`
                    bandwith_unit=`echo $bandwith_info | grep -o "[0-9.]\{1,\} *[a-zA-Z]\{0,\}bits/sec" | awk '{print $2}'`

                    echo "The bandwidth of iperf test is : $bandwith $bandwith_unit" | tee -a $output

                    declare -i band=`echo $bandwith | awk -F . '{print $1}'`

                    if [ "$band" -gt 0 ] ;then
                        echo "iperf blocked test Failed! bandwidth : <$bandwith> <$bandwith_unit>" | tee -a $output
                        let "result=$result+1"
                    else
                        echo "iperf blocked test Passed!" | tee -a $output
                    fi
                else
                    echo "iperf blocked test Passed!" | tee -a $output
                fi
            else
                let "result=$result+1"
            fi
        else
            echo "AT_ERROR : Invalid iperf log!"
            let "result=$result+1"
        fi
    else
        echo "AT_ERROR : No such file <${input}/${current_port}.log>" | tee -a $output
        let "result=$result+1"
    fi
    echo "--------------------------------" | tee -a $output
done

echo "length : ${#unblock_fail_array[@]}"

if [ ${#unblock_fail_array[@]} -gt 0 ];then
    echo "${unblock_fail_array[*]} test Fail,we begin to retry test them!"

    for port in ${unblock_fail_array[*]}
    do
        echo "current test port : ${port}"
        for retry in `seq 1 ${retry_time}`
        do
            echo "Port ${port},Retry ${retry} Times"
            echo "bash $U_PATH_TBIN/iperf_test.sh -${server_side} -target $target -proto UDP -lport $port -rport $port -unblock"
            bash $U_PATH_TBIN/iperf_test.sh -${server_side} -target $target -proto UDP -lport $port -rport $port -unblock
            if [ $? -eq 0 ];then
                let retry_pass=${retry_pass}+1
                echo "AT_WARNING : iperf test PASS on port $port,retry ${retry} times!"
                echo "sleep ${retry_interval}"
                sleep ${retry_interval}
                break
            elif [ ${retry} -eq ${retry_time} ];then
                echo "AT_ERROR : iperf test FAIL on port $port,retry ${retry} times!"
            fi

            echo "sleep ${retry_interval}"
            sleep ${retry_interval}  
        done    
    done

    if [ ${#unblock_fail_array[@]} -eq ${retry_pass} ];then
        result=0
    else
        result=1
    fi
else
    echo "length is 0"
fi
exit $result
