#!/bin/bash

#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to
#
#--------------------------------
# History   :
#   DATE        |   REV  | AUTH   | INFO
#03 May 2012    |   1.0.0   | Howard    | Inital Version

#   U_PATH_TBIN=$G_SQAROOT/bin/$G_BINVERSION/$U_DUT_TYPE

REV="$0 version 1.0.0 (03 May 2012)"
# print REV
echo "${REV}"

#function : parse the scan log by expected result,if all expected results are fit return true.
#input:
#   -i <index of being used by case>
#   -m <expected result>
#   -o <output to file>

while [ $# -gt 0 ]
do
    case "$1" in
    -i)
        index=$2
        echo " index of being used by case ${index}"
        shift 2
        ;;
    -m)
        expect_res=$2
        echo "  expected result ${expect_res}"
        shift 2
        ;;
    -f)
        input=$2
        echo "  input from ${input}"
        shift 2
        ;;
    -test)
        U_PATH_TBIN=.
        G_CURRENTLOG=/tmp
        is_test=1
        echo "  test mode"
        filtered_ports1=(
        "2" "9900" "666"
        )

        nmap_check_type1="all_filtered_except"

        shift 1
        ;;
    *)
        echo ".."
        exit 1
        ;;
    esac
done

if [ -z $is_test ] ;then
    if [ -z $U_PATH_TBIN ] ;then
        source resolve_CONFIG_LOAD.sh
    else
        source $U_PATH_TBIN/resolve_CONFIG_LOAD.sh
    fi
fi

if [ -z $index ] ;then
    index=1
fi

if [ -z $input ] ;then
    input=$G_CURRENTLOG/nmap_${index}.log
fi

if [ ! -f $input ] ;then
    echo "AT_ERROR : input file not existed !"
    exit 1
fi

check_port_result=0

array_names=(
"filtered_ports"
"open_ports"
"closed_ports"
)

filtered_ports=(
)

open_ports=(
)

closed_ports=(
)

#   nmap_check_type

arr_filtered="filtered_ports"$index

arr_open="open_ports"$index

arr_closed="closed_ports"$index

extend_arr(){
    echo "in function extend_arr"

    s_time=`date +%s`

    arr_name=$1

    echo "array to extend : $arr_name"
    eval echo '$'{$arr_name[@]}

    for ((i=0;i<`eval echo '$'{#$arr_name[@]}`;i++));
    do
        curr_p=`eval echo '$'{$arr_name[i]}`
        echo $curr_p | grep -q "-"
        is_a_range=$?

        if [ $is_a_range -eq 0 ] ;then

            startp=`echo $curr_p |awk -F"-" '{print $1}'`
            endp=`echo $curr_p |awk -F"-" '{print $2}'`

            #echo "range : $curr_p from $startp to $endp"

            eval $arr_name[i]=$startp

            let "startp=$startp+1"

            for p_2_add in `seq $startp $endp`
            do
                len_arr=`eval echo '$'{#$arr_name[@]}`
                eval $arr_name[len_arr]=$p_2_add
            done

        fi

    done

    #echo "extended array :"
    #eval echo '$'{$arr_name[@]}

    e_time=`date +%s`

    d_time=`echo "$e_time-$s_time"|bc`

    echo "delta_time extend_arr : $d_time"
    }

