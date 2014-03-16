#!/bin/bash

# Author               :   
# Description          :
#   This tool is used for capturing packets.
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#25 Nov 2011    |   1.0.0   | Alex      | Inital Version       
# 5 Dec 2011    |   1.0.1   | Alex      | make option '-R' can accept multi parameters
#19 Dec 2011    |   1.0.2   | Alex      | When use opiton '-V',make it support print the number of captured packets
#21 Dec 2011    |   1.0.3   | Alex      | Add '-s' option to specify sigle packet size
#28 Dec 2011    |   1.0.4   | Alex      | modified log output
#23 Feb 2011    |   1.0.5   | Alex      | print AT_ERROR 
#08 Jun 2012    |   1.0.6   | Prince    | add para -c to check packet count
##########################################################################################################################

REV="$0 version 1.0.5 (23 Feb 2011)"
# print REV
echo "${REV}"

usage="usage: bash $0 -i <Interface> -f <Capture filter> -R <Read filter> -t <duration> -r <Input file> -s <sigle packet size> -o <Output file> [-V] [-n]-N [name resolving flags] -I <interval> -d <error range> -e <field>  [-test]\n"


#colour echo
cecho() {
    case $1 in
        error)
            echo -e " "$2" "
            ;;
        debug)
            echo -e " "$2" "
            ;;
    esac
}

num=0
readfilter=''
name_resolve_flag=False
interval_time=""
interval_error=0
field=""
# parse commandline
while [ -n "$1" ];
do
    case "$1" in
    -test)
        cecho debug "mode : test mode"
        U_PATH_TBIN=.
        G_CURRENTLOG=.
        shift 1
        ;;
    -i)
        interface=$2
        shift 2
        ;;          
    -f)
        capfilter="$2"
        shift 2
        ;;
    -R)
        if [ $num -eq 0 ]; then
            readfilter=$2
        else
            readfilter=$readfilter" and $2"
        fi
        let "num=$num+1"
        shift 2
        ;;         
    -t)
        dtime=$2
        shift 2
        ;;
    -r)
        infile=$2
        shift 2
        ;;        
    -s)
        sigle_size=$2
        shift 2
        ;;
    -o)
        outfile=$2
        shift 2
        ;;        
    -V)
        view="enable"
        shift 1
        ;;       
    -n)
        flag="nagetive"
        shift 1
        ;;    
    -c)
        packetsend=$2
        shift 2
        ;;
    -h)
        echo -e "$usage"
        shift 1
        exit 1
        ;;
    -N)
        echo "name resolving flags"
        name_resolve_flag=True
        shift
        ;;
    -I)
        interval_time=$2
        echo "interval time:$interval_time"
        shift 2
        ;;
    -d)
        interval_error=$2
        echo "error range : $interval_error"
        shift 2
        ;;
    -e)
        field=$2
        echo "field to print : $field"
        shift 2
        ;;
    *)
        echo -e "$usage"
        echo "AT_ERROR : parameters input error!"
        exit 1
        ;;
    esac
done


# comment by andy. cause of readfilter : udp.dstport == 33434
#readfilter=`echo $readfilter|sed "s/or/ or /g"`
echo "readfilter=$readfilter"


if [ -z "$dtime" ]; then
    dtime=60
fi

if [ -z "$sigle_size" ]; then
    sigle_size=0
fi

if [ -z "$capfilter" ]; then
    capfilter="tcp port http"
fi

if [ -z "$outfile" ];then
    outfile=$G_CURRENTLOG/parse_packet.log
fi

if [ -n "$field" ] && [ -n "$interval_time" ];then
    echo "AT_ERROR : -e and -I can not be used together!"
    exit 1
