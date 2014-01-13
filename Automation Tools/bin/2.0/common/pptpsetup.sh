#!/bin/bash
# Program
#      This tool is used to pptpsetup
#
#
# History
#     DATE    |   REV   |   AUTH   |    INFO        |
#  2012/06/19 |  1.0.0  |  Prince  | Inital Version |
#  2012/09/03 |  1.0.1  |  Messi   | Add retry times |

VER="1.0.0"
echo "$0 version : ${VER}"

retry=5

USAGE()
{
    cat <<usge
USAGE
    bash $0 [--test] -s <pptp server> -u <pptp username> -p <pptp password> -o <output log> -l <output log directory> 
OPTIONS
    -s : pptp server
    -u : pptp username
    -p : pptp password
    -o : output log    
    -l : output log path,just the path!

NOTES
    1.if you DON'T run this script in testcase , please put [--test] option in front of other options
    2.the [-l] and [-o] parameter can be omitted,in that case,the output log will be in \$G_CURRENTLOG

EXAMPLES
    bash $0 [--test] -s 192.168.55.254 -u pptptest001 -p 111111 
usge
}

function cecho(){
    case "$1" in
        "pass")
            #color is green
            echo -e "====== $2 "
            ;;
        "warn")
            #color is yellow
            echo -e "====== $2 "
            ;;
        "fail")
            #color is red
            echo -e "====== $2 "
            ;;
        *)
            echo "====== $1 "
            ;;
    esac
}

function createlog(){
    crefile=$1
    ls ${logpath}/${crefile}* 2> /dev/null
    cecho pass "Create output log"
    if [ $? -gt 0 ];then
        curlogfile="${crefile}_1"
    else
        index=`ls ${logpath}/${crefile}*|wc -l`
        let curindex=${index}+1
        curlogfile="${crefile}_${curindex}"
    fi
    cecho pass "curlogfile=${curlogfile}"
}

testflag=0
while [ -n "$1" ]
do
    case "$1" in
        --test)
            cecho "Test Mode : Test Mode!"
            testflag=1
            export U_PATH_TBIN=.
            export G_CURRENTLOG=.
            export G_PROD_IP_BR0_0_0=192.168.1.1
            export U_DUT_TELNET_USER=admin
            export U_DUT_TELNET_PWD=password
            export U_DUT_TELNET_PORT=23
            shift
            ;;
        -o)
            outlog=$2
            cecho "output log : $outlog"
            shift 2
            ;;
        -l)
            logpath=$2
            cecho "output log path : $logpath"
            shift 2
            ;;
        -s)
	        pptp_server=$2
	        cecho "pptp_server : $pptp_server"
	        shift 2
	        ;;
    	-u)
            pptp_username=$2
	        cecho "pptp username : $pptp_username"
	        shift 2
	        ;;
	    -p)
	        pptp_password=$2
	        cecho "pptp password : $pptp_password"
	        shift 2
	        ;;
        -a)
            pptp_name=$2
	        cecho "pptp name : $pptp_name"
	        shift 2
	        ;;

         *)
            USAGE
            exit 1
    esac
done

if [ -z "${outlog}" ];then
    outlog=output.log
    cecho "The output log : $outlog"
fi

if [ -z "${logpath}" ];then
    echo "G_CURRENTLOG:${G_CURRENTLOG}"
    logpath=${G_CURRENTLOG}
    cecho "The output log path : ${logpath}"
fi

create_pptp(){
if [ $retry -eq 0 ];then
    cecho fail "create pptp fail for 3 times!"
    cecho fail "AT_ERROE : perl $U_PATH_TBIN/verifyPing.pl -d $remote_IP_address -I $usinginterface -l $G_CURRENTLOG -o $curlogfile"
    exit 1
fi

killall -9 pppd

    rm -f /etc/ppp/chap-secrets 
    rm -f ${logpath}/${outlog}
    rm -f ${logpath}/${outlog}_IP
    sleep 2
    echo " pptpsetup  --create $pptp_name --server $pptp_server --username $pptp_username --password $pptp_password  --encrypt --start |tee ${logpath}/${outlog}
"
echo "------------------------------------"
pptpsetup  --create $pptp_name --server $pptp_server --username $pptp_username --password $pptp_password  --encrypt --start |tee ${logpath}/${outlog}

echo "*************************************************"
echo "sleep 2......"
#sleep 2
#if [ ! -f ${logpath}/${outlog} ];then
 #   cecho fail "${logpath}/${outlog} not exist!" && exit 1
#fi
#test ! -f ${logpath}/${outlog} && cecho fail "${logpath}/${outlog} not exist!" && exit 1
cecho pass "cat ${logpath}/${outlog}"
cat ${logpath}/${outlog}
remote_IP_address=`grep -i "remote *IP *address *[0-9]*\.[0-9]*\.[0-9]*\.[0-9]" ${logpath}/${outlog}|awk '{print $4}'`
local_IP_address=`grep -i "local *IP *address *[0-9]*\.[0-9]*\.[0-9]*\.[0-9]" ${logpath}/${outlog}|awk '{print $4}'`
usinginterface=`grep -i  "Using interface" ${logpath}/${outlog}|awk '{print $3}'`

if [ "$remote_IP_address" == "" ];then
    cecho fail "AT_ERROE : pptpsetup  --create $pptp_name --server $pptp_server --username $pptp_username --password $pptp_password  --encrypt --start Fail!"
    cecho fail "AT_ERROE : Not find remote IP address!"

elif [ "$local_IP_address" == "" ];then
    cecho fail "AT_ERROE : pptpsetup  --create $pptp_name --server $pptp_server --username $pptp_username --password $pptp_password  --encrypt --start Fail!"
    cecho fail "AT_ERROE : Not find local IP address!"

elif [ "$usinginterface" == "" ];then
    cecho fail "AT_ERROE : pptpsetup  --create $pptp_name --server $pptp_server --username $pptp_username --password $pptp_password  --encrypt --start Fail!"
    cecho fail "AT_ERROE : Not find Using interface!"
    
fi

cecho pass "ifconfig $usinginterface"
ifconfig $usinginterface
if [ $? != 0 ];then
    cecho fail "AT_ERROR : ifconfig $usinginterface Fail!"
fi

echo "remote_IP_address=$remote_IP_address" |tee ${logpath}/${outlog}_IP
echo "local_IP_address=$local_IP_address" |tee ${logpath}/${outlog}_IP -a
echo "usinginterface=$usinginterface"|tee ${logpath}/${outlog}_IP -a

cecho pass "Start to Ping test"
createlog pingremoteIP.log
echo "perl $U_PATH_TBIN/verifyPing.pl -d $remote_IP_address -I $usinginterface -l $G_CURRENTLOG -o $curlogfile"
perl $U_PATH_TBIN/verifyPing.pl -d $remote_IP_address -I $usinginterface -l $G_CURRENTLOG -o $curlogfile
rc=$?
echo "rc=$rc"


echo " pptpsetup  --delete $pptp_name 
"
echo "------------------------------------"
pptpsetup  --delete $pptp_name 

echo "*************************************************"
echo "sleep 2......"



if [ "$rc" != "0" ];then
    let "retry=$retry-1"
    sleep 5
    echo "sleep 5"
    create_pptp
else
    cecho pass "ping pass"
    exit 0
fi
}

create_pptp

