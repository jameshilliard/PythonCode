#!/bin/bash
# Program
#      This tool is used to change time to minutes
#
#
# History
#     DATE    |   REV   |   AUTH   |    INFO        |
#  2013/03/22 |  1.0.0  |  Howard  | Inital Version |

VER="1.0.0"
echo "$0 version : ${VER}"

#	U_CUSTOM_ASC_START
#	U_CUSTOM_ASC_END
#	U_CUSTOM_ASC_DELTA_DUT2LAN

cur_minutes_lan=$(echo "`date  +%H`*60+`date  +%M`"|bc)

echo "current minutes on LAN : ${cur_minutes_lan}"

#	start-$now-$delta
time2sleep=$(echo "${U_CUSTOM_ASC_START}-${cur_minutes_lan}+(${U_CUSTOM_ASC_DELTA_DUT2LAN})+3"|bc)

if [ ${time2sleep} -gt 1440 ] ;then
	time2sleep=$(echo "${time2sleep}-1440"|bc)
else 
	echo "no cross day"
fi

echo "time to sleep : ${time2sleep}m"

sleep ${time2sleep}m

exit 0
