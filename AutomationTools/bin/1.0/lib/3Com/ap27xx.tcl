#
# ap-xxx.tcl - configures a 3Com thin MAP access points (devices-under-test)
#         connected to a 3Com WRX-100 Switch
#
# Currently-supported AP's include the ap2750
#
# The functions in this file will override any that are defined in the upper
# 3Com level.
#
# serial connection notes: if using the serial port to talk to the WRX-100
# use 9600, 8 data bits, 1 stop bit, parity = None
# hit return to start the CLI
# default username = admin, default password = <none>
#
# $Id: ap27xx.tcl,v 1.3 2007/04/04 01:46:45 wpoxon Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: ap27xx.tcl,v 1.3 2007/04/04 01:46:45 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: ap27xx.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.3 $"]
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
# List of current known 3Com Wx Switches
#
# Model         dap-id range
# -----         ------------
#
# WXR100        1 to 8
# WX1200        1 to 30
# WX2200        1 to 300
# WX4400        1 to 300
#

#
# List of current known 3Com AP types:
#
# ap2750, ap3750, ap7250, ap8250, ap8750,
# mp-52, mp-241, mp-252, mp-262, mp-341, mp-352, mp-620,
# mp-372, mp-372-CN, mp-372-JP,
#

#
# We have not determined yet if 3Com AP's can be divided
# into device families, so for now we just inherit at the vendor level.
#
# For now, hard-code that this ap is configured using the wrx-100 switch.
# in the future if we find that the thin AP's can work with multiple
# different WLC's then we can add a WlanSwitchModel parameter
# in the config file and source in the named WLC here instead of the
# hard-coded one below.
#
set lib [file join $::VW_TEST_ROOT lib 3Com wrx-100.tcl]
if {[catch {source $lib} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}


#
# entry point for configuring the ap
#
set ::config_file_proc dut_configure_3Com
