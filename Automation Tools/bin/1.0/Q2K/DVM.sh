#!/bin/bash
usage="DVM.sh -t <dut ip> -u <dut username> -p <dut password> -d <html folder>"
while [ -n "$1" ];
do
    case "$1" in

    -t)
        dutip=$2
        echo "dut address : ${dutip}"
        shift 2
        ;;
    -u)
        usrname=$2
        echo "dut username : ${usrname}"
        shift 2
        ;;
    -p)
        psw=$2
        echo "dut password : ${psw}"
        shift 2
        ;;
    -d)
        html=$2
        echo "html folder : ${html}"
        shift 2
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done

swversion=`tclsh DUTcmd.tcl $dutip $usrname $psw swversion |grep -A 1 '> swversion' |tail -1`
foo=$html/$swversion
echo $foo
ls $html
#/root/automation/platform/1.0/Q2K/html/QAB001-33.00L.11a
if [  -f $foo ]; then
    echo "found it"
    #go and check if the blacklist exists,if so,skip to black-white-tst step,if not,go and fetch the html files then check if there is an older version folder there,if not,then pass on to gflaunch,if so,do compare_dir_files and make a blacklist,then do black-white-tst step
else
    echo "sorry"
fi
