#!/bin/bash
# Program
#      This tool is used to parse cwmp exist or not!
#
#
# History
#     DATE    |   REV   |   AUTH   |    INFO        |
#  2012/07/10 |  1.0.0  |  Prince  | Inital Version |

VER="1.0.0"
echo "$0 version : ${VER}"

USAGE()
{
    cat <<usge
EXAMPLES
    bash $0 [--test] -c cap.log -v Inform -o Inform.log [-n] 

OPTIONS
    -c : source file
    -v : operation type
    -o : output log    
    -l : output log path,just the path!
    -n : Negative mode

NOTES
    1.if you DON'T run this script in testcase , please put [--test] option in front of other options
    2.the [-l] and [-o] parameter can be omitted,in that case,the output log will be in \$G_CURRENTLOG
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
        -c)
	        srclog=$2
	        cecho "source file : $srclog"
	        shift 2
	        ;;
        -v)
            operation=$2
            cecho "Operation Type : $operation"
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
else
    negflag=1
    cecho "Test Mode : Negative Test!"
fi

if [ -z "${outlog}" ];then
    outlog=output.log
    cecho "The output log : $outlog"
fi

if [ -z "${logpath}" ];then
    logpath=${G_CURRENTLOG}
    cecho "The output log path : ${logpath}"
fi

if [ -z "$srclog" ];then
    cecho fail "source file can not be null!"
    USAGE
    exit 1
fi

if [ -z "$operation" ];then
    cecho fail "operation type can not be null!"
    USAGE
    exit 1
fi
$U_PATH_TBIN/parse_cwmp -c $logpath/$srclog -v $operation -o $logpath/$outlog
rc=$?

if [ "$negflag" == "0" ];then
    cecho "Test Mode : Positive Test!"
    if [ "$rc" == "0" ];then
        cecho pass "Positive Test PASS!"
        exit 0
    else
        cecho fail "Positive Test Fail!"
        exit 1
    fi
elif [ "$negflag" == "1" ];then
    cecho "Test Mode : Negative Test!"
    if [ "$rc" != "0" ];then
        cecho pass "Negative Test PASS!"
        exit 0
    else
        cecho fail "Negative Test Fail!"
        exit 1
    fi
fi