fi
compute_interval(){
    echo "Enter function compute_interval"
    if [ $num -eq 1 ] || [ $num -le 0 ];then
        echo "$num packets was capture!"
        return 1
    fi
    if [ -z "$interval_time" ];then
        echo "No define interval_time!"
        return 1
    elif [ -z "$interval_error" ];then
        echo "No define interval_error!"
        return 1
    fi
    echo "error range:$interval_error"
    echo "$interval_error" | grep "^[0-9][0-9]*$"
    rc1=$?
    echo "$interval_error" | grep "^[1-9][0-9]*%$"
    rc2=$?
    if [ $rc1 -eq 0 ];then
        echo "min_interval=$interval_time-$interval_error"
        let min_interval=$interval_time-$interval_error
        echo "min_interval=$min_interval"

        echo "max_interval=$interval_time+$interval_error"
        let max_interval=$interval_time+$interval_error
        echo "max_interval=$max_interval"
    elif [ $rc2 -eq 0 ];then
        interval_error=`echo "$interval_error" | grep -o "[1-9][0-9]*"`
        let interval_error=$interval_error
        interval_error=`awk -v c=$interval_error 'BEGIN{printf "%.2f",c/100}'`
        min_interval=`awk -v a=$interval_time -v b=$interval_error 'BEGIN{printf "%.2f",a*(1-b)}'`
        max_interval=`awk -v a=$interval_time -v b=$interval_error 'BEGIN{printf "%.2f",a*(1+b)}'`
        min_interval=${min_interval}
        max_interval=${max_interval}
        echo "min_interval=$min_interval"
        echo "max_interval=$max_interval"
    else
        echo "-d : error range format error,should like 60 or 5%!"
        return 1
    fi
    declare -a time_arr=()
    for i in `cat $outfile|sed '/^$/d'|awk '{print $2}'`
    do
        if [ -z "$i" ];then
            echo "AT_ERROR : Time is Null!"
            return 1
        fi
        echo -e "\nTime  :$i"
        echo "date -d \"$i\" +%s"
        c=`date -d "$i" +%s`
        if [ $? -ne 0 ];then
            echo "AT_ERROR : Change Time to second format Error!"
            return 1
        fi
        echo "Second:$c"
        time_arr=(${time_arr[*]} $c)
    done
    echo "time_arr:${time_arr[*]}"
    echo ""
    if [ -z "${time_arr[*]}" ];then
        echo "AT_ERROR : time_err is Null!"
        return 1
    fi
    if [ ${#time_arr[*]} -lt 2 ];then
        echo "AT_ERROR : time_arr length ${#time_arr[*]} less than 2!"
        return 1
    fi
    let b=${#time_arr[*]}-1
    declare -a range_arr=()
    for j in `seq 1 $b`
    do
        let h=$j-1
        let err=${time_arr[$j]}-${time_arr[$h]}
        echo "Interval:$err"
        range_arr=(${range_arr[*]} $err)
    done
    echo ""
    #echo ${range_arr[*]}
    v=1
    for k in ${range_arr[*]}
    do
        
        rc1=`expr $k \>\= $min_interval`
        rc2=`expr $max_interval \>\= $k`
        if [ $rc1 -eq 1 ] && [ $rc2 -eq 1 ];then
            echo "Actual interval:$k in range [$min_interval,$max_interval],PASS!"
        else
            echo "Actual interval:$k out range [$min_interval,$max_interval],FAIL!"
            #echo "Min    interval:$min_interval"
            #echo "Max    interval:$max_interval"            
            echo "The $v interval FAIL!"
            return 1
        fi
        v=v+1
    done
    echo "Leave function compute_interval"
}
#capture packets raw to file cap_raw.log
if [ -z "$infile" ]; then
    if [ -z "$capfilter" ]; then
        cecho debug "tshark -a duration:$dtime -s $sigle_size -w $G_CURRENTLOG/cap_raw.log"
        tshark -i $interface -a duration:$dtime -s $sigle_size -w $G_CURRENTLOG/cap_raw.log
    else
        cecho debug "tshark -i $interface -f "$capfilter" -a duration:$dtime -s $sigle_size -w $G_CURRENTLOG/cap_raw.log"
        tshark -i $interface -f "$capfilter" -a duration:$dtime -s $sigle_size -w $G_CURRENTLOG/cap_raw.log
    fi
fi

#use tshark parse raw capture packets captured before or from input file
if [ "$view" != "enable" ]; then
    if [ -z "$infile" ]; then
        cecho debug "tshark -r $G_CURRENTLOG/cap_raw.log -R $readfilter -s $sigle_size > $outfile"
        tshark -r $G_CURRENTLOG/cap_raw.log -R "$readfilter" -s $sigle_size > $outfile
    else
        if [ "$name_resolve_flag" == "True" ];then
            if [ -z "$field" ];then
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size -N mntC > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size -N mntC > $outfile
            else
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size -N mntC -T fields -e $field > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size -N mntC -T fields -e $field > $outfile
            fi
        else
            if [ -z "$field" ];then
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size > $outfile
            else
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size -T fields -e $field > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size -T fields -e $field > $outfile
            fi
        fi

    fi
#    cat $outfile
else
    if [ -z "$infile" ]; then
        cecho debug "tshark -r $G_CURRENTLOG/cap_raw.log -R $readfilter -s $sigle_size -V > $outfile"
        tshark -r $G_CURRENTLOG/cap_raw.log -R "$readfilter" -s $sigle_size -V > $outfile
    else
        if [ "$name_resolve_flag" == "True" ];then
            if [ -z "$field" ];then
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size -V -N mntC > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size -V -N mntC > $outfile
            else
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size -V -N mntC -T fields -e $field > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size -V -N mntC -T fields -e $field > $outfile
            fi
        else
            if [ -z "$field" ];then
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size -V > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size -V > $outfile
            else
                cecho debug "tshark -r $infile -R $readfilter -s $sigle_size -V -T fields -e $field > $outfile"
                tshark -r $infile -R "$readfilter" -s $sigle_size -V -T fields -e $field > $outfile
            fi
        fi
    fi
fi

count_field(){
    echo "Entry count_field"
    count=`cat $outfile|sed '/^$/d'|sort|uniq|wc -l`
    echo "field count:$count"
    if [ "$count" == "1" ];then
        cp -f $outfile ${outfile}.bak
        cat $outfile|sed '/^$/d'|sort|uniq|sed 's/^ *//g'|sed 's/ *$//g'|tee $outfile
        echo "PASS"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

if [ "$view" != "enable" ]; then
    num=`cat $outfile|sed '/^$/d'| wc -l`
    echo "the number of captured packets is : $num" > $G_CURRENTLOG/cap_read_num.log
else
    tshark -r $infile -R "$readfilter" > $G_CURRENTLOG/cap_read_num.log
    num=`cat $G_CURRENTLOG/cap_read_num.log|sed '/^$/d'| wc -l`
    echo "the number of captured packets is : $num" > $G_CURRENTLOG/cap_result.log
fi

if [ -z "$packetsend" ];then
    if [ "$flag" != "nagetive" ]; then
        if [ $num -eq 0 ]; then
            cecho error "result : no packet captured!"
            echo "AT_ERROR : no packet captured!"
            exit 1
        else
            cecho debug "result : $num packets captured"
            if [ -n "$interval_time" ];then
                compute_interval
                if [ $? -ne 0 ];then
                    exit 1
                fi
            elif [ -n "$field" ];then
                count_field
                if [ $? -ne 0 ];then
                    exit 1
                fi
            fi
            exit 0
        fi
    else
        if [ $num -eq 0 ]; then
            cecho debug "result : no packet captured."
            exit 0
        else
            cecho error "result : $num packets captured!"
            echo "AT_ERROR : negative test,$num packets captured!"
            exit 1
        fi
    fi
else
    if [ "$flag" != "nagetive" ]; then
        cecho debug "Test Mode : Positive Test!"
        if [ "$num" == "$packetsend" ]; then
            cecho debug "result : $num packets captured!"
            if [ -n "$interval_time" ];then
                compute_interval
                if [ $? -ne 0 ];then
                    exit 1
                fi
            elif [ -n "$field" ];then
                count_field
                if [ $? -ne 0 ];then
                    exit 1
                fi
            fi
            exit 0
        else
            cecho debug "result : $num packet captured!Should be $packetsend packets!"
            echo "AT_ERROR : $num packet captured!Should be $packetsend packets!"
            exit 1
        fi
    else
        cecho debug "Test Mode : Negative Test"
        if [ $num -eq 0 ]; then
            cecho debug "result : no packet captured."
            exit 0
        else
            cecho error "result : $num packets captured!"
            echo "AT_ERROR : negative test,$num packets captured!"
            exit 1
        fi
    fi
fi

