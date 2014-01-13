#!/usr/bin/env ruby
# In testing - do not use this, it's not meant to be used yet.
# Currently known to be working: GPV, GPA, SPV, SPA, AddObj, DelObj

$: << File.dirname(__FILE__)
$: << "./common"

require 'rubygems'
require 'ostruct'
require 'optparse'
require 'motive_lib2'
require 'logging'

include Logging.globally
LOGGING_LEVEL = [:fatal, :error, :warn, :info, :debug]
LOGGING_FORMAT = Logging.layouts.pattern.new(:pattern => "%d--%F:%4L--%M--%5l> %m\n", :date_pattern => "%Y/%m/%d %H:%M:%S")

class Hash
    def diff(h2)
        differences = {"Removed" => [], "Added" => []}
        self.each_pair do |k,v|
            unless h2.has_key?(k)
                differences["Removed"] << "#{k}=#{v}"
            end
        end
        h2.each_pair do |k,v|
            unless self.has_key?(k)
                differences["Added"] << "#{k}=#{v}"
            end
        end
        return differences
    end
end

class MC < MotiveLib
    def initialize(sn, u, p, b)
        @results = {}
        super(sn, u, p, b)
    end

    def get_communication_log
        @get_communication_log = true
    end

    def device_info parameter
        find_device
        case STATUS_OPTIONS[parameter.downcase.to_sym]
        when /xml/
            puts device_data_raw
        else
            get_device_status STATUS_OPTIONS[parameter.downcase.to_sym]
        end if STATUS_OPTIONS.has_key?(parameter.downcase.to_sym)
    end

    def execute parameters, operation
        find_device
        return ["Device is not activated, will not continue!", ""] unless device_activated?
        set_device_lock "lock"
        if @get_communication_log
            parse_communication_log
            device_logging "enable"
        end

        if operation.match(/obj/i)
            logger.info "Running GPV prior to object change to get current object sets"
            @browser.get(queue_action("GPV", add_parameters(parents_of(parameters))))
            wait_for_queue_completion
            @old_tree = store_data_values(parameters, operation) if operation.match(/add/i)
            @old_tree = store_data_values(parents_of(parameters), operation) if operation.match(/del/i)
            parameters.each { |parameter| @browser.get(queue_action(operation, add_object(parameter, operation))); sleep 10; manage_device }
            @browser.get(queue_action("GPV", add_parameters(parents_of(parameters))))
        else
            param_request = add_parameters(parameters)
            if param_request.nil?
                logger.fatal "No valid parameters"
                raise "No valid parameters"
            end
            @browser.get(queue_action(operation, param_request))
        end
        wait_for_queue_completion

        if success?
            if operation.match(/obj/i)
                @new_tree = store_data_values(parameters, operation) if operation.match(/add/i)
                @new_tree = store_data_values(parents_of(parameters), operation) if operation.match(/del/i)
                @results = @old_tree.diff(@new_tree)
            else
                @results = store_data_values(parameters, operation)
            end
        else
            @results = "Action status: #{@browser.current_page.parser.at_xpath("//history//entry//last-action-status").text} -- #{@browser.current_page.parser.at_xpath("//history//entry//last-action-substatus").text.strip}"
        end

        set_device_lock "unlock"
        if @get_communication_log
            device_logging "disable"
            parse_communication_log
        end

        return [@results, @comm_log]
    end
end

# Quick method to handle spaces in parameter strings so they join together
def lazy_space_removal
    params = ARGV.join(" ").slice(/(--parameters\s|-p\s).*?(?=\s-|\z)/)
    return ARGV if params.nil?
    params = params.split(' ')
    new_args = ARGV
    params.each {|p| new_args.delete_if {|x| x == p} }
    new_args << "-p"
    new_args << params[1..-1].join(' ').gsub(/\s,/, ',')
    return new_args
end

# TODO Clean up the output methods. These are mostly quick and ugly methods.
def output_to_file filename, output
    result_file = File.open(filename, "w+")
    if output.is_a?(Hash)
        output.each_pair do |k,v|
            if v.is_a?(Array)
                unless v.empty?
                    result_file.write("#{k}:\n")
                    v.each do |x| 
                        unless x.match('parameter is not found in data model')
                            result_file.write("#{x}\n")
                        else
                            result_file.write(":: #{x}\n")
                        end
                    end
                end
            else
                unless v.match('parameter is not found in data model')
                    result_file.write("#{k} = #{v}\n")
                else
                    result_file.write("#{k} :: #{v}\n")
                end
            end
        end
    elsif output.is_a?(Array)
        output.each do |v| 
            unless v.match('parameter is not found in data model')
                result_file.write("#{v}\n")
            else
                result_file.write(":: #{v}\n")
            end
        end
    else
        result_file.write(output)
    end
end

