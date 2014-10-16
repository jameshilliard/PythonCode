#!/bin/bash

# Author        :   
# Description   :
#   This tool is using 
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#07 Dec 2011    |   2.0.0   | Howard    | Inital Version
#08 Dec 2011    |   2.0.1   | Andy      | support opt -p
#09 Dec 2011    |   2.0.2   | Howard    | to create sepatare RPC and Log folder for each login operation
#04 JAN 2012    |   3.0.1   | Andy      | use quotation break up parameter, solve space in parameter
#09 MAR 2012    |   3.0.2   | Andy      | support timeout -e

VER="3.0.2"
echo "$0 version : ${VER}"

USAGE()
{
    cat <<usge
USAGE : 
    
    bash $0 -v <opt type> -c <RPC file> -l <ruby runtime log> -o <output log> -f <communication log> -d <not used> -s <serial No.> -x <debug level> -p <parameter> -e <timeout> -t <test mode>

OPTIONS:
    -v) operation type
            such as GPV , SPV and so on ...

    -c) RPC file
            RPC file to be executed

    -o) output log
            the operation output log , such as GPV result etc.

    -l) ruby runtime log
            the ruby runtime log

    -f) communication log
            the communication log of ruby

    -s) serial No or device id.
            the serial number of tested DUT

    -x) debug level
            debug level

    -d) obseleted
            obseleted in version 2.0

    -p) parameter
            using parameter instead of RPC files

    -e) timeout
            using set expirationTimeOut in ACS server

    -h) help
            display this help message

    -t) test
            test mode
     

NOTES :  
    
    1.  do NOT both defined -c and -p !
    2.  the [-d] option is no longer used !

usge
}

while getopts ":v:c:l:o:f:d:s:x:p:m:e:i:g:th" opt ;
do
    case $opt in
        v)
            RPC=$OPTARG
            ;;

        c)
            config=$OPTARG
            ;;

        p)
            para=$OPTARG
            ;;

        o)
            outputlog=$OPTARG
            ;;

        l)
            loglog=$OPTARG
            ;;

        f)
            difflog=$OPTARG
            ;;

        s)
            serialnumber=$OPTARG
            ;;

        x)
            debuglevel=$OPTARG
            ;;

        d)
            ;;

        e)
            timeout=$OPTARG
            ;;

        m)
            stepmask=$OPTARG
            ;;

        g)
            image_location=$OPTARG
            ;;

        h)
            #echo -e $usage
            USAGE
            exit 0
            ;;

        t)
            G_CURRENTLOG=/root/temp
            U_PATH_TBIN=../common
            U_TR069_CUSTOM_RPC_DEBUG_LOG=0
            U_CUSTOM_MOTIVE_USERNAME="actiontec3"
            U_CUSTOM_MOTIVE_PASSWORD="345edc!@"
            U_CUSTOM_MOTIVE_CLIENT_VER=3.0
            U_CUSTOM_MOTIVE_CLIENT_METHOD=remote_ssh
            U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS=192.168.100.40
            U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME=root
            U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD=actiontec
            U_CUSTOM_MOTIVE_FAIL_ON_CR_FAILRUE_FLAG=false
            U_CUSTOM_PATH_MOTIVE_DATA_MODEL=/root/automation/platform/2.0/CTLC2KA/config/CAH001-31.30L.6G/data_model
            U_CUSTOM_PATH_SERIAL_TO_ID=/root/automation/testsuites/2.0/CTLC2KAtest/cfg/.serialNumber2deviceId.cfg
            TMP_MOTIVE_SERVER_IP="ip.dst==64.186.191.23"
            ;;

        ?)
            paralist=-1
            echo "AT_ERROR : '-$OPTARG' not supported."
            echo -e $usage
            exit 1
    esac
done

