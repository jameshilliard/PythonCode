#!/usr/bin/env ruby

# == Synopsis
#
# testSystem.rb: Ruby scripts to test the Actiontec BHR2 Verizon build.
#
# == Usage
#
# testSystem.rb [OPTIONS]
#
# --json, -j, -f [filename]:
#    Load specified configuration file, overriding loading
#    the configuration file default.json
# --debug, -d [level] (NOT YET COMPLETE):
#    0 only show test stopping errors
#    2 Realtime error, warning and info reports in console 
#    3 verbose mode. Show console output for each action.
# --lanip
#    Override LAN IP address
# --wanip
#    Override WAN IP address
# --nmap, -c [COMMAND]
#    Specify command to run nmap
#
# General options
#
# --no-log: 
#    Don't generate a log file. 
# --output, -o [FILENAME]:
#    Specify output file for config logs
# --version, -v:
#    Outputs the current script system version and exits
# --help, -h:
#    Displays this help text, and exits
#
# == Version
# 0.8.5 07-07-2009
#
# == Copyright
# (c) 2009 Actiontec Electronics, Inc. 
# Confidential. All rights reserved.
# == Author
# Chris Born

$: << File.dirname(__FILE__)

require 'English'
require 'rubygems'
require 'json'
require 'rdoc/usage'
require 'optparse'
require 'ostruct'
require 'open3'

require 'common/ipcheck'
require 'common/t_shark'
require 'testsystem/nmap_system'
require 'testsystem/admin_system'
require 'testsystem/iperf_system'
require 'testsystem/test_system_logging'
require 'testsystem/test_utilities'

options = OpenStruct.new
$debug = 0

natural_exit = FALSE
options.nmap = "nmap"
options.logfile = FALSE
options.input = FALSE
options.lanip = FALSE
options.wanip = FALSE
options.jsonfile = FALSE
options.savelog = TRUE
options.max_root_threads = 10
options.max_subthreads = 10
options.spc = TRUE
options.iperf = FALSE
options.iperf_bidirectional = FALSE
options.tradeoff = FALSE
options.iperf_complete = FALSE
options.iperf_server = FALSE
options.fo = FALSE
options.tshark = FALSE
options.sshcli = FALSE
options.local_ip = ""
options.remote_ip = ""
options.ptrigger = FALSE
options.dut_user = FALSE
options.dut_pass = FALSE
options.dut_ip = FALSE
options.should_fail = FALSE

