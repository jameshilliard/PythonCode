#!/usr/bin/env ruby
# == Copyright
# (c) 2010 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# Grabs the specified value from the console or shell command, or the specified value from the path of within the config file
$: << File.dirname(__FILE__)
File.dirname(__FILE__)=="." ? $: << "../common" : $: << "./common"

require 'rubygems'
require 'telnet_mod'
require 'ip_utils'
require 'serialport'
require 'user-choices'

class ConsoleCommand < UserChoices::Command
    include Net
    include UserChoices
    
    def initialize(file="")
        @config_file = file
        @logged_in = false
        builder = ChoicesBuilder.new
        add_sources(builder)
        add_choices(builder)
        @user_choices = builder.build
        postprocess_user_choices
        # logs(@user_choices[:log_file], 4-@user_choices[:debug], @user_choices[:verbose])
        @available_console_prefixes = %w{help conf upnp qos wmm cwmp bridge firewall connection inet_connection misc firmware_update log dev kernel system flash net cmd}
    end

    def add_sources(builder)
        builder.add_source(CommandLineSource, :usage, "Usage: ruby #{$0} [options]")
        builder.add_source(YamlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/yml|yaml/i)
        builder.add_source(XmlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/xml/i)
        builder.add_source(EnvironmentSource, :with_prefix, "bhr2_")
    end

    def add_choices(builder)
        builder.add_choice(:username) { |cmd| cmd.uses_option("-u", "--username USER", "Specifies the login username information for the BHR2 under testing") }
        builder.add_choice(:password) { |cmd| cmd.uses_option("-p", "--password PASS", "Specifies the login password information for the BHR2 under testing") }
        builder.add_choice(:interface) { |cmd| cmd.uses_option("-i", "--interface INT", "Specifies the IP address, or serial port to use to reach the BHR2 under testing") }
        builder.add_choice(:cmd) { |cmd| cmd.uses_option("--cmd COMMAND", "Processes a console or shell command") }
        builder.add_choice(:value, :type=>[:string]) { |cmd| cmd.uses_option("-v", "--value ROW,COLUMN", "The integer value of the row and column to return for the shell commands. Will return everything if not specified") }
        builder.add_choice(:config) { |cmd| cmd.uses_option("--config PATH", "Retrieves the configuration value from the specified path") }
        builder.add_choice(:count) { |cmd| cmd.uses_switch("--count", "Counts unique entries based off the config path specified") }
        builder.add_choice(:var) { |cmd| cmd.uses_switch("--var", "Returns the variable path for the specified config path (instead of the value of it)") }
        builder.add_choice(:ifconfig, :type=>[:string]) { |cmd| cmd.uses_option("--ifconfig ID,VAL", "Returns interface information for specified ID, will return only the partial information specified in VAL if used") }
        builder.add_choice(:ifnetwork) { |cmd| cmd.uses_switch("--ifnetwork", "Returns network of the specified ifconfig ID") }
        builder.add_choice(:routes, :type=>[:string]) { |cmd| cmd.uses_option("--routes TABLE,VAL", "Returns routing value of the specified routing table") }
        builder.add_choice(:routes_count) { |cmd| cmd.uses_switch("--routes_count", "Counts the entries in the routing table") }
        builder.add_choice(:telnet_port, :type=>:integer, :default=>23) { |cmd| cmd.uses_option("--port PORT", "Specifies port for telnet") }
        builder.add_choice(:debug, :type=>:integer, :default=>3) { |command_line| command_line.uses_option("--debug LEVEL", "Set debug value - default is 3 (highest)") }
        builder.add_choice(:verbose, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--verbose", "Enables/disables console output") }
        builder.add_choice(:log_file) { |command_line| command_line.uses_option("--output FILE", "Set output log file; If not set, no log file is created") }
    end

    def clean_up(unformatted)
        formatted_results = []
        unformatted.gsub!(/conf print \/\//, '')
        unformatted.gsub!(/Returned -?\d/i, '')
        unformatted.gsub!(/Wireless Broadband Router>/i, '')
        unformatted.gsub!(/\/ #/,'''')
        unformatted.gsub!(/\r/, '')
        unformatted.split("\n").each { |formatting| formatted_results << formatting.strip.chomp if formatting.strip.chomp.length > 0 unless formatting.strip.chomp.match(/\A#{@user_choices[:cmd]}\z/) }
        formatted_results
    end
    
    def to_path(input_config)
        output = []
        parents = []

        input_config.each do |line|
            pop_count = 0
            line.strip!
            line.chomp!
            line.split("(").each do |l|
                parents.push l.strip unless l.strip.length == 0
                pop_count += 1 if l.strip == ")"
            end

            if (parents.join("/").count(")") > 0)
                pop_count += parents.join("/").count(")")
                t_line = "/" + parents[0..-2].join("/")
                t_line += " = " + parents.last unless parents.last.gsub(')','').strip.empty?
                t_line.gsub!(")", "")
            else
                t_line = "/" + parents.join("/")
                t_line.gsub!(")", "")
            end
            
            output << t_line unless t_line.match(/\/\z/)
            pop_count.times { parents.pop }
        end
        output
    end
    
    def telnet_get_config
        # Set the command hash to print the configuration
        command_hash = { "String" => "conf print //", "Match" => /returned/im }

        # Open session and login
        session = Telnet.new("Host" => @user_choices[:interface].ip, "Port" => @user_choices[:telnet_port])
        session.waitfor(/username/im)
        session.puts(@user_choices[:username])
        session.waitfor(/password/im)
        session.puts(@user_choices[:password])
        session.waitfor(/Wireless Broadband Router/im)

        # Deliver configuration print command
        config = session.cmd(command_hash)

        # Logout and close session
        session.puts "exit"
        session.close
        to_path(clean_up(config))
    end

    def sc_get_config
        config = ""
        session = SerialPort.new(@user_choices[:interface], 115200)
        session.puts ""
        session = SerialPort.new(@user_choices[:interface], 115200)
        session.puts ""
        serial_wait(session, /username/im)
        session.puts(@user_choices[:username])
        serial_wait(session, /password/im)
        session.puts(@user_choices[:password])
        serial_wait(session, /Wireless Broadband Router/im)
        session.puts "conf print //"

        session.each_char do |r|
            config << r
            if config.match(/returned/im)
                session.close
                break
            end
        end

        to_path(clean_up(config))
    end

    def telnet_cmd
        # Open session and login
        session = Telnet.new("Host" => @user_choices[:interface].ip, "Port" => @user_choices[:telnet_port])
        session.waitfor(/username/im)
        session.puts(@user_choices[:username])
        session.waitfor(/password/im)
        session.puts(@user_choices[:password])
        session.waitfor(/Wireless Broadband Router/im)

        if @available_console_prefixes.include?(@user_choices[:cmd].split(' ')[0])
            console_command = { "String" => "#{@user_choices[:cmd]}", "Match" => /returned/im }
            results = session.cmd(console_command)
        else
            console_command = { "String" => "#{@user_choices[:cmd]}", "Match" => /\/ #/}
            session.puts("system shell")
            session.waitfor(/\/ #/)
            results = session.cmd(console_command)
        end
        clean_up(results)
    end

    def serial_wait(stream, line)
        read_ahead = ""
        buffer = ""
        rest = ""
        until(line === read_ahead)
            begin
                stream_read = stream.readpartial(1048576)
                buffer = rest + stream_read
                if point_stop = buffer.rindex(/\r\z/no)
                    buffer = buffer[0 ... point_stop]
                    rest = buffer[point_stop .. -1]
                end
                buffer.gsub!(/\r\n/no, "\n")
                read_ahead += buffer
            rescue EOFError
                raise "Connection terminated"
            end
        end
        read_ahead
    end

    def serial_cmd
        session = SerialPort.new(@user_choices[:interface], 115200)
        session.puts ""
        serial_wait(session, /username/im)
        session.puts(@user_choices[:username])
        serial_wait(session, /password/im)
        session.puts(@user_choices[:password])
        serial_wait(session, /Wireless Broadband Router/im)

        if @available_console_prefixes.include?(@user_choices[:cmd].split(' ')[0])
            session.puts(@user_choices[:cmd])
            results = serial_wait(/returned/im)
        else
            session.puts("system shell")
            session.waitfor(/\/ #/)
            session.puts(@user_choices[:cmd])
            results = serial_wait(/\/ #/)
        end
        clean_up(results)
    end

    def config_search(conf)
        results = []
        conf.each do |config|
            if config.match(/ 1\z/i)
                results << config.sub(/ 1\z/i, " true")
            elsif config.match(/ 0\z/i)
                results << config.sub(/ 0\z/i, " false")
            else
                results << config
            end if config.match(/#{@user_choices[:config]}/i)
        end
        if @user_choices[:count]
            count = []
            results.each do |check|
                count << check if count.empty?
                count << check unless count.to_s.include?(check.slice(/#{@user_choices[:config]}/i))
            end
            return [" = #{count.length}"]
        else
            results
        end
    end

    def table_find(input, row, column)
        column > 0 ? input[row-1].split(" ")[column-1] : input[row-1]
    end

    def parse_ifconfig(ifconfig)
        id = nil
        parsed_results = {}
        temp_results = {}

        ifconfig.each do |line|
            if line.match(/\ADevice/)
                unless temp_results.empty?
                    parsed_results[id] = temp_results.dup
                    temp_results.clear
                    id = nil
                end
                temp_results["device"] = line.slice(/ .*\)/).delete('-').strip
            elsif line.match(/id ?= ?/)
                id = line.split("=")[1].strip
            else
                line.chomp!
                line.sub!(/,\t/, " ") if line.match(/\d,/)
                line.sub!("\t", " ")
                # Convert to TR69 terms here
                line.sub!("yes", "true")
                line.sub!("no", "false")
                line.sub!("running", "Enabled")
                line.sub!("down", "Disabled")
                line.scan(/.*?=..*? |.*?=.*?\z/) do |z|
                    x = z.split("=")[0].strip
                    y = z.split("=")[1].nil? ? "No data" : z.split("=")[1].strip
                    temp_results[x] = y.strip.empty? ? "No data" : y unless temp_results.has_key?(x)
                end
            end
        end
        parsed_results
    end

    def parse_routes(routes, ifconfig)
        parsed_results = {}
        temp_results = {}
        sorted_results = {}
        #flags = { "U" => "Up", "G" => "Gateway", "H" => "Host", "!" => "Reject", "D" => "Dynamic", "C" => "Cache" }
        routes.each do |line|
            line.gsub!("\t", " ")
            line.squeeze!(" ")
            # Guessing here, looks like the ordering is based off networks first, by ID, then gateways, by ID
            unless line.match(/\ASource Destination/)
                interface = 0
                temp_results[:SourceIPAddress] = line.split(" ")[0].ip
                temp_results[:SourceSubnetMask] = IPUtil::ip_string(IPUtil::bits_to_mask(line.split(" ")[0].split("/")[1].to_i))
                temp_results[:DestIPAddress] = line.split(" ")[1].ip
                temp_results[:SourceSubnetMask] = IPUtil::ip_string(IPUtil::bits_to_mask(line.split(" ")[1].split("/")[1].to_i))
                temp_results[:GatewayIPAddress] = line.split(" ")[2].include?("*") ? "0.0.0.0" : line.split(" ")[2]
                temp_results[:ForwardingMetric] = line.split(" ")[5]
                ifconfig.each_key { |check| interface = check if ifconfig[check]["device"].match(/#{line.split(" ").last}/) }
                temp_results[:MTU] = ifconfig[interface]["MTU"]
                temp_results[:Status] =  line.split(" ")[3].match(/U/i) ? "Enabled" : "Disabled"
                temp_results[:Type] = line.split(" ")[3].match(/G/i) ? "Default" : "Network"
                temp_results[:Enable] = temp_results[:Status].match(/enabled/i) ? "true" : "false"
                temp_results[:ForwardingPolicy] = "-1" # No idea where this comes from yet
                # Fix interface for TR69
                temp_results[:Interface] = interface
                interval = "#{interface}#{line.split(" ")[3]}"
                parsed_results[interval] = temp_results.dup
                temp_results.clear
            end
        end

        interval = 1
        # using just sort and passing key,value here doesn't work. seems like a ruby issue. Using .each fixes it
        parsed_results.sort.each { |a| sorted_results[interval] = a.last; interval += 1 }
        sorted_results
    end

    def command
        unless @user_choices[:interface].ip.empty?
            # do telnet command if ip specified
            if @user_choices.has_key?(:cmd)
                results = telnet_cmd
                puts @user_choices.has_key?(:value) ? table_find(results, @user_choices[:value][0].to_i, @user_choices[:value][1].to_i) : results
            elsif @user_choices.has_key?(:config)
                config = telnet_get_config
                config_results = config_search(config)
                puts config_results.length > 1 ? config_results : (@user_choices[:var] ? config_results[0].split(" = ")[0] : config_results[0].split(" = ")[1]) if config_results.length > 0
            elsif @user_choices.has_key?(:routes)
                @user_choices[:cmd] = "net route"
                routes = telnet_cmd
                @user_choices[:cmd] = "net rg_ifconfig 1"
                ifconfig = parse_ifconfig(telnet_cmd)
                parsed = parse_routes(routes, ifconfig)
                if @user_choices[:routes_count]
                    puts parsed.length
                else
                    if @user_choices[:routes][1]
                        puts parsed[@user_choices[:routes][0].to_i][@user_choices[:routes][1].to_sym]
                    else
                        puts parsed[@user_choices[:routes][0].to_i].inspect
                    end
                end
            elsif @user_choices.has_key?(:ifconfig)
                @user_choices[:cmd] = "net rg_ifconfig 1"
                parsed = parse_ifconfig(telnet_cmd)
                if @user_choices[:ifconfig][0].match(/match/i)
                    parsed.each_key do |check|
                        if parsed[check].has_key?(@user_choices[:ifconfig][1])
                            puts "[#{check}][#{@user_choices[:ifconfig][1]}] => #{parsed[check][@user_choices[:ifconfig][1]]}"
                        end
                    end
                else
                    if @user_choices[:ifnetwork]
                        if parsed[@user_choices[:ifconfig][0]]["netmask"] && parsed[@user_choices[:ifconfig][0]]["ip"]
                            puts "#{IPUtil::ip_string(IPUtil::ip_int(parsed[@user_choices[:ifconfig][0]]["ip"]) & IPUtil::ip_int(parsed[@user_choices[:ifconfig][0]]["netmask"]))}"
                        else
                            puts "No data"
                        end
                    else
                        puts @user_choices[:ifconfig][1] ? parsed[@user_choices[:ifconfig][0]][@user_choices[:ifconfig][1]] : parsed[@user_choices[:ifconfig][0]].inspect
                    end
                end
            end
        else
            # do serial command if tty interface specified
            if @user_choices.has_key?(:cmd)
                results = serial_cmd
                puts @user_choices.has_key?(:value) ? table_find(results, @user_choices[:value][0].to_i, @user_choices[:value][1].to_i) : results
            elsif @user_choices.has_key?(:config)
                config = serial_get_config
                config_results = config_search(config)
                puts config_results.length > 1 ? config_results : (@user_choices[:var] ? config_results[0].split(" = ")[0] : config_results[0].split(" = ")[1]) if config_results.length > 0
            elsif @user_choices.has_key?(:ifconfig)
                @user_choices[:cmd] = "net rg_ifconfig 1"
                ifconfig = serial_cmd
                parsed = parse_ifconfig(ifconfig)
                if @user_choices[:ifnetwork]
                    if parsed[@user_choices[:ifconfig][0]]["netmask"] && parsed[@user_choices[:ifconfig][0]]["ip"]
                        puts "#{IPUtil::ip_string(IPUtil::ip_int(parsed[@user_choices[:ifconfig][0]]["ip"]) & IPUtil::ip_int(parsed[@user_choices[:ifconfig][0]]["netmask"]))}"
                    else
                        puts "No data"
                    end
                else
                    puts @user_choices[:ifconfig][1] ? parsed[@user_choices[:ifconfig][0]][@user_choices[:ifconfig][1]] : parsed[@user_choices[:ifconfig][0]].inspect
                end
            end
        end
    end
end

config_file = ""
config_index = ARGV.index("-f") || ARGV.index("--file")
config_file = ARGV[config_index+1] unless config_index.nil?
ConsoleCommand.new(config_file).command