start_capture(){
    echo "start capture on WAN PC ..."

    perl $U_PATH_TBIN/clicfg.pl -o 15 -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -i 22 -v "killall -s SIGINT tcpdump" -v "rm -rf $TMP_CAP_FILE" -v "nohup tcpdump -i $G_HOST_IF1_2_0 -s 0 -w $TMP_CAP_FILE > /dev/null 2>&1 &"  -v "sleep 3"

    rc=$?
    echo $rc
    if [ $rc -ne 0 ] ;then
        echo "AT_ERROR : star capture on WAN PC failed"
        exit 1
    fi
}

stop_capture(){
    echo "stop capture on WAN PC ..."

    perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/stop_tshark.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_TIP1_0_0 -v "jobs;killall -s SIGINT tcpdump;sleep 3" -v "mv -f $TMP_CAP_FILE ${difflog}.cap;sleep 3"

    rc=$?
    if [ $rc -ne 0 ] ;then
        echo "AT_ERROR : stop capture on WAN PC failed"
        exit 1
    fi
}

refresh_cwmp_info(){
    echo "refresh cwmp info"
    echo "bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log"
    bash $U_PATH_TBIN/cli_dut.sh -v cwmp.info -o $G_CURRENTLOG/cwmpInfo.log

    rc=$?
    if [ $rc -ne 0 ] ;then
        echo "AT_ERROR : get cwmp info failed"
        exit 1
    fi

    cat $G_CURRENTLOG/cwmpInfo.log

    echo "output cwmp info to env!"
    lines=`cat $G_CURRENTLOG/cwmpInfo.log | wc -l`
    for linenumber in `seq 1 $lines`
    do
        line=`sed -n "$linenumber"p $G_CURRENTLOG/cwmpInfo.log`
        export $line
        if [ "$U_CUSTOM_UPDATE_ENV_FILE" ] ; then
            echo $line >> $U_CUSTOM_UPDATE_ENV_FILE
        fi
    done
}

combine_curl_command(){
    echo "combine curl command"
    if [ "$U_CUSTOM_CWMP_FORCE_PERIODIC_INFORM" == "0" -a "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" == "$G_HOST_IP1" ] ;then
        echo "WAN PC works as RUBY server!"
        # curl -v -m 10 --anyauth -u $Conn_Req_Username:$Conn_Req_Password $ConnectionRequestURL

        if [ -z "$TMP_DUT_CWMP_CONN_REQ_USERNAME" -o -z "$TMP_DUT_CWMP_CONN_REQ_PASSWORD" -o -z "$TMP_DUT_CWMP_CONN_REQ_URL" -o "$refresh_cwmp_info_flag" == 0 ] ;then
            refresh_cwmp_info
        fi

        if [ -z "$TMP_DUT_CWMP_CONN_REQ_USERNAME" -o -z "$TMP_DUT_CWMP_CONN_REQ_PASSWORD" -o -z "$TMP_DUT_CWMP_CONN_REQ_URL" -a "$refresh_cwmp_info_flag" == 1  ] ;then
            echo "AT_ERROR : Get cwmp info failed"
            exit 1
        fi

        cwmp_conn_request="curl -f -v -m 10 --anyauth -u ${TMP_DUT_CWMP_CONN_REQ_USERNAME}:${TMP_DUT_CWMP_CONN_REQ_PASSWORD}  ${TMP_DUT_CWMP_CONN_REQ_URL}"

        echo " ------> cwmp_conn_request : $cwmp_conn_request"
    else
        echo "RUBY server is not WAN PC!"
        cwmp_conn_request=""
    fi
}

