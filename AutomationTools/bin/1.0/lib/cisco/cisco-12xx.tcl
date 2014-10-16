#
# cisco-12xx.tcl - code for configuring the cisco 12xx family of access points.
#
# The functions in this file override any functions from cisco-ios.tcl that
# require changes to configure this device family differently from
# devices larger cisco-ios family.
#
# $Id: cisco-12xx.tcl,v 1.9 2007/04/04 01:46:46 wpoxon Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: wpoxon $"]
set cvs_ID      [cvs_clean "$Id: cisco-12xx.tcl,v 1.9 2007/04/04 01:46:46 wpoxon Exp $"]
set cvs_file    [cvs_clean "$RCSfile: cisco-12xx.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.9 $"]
set cvs_date    [cvs_clean "$Date: 2007/04/04 01:46:46 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

#
# inherit (hopefully) most of the code we need to configure
# a cisco-12xx AP from its parent class (the cisco-ios device family)
#
set device_family "cisco-ios"

set lib [file join $::VW_TEST_ROOT lib cisco $device_family.tcl]

if {[catch {source $lib} result]} {
    puts "Opening of $lib failed: $result"
    exit -1
}

#
# entry point for configuring cisco-12xx
#
set ::config_file_proc dut_configure_cisco-cisco-ios
