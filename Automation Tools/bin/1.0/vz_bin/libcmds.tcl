##****************************************************************************
##
##  FILE NAME:           libcmds.tcl
##
##  CREATION DATE:       08/24/2009
##
##  AUTHOR:              Peng Hualin
##
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:        Not decode the packet just list the frames in the packet;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##      packetBuffer: buffer of channel;
##  USAGE:
##      set ret [undecodePacket $buf]
##****************************************************************************

##  DESCRIPTION:         This library file contains subroutines used for
##                       SNMP agent commands.
##
##  USAGE:               source libcmds.tcl
##
##****************************************************************************

############################################################
#
# Subroutines
#
############################################################


#!/usr/bin/wish

##****************************************************************************
##
##  PROCEDURE NAME:      capturePacket
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:	Use Ethereal to Capture Packet With Nic then save the packet into the file;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##      fileName: the file of capture packet;
##      nicNumber: interface of network,eg: eth0 or eth1;
##	time:	the time of running capture packet;
## 	count:	the count of packet;   
##  USAGE:
##      set ret [capturePacket $nicNumber $time $fileName]
##****************************************************************************
proc capturePacket {nicNumber time fileName {count ""} } {
	file mkdir ./Packet
	if {$count==""} {
		spawn tethereal -i $nicNumber -a duration:$time -w ./Packet/${fileName}.cap 
	} else {
		spawn tethereal -i $nicNumber -a duration:$time -w ./Packet/${fileName}.cap -c $count
	}
	match_max [expr 65535*64]
	expect -i $spawn_id "Capturing on"
}

##****************************************************************************
##
##  PROCEDURE NAME:      readPacket
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:        Read and analyse the packet;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##      fileName: the file of capture packet;
## 	filter:   the method of filter,eg:frame.protocols==eth:ip:upd:dhcp;
##  USAGE:
##      set ret [readPacket $fileName $filter]
##****************************************************************************
proc readPacket {fileName filter {decode 0}} {
   if {$decode==0} {
      spawn tethereal -r E:/Roadmap/demo/Packet/${fileName}.cap -R $filter
   }  else {
      spawn tethereal -r E:/Roadmap/demo/Packet/${fileName}.cap -R $filter -V 
   }
   
   match_max [expr 65535*64]
   expect eof {
      set packetBuffer $expect_out(buffer)
   }
   if {$decode==1} {
      return [decodePacket $packetBuffer]
   } else {
      return [undecodePacket $packetBuffer]
   }
}

##****************************************************************************
##
##  PROCEDURE NAME:      decodePacket
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:        decode the packet just list the frames in the packet;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##      packetBuffer: buffer of channel;
##  USAGE:
##      set ret [decodePacket $buf]
##****************************************************************************

proc decodePacket {packetBuffer} {
   set tempBuffer $packetBuffer
   set offset 0
   while {[string first "Frame" $tempBuffer]>=0} {
      set position [expr [lsearch $tempBuffer "Frame"]+1] 
      if {[isDigital [lindex $tempBuffer $position]]==1 } {
         lappend pos [expr $offset + [string first "Frame" $tempBuffer] ]
         set offset 0
        }  else {
         set offset [expr [string first "Frame" $tempBuffer]+1]
      }
        set tempBuffer [string range $tempBuffer [expr [string first "Frame" $tempBuffer]+1] end]
   }
   if {[info exists pos]==0} {
      return ""
   } 
    set posLength [llength $pos]
    if {$posLength<1} {
         return ""
   }    elseif {$posLength==1} {
      return [lappend packetList $packetBuffer] 
   }    else {
      set i 1
      set firstPosition [lindex $pos 0]
      while {$i<$posLength} {
      set lastPosition [expr $firstPosition+[lindex $pos $i]]
         lappend packetList [string range $packetBuffer $firstPosition $lastPosition]
         set firstPosition [expr $firstPosition+1+[lindex $pos $i]]
         incr i
      }
      lappend packetList [string range $packetBuffer $firstPosition end]
      return $packetList
   }
}


