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
TV2KH()
{
    #pppUserName[^&]sed "s#vlanMuxId=[^&]*#vlanMuxId=$U_DUT_CUSTOM_WAN_VLAN_ID#g" |*
    
    cat $file |
    sed "s#vlanMuxId=[^ |&]*#vlanMuxId=-1#g" |
    sed "s#wanIpAddress=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#wanIpAddress=$U_DUT_CUSTOM_STATIC_WAN_IP#g" |
    sed "s#wanSubnetMask=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#wanSubnetMask=$U_DUT_CUSTOM_STATIC_WAN_NETMASK#g" |
    sed "s#wanIntfGateway=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#wanIntfGateway=$U_DUT_CUSTOM_STATIC_WAN_DEF_GW#g" |
    sed "s#dnsPrimary=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#dnsPrimary=$U_DUT_CUSTOM_STATIC_WAN_DNS1#g" |
    sed "s#dnsSecondary=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#dnsSecondary=$U_DUT_CUSTOM_STATIC_WAN_DNS2#g" |
    tee $output
    cat $output |
    tee $file
}
Q2K()
{
    #pppUserName[^&]*
    
    cat $file |
    sed "s#vlanMuxId=[^&]*#vlanMuxId=$U_DUT_CUSTOM_WAN_VLAN_ID#g" |
    sed "s#wanIpAddress=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#wanIpAddress=$U_DUT_CUSTOM_STATIC_WAN_IP#g" |
    sed "s#wanSubnetMask=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#wanSubnetMask=$U_DUT_CUSTOM_STATIC_WAN_NETMASK#g" |
    sed "s#wanIntfGateway=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#wanIntfGateway=$U_DUT_CUSTOM_STATIC_WAN_DEF_GW#g" |
    sed "s#dnsPrimary=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#dnsPrimary=$U_DUT_CUSTOM_STATIC_WAN_DNS1#g" |
    sed "s#dnsSecondary=[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}#dnsSecondary=$U_DUT_CUSTOM_STATIC_WAN_DNS2#g" |
    tee $output
    cat $output |
    tee $file
}
$U_DUT_TYPE
