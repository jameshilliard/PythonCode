#
# ap-xxx.tcl - configures a 3Com ap7760 access point (device-under-test)
#         connected to a 3Com 2475 WLAN Switch
#
# The functions in this file will override any that are defined in the upper
# 3Com level.
#
# serial connection notes: if using the serial port to talk to the congtroller
# use 19200, 8 data bits, 1 stop bit, parity = None
# hit return to start the CLI
#
# $Id: ap77xx.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: ap77xx.tcl,v 1.2 2007/04/04 01:46:45 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: ap77xx.tcl,v $"]
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

#
# We have not determined yet if 3Com AP's can be devided
# into device families, so for now we group them by the WLAN switch controller (WLC)
# which they are known to work with.  In this case, we know the
# 8760 AP works with the 2475 WLC.
#
# For now, hard-code that this ap is configured using the wlc-2475 switch.
# in the future if we find that the thin AP's can work with multiple
# different WLC's then we can add a WlanSwitchModel parameter
# in the config file and source in the named WLC here instead of the
# hard-coded one below.
#
set lib [file join $::VW_TEST_ROOT lib 3Com wlc-2475.tcl]
if {[catch {source $lib} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}


#
# entry point for configuring the ap
#
set ::config_file_proc dut_configure_3Com
