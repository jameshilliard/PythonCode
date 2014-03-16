#!/bin/bash
usage="modify_portforw.sh -n add -f $U_PATH_SANITYCFG/B-Q2K-BA.ASC-001-C001 -l $G_CURRENTLOG/B-Q2K-BA.ASC-001-C001"
while [ -n "$1" ];
do
    case "$1" in
    -t)
        ptype=$2
        echo "port type : ${ptype}"
        shift 2
        ;;
    -n)
        opt=$2
        echo "operation : ${opt}"
        shift 2
        ;;
    -f)
        file=$2
        echo "file : ${file}"
        shift 2
        ;;
    -l)
        output=$2
        echo "output : ${output}"
        shift 2
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done
TV2KH()
{
    #pppUserName[^&]*
    if [ $opt == "add" ]; then
        cat $file |
        sed "s#srvAddr=[^&]*#srvAddr=$G_HOST_TIP0_1_0#g" |
        sed "s#eStart=[0-9]*#eStart=$U_CUSTOM_FW_OUT_PORT#g" |
        sed "s#eEnd=[0-9]*#eEnd=$U_CUSTOM_FW_OUT_PORT#g" |
        sed "s#iStart=[0-9]*#iStart=$U_CUSTOM_FW_OUT_PORT#g" |
        sed "s#iEnd=[0-9]*#iEnd=$U_CUSTOM_FW_OUT_PORT#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file |
        sed "s#rmLst=[^&]*#rmLst=$G_HOST_TIP0_1_0\|$U_CUSTOM_FW_OUT_PORT\|$U_CUSTOM_FW_OUT_PORT\|$ptype\|$U_CUSTOM_FW_OUT_PORT\|$U_CUSTOM_FW_OUT_PORT\|0.0.0.0#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
Q2K()
{
    #pppUserName[^&]*
    if [ $opt == "add" ]; then
        cat $file |
        sed "s#srvAddr=[^&]*#srvAddr=$G_HOST_TIP0_1_0#g" |
        sed "s#eStart=[0-9]*#eStart=$U_CUSTOM_FW_OUT_PORT#g" |
        sed "s#eEnd=[0-9]*#eEnd=$U_CUSTOM_FW_OUT_PORT#g" |
        sed "s#iStart=[0-9]*#iStart=$U_CUSTOM_FW_OUT_PORT#g" |
        sed "s#iEnd=[0-9]*#iEnd=$U_CUSTOM_FW_OUT_PORT#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        #&rmLst=192.168.0.200%7C8888%7C8888%7CTCP%7C8888%7C8888%7C0.0.0.0&
        cat $file |
        sed "s#rmLst=[^&]*#rmLst=$G_HOST_TIP0_1_0\%7C$U_CUSTOM_FW_OUT_PORT\%7C$U_CUSTOM_FW_OUT_PORT\%7C$ptype\%7C$U_CUSTOM_FW_OUT_PORT\%7C$U_CUSTOM_FW_OUT_PORT\%7C0.0.0.0#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
$U_DUT_TYPE
