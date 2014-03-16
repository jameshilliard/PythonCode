#!/usr/bin/env expect

#
# $Id: vw_auto.tcl,v 1.96.2.1.2.7 2008/02/06 15:23:05 manderson Exp $
#

#
# Edit the version below for each release
#
set release_version "4.0.3-WT-3.4"
set path $::env(PATH)
set path "/usr/lib/python2.4/:$path"
set ::env(PATH) $path

set help_message {
###################################################################
# Test Name:
#    vw_auto.tcl
#
# Description:
#    This test loops through a list of DUT's (access points)
#    as well as a list of security types and runs Veriwave's 
#    throughput test on each DUT for each security type.
#
# DUT's and security types are defined in $VW_TEST_ROOT/conf/config.tcl
#
# Example:
#    ./vw_auto.tcl --debug 5 -f /tmp/my_config.tcl
#
# Usage:
#    vw_auto.tcl
#
# Arguments:
#    -h or --help              - This help message.
#
#    -c <ip addr|host>         - Override the WaveTest chassis IP as defined
#                                in the config file.
#
#    -e or --environ           - Test for needed TCL/Expect/Python versions.
#
#    -f <config file>          - Use the specified configuration file instead of
#                                the default $VW_TEST_ROOT/conf/config.tcl
#
#    -w <test> <WML file>      - Run using the specified test with the secified WML file.
#
#    -i or --tid <id>          - Use the specified ID to tag the result output.
#
#    -o <output file>          - Write a log of the test run to the specified file.
#                                The default file is in the results directory.
#
#    --license <key>           - Use the specified license key to enable certain
#                                tests.
#
#    --debug <level>           - Print out debugging output.  Useful values are:
#                                1 - errors only
#                                2 - warnings and errors
#                                3 - warnings, errors and info
#
#    --duts <dut list>         - Override the DUT_LIST in the config file.
#
#    --nodut                   - Do not try to access the DUT.  Equivalent to 
#                                --noclean --noconfig and --noping
#
#    --noclean                 - Do not attempt to erase configuration on AP 
#                                before and between test runs.
#
#    --noconfig                - Do not configure the AP for the current security
#                                method before running the test.
#
#    --noping                  - Do not check network connectivity to the AP
#                                and WaveTest chassis.
#
#    --nopause                 - Do not pause between configuring the AP and
#                                running the test
#
#    --pause <seconds>         - Waits <seconds> seconds after changing the
#                                configuration on the DUT before scanning for
#                                BSSID's.  This is to allow time for the DUT
#                                to reconfigure and re-initialize its radio
#                                interfaces and begin sending beacons
#                                before we scan for BSSID's.  The default
#                                for this parameter is 15 seconds.
#
#    --notest                  - Do not run the test
#
#    --debug <level>           - Print out debugging output.  Useful values are:
#                                1 - errors only
#                                2 - warnings and errors
#                                3 - warnings, errors and info
#
#    --srcgroups  <group list> - Override the SrcGroups in the config file.
#    --destgroups <group list> - Override the DestGroups in the config file.
#
#    --tests <test list>       - Override the TestList in the config file.
#
#    --savepcaps               - Save PCAP files from test runs (regardless of
#                                whether tests PASS or FAIL).  By default,
#                                PCAP files are only saved when tests FAIL or ABORT
#
#    --var   <name> <value>    - Set variable (name) to value (value) before the config
#                                file is sourced.  This allows $name to be used in the config 
#                                file. Values may be singular values or quoted lists.
#                                See doc/advanced.txt for more info.
#
#    --db                      - DataBase support for results (default False)
#                                True  - Enable 
#                                False  - Diasble
#
#    --pf                      - User Specified PassFail criteria Enable/Disable
#                                True - Enable
#                                False - Disable (default)
#
###################################################################
}

# required for keyed lists and signal suppport
if { [catch {package require Tclx} result ]} {
    puts "Error: Tclx package required: $result\n"
    exit -1
}

if { [catch {package require Expect} result ] } {
    puts "Error: Unable to load expect package: $result\n"
    exit -1
}

if { [catch {log_user} result]} {
    puts "Error: expect not found: $result\n"
    exit -1
}

fconfigure stdout -buffering none
fconfigure stderr -buffering none

if { ![info exists env(VW_TEST_ROOT)] } {
    #
    # if the user does not have VW_TEST_ROOT set in their environment,
    # we need to figure it out from the location of this script
    #
    set VW_TEST_ROOT [file join [pwd] [file dirname [info script]] ".."]
} else {
    set VW_TEST_ROOT $env(VW_TEST_ROOT)
}

