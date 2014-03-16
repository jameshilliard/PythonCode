#!/bin/bash
# Program
#      This tool is used to check ping result by parse /var/ping.log which gotten by telnet
#
#
# History
#     DATE    |   REV   |   AUTH   |    INFO        |
#  2012/06/7  |  1.0.0  |  Prince  | Inital Version |

VER="1.0.0"
echo "$0 version : ${VER}"

USAGE()
{
    cat <<usge
USAGE
    bash $0 [--test] -t <ping or trace> [-n]

OPTIONS
    -t : ping or trace
    -o : output log    
    -l : output log path,just the path!
    -n : Negative mode
    -b : br0 ip
    -u : telnet user name
    -p : telnet password
    -port : telnet port
NOTES
    1.if you DON'T run this script in testcase , please put [--test] option in front of other options
    2.the [-l] and [-o] parameter can be omitted,in that case,the output log will be in \$G_CURRENTLOG

EXAMPLES
    bash $0 [--test] -t <ping or trace> [-n]
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
    cecho pass "Create output log!"
    if [ $? -gt 0 ];then
        curlogfile="${crefile}_1"
    else
        index=`ls ${logpath}/${crefile}*|wc -l`
        let curindex=${index}+1
        curlogfile="${crefile}_${curindex}"
    fi
    cecho pass "curlogfile=${curlogfile}"
}

function dutping(){
    cecho pass "Telnet to DUT and get ping.log"
    createlog dut_ping.log
    if [ "$U_DUT_TYPE" == "" ];then
        cecho fail "DUT TYPE is None,Please define it!\$U_DUT_TYPE=$U_DUT_TYPE"
        cecho fail "${dut_type_list}"&& exit 1
    elif [ "$U_DUT_TYPE" == "CTLC2KA" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /var/ping6.log\""
       perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /var/ping6.log"
           
    elif [ "$U_DUT_TYPE" == "BAR1KH" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /var/ping.log\""
        perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /var/ping.log"

    elif [ "$U_DUT_TYPE" == "TV2KH" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /var/ping.log\""
        perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /var/ping.log"
    
    elif [ "$U_DUT_TYPE" == "PK5K1A" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /tmp/ping6.log\""
        dut_ping_result=`perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /tmp/ping6.log"`
            
    elif [ "$U_DUT_TYPE" == "BHR2" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"system shell\" -v \"cat /var/ping.log\""
        perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system shell" -v "cat /var/ping.log"
            
    elif [ "$U_DUT_TYPE" == "FT" ];then
         echo "perl $U_PATH_TBIN/clicfg.pl  -l ${logpath} -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cat /var/ping.log\" -t  ${curlogfile} -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
        perl $U_PATH_TBIN/clicfg.pl  -l ${logpath} -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cat /var/ping.log" -t  ${curlogfile} -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
            
    else
        cecho fail "Unknow DUT TYPE,U_DUT_TYPE=$U_DUT_TYPE"
        cecho fail "${dut_type_list}"&& exit 1
    fi
    if [ $? != 0 ]; then
           cecho fail "AT_ERROR : Failed to execute DUTCmd.pl" && exit 1
    fi

}

function duttrace(){
    cecho pass "Telnet to DUT and get trace.log"
    createlog dut_trace.log
    if [ "$U_DUT_TYPE" == "" ];then
        cecho fail "DUT TYPE is None,Please define it!\$U_DUT_TYPE=$U_DUT_TYPE"
        cecho fail "${dut_type_list}"&& exit 1
    elif [ "$U_DUT_TYPE" == "CTLC2KA" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /var/trace.log\""
       perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /var/trace.log"
    
    elif [ "$U_DUT_TYPE" == "BAR1KH" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /var/trace.log\""
        perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /var/trace.log"
    
    elif [ "$U_DUT_TYPE" == "TV2KH" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /var/trace.log\""
        perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /var/trace.log"
    
    elif [ "$U_DUT_TYPE" == "PK5K1A" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v \"sh\" -v \"cat /var/trace.log\""
        dut_trace_result=`perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -port $U_DUT_TELNET_PORT -v "sh" -v "cat /var/trace.log"`
    
    elif [ "$U_DUT_TYPE" == "BHR2" ];then
         echo "perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v \"system shell\" -v \"cat /var/trace.log\""
        perl $U_PATH_TBIN/DUTCmd.pl -o ${curlogfile} -l ${logpath} -d $G_PROD_IP_BR0_0_0 -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -v "system shell" -v "cat /var/trace.log"
    
    elif [ "$U_DUT_TYPE" == "FT" ];then
         echo "perl $U_PATH_TBIN/clicfg.pl  -l ${logpath} -d $G_PROD_IP_BR0_0_0 -i 23 -m \"#\" -v \"cat /var/trace.log\" -t  ${curlogfile} -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD"
        perl $U_PATH_TBIN/clicfg.pl  -l ${logpath} -d $G_PROD_IP_BR0_0_0 -i 23 -m "#" -v "cat /var/trace.log" -t  ${curlogfile} -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD
    
    else
        cecho fail "Unknow DUT TYPE,U_DUT_TYPE=$U_DUT_TYPE"
        cecho fail "${dut_type_list}"&& exit 1
    fi
    if [ $? != 0 ]; then
           cecho fail "AT_ERROR : Failed to execute DUTCmd.pl" && exit 1
    fi

    
}

function parseping(){
cecho pass "Start to parse ping.log"
if [ ! -f ${logpath}/${curlogfile} ];then
    cecho fail "No exist dest file,\${curlogfile}=${curlogfile}!"&& exit 1
fi
declare -i pingResult=`cat ${logpath}/${curlogfile} | grep "packet loss" | awk '{print $4}'`
cecho pass "received packet "$pingResult
if [ "${negflag}" == "0" ];then
    cecho pass "Test Mode : Positive Test!"

    if [ $pingResult -gt 0 ]; then
        cecho pass "ping result : Success!"
        cecho pass "Positive Test PASS!"
        exit 0
    else
        cecho fail "ping result : Fail!"
        cecho fail "Positive Test Fail!"
        exit 1
    fi
elif [ "${negflag}" == "1" ];then
    cecho pass "Test Mode : Negative Test!"

    if [ $pingResult -gt 0 ]; then
        cecho fail "ping result : Success!"
        cecho fail "Neagtive Test Fail!"
        exit 1
    else
        cecho pass "ping result : Fail!"
        cecho pass "Neagtive Test PASS!"
        exit 0
    fi

fi

} 

function parsetrace(){
    cecho pass "Start to parse tarce.log"
}

while [ -n "$1" ]
do
    case "$1" in
        --test)
            cecho "Test Mode : Test Mode!"
            testflag=1
            export U_PATH_TBIN=.
            export G_CURRENTLOG=.
            export U_DUT_TYPE=TV2KH
            export G_PROD_IP_BR0_0_0=192.168.1.254
            export U_DUT_TELNET_USER=admin
            export U_DUT_TELNET_PWD=1
            export U_DUT_TELNET_PORT=23
            shift
            ;;
        -t)
            optype=$2
            cecho "check type : $optype"
            shift 2
            ;;
        -d)
            U_DUT_TYPE=$2
            cecho "U_DUT_TYPE=$2"
            shift 2
            ;;
        -b)
	        export G_PROD_IP_BR0_0_0=$2
	        cecho "G_PROD_IP_BR0_0_0 : $G_PROD_IP_BR0_0_0"
	        shift 2
	        ;;
    	-u)
            export U_DUT_TELNET_USER=$2
	        cecho "telnet username : $U_DUT_TELNET_USER"
	        shift 2
	        ;;
	    -p)
	        export U_DUT_TELNET_PWD=$2
	        cecho "telnet pwd : $U_DUT_TELNET_PWD"
	        shift 2
	        ;;
	    -port)
	        export U_DUT_TELNET_PORT=$2
	        cecho "telent port : $U_DUT_TELNET_PORT"
	        shift 2
	        ;;
         -o)
            outlog=$2
            cecho "output log : $outlog"
            shift 2
            ;;
        -l)
            export logpath=$2
            cecho "output log path : $logpath"
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

