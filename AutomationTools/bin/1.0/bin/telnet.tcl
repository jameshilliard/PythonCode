#!/usr/bin/tclsh
# Copyright (c) 2000 by Todd J Martin <todd.martin@acm.org>
# $Id: telnet.tcl,v 1.2 2007/01/11 21:49:04 wpoxon Exp $
#
# This file is used to for testing the telnet library.  It can also serve as
# an example of how to use the library.  The file implements a very simple
# telnet client in pure tcl.

# $Id: telnet.tcl,v 1.2 2007/01/11 21:49:04 wpoxon Exp $
# This is an implementation of the client side of the telnet protocol in Tcl
#
#  Copyright (c) 2000 by Todd J Martin <todd.martin@acm.org>

package provide telnet 2.0.1
namespace eval telnet {
    # This is an array containing textual representations of the various
    # telnet commands
    variable tcmd
    variable optId
    variable sbCmd
    # This array is used to maintain internal state information for the
    # extension
    variable telnetState
    # This buffer is used in case we only receive part of a telnet command
    # when we read.  We store the imcomplete command and wait for the rest of
    # it to come.
    #variable tmpBuffer

    namespace export open read write cook
}

# This initializes variables and settings for the extension
proc telnet::init {} {
    variable tcmd 
    variable optId 
    variable sbCmd 
    variable telnetState 
    variable tclTelnet
    array set tcmd [list \
	IAC [binary format c 255] \
	DONT [binary format c 254] \
	DO [binary format c 253] \
	WONT [binary format c 252] \
	WILL [binary format c 251] \
	SB [binary format c 250] \
	GA [binary format c 249] \
	EL [binary format c 248] \
	EC [binary format c 247] \
	AYT [binary format c 246] \
	AO [binary format c 245] \
	IP [binary format c 244] \
	BRK [binary format c 243] \
	DM [binary format c 242] \
	NOP [binary format c 241] \
	SE [binary format c 240] \
	EOR [binary format c 239] \
	ABORT [binary format c 238] \
	SUSP [binary format c 237] \
	EOF [binary format c 236] \
    ]

    set optId(ECHO) [binary format c 1]
    # Suppress Go Ahead
    set optId(SGA) [binary format c 3]
    set optId(STATUS) [binary format c 5]
    # Timing Mark
    set optId(TMRK) [binary format c 6]
    # terminal type  RFC 1091
    set optId(TERM) [binary format c 24]
    # terminal window size
    set optId(WINSIZE) [binary format c 31]
    # terminal speed
    set optId(TSPEED) [binary format c 32]
    # remote flow control
    set optId(FLOW) [binary format c 33]
    # linemode RFC 1184
    set optId(LINE) [binary format c 34]
    # X display location  RFC 1096
    set optId(XDISP) [binary format c 35]
    # environment variables RFC 1408
    set optId(ENV) [binary format c 36]
    # new environment variables RFC 1572
    set optId(NEWENV) [binary format c 39]

    set sbCmd(SEND) [binary format c 1]
    set sbCmd(IS) [binary format c 0]

    # The telnetState array determines which options this client supports
    set telnetState(TERM) WILL
    set telnetState(TSPEED) WILL
    set telnetState(ENV) WONT
    set telnetState(XDISP) WONT
    set telnetState(NEWENV) WONT
    set telnetState(ECHO) WONT
    set telnetState(SGA) WILL

    foreach tOpt [array names optId] {
	# 0 - haven't done anything with the option
	# 1 - Sent Do
	# 2 - Sent Dont
	# 3 - Sent Will
	# 4 - Sent Wont
	# 5 - Done negotiating
	set tState($tOpt) 0
    }
    unset tOpt
    set tclTelnet(debug) 0
}

# This routine prints debug statements to stdout if the debug variable is 1
proc telnet::DEBUG {str} {
    variable tclTelnet
    if {$tclTelnet(debug) == 1} {
	puts "$str"
    }
}

