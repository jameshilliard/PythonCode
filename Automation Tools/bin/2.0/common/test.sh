#!/bin/bash

test_arr=(
3-50
2012-2100
400-600
268-1024
55
75
)

sort_arr(){
    echo "in function sort_arr"

    local s_time=`date +%s`

    local arr_name=$1

    local tmp_arr_name="tmp"$arr_name

    local tmp_str=""

    for ((i=0;i<`eval echo '$'{#$arr_name[@]}`;i++));
    do
        local tmp_str=$tmp_str"\n"`eval echo '$'{$arr_name[i]}`
    done

    for t_str in `echo -e $tmp_str |sort -un`;
    do
        local len_arr=`eval echo '$'{#$tmp_arr_name[@]}`
        eval local $tmp_arr_name[len_arr]=$t_str
    done

    eval $arr_name='('`eval echo '$'{$tmp_arr_name[@]}`')'

    local e_time=`date +%s`

    local d_time=`echo "$e_time-$s_time"|bc`

    echo "delta_time sort_arr : $d_time"
    }

extend_arr(){
    echo "in function extend_arr"

    local s_time=`date +%s`

    local arr_name=$1

    echo "array to extend : $arr_name"
    eval echo '$'{$arr_name[@]}

    for ((i=0;i<`eval echo '$'{#$arr_name[@]}`;i++));
    do
        local curr_p=`eval echo '$'{$arr_name[i]}`
        echo $curr_p | grep -q "-"
        local is_a_range=$?

        if [ $is_a_range -eq 0 ] ;then

            local startp=`echo $curr_p |awk -F"-" '{print $1}'`
            local endp=`echo $curr_p |awk -F"-" '{print $2}'`

            eval $arr_name[i]=$startp

            let "startp=$startp+1"

            for p_2_add in `seq $startp $endp`
            do
                local len_arr=`eval echo '$'{#$arr_name[@]}`
                eval $arr_name[len_arr]=$p_2_add
            done

        fi

    done

    local e_time=`date +%s`

    local d_time=`echo "$e_time-$s_time"|bc`

    echo "delta_time extend_arr : $d_time"
    }


pprint_array(){
    local arr_name=$1

    echo "array to pprint : $arr_name"

    sort_arr $arr_name

    local str_4_closed_ports=""

    local s_time=`date +%s`

    local len_closed_ports=`eval echo '$'{#$arr_name[@]}`

    local f_p=`eval echo '$'{$arr_name[0]}`

    for((i=1;i<$len_closed_ports;i++)); do
        local c_p=`eval echo '$'{$arr_name[i]}`
        local p_idx=`echo "$i-1"|bc`
        local a_idx=`echo "$i+1"|bc`
        local p_p=`eval echo '$'{$arr_name[p_idx]}`

        local delta=`echo "$c_p-$p_p"|bc`

        if [ $delta -gt 1  ] ;then
            if [ $i -ne 1 ] ;then
                local str_4_closed_ports=$str_4_closed_ports"-"$p_p" "$c_p
            else
                local str_4_closed_ports=$f_p" "$c_p
            fi
        else
            if [ $i -eq 1 ] ;then
                local str_4_closed_ports=$f_p
            elif [ $a_idx -eq $len_closed_ports ] ;then
                local str_4_closed_ports=$str_4_closed_ports"-"$c_p
            fi
        fi
    done

    local e_time=`date +%s`

    local d_time=`echo "$e_time-$s_time"|bc`

    echo "take $d_time s to pprint_array"

    echo $str_4_closed_ports
    }

extend_arr test_arr

pprint_array test_arr
