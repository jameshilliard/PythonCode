#!/usr/bin/env tclsh
#
# environ.tcl 
#
# utility function to collect and verify base version of packages installed on 
# the platform on which we are running.  Invoked from tclsh or by sourcing
# this file.
#
# todo add catch's around all the calls to tcl_platform
#
# $Id: environ.tcl,v 1.4.4.1 2007/08/20 18:37:20 manderson Exp $
#

namespace eval vw_environ {

	# set the minimum required versions

	set auto_min_tcl_ver 8.4
	set auto_min_python_ver 2.4.0
	set auto_min_expect_ver 5.30
	set auto_min_linux_ver 2.6.5
	set auto_min_windows_ver 5.0

	# for windows versions see wiki.tcl.tk
	# 5.0 is 2000 pro
	# 5.1 is XP
	# 5.2 is 2003 server
	# 6.0 is Vista

	#
	# proc lessthan_ver
	#
	# compare a version string of the form x.y.z.... against a minimum version
	# of the form a.b.c... to see of the passed in version is less than the
	# minimmum version.  Return 0 if it is less than or 1 if not.
	#
	proc lessthan_ver { test_ver min_ver} {
    	set test_list [split $test_ver .]
        set min_list [split $min_ver .]
        set min_len [llength $min_list]
        set test_len [llength $test_list]

        for {set x 0 } {$x < $min_len} {incr x} {
            if { $x >= $test_len } {
                set test_num 0
            } else {
                set test_num [lindex $test_list $x]
            }

            set min_num [lindex $min_list $x]
            if {$test_num < $min_num } {
                # bail out when the first rev number is less than the minimum 
                # required.
                return 1
            }
        }
        return 0
    }