combine_ruby_parameter(){
    echo "combine motive_client.rb parameter"
    parameter="-x $debuglevel -m $stepmask -s $serialnumber --username=$U_CUSTOM_MOTIVE_USERNAME --password=$U_CUSTOM_MOTIVE_PASSWORD -v $RPC -f $U_CUSTOM_MOTIVE_FAIL_ON_CR_FAILRUE_FLAG --timeout $timeout "

    #device id
    count_serialnumber=`grep -c "$serialnumber" $U_CUSTOM_PATH_SERIAL_TO_ID`
    if [ $count_serialnumber -ne 1 ] ;then
        echo "AT_ERROR : more than one $serialnumber or no one in $U_CUSTOM_PATH_SERIAL_TO_ID"
        exit 1
    fi
    device_id=`grep "$serialnumber" $U_CUSTOM_PATH_SERIAL_TO_ID | awk '{print $2}'`

    parameter=$parameter"-i $device_id "

    if [ "$para" ] ;then
        parameter=$parameter"-p \\\"$para\\\" "
    elif [ "$config" ] ;then
        dos2unix $config
        echo "$RPC" | grep -i "spv"
        rc=$?
        if [ $rc -eq 0 ] ;then
            echo "SPV"
            lines=`cat $config|wc -l`
            for linenumber in `seq 1 $lines`
            do
                line=`sed -n "$linenumber"p $config`
                raw_node=`echo $line | awk -F '=' '{print $1}'`
                echo "raw_node : $raw_node"
                node=`echo $raw_node | sed "s/\.[0-9][0-9]*\./\./g"`
                echo "node : $node"
                node_type=`grep "^$node " $U_CUSTOM_PATH_MOTIVE_DATA_MODEL | awk '{print $2}'`
                echo "type : $node_type "
                if [ -z "$node_type" ] ;then
                    echo "AT_ERROR : can NOT get the type of $node in $U_CUSTOM_PATH_MOTIVE_DATA_MODEL"
                    exit 1
                fi
                type_count=`echo "$node_type" | wc -l`
                if [ "$type_count" != "1" ] ;then
                    echo "AT_ERROR : redefine $node in $U_CUSTOM_PATH_MOTIVE_DATA_MODEL"
                fi
                echo "$node_type" | grep -i "object"
                rc=$?
                if [ $rc -eq 0 ] ;then
                    echo "AT_ERROR : $node is NOT a leaf node in $U_CUSTOM_PATH_MOTIVE_DATA_MODEL"
                    exit 1
                fi
                parameter=$parameter"-p \\\"${line}::%#${node_type}\\\" "
            done
        else
            echo "not SPV"
            for line in `cat $config`
            do
                rc=`echo $line | grep -v "^ *#"`
                echo "node : $rc"
                if [ -n "$rc" ] ;then
                    parameter=$parameter"-p \\\"$rc\\\" "
                fi
            done
        fi
    elif [ "$image_location" ] ;then
        parameter=$parameter"-g \\\"$image_location\\\" "
    else
        echo "AT_ERROR : You must pass at least one parameter, a parameter file or image location -p -c -g"
        exit 1
    fi

    if [ "$cwmp_conn_request" ] ;then
        parameter=$parameter"-w \\\"$cwmp_conn_request\\\" "
    fi

    echo " ------> ruby client parameter : $parameter"
}

# return value
# 0 : parse capture -- Success
# 1 : parse capture -- Failure
# 2 : retry
# 3 : no parse capture
run_motive_client(){
    echo "run mitive_client.rb on WAN PC"
    
    if [ "$U_CUSTOM_MOTIVE_CLIENT_VER" == "4.0" ] ;then
        perl $U_PATH_TBIN/sshcli.pl -t 1200 -l "$G_CURRENTLOG" -o "$loglog" -d $U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -v "ruby $G_SQAROOT/tools/2.0/tr69/v4/motive_client.rb $parameter"
    else
        perl $U_PATH_TBIN/sshcli.pl -t 1200 -l "$G_CURRENTLOG" -o "$loglog" -d $U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -v "ruby /root/tr69/motive_client.rb $parameter"
    fi

    # ssh failed
    rc=$?
    if [ $rc -ne 0 ] ;then
        echo "AT_ERROR : ssh to remote pc failed"
        return 3
    fi

    motive_result=`sed -n '/##########BEGIN result##########/,/##########END result##########/'p $loglog`

    # curl failed
    echo $motive_result | grep -i "Connection Request Failed"
    rc=$?
    if [ $rc -eq 0 ] ;then
        echo "Connection Request Failed"
        return 2
    fi

    # Success
    echo $motive_result | grep -i "Success.*Not Available"
    rc=$?
    if [ $rc -eq 0 ] ;then
        echo "Success -- Not Available"
        return 0
    fi

    # Failure -- Not Availabl
    echo $motive_result | grep -i "Failure.*Not Available"
    rc=$?
    if [ $rc -eq 0 ] ;then
        echo "Failure -- Not Available"
        return 1
    fi

    # other
    return 3
}

