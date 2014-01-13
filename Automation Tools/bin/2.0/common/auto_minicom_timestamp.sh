#!/bin/bash - 
#===============================================================================
#
#          FILE: auto_minicom_timestamp.sh
# 
#         USAGE: ./auto_minicom_timestamp.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 04/24/2013 09:42:13 AM CST
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

#LOGFILE="$G_LOGS/current/"
TIMEOUT=30

if [ -z "$1" ]; then
    echo ''
else
    TIMEOUT=$1
fi

update_timestamp(){

    LOGFILE=`ps aux | grep -v grep | grep minicom.log | grep -i screen | awk '{print $NF}'`
    if [ -z "$LOGFILE" ]; then
        echo 'Not found log file for minicom in running'
    else
        echo "Found log file for minicom in running : $LOGFILE"
        echo -e "\n\nAT_DEBUG_TIMEDATE : "`date`"\n\n" >> $LOGFILE
    fi
}

interval_sleep(){
    echo "Enter interval sleep($TIMEOUT) "
    sleep $TIMEOUT
}


main(){
    #for i in `seq 9999`
    while [ 1 -eq 1 ]
    do
        echo "loop $i ..."
        update_timestamp
        interval_sleep
    done
}


main