opts = OptionParser.new do |opts|
	opts.separator ""
	opts.banner = "testSystem.rb: Ruby scripts to test the Actiontec BHR2 Verizon build."
	opts.on("-j", "-f", "--json FILENAME", "Load specified configuration file, overriding loading the configuration file default.json") { |file| options.jsonfile = file }
	opts.on("-d", "--debug LEVEL", "Sets the debug level for the session. Default is 0, and runs config in Xvfb.") { |d| $debug = d.to_i if d.to_i < 4 && d.to_i > 0 }
	opts.on("--lanip IP", "Override the LAN IP address from the config file.") { |ip| options.lanip = ip }
	opts.on("--wanip IP", "Override the WAN IP address from the config file.") { |ip| options.wanip = ip }
	opts.on("-c", "--nmap COMMAND", "Changes the NMAP command to be something else if necessary.") { |c| options.nmap = c }
	opts.on("-o", "--output LOG", "Set the log file.") { |log| options.logfile = log}
	opts.on("--threads THREADS", "Sets maximum amount of threads for running tests. Default is 20") { |t| options.max_root_threads = t.to_i }
    opts.on("--subthreads THREADS", "Sets maximum amount of sub-threads for running nmap. Only used for source port ranges - Default is 10") { |t| options.max_subthreads = t.to_i }
    # following two options are deprecated
    opts.on("--iperf-lcommand COMMAND", "Deprecated") { |c| options.local_iperf_command = c }
    opts.on("--iperf-rcommand COMMAND", "Deprecated") { |c| options.remote_iperf_command = c }
    # -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0
    opts.on("--dut_user USER", "Sets DUT username for remote admin testing.") { |o| options.dut_user = o }
    opts.on("--dut_pass PASS", "Sets DUT password for remote admin testing.") { |o| options.dut_pass = o }
    opts.on("--dut_ip IP", "Sets DUT IP address for remote admin testing.") { |o| options.dut_ip = o }
    opts.on("--iperf [FLAGS]", "Runs test system using iperf in addition to everything else. Valid flags: random, all, or a comma separated port list.") { |o| options.iperf = o }
    opts.on("--iperf_bidirectional LISTEN_PORT", "Sets iperf test to run in bidirectional mode on the specified listening port.") { |o| options.iperf_bidirectional = o.to_i }
    opts.on("--iperf_tradeoff LISTEN_PORT", "Sets iperf test to run in bidirectional mode on the specified listening port using tradeoff (client first, server second.)") { |o| options.iperf_tradeoff = o.to_i }
    opts.on("--iperf-server PC", "Sets the server to REMOTE or LOCAL.") { |s| options.iperf_server = s }
    opts.on("--iperf-complete", "Does a thorough iperf test. This means every port of every range. A very long test and not recommended, but here for thoroughness.") { options.iperf_complete = TRUE }
    opts.on("--[no-]spc", "Turns surrounding port checking off.") { |o| options.spc = o }
    opts.on("--filter-override", "Makes the filter check always check against a filtered result, regardless of the test settings passed.") { options.fo = TRUE }
    opts.on("--start-tshark", "Starts PCap format T-Shark logs from within this test system.") { options.tshark = TRUE }
    opts.on("--use-sshcli CMD", "Use SSHCLI for remote system procedures with the command string CMD.") { |sshcli| options.sshcli = sshcli }
    opts.on("--local-ip IP", "Set local IP for the test system to bind T-Shark to.") { |ip| options.local_ip = ip }
    opts.on("--remote-ip IP", "Set remote IP for the test system to bind T-Shark to.") { |ip| options.remote_ip = ip }
    opts.on("--port-trigger", "iperf test flag for port triggering.") { options.ptrigger = TRUE }
    opts.on("--no-pass", "If tests should fail, use this option") { options.should_fail = TRUE }
	opts.separator ""
	opts.separator "General options:"
    opts.on("--verbose") { options.verbose = true }
	opts.on("--[no-]log", "Disables logging, for functional testing.") { |l| options.savelog = l }
	opts.on("-v", "--version", "Shows the version number of this script suite.") { RDoc::usage('Version', 'Author') }
	opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
	options
end

def self.parse_json(filename)
    begin
        json = JSON.parse!(File.open(filename).read)
    rescue JSON::ParserError => ex
        puts "Error: Cannot parse " + filename
        puts "#{ex.message}"
        exit -1
    end
    return json
end