    #
    # proc check_versions
    #
    # This proc gets the revisons of tcl, expect, python and what flavor
    # and rev of OS we are running on.  It compares this against the minimum
    # levels and reports any errors. If errros are found the tcl_platform info
    # is dumped out and the environment passed to tcl is dumped out.
    #
    #
    proc check_versions {} {

        puts ""
        puts "checking version compatability"
        puts "------------------------------------------------"

        # get the os
        if {[catch {set my_os $::tcl_platform(os)}] } {
            set error_cnt 1
            set my_os "unknown"
        } else {
            set error_cnt 0
            if { $my_os != "Windows NT" } {
                puts "os is $my_os"
                # we'll handle windows version below
            }
        }

        # get the tcl version
        set my_tcl_version [info patchlevel]

        #
        # check tcl version
        #

        if { [lessthan_ver $my_tcl_version $::vw_environ::auto_min_tcl_ver] } {
            puts "You are running version $my_tcl_version of tcl. Please upgrade/downgrade\
                to at least $::vw_environ::auto_min_tcl_ver"
            incr error_cnt

        } else {
            puts "tcl version $my_tcl_version is fine."
        }

        # get the python version
        # note exec'ing python -v returns a val of 1
        #

        if {![catch {exec python -V}  my_python_version_string]} {
            puts "error looking for python: $my_python_version_string"
            set my_python_version "unknown"
        incr error_cnt
        } else {
            set python_list [split $my_python_version_string]
            set len [llength $python_list]
            if { ($len == 2)  && ([lindex $python_list 0] == "Python") } {
                set len [expr ($len - 1 )]
                set my_python_version [lindex $python_list $len ]
            } else {
                puts "error finding python version: $my_python_version_string"
                set my_python_version "unknown"
                incr error_cnt
            }
        }

        #
        # check python version
        #

        if {$my_python_version == "unknown"}  {
            puts "Can't find a python version number. Please install at least\
             $::auto_min_python_ver of python"
        } elseif { [lessthan_ver $my_python_version  $::vw_environ::auto_min_python_ver] } {
            puts "You are running version $my_python_version of python.\
               Please upgrade to at least $::vw_environ::auto_min_python_ver"
            incr error_cnt
        } else {
            puts "Python version $my_python_version is fine."
        }

        # get the expect version
    
        if {$my_os == "Windows NT"} {
            if {[catch {package require Expect} my_expect_version]} {
                puts "Can't seem to find expect error: $my_expect_version"
                set my_expect_version "unknown"
                incr error_cnt
            }
        } else {
            # note exec'ing expect -v returns 0
            if {[catch {exec expect -v}  my_expect_version_string]} {
                puts "error looking for expect: $my_expect_version_string"
                set my_expect_version "unknown"
                incr error_cnt
            } else {      
                set expect_list [split $my_expect_version_string]
                set len [llength $expect_list]
                if { ($len == 3)  && ([lindex $expect_list 0] == "expect") } {
                    set len [expr ($len - 1 )]
                    set my_expect_version [lindex $expect_list $len ]
                } else {
                    puts "error finding expect version: $my_expect_version_string"
                    set my_expect_version "unknown"
                    incr error_cnt
                }
            }
        }

        # 
        # check expect version
        #

        if {$my_expect_version == "unknown"}  {
            puts "Can't find an expect version number Please install at least\
                $::vw_environ::auto_min_expect_ver of expect"
        } elseif { [lessthan_ver $my_expect_version  $::vw_environ::auto_min_expect_ver] } {
            puts "You are running version $my_expect_version of expect.\
               Please upgrade to at least $::vw_environ::auto_min_expect_ver"
            incr error_cnt
        } else {
            puts "Expect version $my_expect_version is fine."
        }

        #
        # os specific checks 
        #

        if { $my_os == "Linux" } {
            # 
            # linux specific checks
            #
            # get the version of Linux

            if {[catch {set my_os_version $::tcl_platform(osVersion)}] } {
                set my_os_version "unknown"
                incr error_cnt
            }
            if {[catch {set machine $::tcl_platform(machine)}] } {
                set machine "unknown"
                incr error_cnt
            }
            if {!(($machine == "i486") || ($machine == "i586") 
                || ($machine == "i686"))} {
                puts "You are running linux on $machine which is an unsupported\
                   machine type. Please run on an i486, i586 or i686 platform"
                incr error_cnt
            }

            set ver_list [split $my_os_version -]
            set base_version [lindex $ver_list 0]
            if { [lessthan_ver $base_version  $::vw_environ::auto_min_linux_ver] } {

                puts "You are running on linux version $my_os_version.  Please\
                   upgrade to at least $::vw_environ::auto_min_linux_ver"
                incr error_cnt
            } else {
                puts "Linux version $my_os_version is fine."
            }
            if { [catch {set invoked $::env(_)}] } {
                incr error_cnt
                set invoked "unknown"
            } else {
                puts "Invoked as $invoked"
            }
        } elseif {$my_os == "Windows NT"} {
            #
            # Windows specific checks
            #
            # get the version of windows
            #

            if {[catch {set my_os_version $::tcl_platform(osVersion)}] } {
                set my_os_version "unknown"
                incr error_cnt
            }
            if {[catch {set machine $::tcl_platform(machine)}] } {
                set machine "unknown"
                incr error_cnt
            }
	        if {[lessthan_ver $my_os_version  $::vw_environ::auto_min_windows_ver]} {
                puts "It appears you are running a pre win2k version of Windows"
                puts "At this time only 2000, XP, 2003 Server and Vista are supported"
                incr error_cnt
            } else {
                puts "Tcl reports platform  $my_os version $my_os_version aka:"
                if {$my_os_version == "5.0" } {
                    puts "Windows 2000"
                } elseif {$my_os_version == "5.1" } {
                    puts "Windows XP"
                } elseif {$my_os_version == "5.2" } {
                    puts "Windows 2003"
                } elseif {$my_os_version == "6.0" } {
                    puts "Windows Vista"
                } else {
                    puts "unknown Windows version"
                } 
            } 
            if { [catch {set arch $::env(PROCESSOR_ARCHITECTURE)}]} {
                incr error_cnt
            }
            if { ($arch == "x86_64") || ($arch == "IA64") } {
                puts "It appears you are running on a 64 bit processor."
                puts "Only 32-bit architectures are supported at this time."
                incr error_cnt
            } elseif {$arch == "x86"} {
                puts "It appears you are running on a 32-bit windows box."
            } else {
                puts "It appears you are running windows on a non x86 platform"
                puts "and/or non 32-bit platform. This is unsupported."
                incr error_cnt
            }

        } else {
            #
            # Unknown OS error
            #
            puts "Unknown OS type. The following OS's are supported:"
            puts " Linux (32 bit)"
            puts " Windows 2000, XP, 2003, Vista on 32 bit hardware"
        }

    
        puts "------------------------------------------------"
        puts ""
   
        set more_info 0 
        if [ info exists ::DEBUG_LEVEL] {
            if {$::DEBUG_LEVEL > 0} {
                set more_info 1
            } 
        }
        if {($error_cnt > 0) || ($more_info == 1)} {
            puts "Running on this platform:"
            parray ::tcl_platform
            puts ""
            puts "In this environment:"
            parray ::env
        }

        return $error_cnt
    }

    set rc [check_versions]
    puts ""
    if { $rc == 0 } { 
        puts "Compatability check PASSED "
    } else {
        puts "Compatability check FAILED "
    }
    puts ""
}
