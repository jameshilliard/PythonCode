#!/bin/bash
usage="modify_ASC_rule.sh -n add -f $U_PATH_SANITYCFG/B-Q2K-BA.ASC-001-C001 -l $G_CURRENTLOG/B-Q2K-BA.ASC-001-C001"
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
        cat $file |
        sed "s#mac=[^&]*#mac=$TMP_HOST_MAC0_2_0#g" |
        sed "s#username=[^&]*#username=$TMP_HOST_MAC0_2_0#g" |
        sed "s#start_time=[^&]*#start_time=`expr $U_CUSTOM_LOCALTIME + 1`#g" |
        sed "s#end_time=[0-9]\{1,4\}#end_time=`expr $U_CUSTOM_LOCALTIME + 3`#g" |
        sed "s#days=[0-9]\{1,3\}#days=127#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file |
        sed "s#rmLst=[^ |&]*#rmLst=$TMP_HOST_MAC0_2_0#g" |
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
        sed "s#mac=[^&]*#mac=$TMP_HOST_MAC0_2_0#g" |
        sed "s#username=[^&]*#username=$TMP_HOST_MAC0_2_0#g" |
        sed "s#start_time=[^&]*#start_time=`expr $U_CUSTOM_LOCALTIME + 1`#g" |
        sed "s#end_time=[0-9]\{1,4\}#end_time=`expr $U_CUSTOM_LOCALTIME + 3`#g" |
        sed "s#days=[0-9]\{1,3\}#days=127#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file |
        sed "s#rmLst=[^ |&]*#rmLst=$TMP_HOST_MAC0_2_0#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
$U_DUT_TYPE
