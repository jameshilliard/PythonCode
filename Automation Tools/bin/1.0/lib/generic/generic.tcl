#
# generic.tcl - stub DUT configuration code for when a master automation framework
#               is driving Waveautomate or when DUT configuration code has not yet
#               been written for a particular vendor or model.
#
# Note: This file is not a good place to start when writing wrapper code to
#       call an external program to configure a DUT or as an example of what
#       what needs to be done to support a real AP.
#
# $Id: generic.tcl,v 1.1 2007/06/01 20:21:51 manderson Exp $
#

global Author Id RCSfile Revision Date Name

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: generic.tcl,v 1.1 2007/06/01 20:21:51 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: generic.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.1 $"]
set cvs_date    [cvs_clean "$Date: 2007/06/01 20:21:51 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

#
# entry point for "configuring" a generic AP
#
set ::config_file_proc dut_configure_generic_ap

#
# dut_configure_generic_ap - top level procedure to "configure" a generic/unknown
#                            AP
#
# parameters:
# dut_name    - The name of the AP to be configured
#
# group_name  - The name of the group this AP will be configured for
#
# global_name - A pointer to the global config for this test
#
proc dut_configure_generic_ap { dut_name group_name global_name } {    

    debug $::DBLVL_TRACE "dut_configure_generic_ap"
    
    # whew
    return 0
}

set ::config_file_proc dut_configure_generic_ap