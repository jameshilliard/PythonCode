#!/bin/bash
usage="modify_ASC_rule.sh -mac MAC"
while [ -n "$1" ];
do
    case "$1" in

    -mac)
        mac=$2
        echo "mac : ${mac}"
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
    echo $mac  |
    #sed 's/:/%3A/g' |
    awk '{print "TMP_HOST_MAC0_2_0=" $1}'
}
Q2K()
{
    echo $mac  |
    sed 's/:/%3A/g' |
    awk '{print "TMP_HOST_MAC0_2_0=" $1}'
}
$U_DUT_TYPE
