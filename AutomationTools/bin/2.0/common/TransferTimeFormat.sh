#!/bin/bash
#---------------------------------
# Name: Howard Yin
# Description:
# This script is used to
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH   | INFO
#17 May 2012    |   1.0.0   | Prince    | Inital Version


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
ToSecond=False
# print REV
echo "${REV}"

while [ $# -gt 0 ]
do
    case "$1" in
    -v)
        var=$2
        echo "Variable Name : ${var}"
        shift 2
        ;;
    -t)
        ctime=$2
        echo "Time :$ctime"
        shift 2
        ;;
    -z)
        tzone=$2
        echo "tzone ${tzone}"
        shift 2
        ;;
    -d)
        dls=$2
        echo "day light saving is $dls"
        shift 2
        ;;
    -s)
        ToSecond=True
        shift
        ;;
    -l)
        output=$2
        echo "out put file : $output"
        shift 2
        ;;
    -test)
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
let result=0
echo $ctime|grep "P\.M\."
rcpm=$?
if [ $rcpm -eq 0 ];then
    ctime=`echo "$ctime"|sed 's/ *P\.M\. *//g'`
    let result=12*3600
fi
echo "=========="
echo $ctime|grep "A\.M\."
rcam=$?
if [ $rcam -eq 0 ];then
    ctime=`echo "$ctime"|sed 's/ *A\.M\. *//g'`
fi
a=`date -d "$ctime" -u +%s `
echo "$a"
if [ "$tzone" == "Pacific" ];then
    let result=$a+8*3600+$result
else
    let result=$a+$result
fi


if [ "$dls" == "On" ] || [ "$dls" == "on" ] || [ "$dls" == "ON" ];then
    let result=$result-3600
fi
echo "--------------"
echo "${var}=${result}"|tee $output
