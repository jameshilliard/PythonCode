#
#   configures a Trapeze thin MAP access points (devices-under-test)
#         connected to a Trapeze MXR-x Switch
#
# Currently-supported AP's include the MP-372 and MP-xxx
#
# The functions in this file will override any that are defined in the upper
# Trapeze level.
#
# serial connection notes: if using the serial port to talk to the MXR
# use 9600, 8 data bits, 1 stop bit, parity = None
# hit return to start the CLI
# default username = admin, default password = <none>
#
# $Id: MP-xxx.tcl,v 1.2 2007/05/10 16:54:41 manderson Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: MP-xxx.tcl,v 1.2 2007/05/10 16:54:41 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: MP-xxx.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.2 $"]
set cvs_date    [cvs_clean "$Date: 2007/05/10 16:54:41 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

#
# note that except for the entry point for the AP's configuration,
# this file is currently blank but as differences between various Trapeze
# access points are identified this file will get utilized for configuring
# any settings unique to the various Trapeze AP's.
#

#
#

#
# List of current known Trapeze AP types:
#
# mp-52, mp-241, mp-252, mp-262, mp-341, mp-352, mp-620,
# mp-372, mp-372-CN, mp-372-JP,
#

#
# We have not determined yet if Trapeze AP's can be divided
# into device families, so for now we just inherit at the vendor level.
#
# For now, hard-code that this ap is configured using the wrx-100 switch.
# in the future if we find that the thin AP's can work with multiple
# different WLC's then we can add a WlanSwitchModel parameter
# in the config file and source in the named WLC here instead of the
# hard-coded one below.
#
set lib [file join $::VW_TEST_ROOT lib trapeze mxr-2.tcl]
if {[catch {source $lib} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}


#
# entry point for configuring the ap
#
set ::config_file_proc dut_configure_trapeze
