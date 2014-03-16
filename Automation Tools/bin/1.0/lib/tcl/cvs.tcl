
#
# code for manipulating CVS keywords
#
# $Id: cvs.tcl,v 1.1 2006/07/12 00:08:23 wpoxon Exp $
#

set Author ""
set Date ""
set Id ""
set RCSfile ""
set Revision ""
set Name ""


#
# clean up some of the cruft we get in cvs keywords
#
# Example:
#
#  set cvs_ID [cvs_clean "$Id: cvs.tcl,v 1.1 2006/07/12 00:08:23 wpoxon Exp $"]
#
proc cvs_clean { dirty } {
	regsub {\$$} $dirty "" clean
	set dirty $clean

	regsub {^:\ } $dirty "" clean
	set dirty $clean

	regsub {,v} $dirty "" clean
	set dirty $clean

	regsub {Exp\ $} $dirty "" clean
	set dirty $clean

	return $clean
}

