#!/bin/bash
usage="modify_dmz.sh -n add -f $U_PATH_SANITYCFG/B-Q2K-BA.ASC-001-C001 -l $G_CURRENTLOG/B-Q2K-BA.ASC-001-C001"
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
        sed "s#address=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#address=$G_HOST_TIP0_1_0#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file |
        sed "s#address=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#address=$G_HOST_TIP0_1_0#g" |
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
        sed "s#address=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#address=$G_HOST_TIP0_1_0#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file |
        sed "s#address=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#address=$G_HOST_TIP0_1_0#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
$U_DUT_TYPE