dut_type_list="Current DUT TYPE : BAR1KH,BHR2,C1KA,CTLC1KA,CTLC2KA,FT,PK5K1A,Q1K,Q2KH,SV1KH,TV1KH,TV2KH"

if [ -z "${testflag}" ];then
    testflag=0
    cecho "testflag = $testflag"
fi

if [ -z "${outlog}" ];then
    outlog=check_ping_traceroute.log
    cecho "The output log : $outlog"
fi

if [ -z "${logpath}" ];then
    logpath=${G_CURRENTLOG}
    cecho "The output log path : ${logpath}"
fi

if [ -z "${negflag}" ];then
    negflag=0
    cecho "Test Mode : Postive Test!"
fi

if [ -z "$U_DUT_TYPE" ];then
    cecho fail "Please define U_DUT_TYPE!"&& exit 1
else
    cecho "U_DUT_TYPE=$U_DUT_TYPE"
fi

if [ "$optype" == "" ];then
    cecho fail "Please define 'ping' or 'trace'!" && exit 1
elif [ "$optype" == "ping" ];then
    dutping
    parseping    
elif [ "$optype" == "trace" ];then
    duttrace
    parsetrace
elif [ "$optype" != "ping" -o "$optype" != "trace" ];then
    cecho fail "\$optype is $optype,it must be 'ping' or 'trace'!" && exit 1
fi