class TestSystem
	include Log
	include Open3
    include TestUtilities
    include Iperf_system
    
	def initialize
		@lanip = ""
		@wanip = ""
		@out = {}
		@logs = Dir.getwd() + "/TestSystem-results.json"
		self.logs(@logs)
	end

	def run(rule_name, info)
		Debug.out("Starting test system.")
		# check if the logs should go somewhere else
		if info.has_key?('logs')
			@logs = info['logs']
			self.logs(info['logs'])
		end
		if info.has_key?('type')
			Debug.out("Checking for test type")
			case info['type']
            # Case for IPerf
            when /iperf/i
                iperf_controller(rule_name, info)
			# Case for port scanning
			when /port.?scan/i
				if info.has_key?('tcp_ports') || info.has_key?('udp_ports')
					if info.has_key?('wanip')
                        if info['type'].include?("-scatter")
                            if info.has_key?('tcp_ports')
                                Debug.out("-scatter used. Scattering TCP ports.")
                                scattered_list = info['tcp_ports'].split(',').inject("") do |x,v|
                                    scattered = scatter_range(v.split(':')[1], 10)
                                    x << scattered.split(',').inject("") { |a,b| a << "any:#{b},"}
                                end
                                info['tcp_ports'] = scattered_list
                            end
                            if info.has_key?('udp_ports')
                                Debug.out("-scatter used. Scattering UDP ports.")
                                scattered_list = info['udp_ports'].split(',').inject("") do |x,v|
                                    scattered = scatter_range(v.split(':')[1], 10)
                                    x << scattered.split(',').inject("") { |a,b| a << "any:#{b},"}
                                end
                                info['udp_ports'] = scattered_list
                            end
                        end
						results = PortTest.scan(info, info['wanip'])
                        if results.include?('Fatal')
							Debug.out("Test failed. System reported: #{results}")
						else
							self.msg(rule_name, :info, 'Test System - Port Scan', "#{results}")
						end

 						# Surrounding port check (SPC) - scans just outside the port range that was specified in the config.
 						# What ever was not forwarded should be consequently closed. Only useful for port forwarding checks.
                        # Adjust ports
                        if info['spc'] == TRUE
                            Debug.out("Creating SPC tests.")
                            if info.has_key?('tcp_ports') && info['tcp_ports'].length > 0
                                newlist = ""
                                e_list = ""
                                e_list << info['tcp_ports'].scan(/(?:any:\d+)[,|\z]/).join(',').delete('[a-zA-Z]:')
                                e_list << ',' + info['tcp_ports'].scan(/any:\d+-\d+/).join(',').delete('[a-zA-Z]:')
                                e_list.gsub(/,{2,}/,',')
                                e_list.sub!(/,\z/, '')
                                expanded_tcp_list = expand(e_list)
                                info['tcp_ports'].split(',').each do |replace|
                                    if replace.match(/~|!/)
                                        replace.delete!('~!')
                                        exc = ""
                                    else
                                        exc = "!"
                                    end
                                    exc = "" if info['from'].match(/dmz/i)
                                    if replace.match(/any:/i)
                                        new_range = spc_range(replace)
                                        newlist << "#{exc}any:#{new_range.split(',')[0]},#{exc}any:#{new_range.split(',')[1]}," if spc_check(expand(new_range), expanded_tcp_list) == TRUE
                                    end
                                end
                                newlist.sub!(/,\z/,'')
                                Debug.out("SPC TCP List = #{newlist}")
                                info['tcp_ports'] = newlist
                            end
                            if info.has_key?('udp_ports') && info['udp_ports'].length > 0
                                newlist = ""
                                e_list = ""
                                e_list << info['udp_ports'].scan(/(?:any:\d+)[,|\z]/).join(',').delete('[a-zA-Z]:')
                                e_list << ',' + info['udp_ports'].scan(/any:\d+-\d+/).join(',').delete('[a-zA-Z]:')
                                e_list.gsub(/,{2,}/,',')
                                e_list.sub!(/,\z/, '')
                                expanded_udp_list = expand(e_list)
                                info['udp_ports'].split(',').each do |replace|
                                    if replace.match(/~|!/)
                                        replace.delete!('~!')
                                        exc = ""
                                    else
                                        exc = "!"
                                    end
                                    exc = "" if info['from'].match(/dmz/i)
                                    if replace.match(/any:/i)
                                        new_range = spc_range(replace)
                                        newlist << "#{exc}any:#{new_range.split(',')[0]},#{exc}any:#{new_range.split(',')[1]}," if spc_check(expand(new_range), expanded_udp_list) == TRUE
                                    end
                                end
                                newlist.sub!(/,\z/,'')
                                Debug.out("SPC UDP List = #{newlist}")
                                info['udp_ports'] = newlist
                            end
                            Debug.out("Running SPC tests.")
                            spc_test = PortTest.scan(info, info['wanip'])
                            if spc_test.include?('Fatal')
                                Debug.out("Test failed doing SPC. System reported: #{spc_test}")
                            else
                                self.msg("Surrounding Ports Scan - #{rule_name}", :info, 'Test System - Port Scan (SPC)', "#{spc_test}")
                            end
                        end
					end
				else
					self.msg(rule_name, :error, 'Test System - Port Scan', 'No ports, files, or test case for the file included. Cannot test. Check configuration.')
					return
				end
            when /remote admin/i
                tags = {}
                results = ""
                t_results = ""
                pass_count, total_count = 0, 0
                tags['primary_http'] = "Primary HTTP"
                tags['secondary_http'] = "Secondary HTTP"
                tags['primary_https'] = "Primary HTTPS"
                tags['secondary_https'] = "Secondary HTTPS"
                tags['telnet'] = "Primary Telnet"
                tags['secondary_telnet'] = "Secondary Telnet"
                tags['secure_telnet'] = "Secure Telnet (SSL)"
                tags['wan_icmp'] = "WAN ICMP"
                tags['wan_udp_traceroute'] = "WAN UDP Traceroute"
                
                # What we need to do here is initiate an SSH connection, copy the file over, run it, and then remove it.
                rf = SSHCLI_Tools::parse_sshcli(info['sshcli'])
                Debug.out("Remote system: #{rf['host']} - #{rf['user']}, #{rf['pass']}")
                SSHCLI_Tools::scp(rf, `echo $U_MI424WR/admin_check.rb`.chomp, "/root")
                rs = RemoteSystem.new(rf['host'], rf['user'], rf['pass'])

                # Create our admin check flags
                ports = info['administration_ports'].scan(/.+? (?:on|off) \d+/).inject("") { |x,v| x << "#{v.delete('^[0-9]')}," unless v.match(/icmp|trace/i) }.sub(/,\z/,'')

                # It makes sense to run everything at once, and then just check against failures. The check doesn't take long, so it's a good idea to verify it all.
                rs_data = rs.command("/root/admin_check.rb -s --all #{ports} --icmp --udptrace -i #{info['wanip']} -u #{info['dut_user']} -p #{info['dut_pass']}")
                rs.close
                # Compare results to what should have happened
                begin
                    rs_data.split("\n").each { |v|
                        current_data = v.split(' ')[1..-1].join(' ')
                        current_compare = info['administration_ports'].slice(/#{v.split(' ')[0].strip} (?:on|off)/)
                        current_tag = tags[v.split(' ')[0].chomp.delete('-').strip]

                        if current_compare.match(/off/i)
                            current_data.match(/failed/i) ? current_result = "Passed. Unable to access as expected." : current_result = "Failed. Able to login and got DUT information: #{current_data}" unless current_compare.match(/icmp|trace/i)
                            current_data.match(/failed/i) ? current_result = "Passed. No response as expected." : current_result = "Failed." if current_compare.match(/icmp|trace/i)
                        else
                            current_result = "Passed. Received DUT information - #{current_data}"
                        end
                        pass_count += 1 if current_result.match(/pass/i)
                        current_tag << "(using port #{ports.split(',')[total_count]})" unless current_compare.match(/icmp|trace/i)
                        total_count += 1
                        t_results << "#{current_tag}: #{current_result}\n"
                    }
                rescue => tm
                    puts "Problem encountered: #{tm}\n"
                    puts "Remote system data: #{rs_data}\n"
                    puts "Parsed so far: #{t_results}"
                end
                # Log results
                pass_count == total_count ? results << "P" : results << "F"
                results << "#{pass_count} tests passed out of #{total_count}\n"
                results << t_results
                self.msg("Remote Administration Check", :info, "Remote Admin", "#{results}")
			else 
				self.msg(rule_name, :error, 'Test System', 'Test method specified is not yet implemented, or... it just doesn\'t exist. Skipping!')
				return
			end
		end
	end
end

begin
	opts.parse!(ARGV)

	input = parse_json(options.jsonfile)
	Debug.out("Creating test object.")
    dut = TestSystem.new

    if options.tshark
        Debug.err("The T-Shark option can only be used in conjunction with the --use-sshcli option. Exiting.") unless options.sshcli
        Debug.err("The T-Shark option needs the local IP specified using --local-ip. Exiting.") unless options.local_ip.length > 0
        Debug.err("The T-Shark option needs the remote IP specified using --remote-ip. Exiting.") unless options.remote_ip.length > 0
        Debug.out("Starting remote system T-Shark thread.")
        tshark_remote = T_Shark.new({ :file => "#{options.logfile.sub(/.{4}\z/, '-remote_tshark.pcap')}", :sshcli => options.sshcli }, options.remote_ip)
        sleep 5
        Debug.out("Starting local system T-Shark thread.")
        tshark_local = T_Shark.new({:file => "#{options.logfile.sub(/.{4}\z/, '-local_tshark.pcap')}"}, options.local_ip)
        sleep 5
    end

    # iterate over the rules in the input file
	Debug.out("Beginning test...")

    for key in input.sort
        unless key[1].key?('type')
            dut.msg(key, 'Error', 'Test Check', 'No test system type specified.')
        else
            key[1]['logs'] = options.logfile unless options.logfile == FALSE
            key[1]['wanip'] = options.wanip unless options.wanip == FALSE
            key[1]['lanip'] = options.lanip unless options.lanip == FALSE
            key[1]['max_root_threads'] = options.max_root_threads unless key[1].has_key?('max_root_threads')
            key[1]['max_subthreads'] = options.max_subthreads
            key[1]['spc'] = options.spc unless key[1].has_key?('spc')
            key[1]['fo'] = options.fo unless key[1].has_key?('fo')
            key[1]['iperf_tradeoff'] = options.iperf_tradeoff unless options.iperf_tradeoff == FALSE
            key[1]['iperf_bidirectional'] = options.iperf_bidirectional unless options.iperf_bidirectional == FALSE
            key[1]['nmap_command'] = options.nmap
            key[1]['sshcli'] = options.nmap if options.nmap.match(/sshcli/i)
            key[1]['sshcli'] = options.sshcli unless options.nmap.match(/sshcli/i)
            key[1]['iperf_server'] = options.iperf_server unless options.iperf_server == FALSE
            key[1]['local_ip'] = options.local_ip unless options.local_ip.empty?
            key[1]['remote_ip'] = options.remote_ip

            key[1]['dut_user'] = options.dut_user
            key[1]['dut_pass'] = options.dut_pass
            key[1]['should_fail'] = options.should_fail
            # For legacy support, replace all tcp_ports and udp_ports strings for iperf into the inbound set as TCP:port,UDP:port
            # TCP first
            inbound_set = ""
            inbound_set << key[1]['tcp_ports'].gsub(/any:/, 'TCP:') if key[1].has_key?("tcp_ports")
            # UDP second
            inbound_set << key[1]['tcp_ports'].gsub(/any:/, 'UDP:') if key[1].has_key?("udp_ports")
            key[1]['inbound'] = inbound_set unless inbound_set == ""
            key[1]['inbound_ip'] = key[1]['wanip'] unless key[1].has_key?('inbound_ip')
            key[1]['outbound_ip'] = options.remote_ip if key[1]['outbound_ip'].match(/--remote-ip/) if key[1].has_key?("outbound_ip")
            dut.run(key[0], key[1])
        end
    end
    
    # save the output
    dut.saveoutput(options.logfile) if options.savelog == TRUE
	natural_exit = true
ensure
	# In case something went horribly wrong, let's shoot the log out
	if dut != nil && !natural_exit
		Debug.out("#{dut} and #{natural_exit}")
		dut.errorout
	end
    if options.tshark
        Debug.out("Killing T-Shark processes and saving logs.")
        tshark_local.killsave
        tshark_remote.killsave
    end
end