def output_to_console output
    console_output = []
    if output.is_a?(Hash)
        output.each_pair do |k,v|
            if v.is_a?(Array)
                logger.info("#{k}: ")
                console_output << "#{k}: "
                v.each {|x| logger.info x; console_output << x}
            else
                logger.info("#{k} = #{v}")
                console_output << "#{k} = #{v}"
            end
        end
    elsif output.is_a?(Array)
        output.each {|v| logger.info("#{v}"); console_output << v}
    else
        logger.info output
        console_output << output
    end
    puts console_output.join "\n"
end

logging_format = Logging.layouts.pattern.new(:pattern => "%d--%F:%4L--%M--%5l> %m\n", :date_pattern => "%Y/%m/%d %H:%M:%S")

options = OpenStruct.new
options.base_url = "http://xatechdm.xdev.motive.com/hdm"
options.username = "ps_training"
options.password = "actiontec135"
options.debug = 0
options.quiet = false

OptionParser.new do |opts|
    opts.banner = "Motive Client using Motive Lib2: An interface to Motive without using Internet Explorer\n -- Usage: #{File.basename($0)} [OPTIONS]"
    opts.separator "\nMotive specific options (these options should already be included inside the script, only change if necessary)"
    opts.on("--username USER", "Motive username") {|o| options.username = o }
    opts.on("--password PASS", "Motive password") {|o| options.password = o }
    opts.on("--base URL", "Sets the Motive ACS base URL") { |o| options.base_url = o }
    opts.separator "\nClient options"
    opts.on("-v", "--operation OPERATION", "Sets the parameter operation") { |o| options.operation = o }
    opts.on("-s", "--serial DEVICE_SERIAL", "Sets the device serial number") { |o| options.device_serial = o }
    opts.on("-c", "--config FILE", "Load the specified file to read parameters from") { |o| options.parameters_file = o}
    opts.on("-p", "--parameters PARAMS", Array, "Parameters to run if -c options is not used", "  (separate multiple parameters with a comma [spaces allowed])") { |o| options.parameter_list = o.map {|x| x.strip } }
    opts.separator "Logging options"
    opts.on("-o", "--result FILE", "Send the results to the file specified instead of STDOUT") { |o| options.results_file = o }
    opts.on("-l", "--log FILE", "Sets the client logging file") { |o| options.log_file = o }
    opts.on("-f", "--diff FILE", "Save the communication log to the specified file") { |o| options.comm_log = o }
    opts.on("-x", "--debug LEVEL", Integer, "Sets the debug level (1-4)") { |o| options.debug = o }
    opts.on("--quiet", "Squelches logging to the console, but will still write to the log file") { options.quiet = true }
    opts.separator ""
    opts.on("-d DEPRECATED_OPTION", "This option isn't used, but here for compatibility") {|o| options.deprecated_value_set = o}
    opts.on("--timeout DEPRECATED_OPTION", "This option isn't used, but here for compatibility") {|o| options.deprecated_value_set = o}
    opts.on_tail("-h", "--help", "Shows these help options") { puts opts; exit }
end.parse!(lazy_space_removal)

raise "Operation type must be set!" unless options.operation
raise "No device serial number specified!" unless options.device_serial

Logging.logger.root.add_appenders(Logging.appenders.file(options.log_file, :layout => logging_format)) if options.log_file
Logging.logger.root.add_appenders(Logging.appenders.stdout(:layout => logging_format)) if options.debug unless options.quiet
Logging.logger.root.level = LOGGING_LEVEL[options.debug]
Logging.logger.root.trace = true
Logging.logger['MC'].trace = true

if options.parameters_file
    logger.debug "Reading parameters from file: #{options.parameters_file}"
    options.parameters = File.open(options.parameters_file).readlines
    options.parameters.delete_if {|x| x.match(/^#/) || x.strip.empty?}
else
    options.parameters = options.parameter_list
end

if MotiveLib.supported_operation? options.operation
    unless options.parameters
        logger.fatal "You must pass at least one parameter or a parameter file!"
        logger.fatal "Exiting."
        raise "You must pass at least one parameter or a parameter file"
    end
    logger.debug "Starting Mechanize browser agent"
    motive_client = MC.new(options.device_serial, options.username, options.password, options.base_url)
    motive_client.login
    motive_client.get_communication_log if options.comm_log
    output = motive_client.execute(options.parameters, options.operation)
    if options.results_file
        output_to_file options.results_file, output[0]
    else
        output_to_console output[0]
    end
    File.open(options.comm_log, "w+").write(output[1]) if options.comm_log
elsif MotiveLib.supported_value_retrieval? options.operation
    motive_client = MC.new(options.device_serial, options.username, options.password, options.base_url)
    motive_client.login
    output = motive_client.device_info(options.operation)
    if options.results_file
        File.open(options.results_file, "w+").write(output)
    else
        logger.info output
        puts output
    end
else
    logger.fatal "Not a valid or supported RPC operation #{options.operation}"
end
