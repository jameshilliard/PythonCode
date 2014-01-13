#
# proc exit
#
# A replacement to the built-in exit function but with the added
# benefits of making sure the Veriwave chassis is unlocked, output
# logs are saved and a test summary is written before exiting.
#
# $Id: exit.tcl,v 1.7 2007/07/02 16:11:55 manderson Exp $
#

# move it out of the way for later use.
rename exit ::tcl::exit

proc exit {code} {

    # make sure the chassis is unlocked if there is an error
    if { $code != 0 } {
        unlock_chassis "yes"
        set status "interrupted"
        incr ::test_aborts
        if { $::test_runs == 0} {
            incr ::test_runs
        }
    } else {
        set status "completed"
    }
    
    set time_stamp [clock format [clock seconds] -format "%Y%m%d-%H%M%S"]

    puts ""
    puts "#### Automated test run $status at $time_stamp."
    puts "#### Config file used: $::config_file"
    puts ""

    puts "#### Test Summary: $::test_fails failure(s), $::test_aborts abort(s), $::test_skips skip(s) during $::test_runs test(s)."
    puts ""

    if {[info exists ::summary_header1] && [info exists ::summary_header2]} {
        puts "$::summary_header1"
        puts "$::summary_header2"
    }
    
    if {[info exists ::summary]} {
        puts "$::summary"
    }

    # if the user didn't specify a custom log file, move the one in temp into
    # the top-level results directory, only if -w was not specified.
    if {![info exists args(-w)]} {
        if {![info exists ::custom_log_file]} {
            set result "Automation startup error"
            if {[file exists [file join "$::initial_log_dir" output.log]]} {
                if {[catch {file delete [file join "$::initial_log_dir" output.log]} result]} {
                    catch {::tcl::puts "Unable to delete old log file: $result"}
                }
            }
            if {![info exists ::initial_log_dir] || [catch {file copy "$::output_log_file" [file join "$::initial_log_dir" output.log]} result]} {
                catch {::tcl::puts "Unable to move log file: $result"}
                ::tcl::exit -1
            }
            if {[catch {file delete "$::output_log_file"} result]} {
                if {$::tcl_platform(platform) != "windows"} {
                    catch {::tcl::puts "Unable to delete temp file: $result"}
                }
            }
            catch {::tcl::puts "#### Full logs are at:$::initial_log_dir/output.log"}
        } else {
            catch {::tcl::puts "#### Full logs are at: $::custom_log_file"}
        }
    }
    
    flush stdout
    sleep 3
    
    ::tcl::exit $code
}
