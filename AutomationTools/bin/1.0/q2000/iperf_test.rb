#!/usr/bin/env ruby
# Test with iperf - separated from the other testing script so that it doesn't break legacy items
# Eventually this all needs to be integrated fully and other items needs to be ported to this format
$: << File.dirname(__FILE__)

require 'ipcheck'
require 'iperf_parser'
require 'rubygems'
require 'user-choices'

class IPerfTest < UserChoices::Command
    # Modules that are required
    include UserChoices
    include IPerf

    def initialize(file="")
        @config_file = file
        @logged_in = false
        builder = ChoicesBuilder.new
        add_sources(builder)
        add_choices(builder)
        @user_choices = builder.build
        postprocess_user_choices
        sshcli_info = []
        sshcli_info = `echo $U_COMMONBIN,$G_CURRENTLOG,$G_HOST_IP1,$G_HOST_USR1,$G_HOST_PWD1`.chomp.split(',')

        unless @user_choices.member?(:sshcli)
            @sshcli = "perl #{sshcli_info[0]}/sshcli.pl"
            sshcli_info[1].empty? ? @sshcli_logs = "" : @sshcli_logs = "-l #{sshcli_info[1]}"
            @sshcli_flags = "-t 3600 -d #{sshcli_info[2]} -u #{sshcli_info[3]} -p #{sshcli_info[4]} -n -v"
        end

        @client_flags = flag_parse(:client => TRUE, :dscp => @user_choices[:dscp], :protocol => @user_choices[:protocol], :tradeoff => false, :bidirectional => false, :ip => @user_choices[:target], :port => @user_choices[:port], :bind_ip => @user_choices[:client_bind_ip])
        @server_flags = flag_parse(:client => false, :dscp => false, :protocol => @user_choices[:protocol], :tradeoff => false, :bidirectional => false, :ip => false, :port => @user_choices[:server_port] || @user_choices[:port], :bind_ip => @user_choices[:server_bind_ip])
        @iperf_results = "No data"
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
        builder.add_choice(:rsi, :type=>[:string]) { |command_line| command_line.uses_option("--rsi ADDRESS,USER,PASS", "For remote scanning, sets the remote system information as needed by sshcli") }
        builder.add_choice(:sshcli) { |command_line| command_line.uses_option("--sshcli PATH", "SSHCLI path. Will try to derive from environment variables if not included as an argument") }
        builder.add_choice(:sshcli_logs) { |command_line| command_line.uses_option("--sshcli_logs PATH", "Path to use for logs. Will try to derive from environment variables if not included as an argument") }
        builder.add_choice(:data, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--data", "Specifies that a 'passing' test of iperf means it should not work/no data returned") }
        
        # iperf specific options
        builder.add_choice(:dscp) { |command_line| command_line.uses_option("--dscp VALUE", "Set DSCP value on iperf traffic") }
        builder.add_choice(:target) { |command_line| command_line.uses_option("--target IP", "Target IP to connect the client to") }
        builder.add_choice(:server_bind_ip) { |command_line| command_line.uses_option("--server_bind_ip IP", "IP or interface name to bind the iperf server to") }
        builder.add_choice(:client_bind_ip) { |command_line| command_line.uses_option("--client_bind_ip IP", "IP or interface name to bind the iperf client to") }
        builder.add_choice(:local_client, :type=>:boolean, :default=>false) { |command_line| command_line.uses_switch("--local_client", "Client should be local") }
        builder.add_choice(:local_server, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--local_server", "Server should be local") }
        builder.add_choice(:protocol, :type=>:string, :default=>"TCP") { |command_line| command_line.uses_option("--protocol PROTOCOL", "Set protocol (TCP, UDP)") }
        builder.add_choice(:port, :type=>:integer) { |command_line| command_line.uses_option("--port PORT", "Port that the iperf server should listen to traffic on") }
        builder.add_choice(:server_port) { |command_line| command_line.uses_option("--server_port PORT", "Specifies the port the server should listen on in case the testing port is different on the WAN side") }
    end

    def iperf_setup
        # Verify passed arguments fit the requirements - not used in this version.
        # raise "No ports passed. Nothing to scan. Exiting" unless @user_choices.member?(:stream_1) || @user_choices.member?(:stream_2) || @user_choices.member?(:stream_3) || @user_choices.member?(:stream_4)

        # Setup SSHCLI if we need to use it
        @sshcli_flags = "-t 3600 -d #{@user_choices[:rsi][0]} -u #{@user_choices[:rsi][1]} -p #{@user_choices[:rsi][2]} -n -v" if @user_choices[:rsi].length == 3 if @user_choices.member?(:rsi)
        @sshcli = "perl #{@user_choices[:sshcli]}/sshcli.pl" if @user_choices.member?(:sshcli)
        @sshcli_logs = "-l #{@user_choices[:sshcli_logs]}" if @user_choices.member?(:sshcli_logs)

        # Run iperf test
        self.iperf_test

        # Put out results
        if @iperf_results.match(/failed/im)
            puts "No data from iperf test - #{@user_choices[:data] ? 'FAIL' : 'PASS'}"
        else
            results = IPerf_Data.new(@iperf_results)
            puts "** #{results.format_bandwidth} ** - PASS"
        end
    end
end

config_file = ""
config_index = ARGV.index("-f") || ARGV.index("--file")
config_file = ARGV[config_index+1] unless config_index.nil?
IPerfTest.new(config_file).iperf_setup
