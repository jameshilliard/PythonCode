#!/usr/bin/env ruby
# Port scan utility. Interfaces between sshcli.pl and nmap as necessary. 

$: << File.dirname(__FILE__)

require 'rubygems'
require 'user-choices'
require 'ipcheck'
require 'nmap-parser'

class Scanner < UserChoices::Command
    # Modules that are required
    include UserChoices

    def initialize(file="")
        @config_file = file
        @logged_in = false
        builder = ChoicesBuilder.new
        add_sources(builder)
        add_choices(builder)
        @user_choices = builder.build
        postprocess_user_choices
        sshcli_info = `echo $U_COMMONBIN,$G_CURRENTLOG,$G_HOST_IP1,$G_HOST_USR1,$G_HOST_PWD1`.chomp.split(',')
        @sshcli = "perl #{sshcli_info[0]}/sshcli.pl"
        sshcli_info[1].empty? ? @sshcli_logs = "" : @sshcli_logs = "-l #{sshcli_info[1]}"
        @sshcli_flags = "-t 3600 -d #{sshcli_info[2]} -u #{sshcli_info[3]} -p #{sshcli_info[4]} -n -v"
    end

    # Set up sources for getting the intended configuration via user choices
    def add_sources(builder)
        builder.add_source(CommandLineSource, :usage, "Usage: ruby #{$0} [options]")
        builder.add_source(YamlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/yml|yaml/i)
        builder.add_source(XmlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/xml/i)
        builder.add_source(EnvironmentSource, :with_prefix, "portscan_")
    end

    # Define choices
    def add_choices(builder)
        # Script settings
        builder.add_choice(:config_file) { |command_line| command_line.uses_option("-f", "--file FILE", "Config file to use in XML or YAML format") }
        builder.add_choice(:ports, :type=>[:string]) { |command_line| command_line.uses_option("--ports PORT,PORT,PORT", "Comma separated ports or port ranges") }
        builder.add_choice(:protocol, :type=>:string) { |command_line| command_line.uses_option("--protocol PROTOCOL", "Set protocol (TCP, UDP, GRE, etc)") }
        builder.add_choice(:source_port) { |command_line| command_line.uses_option("--source_port PORT", "Set remote source port to use. If a range, will randomly select a port from that range") }
        builder.add_choice(:target) { |command_line| command_line.uses_option("--target IP", "Target IP to scan") }
        builder.add_choice(:bind_ip) { |command_line| command_line.uses_option("--bind_ip IP", "IP or interface name to bind NMAP to when scanning") }
        builder.add_choice(:rsi, :type=>[:string]) { |command_line| command_line.uses_option("--rsi ADDRESS,USER,PASS", "For remote scanning, sets the remote system information as needed by sshcli") }
        builder.add_choice(:sshcli) { |command_line| command_line.uses_option("--sshcli PATH", "SSHCLI path. Will try to derive from environment variables if not included as an argument") }
        builder.add_choice(:sshcli_logs) { |command_line| command_line.uses_option("--sshcli_logs PATH", "Path to use for logs. Will try to derive from environment variables if not included as an argument") }
        builder.add_choice(:local, :type=>:boolean) { |command_line| command_line.uses_switch("--local", "Scan from the local PC and don't use sshcli (for outbound port scans)") }
        builder.add_choice(:check) { |command_line| command_line.uses_option("--check STATE", "Check against [STATE], either [OPEN|CLOSED] or [FILTERED]") }
    end

    # Begin parsing here
    def portscan
        # Variables for further down
        results = []
        nmap_flags = ""
        source_port = ""
        id = 1

        # Verify passed arguments fit the requirements
        raise "No ports passed. Nothing to scan. Exiting" unless @user_choices.member?(:ports)
        raise "No target IP passed. Exiting" unless @user_choices.member?(:target)
        raise "No protocol specified. Exiting" unless @user_choices.member?(:protocol)
        raise "Target IP not valid. Exiting" unless @user_choices[:target].valid_ip?

        # Setup SSHCLI if we need to use it
        unless @user_choices[:local]
            @sshcli_flags = "-t 3600 -d #{@user_choices[:rsi][0]} -u #{@user_choices[:rsi][1]} -p #{@user_choices[:rsi][2]} -n -v" if @user_choices[:rsi].length == 3 if @user_choices.member?(:rsi)
            @sshcli = "perl #{@user_choices[:sshcli]}/sshcli.pl" if @user_choices.member?(:sshcli)
            @sshcli_logs = "-l #{@user_choices[:sshcli_logs]}" if @user_choices.member?(:sshcli_logs)
        end

        # Add close or open option when check is set to close or open (so it checks against both)
        @user_choices[:check] << "|closed" if @user_choices[:check].match(/\Aopen\z/i) if @user_choices[:check]
        @user_choices[:check] << "|open" if @user_choices[:check].match(/\Aclosed\z/i) if @user_choices[:check]

        # Results header information
        results << "Nmap port scan"
        results << "(ID)\tProtocol\tPort\t\tState\tReason"
		results << "-"*70

        # Add nmap protocol flag
        nmap_flags = "-sS #{@user_choices[:target]} -PN" if @user_choices[:protocol].match(/syn/i)
        nmap_flags = "-s#{@user_choices.member?(:source_port) ? "S" : "T"} #{@user_choices[:target]} -PN" if @user_choices[:protocol].match(/tcp/i)
        nmap_flags = "-sU #{@user_choices[:target]} -PN" if @user_choices[:protocol].match(/udp/i)

        # Look for big port ranges to scan and split them up so they only scan the beginning, middle, and end ports
        @user_choices[:ports].each_index do |port_index|
            if ((@user_choices[:ports][port_index].split("-")[1].to_i)-(@user_choices[:ports][port_index].split("-")[0].to_i)) > 99
                # If so, get the beginning, middle, and end ports
                min_port = @user_choices[:ports][port_index].split("-")[0].to_i
                max_port = @user_choices[:ports][port_index].split("-")[1].to_i
                mid_port = (((max_port - min_port)/2)+min_port).to_i
                @user_choices[:ports][port_index] = "#{min_port},#{mid_port},#{max_port}"
            end if @user_choices[:ports][port_index].include?("-")
        end

        # Add nmap port flag
        nmap_flags << " -p #{@user_choices[:ports].join(',')}"

        # Add nmap source port
        if @user_choices[:source_port].include?("-")
            source_port = (rand(@user_choices[:source_port].split('-')[1].to_i)+@user_choices[:source_port].split('-')[0].to_i).to_s
            nmap_flags << " -g #{source_port}"
        else
            source_port = @user_choices[:source_port]
            nmap_flags << " -g #{@user_choices[:source_port]}"
        end if @user_choices[:source_port]
        
        # Add nmap bind interface
        if @user_choices[:local]
            @user_choices[:bind_ip].valid_ip? ? nmap_flags << " -e #{IPCommon::interface_by_ip(@user_choices[:bind_ip])}" : nmap_flags << " -e #{@user_choices[:bind_ip]}"
        else
            @user_choices[:bind_ip].valid_ip? ? nmap_flags << " -e #{`#{@sshcli} #{@sshcli_logs} #{@sshcli_flags} ifconfig |grep -B 2 -e \"#{@user_choices[:bind_ip]} \" | awk '/Link encap/ {split ($0,A," "); print A[1]}'`.chomp}" : nmap_flags << " -e #{@user_choices[:bind_ip]}"
        end if @user_choices.member?(:bind_ip)

        # Scan ports
        @user_choices[:local] ? scan_results = Nmap::Parser.parsescan("nmap", nmap_flags) : scan_results = Nmap::Parser.parsescan("#{@sshcli} #{@sshcli_logs} #{@sshcli_flags}", nmap_flags)

        # Parse through scan results
        scan_results.hosts("up") do |host|
            # UDP
            host.udp_port_list do |port|
                results << "(#{id})\tUDP\t\t#{source_port.empty? ? '' : source_port+':'}#{port}#{port.to_s.length > 2 ? "#{source_port.empty? ? "\t\t" : "\t"}" : "\t\t"}#{host.udp_state(port)}\t#{host.udp_reason(port)}"
                # Add pass|fail if we're checking for state
                results.last << "\tPASS" if host.udp_state(port).match(/#{@user_choices[:check]}/i) if @user_choices[:check]
                results.last << "\tFAIL" unless host.udp_state(port).match(/#{@user_choices[:check]}/i) if @user_choices[:check]
                id += 1
            end if @user_choices[:protocol].match(/udp/i)

            # TCP
            host.tcp_port_list do |port|
                results << "(#{id})\tTCP\t\t#{source_port.empty? ? '' : source_port+':'}#{port}#{port.to_s.length > 2 ? "#{source_port.empty? ? "\t\t" : "\t"}" : "\t\t"}#{host.tcp_state(port)}\t#{host.tcp_reason(port)}"
                # Add pass|fail if we're checking for state
                results.last << "\tPASS" if host.tcp_state(port).match(/#{@user_choices[:check]}/i) if @user_choices[:check]
                results.last << "\tFAIL" unless host.tcp_state(port).match(/#{@user_choices[:check]}/i) if @user_choices[:check]
                id += 1
            end if @user_choices[:protocol].match(/syn|tcp/i)
        end

        # Toss results to stdout
        puts results
    end
end

config_file = ""
config_index = ARGV.index("-f") || ARGV.index("--file")
config_file = ARGV[config_index+1] unless config_index.nil?
Scanner.new(config_file).portscan