# Dump the string out as unsigned decimal numbers
proc telnet::rawDump {str} {
    set out ""
    for {set cnt 0} {$cnt < [string length $str]} {incr cnt} {
	binary scan [string index $str $cnt] c dec
	set dec [expr ( $dec + 0x100 ) % 0x100]
	append out "$dec "
    }
    return $out
}

# For the given telnet command and option, this decodes and return the values
# in english in a list.
proc telnet::decodeTelnetOption {tComm tOpt} {
    variable tcmd 
    variable optId

    # Decode the command and option and print it out
    set tCommDecode ""
    set tOptDecode ""
    foreach cmd [array names tcmd] {
	if {$tComm == $tcmd($cmd)} {
	    set tCommDecode $cmd
	    break
	}
    }
    foreach opt [array names optId] {
	if {$tOpt == $optId($opt)} {
	    set tOptDecode $opt
	    break
	}
    }

    if {$tCommDecode != "" && $tOptDecode != ""} {
	DEBUG "RCVD: IAC $tCommDecode $tOptDecode"
    } else {
	DEBUG "RCVD: Could not decode"
    }
    return [list $tCommDecode $tOptDecode]
}

# This is the telnet client state machine.  Given an incoming telnet command
# and option, it returns a string containing what should be sent back to the
# server.
proc telnet::processTelnetCommand {tComm tOpt {sbString ""}} {
    DEBUG "entering processTelnetCommand: $tComm $tOpt"
    variable tcmd 
    variable telnetState 
    variable optId 
    variable sbCmd

    # Decide what to do with this command
    switch  -exact $tComm {
	DO {
	    if [info exists telnetState($tOpt)] {
		return $tcmd(IAC)$tcmd($telnetState($tOpt))$optId($tOpt)
	    } else {
		return $tcmd(IAC)$tcmd(WONT)$optId($tOpt)
	    }
	}
	DONT {
	}
	WILL {
	    if [info exists telnetState($tOpt)] {
		return $tcmd(IAC)$tcmd($telnetState($tOpt))$optId($tOpt)
	    } else {
		return $tcmd(IAC)$tcmd(DONT)$optId($tOpt)
	    }
	}
	WONT {
	}
	SB {
	    DEBUG "\tGot an SB"
	    set sbParameter ""

	    DEBUG "\tsbString = [rawDump $sbString]"
	    for {set i 0} {$i < [string length $sbString]} {incr i} {
		set sbChar [string index $sbString $i]
		if {$sbChar == $tcmd(IAC)} {
		    if {[string index $sbString [expr $i+1]] == $tcmd(SE) } {
			incr i 2
			break
		    }
		} else {
		    append sbParameter ${sbChar}
		}
	    }
	    DEBUG "sbParameter= [rawDump $sbParameter]"
	    switch -exact $tOpt {
		TERM {
		    set command [string index $sbParameter 0]
		    if {$command == $sbCmd(SEND)} {
			DEBUG "RCVD Send $tOpt"
			return $tcmd(IAC)$tcmd(SB)$optId(TERM)$sbCmd(IS)XTERM$tcmd(IAC)$tcmd(SE)
		    } elseif {$command == $sbCmd(IS)} {
			# telnet clients should not get this.  This is for
			# servers
			DEBUG "RCVD Is $tOpt"
		    }
		}
		TSPEED {
		    set command [string index $sbParameter 0]
		    if {$command == $sbCmd(SEND)} {
			DEBUG "RCVD: Send $tOpt"
			return $tcmd(IAC)$tcmd(SB)$optId(TSPEED)$sbCmd(IS)9600,9600$tcmd(IAC)$tcmd(SE)
		    } elseif {$command == $sbCmd(IS)} {
			DEBUG "RCVD Is $tOpt"
		    }
		}
		default {
		    DEBUG "RCVD SB Parameter: $sbParameter"
		}
	    }
	}
    }
    return ""
}

