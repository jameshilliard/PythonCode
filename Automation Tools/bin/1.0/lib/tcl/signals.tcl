#
# signals.tcl - signal handling for the automated testing framework
#
#
# $Id: signals.tcl,v 1.5 2007/01/11 21:49:04 wpoxon Exp $
#

proc sig_handler {} {
    debug $::DBLVL_INFO "Notice: signal caught.  cleaning up"

    # exit handles all the cleanup
    exit -2
}

# we want to be notified when ^c is hit.
signal trap SIGINT sig_handler