# set VERIWAVE_HOME to top
set VERIWAVE_HOME [file join $VW_TEST_ROOT ".."]
set env(VERIWAVE_HOME) $VERIWAVE_HOME

set DEBUG_LEVEL 0		

# by default, pause 15s to wait for DUT radios to init
set DUT_PAUSE 15

# simple arg parser courtesy of the tcl wiki
set arglen [llength $argv]
set index 0
while {$index < $arglen} {
    set arg [lindex $argv $index]
    switch -exact -- $arg {
	      {-c}                {set args($arg) [lindex $argv [incr index]]}
        {-f}                {set args($arg) [lindex $argv [incr index]]}
        {-h}                {set args($arg) .}
        {--help}            {set args($arg) .}

        {-tid}              -
        {--tid}             -
        {-i}                {set test_id [lindex $argv [incr index]]}

        {-o}                {set custom_log_file [lindex $argv [incr index]]}
        {-w}                {
            set ::benchmark [lindex $argv [incr index]]
            set args($arg)  [lindex $argv [incr index]]
            }
		
        {--debug}           {set DEBUG_LEVEL [lindex $argv [incr index]]}
        {--dut}             -
        {--duts}            {set args($arg) [lindex $argv [incr index]]}
        {--license}         {set args($arg) [lindex $argv [incr index]]}
		
        {--noclean}         {set args($arg) .}
        {--nodut}           -
        {--noduts}          {
            set args(--noclean)  .
            set args(--noconfig) .
            set args(--noping)   .
        }
        {--noconfig}        {
            set args($arg) .
            set DUT_PAUSE 0
        }
        {--nopause}         {set DUT_PAUSE 0}
        {--noping}          {set args($arg) .}
        {--notest}          {set args($arg) .}
        {--db}              {set args($arg) .}
        {--pf}              {set args($arg) .}

        {--srcgroups}       -
        {--srcgroup}        {set args(--srcgroups) [lindex $argv [incr index]]}
        {--destgroups}      -
        {--destgroup}       {set args(--destgroups) [lindex $argv [incr index]]}

        {--tests}           -
        {--test}            {set args(--tests) [lindex $argv [incr index]]}

        {--nopause}         {set DUT_PAUSE 0 }
        {--pause}           {set DUT_PAUSE [lindex $argv [incr index]]}

        {--savepcaps}       {set args($arg) .}

        {--var}             {
            set name        [lindex $argv [incr index]]
            set val         [lindex $argv [incr index]]
            set $name $val
            unset name
            unset val
        }

        {-e}                {set args($arg) .}
        {--environ}         {set args(-e) .}
        
        default             {puts "Unknown option \"$arg\" - ignoring"}
    }
    incr index
}



if {[info exists args(--license)]} {
    keylset global_config LicenseKey $args(--license)
}

if { [info exists args(--db)] } {
   set DbSupport "True"
   keylset global_config DbSupport $DbSupport 
} else {
   set DbSupport "False"
   keylset global_config DbSupport $DbSupport
}
if { [info exists args(--pf)] } {
   set PassFailUser "True"
   keylset global_config PassFailUser $PassFailUser
   puts "Note: User Specified Pass/Fail Criteria is enabled, Please give corresponding parameters in the config file"
} else {
   set PassFailUser "False"
   keylset global_config PassFailUser $PassFailUser
}

if {[info exists args(-h)] || [info exists args(--help)]} {
    puts $help_message
    exit 0
}

set test_runs   0
set test_fails  0
set test_aborts 0
set test_skips  0

if {[info exists args(-e)]} {
    source [file join $VW_TEST_ROOT lib tcl environ.tcl]
}

### Getting the Test case name (The config file name will be the test case name)

set testpathlist [split $args(-f) "/" ]
set testcasename [lindex $testpathlist [expr {[llength $testpathlist]-1}]]
set filep [open "temp_tc.txt" "w+"]
puts $filep $testcasename
close $filep
# Setup information
set libs {
    "[file join $VW_TEST_ROOT conf paths.tcl]"
    "[file join $VW_TEST_ROOT lib tcl cvs.tcl]"
    "[file join $VW_TEST_ROOT lib tcl range.tcl]"
    "[file join $VW_TEST_ROOT conf environment.tcl]"
}
foreach lib $libs {
    set full_lib [expr $lib]
    if {[catch {source $full_lib} result]} {
        puts "Opening of $full_lib failed: $result"
        exit -1
    }
}

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: vw_auto.tcl,v 1.96.2.1.2.7 2008/02/06 15:23:05 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: vw_auto.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.96.2.1.2.7 $"]
set cvs_date    [cvs_clean "$Date: 2008/02/06 15:23:05 $"]

