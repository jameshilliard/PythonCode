#!/bin/bash
#---------------------------------
# Name: Andy liu
# Description:
# This script is used to execute upnpc-shard in wine to add or delete upnp rule
#
#--------------------------------
# History    :
#   DATE        |   REV     | AUTH      | INFO
#04 JUN 2012    |   1.0.0   | Andy      | Inital Version

REV="$0 version 1.0.0 (04 JUN 2012)"
echo "${REV}"

USAGE()
{
    cat <<usge
USAGE :
    bash upnp_test.sh -d <ip address> -i <internal port> -e <external port> -p <protocol> -o <output> [options]
        Add port redirection

    bash upnp_test.sh -e <external port> -p <protocol> -o <output>
        Delete port redirection

protocol is UDP or TCP

options :
    -n: negative test

EXAMPLES:
    bash upnp_test.sh -d 192.168.0.100 -i 1234 -e 12345 -p TCP -o /tmp/upnp.log
        Add an Upnp TCP rule : external 192.168.55.199:12345 TCP is redirected to internal 192.168.1.100:1234

    bash upnp_test.sh -d 192.168.0.100 -i 1234 -e 12345 -p UDP -n -o /tmp/upnp.log
        Add an Upnp DUP rule and expect can't add it
    
    bash upnp_test.sh -e 12345 -p TCP -o /tmp/upnp.log
        Delete and Upnp TCP rule
usge
}

parse_input(){
    if [ -z "$e_port" ] ;then
        echo "AT_ERROR : Haven't specified external port"
        exit 1
    fi

    if [ -z "$protocol" ] ;then
        echo "AT_ERROR : Haven't specified protocol"
        exit 1
    else
        if ! [ "$protocol" == "TCP" -o "$protocol" == "UDP" ] ;then
            echo "AT_ERROR : Please specified protocol : <TCP|UDP>"
            exit 1
        fi
    fi

    if [ "$ip" -a "$i_port" ] ;then
        echo "AT_INFO : Add port redirection"
        mode="add"

        if [ "$nega" == "0" ] ;then
            echo "AT_INFO : positive test"
        else
            echo "AT_INFO : negative test"
        fi

    elif [ -z "$ip" -a -z "$i_port" ] ;then
        echo "AT_INFO : Delete port redirection"
        mode="del"

        if [ "$nega" == "1" ] ;then
            echo "AT_ERROR : Delete port redirection mode is not support negative test"
            exit 1
        fi
    else
        echo "AT_ERROR : Should specified both of <client ipaddress> and <internal port> or both not specified"
        exit 1
    fi

    if [ -z "$output" ] ;then
        echo "AT_WARNING : Haven't specified output file,use default output file: $G_CURRENTLOG/UPnP.log"
        output=$G_CURRENTLOG/UPnP.log
    fi
}

execute_upnp(){
    if [ "$mode" == "add" ] ;then
	if [ "$U_DUT_TYPE" == "TDSV2200H" ];then
	echo "TDSV2200H WAN mode PTM need more time to make WAN connection ready for test. "
	echo "Waitting time:400s\!"
	sleep 400 
	fi
        [ $Debug -gt 1 ] && echo "Debug : wine $U_PATH_TOOLS/wine/UPnP/upnpc-shared.exe -a \"$ip\" \"$i_port\" \"$e_port\" \"$protocol\" | tee $output"
        wine $U_PATH_TOOLS/wine/UPnP/upnpc-shared.exe -a "$ip" "$i_port" "$e_port" "$protocol" | tee $output
	rc=$?
    fi

    if [ "$mode" == "del" ] ;then
        [ $Debug -gt 1 ] && echo "Debug : wine $U_PATH_TOOLS/wine/UPnP/upnpc-shared.exe -d \"$e_port\" \"$protocol\" | tee $output"
        wine $U_PATH_TOOLS/wine/UPnP/upnpc-shared.exe -d "$e_port" "$protocol" | tee $output
    fi
}

parse_output(){
    if [ "$mode" == "add" ] ;then
        #### external 192.168.55.199:12345 TCP is redirected to internal 192.168.1.100:1234
        [ $Debug -gt 1 ] && echo "Debug : grep \"external ${TMP_DUT_WAN_IP}:${e_port} [TCPUD]* is redirected to internal ${ip}:${i_port}\" $output"
        if [ "$U_DUT_TYPE" == "BHR2" ] && [ "$U_DUT_SW_VERSION" == "20.19.8" ];then
            debug_grep=`grep -i "ExternalIPAddress  *=  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" $output`
        elif [ "$U_DUT_TYPE" == "BHR4_OpenWRT" ];then
            debug_grep=`grep -i "ExternalIPAddress  *=  *[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" $output`
        else 
            debug_grep=`grep "external ${TMP_DUT_WAN_IP}:${e_port} [TCPUD]* is redirected to internal ${ip}:${i_port}" $output`
        fi
        rc=$?
        [ $Debug -gt 1 ] && echo "Debug : $debug_grep"  
        if [ "$nega" == "0" ] ;then
            if [ "$rc" -eq 0 ] ;then
                echo "AT_INFO : Add UPnP rule is successful -- positive test"
                rc=0
            else
                echo "AT_ERROR : Add UPnP rule is failed -- positive test"
                rc=1
            fi
        else
            if [ "$rc" -eq 0 ] ;then
                echo "AT_ERROR : Add UPnP rule is failed -- negative test"
                rc=1
            else
                echo "AT_INFO : Add UPnP rule is successful -- negative test"
                rc=0
            fi
        fi
    elif [ "$mode" == "del" ] ;then
        #### UPNP_DeletePortMapping() returned : 0
        [ $Debug -gt 1 ] && echo "Debug : grep \"UPNP_DeletePortMapping() returned : 0\" $output"
        debug_grep=`grep "UPNP_DeletePortMapping() returned : 0" $output`
        rc=$?
        [ $Debug -gt 1 ] && echo "Debug : $debug_grep"
        if [ "$rc" -eq 0 ] ;then
            echo "AT_INFO : Delete Unpn rule is successful"
            rc=0
        else
            echo "AT_ERROR : Delete UPnP rule is failed"
            rc=1
        fi
    fi
}

#if you want output more information set Debug to 1:comment 2:debug.
Debug=2

nega=0

mode=""

retry=3

delay=30

while [ $# -gt 0 ]
do
    case "$1" in
    --test)
        echo "Mode : Test mode"
        G_CURRENTLOG=/tmp
        U_PATH_TOOLS=$SQAROOT/tools/2.0
        TMP_DUT_WAN_IP=192.168.55.199
        shift 1
        ;;
    -d)
        ip=$2
        echo "  client ipaddress : ${ip}"
        shift 2
        ;;
    -i)
        i_port=$2
        echo "  internal port : ${i_port}"
        shift 2
        ;;
    -e)
        e_port=$2
        echo "  external port : ${e_port}"
        shift 2
        ;;
    -p)
        protocol=$2
        echo "  protocol : ${protocol}"
        shift 2
        ;;
    -o)
        output=$2
        echo "  output : ${output}"
        shift 2
        ;;
    -n)
        nega=1
        echo "  negative test!"
        shift 1
        ;;
    *)
        USAGE
        exit 1
        ;;
    esac
done

parse_input

for i in `seq $retry`; do
    execute_upnp

    parse_output

    if [ "$rc" == "0" ];then
        echo "AT_INFO : UPnP test passed"
        exit 0
    else
        echo "sleep $delay seconds and retry..."
        sleep $delay
    fi
done

echo "AT_ERROR : UPnP test failed"

exit 1

