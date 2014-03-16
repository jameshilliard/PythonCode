#
set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: configurator.tcl,v 1.28.2.1.2.13 2008/02/06 20:01:24 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: configurator.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.28.2.1.2.13 $"]
set cvs_date    [cvs_clean "$Date: 2008/02/06 20:01:24 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

namespace eval configurator {
    
    # the list of probed argument categories found via wmlConfig.py and wmxConfig.py
    set option_list {}

    # proc configurator
    #
    # configurator examines the test configuration and generates the necessary loops
    # to iterate over all specified options.
    proc configurator {} {
    
        debug $::DBLVL_TRACE "::configurator::configurator"

        set ::configurator::external_tests {}
        set ::configurator::grouped_options {}
        
        foreach test_name $::benchmark_list {

            upvar #0 $test_name test
            if { [catch {set test_type [vw_keylget test vwTestType]}]} {
                set test_type "wml"
                set wml_needed 1
                keylset ::$test_name vwTestType "wml"
            }
            
            switch [string tolower $test_type] {
            
                "wml" {
                    set wml_needed 1
                }
            
                "external" {
                    lappend ::configurator::external_tests $test_name
                }
            }
            debug $::DBLVL_TRACE "$test_name is of type $test_type"
            
        }
        
        if {[info exists wml_needed]} {
            # find the list of valid config options from wmlConfig.py -h
            if {[get_wmlConfig_option_list] != 0} {
                puts "Error: Unable to retrieve valid configuration options from wmlConfig.py"
                exit -1
            }
        }

        # store any options for the external tests
        foreach test_name $::configurator::external_tests {
            upvar #0 ::$test_name test
            if {[catch {set test_type [vw_keylget test Test]} result]} {
                puts "Error: Test $test_name needs a Test variable defined ($result)"
                exit -1
            }
            set ::configurator::external_$test_type\_options {}
            catch {set ::configurator::external_$test_type\_options [vw_keylget test TestArgs]}
        }
        
        generate_loops
    }


    proc format_generic_list { list where } {
        
        debug $::DBLVL_TRACE "::configurator::format_generic_list"
        
        set arg "--$where="
        foreach item $list {
            append arg "$item,"
        }
        
        # trim the trailing ","
        set arg [string trimright $arg ","]
        
        return $arg
    }


    # lists like Source and Destination lists want comma separated elements
    # with quotes around the elements
    #
    proc format_python_list { list where } {
        
        debug $::DBLVL_TRACE "::configurator::format_python_list"
        
        set arg "--$where=\["
        foreach item $list {
            append arg "\'$item\',"
        }
        
        # trim the trailing ","
        set arg [string trimright $arg ","]
        append arg "\]"
        return $arg
    }



    # lists like ILoadList and FrameSize lists want comma separated elements
    # without quotes around the elements
    #
    proc format_python_list_no_quotes { list where } {

        debug $::DBLVL_TRACE "::configurator::format_python_list"

        set arg "--$where=\["
        foreach item $list {
            append arg "$item,"
        }

        # trim the trailing ","
        set arg [string trimright $arg ","]
        append arg "\]"
        return $arg
    }

        
    # proc get_wmlConfig_option_list
    #
    # calls wmlConfig to get a full list of config options that are available.
    # parses the text help message and returns a TCL list of these options.
    #
    proc get_wmlConfig_option_list {} {

        debug $::DBLVL_TRACE "::configurator::get_wmlConfig_option_list"

        set ::configurator::grouped_options {}

        foreach prog {wmlConfig.py wmxConfig.py} {
            set cmd [file join $::VW_TEST_ROOT bin $prog]
            set cmd_line "| python \"$cmd\" --parsableHelp"
    
            set fp [open "$cmd_line"]
            set data [read $fp]
            if {[catch {close $fp} result]} {
                puts "wmlConfig failed: $result"
                return -1
            }

            set data [split $data "\n"]
            foreach line $data {

                set trimmed [string trim $line]

                # a blank line?  may be a new option section coming up
                if { $trimmed == ""} {
                    set new_section 1
                    continue
                }

                if {[info exists new_section]} {
                    # there can be options with a preceding blank line
                    if {[string range $trimmed end end] == ":"} {

                        switch -glob -- $trimmed {
                            "options:"               -
                            "Client Analysis Param*" {
                                set option_section "global_options"
                            }
                            "Client Param*"                -
                            "Client Security Parameters:"  {
                                set option_section "grouped_options"
                            }
                            "Common Test Param*" {
                                set option_section "test_options"
                            }
                            "Blog Parameters:" {
                                set option_section "blog_parameters"
                            }
                            "aaa_auth_rate:" {
                                set option_section "aaa_auth_rate_options"
                            }
                            "qos_capacity:" {
                                set option_section "qos_capacity_options"
                            }
                            "qos_service:" {
                                set option_section "qos_assurance_options"
                            }
                            "rate_vs_range:" {
                                set option_section "rate_vs_range_options"
                            }
                            "roaming_benchmark:" {
                                set option_section "roaming_benchmark_options"
                            }
                            "roaming_delay:" {
                                set option_section "roaming_delay_options"
                            }
                            "tcp_goodput:" {
                                set option_section "tcp_goodput_options"
                            }
                            "unicast_packet_loss:" {
                                set option_section "unicast_packet_loss_options"
                            }
                            "unicast_max_client_capacity:" {
                                set option_section "unicast_max_client_capacity_options"
                            }
                            "voip_roam_quality:" {
                                set option_section "qos_roam_quality_options"
                            }
                            "wimix_script:" {
                                set option_section "wimix_script_options"
                            }
                            "WiMix Traffic Param*" {
                                set option_section "wimix_traffic_options"
                            }
                            "WiMix Server Param*" {
                                set option_section "wimix_server_options"
                            }
                            "Common Parameters:"    {
                                set option_section "common_options"
                            }
                            default {
                                debug $::DBLVL_CFG "Unknown option section: $trimmed"
                                set option_section "unknown_options"
                            }
                        }
                        if {![info exists ::configurator::$option_section]} {
                            set ::configurator::$option_section {}
                        }
                        if { [lsearch $::configurator::option_list $option_section] eq -1} {
                            lappend ::configurator::option_list $option_section
                            
                        }
                    
                        debug $::DBLVL_CFG "New $option_section section: $trimmed"
                        unset new_section
                    }
                }
        
                # an argument?
                
                if {![info exists option_section]} {
                    continue
                }
                if {$option_section == "common_options"} {
                    if {[regexp -- {--([[:alnum:]]+)[=\s][^\[]+\[([\w\,\s]+)} $trimmed all arg group_str]} {
                        set group_list [split $group_str ","]
                       
                        foreach group $group_list {
                            set group [string trim $group]
                            switch $group {
                                "roaming_delay" -
                                "roaming_benchmark" -
                                "qos_roam_quality" {
                                    if {[lsearch $::configurator::grouped_options $arg] eq -1} {
                                        debug $::DBLVL_CFG "Found grouped_options:$arg"
                                        lappend ::configurator::grouped_options $arg
                                    }
                                }
                                
                                "qos_capacity" -
                                "qos_service"  {
                                    if {![info exists ::configurator::qos_common_options]} {
                                        set ::configurator::qos_common_options {}
                                    }
                                    if { [lsearch $::configurator::qos_common_options $arg] eq -1} {
                                        debug $::DBLVL_CFG "Found qos_common_options:$arg"
                                        lappend ::configurator::qos_common_options $arg
                                    }
                                }
                                
                                default {
                                    set cur_section "global_options"
                                    if {![info exists ::configurator::global_options]} {
                                        set ::configurator::global_options {}
                                    }
                                    
                                    if {[lsearch $::configurator::global_options $arg] eq -1} {
                                        debug $::DBLVL_CFG "Found global_options:$arg"
                                        lappend ::configurator::global_options $arg
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if {[regexp -- {--([[:alnum:]]+)[=\s]} $trimmed all arg]} {
                        if {[info exists option_section] && [info exists ::configurator::$option_section]} {
        
                            # some of these are handled separately
                            switch $arg {
        
                                "help"                -
                                "parsableHelp"        -
                                "norun"               -
                                "generateMetadata"    {
                                
                                    debug $::DBLVL_CFG "Ignoring $option_section:$arg"
                                }
                                
                                default {
                                    debug $::DBLVL_CFG "Found $option_section:$arg"
                                    lappend ::configurator::$option_section $arg
                                }
                            }
                        } else {
                            debug $::DBLVL_CFG "Found argument \"$trimmed\" without a section"
                        }
                    }
                }
            }
        }
        
        # sort the lists to make generated code consistent
        foreach o $::configurator::option_list {
            set $o [lsort $o]
        }

        set ::configurator::grouped_options [lsort -unique $::configurator::grouped_options]
        # the options we need that wmlConfig doesn't know about
        lappend ::configurator::global_options "Channel"
        lappend ::configurator::global_options "DhcpServer"
        lappend ::configurator::global_options "PortMonitors"
        
        lappend ::configurator::grouped_options "GroupType"
        lappend ::configurator::grouped_options "Dut"
        lappend ::configurator::grouped_options "AuxDut"
        lappend ::configurator::grouped_options "WepKey40Ascii"
        lappend ::configurator::grouped_options "WepKey40Hex"
        lappend ::configurator::grouped_options "WepKey128Ascii"
        lappend ::configurator::grouped_options "WepKey128Hex"
        lappend ::configurator::grouped_options "PskAscii"
        lappend ::configurator::grouped_options "PskHex"        
        lappend ::configurator::grouped_options "ServiceProfile"
        lappend ::configurator::grouped_options "BssidIndex"
        lappend ::configurator::grouped_options "ApVlanName"
        lappend ::configurator::grouped_options "RadiusInternal"
        lappend ::configurator::grouped_options "ApVlanPorts"

        lappend ::configurator::wimix_script_options "clientAnalysisProfiles"
        lappend ::configurator::wimix_script_options "ClientMix"
        lappend ::configurator::wimix_script_options "TrafficMix"

        lappend ::configurator::test_options "PreTestHook"
        lappend ::configurator::test_options "PostTestHook"
        lappend ::configurator::group_options "PreGroupHook"
        lappend ::configurator::group_options "PostGroupHook"
        
        return 0
    }


    proc write_code_file { dir} {

        debug $::DBLVL_TRACE "::configurator::write_code_file"

        if { $::DEBUG_LEVEL >= $::DBLVL_TRACE } {
            debug DBLVL_TRACE "Dumping code: start"
            foreach line [split $::configurator::code "\n"] {
                puts $line
            }
            debug DBLVL_TRACE "Dumping code: end"
        }

        if {[catch {open [file join $dir "gen_code.tcl"] "w"} fp]} {
            puts "Error: Unable to open generated code file: $fp"
            exit -1
        }
        
        # a normal puts will log the data
        ::tcl::puts $fp $::configurator::code
        
        if {[catch {close $fp} result]} {
            puts "Error: Unable to close generated code file: $result"
            exit -1
        }
    }


    proc loop_d_loop { dir } {

        debug $::DBLVL_TRACE "::configurator::loop_d_loop"

        set ::configurator::code_path [file join $dir "gen_code.tcl"]

        # so much work in so little code
        set ::configurator::run_time 1
        uplevel 1 {source $::configurator::code_path}
    }


    proc deprecated_option { key was is } {
        
        debug $::DBLVL_TRACE "::configurator::deprecated_option"
        
        # warn once per run
        if {![info exists ::configurator::deprecated]} {
            set ::configurator::deprecated {}
        }
        if {[lsearch $::configurator::deprecated $key] == -1} {
            debug $::DBLVL_WARN "$was is deprecated.  Please use $is"
            lappend ::configurator::deprecated $key
        }
        set val [keylget ::configurator::user_config $key]
        keyldel ::configurator::user_config $key
        keylset ::configurator::user_config [string tolower $is] $val
    }
    
    
    #
    # merge_config
    #   merges any items in the new_list keyed list into orig_list, 
    #   overwriting any existing values in the original.  returns new list
    #                          
    proc merge_config { orig_list new_list } {
         
        debug $::DBLVL_TRACE "::configurator::merge_config"

        if {![info exists orig_list]} {
            debug $::DBLVL_CFG "Source list does not exist"
            set orig_list {}
        }
        
        if {![info exists new_list]} {
            debug $::DBLVL_CFG "New list does not exist"
            return $orig_list
        }
        
        foreach key [keylkeys new_list] {
            regsub -all {_} $key {} new_key
            set new_key [string tolower $new_key]
            set new_val [keylget new_list $key]
            if {[catch {set old_val [vw_keylget orig_list $new_key]}]} {
                debug $::DBLVL_CFG "Adding $key ($new_val)"
                keylset orig_list $key $new_val
            } elseif { $old_val != $new_val } {
                debug $::DBLVL_CFG "Replacing $key ($new_val)"
                keyldel orig_list $new_key
                keylset orig_list $new_key $new_val
            }
        }
        
        return $orig_list
    }
    

    proc loop_or_var { name list {cur_group {}} {extra_groups {}} {wml 1} {upvar 0} } {

        debug $::DBLVL_TRACE "::configurator::loop_or_var ($name $list $cur_group)"

        set ca ::configurator::code_append
        
        # sometimes $list can be a list and not a reference to a list
        if { $upvar == 1 } {
            upvar #0 $list true_list
        } else {
            set true_list $list
            ###True list is the one which is taken for iterations
        }
        
        # these are not eligible for loop generation 
        switch -- $name {
            FrameSizeList  -
            ILoadList      -
            Source         -
            Destination    -
            AuxDut         -
            ApVlanPorts    -
            RadiusInternal -
            LogsDir        -
            ClientMix      -
            TrafficMix     -
            MediumCapacity         -
            clientAnalysisProfiles -
            RefPowerList -
            RefRateList  -
            PortMonitors           {
                set list_len 1
            }
            
            default {
                set list_len [llength $true_list]
            }
        }
        
        # if the passed in variable name is not a list, just set the variable up
        # otherwise build a for loop and increment the loop level
        if { $list_len == 1 && $wml == 1 } {
            # concat because these can have weird leading and trailing whitespace
            set conc [concat $true_list]

            # these are handled elsewhere
            switch -- $name {
                "Channel"        -
                "ServiceProfile" {
                }
                
                default {
                    $ca "keylset ::configurator::cfg_$::configurator::loop_level $name \"$conc\""
                }
            }
            if { $cur_group != "" } {
                $ca "keylset grp_$cur_group $name \"$conc\""
                $ca "debug $::DBLVL_CFG \"setting $cur_group->$name to $conc\""
            }
            foreach group $extra_groups {
                $ca "if \{\[catch \{vw_keylget $group $name\}\]\} \{"
                $ca " keylset grp_$group $name \"$conc\""
                $ca " debug $::DBLVL_CFG \"setting $group->$name to $conc\""
                $ca "\}"
            }
        } else {
            set next_level [expr $::configurator::loop_level + 1]
            #RJS Only update header the once if multiple tests are run
            if { $::bench_cnt > 1} {
                append ::summary_header1 [format "%-17s " [string range "$name" 0 16]]
                append ::summary_header2 "################# "
            }
            $ca ""
            $ca "set logs_at_level_$next_level \$log_dir"
            $ca "set summary_at_level_$next_level \$::summary_line"
            if { $upvar == 1 } {
                $ca "foreach $name\_$next_level \$$list \{\n"
            } else {
                $ca "foreach $name\_$next_level \{$list\} \{\n"
            }
            $ca " set log_dir \[file join \$logs_at_level_$next_level $name=\$$name\_$next_level\]"
            $ca " set ::configurator::cfg_$next_level \$::configurator::cfg_$::configurator::loop_level"
            incr ::configurator::loop_level
            $ca "set ::configurator::loop_level $::configurator::loop_level"
            $ca "set ::summary_line \[format \"%s%-17s \" \$summary_at_level\_$::configurator::loop_level \[string range \$$name\_$::configurator::loop_level 0 14\]\]"
            # channels are group info
            if {$name != "Channel" } {
                $ca "keylset ::configurator::cfg_$::configurator::loop_level $name \$$name\_$::configurator::loop_level"
            }
            if { $cur_group != "" } {
                if {$name == "Channel"} {
                   foreach group $extra_groups {
                        $ca " keylset grp_$group $name \$$name\_$::configurator::loop_level"
                        $ca " debug $::DBLVL_CFG \"setting grp_$group->$name to \$$name\_$::configurator::loop_level\""
                   }
                }

                $ca "keylset grp_$cur_group $name \$$name\_$::configurator::loop_level"
                $ca "debug $::DBLVL_CFG \"setting $cur_group->$name to \$$name\_$::configurator::loop_level\""
            }
            foreach group $extra_groups {
                $ca "if \{\[catch \{vw_keylget $group $name\}\]\} \{"
                $ca " keylset grp_$group $name \$$name\_$::configurator::loop_level" 
                $ca " debug $::DBLVL_CFG \"setting $cur_group->$name to \$$name\_$::configurator::loop_level\""
                $ca "\}"
            }
        }
    }


    proc code_append { snippet } {

        set indent ""
        for {set space 0} {$space<$::configurator::loop_level} {incr space} {
            append indent " "
        }
        
        if { $snippet != "" } {
            debug $::DBLVL_CFG "Code - $snippet"
        }
        append ::configurator::code "$indent$snippet\n"
    }

    
    proc vwConfig_group_bssid { cfg_name cli_args } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_group_bssid"

        set ca ::configurator::code_append
        
        upvar 2 $cfg_name cfg_list
        
        # check for a BSSID at the top of the group
        catch {set bssid [vw_keylget cfg_list Bssid]}

        # maybe it is at the DUT level?
        # grab the DUT from this group
        if {[catch {set duts [vw_keylget cfg_list Dut]} result]} {
            puts "Error: Group $cfg_name has no configured Dut ($result)"
            exit -1
        }
        
        if {[catch {set group_type [vw_keylget cfg_list GroupType]} result]} {
            puts "Error: Group $cfg_name has no configured GroupType ($result)"
            exit -1
        }
        
        if {[llength $duts] > 1} {
            set duts [lindex $duts 0]
            debug $::DBLVL_WARN "More than one DUT per group not supported.  Using \"$duts\""
        }
        upvar #0 $duts dut_cfg
        catch {set bssid [vw_keylget dut_cfg Bssid]}

        # finally, try for one at the interface
        set target_type [vwConfig_group_type $cfg_name $cfg_list]
                
        if {[catch {set int_list [vw_keylget dut_cfg Interface]} result]} {
            puts "Error: No Interface section defined in $cfg_name->$duts ($result)"
            exit -1
        }

        foreach interface [keylkeys int_list] {
            set int_cfg [vw_keylget int_list $interface]
            if {[catch {set int_type [vw_keylget int_cfg InterfaceType]} result]} {
                puts "Error: No InterfaceType defined in $cfg_name->$duts->$interface ($result)"
                exit -1
            }
            if { $int_type == $target_type } {
                catch {set bssid [vw_keylget int_cfg Bssid]}
            }
        }
        
        if {[info exists bssid]} {
            debug $::DBLVL_INFO "Using BSSID \"$bssid\""
            lappend cli_args "--Bssid=$bssid"
        } else {
            debug $::DBLVL_INFO "No BSSID found, will probe"
        }
        
        return $cli_args
    }
    
    
    proc vwConfig_model_info { cfg_name cli_args } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_gen_model_info"
        
        # only the first DUT in the first group gets checked.
        if {[info exists ::model_info]} {
            return $cli_args
        }
        
        set ca ::configurator::code_append
        
        upvar 2 $cfg_name cfg_list
        
        # grab the DUT from this group
        if {[catch {set duts [vw_keylget cfg_list Dut]} result]} {
            puts "Error: Group $cfg_name has no configured Dut ($result)"
            exit -1
        }
        
        if {[catch {set group_type [vw_keylget cfg_list GroupType]} result]} {
            puts "Error: Group $cfg_name has no configured GroupType ($result)"
            exit -1
        }
        
        if {[llength $duts] > 1} {
            set duts [lindex $duts 0]
            debug $::DBLVL_WARN "More than one DUT per group not supported.  Using \"$duts\""
        }
        upvar #0 $duts dut_cfg
        
        # save the name of the DUT
        set ::dut_name $duts
        
        # figure out the VENDOR for this DUT"
        if {[catch {set dut_vendor [vw_keylget dut_cfg Vendor]}]} {
            puts "Error: No Vendor is defined for DUT $duts"
            exit -1
        }
        
        # figure out the APModel/MODEL of this DUT"
        if {[catch {set dut_model [vw_keylget dut_cfg APModel]}]} {
            if {[catch {set dut_model [vw_keylget dut_cfg Model]} result]} {
                puts "Error: No APModel is defined for DUT $duts ($result)"
                exit -1
            }
        }
        
        set dut_vendor_model $dut_vendor
        append dut_vendor_model " "
        append dut_vendor_model $dut_model
        lappend cli_args "--APModel=$dut_vendor_model"

        if {[catch {set dut_sw_version [vw_keylget dut_cfg APSWVersion]}]} {
            debug $::DBLVL_WARN "No APSWVersion defined for DUT $duts"
            set dut_sw_version "Unspecified"
        }
        lappend cli_args "--APSWVersion=$dut_sw_version"
        
        if {[catch {set dut_switch_model [vw_keylget dut_cfg WLANSwitchModel]}]} {
            debug $::DBLVL_WARN "No WLANSwitchModel is defined for DUT $duts"
            set dut_switch_model "Unspecified"
        }
        lappend cli_args "--WLANSwitchModel=$dut_switch_model"
        
        if {[catch {set dut_switch_version [vw_keylget dut_cfg WLANSwitchSWVersion]}]} {
            debug $::DBLVL_WARN "No WLANSwitchSWVersion is defined for DUT $duts"
            set dut_switch_version "Unspecified"
        }
        lappend cli_args "--WLANSwitchSWVersion=$dut_switch_version"

        set ::model_info {}

        return $cli_args
    }


    proc vwConfig_framesize_iload_lists { cfg_list cli_args } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_framesize_iload_lists"
        
        set ca ::configurator::code_append
        
        # generate the frame size list if needed
        switch $::current_benchmark_name {
            
            "rate_vs_range"                     -
            "mesh_latency_aggregate"            -
            "mesh_latency_per_hop"              -
            "mesh_throughput_aggregate"         -
            "mesh_throughput_per_hop"           -
            "mesh_max_forwarding_rate_per_hop"  -
            "unicast_latency"                   -
            "unicast_max_client_capacity"       -
            "unicast_max_forwarding_rate"       -
            "unicast_packet_loss"               -
            "unicast_unidirectional_throughput" -
            "tcp_goodput"                       {

                if {[catch {set frame_size_list [vw_keylget $cfg_list FrameSizeList]} result]} {
                    puts "Error: $::benchmark needs a FrameSizeList defined ($result)."
                    exit -1
                }
                lappend cli_args [format_python_list_no_quotes "$frame_size_list" FrameSizeList]
                catch {keyldel $cfg_list FrameSizeList}
            }
            
            default {
                debug $::DBLVL_CFG "$::benchmark has no frame size list"
            }
        }
        
        # generate the intended load list if needed
        switch $::current_benchmark_name {

            "rate_vs_range"               -
            "unicast_latency"             -
            "unicast_max_client_capacity" -
            "mesh_latency_aggregate"      -
            "mesh_latency_per_hop"        -
            "unicast_packet_loss"         {
                if {[catch {set iload_list [vw_keylget $cfg_list ILoadList]} result]} {
                    puts "Error: $::benchmark needs an ILoadList defined ($result)."
                    exit -1
                }
                lappend cli_args [format_python_list_no_quotes "$iload_list" ILoadList]
                catch {keyldel $cfg_list ILoadList}
            }
            default {
                debug $::DBLVL_CFG "$::benchmark has no intended load list"
            }
        }
        
        # sanity check for tests that need matching list sizes
        switch $::current_benchmark_name {
            "rate_vs_range"                -
            "unicast_latency"              -
            "mesh_latency_aggregate"       -
            "mesh_latency_per_hop"         -
            "unicast_max_client_capacity" {
                if {"$::current_benchmark_name" == "unicast_latency" || "$::current_benchmark_name" == "mesh_latency_aggregate" || "$::current_benchmark_name" == "mesh_latency_per_hop"} {
                    if {[llength $frame_size_list] != [llength $iload_list]} {
                        puts "Error: Test $::benchmark requires ILoadList and FrameSizeList to be of equal length."
                        puts "Error: ILoadList=$iload_list, FrameSizeList=$frame_size_list"
                        exit -1
                    }
                }
            }
        }
        
        # add in the medium capacity if present
        if {![catch {set med_cap [vw_keylget $cfg_list MediumCapacity]} result]} {
            lappend cli_args [format_python_list "$med_cap" MediumCapacity]
            catch {keyldel $cfg_list MediumCapacity}
        }        
        
        return $cli_args
    }

    
    proc vwConfig_group_ip_addrs { cfg_name cli_args } {

        debug $::DBLVL_TRACE "::configurator::vwConfig_group_ip_addrs"

        upvar 2 $cfg_name cfg_list
        
        set target_type [vwConfig_group_type $cfg_name $cfg_list]

        if {[catch {set duts [vw_keylget cfg_list Dut]} result]} {
            puts "Error: Group $cfg_name has no Dut configured ($result)"
            exit -1
        }
        
        if {[llength $duts] > 1} {
            set duts [lindex $duts 0]
            debug $::DBLVL_WARN "More than one DUT per group not supported.  Using \"$duts\""
        }
        
        if {[catch {set int_list [vw_keylget $duts Interface]} result]} {
            puts "Error: No Interface section defined in $cfg_name->$duts ($result)"
            exit -1
        }

        set int_found 0
        foreach interface [keylkeys int_list] {
            set int_cfg [vw_keylget int_list $interface]
            if {[catch {set int_type [vw_keylget int_cfg InterfaceType]} result]} {
                puts "Error: No InterfaceType defined in $cfg_name->$duts->$interface ($result)"
                exit -1
            }
            if { $int_type == $target_type } {
                set int_found 1
                break
            }
        }
        if { $int_found == 0 } {
            puts "Error: No interface of type \"$target_type\" found"
            exit -1
        }
        
        if {[catch {set dhcp [vw_keylget cfg Dhcp]}]} {
            debug $::DBLVL_CFG "No DHCP option found for $cfg_name defaulting to disable"
            set dhcp "Disable"
        } else {
            if {[string equal -nocase "enable" $dhcp]} {
                set dhcp "Enable"
            } else {
                set dhcp "Disable"
            }
        }
        debug $::DBLVL_CFG "DHCP option for $interface is $dhcp"
        if {[string equal "Disable" $dhcp]} {
            if {[catch {set tx_gateway [vw_keylget cfg TestGate]}]} {
                 debug $::DBLVL_CFG "No gateway found for $cfg_name"
            } else {
                lappend cli_args "--Gateway=$tx_gateway"
            }
            if {[catch {set tx_base [vw_keylget cfg TestBase]}]} {
                debug $::DBLVL_CFG "No test base found for $cfg_name"
            } else {
                lappend cli_args "--BaseIp=$tx_base"
            }
            if {[catch {set tx_mask [vw_keylget cfg TestMask]}]} {
                debug $::DBLVL_CFG "No subnet mask found for $cfg_name"
            } else {
                lappend cli_args "--SubnetMask=$tx_mask"
            }
            if {[catch {set tx_incr [vw_keylget cfg TestIncr]}]} {
                debug $::DBLVL_CFG "No ip increment found for $cfg_name"
            } else {
                lappend cli_args "--IncrIp=$tx_incr"
            }
        }
        
        return $cli_args
    }


    proc vwConfig_group_aaa { cfg_name cli_args } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_group_aaa"
        
        set ca ::configurator::code_append
        
        upvar 2 $cfg_name cfg_list
        
        if {[catch {set security_method [vw_keylget cfg_list Method]}]} {
            debug $::DBLVL_CFG "$cfg_name has no method and needs no AAA configuration"
            return $cli_args
        }

        foreach method $::ALL_SECURITY_METHODS {
            if {$method == $security_method} {
                set method_found 1
                break
            }
        }
        if {![info exists method_found]} {
            debug $::DBLVL_ERROR "Security method \"$security_method\" is not valid.  Choices are:\n$::ALL_SECURITY_METHODS"
            exit -1
        }

        # grab the PSK key if we need it"
        # if both HEX and ASCII are defined, defaults to ASCII"
        if { $security_method == "WPA-PSK" || $security_method == "WPA2-PSK" || \
             $security_method == "WPA-PSK-AES" || $security_method == "WPA2-PSK-TKIP"} {
            set is_ascii 1
            if [catch {set psk [vw_keylget cfg_list PskAscii]}] {
                set is_ascii 0
                if [catch {set psk [vw_keylget cfg_list PskHex]}] {
                    set is_ascii 1
                    set psk "whatever"
                }
            }
            lappend cli_args "--NetworkKey=$psk"

            if { $is_ascii } {
                lappend cli_args "--KeyType=ascii"
            } else {
                lappend cli_args "--KeyType=hex"
            }
        }
        
        # 40bit WEP keys"
        # if both HEX and ASCII are defined, defaults to ASCII"
        set is_ascii 1
        if { $security_method == "WEP-Open-40" || $security_method == "WEP-SharedKey-40" } {
            if [catch {set wep [vw_keylget cfg_list WepKey40Ascii]}] {
                set is_ascii 0
                if [catch {set wep [vw_keylget cfg_list WepKey40Hex]}] {
                    set is_ascii 1
                    set wep "12345"
                }
            }
            lappend cli_args "--NetworkKey=$wep"

            if { $is_ascii } {
                lappend cli_args "--KeyType=ascii"
            } else {
                lappend cli_args "--KeyType=hex"
            }
        }

        # 128bit WEP keys"
        # if both WEP and ASCII are defined, defaults to ASCII"
        set is_ascii 1
        if { $security_method == "WEP-Open-128" || $security_method == "WEP-SharedKey-128" } {
            if [catch {set wep [vw_keylget cfg_list WepKey128Ascii]}] {
                set is_ascii 0
                if [catch {set wep [vw_keylget cfg_list WepKey128Hex]}] {
                    set is_ascii 1
                    set wep "123456789ABCD"
                }
            }
            lappend cli_args "--NetworkKey=$wep"

            if { $is_ascii } {
                lappend cli_args "--KeyType=ascii"
            } else {
                lappend cli_args "--KeyType=hex"
            }
        }

        foreach { key value } [array get ::$security_method] {
            lappend cli_args "--$key=$value"
        }

        return $cli_args
    }
    
    
    proc external_args { cfg_list } {

        debug $::DBLVL_TRACE "::configurator::external_args"
            
        upvar #0 $::benchmark this_test

        set cli_args {}
                
        # need the command line
        if {[catch {lappend cli_args [vw_keylget this_test TestLocation]} result]} {
            puts "Error: $::benchmark has no TestLocation line ($result)"
            exit -1
        }

        # any extra args
        if {![catch {set these_args [vw_keylget this_test TestExtraArgs]}]} {
            foreach option $these_args {
                lappend cli_args $option
            }
        } else {
            debug $::DBLVL_CFG "$::benchmark has no extra arguments"
        }
        
        set prefix "--"
        catch {set prefix [vw_keylget this_test TestArgsPrefix]}

        set equals "="
        catch {set equals [vw_keylget this_test TestArgsEquals]}
        
        # and the loopable args
        if {![catch {set these_args [vw_keylget this_test TestArgs]}]} {
            foreach option $these_args {
                if {![catch {set val [vw_keylget $cfg_list $option]}]} {
                    lappend cli_args "$prefix$option$equals$val"
                    debug $::DBLVL_CFG "adding $prefix$option$equals$val"
                }
            }
        } else {
            debug $::DBLVL_CFG "$::benchmark needs no arguments"
        }
                
        return $cli_args
    }
    

    proc test_needs_groups { benchmark } {
        
        debug $::DBLVL_TRACE "::configurator::test_needs_groups"

        switch $benchmark {
            "wimix_script" -
            "wave_client"  {
                return 0
            }
            default {
                return 1
            }
        }
    }


    proc vwConfig_global_args { cfg_list } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_global_args"

        # need to know where wml/wmxConfig is
        if { $::current_benchmark_name != "wimix_script" && 
             $::current_benchmark_name != "wave_client" } {
            set cli_args [file join $::VW_TEST_ROOT bin wmlConfig.py]
        } else {
            set cli_args [file join $::VW_TEST_ROOT bin wmxConfig.py]
        }
        set cli_args "\"$cli_args\""    

        set vwConfig_mode "waveapps"

        if {[info exists ::args(--notest)]} {
            set vwConfig_mode "wmlonly"
        }

        # may not be a built-in benchmark
        upvar #0 $::benchmark this_test
        if {![catch {set test_location [vw_keylget this_test TestLocation]}]} {
            set vwConfig_mode "wml"
            lappend cli_args "-e"
            lappend cli_args $test_location
        }

        lappend cli_args "-m"
        lappend cli_args $vwConfig_mode
        
        # tell vwConfig which test this will be.
        lappend cli_args "-t"
        if { $::current_benchmark_name == "wave_client" } {
            lappend cli_args "wimix_script"
        } else {
            lappend cli_args $::current_benchmark_name
        }
        
        # send our debug level down
        if [ info exists ::DEBUG_LEVEL] {
            lappend cli_args "-d"
            lappend cli_args $::DEBUG_LEVEL
        }
        
        if [ info exists ::DbSupport ] {
            if { $::DbSupport == "False"} { #if the user hasn't set the cmd line Db option see if its set in configuration file 
                if { ![catch {set ::DbSupport [vw_keylget global_config DbSupport]}] } {
                  puts "Note: User has configured database support as: $::DbSupport" 
                }
            } else { 
              puts "Note: Database support is enabled by command line override"
            }
        }

        if { $::DbSupport == "True"} {
            lappend cli_args "--db"
            lappend cli_args $::DbSupport 
            if {![catch {set ::DbType [vw_keylget global_config DbType]}]} {
               lappend cli_args "--dbtype"
               lappend cli_args $::DbType
            } else {
              puts "Database type not given by the user. "
            }
            if {$::DbType == "mysql"} {
                    if {![catch {set ::DbName [vw_keylget global_config DbName]}]} {
                        lappend cli_args --dbname 
                        lappend cli_args $::DbName 
                    } else {
                        puts " User has not specified the DataBase Name defaulting to veriwave"
                        lappend cli_args --dbname 
                        lappend cli_args "veriwave"     
                    }

                    if {![catch {set ::DbUserName [vw_keylget global_config DbUserName]}]} {
                        lappend cli_args --dbusername 
                        lappend cli_args $::DbUserName
                    } else {
                        puts " User has not specified the username for database defaulting to root"
                        lappend cli_args --dbusername 
                        lappend cli_args "root"     
                    }
                 
                    if {![catch {set ::DbPassword [vw_keylget global_config DbPassword]}]} {
                        lappend cli_args --dbpassword
                        lappend cli_args $::DbPassword 
                    } else {
                        puts "User has not specified the password for the access to database defaulting to veriwave"
                        lappend cli_args --dbpassword
                        lappend cli_args "veriwave"     
                    }

                    if {![catch {set ::DbServerIP [vw_keylget global_config DbServerIP]}]} {
                        lappend cli_args --dbserverip
                        lappend cli_args $::DbServerIP 
                    } else {
                        puts " User has not specified the Database server IP name or address defaulting to localhost"
                        lappend cli_args --dbserverip
                        lappend cli_args "localhost"     
                    }

                    if  {![catch {set ::TestCaseName [vw_keylget global_config TestCaseName]}]} {
                        lappend cli_args --testcasename
                        lappend cli_args $::TestCaseName
                    } elseif  {[info exists ::TestCaseName]} {
                        lappend cli_args --testcasename
                        lappend cli_args $::TestCaseName
                    } else {
                        puts " User has not specified the test case Name defaulting NoTestName "
                        lappend cli_args --testcasename
                        lappend cli_args "NoTestName"
                    }

                    if {![catch {set ::TestCaseDescription [vw_keylget global_config TestCaseDescription]}]} {
                        lappend cli_args --testcasedescription
                        lappend cli_args $::TestCaseDescription 
                    } else {
                        puts "Note: User has not given any description for test case hence storing no description"
                        lappend cli_args --testcasedescription
                        lappend cli_args "NO Description given"     
                    }
            }
        }
                
        if [ info exists ::PassFailUser ] {
            if { $::PassFailUser == "False" } {
                if {![catch {set ::PassFailUser [vw_keylget global_config PassFailUser]}]} {
                    puts "Note: The UserPassFail criteria support is configured as: $::PassFailUser"
                }
            } else {
                puts "Note: UserPassFail criteria is enabled by command line override."
            }
            lappend cli_args "--pf"
            lappend cli_args $::PassFailUser
         }

        # send licenses if they exist.
        if {![catch {set license_key [vw_keylget global_config LicenseKey]}]} {
            lappend cli_args "-l"
            lappend cli_args [join $license_key ","]
        }
         
        # figure out which options we need to look at
        #
        # while roaming delay does have options, they are
        # used per group and not per test

        set configs {global_options test_options}
        
        switch -- $::current_benchmark_type {
        
            "wml" {
                switch -- $::current_benchmark_name {
            
                    "unicast_client_capacity" -
                    "unicast_packet_loss" -
                    "unicast_max_client_capacity"       -
                    "aaa_auth_rate"           -
                    "rate_vs_range"           -
                    "tcp_goodput"             -
                    "roaming_benchmark"       -
                    "roaming_delay"           -
                    "wimix_script"            {
                        lappend configs "$::current_benchmark_name\_options"
                    }

                    "wave_client" {
                        lappend configs "wimix_script_options"
                    }
                    
                    "roaming_benchmark"       -
                    "roaming_delay"           {
                        lappend configs "$::current_benchmark_name\_options"
                        #lappend configs "roaming_common_options"
                    }
                                            
                    "mesh_latency_aggregate"            -
                    "mesh_latency_per_hop"              -
                    "mesh_throughput_aggregate"         -
                    "mesh_throughput_per_hop"           -
                    "mesh_max_forwarding_rate_per_hop"  -
                    "unicast_latency"                   -
                    "unicast_max_forwarding_rate"       -
                    "unicast_call_capacity"             -
                    "unicast_unidirectional_throughput" {
                        #append configs {}
                    }
            
                    "qos_roam_quality" {
                        lappend configs "qos_common_options"
                        lappend configs "$::current_benchmark_name\_options"
                        #lappend configs "roaming_common_options"
                    }
                        
                    "qos_capacity"   -
                    "qos_assurance"  {
                        lappend configs "qos_common_options"
                        lappend configs "$::current_benchmark_name\_options"
                    }
                
                    default {
                        puts "Error: Unknown test - $::benchmark $::current_benchmark_name"
                        exit -1
                    }
                }
            }
            
            default {
                puts "Error: Unknown test type - $::current_benchmark_name ($::current_benmark_type)"
                exit -1
            }
        }
        
        set cli_args [vwConfig_framesize_iload_lists $cfg_list $cli_args]

        foreach list_name $configs {
            # yeesh.
            upvar 0 ::configurator::$list_name list
            foreach option $list {
                if {![catch {set val [vw_keylget $cfg_list $option]}]} {

                    # handled later
                    switch -- $option {
                            "Destination"    		 -
                            "Source"         		 -
                            "DhcpServer"    		 -
                            "ClientMix"      		 -
                            "TrafficMix"     		 -
                            "numClients"     		 -
                            "perClients"     		 -
                            "totalClientPer" 		 -
                            "PreTestHook"    		 -
                            "PostTestHook"   		 -
                            "PreGroupHook"     		 -
                            "PostGroupHook"          -
                            "clientAnalysisProfiles" -
                            "PortMonitors"           {
                        }
                        
                        default {
                            lappend cli_args "--$option=$val"
                            debug $::DBLVL_CFG "adding --$option=$val"
                        }
                    }
                }
            }
        }
        
        if {[test_needs_groups $::current_benchmark_name]} {
            if {[catch {set s_groups [vw_keylget $cfg_list Source]} result]} {
                puts "Error: No Source defined in global or test configs ($result)"
                exit -1
            } else {
                lappend cli_args [format_python_list $s_groups "Source"]
            }
            if {[catch {set d_groups [vw_keylget $cfg_list Destination]} result]} {
                puts "Error: No Destination defined in global or test configs ($result)"
                exit -1
            } else {
                lappend cli_args [format_python_list $d_groups "Destination"]
            }
        } else {
            if {$::current_benchmark_name == "wimix_script" ||
                $::current_benchmark_name == "wave_client" } {
                upvar #0 $cfg_list tmp_config
                set s_groups [vwConfig_wimix_find_groups $tmp_config]
            }
            
            set cli_args [vwConfig_wimix_profiles $cfg_list $cli_args]
            
            if {$::current_benchmark_name == "wave_client" } {
                set cli_args [vwConfig_wave_client_analysis $cfg_list $cli_args]
            }
        }
        
        set cli_args [vwConfig_port_monitor $cfg_list $cli_args]
        
        # reset the model info pointer
        if {[info exists ::model_info]} {
            unset ::model_info
        }
        
        lappend cli_args "--TimeStampDir=False"
        
        if {[info exists ::dut_channel]} {
            unset ::dut_channel
        }

        if {[info exists ::args(--savepcaps)]} {
            lappend cli_args "--savelogs"
        }
        
        return $cli_args
    }
    

    proc vwConfig_wimix_test_type { cfg_list } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_wimix_test_type"
        
        if {[catch {set wimix_type [vw_keylget cfg_list wimixMode]} result]} {
            puts "Error: No wimixMode defined in test ($result)"
            exit -1
        }
        return $wimix_type
    }
    
    proc vwConfig_wimix_get_traffic_profiles_list { cfg_list } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_wimix_get_trafic_options"

        set t_profiles {}

        upvar #0 $cfg_list tmp_cfg
        set wimix_type [vwConfig_wimix_test_type $tmp_cfg]

        switch "$wimix_type" {
            
            "Client" {
                if {[catch {set cmix [vw_keylget $cfg_list ClientMix]} result]} {
                    puts "Error: No ClientMix found in configuration ($result)"
                    exit -1
                }
                foreach key [keylkeys cmix] {
                    set profile [vw_keylget cmix $key]
                    if {[catch {set ttypes [vw_keylget profile TrafficType]} result]} {
                        puts "Error: No TrafficType found for profile $key ($result)"
                        exit -1
                    }
    
                    if {[llength $ttypes] > 1} {
                        set commas ""
                        foreach type $ttypes {
                            append commas "$type,"
                        }
                        set commas [string trimright $commas ","]
                        lappend t_profiles $commas
                    } else {
                        lappend t_profiles $ttypes
                    }
                }
            }
            
            "Traffic" {
                if {[catch {set tmix [vw_keylget $cfg_list TrafficMix]} result]} {
                    puts "Error: No TrafficMix found in configuration ($result)"
                    exit -1
                }
                foreach key [keylkeys tmix] {
                    lappend t_profiles $key
                }
            }
            
            default {
                puts "Error: Unknown wimixMode ($wimix_type)"
                exit -1
            }
        }

        return $t_profiles        
    }


    proc vwConfig_wimix_get_traffic_profiles { cfg_list } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_wimix_get_trafic_options"

        set t_profiles {}

        upvar #0 $cfg_list tmp_cfg
        set wimix_type [vwConfig_wimix_test_type $tmp_cfg]

        switch "$wimix_type" {
            
            "Client" {
                if {[catch {set cmix [vw_keylget $cfg_list ClientMix]} result]} {
                    puts "Error: No ClientMix found in configuration ($result)"
                    exit -1
                }
                foreach key [keylkeys cmix] {
                    set profile [vw_keylget cmix $key]
                    if {[catch {set ttypes [vw_keylget profile TrafficType]} result]} {
                        puts "Error: No TrafficType found for profile $key ($result)"
                        exit -1
                    }
                    foreach ttype $ttypes {
                        lappend t_profiles $ttype
                    }
                }
            }
            
            "Traffic" {
                if {[catch {set tmix [vw_keylget $cfg_list TrafficMix]} result]} {
                    puts "Error: No TrafficMix found in configuration ($result)"
                    exit -1
                }
                foreach key [keylkeys tmix] {
                    lappend t_profiles $key
                }
            }
            
            default {
                puts "Error: Unknown wimixMode ($wimix_type)"
                exit -1
            }
        }
        
        return $t_profiles        
    }


    proc vwConfig_wave_client_analysis { cfg_list cli_args } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_wave_client_analysis"
        
        if { [catch {set profiles [vw_keylget $cfg_list clientAnalysisProfiles]}]} {
            puts "Warning: No clientAnalysisProfiles found in config."
            return $cli_args
        }

        foreach profile $profiles {
            lappend cli_args "--ClientFlowProfile"
            lappend cli_args $profile

            if { ! [info exists ::$profile] } {
                puts "Error: $profile referenced in clientAnalysisProfiles but not defined"
                exit -1
            }
            foreach key [keylkeys ::$profile] {
                set val [vw_keylget ::$profile $key]
                lappend cli_args "--$key=$val"
            }
        }
     
        return $cli_args
    }

    proc vwConfig_port_monitor { cfg_list cli_args } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_port_monitor"
        
        if { [catch {set monitors [vw_keylget $cfg_list PortMonitors]}]} {
            debug $::DBLVL_CFG "No PortMonitors found in config."
            return $cli_args
        }

        foreach monitor $monitors {
            if { ! [info exists ::$monitor] } {
                puts "Error: $monitor referenced in PortMonitors but not defined"
                exit -1
            }

            if { [catch {set p [vw_keylget ::$monitor Port]}]} {
                puts "Error: No Port defined for $monitor"
                exit -1
            }
            if {[catch {set c [vw_keylget ::$monitor Channel]}]} {
                puts "Error: No Channel defined for $monitor"
                exit -1
            }
            lappend cli_args "--PortMonitor=$p,$c"
        }
     
        return $cli_args
    }

    proc vwConfig_wimix_profiles { cfg_list cli_args } {
    
        debug $::DBLVL_TRACE "::configurator::vwConfig_wimix_profiles"

        set server_list {}

        set t_profiles [vwConfig_wimix_get_traffic_profiles $cfg_list]
        foreach profile $t_profiles {
            if {![info exists ::$profile]} {
                puts "Error: Wimix traffic profile \"$profile\" referenced but not defined"
                exit -1
            }
            lappend cli_args "--WimixTrafficProfile"
            lappend cli_args "$profile"
            
            foreach option $::configurator::wimix_traffic_options {
                if {![catch {set val [vw_keylget ::$profile $option]}]} {
                    lappend cli_args "--$option=$val"
                }
            }
            
            if {[catch {lappend server_list [vw_keylget ::$profile WimixtrafficServer]}]} {
                puts "Error: No WimixtrafficServer defined for traffic profile \"$profile\""
                exit -1
            }
        }  

        foreach server [lsort -unique $server_list] {
            if {![info exists ::$server]} {
                puts "Error: Wimix server profile \"$server\" referenced but not defined."
                exit -1
            }
            lappend cli_args "--WimixServerProfile"
            lappend cli_args "$server"
            
            foreach option $::configurator::wimix_server_options {
                if {![catch {set val [vw_keylget ::$server $option]}]} {
                    lappend cli_args "--$option=$val"
                }
            }
        }
        
        upvar #0 $cfg_list tmp_cfg
        set wimix_type [vwConfig_wimix_test_type $tmp_cfg]

        switch "$wimix_type" {

            "Client" {
                
                set s_groups [vwConfig_wimix_find_groups $tmp_cfg]
                lappend cli_args [format_python_list "$s_groups" clientList]

                lappend cli_args [format_python_list [vwConfig_wimix_get_traffic_profiles_list $cfg_list] trafficList]

                if {[catch {set cmix [vw_keylget $cfg_list ClientMix]} result]} {
                    puts "Error: No ClientMix found in configuration ($result)"
                    exit -1
                }
                
                set percentage_list {}
                set per_total 0
                set delay_list {}
                set end_list {}
                
                foreach key [keylkeys cmix] {
                    set profile [vw_keylget cmix $key]
                    if {[catch {set perClients [vw_keylget profile Percentage]} result]} {
                        if {[catch {set perClients [vw_keylget profile perClients]} result]} {
                            puts "Warning: No Percentage/perClients found for profile $key"
                            set perClients 0
                        }
                    }
                    lappend percentage_list $perClients
                    set per_total [expr $per_total + $perClients]
                    
                    if {[catch {set delay [vw_keylget profile Delay]} result]} {
                        if {[catch {set delay [vw_keylget profile startTime]} result]} {
                            set delay 0
                        }
                    }
                    lappend delay_list $delay
                    
                    if {[catch {set end [vw_keylet profile End]} result]} {
                        if {[catch {set end [vw_keylget profile endTime]} result]} {
                            set end "END"
                        }
                    }
                    lappend end_list $end

                }
                lappend cli_args [format_python_list_no_quotes $percentage_list "perClients"]
                lappend cli_args "--totalClientPer=$per_total"
                lappend cli_args [format_python_list_no_quotes $delay_list "delay"]
                lappend cli_args [format_python_list $end_list "end"]
            }
            
            "Traffic" {
                if {[catch {set tmix [vw_keylget $cfg_list TrafficMix]} result]} {
                    puts "Error: No TrafficMix found in configuration ($result)"
                    exit -1
                }
                
                set client_list {}
                set traffics_list {}
                set percentage_list {}
                set pps_list {}
                set delay_list {}
                set end_list {}
                set per_total 0

                foreach key [keylkeys tmix] {
                    lappend traffics_list $key
                    set profile [vw_keylget tmix $key]
                    if {[catch {set perClients [vw_keylget profile Percentage]} result]} {
                        if {[catch {set perClients [vw_keylget profile perClients]} result]} {
                            puts "Warning: No Percentage/perClients found for profile $key"
                            set perClients 0
                        }
                    }
                    lappend percentage_list $perClients
                    set per_total [expr $per_total + $perClients]
                    
                    if {[catch {set client_type [vw_keylget profile ClientType]} result]} {
                        puts "Error: No ClientType defined for profile $key"
                        exit -1
                    }
                    lappend client_list $client_type

                    if {[catch {set delay [vw_keylget profile Delay]} result]} {
                        if {[catch {set delay [vw_keylget profile startTime]} result]} {
                            set delay 0
                        }
                    }
                    lappend delay_list $delay
                    
                    if {[catch {set end [vw_keylet profile End]} result]} {
                        if {[catch {set end [vw_keylget profile endTime]} result]} {
                            set end "END"
                        }
                    }
                    lappend end_list $end
                    
                    if {![info exists ::$key]} {
                        puts "Error: Wimix traffic profile \"$key\" referenced but not defined"
                        exit -1
                    }

                    switch "$key" {

                        "VOIPG711" {
                            set frmSize 236
                            set computedPps 100
                        }

                        "VOIPG723" {
                            set frmSize 96
                            set computedPps 100
                        }

                        "VOIPG729" {
                            set frmSize 96
                            set computedPps 66
                        }

                        default {
                            if {[catch {set frmSize [vw_keylget ::$key WimixtrafficFramesize]}]} {
                                if {[catch {set frmSize [vw_keylget ::$key Framesize]}]} {
                                    debug $::DBLVL_ERROR "No WimixtrafficFramesize/Framesize defined for \"$key\""
                                    exit -1
                                }
                            }
                            if {[catch {set direction [vw_keylget ::$key WimixtrafficDirection]}]} {
                                if {[catch {set direction [vw_keylget ::$key Direction]}]} {
                                  debug $::DBLVL_ERROR "No WimixtrafficDirection/Direction defined for \"$key\""
                                  exit -1
                                }
                            }
                            set dirFactor 1
                            if { $direction == "bidirectional" } {
                                set dirFactor 2
                            }
                            if {[catch {set loadMode [vw_keylget $cfg_list loadMode]} ]} {
                               debug $::DBLVL_ERROR "No loadMode defined."
                               exit -1
                            }
                            if { $loadMode == 0 } {
                                if {[catch {set loadVal [vw_keylget $cfg_list loadVal]}]} {
                                    debug $::DBLVL_ERROR "No loadVal defined.  Using 20000"
                                    exit -1
                                }
                            } else {
                                if {[catch {set loadVal [vw_keylget $cfg_list loadSweepStart]}]} {
                                    debug $::DBLVL_ERROR "No loadSweepStart defined."
                                    exit -1
                                }
                            } 
                            set loadPerFlow [expr "$perClients*$loadVal/100"]
                            set computedPps [expr "round($loadPerFlow*1000/($frmSize*$dirFactor*8))"]
                        }
                    }
                    lappend pps_list $computedPps
                }
                
                lappend cli_args [format_python_list $client_list "clientGroupList"]
                lappend cli_args [format_python_list $traffics_list "trafficList"]
                lappend cli_args [format_python_list_no_quotes $percentage_list "perTraffic"]
                lappend cli_args "--totalTrafficPer=$per_total"
                lappend cli_args [format_python_list_no_quotes $pps_list "loadPps"]
                lappend cli_args [format_python_list_no_quotes $delay_list "delay"]
                lappend cli_args [format_python_list $end_list "endTime"]


            }
            
            default {
                puts "Error: Unknown wimixMode ($wimix_type)"
                exit -1
            }
        }

        return $cli_args
    }
    
    proc vwConfig_wimix_find_groups { cfg_list } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_wimix_find_groups"
    
        set groups {}

        # the groups are in different places depending on the wimix type
        set wimix_type [vwConfig_wimix_test_type $cfg_list]
        switch "$wimix_type" {
            "Client" {
                if {[catch {set cmix [vw_keylget cfg_list ClientMix]} result]} {
                    puts "Error: No ClientMix defined for test ($result)"
                    exit -1
                }
                set groups [keylkeys cmix]
            }
            
            "Traffic" {
                if {[catch {set tmix [vw_keylget cfg_list TrafficMix]} result]} {
                    puts "Error: No TrafficMix defined for test ($result)"
                    exit -1
                }
                foreach key [keylkeys tmix] {
                    if {[catch {set ttype [vw_keylget tmix $key]} result]} {
                        puts "Error: Unable to retrieve $key from list ($result)"
                        exit -1
                    }
                    if {[catch {set ctype [vw_keylget ttype ClientType]} result]} {
                        puts "Error: No ClientType defined for TrafficMix \"$key\" ($result)"
                        exit -1
                    }
                    lappend groups $ctype
                }
            }
            
            default {
                puts "Error: wimixMode neither Client nor Traffic"
                exit -1
            }
        }

        return $groups
    }
    
    
    proc vwConfig_group_type { cfg_name cfg_list { channel 0 }} {

        debug $::DBLVL_TRACE "::configurator::vwConfig_group_type"
                
        # extract the physical chassis:card.port connection info out of the DUT
        # XXX - how to handle when more than one DUT is configured here?
        if {[catch {set group_type [vw_keylget cfg_list GroupType]} result]} {
            puts "Error: Group $cfg_name has no GroupType configured ($result)"
            exit -1
        }
        
        # XXX - this might be a good place to remove radio options from ethernet groups
        #       and vice versa.
        switch -glob -- $group_type {
            "802.3" {
                set target_type "802.3"
            }
            "802.11*" {
                # narrow things down a bit
                if { $channel == 0 } {
                    if {[catch {set channel [vw_keylget cfg_list Channel]} result]} {
                        puts "Error: Group $cfg_name has no Channel configured ($result)"
                        exit -1
                    }
                }
                # XXX - someday support Japanese channel 8 (if necessary)
                set target_type "802.11n"
                if { $group_type != "802.11n" && $group_type != "802.11abgn" } {
                    if { $channel <= 14 } {
                        set target_type "802.11bg"
                    } else {
                        set target_type "802.11a"
                    }
                }
            }
            default {
                puts "Error: $group_type is not a valid GroupType (802.3, 802.11a, 802.11bg, 802.11n)"
                exit -1
            }
        }

        return $target_type
    }
    
    
    # find an interface that matches a passed in type for a dut
    proc get_dut_interface { dut_name target_type } {

        debug $::DBLVL_TRACE "::configurator::get_dut_interface"
        
        upvar #0 ::$dut_name dut_cfg
        
        if {[catch {keylkeys dut_cfg} result]} {
            puts "Error: Missing configuration for AP $dut_name ($result)"
            exit -1
        }
        
        if {[catch {set int_list [vw_keylget dut_cfg Interface]} result]} {
            puts "Error: No Interface section defined in $dut_name ($result)"
            exit -1
        }

        foreach interface [keylkeys int_list] {
            set int_cfg [vw_keylget int_list $interface]
            if {[catch {set int_type [vw_keylget int_cfg InterfaceType]} result]} {
                puts "Error: No InterfaceType defined in $dut_name->$interface ($result)"
                exit -1
            }
            if { $int_type == $target_type } {
                return $int_cfg
            }
        }

        # not found
        debug $::DBLVL_WARN "No interface of type $target_type found for DUT $dut_name"
        return {}
    }
    
    
    # find the bssid for the passed in DUT info
    proc get_dut_interface_bssid { dut_name target_type } {

        debug $::DBLVL_TRACE "::configurator::get_dut_interface_bssid"

        set bssid {}
        set int_cfg [get_dut_interface $dut_name $target_type]
        if {[catch {set bssid [vw_keylget int_cfg Bssid]}]} {
            debug $::DBLVL_WARN "No Bssid defined for $dut_name->$target_type"
        }
        
        return $bssid
    }
    
    
    # find the chassis:card.port for the passed in DUT info
    proc get_dut_interface_wavetest_port { dut_name target_type } {

        debug $::DBLVL_TRACE "::configurator::get_wavetest_port"
        
        set int_cfg [get_dut_interface $dut_name $target_type]
        if {[catch {set found_port [vw_keylget int_cfg WavetestPort]} result]} {
            puts "Error: No WavetestPort defined in $dut_name->$target_type ($result)"
            exit -1
        }
        
        return $found_port
    }
    
    
    proc vwConfig_group_args { cfg_name cli_args cfg_global } {
        
        debug $::DBLVL_TRACE "::configurator::vwConfig_group_args"
        
        # the group name has "grp_" as a prefix, remove it to send to vwConfig
        set true_group [string range $cfg_name 4 end]
        lappend cli_args "--ClientGroup=$true_group"
        debug $::DBLVL_CFG "adding --ClientGroup=$true_group"
        
        upvar 1 $cfg_name cfg_list

        set cli_args [vwConfig_model_info     $cfg_name $cli_args ]

        set cli_args [vwConfig_group_aaa      $cfg_name $cli_args ]
        set cli_args [vwConfig_group_bssid    $cfg_name $cli_args ]
        set cli_args [vwConfig_group_ip_addrs $cfg_name $cli_args ]
        
        set target_type [vwConfig_group_type $cfg_name $cfg_list]

        if {[catch {set duts [vw_keylget cfg_list Dut]} result]} {
            puts "Error: Group $true_group has no Dut configured ($result)"
            exit -1
        }
        
        if {[llength $duts] > 1} {
            set duts [lindex $duts 0]
            debug $::DBLVL_WARN "More than one DUT per group not supported.  Using \"$duts\""
        }
        
        set found_port [get_dut_interface_wavetest_port $duts $target_type]
        lappend cli_args "--wt_card=$found_port"
        
        foreach option $::configurator::grouped_options {
            if {![catch {set val [vw_keylget cfg_list $option]}]} {
                switch -- $option {
                    # these options are handled later (or not at all)
                    "Dut"            -
                    "WepKey40Ascii"  -
                    "WepKey40Hex"    -
                    "WepKey128Ascii" -
                    "WepKey128Hex"   -
                    "PskAscii"       -
                    "PskHex"         -
                    "ServiceProfile" -
                    "BssidIndex"     -
                    "ApVlanName"     -
                    "ApVlanPorts"    -
                    "RadiusInternal" -
                    "AuxDut"         -
                    "PortMonitors"    {
                    }
                    
                    "GroupType" {
                        if { $val == "802.11n" || $val == "802.11abgn" } {
                            if {[catch {vw_keylget cfg_list phyInterface}]} {
                                debug $::DBLVL_INFO "11n group detected. Setting phyInterface"
                                lappend cli_args "--phyInterface=802.11n"
                            }
                        }
                    }
                    
                    default {
                        lappend cli_args "--$option=$val"
                        debug $::DBLVL_CFG "adding --$option=$val"
                    }
                }
            }
        }
        
        # if the test is roaming, compute and figure out those options
        if { ($::current_benchmark_name == "roaming_delay" || \
              $::current_benchmark_name == "roaming_benchmark" || \
              $::current_benchmark_name == "qos_roam_quality" || \
              $::current_benchmark_name == "wave_client" || \
              $::current_benchmark_name == "wimix_script") && $target_type != "802.3" } {
            foreach option "$::configurator::roaming_delay_options" {
                
                switch -- $option {
                    "ssid"         -
                    "portNameList" -
                    "bssidList"    {
                        # ignoring these for now
                    }
                    default {
                        if {[info exists val]} {
                            unset val
                        }
                        # check for this option at the group level.
                        if {[catch {set val [vw_keylget cfg_list $option]}]} {
                            
                            # not found, try the global config space
                            catch {set val [vw_keylget $cfg_global $option]}
                        }
                        # if an option found, build an argument
                        if {[info exists val]} {
                            lappend cli_args "--$option=$val"
                            debug $::DBLVL_CFG "adding --$option=$val"
                        }
                    }
                }
            }
            
            # ssid
            if {[string first roam $::current_benchmark_name] != -1} {
                if {[info exists val]} {
                    unset val
                }
                if {[catch {set val [vw_keylget cfg_list Ssid]}]} {
                    catch {set val [vw_keylget $cfg_global Ssid]}
                }
                if {[info exists val]} {
                    lappend cli_args "--ssid=$val"
                    debug $::DBLVL_CFG "adding --ssid=$val"
                }
            }
            
            if {[catch {set aux_dut [vw_keylget cfg_list AuxDut]} result]} {
                if {[string first roam $::current_benchmark_name] != -1} {
                    puts "Error: At least one AP needs to be specified in AuxDut for group $true_group ($result)"
                    exit -1
                } else {
                    set aux_dut {}
                }
            }
            
            # portNameList, bssidList & channelList
            set pl {}
            set bl {}
            set cl {}
                
            # the AP's info
            lappend pl $found_port
            set b_id [get_dut_interface_bssid $duts $target_type]
            if { $b_id != {} } {
                lappend bl $b_id
            }
            set chan {}
            catch {set chan [vw_keylget cfg_list Channel]}
            lappend cl $chan
            if {![info exists ::dut_channel]} {
                set ::dut_channel $chan
            }
            
            foreach ap $aux_dut {
                
                upvar #0 ::$ap aux_cfg
                
                # default to use the channel from the group level
                # but use it if defined at the DUT level
                set aux_chan $chan
                catch {set aux_chan [vw_keylget aux_cfg Channel]}
                lappend cl $aux_chan
                
                set aux_target [vwConfig_group_type $cfg_name $cfg_list $aux_chan]

                lappend pl [get_dut_interface_wavetest_port $ap $aux_target]
                lappend bl [get_dut_interface_bssid         $ap $aux_target]

            }
            
            # if the port list and bssid list are not the same size, complain to the user
            # and remove all bssids.
            if { [llength $pl] != [llength [concat $bl]] } {
                debug $::DBLVL_WARN "Number of configured BSSIDs does not match number of APs. Probing all"
                set bl {}
            }
            lappend cli_args [format_generic_list "$pl" portNameList]
            if { [llength [concat $bl]] != 0 } {
                lappend cli_args [format_generic_list "$bl" bssidList]
            }
            lappend cli_args [format_generic_list "$cl" ChannelList]
        }
        
        return $cli_args
    }
    
    
    proc run_external_test { cmd } {
    
        debug $::DBLVL_TRACE "::configurator::run_external_test"
        
        return [exec_lines "$cmd"]
    }
    
 
    proc run_wml_test { cmd } {
        
        debug $::DBLVL_TRACE "::configurator::run_wml_test"
        
        set rc 0      

        set suffix "wml"
        if { $::current_benchmark_name == "wave_client" } {
            set suffix "wcl"
        }
        
        set wavetest_cfg_file [file join $::log_dir $::current_benchmark_name.$suffix]
        lappend cmd "$wavetest_cfg_file"
        
        debug $::DBLVL_CFG "python $cmd"
        
        set rc [exec_lines "python $cmd"]

        return $rc
    }
    
    
    proc generate_loops {} {
        
        debug $::DBLVL_TRACE "::configurator::generate_loops"

        set ca ::configurator::code_append
        
        # loop level, needed for command line generation
        set ::configurator::loop_level 0
        $ca "set ::configurator::loop_level 0"

        # test counters
        $ca "set ::test_case_number 0"
        $ca "set dut_aborts 0"
        $ca "set test_skips 0"
        $ca "set test_aborts 0"
        $ca "set test_pf_fails 0"
        $ca "set test_pass 0"
        $ca "set test_fails 0"
        
        # card groupings for vwConfig
        set wml_group 0
        
        set ::summary_header1 [format "Result %-20s " "Test"]
        set ::summary_header2 "###### #################### "
        set ::bench_cnt 0 
        foreach ::benchmark $::benchmark_list {
            incr ::bench_cnt
            $ca "set ::summary_line \[format \"%-20s \" \[string range $::benchmark 0 19\]\]"
            upvar #0 $::benchmark bench_cfg
            if {![info exists bench_cfg]} {
                debug $::DBLVL_ERROR "No test called \"$::benchmark\" configured.  Skipping"
                break
            }
            
            # grab the test name and type out of the keyed list
            if {[catch {set ::current_benchmark_name [vw_keylget bench_cfg Test]}]} {
                if {[catch {set ::current_benchmark_name [vw_keylget bench_cfg Benchmark]}]} {
                    debug $::DBLVL_WARN "No Test set for $::benchmark, using name"
                    set ::current_benchmark_name $::benchmark
                } else {
                    debug $::DBLVL_WARN "Benchmark deprecated.  Please use Test"
                }
            }
            if {[catch {set ::current_benchmark_type [string tolower [vw_keylget bench_cfg vwTestType]]}]} {
                    debug $::DBLVL_WARN "No vwTestType set for $::benchmark, using WML"
                    set ::current_benchmark_type "WML"
            }
            
            $ca "set benchmark $::benchmark"
            $ca "set current_benchmark_name $::current_benchmark_name"
            $ca "set current_benchmark_type $::current_benchmark_type"
            $ca ""
            
            if {$::configurator::loop_level != 0} {
                puts "Error: Code generation error at test loop ($::configurator::loop_level)"
                puts $::configurator::code
                exit -1
            }
        
            $ca "set log_dir \[file join \$initial_log_dir \$benchmark\]"

            # combine original global and config for this specific test into working_cfg
            set working_config [merge_config $::global_config $bench_cfg]

            # check for group overrides from the command line
            if {[info exists ::args(--srcgroups)]} {
                if {[catch {keylset working_config Source $::args(--srcgroups)} result]} {
                    puts "Error: Unable to set Source from command line ($result)"
                    exit -1
                }
            }
            if {[info exists ::args(--destgroups)]} {
                if {[catch {keylset working_config Destination $::args(--destgroups)} result]} {
                    puts "Error: Unable to set Destination from command line ($result)"
                    exit -1
                }
            }

            if {[test_needs_groups $::current_benchmark_name]} {

                if {[catch {set s_groups [vw_keylget working_config Source]} result]} {
                    puts "Error: No Source defined in test ($result)"
                    exit -1
                }
            
                if {[catch {set d_groups [vw_keylget working_config Destination]} result]} {
                    puts "Error: No Destination defined in test ($result)"
                    exit -1
                }
            } else {
                if {$::current_benchmark_name == "wimix_script" ||
                    $::current_benchmark_name == "wave_client"} {
                    set s_groups [vwConfig_wimix_find_groups $working_config]
                    set d_groups {}
                }
            }
            
            set dut_group_list {}

            # build list of groups out of src and dest lists
            set group_list [concat $s_groups $d_groups]

            # walk through each group in order of definition, merging the items in the
            # group config into the working_config.  we do this before any of the 
            # loop_or_var mumbo jumbo to make sure we find any global or test specific
            # options that may have been defined at the group level.
            #foreach group $group_list {
            #    debug $::DBLVL_CFG "Searching $group for global/test options"
            #    upvar #0 $group group_cfg
            #    set working_config [merge_config $working_config $group_cfg]
            #}

            # reset the config list that will be used at actual test time
            $ca "set ::configurator::cfg_$::configurator::loop_level \{\}"

            # at this point we've got a pretty good idea of what needs to be done.
            # the group options are still muddled because we just overwrote them
            # all while figuring out the test and global options.  we'll deal with that
            # later.  time to generate some loops for the global options, generic test
            # options and test specific options (if any)
            set configs {global_options test_options}
            switch -exact -- $::current_benchmark_type {
            
                "wml" {
                    switch -exact -- $::current_benchmark_name {
                
                        "unicast_call_capacity"   -
                        "unicast_packet_loss"     -
                        "unicast_client_capacity" -
                        "unicast_max_client_capacity"       -
                        "roaming_delay"           -
                        "roaming_benchmark"       -
                        "rate_vs_range"           -
                        "aaa_auth_rate"           -
                        "tcp_goodput"             -
                        "wimix_script"            {
                            append configs " $::current_benchmark_name\_options"
                        }
                        
                        "wave_client" {
                            append configs " wimix_script_options"
                        }
                
                        "mesh_latency_aggregate"            -
                        "mesh_latency_per_hop"              -
                        "mesh_throughput_aggregate"         -
                        "mesh_throughput_per_hop"           -
                        "mesh_max_forwarding_rate_per_hop"  -
                        "unicast_latency"                   -
                        "unicast_max_forwarding_rate"       -
                        "unicast_unidirectional_throughput" {
                            append configs {}
                        }
                
                        "qos_roam_quality" - 
                        "qos_capacity" -
                        "qos_assurance"  {
                            append configs " qos_common_options $::current_benchmark_name\_options"
                        }
                    
                        default {
                            puts "Error: Unknown test - $::benchmark $::current_benchmark_name"
                            exit -1
                        }
                    }
                }
                
                "external" {
                    append configs " external_$::current_benchmark_name\_options"
                }
            }

            foreach list_name $configs {
                # yeesh.
                upvar 0 ::configurator::$list_name list
                if {[info exists list]} {
                    foreach option $list {
                        if {![catch {set val [vw_keylget working_config $option]}]} {
                            if { $option != "Channel" } {
                                loop_or_var "$option" "$val"
                            }
                        }
                    }
                }
            }
            # walk through each group in the order they were defined generating loops
            # for all the grouped options.
            foreach group $group_list {
                $ca "set grp_$group \{\}"
            }

            # now look for group options defined in the working config which are not defined in
            # any of the group configs.
            foreach option $::configurator::grouped_options {
                if {![catch {set val [vw_keylget working_config $option]}]} {
                    set found_in_group 0
                    foreach group $group_list {
                        if {![catch {set val2 [vw_keylget $group $option]}]} {
                            incr found_in_group
                        }
                    }
                    if { $found_in_group == 0 } {
                        if {$option != "Channel"} {
                           # channel handled below.
                           loop_or_var $option "$val" "$group" "$group_list"
                        }
                    }
                }
            }

            if {![catch {set val [vw_keylget working_config "Channel"]}]} {
                set group_channels 0
                foreach group $group_list {
                if {![catch {set val [vw_keylget $group "Channel"]}]} {
                    # if the channel is not configured in any group but is configured
                    # as a gloabl option Pass it in as a group option since it really is
                    #
                    incr group_channels
                    }
                }
                if { $group_channels == 0 } {
                    loop_or_var "Channel" "$val" "$group" "$group_list"
                }
            }
            foreach group $group_list {
                debug $::DBLVL_CFG "Generating loops from group $group"
                foreach option $::configurator::grouped_options {
                    if {![catch {set val [vw_keylget $group $option]}]} {
                        # RJS Do not pass a group list here as that would
                        # set all the other groups group options to the
                        # value in this group
                        #loop_or_var "$option" "$val" "$group" "$group_list"
                        loop_or_var "$option" "$val" "$group" ""
                    }
                    if { $::current_benchmark_name == "roaming_delay" || $::current_benchmark_name == "roaming_benchmark" ||  $::current_benchmark_name == "qos_roam_quality"} {
                        foreach option "$::configurator::roaming_delay_options" {
                            if {![catch {set val [vw_keylget $group $option]}]} {
                                loop_or_var "$option" "$val" "$group" "$group_list"
                            }
                        }
                    }
                }
            }
            $ca ""
            
            # we're now at the innermost loop of the generated code
            # time to generate the command line for the test
            
            # restuff the logging directory since it changes with each test
            $ca "keylset ::configurator::cfg_$::configurator::loop_level LogsDir \"\$log_dir\""

            # the global and test options
            $ca "if \{\$::current_benchmark_type == \"wml\" \} \{"
            $ca " set cli_args \[::configurator::vwConfig_global_args ::configurator::cfg_$::configurator::loop_level\]"
            $ca "\} elseif \{\$::current_benchmark_type == \"external\"\} \{"
            $ca " set cli_args \[::configurator::external_args ::configurator::cfg_$::configurator::loop_level \]"
            $ca "\} else \{"
            $ca " puts \"Error: Unknown vwTestType for \$::current_benchmark_name(\$::current_benchmark_test)\""
            $ca " exit -1"
            $ca "\}"

            $ca "if \{\$::current_benchmark_type == \"wml\" \} \{"
            $ca " foreach group \{$group_list\} \{"
            $ca "  set cli_args \[::configurator::vwConfig_group_args grp_\$group \$cli_args ::configurator::cfg_$::configurator::loop_level\]"
            $ca " \}"
            $ca "\}"
                        
            # and now the AP configuration / WML Generation / test execution
            $ca "incr ::test_case_number"
            $ca "if \{\[catch \{file mkdir \$log_dir\} result\]\} \{"
            $ca " puts \"Error: Cannot mkdir \$log_dir : \$result\""
            $ca " exit -1"
            $ca "\}"
            $ca ""
                
            $ca "puts \"\""
            $ca "puts \"###\""
            $ca "set time_stamp \[clock format \[clock seconds\] -format \"%Y%m%d-%H%M%S\"\]"
            $ca "puts \"### BEGIN testcase \$::test_case_number at \$time_stamp:\""
            $ca "puts \"\""
            $ca ""

            $ca "set rc 0"
            
            $ca "puts \"### BEGIN DUT configuration for testcase \$::test_case_number\""
            
            $ca "set ::configurator::configured_duts {}"
            foreach group $group_list {

                $ca "puts \"### Configuring DUT for group $group testcase \$::test_case_number\""
                $ca "incr rc \[::configurator::configure_dut grp_$group $::configurator::loop_level \]"
            }
            
            $ca "puts \"### END DUT configuration for testcase \$::test_case_number rc = \$rc\""

            # run the pre test hooks
            foreach group $group_list {
                set dut_list [::configurator::build_dut_list "$group"]
                foreach dut $dut_list {
                    $ca "set cfg \[::configurator::build_test_config grp_$group $::configurator::loop_level $dut \]"
                    $ca "incr rc \[::configurator::run_hook \$cfg \"PreGroupHook\" \]"
                    
                }
            }
            $ca "# the PreTestHook will get the config from the last configured DUT"
            $ca "incr rc \[::configurator::run_hook \$cfg \"PreTestHook\" \]"
            
            
            $ca "if \{ \$rc == 0 \} \{"

            if {$::DUT_PAUSE > 0} {
                $ca "  debug \$::DBLVL_INFO \"Pausing $::DUT_PAUSE seconds for DUT radio interfaces to initialize\""
                $ca "  breakable_after $::DUT_PAUSE"
                $ca ""
            }

            if {![catch {set vcal_log [vw_keylget ::global_config VcalLogging]}]} {
                $ca " # set the environment up for logging"
                $ca " set env(VCAL_LOGGING) $vcal_log"
                $ca " set env(VCAL_LOGGING_FILE) \[file join \$log_dir \"vcal_vwconfig.log\"\]"
            }

            $ca "puts \"### BEGIN run of testcase \$::test_case_number\""

            # figure out the config used for this test run
            $ca "if \{\$::current_benchmark_type == \"wml\" \} \{"
            $ca " puts \"### Building WML file for testcase \$::test_case_number\""
            $ca " set rc \[::configurator::run_wml_test \$cli_args\]"
            $ca "\} elseif \{\$::current_benchmark_type == \"external\"\} \{"
            $ca " set rc \[::configurator::run_external_test \$cli_args\]"
            $ca "\} else \{"
            $ca " puts \"Error: Unknown vwTestType for \$::current_benchmark_name(\$::current_benchmark_test)\""
            $ca " exit -1"
            $ca "\}"

            # and the post test hooks
            foreach group $group_list {
                # dut_list determined at pre-test time
                foreach dut $dut_list {
                    $ca "set cfg \[::configurator::build_test_config grp_$group $::configurator::loop_level $dut \]"
                    $ca "incr rc \[::configurator::run_hook \$cfg \"PostDUTHook\" \]"
                }
            }
            $ca "# the PostTestHook will get the config from the last configured DUT"
            $ca "incr rc \[::configurator::run_hook \$::configurator::test_config \"PostTestHook\" \]"
            
            $ca "puts \"### END run of testcase \$::test_case_number\""
            $ca ""

            $ca " set time_stamp \[clock format \[clock seconds\] -format \"%Y%m%d-%H%M%S\"\]"
            $ca ""
            $ca " puts \"### END Testcase \$::test_case_number\""

            $ca "if \{ \$dut_aborts > 0 \} \{"
            $ca " puts \"### Testcase \$::test_case_number Error: DUT/AP configuration Error at \$time_stamp.\""
            $ca " set result \"SKIP\""
            $ca " incr test_skips"
            $ca "\} elseif \{\$rc == 0\} \{"
            $ca " puts \"### Testcase \$::test_case_number Passed at \$time_stamp.\""
            $ca " set result \"PASS\""
            $ca " incr test_pass"
            $ca "\} elseif \{\$rc >0 && \$rc<=2 \} \{"
            $ca " puts \"### Testcase \$::test_case_number Aborted at \$time_stamp.\""
            $ca " set result \"ABORT\""
            $ca " incr test_aborts"
            if { [ info exists ::PassFailUser ]} { 
              if { [catch {set tempPassFailUser [vw_keylget global_config PassFailUser]}] } {
                  set tempPassFailUser "False"
              }
              if { $::PassFailUser == "True"  || $tempPassFailUser == "True" } {
                  $ca "\} elseif \{\$rc == 3\} \{"
                  $ca " puts \"### Testcase \$::test_case_number PF criteria Failed at \$time_stamp.\""
                  $ca " set result \"PF:FAIL\""
                  $ca " incr test_pf_fails"
              }  
            }
            $ca "\} else \{"
            $ca " puts \"### Testcase \$::test_case_number Failed at \$time_stamp.\""
            $ca " set result \"FAIL\""
            $ca " incr test_fails"
            $ca "\}"
            if { $::PassFailUser == "True" } {
            $ca " puts \"### Intermediate Results: PASS: \$test_pass FAIL: \$test_fails ABORT: \$test_aborts PF_FAIL: \$test_pf_fails Skipped: \$test_skips  \""
            } else {
            $ca " puts \"### Intermediate Results: PASS: \$test_pass FAIL: \$test_fails ABORT: \$test_aborts Skipped: \$test_skips  \""
            }
            $ca "append ::summary \[format \"%-6s %s\\n\" \$result \$::summary_line\]"

            if {$::configurator::loop_level > 0} {
                $ca " \}"
            }
            $ca "\}"
            $ca ""

            # unroll the generated loop endings
            while {$::configurator::loop_level >= 2} {
                incr ::configurator::loop_level -1
                $ca "\}"
            }
            if { $::configurator::loop_level > 0 } {
                incr ::configurator::loop_level -1
            }
        }
    }


    proc run_hook {config which_hook} {
        
        debug $::DBLVL_TRACE "::configurator::run_hook $which_hook"

        set rc 0
        
        if {![catch {set hook_list [vw_keylget config $which_hook]}]} {
            foreach hook $hook_list {
                if {[catch {::$hook "$config"} result]} {
                    incr rc
                    puts "Error: Call of $hook failed - $result"
                    exit -1
                }
            }
        } else {
            debug $::DBLVL_TRACE "No hooks found for $which_hook"
        }
        return $rc
    }


    proc build_test_config { group loop_level dut } {
        
        debug $::DBLVL_TRACE "::configurator::build_test_config"
        
        upvar #0 $group group_config
        upvar #0 ::configurator::cfg_$loop_level global_config
        upvar #0 $dut dut_config
        
        set cfg [::configurator::merge_config "$global_config" "$group_config"]
        set cfg [::configurator::merge_config "$cfg"           "$dut_config"]
        
        set ::configurator::test_config $cfg

        return $cfg
    }
    
    
    proc build_dut_list { group } {
        
        upvar #0 $group group_list

        # need to find out the name(s) of the DUTs to receive this config.
        if {[catch {set dut_list [vw_keylget group_list Dut]}]} {
            debug $::DBLVL_WARN "No Duts defined for group \"$group\""
            return 0
        }
        
        # if test is roaming or wave_client, concat AuxDut in
        if { $::current_benchmark_name == "roaming_delay" ||     \
             $::current_benchmark_name == "roaming_benchmark" || \
             $::current_benchmark_name == "qos_roam_quality" ||  \
             $::current_benchmark_name == "wave_client" || \
             $::current_benchmark_name == "wimix_script" } {
            if {[catch {set aux_list [vw_keylget group_list AuxDut]}]} {
                if {[string first roam $::current_benchmark_name] != -1} {
                    debug $::DBLVL_WARN "No AuxDut defined for group \"$group\""
                	#CHB ethernet group won't have an AuxDut so return what we got
                	return $dut_list
                } else {
                    set aux_list {}
                }
            }
            set dut_list [concat $dut_list $aux_list]
        }
        return $dut_list
    }
    
    
    proc configure_dut { group loop_level } {

        debug $::DBLVL_TRACE "::configurator::configure_dut"
        
        upvar #0 $group group_list
        
        if {[info exists ::args(--noconfig)]} {
            debug $::DBLVL_INFO "Not configuring APs for group \"$group\""
            return 0
        }
        
        debug $::DBLVL_INFO "Configuring APs for group \"$group\""
        
        set dut_list [::configurator::build_dut_list $group]
        
        foreach dut $dut_list {
            upvar #0 $dut dut_cfg

        set key "$dut"
        # try to cut down on the amount of AP configuration
        if {[catch {set dut_int_type [vw_keylget group_list GroupType]} result]} {
        puts "Error: No GroupType for $group ($result)"
        exit -1
        }

        set ln "::configurator::cfg_$loop_level"
        upvar #0 $ln ll
        set key "$key.$dut_int_type"
        if {$dut_int_type != "802.3"} {
            if {[catch {set dut_method [vw_keylget ll Method]} result]} {
                puts "Error: No Method defined for $ln ($result)"
                exit -1
            }
        set key "$key.$dut_method"
        }

        if {![catch {set junk [vw_keylget ::configurator::configured_duts $key]} result]} {
        debug $::DBLVL_INFO "AP $dut:$dut_int_type already configured ($key)"
        return 0
        } else {
            keylset ::configurator::configured_duts $key "done"
        }

            if {[catch {set dut_vendor [vw_keylget dut_cfg Vendor]} result]} {
                puts "Error: No Vendor defined for $dut_name ($result)"
                exit -1
            }

            if { $dut_vendor != "generic" } {
                if {[catch {set dut_model [vw_keylget dut_cfg APModel]} result]} {
                    if {[catch {set dut_model [vw_keylget dut_cfg Model]} result]} {
                        puts "Error: No ApModel defined for $dut ($result)"
                        exit -1
                    }
                }
            } else {
                set dut_model "generic"
            }

            set ap_vendor_dir [file join $::VW_TEST_ROOT lib $dut_vendor]

            # entry point will not exist first time around.
            catch {unset ::config_file_proc}
                
            # source in code for configuring this particular dut
            #
            # XXX - 3com has funky model numbers - x7xx
            # XXX - this find the proper code to source should probably be at the vendor
            # XXX - level and not here.
            set model_code [file join $ap_vendor_dir $dut_model.tcl]
            debug $::DBLVL_INFO "Finding AP configuration code for DUT $dut ($dut_vendor $dut_model)"
            set model_len [string length $dut_model]
            set model_name $dut_model
            set model_x {}
                
            debug $::DBLVL_INFO "Attempting to source $model_code for ($dut_vendor / $dut_model)"
            while { 1 } {
                
                set try_to_source 0
                set fatal_error 0
                
                if {![file exists "$model_code"]} {
                    debug $::DBLVL_INFO "configurator.tcl: configure_dut: $model_code does not exist"
                } else {
                    if {![file readable "$model_code"]} {
                        debug $::DBLVL_ERROR "configurator.tcl: configure_dut: $model_code is not readable"
                        set fatal_error 1
                    } else {
                        if {![file size "$model_code"]} {
                            debug $::DBLVL_ERROR "configurator.tcl: configure_dut: $model_code is zero length"
                            set fatal_error 1
                        } else {
                            set try_to_source 1
                        }
                    }
                }
                
                set rc 1
                
                if { $try_to_source == 1 } {
                    set rc [catch {source $model_code} result ]
                }
                
                if { $rc == 0 } {
                    debug $::DBLVL_INFO "Sourced $model_code for ($dut_vendor / $dut_model)"
                    break
                }
                
                if { $try_to_source == 1 } {
                    debug $::DBLVL_INFO "source $model_code for ($dut_vendor / $dut_model) failed: $result"
                    set fatal_error 1
                }
                
                if { $fatal_error == 1 } {
                    #
                    # if we tried to source a file which exists, and we failed
                    # or if the file existed by was unreadable or zero length
                    # we need to stop our search for an AP definition file at this point.
                    # The file we wanted existed and was unable to be loaded properly and that
                    # constitutes a fatal error.  We shouldn't proceed with
                    # trying to load alternate files in this case.
                    #
                    break
                }
                
                #
                # If we're here, the file we tried to source
                #   - did not exist
                #   - or was not readable
                #   - or was zero length
                #
                # Keep trying to load a valid AP definition by climbing one level
                # higher and look for an AP definition file which is one level
                # more generic than the one we just looked for or tried to load
                #
                incr model_len -1
                if { $model_len < 0 } {
                    break
                }

                # only try until we run out of digits in the model number
                set char [string range $model_name $model_len $model_len]
                if { $char < "0" || $char > "9" } {
                    break
                }

                append model_x "x"
                set model_name [string range $model_name 0 end-1]
                set model_code [file join $ap_vendor_dir $model_name$model_x.tcl]
                debug $::DBLVL_INFO "Attempting to source $model_code for ($dut_vendor / $dut_model)"
            }

            # if the search for a valid configuration entry point failed
            if {! [info exists ::config_file_proc]} {
                debug $::DBLVL_ERROR "Error: No DUT auto-config definitions were found for model $dut_vendor $dut_model"
                exit -1
            } else {
                debug $::DBLVL_INFO "source $model_code succeeded."
            }

            # jump to the config code, passing down the config info
            set rc [$::config_file_proc "$dut" "$group" "::configurator::cfg_$::configurator::loop_level"]
            if {$rc != 0} {
                debug $::DBLVL_WARN "configure_dut: vendor/model-specific DUT configurator function $::config_file_proc returned an error"
                return $rc
            }
        }
        
        return 0
    }


    # proc configure_dut_erase
    #
    # Configures the DUT and auxilary APs needed for this test.
    #
    # Returns 0 if all was successful and 1 if something went wrong.
    #
    proc configure_dut_erase {} {
    
        debug $::DBLVL_TRACE "::configurator::configure_dut_erase"
        
        # If --noclean was specified or this AP only needs to be reset at the beginning
        # there is nothing to do.
        if {![info exists ::args(--noclean)] && ![info exists ::reset_just_once]} {
            debug $::DBLVL_INFO "Resetting $::dut_name to factory defaults before configuring for $::security_method ..."

            set rc [configure_dut $::dut_name "erase-config" $::ap_reset]
            if { $rc != 0 } {
                puts "Error: Cannot erase config on $::dut_name"
                set ::clean_err 1
                incr ::dut_aborts
                return 1
            }

            if {[info exists ::aux_ap_list]} {
                foreach ap $::aux_ap_list {
                    if {![info exists ::clean_err]} {
                        debug $::DBLVL_INFO "Resetting $ap to factory defaults before configuring for $::security_method ..."
                        set rc [configure_dut $ap "erase-config" $::ap_reset]
                        if { $rc != 0 } {
                            puts "Error: Cannot erase config on $ap"
                            set ::clean_err 1
                            incr ::dut_aborts
                            return 1
                        }
                    }
                }
            }

            # KNOWN ISSUE:
            # ARP problem of going from EAP -> DWEP without an erase-
            # config in-between.  This is not a Veriwave issue, but a
            # Cisco AP issue. As a work-around, run DWEP security methods
            # before running other EAP security methods.
            # See VPR 3512 for more information.
            set ::reset_just_once 1
        }

        return 0
    }


    #
    # method_needs_radius - one big switch statement
    #
    # returns 1 if the passed in method needs a radius server, 0 otherwise
    #
    proc method_needs_radius { security_method } {

        debug $::DBLVL_TRACE "::configurator::method_needs_radius"

        switch $security_method {
            "WPA2-EAP-TLS"                     -
            "WPA-EAP-TLS"                      -
            "WPA-EAP-TTLS-GTC"                 -
            "WPA2-EAP-TTLS-GTC"                -
            "WPA-PEAP-MSCHAPV2"                -
            "WPA2-PEAP-MSCHAPV2"               -
            "DWEP-EAP-TLS"                     -
            "WPA-CCKM-PEAP-MSCHAPV2-TKIP"      -
            "WPA-CCKM-PEAP-MSCHAPV2-AES-CCMP"  -
            "WPA-CCKM-TLS-TKIP"                -
            "WPA-CCKM-TLS-AES-CCMP"            -
            "WPA-CCKM-LEAP-TKIP"               -
            "WPA-CCKM-LEAP-AES-CCMP"           -
            "WPA-CCKM-FAST-TKIP"               -
            "WPA-CCKM-FAST-AES-CCMP"           -
            "WPA2-CCKM-PEAP-MSCHAPV2-TKIP"     -
            "WPA2-CCKM-PEAP-MSCHAPV2-AES-CCMP" -
            "WPA2-CCKM-TLS-TKIP"               -
            "WPA2-CCKM-TLS-AES-CCMP"           -
            "WPA2-CCKM-LEAP-TKIP"              -
            "WPA2-CCKM-LEAP-AES-CCMP"          -
            "WPA2-CCKM-FAST-TKIP"              -
            "WPA2-CCKM-FAST-AES-CCMP"          -
            "DWEP-EAP-TTLS-GTC"                -
            "DWEP-PEAP-MSCHAPV2"               -
            "WPA-EAP-FAST"                     -
            "WPA2-EAP-FAST"                    -
            "WPA-PEAP-MSCHAPV2-AES"            -
            "WPA2-PEAP-MSCHAPV2-TKIP"          -
            "WPA2-EAP-TLS-TKIP"                -
            "LEAP"                             -
            "WPA-LEAP"                         -
            "WPA2-LEAP"                        {
                return 1
            }
            default {   
                return 0
            }
        }
    }


    #
    # dut_send_cmd - send a command and wait for the specified prompt.
    #
    # parameters:
    #  cmd     - command to send to the device.  Note that this string must have any
    #            necessary carriage returns.
    #
    #  prompt  - prompt to look for upon successful completion.
    #
    #  timeout - how long to wait for prompt 
    #
    proc dut_send_cmd { cmd prompt timeout } {

        global spawn_id

        debug $::DBLVL_TRACE "::configurator::dut_send_cmd"

        if {[info exists ::dut_configure_send_buf]} {
            unset ::dut_configure_send_buf
        }

        set timeout $timeout
        if {[catch {send "$cmd"} result]} {
            debug $::DBLVL_ERROR "send \"$cmd\" failed: $result"
            return 1
        }
        expect {
            -re "$prompt" {
                set ::dut_configure_send_buf $expect_out(buffer)
                return 0
            }

            -re "\n% (.*)\n" {
                debug $::DBLVL_ERROR "dut_send_cmd caught error: $expect_out(1,string)"
                return 1
            }

            default {
                return 1
            }
        }
    }
    
    
    #
    # find_ssid - Search a configuration for a defined SSID
    #
    # dut_name   - the name of the DUT being configured
    #
    # cfg    - the merged configuration to search through.
    #
    # active_int - the wireless interface to be used
    
    proc find_ssid { dut_name cfg active_int } {

        global $dut_name

        debug $::DBLVL_TRACE "::configurator::dut_find_ssid"

        if {![catch {set dut_int_list [vw_keylget cfg Interface]} result]} {
            if {[catch {set this_int [vw_keylget dut_int_list $active_int]} result]} {
                puts "Error: No interface \"$active_int\" for DUT $dut_name defined ($result)"
                exit -1
            } else {
                catch {set dut_ssid [vw_keylget this_int Ssid]}
            }
        } else {
            puts "Error: No Interface info found for DUT $dut_name ($active_int)"
            exit -1
        }
        
        # if there is no SSID yet, try for it at the global DUT level.
        if {![info exists dut_ssid]} {
            if [catch {set dut_ssid [vw_keylget cfg Ssid]}] {
                if {[catch {set dut_ssid [vw_keylget ::configurator::user_config ssid]} result]} {
                    puts "Error: No Ssid found (not even generated): $result"
                    exit -1
                }
            }
        }

        return $dut_ssid
    }
    
    
    proc check_parameters { param valid_values } {
        foreach value $valid_values {
            if { ![string compare -nocase $param $value] } {
                return 1
            }
        }
        return 0
    }


    proc is_affirmative_parameter { param } {
        return [check_parameters $param {enable on true yes}]
    }


    proc is_negative_parameter { param } {
        return [check_parameters $param {disable off false none no}]
    }
}
