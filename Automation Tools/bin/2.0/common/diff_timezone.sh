#!/bin/bash
#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH   | INFO
#17 May 2012    |   1.0.0   | Howard    | Inital Version

#   U_PATH_TBIN=$G_SQAROOT/bin/$G_BINVERSION/$U_DUT_TYPE

USAGE()
{
    cat <<usge
USAGE :

    bash diff_timezone.sh -c <captured file> -d <delta range> [-z <timezone>] -test [-dls]

OPTIONS:
    -c:     tshark raw captured output file
    -d:     allowed delta range between DUT local time and NTP server time
    -z:     timezone that DUT currently using , such as '-9' , '+8' , make sure it is quoted
    -dls:   indicates that the DUT enabled day light saving
    -test:  test mode

EXAMPLES:

    bash diff_timezone.sh -c ~/automation/tshark.cap -d 200 -z '-5' -test -dls
usge
}

REV="$0 version 1.0.0 (17 May 2012 )"
# print REV
echo "${REV}"

while [ $# -gt 0 ]
do
    case "$1" in
    -c)
        capture_file=$2
        echo "  capture_file ${capture_file}"
        shift 2
        ;;
    -d)
        delta_sec=$2
        echo "  delta_sec ${delta_sec}"
        shift 2
        ;;
    -z)
        exp_tzone=$2
        echo "  exp_tzone ${exp_tzone}"
        shift 2
        ;;
    -dls)
        dls=1
        echo "  day light saving"
        shift 1
        ;;
    -nodls)
        dls=0
        echo "  no day light saving"
        shift 1
        ;;
    -test)
        capture_file=~/automation/tshark.cap
        U_PATH_TBIN=.
        G_CURRENTLOG=/tmp
        TMP_DUT_WAN_IP=192.168.55.114
        is_test=1
        shift 1
        ;;

    *)
        USAGE
        exit 1
        ;;
    esac
done

if [ -z $delta_sec ] ;then
    delta_sec=300
fi

get_wan_ip(){
    echo "in function get_wan_ip"

    bash $U_PATH_TBIN/cli_dut.sh -v "wan.info" -o $G_CURRENTLOG/wan.info.log

    wan_info_rc=$?

    if [ $wan_info_rc -gt 0 ] ;then
        echo "AT_ERROR : failed to execute cli_dut.sh"
        exit 1
    fi

    for to_export in `cat $G_CURRENTLOG/wan.info.log`
    do
        export $to_export
    done

    echo "TMP_DUT_WAN_IP=$TMP_DUT_WAN_IP"

    if [ "$TMP_DUT_WAN_IP" == ""  ] ;then
        echo "AT_ERROR : failed to get DUT WAN IP"
        exit 1
    fi
    }

parse_cfile(){
    echo "in function parse_cfile"

    if [ -f $capture_file ] ;then
        echo "  starting to parse $capture_file"

        get_wan_ip

        echo "tshark -r $capture_file -R \"ntp and ip.dst==$TMP_DUT_WAN_IP\" -V > $G_CURRENTLOG/ntp.log"
        tshark -r $capture_file -R "ntp and ip.dst==$TMP_DUT_WAN_IP" -V > $G_CURRENTLOG/ntp.log
    else
        echo "  AT_ERROR : $capture_file not existed ."
        exit 6
    fi
    }

fetch_dut_time(){
    echo "in function fetch_dut_time"

    if [ ! -z $is_test ] ;then
        echo "      test mode"
        bash $U_PATH_TBIN/cli_dut.sh -test -v "dut.date" -o $G_CURRENTLOG/dut.date.log
    else
        bash $U_PATH_TBIN/cli_dut.sh -v "dut.date" -o $G_CURRENTLOG/dut.date.log
    fi

    rc_cli=$?

    if [ $rc_cli -gt 0 ] ;then
        echo "AT_ERROR : executing cli_dut.sh failed !"
        exit 5
    fi

    DUT_TIME=`cat $G_CURRENTLOG/dut.date.log | grep "U_CUSTOM_LOCALTIME" |awk -F= '{print $2}'`

    echo "dut time is           |${DUT_TIME}|"

    DUT_TIME_IN_SEC=`date -d "${DUT_TIME}" -u +%s`

    #echo "DUT_TIME_IN_SEC : $DUT_TIME_IN_SEC"
    }

fetch_ntp_time(){
    ntp_time=`cat $G_CURRENTLOG/ntp.log |grep -i "Transmit *Time *Stamp:"|tr [A-Z] [a-z]|sed "s/transmit *time *stamp: *//g" |tail -1`

    if [ "" == "$ntp_time" ] ;then
        echo "AT_ERROR : maybe no NTP packet captured"
        exit 4
    fi

    echo "NTP server time is    |${ntp_time}|"

    NTP_TIME_IN_SEC=`date -d "${ntp_time}" -u +%s`

    #echo "NTP_TIME_IN_SEC : $NTP_TIME_IN_SEC"
    }

get_DUT_NTP_offset(){
    if [ ! -z $exp_tzone ] ;then
        DUT_TIME_IN_SEC=`echo "$DUT_TIME_IN_SEC-($exp_tzone*3600)"|bc`
    fi

    if [ ! -z $dls ] ;then
        if [ $dls -eq 1 ] ;then
            DUT_TIME_IN_SEC=`echo "$DUT_TIME_IN_SEC-3600"|bc`
        #elif [] ;then
        fi
    else
        echo "  day light saving setting in config file"
        if [ "$U_DEF_TZONE_DSLENABLED" == "1" ] ;then
            DUT_TIME_IN_SEC=`echo "$DUT_TIME_IN_SEC-3600"|bc`
        fi
    fi

    delta=`echo "$DUT_TIME_IN_SEC-$NTP_TIME_IN_SEC"|bc`

    if [ $delta -lt 0 ] ;then
        delta=`echo "0-($delta)"|bc`
    fi

    echo "delta : $delta"
    }

compare_delta(){
    echo "in function compare_delta"

    #   delta_sec
    offset=`echo "$delta_sec-($delta)"|bc`

    if [ $offset -gt 0 ] ;then
        echo "DUT time and NTP server time matched"
        exit 0
    else
        echo "AT_ERROR : offset is too big"

        if [ $delta -gt 3600 ] ;then
            echo "AT_ERROR : offset is bigger than an hour , the timezone maybe wrong"
            exit 1
        else
            exit 2
        fi
    fi
    }

parse_cfile

fetch_dut_time

fetch_ntp_time

get_DUT_NTP_offset

compare_delta
