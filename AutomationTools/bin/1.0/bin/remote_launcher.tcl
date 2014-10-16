#!/usr/bin/env expect

#
# $Id: remote_launcher.tcl,v 1.2 2006/08/02 17:30:21 mstudeny Exp $
#

namespace eval veriwave {
    variable DEBUG_LEVEL 5 

    ##################################################################
    #  proc remote_launcher 
    #
    #  Usage:
    #    set rc [::veriwave::remote_launcher $hostname $username $password $script \
    #            $config_file $output_log $cmd_line $vw_timeout]                            
    #
    #  Returns:
    #    returns 0 if completes without error
    #    returns 1 if encounters an error
    #
    #  Takes the following as inputs:
    #      hostname     -- the hostname where the veriwave automation lives
    #                      can be ip address or dns name 
    #
    #      username     -- username to log into host as
    #
    #      password     -- password associated with username
    #
    #      script       -- name of script to run including path
    #
    #      config_file  -- name and path of config file on host
    #                      if set to 0, default config.tcl
    #                      will be used.
    #
    #      output_log   -- name and path of output log on host
    #                      if set to 0, default output.log
    #                      will be saved per vw_auto.tcl.
    #
    #      cmd_line     -- remaining command line args to send to
    #                      vw_auto.tcl - can be set to ""
    #                      ex:  "--debug 5 --noconfig --noclean --noping"
    #                      ex:  "" 
    #
    #      vw_timeout   -- An optional argument -- amount of time to wait 
    #                      in seconds for the return of vw_auto.tcl
    #                      the default is -1, which is unlimited time
    #                                                                
    ##################################################################
    proc remote_launcher { hostname username password script config_file output_log cmd_line {vw_timeout -1} } {
        global spawn_id
        global expect_out

        set host_prompt "(%|#|\\$) $"
        set password_prompt "password:|Password:"
        set file_err_msg "No such file or directory"
    
        if {! [regexp {^([a-zA-Z0-9\._\-\:/]+)/([a-zA-Z0-9\._-]+)$} $script match script_path script_name] } {
            debug 1 "Unable to parse script path and script name"
            return 1
        }

        if { $output_log != 0 } {
            if {! [regexp {^([a-zA-Z0-9\._\-\:/]+)/([a-zA-Z0-9\._-]+)$} $output_log match log_path log_name] } {
                debug 1 "Unable to parse output log path and output log name"
                return 1
            }
        }

        log_user 1

        # ping hostname
        if { ![ping_test $hostname] } {
            puts "Ping failed - Cannot reach $hostname."
            return 1
        } else {
            debug 1 "Ping succeeded to $hostname."
        }
   
        set ssh_pid [spawn ssh -l $username $hostname]

        debug 99 "spawn returned $ssh_pid"

        # wait a few seconds
        debug 99 "sleeping 10 ....."
        sleep 10 

        # Looking for something like this:
        # user@hostname's password:

        expect {
            # Look for password or Password
            -re "$password_prompt" {

                if {[shim_send_cmd "$password\r" "$host_prompt" 5]} {
                    debug 1 "Warning: Didn't reach host prompt."
                    debug 1 "Not logged onto $hostname"
                    return 1
                }
            }
   
            default {
                debug 1 "Unknown prompt found - return."
                return 1 
            }
        }

        # wait a bit
        debug 99 "sleeping 5 ....."
        sleep 5
 
        # cd to script directory
        if {![shim_send_cmd "cd $script_path\r" "$file_err_msg" 10]} {
            debug 1 "Warning: Couldn't cd to  $script_path."
            return 1
        }

        # look for script name
        if {![shim_send_cmd "ls $script_name\r" "$file_err_msg" 10]} {
            debug 1 "Warning: Couldn't find $script_name"
            return 1
        }
    
        # look for config_file
        if { $config_file != 0 } {
            # check to make sure config_file is there 
            if {![shim_send_cmd "ls $config_file\r" "$file_err_msg" 10]} {
                debug 1 "Warning: $config_file cannot be found on $hostname"
                return 1
            }

            if { [info exists log_path] } {
                # check to see if output_log path exists
                if {![shim_send_cmd "ls $log_path\r" "$file_err_msg" 10]} {
                    debug 1 "Warning: $log_path cannot be found on $hostname"
                    return 1
                }
    
                # if config_file and log_path exist, 
                # run vw_auto.tcl with -f option, -o option, and cmd_line.
                debug 5 "Sending $script -f $config_file -o $output_log $cmd_line to $hostname"
                set rc [shim_exec "$script -f $config_file -o $output_log $cmd_line" $vw_timeout] 
             
            } else {
                # if config_file exists, run vw_auto.tcl with -f option and cmd_line.
                debug 5 "Sending $script -f $config_file to $hostname"
                set rc [shim_exec "$script -f $config_file $cmd_line" $vw_timeout] 

            }
    
        } else {
            if { [info exists log_path] } {
                # check to see if output_log path exists
                if {![shim_send_cmd "ls $log_path\r" "$file_err_msg" 10]} {
                    debug 1 "Warning: $log_path cannot be found on $hostname"
                    return 1
                }

                # if output_log path exists, run vw_auto.tcl with -o option.
                debug 5 "Sending $script -o $output_log $cmd_line to $hostname"
                set rc [shim_exec "$script -o $output_log $cmd_line" $vw_timeout] 
             
            } else {
    
                # run vw_auto.tcl script with cmd_line
                # vw_auto.tcl will use the default config.tcl
                debug 5 "Sending $script to $hostname"
                set rc [shim_exec "$script $cmd_line" $vw_timeout] 
            }
        }

        debug 99 "shim_exec returned $rc"
        debug 99 "End of remote_launcher"

        return $rc

    } ; # End of proc remote_launcher 

