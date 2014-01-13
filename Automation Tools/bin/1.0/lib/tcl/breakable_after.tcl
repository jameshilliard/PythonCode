#

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: breakable_after.tcl,v 1.2 2006/07/18 15:45:05 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: breakable_after.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.2 $"]
set cvs_date    [cvs_clean "$Date: 2006/07/18 15:45:05 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

# proc breakable_after timeout
#
# timeout - how long to wait in seconds
#
# breakable_after pauses just like the TCL built-in after command but allows
# for interruption by ^c and other signals.
#
# $Id: breakable_after.tcl,v 1.2 2006/07/18 15:45:05 manderson Exp $
#
proc breakable_after { timeout } {
    
    for {set x 0} {$x<$timeout} {incr x} {
        after 1000
    }
}