set version_banner "WaveAutomation version $release_version"

# Use a user-supplied configuration file if present
if {[info exists args(-f)]} {
    set config_file $args(-f)
    lappend ::config_dirs [file dirname $config_file]
} else {
    set config_file [file join $CONF_DIR config.tcl]
}

lappend ::config_dirs $CONF_DIR

# remove vcl.vw before vcl is initialized
catch {file delete [file join $VW_TEST_ROOT ".." "vcl.vw"]}

# Load the VCL bindings
if { $tcl_platform(platform) == "windows" } {
    set lib_ext "dll"
} else {
    set lib_ext "so"
}
set lib [file join $VCL_LIB_DIR vclapi.$lib_ext]
if {[catch {load $lib} result]} {
    puts "Error: Unable to load $lib : $result"
    exit -1
}
    
set lib [file join $VCL_LIB_DIR vclinit.tcl]
if {[catch {source $lib} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}

# Libraries to load.
set libs {
    puts.tcl
    exit.tcl
    signals.tcl
    debug.tcl
    vw_keylget.tcl
    ping.tcl
    breakable_after.tcl
    exec_lines.tcl
    randomness.tcl
    configurator.tcl
}

foreach lib $libs {
    set full_lib [file join $TCL_LIB_DIR $lib]
    if {[catch {source "$full_lib"} result]} {
        puts "Error: Opening of $full_lib failed: $result"
        exit -1
    }
}

set lib [file join $LIB_DIR security_methods.tcl]
if {[catch {source "$lib"} result]} {
    puts "Error: Opening of $lib failed: $result"
    exit -1
}

#
# Print out how we were called if debug level is CFG or greater
#
debug $::DBLVL_CFG "Invoked as: $argv0 $argv"


#
# print out the version of the code we're running before we try much else
# (so if customers encounter errors, the version will be printed out
# before the program exits to aid in debugging).
#
puts "####"
puts "#### $version_banner"
puts "####"

set initial_time_stamp [clock format [clock seconds] -format "%Y%m%d-%H%M%S"]
puts "#### Starting automated test run at $initial_time_stamp."
puts "#### Using config file $config_file"
puts "####"

# if a benchmark/WML file was specified on the command line, run it now.
if {[info exists args(-w)]} {
    set ::dut_aborts 0
    set rc [::configurator::run_benchmark "$::benchmark" $args(-w)]
    exit $rc
}

proc cfg_load_module { module_type module_name } {

    debug $::DBLVL_TRACE "cfg_load_module $module_type $module_name"
    
    #
    # try to load module_name (a sub-config file)
    #
    # first search for it in the user's config directory
    # (the directory they said their config file lives with the -f option)
    #
    # If that does not work, then try conf directory under where
    # vw_auto is installed
    #
    set module_filename $module_name.tcl
    foreach dir $::config_dirs {
        set ::module_path [file join $dir $module_type $module_filename]
        debug $::DBLVL_TRACE "cfg_load_module: looking for config module $module_name in $::module_path"
        if {[file exists "$::module_path"]} {
            debug $::DBLVL_TRACE "cfg_load_module: $::module_path exists"
            if {[file readable "$::module_path"]} {
                debug $::DBLVL_TRACE "cfg_load_module: $::module_path is readable"
                if {[file size "$::module_path"]} {
                    debug $::DBLVL_TRACE "cfg_load_module: $::module_path has non-zero length"
                    set ::module_cfg_template_vers "(unknown)"
                    if {![catch {uplevel 1 {source "$::module_path"}} result]} {
                        debug $::DBLVL_INFO "cfg_load_module: Loaded config module $module_name from $::module_path"
                        debug $::DBLVL_CVS_VERSION "$module_name $module_type cfg template version: $::module_cfg_template_vers"
                        return
                    } else {
                        debug $::DBLVL_ERROR "cfg_load_module: error loading $::module_path: $result"
                    }
                } else {
                    debug $::DBLVL_TRACE "cfg_load_module: $::module_path has zero length"
                }
            } else {
                debug $::DBLVL_TRACE "cfg_load_module: $::module_path is readable"
            }
        } else {
            debug $::DBLVL_TRACE "cfg_load_module: $::module_path does not exist."
        }
    }

    debug $::DBLVL_ERROR "cfg_load_module unable to load configuration sub-module $module_name"
    exit 1
}

# Read the test automation config file
if {[catch {source $config_file} result]} {
    puts "Error: Opening of $config_file failed: $result"
    exit -1
}

if {![info exists global_config]} {
    puts "Error: No global_config section found in config file."
    puts "Does \"$config_file\" need converting?"
    exit -1
}

if {![catch {set template_version [keylget global_config TemplateVersion]}]} {
    debug $::DBLVL_CVS_VERSION "loaded test automation cfg based on template $template_version"
}

# set the directory for the results to be written
if [catch {set initial_log_dir [vw_keylget global_config LogDir]}] {
    if {[catch {set initial_log_dir [vw_keylget global_config LogsDir]}]} {
        debug $::DBLVL_INFO "No LogsDir set in config file."
    }
} 

# if the user specified a test id, use that.
# otherwise make one up.
if {[info exists test_id ]} {
    set initial_log_dir [file join $initial_log_dir $test_id]
} else {
    set initial_log_dir [file join $initial_log_dir $initial_time_stamp]
}
set ild "\{$initial_log_dir\}"

if {[catch {mkdir -path $ild} result]} {
    puts "Error: Unable to create $initial_log_dir: $result"
    exit -1
}

if {[info exists args(--license)]} {
    keylset global_config LicenseKey $args(--license)
}

# if a license key exists, set the license files
#if {![catch {set license_key [vw_keylget global_config LicenseKey]}]} {
#
#    debug $::DBLVL_INFO "Generating license files"
#
#    # remove the key so configurator doesn't try to use it
#    catch {keyldel global_config LicenseKey}
#    
#   	# license_key is now a tcl list -- join them on space. 
#   	
#   	set    license_list [join $license_key " "]
#   	
#    set    license_gen "python \"" 
#    append license_gen [file join $VW_TEST_ROOT "bin" "vwLicManager.py"]
#    append license_gen "\""
#        
#    debug $::DBLVL_TRACE "calling license manager with the command $license_gen $license_list"
#
#    if {[catch { eval [concat exec $license_gen $license_list 2>@ stdout]} result]} {
#        debug $::DBLVL_WARN "License file generation failed : $result"
#    }
#    
#    if {[catch { eval [concat exec $license_gen 2>@ stdout]} features]} {
#        debug $::DBLVL_WARN "Could not determine enabled features"
#    }
#    
#    debug $::DBLVL_INFO "Enabled Test Features: $features"
#
#}

# if the user specified their own log file, use it
if {[info exists custom_log_file]} {
    # just in case we haven't sent any output (and don't yet have the file)
    puts "Logging to $custom_log_file"
    if {[catch {file rename $::output_log_file $custom_log_file} result]} {
        ::tcl::puts "Error: Unable to use $custom_log_file for logging: $result"
        exit -1
    }
    
    set ::output_log_file $custom_log_file
}

# find the list of benchmarks, either on the command line or the config file
if {[info exists ::args(--tests)]} {
    set benchmark_list $::args(--tests)
} else {
    if [catch {set benchmark_list [vw_keylget global_config TestList]}] {
        if {[catch {set benchmark_list [vw_keylget global_config BenchmarkList]}]} {
            puts "Error: No BenchmarkList defined in config file - nothing to do"
            exit -1
        } else {
            debug $::DBLVL_WARN "BenchmarkList deprecated.  Please use TestList"
        }
    }
}

# the default is to erase/reload the ap after each configuration change.
# this will be flipped for the channel list so we don't have to wait for
# the reload when just channel has changed between tests.
set ap_reset "yes"

# generate the loops and test run code
::configurator::configurator

# save the code to a file for posterity and source'ing
::configurator::write_code_file $initial_log_dir

# Try to ping the WaveTest chassis 
#if [catch {set vw_chassis_addr [vw_keylget ::configurator::user_config chassisname]}] {
#    puts "Error: No ChassisName set in test_config"
#    exit -1
#}
#if { ![ ping_test $vw_chassis_addr ] } {
#    puts "Error: Ping failed for WaveTest chassis at $vw_chassis_addr."
#    exit -1
#}

# run the generated code
::configurator::loop_d_loop $initial_log_dir
if { $::PassFailUser == "True" } {
  if { $::test_pf_fails != 0 } {
    exit 3
  }
}
exit 0