    #
    # proc debug
    #
    # level -- a debug level for the message.
    # msg -- a debug message to be printed
    #
    # The debug proc prints the message passed in the msg argument if a
    # the global DEBUG_LEVEL variable is set to a value which exceeds the level of
    # this message.  All debug messages have a level associated with them and
    # more information # can be printed by increasing the value of DEBUG_LEVEL.
    # A negative or zero value for DEBUG_LEVEL turns off debugging.
    #

    proc debug {level msg} {
        if [ info exists ::veriwave::DEBUG_LEVEL] {
            if {($::veriwave::DEBUG_LEVEL > 0) && ($level <= $::veriwave::DEBUG_LEVEL) } {
                puts "DEBUG-$level: $msg"
            }

        }

    } ; # End proc debug

    #
    # proc ping_test {ip_addr}
    #
    # ip_addr -- the ip address to ping
    #
    # The ping_test proc sends one ping packet to the ip address passed
    # to it.  It then searches the result for "1 received" to determine
    # if ping succeeded.
    #
    # If the ping succeeds, ping_test returns 1.
    # If the ping fails, ping_test returns 0.
    #
    #    linux:~/demo # ping -c 1 192.168.10.42
    #    PING 192.168.10.42 (192.168.10.42) 56(84) bytes of data.
    #    64 bytes from 192.168.10.42: icmp_seq=1 ttl=255 time=0.558 ms
    #
    #    --- 192.168.10.42 ping statistics ---
    #    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    #    rtt min/avg/max/mdev = 0.558/0.558/0.558/0.000 ms
    #
    proc ping_test {ip_addr} {
   
        set ping_count_arg "-c"
        set ping_regex "1 received"
 
        catch {exec ping $ping_count_arg 1 $ip_addr} result
        debug 3 "Ping $ip_addr result: $result"

        if { [regexp $ping_regex $result match] } {
            return 1
        } else {
            return 0
        }

    } ; # End proc ping_test

    #
    # shim_send_cmd - send a command and wait for the specified prompt.
    #
    # parameters:
    #  cmd     - command to send to the device.  Note that this string must have any
    #            necessary carriage returns.
    #
    #  prompt  - prompt to look for upon successful completion.
    #
    #  timeout - how long to wait for prompt
    #
    proc shim_send_cmd { cmd prompt timeout } {

        global spawn_id
        global expect_out

        log_user 1

        debug 99 "shim_send_cmd"
        debug 99 "sending $cmd"

        set exp_timeout $timeout
        send "$cmd"
   
        expect {
            -re "$prompt" {
                debug 1 "Found $prompt after running $cmd\n"
                return 0
            }

            default {
                debug 1 "Unable to find $prompt, found $expect_out(buffer)"
                return 1
            }
        }

    } ; # end shim_send_cmd

    #
    # proc shim_exec cmd timeout
    #
    #  parameters:
    #    cmd -- the command the be executed.
    #
    #    timeout - how long to wait for prompt
    #
    proc shim_exec { cmd timeout } {

        global host_prompt
    
        debug 99 "shim_exec $cmd"

        set exp_timeout $timeout

        exp_send "$cmd\n"
        exp_send "echo vw_remote_launcher\\ complete\n"

        expect {
            "exiting due to errors" {
                debug 1 "Exiting due to errors while running $cmd\n"
                return 1
            }
            "vw_remote_launcher complete" {
                debug 1 "Found \"vw_remote_launcher complete\" after running $cmd\n"
                return 0
            }
        
            default {
                debug 1 "\"vw_remote_launcher complete\" not found - possible timeout\n"
                return 1
            }
        }
    } ; # end of shim_exec

} ; # end of namespace veriwave
