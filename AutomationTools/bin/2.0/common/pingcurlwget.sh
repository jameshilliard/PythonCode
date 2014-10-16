#!/bin/bash
# Program
#      This tool is used to do ping,wget or curl test
#
#
# History
#     DATE    |   REV   |   AUTH   |    INFO        |
#  2012/07/17 |  1.0.0  |  Prince  | Inital Version |

VER="1.0.0"
echo "$0 version : ${VER}"

USAGE()
{
    cat <<usge
USAGE
    bash $0 [--test] -p <ping dst IP> -I <ping src IP> -u <curl username:password> -r <curl URL> -w <wget URL>
OPTIONS
    -p : ping dst IP
    -I : ping src IP
    -u : curl username and password
    -r : curl URL
    -w : wget URL

NOTES
    1.if you DON'T run this script in testcase , please put [--test] option in front of other options
    2.the [-l] and [-o] parameter can be omitted,in that case,the output log will be in \$G_CURRENTLOG

EXAMPLES
    bash $0 [--test] -p 192.168.55.254
    bash $0 [--test] -w 192.168.55.254
    bash $0 [--test] -u 001505-TELUSV2000H-CVLK1301800043:9b24a6a4f82741a8bb4cb5cd2919968f  http://192.168.55.179:7547/
    bash $0 [--test] -p 192.168.55.254 -I 192.168.0.100 -u 001505-TELUSV2000H-CVLK0043:9b24a6a741a8bb4cb5cd2919968f  http://192.168.55.179:7547/
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
ping_timeout=60
ping_packets=5
while [ -n "$1" ]
do
    case "$1" in
        --test)
            cecho "Test Mode : Test Mode!"
            testflag=1
            export U_PATH_TBIN=.
            export G_CURRENTLOG=.
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
        -p)
	        ping_dst_ip=$2
	        cecho "ping dst IP : $ping_dst_ip"
	        shift 2
	        ;;
	    -I)
	        ping_src_ip=$2
	        cecho "ping_src_ip : $ping_src_ip"
	        shift 2
	        ;;
    	-u)
            curl_username_pwd=$2
	        cecho "curl username and pwd : $curl_username_pwd"
            username=`echo "$curl_username_pwd"|awk -F: '{print $1}'`
            userpwd=`echo "$curl_username_pwd"|awk -F: '{print $2}'`
            if [ -z "$username" ];then
                cecho fail "curl username is NULL!"
                USAGE
                exit 1
            fi
            if [ -z "$userpwd" ];then
                cecho fail "curl password is NULL!"
                USAGE
                exit 1
            fi
	        shift 2
	        ;;
        -r)
            curl_url=$2
            cecho "curl URL : $curl_url"
            shift 2
            ;;
        -w)
	        wget_url=$2
	        cecho "wget URL : $wget_url"
	        shift 2
	        ;;
	     -n)
            negflag=1
            cecho "Test Mode : Negative Test!"
            shift
            ;;
        *)
            USAGE
            exit 1
    esac
done

if [ -z "${negflag}" ];then
    negflag=0
    cecho "Test Mode : Positive Test!"
fi

if [ -z "${outlog}" ];then
    outlog=output.log
    cecho "The output log : $outlog"
fi

if [ -z "${logpath}" ];then
    logpath=${G_CURRENTLOG}
    cecho "The output log path : ${logpath}"
fi

function ping_test(){
    cecho pass "Entry function pint_test"
    rm -f $logpath/ping_test.log
    if [ -z "$ping_src_ip" ];then
        cecho pass "No define source IP!"
        cecho pass "ping -d $ping_dst_ip -t $ping_timeout -c $ping_packets |tee $logpath/ping_test.log"
        ping -d $ping_dst_ip -t $ping_timeout -c $ping_packets |tee $logpath/ping_test.log
    else
        cecho pass "ping -d $ping_dst_ip -I $ping_src_ip -t $ping_timeout -c $ping_packets |tee $logpath/ping_test.log"
        ping -d $ping_dst_ip -I $ping_src_ip -t $ping_timeout -c $ping_packets |tee $logpath/ping_test.log
    fi
    declare -i receive_package=`cat $logpath/ping_test.log | grep -i "packet *loss" |grep -i "received"| awk '{print $4}'`
    echo "receive package numbers : $receive_package"
    if [ "$negflag" == "0" ];then
        cecho pass "Positive Test!"
        if [ $receive_package -gt 0 ];then
            cecho pass "Ping Test PASS PASS PASS!"
        else
            cecho fail "Ping Test FAIL FAIL FAIL!"
            exit 2
        fi
    else
        cecho pass "Negative Test!"
        if [ $receive_package -gt 0 ];then
            cecho fail "Ping Test FAIL FAIL FAIL!"
            exit 2
        else
            cecho pass "Ping Test PASS PASS PASS!"
        fi
    fi

}

function curl_test(){
    cecho pass "Entry function curl_test"
    rm -f $logpath/curl_test.log
    cecho pass "curl -f -v -m 10 --anyauth -u $curl_username_pwd $curl_url -o $logpath/curl_test.log"
    i=1
    timeout=60
    while true
    do        
        echo ""
        echo "--------------------------------------------------------------------------------------------------"
        cecho " Times : $i"
        curl -f -v -m 10 --anyauth -u $curl_username_pwd $curl_url
        rcc=$?
        echo "curl Result : $rcc"
        if [ "$rcc" == "0" ];then
            cecho pass "\"curl -f -v -m 10 --anyauth -u $curl_username_pwd $curl_url\" PASS PASS PASS!"
            break
        else
            cecho fail "\"curl -f -v -m 10 --anyauth -u $curl_username_pwd $curl_url\" FAIL FAIL FAIL!"
        fi
        let i=$i+1
        if [ "$i" == "5" ] ;then
            exit 3
        fi
        cecho "Try again after $timeout seconds......"
        sleep $timeout
        let timeout=$timeout+30
    done
}

function wget_test(){
    cecho pass "Entry function wget_test"
    rm -f $logpath/wget_test.log
    cecho pass "wget $wget_url -O $logpath/wget_test.log"
    wget $wget_url -O $logpath/wget_test.log
    rccc=$?
    echo "wget Result : $rccc"
    if [ "$rccc" == "0" ];then
        cecho pass "wget Test PASS PASS PASS"
    else
        cecho fail "wget Test FAIL FAIL FAIL"
        exit 4
    fi
}
echo "----------------- ifconfig --------------------"
ifconfig
echo "----------------- route -n --------------------"
route -n
echo "-----------------------------------------------"

if [ -n "$ping_dst_ip" ];then
    cecho pass "Start to do ping test!"
    cecho pass "ping_dst_ip : $ping_dst_ip" 
    ping_test
fi

if [ -n "$curl_username_pwd" ] && [ -n "$curl_url" ];then
    cecho pass "Start to do curl test!"
    cecho pass "curl_username_pwd : $curl_username_pwd" 
    cecho pass "curl_url : $curl_url"
    curl_test
elif [ -z "$curl_username_pwd" ] && [ -n "$curl_url" ];then
    cecho fail "curl username and pwd is NULL! Please define curl username and pwd!"
    USAGE
    exit 1
elif [ -n "$curl_username_pwd" ] && [ -z "$curl_url" ];then
    cecho fail "curl URL is NULL! Please define curl URL!"
    USAGE
    exit 1
fi

if [ -n "$wget_url" ];then
    cecho pass "Start to do wget test!"
    cecho pass "wget_url : $wget_url"
    wget_test
fi
