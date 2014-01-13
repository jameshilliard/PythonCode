#!/usr/bin/wish

package require Expect
source /mnt/automation/bin/1.0/vz_bin

if {$argc <= 1} {

	puts "ERR: Missing arguments"
	exit 0
} elseif {$argc > 2} {

	puts "ERR: Invalid arguments - count =$argc args=\"$argv\""
	exit 0
} else {

	set cmd [lindex $argv 0]
	set logFile [lindex $argv 1]
	
}
#-----------------------------------------------------#
#  Main: anayls the package of capture                #
#-----------------------------------------------------#
    

################# read the package ###############################
set packetList [readPacket $frameName frame.protocols==eth:ip:udp:syslog 1]
set frameLength [llength $packetList]
puts "\n=======The length of capture is $frameLength ======="

set sign 0
set logmessage 0;
if {$frameLength==0} {
   	puts "no frame"
} else {


 
	puts "\n -------------------------------------------------------------------------"
	puts "        Check if receive right message of log                               "
	puts " ---------------------------------------------------------------------------"
	
	for {set i 0} {$i < $frameLength} {incr i 1} {
	set checkList [lindex $packetList $i]
	
	if {[string first $logmessage $checkList] != -1} {
		puts "\n===Get message of trap is : $logmessage =================\n"
		puts "=== Its successful to get trap message of log===============\n"
		puts "============================================================\n"	

		regexp {9:[ ]+([0-10].*)[ ]+} $checkList match OID;
		puts "OID of trap is : $OID"
		
		incr sign 1;
		puts "*******************"
		puts "*** step $sign pass ***"
		puts "*******************"
		} 
	
	} 
    
}
if {$sign == 1} {
	puts "PASSED: The test is Successfully"
}

