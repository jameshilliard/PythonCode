#
# proc debug
#
# level -- a debug level for the message.
# msg -- a debug message to be printed
#
# The debug proc prints the message passed in the msg argument if a
# the global DEBUG_LEVEL variable is set to a value which exceeds the level of
# this message.  All debug messages have a level associated with them and
# more information # can be printed by increasing the value of DEBUG_LEVEL.
# A negative or zero value for DEBUG_LEVEL turns off debugging.
#
# $Id: debug.tcl,v 1.8 2007/04/04 01:46:46 wpoxon Exp $
#

proc debug {level msg} {
    if [ info exists ::DEBUG_LEVEL] {
        if {($::DEBUG_LEVEL > 0) && ($level <= $::DEBUG_LEVEL) } {
            switch -exact -- "$level" {
                "1" {
                    set pfx "Error:"
                }
                "2" {
                    set pfx "Warning:"
                }
                "3" {
                    set pfx "Info:"
                }
				"4" {
                    set pfx "Devel (Shatner: remove this!):"
                }
                "9" {
                    set pfx "Config:"
                }
                "10" {
                    set pfx "Version:"
                }
                "15" {
                    set pfx "VwConfig:"
                }
                "99" {
                    set pfx "Trace:"
                }
                default {
                    set pfx "-"
                }
            }
            puts "DEBUG-$level $pfx $msg"
			flush stdout
			flush stderr
        }
    }
} ; # End proc debug

set ::DBLVL_ERROR        1
set ::DBLVL_WARN         2
set ::DBLVL_INFO         3
set ::DBLVL_DEVEL        4
set ::DBLVL_CVS_VERSION  5
set ::DBLVL_CFG          9
set ::DBLVL_VWCONFIG    15
set ::DBLVL_TRACE       99

