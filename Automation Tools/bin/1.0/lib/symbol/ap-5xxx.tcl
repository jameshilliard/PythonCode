#
# ap-5131.tcl - configures a Symbol ap-5131 access point (device-under-test)
#
# The functions in this file will override any that are defined in the upper
# symbol level.
#
# serial connection notes: if using the serial port on this type of AP for
# configuration, 19200, 8 data bits, 1 stop bit, parity = None
# and press <ESC> or <RET> to start the CLI
# default username = admin, default password = symbol
#
# $Id: ap-5xxx.tcl,v 1.3 2007/04/04 01:46:46 wpoxon Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: ap-5xxx.tcl,v 1.3 2007/04/04 01:46:46 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: ap-5xxx.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.3 $"]
set cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:46 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

# note that except for the entry point for the AP's configuration, this file is currently
# blank but as differences between various Symbol access points are identified this file
# will get utilized for configuring any settings unique to the ap-5131

# symbol doesn't really have device families, so we just inherit
# at the vendor level.
set lib [file join $::VW_TEST_ROOT lib symbol symbol-ap.tcl]
if {[catch {source $lib} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}


#
# entry point for configurating the 5131
#
set ::config_file_proc dut_configure_symbol_ap
