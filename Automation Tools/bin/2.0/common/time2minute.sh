#!/bin/bash
# Program
#      This tool is used to change time to minutes
#
#
# History
#     DATE    |   REV   |   AUTH   |    INFO        |
#  2012/05/30 |  1.0.0  |  Prince  | Inital Version |

VER="1.0.0"
echo "$0 version : ${VER}"

usage="bash $0 -o <output file> [--test]"

USAGE()
{
    cat <<usge
USAGE
     bash $0 -o <output file> [--test]

OPTIONS
     -o:  output file

NOTES
     1.if you DON'T run this script in testcase , please put [--test] option in front of another options

EXAMPLES
     bash $0 -o <outfile> [--test]
usge
}

function cecho(){
    case "$1" in
        "pass")
            #color is green
            echo -e " ====== $2 "
            ;;
        "warn")
            #color is yellow
            echo -e " ====== $2 "
            ;;
        "fail")
            #color is red
            echo -e " ====== $2 "
            ;;
        *)
            echo "====== $1 "
            ;;
    esac
}


while [ -n "$1" ]
do
    case "$1" in
        --test)
            cecho "Test Mode : Test Mode!"
            export U_PATH_TBIN=.
            export G_CURRENTLOG=.
            export U_CUSTOM_ACCESS_DENY_SEC=300
            export U_CUSTOM_ACCESS_ALLOWED_SPAN_SEC=300
            export G_PROD_IP_BR0_0_0=192.168.2.1
            export U_DUT_TELNET_USER=admin
            export U_DUT_TELNET_PWD=admin1
            export U_DUT_TELNET_PORT=23
            shift
            ;;
        -o)
            outlog=$2
            cecho "output file : $outlog"
            shift 2
            ;;
        *)
            USAGE
            exit 1
    esac
done

if [ -z "$outlog" ];then
    outlog=$G_CURRENTLOG/access_span.log
    cecho "The output file : $outlog"
fi


bash $U_PATH_TBIN/cli_dut.sh -v dut.date -o $G_CURRENTLOG/dut_date_info.log

if [ "$?" -ne "0" ];then
    cecho fail "bash $U_PATH_TBIN/cli_dut.sh -v dut.date -o $G_CURRENTLOG/dut_date_info.log"
    cecho fail "AT_ERROR : Get DUT date info Failed"
    exit 1
fi

curdate=`cat $G_CURRENTLOG/dut_date_info.log|awk -F= '{print $2}'`
cecho "DUT Current date : $curdate"
if [ -z "$curdate" ];then
	echo "AT_ERROR : DUT Current date is NULL!"
	exit 1
fi

date_curdate=`date -u -d "$curdate" +%d`
echo "date_curdate_DUT : ${date_curdate}"
#exit 0

curminutes=$(echo "`date -u -d \"$curdate\" +%H`*60+`date -d \"$curdate\" +%M`"|bc)
cecho "Current minutes DUT : $curminutes"

echo "current date LAN : `date`"
cur_minutes_lan=$(echo "`date  +%H`*60+`date  +%M`"|bc)
date_curdate_lan=`date  +%d`
echo "Current minutes on LAN PC : $cur_minutes_lan"

delta_min_DUT_LAN=$(echo "${cur_minutes_lan}-${curminutes}"|bc)
echo "delta_min_DUT_LAN : $delta_min_DUT_LAN"
#	date_curdate_lan
delta_date_DUT_LAN=$(echo "${date_curdate_lan}-${date_curdate}"|bc)
if [ "${delta_date_DUT_LAN}" != "0" ] ;then
	delta_min_DUT_LAN=$(echo "${delta_min_DUT_LAN}+1440"|bc)
fi

cecho "U_CUSTOM_ACCESS_DENY_SEC=$U_CUSTOM_ACCESS_DENY_SEC"
cecho "U_CUSTOM_ACCESS_ALLOWED_SPAN_SEC=$U_CUSTOM_ACCESS_ALLOWED_SPAN_SEC"
let start_time=$curminutes+$U_CUSTOM_ACCESS_DENY_SEC/60
let end_time=$start_time+$U_CUSTOM_ACCESS_ALLOWED_SPAN_SEC/60

if [ $end_time -gt 1425 ] ;then
    echo "AT_INFO : the peroid time cross to tomorrow , test will continue to execute next day"
    
    let delta_sleep=1440-$curminutes
           
    echo "sleep ${delta_sleep}m"
    sleep ${delta_sleep}m

    date
    
    bash $U_PATH_TBIN/cli_dut.sh -v dut.date -o $G_CURRENTLOG/dut_date_info.log

    if [ "$?" -ne "0" ];then
        cecho fail "bash $U_PATH_TBIN/cli_dut.sh -v dut.date -o $G_CURRENTLOG/dut_date_info.log"
        cecho fail "AT_ERROR : Get DUT date info Failed"
        exit 1
    fi

    curdate=`cat $G_CURRENTLOG/dut_date_info.log|awk -F= '{print $2}'`
    
    cecho "Current date : $curdate"
    curminutes=$(echo "`date -u -d \"$curdate\" +%H`*60+`date -d \"$curdate\" +%M`"|bc)
    cecho "Current minutes : $curminutes"

    cecho "U_CUSTOM_ACCESS_DENY_SEC=$U_CUSTOM_ACCESS_DENY_SEC"
    cecho "U_CUSTOM_ACCESS_ALLOWED_SPAN_SEC=$U_CUSTOM_ACCESS_ALLOWED_SPAN_SEC"
    let start_time=$curminutes+$U_CUSTOM_ACCESS_DENY_SEC/60
    let end_time=$start_time+$U_CUSTOM_ACCESS_ALLOWED_SPAN_SEC/60
       
fi
#echo "delta_min_DUT_LAN : $delta_min_DUT_LAN"
echo ""
echo "U_CUSTOM_ASC_START=$start_time U_CUSTOM_ASC_END=$end_time U_CUSTOM_ASC_DELTA_DUT2LAN=$delta_min_DUT_LAN"|tee $outlog
