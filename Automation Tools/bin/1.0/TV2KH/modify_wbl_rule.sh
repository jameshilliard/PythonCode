#!/bin/bash
usage="modify_wbl_rule.sh -n add -f $U_PATH_SANITYCFG/B-Q2K-BA.ASC-001-C001 -l $G_CURRENTLOG/B-Q2K-BA.ASC-001-C001"
while [ -n "$1" ];
do
    case "$1" in

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
        cat $file|
        sed "s#www.yahoo.com#$U_CUSTOM_WAN_HOST2#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file|
        sed "s#www.yahoo.com#$U_CUSTOM_WAN_HOST2#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
Q2K()
{
    #pppUserName[^&]*
    #TodUrlAdd=www.google.com&Lan_IP=192.168.0.225&Lan_PcName=192.168.0.225
    if [ $opt == "add" ]; then
        cat $file|
        sed "s#TodUrlAdd=[^&]*#TodUrlAdd=$U_CUSTOM_WAN_HOST2#g" |
        sed "s#Lan_IP=[^&]*#Lan_IP=$G_HOST_TIP0_2_0#g" |
        sed "s#Lan_PcName=[^&]*#Lan_PcName=$G_HOST_TIP0_2_0#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        #rmLstUrl=www.google.com&rmLstIp=192.168.0.225&
        cat $file|
        sed "s#rmLstUrl=[^&]*#rmLstUrl=$U_CUSTOM_WAN_HOST2#g" |
        sed "s#rmLstIp=[^&]*#rmLstIp=$G_HOST_TIP0_2_0#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
$U_DUT_TYPE
