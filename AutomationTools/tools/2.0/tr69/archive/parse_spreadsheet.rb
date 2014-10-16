#!/usr/bin/env ruby
# == Copyright
# (c) 2010 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# Grabs the specified value from the GUI
$: << File.dirname(__FILE__)

require 'rubygems'
require 'common/ip_utils'
require 'user-choices'
require 'spreadsheet'
require 'common/log'
require 'time'

class SSParser < UserChoices::Command
    include UserChoices
    include Log

    def initialize(file="")
        @z_names = %w{ Hawaii_Time Alaska_Time Pacific_Time Mountain_Time Central_Time Eastern_Time Greenwich_Mean_Time Other }
        @z_times = %w{ -10:00 -09:00 -08:00 -07:00 -06:00 -05:00 +00:00 +01:00 }
        @console_parser = "console_parser.rb"
        @gui_parser = "gui_parser.rb"
        @config_file = file
        @logged_in = false
        builder = ChoicesBuilder.new
        add_sources(builder)
        add_choices(builder)
        @user_choices = builder.build
        postprocess_user_choices
        logs(@user_choices[:log_file], 4-@user_choices[:debug], @user_choices[:verbose])
    end

    def add_sources(builder)
        builder.add_source(CommandLineSource, :usage, "Usage: ruby #{$0} [options]")
        builder.add_source(YamlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/yml|yaml/i)
        builder.add_source(XmlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/xml/i)
        builder.add_source(EnvironmentSource, :with_prefix, "tr69ss_")
    end

    def add_choices(builder)
        builder.add_choice(:username) { |cmd| cmd.uses_option("-u", "--username USER", "Specifies the login username information for the DUT") }
        builder.add_choice(:password) { |cmd| cmd.uses_option("-p", "--password PASS", "Specifies the login password information for the DUT") }
        builder.add_choice(:interface) { |cmd| cmd.uses_option("-i", "--interface INT", "Specifies the IP address to reach the DUT") }
        builder.add_choice(:tr69_interface) { |cmd| cmd.uses_option("--tr69_server IP:PORT", "Specifies the IP address and port of the TR69 server") }
        builder.add_choice(:dut_serial) { |cmd| cmd.uses_option("--serial SERIAL", "Serial number of the DUT (used for TR69 server)") }
        builder.add_choice(:spreadsheet) { |cmd| cmd.uses_option("-s", "--spreadsheet SHEET", "Specifies the spreadsheet to parse; will parse through the entirity unless the [single] option is used") }
        builder.add_choice(:console, :type=>:boolean, :default=>true) { |cmd| cmd.uses_switch("--console", "Runs console items (as long as they're present) [Default: YES]") }
        builder.add_choice(:gui, :type=>:boolean, :default=>true) { |cmd| cmd.uses_switch("--gui", "Runs GUI items (as long as they're present) [Default: YES]") }
        builder.add_choice(:row) { |command_line| command_line.uses_option("--row ITEM", "Test/parse the parameter located at row ITEM in the spreadsheet only. You can use a range here, i.e. 80-100") }
        builder.add_choice(:debug, :type=>:integer, :default=>3) { |command_line| command_line.uses_option("--debug LEVEL", "Set debug value - default is 3 (highest)") }
        builder.add_choice(:verbose, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--verbose", "Enables/disables console output") }
        builder.add_choice(:log_file) { |command_line| command_line.uses_option("-l", "--log FILE", "Set output log file; If not set, no log file is created") }
    end

    # functions to find the BEGIN and END rows
    def find_value(sheet, tag)
        row_index = 0
        sheet.each { |row| return row_index if row[0].include?(tag); row_index+=1 }
    end

    def find_parent(sheet, parent_of)
        return sheet.row(parent_of)[0] if sheet.row(parent_of)[4].include?("P")
        (parent_of-1).downto(1) { |i| return sheet.row(i)[0] if sheet.row(i)[4].include?("P") }
    end

    # compares time
    def compare_time(time_1, time_2, disparity=300)
        return false if time_1.match(/no data/i) or time_2.match(/no_data/i)
        # check if the value is all numbers for both time_1 and time_2, if not, convert using Time.parse and then convert to an integer of seconds
        unless time_1.to_i.to_s == time_1
            new_time_1 = Time.parse(time_1).to_i
        else
            new_time_1 = time_1.to_i
        end

        unless time_2.to_i.to_s == time_2
            new_time_2 = Time.parse(time_2).to_i
        else
            new_time_2 = time_2.to_i
        end

        return ((new_time_1-disparity)..(new_time_1+disparity)) === new_time_2
    end

    # Returns a valid SPV value for some timezone conditions
    def timezone_set_value(current)
        if @z_names.include?(current)
            return @z_names[@z_names.index(current)+1] unless @z_names[@z_names.index(current)+1].nil?
            return @z_names.first
        elsif @z_times.include?(current)
            return @z_names[@z_names.index(current)+1] unless @z_names[@z_names.index(current)+1].nil?
            return @z_names.first
        end
    end

    # Compares logs - if the majority is there, then it passes.
    def compare_log(log_1, log_2, disparity=0.8)
        total = 0
        matches = 0
        log_1.each do |v|
            total += 1
            matches += 1 if log_2.match(log_1)
        end
        return (matches/total >= disparity) ? true : false
    end

    # Console parser call method
    def console_parser(sheet, i, interval)
        console_dut_result = ""
        unless sheet.row(i)[1].strip.chomp.empty?
            if sheet.row(i)[1].match(/Value:/i)
                console_dut_result = sheet.row(i)[1][(sheet.row(i)[1].index(":")+1)..-1].strip.chomp
            else
                console_dut_result = `#{@tool_dir}/console_parser.rb #{sheet.row(i)[1].strip.chomp.gsub("{i}", interval)} --username #{@user_choices[:username]} --password #{@user_choices[:password]} --interface #{@user_choices[:interface]}`.strip.chomp
            end
        end unless sheet.row(i)[1].nil? if @user_choices[:console]
        console_dut_result
    end
    
    # GUI parser call method
    def gui_parser(sheet, i, interval)
        gui_dut_result = ""
        unless sheet.row(i)[2].strip.chomp.empty?
            if sheet.row(i)[2].match(/Value:/i)
                gui_dut_result = sheet.row(i)[2][(sheet.row(i)[2].index(":")+1)..-2].strip.chomp
            else
                gui_dut_result = `#{@tool_dir}/gui_parser.rb #{sheet.row(i)[2].strip.chomp.gsub("{i}", interval)} --username #{@user_choices[:username]} --password #{@user_choices[:password]} --interface #{@user_choices[:interface]}`.strip.chomp
            end
        end unless sheet.row(i)[1].nil? if @user_choices[:gui]
        gui_dut_result
    end

    # Gets SPV TR69 value
    def get_set_value(console, gui)
        tr69_value = ""
        if !console.empty?
            if console.match(/true|false/i)
                tr69_value = console.match(/true/i) ? "false" : "true"
            else
                tr69_value = console.next
            end
        elsif !gui.empty?
            if gui.match(/true|false/i)
                tr69_value = gui.match(/true/i) ? "false" : "true"
            else
                tr69_value = gui.next
            end
        end
        tr69_value
    end

    # TODO: Allow multiple parameters at the same time by running the parents first, and comparing groups of results instead of one individual item if necessary. 
    def parse
        current_parent = ""
        # Sheet row organization: TR69 Value, Console location, GUI location, Flags, Other
        # define tool directory by using the prefix of the spreadsheet:
        @tool_dir = @user_choices[:spreadsheet][(@user_choices[:spreadsheet].rindex("/")+1)..-1].split("_")[0]
        book = Spreadsheet.open("#{@user_choices[:spreadsheet]}")
        sheet = book.worksheet(0)
        @log.debug("Using tool directory #{@tool_dir}")
        # Find sheets begin and end rows
        begin_row = find_value(sheet, "BEGIN")
        end_row = find_value(sheet, "END")
        @log.debug("Found begin row to be #{begin_row} and end row to be #{end_row}")
        if @user_choices.has_key?(:row)
            @user_choices[:row].include?('-') ? start_row = @user_choices[:row].split('-')[0].to_i - 1 : start_row = @user_choices[:row].to_i - 1
            raise "Invalid row position for start. (Must be #{begin_row} or greater)" if start_row <= begin_row
            @user_choices[:row].include?('-') ? stop_row = @user_choices[:row].split('-')[1].to_i - 1 : stop_row = end_row
            raise "Invalid row position for end. (Must be less than #{stop_row}" if stop_row >= end_row
            # Find the parent if one isn't defined
            current_parent = find_parent(sheet, start_row).strip.chomp
        else
            stop_row = end_row-1
            start_row = begin_row+1
            unless sheet.row(start_row)[4].include?("P")
                @log.fatal("Spreadsheet does not begin with a parent as required. Aborting.")
                raise "Spreadsheet does not begin with a parent as required. Aborting."
            end
            current_parent = sheet.row(start_row)[0].strip.chomp
            @log.debug("Starting parent value is #{current_parent}")
        end

        @log.info("Starting at spreadsheet row #{start_row} and stopping at #{stop_row}")
        for i in start_row..stop_row do
            intervals = ["1"]
            if sheet.row(i)[4].include?("P")
                current_parent = sheet.row(i)[0].strip.chomp
                @log.debug("New parent value is #{current_parent}")
                if sheet.row(i)[0].include?("{i}")
                    if sheet.row(i)[1].include?("--")
                        base_value = console_parser(sheet, i)
                        intervals = []
                        1.upto(base_value) { |val| intervals << val.to_s }
                    end
                    @log.debug("Interval values: #{intervals.join(", ")}")
                end
            else
                intervals.each do |interval|
                    # GPV section
                    if sheet.row(i)[4].include?("R")
                        @log.debug("Running GPV on #{current_parent}#{sheet.row(i)[0].strip.chomp} (row #{i+1})")

                        # Send to console parser
                        console_dut_result = console_parser(sheet, i, interval)
                        # Send to GUI parser
                        gui_dut_result = gui_parser(sheet, i, interval)

                        # Send to TR69 server
                        if !console_dut_result.empty? || !gui_dut_result.empty?
                            # Run the TR69 command first
                            tr69_result = `./tr69client.rb -c #{@user_choices[:tr69_interface]} --serial #{@user_choices[:dut_serial]} -p #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp}`.strip.chomp
                            # Compare to console if we have a console result
                            # This is to prevent a nil result causing an error in the comparison
                            tr69_result += " No data" if tr69_result.match(/=\z/)
                            @log.debug("TR69 value retrieved was #{tr69_result}")
                            unless console_dut_result.empty?
                                @log.debug("Console value retrieved was #{console_dut_result}")
                                if tr69_result.split(" = ")[1].match(/#{console_dut_result}/)
                                    @log.info "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = PASSED"
                                elsif !sheet.row(i)[5].nil?
                                    if compare_time(console_dut_result, tr69_result.split(" = ")[1])
                                        @log.info "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = PASSED"
                                    else
                                        @log.error "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = FAILED"
                                        @log.error "Console reports this value: #{console_dut_result}; TR69 reported this value: #{tr69_result.split(" = ")[1]}"
                                    end if sheet.row(i)[5].match(/time/i)
                                    if compare_log(console_dut_result, tr69_result.split(" = ")[1])
                                        @log.info "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = PASSED"
                                    else
                                        @log.error "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = FAILED"
                                        @log.error "Console reports this value: #{console_dut_result}; TR69 reported this value: #{tr69_result.split(" = ")[1]}"
                                    end if sheet.row(i)[5].match(/log/i)
                                else
                                    @log.error "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = FAILED"
                                    @log.error "Console reports this value: #{console_dut_result}; TR69 reported this value: #{tr69_result.split(" = ")[1]}"
                                end
                            end

                            unless gui_dut_result.empty?
                                @log.debug("GUI value retrieved was #{gui_dut_result}")
                                if tr69_result.split(" = ")[1].match(/#{gui_dut_result}/)
                                    @log.info "TR69 vs GUI information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = PASSED"
                                elsif !sheet.row(i)[5].nil?
                                    if compare_time(gui_dut_result, tr69_result.split(" = ")[1])
                                        @log.info "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = PASSED"
                                    else
                                        @log.error "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = FAILED"
                                        @log.error "Console reports this value: #{gui_dut_result}; TR69 reported this value: #{tr69_result.split(" = ")[1]}"
                                    end if sheet.row(i)[5].match(/time/i)
                                else
                                    @log.error "TR69 vs GUI information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = FAILED"
                                    @log.error "Console reports this value: #{gui_dut_result}; TR69 reported this value: #{tr69_result.split(" = ")[1]}"
                                end
                            end
                        end
                    end

                    # SPV section
                    # SPV methodology: Because we don't want to focus on creating different values for each one of these,
                    # what we will do instead is create a method of which we grab the CURRENT value from the DUT, and then
                    # increase the value of that by 1. That will be the SPV value.
                    if sheet.row(i)[4].include?("W")
                        tr69_result = ""
                        @log.debug("Running SPV on #{sheet.row(i)[0].strip.chomp} (row #{i+1})")

                        # Get current values to use for an SPV
                        if sheet.row(i)[0].match(/LocalTimeZone/)
                            # Special case for timezone options
                            tr69_value = sheet.row(i)[0].match(/Name/) ? timezone_set_value(console_parser(sheet, i)) : timezone_set_value(@z_times[@z_names.index?(console_parser(sheet, i))])
                        else
                            tr69_value = get_set_value(console_parser(sheet, i), gui_parser(sheet, i))
                        end

                        # Empty these containers again for later
                        console_dut_result = ""
                        gui_dut_result = ""

                        # Run the TR69 command first
                        if tr69_value.empty?
                            @log.error "[FAILED] Failed to get any value from the console or the GUI of the DUT. Skipping this parameter: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp}"
                        else
                            @log.info "Testing SPV with value: #{tr69_value}"
                            tr69_result = `./tr69client.rb -c #{@user_choices[:tr69_interface]} --serial #{@user_choices[:dut_serial]} -p #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} --type #{sheet.row(i)[3].strip.chomp} --value #{tr69_value}`.strip.chomp unless sheet.row(i)[0].strip.chomp.length < 2 unless sheet.row(i)[0].nil?
                            # Get current values again
                            # Send to console parser
                            console_dut_result = console_parser(sheet, i)
                            # Send to GUI parser
                            gui_dut_result = gui_parser(sheet, i)

                            # Send to TR69 server
                            if !console_dut_result.empty? || !gui_dut_result.empty?
                                # Compare to console if we have a console result
                                @log.debug "Received: #{tr69_result}"
                                unless console_dut_result.empty?
                                    @log.debug("Console value retrieved was #{console_dut_result}")
                                    if tr69_result.split(" = ")[1].match(/#{console_dut_result}/)
                                        @log.info "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = PASSED"
                                    else
                                        @log.error "TR69 vs Console information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = FAILED"
                                        @log.error "Console reports this value: #{console_dut_result}; TR69 was set to this value: #{tr69_value}"
                                    end
                                end
                                # And/or compare to GUI
                                unless gui_dut_result.empty?
                                    @log.debug("GUI value retrieved was #{gui_dut_result}")
                                    if tr69_result.split(" = ")[1].match(/#{gui_dut_result}/)
                                        @log.info "TR69 vs GUI information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = PASSED"
                                    else
                                        @log.error "TR69 vs GUI information: #{current_parent.sub("{i}",interval)}#{sheet.row(i)[0].strip.chomp} = FAILED"
                                        @log.error "Console reports this value: #{gui_dut_result}; TR69 was set to this value: #{tr69_value}"
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

config_file = ""
config_index = ARGV.index("-f") || ARGV.index("--file")
config_file = ARGV[config_index+1] unless config_index.nil?
SSParser.new(config_file).parse