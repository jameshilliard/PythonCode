#! /bin/bash
#
# Author        :   Andy(aliu@actiontec.com)
# Description   :
#   This tool is used to setup the DUT's WAN server .
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#25 Jun 2012    |   1.0.0   | Andy      | Inital Version

REV="$0 version 1.0.0 (25 Jun 2012)"

echo "${REV}"

# USAGE
USAGE()
{
    cat <<usge
USAGE :

    bash $0 -e <enable_list> -d <disable_list> --[test]

    OPTIONS:

    -e          setup server which need enable,     server1[,server2...]
    -d          setup server which need disable,    server1[,server2...]
    --test      test mode

    Note : You can setup global variable U_CUSTOM_WAN_SERVER_ENABLE_LIST and U_CUSTOM_WAN_SERVER_DISABLE_LIST for list the server status.
usge
}

enable_list=$U_CUSTOM_WAN_SERVER_ENABLE_LIST
disable_list=$U_CUSTOM_WAN_SERVER_DISABLE_LIST

while [ -n "$1" ];
do
    case "$1" in
        -e)
            enable_list="$2"
            shift 2
            ;;
        -d)
            disable_list="$2"
            shift 2
            ;;

        --test)
            echo "Test mode:"
            U_PATH_TBIN=/root/automation/bin/2.0/common
            G_HOST_TIP1_0_0=192.168.100.40
            G_HOST_USR1=root
            G_HOST_PWD1=actiontec
            shift 1
            ;;
        *)
            echo $USAGE
            exit 1
            ;;
    esac
done

echo "Enable server list : $enable_list"
echo "Disable server list : $disable_list"

if [ "$enable_list" ] ;then
    for server in `echo "$enable_list" | sed 's/\,/\ /g'`
    do
        echo "Start $server"

        if [ "$server" == "pppoe-server" ] ;then
            echo "$U_PATH_TBIN/clicmd -d \"$G_HOST_TIP1_0_0\" -u \"$G_HOST_USR1\" -p \"$G_HOST_PWD1\" -m \"#\" -v \"bash $G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/setup_pppd.sh $G_HOST_IF1_2_0 start\""
            $U_PATH_TBIN/clicmd -d "$G_HOST_TIP1_0_0" -u "$G_HOST_USR1" -p "$G_HOST_PWD1" -m "#" -v "bash $G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/flushVLANIP.sh" -v "bash $G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/setup_pppd.sh $G_HOST_IF1_2_0 start"
        else
            echo "$U_PATH_TBIN/clicmd -d \"$G_HOST_TIP1_0_0\" -u \"$G_HOST_USR1\" -p \"$G_HOST_PWD1\" -m \"#\" -v \"service $server restart\""
            $U_PATH_TBIN/clicmd -d "$G_HOST_TIP1_0_0" -u "$G_HOST_USR1" -p "$G_HOST_PWD1" -m "#" -v "service $server restart" -v "service $server status" -v "ps aux | grep -i $server"
        fi
    done
else
    echo -e " AT_INFO : The enable server list is empty "
fi

if [ "$disable_list" ] ;then
    for server in `echo "$disable_list" | sed 's/\,/\ /g'`
    do
        echo "Stop $server"

        if [ "$server" == "pppoe-server" ] ;then
            echo "$U_PATH_TBIN/clicmd -d \"$G_HOST_TIP1_0_0\" -u \"$G_HOST_USR1\" -p \"$G_HOST_PWD1\" -m \"#\" -v \"bash $G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/setup_pppd.sh $G_HOST_IF1_2_0 stop\""
            $U_PATH_TBIN/clicmd -d "$G_HOST_TIP1_0_0" -u "$G_HOST_USR1" -p "$G_HOST_PWD1" -m "#" -v "bash $G_SQAROOT/tools/$G_TOOLSVERSION/START_SERVERS/setup_pppd.sh $G_HOST_IF1_2_0 stop"
        else
            echo "$U_PATH_TBIN/clicmd -d \"$G_HOST_TIP1_0_0\" -u \"$G_HOST_USR1\" -p \"$G_HOST_PWD1\" -m \"#\" -v \"service $server stop\" -v \"service $server status\" -v \"ps aux | grep -i $server|grep -v grep&&killall -9 $server\""
            $U_PATH_TBIN/clicmd -d "$G_HOST_TIP1_0_0" -u "$G_HOST_USR1" -p "$G_HOST_PWD1" -m "#" -v "service $server stop" -v "service $server status" -v "ps aux | grep -i $server|grep -v grep&&killall -9 $server"
        fi
    done
else
    echo -e " AT_INFO : The disable server list is empty "
fi

exit 0