parse_cwmp(){
    echo "star parse cwmp"
    echo "filter is : $TMP_FILTER"
    bash $U_PATH_TBIN/tshark_capture.sh -r ${difflog}.cap -R "$TMP_FILTER" -V -o $difflog

    rc=$?
    if [ $rc -ne 0 ] ;then
        echo "AT_ERROR : parse origin capture package"
        exit 1
    fi

    if [ "$1" == "SPV" ] ;then
        echo "SPV do not do cwmp parse"
        exit 0
    fi
    
    echo "exec : $U_PATH_TBIN/parse_cwmp -c $difflog -v $1 -o $outputlog"
    $U_PATH_TBIN/parse_cwmp -c $difflog -v $1 -o $outputlog

    rc=$?
    if [ $rc -eq 0 ] ;then
        echo "end parse cwmp"
        sort $outputlog -o $outputlog
        #exit 0
    else
        echo "AT_ERROR : paser cwmp failed"
        exit 1
    fi
}

if [ -z "$U_CUSTOM_MOTIVE_USERNAME" ] ;then
    U_CUSTOM_MOTIVE_USERNAME=ps_training
fi
if [ -z "$U_CUSTOM_MOTIVE_PASSWORD" ] ;then
    U_CUSTOM_MOTIVE_PASSWORD=actiontec135
fi
if [ -z "$U_CUSTOM_MOTIVE_CLIENT_VER" ] ;then
    U_CUSTOM_MOTIVE_CLIENT_VER=3.0
fi
if [ -z "$U_CUSTOM_MOTIVE_CLIENT_METHOD" ] ;then
    U_CUSTOM_MOTIVE_CLIENT_METHOD=remote_ssh
fi
if [ -z "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" ] ;then
    U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS=10.20.10.225
fi
if [ -z "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" ] ;then
    U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME=root
fi
if [ -z "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" ] ;then
    U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD=premax
fi
if [ -z "$U_CUSTOM_PATH_MOTIVE_DATA_MODEL" ] ;then
    U_CUSTOM_PATH_MOTIVE_DATA_MODEL=$G_SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/data_model
fi
if [ -z "$U_CUSTOM_PATH_SERIAL_TO_ID" ] ;then
    if [ ! -f "$G_SQAROOT/testsuites/$G_CFGVERSION/$U_DUT_TYPE/cfg/.serialNumber2deviceId.cfg" ] ;then
        touch $G_SQAROOT/testsuites/$G_CFGVERSION/$U_DUT_TYPE/cfg/.serialNumber2deviceId.cfg
    fi
    U_CUSTOM_PATH_SERIAL_TO_ID=$G_SQAROOT/testsuites/$G_CFGVERSION/$U_DUT_TYPE/cfg/.serialNumber2deviceId.cfg
fi
if [ -z "$U_CUSTOM_MOTIVE_FAIL_ON_CR_FAILRUE_FLAG" ] ;then
    U_CUSTOM_MOTIVE_FAIL_ON_CR_FAILRUE_FLAG=false
fi

if [ -z "$stepmask" ] ;then
    # do Operation
    stepmask=2
