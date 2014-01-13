#!/bin/bash - 
#===============================================================================
#
#          FILE: create_start_server_config_file.sh
# 
#         USAGE: ./create_start_server_config_file.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Andy (aliu@actiontec.com), 
#  ORGANIZATION: 
#       CREATED: 02/06/2013
#      REVISION: 1.0.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error
config_file_path="$G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/config_net.conf"

main_common(){

if [ -z "$G_HOST_IP0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IP0"
    exit 1
elif [ -z "$G_HOST_IP1" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IP1"
    exit 1
elif [ -z "$G_HOST_IF1_0_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IF1_0_0"
    exit 1
elif [ -z "$G_HOST_IF1_1_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IF1_1_0"
    exit 1
elif [ -z "$G_HOST_IF1_2_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IF1_2_0"
    exit 1
elif [ -z "$U_CUSTOM_VLANETH" ] ;then
    echo "AT_ERROR : Not define variable U_CUSTOM_VLANETH"
    exit 1
elif [ -z "$G_HOST_TIP1_1_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_TIP1_1_0"
    exit 1
elif [ -z "$G_HOST_GW1_1_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_GW1_1_0"
    exit 1
fi

if [ -f "$config_file_path" ] ;then
    mv $config_file_path $config_file_path.bak
fi

echo "# The configuration file for setting WAN PC
#
# The management IP address for LAN PC
# if set to \"no\", will not do nfs
LAN_MNGMT_IP        $G_HOST_IP0

# The management IP address for WAN PC
WAN_MNGMT_IP        $G_HOST_IP1

# Set the NIC which is used for magagemet
WAN_MNGMT_IF        $G_HOST_IF1_0_0

# Set the NIC that connect to internet
# DCHP mode: NIC
# WAN_NETWORK_IF  eth1
# Manual mode : NIC:IP:Gateway
# WAN_NETWORK_IF  eth1:172.16.10.62:172.16.10.254
WAN_NETWORK_IF      $G_HOST_IF1_1_0:$G_HOST_TIP1_1_0:$G_HOST_GW1_1_0

# Set the NIC which is used for servers
WAN_SERVER_IF       $G_HOST_IF1_2_0

# Set the vlan list which is start on server interface
# Set to no if no vlan.
# eg. 
# VLAN_LIST         vlan1[,vlan2 ...]
VLAN_LIST           $U_CUSTOM_VLANETH

# whether need to reconfig server
reconfig            1">$config_file_path
}

main_fc18(){
if [ -z "$G_HOST_IP0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IP0"
    exit 1
elif [ -z "$G_HOST_IP1" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IP1"
    exit 1
elif [ -z "$G_HOST_IF1_0_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IF1_0_0"
    exit 1
elif [ -z "$G_HOST_IF1_1_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IF1_1_0"
    exit 1
elif [ -z "$G_HOST_IF1_2_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_IF1_2_0"
    exit 1
elif [ -z "$U_CUSTOM_VLANETH" ] ;then
    echo "AT_ERROR : Not define variable U_CUSTOM_VLANETH"
    exit 1
elif [ -z "$G_HOST_IP1" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_TIP1_1_0"
    exit 1
elif [ -z "$G_HOST_GW1_0_0" ] ;then
    echo "AT_ERROR : Not define variable G_HOST_GW1_1_0"
    exit 1
fi

if [ -f "$config_file_path" ] ;then
    mv $config_file_path $config_file_path.bak
fi

echo "# The configuration file for setting WAN PC
#
# The management IP address for LAN PC
# if set to \"no\", will not do nfs
LAN_MNGMT_IP        $G_HOST_IP0

# The management IP address for WAN PC
WAN_MNGMT_IP        $G_HOST_IP1

# Set the NIC which is used for magagemet
WAN_MNGMT_IF        $G_HOST_IF1_0_0

# Set the NIC that connect to internet
# DCHP mode: NIC
# WAN_NETWORK_IF  eth1
# Manual mode : NIC:IP:Gateway
# WAN_NETWORK_IF  eth1:172.16.10.62:172.16.10.254
WAN_NETWORK_IF      $G_HOST_IF1_0_0:$G_HOST_IP1:$G_HOST_GW1_0_0

# Set the NIC which is used for servers
WAN_SERVER_IF       $G_HOST_IF1_2_0

# Set the vlan list which is start on server interface
# Set to no if no vlan.
# eg. 
# VLAN_LIST         vlan1[,vlan2 ...]
VLAN_LIST           $U_CUSTOM_VLANETH

# whether need to reconfig server
reconfig            1">$config_file_path
}


main(){

    echo "Try to check if WAN PC eth1 is exist or not..."
    python $U_PATH_TBIN/clicmd -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "ifconfig $G_HOST_IF1_1_0"|grep "last_cmd_return_code:0"
    rc=$?
    if [ "$rc" -ne "0" ];then
        echo "Two network interface..."
        main_fc18
    else
        echo "THree network interface..."
        main_common
    fi

}

main
