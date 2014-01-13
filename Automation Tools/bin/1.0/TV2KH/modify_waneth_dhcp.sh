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
    #pppUserName[^&]*
    
       # cat $file |
       # sed "s#mac=[^&]*#mac=$TMP_HOST_MAC0_2_0#g" |
       # sed "s#username=[^&]*#username=$TMP_HOST_MAC0_2_0#g" |
       # sed "s#start_time=[^&]*#start_time=`expr $U_CUSTOM_LOCALTIME + 1`#g" |
       # sed "s#end_time=[^&]*#end_time=`expr $U_CUSTOM_LOCALTIME + 3`#g" |
       # tee $output
        
       cat $file |
       sed "s#vlanMuxId=[^ |&]*#vlanMuxId=-1#g" |
       tee $output
       cat $output |
       tee $file
}
Q2K()
{
    #pppUserName[^&]*
    
       # cat $file |
       # sed "s#vlanMuxId=[^&]*#vlanMuxId=$U_DUT_CUSTOM_WAN_VLAN_ID#g" |
       # sed "s#username=[^&]*#username=$TMP_HOST_MAC0_2_0#g" |
       # sed "s#start_time=[^&]*#start_time=`expr $U_CUSTOM_LOCALTIME + 1`#g" |
       # sed "s#end_time=[^&]*#end_time=`expr $U_CUSTOM_LOCALTIME + 3`#g" |
       # tee $output
        
       cat $file |
       sed "s#vlanMuxId=[^&]*#vlanMuxId=$U_DUT_CUSTOM_WAN_VLAN_ID#g" |
       tee $output
       cat $output |
       tee $file
}
$U_DUT_TYPE
