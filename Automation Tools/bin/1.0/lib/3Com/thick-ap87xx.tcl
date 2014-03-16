#
# ap-xxx.tcl - configures a 3Com ap8760 access point (device-under-test)
#         running in stand-alone (thick) mode
#
# The functions in this file will override any that are defined in the upper
# 3Com level.
#
# serial connection notes: if using the serial port to talk to the congtroller
# use 9600, 8 data bits, 1 stop bit, parity = None
# hit return to start the CLI
#
# $Id: thick-ap87xx.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: thick-ap87xx.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: thick-ap87xx.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.2 $"]
set cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:45 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

#
# note that except for the entry point for the AP's configuration,
# this file is currently blank but as differences between various 3Com
# access points are identified this file will get utilized for configuring
# any settings unique to the various 3Com AP's.
#

set lib [file join $::VW_TEST_ROOT lib 3Com thick-apxx60.tcl]
if {[catch {source $lib} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}


#
# entry point for configuring the ap
#
set ::config_file_proc dut_configure_3Com