# Once IAC is found, this proc is called to read and process the telnet
# option.  It will decode the telnet command and issue any necessary response.
# There is no meaningful return value.
proc telnet::doTelnetOption {channel inString} {
    variable tcmd 
    variable optId
    set tComm [string index $inString 0]
    set tOpt [string index $inString 1]

    set tList [decodeTelnetOption $tComm $tOpt]
    if {[lindex $tList 0] == "SB"} {
	set out [processTelnetCommand [lindex $tList 0] \
		[lindex $tList 1] [string range $inString 2 end]]
    } else {
	set out [processTelnetCommand [lindex $tList 0] \
		[lindex $tList 1]]
    }

    [namespace current]::writeRaw $channel $out
}


# This takes a string that contains any text and possible telnet options.  It
# will parse out the telnet option strings and pass them to doTelnetOption.
# It will return the original text with the telnet stuff removed.
proc telnet::cook {channel inBuffer} {
    variable tcmd 
    variable optId
    # This is tricky.  It is possible to not have the entire IAC command in
    # the inBuffer when it is read.  If this happens, we will store the
    # incomplete data in tmpBuffer and prepend that to inBuffer before
    # processing.  Now we don't have to concern the user with this sort of
    # minutiae
    variable tmpBuffer$channel
    upvar 0 tmpBuffer$channel tmpBuffer

    set out ""
    
    # Check if we have to deal with tmpBuffer
    if {![string compare $tmpBuffer ""]} {
	append tmp $tmpBuffer $inBuffer
	set inBuffer $tmp
	set tmpBuffer ""
    }
    while {1} {
	set len [string length $inBuffer]
	set indexIAC [string first $tcmd(IAC) $inBuffer]
	if {$indexIAC == -1} {
	    # There is no IAC in here, So just return in
	    append out $inBuffer
	    return $out
	}

	# There is an IAC in here.  If it is the last (or second to last)
	# character of the string, then we need to wait for more data to come.
	# We will return the rest of the string.
	if {$indexIAC >= [expr $len-2]} {
	    append out [string range $inBuffer 0 [expr $indexIAC-1]]
	    set tmpBuffer $tcmd(IAC)
	    return $out
	}

	# If indexIAC + 1 is also an IAC, then we will return one IAC, this is
	# not considered a telnet command.
	if {[string index $inBuffer [expr $indexIAC+1]] == $tcmd(IAC)} {
	    append out [string range $inBuffer 0 $indexIAC]
	    set inBuffer [string range [expr $indexIAC+2] end]
	    continue
	}

	# Check to see if the command is an SB or not.  SB's could be long and
	# require extra processing.  The other commands are easy to handle.
	set tCommand [string index $inBuffer [expr $indexIAC+1]]
	set tOpt [string index $inBuffer [expr $indexIAC+2]]
	if {$tCommand == $tcmd(SB)} {
	    # Look to see if we have the whole SB command in the buffer
	    set indexSE [string first $tcmd(IAC)$tcmd(SE) $inBuffer]
	    if {$indexSE == -1} {
		# We haven't gotten SE yet.  Return what we can.
		append out [string range $inBuffer 0 [expr $indexIAC-1]]
		set tmpBuffer [string range $inBuffer $indexIAC end]
		return $out
	    }
	    doTelnetOption $channel \
		    [string range $inBuffer [expr $indexIAC+1] [expr $indexSE+1]]]
	    append out [string range $inBuffer 0 [expr $indexIAC-1]]
	    set inBuffer [string range $inBuffer [expr $indexSE+2] end]
	    continue
	} else {
	    # Process the WILL, WONT, DO, DONT command
	    doTelnetOption $channel $tCommand$tOpt
	    append out [string range $inBuffer 0 [expr $indexIAC-1]]
	    set inBuffer [string range $inBuffer [expr $indexIAC+3] end]
	    continue
	}
    }
}

proc telnet::escapeIAC {buf} {
	variable tcmd
	regsub -all -- $tcmd(IAC) $buf $tcmd(IAC)$tcmd(IAC) newbuf
	return $newbuf
}

