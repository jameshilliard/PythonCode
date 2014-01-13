#!/bin/bash
usage="modify_sbl_ftp.sh -n add -f $U_PATH_SANITYCFG/B-Q2K-BA.ASC-001-C001 -l $G_CURRENTLOG/B-Q2K-BA.ASC-001-C001"
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
        sed "s#remGuiTimeout=[^&]*#remGuiTimeout=$U_CUSTOM_RGU_DURATION#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file|
        sed "s#remGuiTimeout=[^&]*#remGuiTimeout=$U_CUSTOM_RGU_DURATION#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
Q2K()
{
    #pppUserName[^&]*
    if [ $opt == "add" ]; then
        cat $file|
        sed "s#remGuiTimeout=[^&]*#remGuiTimeout=$U_CUSTOM_RGU_DURATION#g" |
        tee $output
        cat $output |
        tee $file
    elif [ $opt == "remove" ]; then
        cat $file|
        sed "s#remGuiTimeout=[^&]*#remGuiTimeout=$U_CUSTOM_RGU_DURATION#g" |
        tee $output
        cat $output |
        tee $file
    fi
    
}
$U_DUT_TYPE
