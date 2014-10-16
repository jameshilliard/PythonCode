#!/bin/bash
usage="modify_waneth_dhcp.sh -f $U_PATH_SANITYCFG/B-Q2K-BA.ASC-001-C001 -l $G_CURRENTLOG/B-Q2K-BA.ASC-001-C001"
while [ -n "$1" ];
do
    case "$1" in
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
Q2K()
{
    cat $file |
    sed "s#vlanMuxId=[^&]*#vlanMuxId=$U_DUT_CUSTOM_WAN_VLAN_ID#g" |
    sed "s#pppUserName=[a-z0-9A-Z]\{1,12\}#pppUserName=$U_DUT_CUSTOM_PPP_USER#g" |
    sed "s#pppPassword=[a-z0-9A-Z]\{1,12\}#pppPassword=$U_DUT_CUSTOM_PPP_PWD#g" |
    tee $output
    cat $output |
    tee $file
}
$U_DUT_TYPE
