#!/bin/bash

#SET THE PATH FOR vw_auto.tcl
VW_AUTO='/home/carl/automation_linux/automation/bin/vw_auto.tcl'
#VW_AUTO='/home/vinay/waveautomation/WaveAutomate_3.2.2_2008.03.24.04_linux-x86/automation/bin/vw_auto.tcl'
while read newline
do
{
       $VW_AUTO -f $newline  
	 
}
done < testlist

