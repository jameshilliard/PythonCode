#!/usr/bin/env expect

set Id "Id"
set RCSfile "RCSfile"
set Revision "Revision"
set Date "Date"
set Name "Release"

# $Id: test.tcl,v 1.5 2006/07/11 23:33:21 wpoxon Exp $

set cvs_ID "$Id: test.tcl,v 1.5 2006/07/11 23:33:21 wpoxon Exp $"
regexp {[a-zA-Z0-9\.\ \/\:\,]*} $cvs_ID clean
puts $clean

set cvs_RCSfile "$RCSfile: test.tcl,v $"
regexp {[a-zA-Z0-9\.\ \/\:\,]*} $cvs_RCSfile clean
puts $clean

set cvs_Revision "$Revision: 1.5 $"
regexp {[a-zA-Z0-9\.\ \/\:\,]*} $cvs_Revision clean
puts $clean

set cvs_Date "$Date: 2006/07/11 23:33:21 $"
regexp {[a-zA-Z0-9\.\ \/\:\,]*} $cvs_Date clean
puts $clean

set cvs_Name "$Name: b2_4_2_rd $"
regexp {[a-zA-Z0-9\.\ \/\:\,]*} $cvs_Name clean
puts $clean