load_ports(){
    echo "in function load_ports"

    s_time=`date +%s`

    for p_status in `cat $input  |grep -o "^Discovered *[^ ]* *port"|awk '{print $2}' |sort -u`;
    do
        echo "  found ports of type : "$p_status
        array_name=$p_status"_ports"
        array_name=`echo $array_name | sed "s/|/_/g"`
        len_array_names=${#array_names[@]}

        existed=0

        for ((i=0;i<$len_array_names;i++))
        do
            if [ "${array_names[i]}" == "$array_name" ] ;then
                existed=1
            fi
        done

        if [ $existed -eq 0 ] ;then
            array_names[len_array_names]=$array_name
        fi
    done

    echo "all types of ports :  "${array_names[@]}

    for c_port_sta in `echo ${array_names[@]}`;
    do
        c_p_sta=`echo $c_port_sta | sed "s/\_ports//g" |sed "s/_/|/g"`
        echo "  searching $c_p_sta ports"
        for cport in `cat $input |grep -o "^Discovered *$c_p_sta *port *[0-9]*"|awk '{print $NF}' |sort -nu`;
        do
            len_array=`eval echo '$'{#$c_port_sta[@]}`
            eval $c_port_sta[len_array]=$cport
        done
    done

    e_time=`date +%s`
    d_time=`echo "$e_time-$s_time"|bc`
    echo "delta_time load_ports : $d_time"

    }

load_ports2(){
    echo "in function load_ports"

    s_time=`date +%s`

    for p_status in `cat $input  |egrep -o "^Discovered *[^ ]* *port|^[0-9]*/udp  [openfiltrclsd]+\|[openfiltrclsd]+"|awk '{print $2}' |sort -u`;
    do
        echo "  found ports of type : "$p_status
        array_name=$p_status"_ports"
        array_name=`echo $array_name | sed "s/|/_/g"`
        len_array_names=${#array_names[@]}

        existed=0

        for ((i=0;i<$len_array_names;i++))
        do
            if [ "${array_names[i]}" == "$array_name" ] ;then
                existed=1
            fi
        done

        if [ $existed -eq 0 ] ;then
            array_names[len_array_names]=$array_name
        fi
    done

    echo "all types of ports :  "${array_names[@]}

    for c_port_sta in `echo ${array_names[@]}`;
    do
        c_p_sta=`echo $c_port_sta | sed "s/\_ports//g" |sed "s/_/|/g"`
        echo "  searching $c_p_sta ports"
        arr_line=`python $U_PATH_TBIN/decode_arr.py -t load "$c_p_sta" -f $input`
        
        array=`echo $arr_line |grep "array in line"|awk -F'|' '{print $2}'`
        
        #echo "array is : "$array
                
        eval $c_port_sta=\($array\)
    done

    e_time=`date +%s`
    d_time=`echo "$e_time-$s_time"|bc`
    echo "delta_time load_ports : $d_time"

    }


load_ports_from_input(){
    echo "in function load_ports_from_input"

    s_time=`date +%s`

    load_ports2

    for a_name in `echo ${array_names[@]}`
    do
        len_a=`eval echo '$'{#$a_name[@]}`
        if [ $len_a -gt 0 ] ;then
            echo ""
            eval echo "$a_name : "'$'{#$a_name[@]}
            if [ -f "$U_PATH_TBIN/decode_arr.py" ] ;then
                eval echo '$'{$a_name[@]} >$G_CURRENTLOG/temp_arr
                python $U_PATH_TBIN/decode_arr.py -t pprint -f $G_CURRENTLOG/temp_arr
            fi
            
            echo ""
        else
            echo ""
            echo "$a_name : 0"
            echo ""
        fi
    done

    e_time=`date +%s`
    d_time=`echo "$e_time-$s_time"|bc`
    echo "delta_time load_ports_from_input : $d_time"

    }


all_filtered_except(){
    echo "in function all_filtered_except"

    s_time=`date +%s`
    
    extend_arr $arr_filtered
    
    eval echo '$'{$arr_filtered[@]} >$G_CURRENTLOG/temp_arr_filtered
    
    echo ${open_ports[@]} >$G_CURRENTLOG/temp_open_ports
    
    echo ${closed_ports[@]} >$G_CURRENTLOG/temp_closed_ports
    
    echo ${filtered_ports[@]} >$G_CURRENTLOG/temp_filtered_ports
    
    arr_sbfbn_line=`python $U_PATH_TBIN/decode_arr.py -t all_filtered_except --open_ports $G_CURRENTLOG/temp_open_ports --closed_ports $G_CURRENTLOG/temp_closed_ports --arr_filtered $G_CURRENTLOG/temp_arr_filtered`
        
    arr_sbfbn=(`echo $arr_sbfbn_line |grep "array in line"|awk -F'|' '{print $2}'`)
    
    
    arr_snbf_line=`python $U_PATH_TBIN/decode_arr.py --snbf -t all_filtered_except --open_ports $G_CURRENTLOG/temp_open_ports  --closed_ports $G_CURRENTLOG/temp_closed_ports --arr_filtered $G_CURRENTLOG/temp_arr_filtered --filtered_ports $G_CURRENTLOG/temp_filtered_ports`
        
    arr_snbf=(`echo $arr_snbf_line |grep "array in line"|awk -F'|' '{print $2}'`)
    
                   
    len_arr_sbfbn=${#arr_sbfbn[@]}
    len_arr_snbf=${#arr_snbf[@]}
    
    if [ $len_arr_sbfbn -gt 0 ] ;then
        check_port_result=1
    elif [ $len_arr_snbf -gt 0 ] ;then
        check_port_result=1
    fi

    e_time=`date +%s`
    d_time=`echo "$e_time-$s_time"|bc`
    echo "delta_time $nmap_check_type : $d_time"

    }
    
all_not_filtered_except(){
    echo "in function all_not_filtered_except"

    s_time=`date +%s`
    # the ones in arr_filtered should not be in open_ports or closed_ports

    extend_arr $arr_filtered
    
    eval echo '$'{$arr_filtered[@]} >$G_CURRENTLOG/temp_arr_filtered
    
    echo ${open_ports[@]} >$G_CURRENTLOG/temp_open_ports
    
    echo ${closed_ports[@]} >$G_CURRENTLOG/temp_closed_ports
    
    echo ${filtered_ports[@]} >$G_CURRENTLOG/temp_filtered_ports
    
    arr_sbfbn_line=`python $U_PATH_TBIN/decode_arr.py -t all_not_filtered_except --open_ports $G_CURRENTLOG/temp_open_ports --closed_ports $G_CURRENTLOG/temp_closed_ports --arr_filtered $G_CURRENTLOG/temp_arr_filtered`
        
    arr_sbfbn=(`echo $arr_sbfbn_line |grep "array in line"|awk -F'|' '{print $2}'`)
    
    arr_snbf_line=`python $U_PATH_TBIN/decode_arr.py -t all_not_filtered_except --open_ports $G_CURRENTLOG/temp_open_ports --snbf --closed_ports $G_CURRENTLOG/temp_closed_ports --arr_filtered $G_CURRENTLOG/temp_arr_filtered  --filtered_ports $G_CURRENTLOG/temp_filtered_ports`
        
    arr_snbf=(`echo $arr_snbf_line |grep "array in line"|awk -F'|' '{print $2}'`)
    
                   
    len_arr_sbfbn=${#arr_sbfbn[@]}
    len_arr_snbf=${#arr_snbf[@]}
    
    if [ $len_arr_sbfbn -gt 0 ] ;then
        check_port_result=1
    elif [ $len_arr_snbf -gt 0 ] ;then
        check_port_result=1
    fi

    e_time=`date +%s`
    d_time=`echo "$e_time-$s_time"|bc`
    echo "delta_time $nmap_check_type : $d_time"
    }


all_not_filtered(){
    echo "in function all_not_filtered"

    # the sum of len_closed and len_open should equal to count_all

    s_time=`date +%s`

    count_all=`cat $input|grep -o  "[0-9]* total ports"|awk '{print $1}'`

    echo "  all $count_all ports scanned !"

    len_closed_ports=${#closed_ports[@]}
    len_open_ports=${#open_ports[@]}

    c_all=`echo "$len_closed_ports+$len_open_ports"|bc`

    echo "  the sum of open ports and closed ports : $c_all"

    if [ "$c_all" != "$count_all" ] ;then
        echo "AT_ERROR : all_not_filtered check failed ."

        check_port_result=1
    else
        echo "AT_INFO : all_not_filtered check passed ."
    fi

    e_time=`date +%s`
    d_time=`echo "$e_time-$s_time"|bc`
    echo "delta_time $nmap_check_type : $d_time"

    }

all_blocked(){
    echo "in function all_blocked"

    s_time=`date +%s`
    #   len of open_ports and closed_ports should be 0

    #len_filtered_ports=${#filtered_ports[@]}
    len_open_ports=${#open_ports[@]}
    len_closed_ports=${#closed_ports[@]}

    if [ $len_open_ports -eq 0 -a $len_closed_ports -eq 0 ] ;then
        echo "all_blocked check passed ."

    else
        echo "AT_ERROR : all blocked check failed"
        check_port_result=1
    fi

    e_time=`date +%s`
    d_time=`echo "$e_time-$s_time"|bc`
    echo "delta_time $nmap_check_type : $d_time"

    }

load_ports_from_input

len_arr_filtered=`eval echo '$'{#$arr_filtered[@]}`

echo "  len_arr_filtered=$len_arr_filtered"

check_type="nmap_check_type"$index
nmap_check_type=`eval echo '$'$check_type`

if [ "$nmap_check_type" == "" ] ;then
    echo "AT_ERROR : must define nmap_check_type"
    exit 1
fi

echo "  nmap_check_type : $nmap_check_type"

$nmap_check_type

method_rc=$?

if [ $method_rc -eq 127 ] ;then
    echo "AT_ERROR : nmap_check_type -> $nmap_check_type not supported"
    exit 1
fi

if [ $check_port_result -eq 0 ] ;then
    echo "scan result parsing passed !"
    exit 0
else
    echo "AT_ERROR : scan result parsing failed !"
    
    len_arr_sbfbn=${#arr_sbfbn[@]}
    len_arr_snbf=${#arr_snbf[@]}
    
    echo "---------------------------------------------------------"
    
    if [ $len_arr_sbfbn -gt 0 ] ;then
        echo "the ports that should be filtered :"
        
        if [ -f "$U_PATH_TBIN/decode_arr.py" ] ;then
            echo ${arr_sbfbn[@]} >$G_CURRENTLOG/temp_arr
            python $U_PATH_TBIN/decode_arr.py -t pprint -f $G_CURRENTLOG/temp_arr
        fi
    fi
    
    echo "---------------------------------------------------------"
    
    if [ $len_arr_snbf -gt 0 ] ;then
        echo "the ports that should not be filtered :"
        
        if [ -f "$U_PATH_TBIN/decode_arr.py" ] ;then
            echo ${arr_snbf[@]} >$G_CURRENTLOG/temp_arr
            python $U_PATH_TBIN/decode_arr.py -t pprint -f $G_CURRENTLOG/temp_arr
        fi
    fi
    
    echo "---------------------------------------------------------"
    
    exit 1
fi