# Takes the same arguments as read.  It handles any embedded telnet options
# and returns the data with the telnet options removed and processed
proc telnet::read {args} {
    set nonewline ""
    if {[lindex $args 0] == "-nonewline"} {
	set nonewline " -nonewline "
	set args [lrange $args 1 end]
    }
    if {[llength $args] == 0} {error "Wrong number of arguments"}
    foreach {channel bytes} $args {}
    set readCmd "::read "
    append readCmd " $channel "
    append readCmd " $nonewline "
    append readCmd " $bytes "
    if {[catch {set buffer [eval $readCmd]} err]} {
	error $err $::errorInfo
    }
    DEBUG "buffer = [rawDump $buffer]"
    set input [cook $channel $buffer]
    DEBUG "input = $input"
    return $input
}

proc telnet::write {channel outBuffer} {
    # If outBuffer has any IACs in it, we need to escape that with IAC IAC
    set outBuffer [escapeIAC $outBuffer]
    DEBUG "outBuffer = [rawDump $outBuffer]"
    if {[catch {[namespace current]::writeRaw $channel $outBuffer} err]} {
	error $err $::errorInfo
    }
}

proc telnet::writeRaw {channel outBuffer} {
    DEBUG "outBuffer = [rawDump $outBuffer]"
    if { [catch {puts -nonewline $channel $outBuffer} err]} {
	error $err $::errorInfo
    }
    flush $channel
}

# Need to allow options (e.g. -myaddr, -myport, -async) to get passed down to
# socket
proc telnet::open {host port} {
    DEBUG "host = $host\nport = $port"
    if {[catch {set channel [socket $host $port]} errMsg]} {
	error $errMsg $::errorInfo
    }
    variable tmpBuffer$channel
    upvar 0 tmpBuffer$channel tmpBuffer
    set tmpBuffer ""
    fconfigure $channel -translation binary
    return $channel
}

telnet::init

if { $argc != 2 } {
    puts "Wrong number of args"
    puts "Usage: telnet_test.tcl host port"
    exit 1
}
set host [lindex $argv 0]
set port [lindex $argv 1]

set ttyBuffer {}
proc readTty {tty} {
    if {[catch {set input [read $tty]} err]} {
	error $err $::errorInfo
    }
    append ::ttyBuffer $input
    set ::telnetEvent readTty
}

proc readStdin {} {
    if {[eof stdin]} {
      set ::telnetEvent EOF
      return
    }
    if {[catch {set input [gets stdin]} err]} {
	error $err $::errorInfo
    }
    # Add a carriage return because if you are interactive on windows, then
    # the carriage return is eaten by the console
    append ::ttyBuffer $input "\r"
    set ::telnetEvent readStdin
}

proc tcpRead {pt} {
    if {[eof $pt]} {
      set ::telnetEvent EOF
      return
    }
    append ::telnetBuffer [telnet::read $pt]
    set ::telnetEvent tcpRead
}

set pt [telnet::open $host $port]
fconfigure $pt -blocking false -buffering none
fileevent $pt readable [list tcpRead $pt]

if {[string match $tcl_platform(platform) "unix"]} {
    close stdin
    set tty [open /dev/tty r]
    exec stty icanon brkint min 1 time 0 -istrip -ixon -ixoff -icanon -echo < /dev/tty
    fconfigure $tty -blocking false -buffering none
    fileevent $tty readable [list readTty $tty]
} else {
    fileevent stdin readable [list readStdin]
}

fconfigure stdout -buffering none
while {1} {
    set telnetEvent {}
    vwait telnetEvent
    if {[string equal $telnetEvent "tcpRead"]} {
	puts -nonewline "$telnetBuffer"
	set telnetBuffer {}
    } elseif {[string equal $telnetEvent "readTty"] || \
	      [string equal $telnetEvent "readStdin"] } {
	if {[catch {telnet::write $pt $ttyBuffer} err]} {
	    # Must be shutting down the connection
	    break
	}
	set ttyBuffer {}
    } elseif {[string equal $telnetEvent "EOF"]} {
	break
    }
}
close $pt