fi

TMP_FILTER="ip.dst==$TMP_MOTIVE_SERVER_IP"

TMP_CAP_FILE="/root/tr.cap"
echo "$U_CUSTOM_MOTIVE_CLIENT_VER" |grep "^1"
rc=$?
if [ $rc -eq 0 ] ;then
    cd ${SQAROOT}/tools/${G_BINVERSION}/tr69
    ruby tr69client.rb $*
    rc=$?
    cd -
    exit $rc
fi


echo "$U_CUSTOM_MOTIVE_CLIENT_VER" |grep "^2"
rc=$?
if [ $rc -eq 0 ] ;then

    echo "$U_CUSTOM_MOTIVE_CLIENT_METHOD" | grep "local"
    rc=$?
    if [ $rc -eq 0 ] ;then
        echo "local motive_client.rb"
        rc=$?
        exit $rc
    fi

    echo "$U_CUSTOM_MOTIVE_CLIENT_METHOD" | grep "remote_ssh"
    rc=$?

    GUID=`date +%H_%M_%S_`$serialnumber"_"

    echo "current GUID is $GUID"

    if [ $rc -eq 0 ] ;then
        echo "remote_ssh motive_client.rb"
        if [ -n "$config" ] ;then
            if [ -f $config ] ;then
                echo "the local RPC file : $config will be stored to /tmp/motive_RPC/$GUID$RPC on remote host ..."
            else
                echo "--| ERROR : RPC file not found , please check the path ... |--"
                exit 1
            fi

            echo "the remote $RPC logs will be stored to /tmp/motive_LOG/$GUID$RPC on remote host ..."

            perl $U_PATH_TBIN/sshcli.pl -t 900 -l "$G_CURRENTLOG" -o "$G_CURRENTLOG/sshcli.log" -d $U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -v "mkdir -p /tmp/motive_RPC/$GUID$RPC 2> /dev/null" -v "mkdir -p /tmp/motive_LOG/$GUID$RPC 2> /dev/null"
            rc=$?
            if [ $rc -ne 0 ] ;then
                echo "--| ERROR : Create directory on remote host failed ... |--"
                exit 1
            fi

            echo "the name of RPC file is : $config"

            RPC_base_name=`basename "$config"`

            echo "the base name of RPC file is : "$RPC_base_name

            remote_file="/tmp/motive_RPC/$GUID$RPC/"$RPC_base_name

            perl $U_PATH_TBIN/scpFile.pl -d "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -src $config -dst $remote_file -s -l $G_CURRENTLOG
            rc=$?
            if [ "$rc" -ne 0 ] ;then
                echo "--| ERROR : copy local RPC file to remote host failed ... |--"
                exit 1
            fi

            parameter="-x $debuglevel -v $RPC -s $serialnumber --username=$U_CUSTOM_MOTIVE_USERNAME --password=$U_CUSTOM_MOTIVE_PASSWORD -c $remote_file"
        elif [ -n "$para" ] ;then
            perl $U_PATH_TBIN/sshcli.pl -l "$G_CURRENTLOG" -o "$G_CURRENTLOG/sshcli.log" -d $U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -v "mkdir -p /tmp/motive_LOG/$GUID$RPC 2> /dev/null"
            parameter="-x $debuglevel -v $RPC -s $serialnumber --username=$U_CUSTOM_MOTIVE_USERNAME --password=$U_CUSTOM_MOTIVE_PASSWORD -p $para"
        else
            echo "--| ERROR : cmust input RPC file or parameter ... |--"
            exit 1
        fi

        if [ -n "$outputlog" ] ;then
            ssh_output_log="/tmp/motive_LOG/$GUID$RPC/"`basename $outputlog`
            echo "the $RPC output log will be : $ssh_output_log"
            parameter="$parameter -o $ssh_output_log"
        fi
        if [ -n "$loglog" ] ;then
            ssh_log_log="/tmp/motive_LOG/$GUID$RPC/"`basename $loglog`
            echo "the $RPC loglog will be : $ssh_log_log"
            parameter="$parameter -l $ssh_log_log"
        fi
        if [ -n "$difflog" ] ;then
            ssh_diff_log="/tmp/motive_LOG/$GUID$RPC/"`basename $difflog`
            echo "the $RPC diff log will be : $ssh_diff_log"
            parameter="$parameter -f $ssh_diff_log"
        fi

        perl $U_PATH_TBIN/sshcli.pl -t 900 -l "$G_CURRENTLOG" -o "$G_CURRENTLOG/sshcli.log" -d $U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -v "ruby /root/tr69/motive_client.rb $parameter"

        if [ -n "$outputlog" ] ;then
            if [ -f "$outputlog" ] ;then
                echo "file is already exist : $outputlog"
            fi
            perl $U_PATH_TBIN/scpFile.pl -d "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -src "$ssh_output_log" -dst "$outputlog" -l $G_CURRENTLOG
            rc=$?
            if [ "$rc" -ne 0 ] ;then
                echo "--| ERROR : copy remote output log to local failed ... |--"
                exit 1
            fi
            sort $outputlog -o $outputlog
        fi

        if [ -n "$loglog" ] ;then
            perl $U_PATH_TBIN/scpFile.pl -d "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -src "$ssh_log_log" -dst "$loglog" -l $G_CURRENTLOG
            rc=$?
            if [ "$rc" -ne 0 ] ;then
                echo "--| ERROR : copy remote ruby log to local failed ... |--"
                exit 1
            fi
        fi

        if [ -n "$difflog" ] ;then
            perl $U_PATH_TBIN/scpFile.pl -d "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -src "$ssh_diff_log" -dst "$difflog" -l $G_CURRENTLOG
            rc=$?
            if [ "$rc" -ne 0 ] ;then
                echo "--| ERROR : copy remote communication log to local failed ... |--"
                exit 1
            fi
        fi
        exit 0
    fi
    exit 1
