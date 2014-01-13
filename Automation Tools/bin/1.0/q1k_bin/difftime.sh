#!/bin/bash 
#---------------------------------
# Filename:	difftime.sh
# Author: 	Martin(Jing Ma)
# Description:	diff time in sec
# Usage: 	difftime.sh -n <DT/ST> [Dut_Time_File] [PC_Time_File]
# Date:		11/10/2009
#--------------------------------

#set -x 
if [ $# -lt 2 ]; then
	echo "Usage: difftime.sh -n <DT/ST> [Dut_Time_File] [PC_Time_File]" 
	exit
fi

if [ $1 != "-n" ]; then
	echo "Usage: difftime.sh -n <DT/ST> [Dut_Time_File] [PC_Time_File]" 
	exit
fi

if [ -z $3 ]; then
    dut_time_file="$G_CURRENTLOG/clicfg.pl.log"	
else 
    dut_time_file="$3"	
fi

if [ -z $4 ]; then
    pc_time_file="$G_CURRENTLOG/PC2time.log"	
else 
    pc_time_file="$4"	
fi

if [ ! -e $dut_time_file -o ! -e $pc_time_file ]; then
	exit 1
fi

duttime=`grep -A 1 "# date" $dut_time_file | grep -v "date" | tr -d '\r'`

if [ $duttime -eq 0 ]; then
	exit 1
fi

#select standard time on DUT
if [ $2 == "ST" ]; then
	grep "ST" $pc_time_file

	#PC is standard time
	if [ $? -eq 0 ]; then
		pctime=`grep -v "ST" $pc_time_file`
	#PC is day-light saving time
	else
		pctime=`expr $(grep -v "DT" $pc_time_file) - 3600`
	fi
	
#select day-light saving time on DUT
else
	grep "DT" $pc_time_file

	#PC is day-light saving time
	if [ $? -eq 0 ]; then
		pctime=`grep -v "DT" $pc_time_file`
	#PC is standard time
	else
		pctime=`expr $(grep -v "ST" $pc_time_file) + 3600`
	fi
fi

sec=`expr $duttime - $pctime | tr -d -`
    
if [ $sec -gt 180 ]; then
	echo "wrong time"
	exit 1 
else
	echo "true time"
	exit 0 
fi

