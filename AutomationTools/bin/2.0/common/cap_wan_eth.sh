#!/bin/bash - 
#===============================================================================
#
#          FILE: cap_wan_eth.sh
# 
#         USAGE: ./cap_wan_eth.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 07/29/2013 10:28:14 AM CST
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error


function cap_wan_eth()
{
    dtnow=`date +%Y_%m_%d_%H_%M_%S`
    capfile="$G_CURRENTLOG/wan_${G_HOST_IF1_2_0}_${dtnow}.cap"
    logfile="$G_CURRENTLOG/log4cap_wanpc"
    clicmd --timeout 7200 --mute -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "killall tshark;tshark -B 10 -s 0 -i $G_HOST_IF1_2_0 -w '$capfile' >> $logfile 2>&1 "

}

function main()
{
    for((i=0;i<10000;i++))
    do
        echo "==[$i]== do cap in wan pc"
        cap_wan_eth
        sleep 5
    done
}

#
main