##****************************************************************************
##
##  PROCEDURE NAME:      undecodePacket
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:        Not decode the packet just list the frames in the packet;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##      packetBuffer: buffer of channel;
##  USAGE:
##      set ret [undecodePacket $buf]
##****************************************************************************
proc undecodePacket {packetBuffer} {
	set symbol "\n"
	puts "[ string first $symbol $packetBuffer]"
	set packetList "" 
	while {[string length $packetBuffer] != 0} {
		lappend packetList [string range $packetBuffer 0 [expr [string first $symbol $packetBuffer]-1]]
		set packetBuffer [string range $packetBuffer [expr [string first $symbol $packetBuffer]+3] end]
	}
	puts $packetList
	return $packetList
}

##****************************************************************************
##
##  PROCEDURE NAME:      telnet
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:         This subroutine opens the telnet;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##    	Dev_ipaddr: IP address of object client;
##    	port: the port of TCP/IP protocol,e.g. 21,23,80;
##  USAGE:
##    	set ret [telnet $Dev_ipaddr $port]
##****************************************************************************

proc telnet {Dev_ipaddr port} {
   
   puts "Initialize the telnet port ... "
   
   while { [catch {set fileid [socket $Dev_ipaddr $port] fid] } {
     
	 set check "N"
     puts "£¡£¡£¡$server initialize is fail ¡­¡­£¡\n"
     puts "Please check if address of server or port is right!\n"
	 
     while { $check != "Y" && $check != "y" } {
		puts -nonewline "Is it normal for address and port of server £¿Y/N: "
		gets stdin check
		puts " "
     }
   }
	  #sets and queries properties of I/O channels;
      fconfigure $fileid -buffering none 
	  fconfigure $fileid -blocking 0   
      fconfigure stdout -buffering none 
      fileevent $fileid readable
	
   puts "It's successful to open the sock ..."
   after 100;

   return $fileid;
    }
}

##****************************************************************************
##
##  PROCEDURE NAME:      Com_Setup
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:         This subroutine initialize the port of com;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##    	Portno: communicate port ,e.g. COM1,COM2;
##    	ComRate: the rate of com port,e.g. 9600,12500;
##  USAGE:
##    	set ret [Com_Setup $PortNo $ComRate]
##****************************************************************************
proc Com_Setup { PortNo ComRate } {

   puts "Initialize the telnet port ... "
   set dslamcomname $PortNo
      
   while { [catch {set channel [open $PortNo w+]} fid]} { 
   
     puts "£¡£¡£¡$server initialize is fail ¡­¡­£¡\n"
     puts "Please check if address of server or port is right!\n"
     while { $check != "Y" && $check != "y" } {
		puts -nonewline "Is it normal for address and port of server £¿Y/N: "
		gets stdin check
		puts " "
     }
   } 
   
   puts "$PortNo initialize is ok£¡\n"
   set rate $ComRate
   #sets and queries properties of I/O channels;
   fconfigure $channel -mode $ComRate,n,8,1 
   fconfigure $channel -blocking 0 
   fconfigure $channel -buffering full
   fconfigure $channel -translation { binary binary }
   fileevent $channel readable ""
   
   return $channel
}
##****************************************************************************
##
##  PROCEDURE NAME:      writeline
##  PROCEDURE AUTHOR:    Peng Hualin
##
##  DESCRIPTION:         This subroutine write the command to I/O channels ;
##  DEPENDENCIES:
##  INPUT PARAMETERS:
##    	fileid: 	procedure,for I/O channels;
##    	command: 	string ;
##  USAGE:
##    	set ret [writeline $fileid $command]
##****************************************************************************
proc writeline { fileid command } {
   
   set letter_delay 2
   
   # get the length of command string;
   set commandlen [string length $command]
   
   for {set i 0} {$i < $commandlen} {incr i} {
   
      set letter [string index $command $i]
      after $letter_delay
	  # write the string to I/O channels; 
      puts -nonewline $fileid $letter
      #puts "now writing :   $letter "
      
   }
   
   after $letter_delay
   
   # Type a enter when finished the whole command every time;
   puts -nonewline $fileid "\r"
   
   flush $fileid;
 
} 