fi

GUID=`date +%H_%M_%S_`
echo "$U_CUSTOM_MOTIVE_CLIENT_VER" |grep -e "^3" -e "^4"
rc=$?
if [ $rc -eq 0 ] ;then
    echo "$U_CUSTOM_MOTIVE_CLIENT_METHOD" | grep "local"
    rc=$?
    if [ $rc -eq 0 ] ;then
        echo "local motive_client.rb"
        rc=$?
        exit $rc
    fi

    echo "$U_CUSTOM_MOTIVE_CLIENT_METHOD" | grep "remote_ssh"
    rc=$?

    if [ $rc -eq 0 ] ;then
        echo "Execute motive_client.rb by remote"
        if [ -z "$stepmask" ] ;then
            echo "AT_ERROR : You must set stepmask! -m"
            exit 1
        fi

        if [ -z "$loglog" ] ;then
            #echo "You must set the ruby runtime log! -l"
            loglog=$G_CURRENTLOG/${GUID}tr69_ruby_log.log
        fi

        if [ -z "$serialnumber" ] ;then
            echo "AT_ERROR : You must set device serial number! -s"
            exit 1
        fi

        if [ -z "$outputlog" ] ;then
            echo "AT_ERROR : You must set output log! -o"
            exit 1
        fi

        if [ ! -f "$U_CUSTOM_PATH_SERIAL_TO_ID" ] ;then
            echo "You did not creat file:$U_CUSTOM_PATH_SERIAL_TO_ID"
            echo "creat file:$U_CUSTOM_PATH_SERIAL_TO_ID ..."
            touch $U_CUSTOM_PATH_SERIAL_TO_ID
        fi

        if [ $stepmask -eq 1 ] ;then
            echo "stepmask:$stepmask"
            echo "find device id and lock device"

            if [ "$U_CUSTOM_MOTIVE_CLIENT_VER" == "4.0" ] ;then
                echo "== Current Motive client version is : 4.0"
                #if [ -z "$U_DUT_MOTIVE_DEVICE_ID" ] ;then
                #    echo "== Not define U_DUT_MOTIVE_DEVICE_ID"
                #    parameter="-x $debuglevel -m $stepmask -s $serialnumber --username=$U_CUSTOM_MOTIVE_USERNAME --password=$U_CUSTOM_MOTIVE_PASSWORD"
                #    #exit 1
                #else
                #    device_id="$U_DUT_MOTIVE_DEVICE_ID"
                #    parameter="-x $debuglevel -m $stepmask -i $device_id --username=$U_CUSTOM_MOTIVE_USERNAME --password=$U_CUSTOM_MOTIVE_PASSWORD"
                #fi
                   
                parameter="-x $debuglevel -m $stepmask -s $serialnumber --username=$U_CUSTOM_MOTIVE_USERNAME --password=$U_CUSTOM_MOTIVE_PASSWORD"
                 
                start_capture
                run_motive_client
                #clicmd -o "$loglog" -d "$U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS" -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -v "ruby /root/automation/tools/2.0/tr69/v4/motive_client.rb $parameter"
                stop_capture
                #fi
                
                
                if [ -f "$loglog" ] ;then
                    device_var_id=`sed -n '/##########BEGIN result##########/,/##########END result##########/'p $loglog | grep "U_DUT_MOTIVE_DEVICE_ID=[[:alnum:]][[:alnum:]]*"`
                    if [ -z "$device_var_id" ] ;then
                        error_msg=`sed -n '/##########BEGIN result##########/ {n;p;}' $loglog`
                        echo "AT_ERROR : $error_msg"
                        exit 1
                    else
                        echo $device_var_id >> $outputlog
                    fi
                else
                    echo "AT_ERROR : No such file: $loglog"
                    exit 1
                fi
            
                device_id=`echo $device_var_id | awk -F '=' '{print $2}'`


            elif [ "$U_CUSTOM_MOTIVE_CLIENT_VER" == "3.0" ] ;then


                parameter="-x $debuglevel -m $stepmask -s $serialnumber --username=$U_CUSTOM_MOTIVE_USERNAME --password=$U_CUSTOM_MOTIVE_PASSWORD"

                #            perl $U_PATH_TBIN/sshcli.pl -t 600 -l "$G_CURRENTLOG" -o "$loglog" -d $U_CUSTOM_MOTIVE_SSH_SERVER_IPADDRESS -u "$U_CUSTOM_MOTIVE_SSH_SERVER_USERNAME" -p "$U_CUSTOM_MOTIVE_SSH_SERVER_PASSWORD" -v "ruby /root/tr69/motive_client.rb $parameter"
                #
                #            rc=$?
                #            if [ $rc -ne 0 ] ;then
                #                echo "AT_ERROR : ssh to remote pc failed!"
                #                exit 1
                #            fi

                start_capture

                run_motive_client

                stop_capture

                if [ -f "$loglog" ] ;then
                    device_var_id=`sed -n '/##########BEGIN result##########/,/##########END result##########/'p $loglog | grep "U_DUT_MOTIVE_DEVICE_ID=[[:alnum:]][[:alnum:]]*"`
                    if [ -z "$device_var_id" ] ;then
                        error_msg=`sed -n '/##########BEGIN result##########/ {n;p;}' $loglog`
                        echo "AT_ERROR : $error_msg"
                        exit 1
                    else
                        echo $device_var_id >> $outputlog
                    fi
                else
                    echo "AT_ERROR : No such file: $loglog"
                    exit 1
                fi
            
                device_id=`echo $device_var_id | awk -F '=' '{print $2}'`
                
            fi
            sed -i "/$serialnumber/d" $U_CUSTOM_PATH_SERIAL_TO_ID
            echo "update $U_CUSTOM_PATH_SERIAL_TO_ID file: set serial number: $serialnumber --> device id: $device_id"
            echo " sed -i -e \"$ a$serialnumber $device_id\" $U_CUSTOM_PATH_SERIAL_TO_ID "
            echo "$serialnumber $device_id" >> $U_CUSTOM_PATH_SERIAL_TO_ID
            exit 0

        else
            echo "stepmask:$stepmask"
            echo "do Operation"

            if [ -z "$RPC" ] ;then
                echo "AT_ERROR : Operation type must be set!"
                exit 1
            fi

            echo "do operation : $RPC"

            if [ -z "$difflog" ] ;then
                #echo "You must set SOAP file! -f"
                #exit 1
                difflog=$G_CURRENTLOG/${GUID}tr69_capture_soap.log
            fi

            if [ ! -f "$U_CUSTOM_PATH_MOTIVE_DATA_MODEL" ] ;then
                echo "AT_ERROR : No such file: $U_CUSTOM_PATH_MOTIVE_DATA_MODEL"
                exit 1
            fi

            if [ -z "$TMP_MOTIVE_SERVER_IP" ] ;then
                echo "AT_ERROR : You must set motive server ip"
                exit 1
            else
                #TMP_MOTIVE_SERVER_IP=`echo $TMP_MOTIVE_SERVER_IP | sed 's/dst/addr/g'`
                TMP_FILTER="ip.addr==$TMP_MOTIVE_SERVER_IP"
            fi

            echo "Fail On CR Failrue flag : "
            echo $U_CUSTOM_MOTIVE_FAIL_ON_CR_FAILRUE_FLAG | grep -i "^true$"
            rc=$?
            echo $U_CUSTOM_MOTIVE_FAIL_ON_CR_FAILRUE_FLAG | grep -i "^false$"
            rc2=$?

            if [ $rc -ne 0 -a $rc2 -ne 0 ] ;then
                echo "AT_ERROR : You must set U_CUSTOM_MOTIVE_FAIL_ON_CR_FAILRUE_FLAG : true or false"
                exit 1
            fi

            if [ -z $timeout ] ;then
                timeout=300
               if [ $U_DUT_TYPE == "BHR4_OpenWRT" ] ;then
                echo "change timeout for bhr4 60s"
                timeout=60
               fi
            fi

            refresh_cwmp_info_flag=1

            for (( i=1; i<=4; i=i+1 ))
            do
                combine_curl_command

                combine_ruby_parameter

                start_capture

                run_motive_client

                rmc_flag=$?
                # return value
                # 0 : parse capture -- Success
                # 1 : parse capture -- Failure
                # 2 : retry
                # 3 : not parse capture

                stop_capture

                case $rmc_flag in
                    0)
                        echo "parse capture -- Success"
                        break
                        ;;
                    1)
                        echo "parse capture -- Failure"
                        break
                        ;;
                    2)
                        echo "retry"
                        refresh_cwmp_info_flag=0
                        ;;
                    3)
                        echo "not parse capture"
                        break
                        ;;
                    *)
                        echo "AT_ERROR : bad run_motive_client return value"
                        exit 1
                        ;;
                esac
            done

            if [ "$rmc_flag" == "0" ] ;then
                parse_cwmp $RPC
                exit 0
            elif [ "$rmc_flag" == "1" ] ;then
                parse_cwmp FAULT
                exit 1
            else
                motive_result=`sed -n '/##########BEGIN result##########/ {n;p;}' $loglog`
                echo "AT_ERROR : $motive_result"
            fi
        fi
    fi
fi

echo "$U_CUSTOM_MOTIVE_CLIENT_VER" |grep -e "^5"
rc=$?
if [ $rc -eq 0 ] ;then
    python $SQAROOT/tools/2.0/common/launchTr69_jacs.py $*
    exit $?
fi

exit 1
