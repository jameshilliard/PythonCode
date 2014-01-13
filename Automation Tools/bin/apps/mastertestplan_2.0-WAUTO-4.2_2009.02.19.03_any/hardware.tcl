# DUT Configuration
# Leave HardwareType and Vendor as generic unless your AP is
# specifically integrated with WaveAutomation.
keylset dut1 HardwareType                         generic
keylset dut1 Vendor                               generic
keylset dut1 APModel                              MY_AP
#keylset dut1 PreGroupHook                         SampleDUTHook
keylset dut1 Interface.bg_radio.InterfaceType     802.11bg 
set chassis_addr [vw_keylget ::global_config ChassisName]
# SET the card and port index for bg
keylset dut1 Interface.bg_radio.WavetestPort      $chassis_addr:3
keylset dut1 Interface.ethernet.InterfaceType     802.3 
keylset dut1 Interface.ethernet.WavetestPort      $chassis_addr:7

# any variables defined after these are optional and can be used
# by your code
keylset dut1 LoginProto                           "http"
keylset dut1 LoginUser                            "admin"
keylset dut1 LoginPassword                        "abc123"
keylset dut1 LoginAddress                         "192.168.10.243"
keylset dut1 LoginPort                            "80"


# this is a sample of how to integrate WaveAutomate with an external
# program to get an AP/Wireless Controller configured.
proc SampleDUTHook { config } {

    puts "Start of SampleDUTHook function"

    # This function will be called once for every client group configured
    # for each test.  In the simplest form, this function will be called twice.
    # Once for the wireless client group and a second time for the ethernet
    # clients.

    # $config is a TCL keyed list containing the global, group, test and DUT
    # configuration for this particular client group.

    # Start building the command line
	set cmd "python"
	lappend cmd "c:\\veriwave\\MY_AP.py"

    # Items are retrieved from this data structure with the
	  # vw_keylget function.
    # Knowing which type of client this is is usually the first step.
    set group_type [vw_keylget config "GroupType"]
    switch -glob -- $group_type {
        
        "802.3" {
            puts "Ethernet groups need no configuration."
        }
        
        "802.11*" {
            
            # set some defaults
            if {[catch {set proto [vw_keylget config LoginProto]}]} {
                keylset config LoginProto "http"
            }

            if {[catch {set user [vw_keylget config LoginUser]}]} {
                keylset config LoginUser "admin"
            }

            if {[catch {set pass [vw_keylget config LoginPassword]}]} {
                keylset config LoginPassword "abc123"
            }
            
            if {[catch {set addr [vw_keylget config LoginAddress]}]} {
                keylset config LoginAddress "192.168.10.244"
            }

            if {[catch {set port [vw_keylget config LoginPort]}]} {
                keylset config LoginPort "80"
            }

            # Dump all the configuration options.  Let the external program
            # sort out what it needs
            foreach key [keylkeys config] {
                set val [vw_keylget config $key]
                lappend cmd "--$key=$val"
            }
            
            # config the AP
            exec_lines $cmd
        }
    }

    # All output from puts statements will show up in the output.log file
    # at the top level of the results directory
    puts "End of SampleDUTHook function"
}
