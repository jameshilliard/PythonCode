#!/usr/bin/env ruby
# In testing - do not use this, it's not meant to be used yet.
# Currently known to be working: GPV, GPA, SPV, SPA, AddObj, DelObj

$: << File.dirname(__FILE__)

require 'rubygems'
require 'ostruct'
require 'optparse'
require 'motive_lib2'
require 'logging'
include Logging.globally

LOGGING_LEVEL = [:fatal, :error, :warn, :info, :debug]
LOGGING_FORMAT = Logging.layouts.pattern.new(:pattern => "%d--%F:%4L--%M--%5l> %m\n", :date_pattern => "%Y/%m/%d %H:%M:%S")

# Quick method to handle spaces in parameter strings so they join together
def lazy_space_removal
    #    params = ARGV.join(" ").slice(/(--parameters\s|-p\s).*?(?=\s-|\z)/)
    #    return ARGV if params.nil?
    #    params = params.split(' ')
    new_args = ARGV
    #    params.each {|p| new_args.delete_if {|x| x == p} }
    #    new_args << "-p"
    #    new_args << params[1..-1].join(' ').gsub(/\s,/, ',')
    return new_args
end

class MC < MotiveLib
    def initialize(sn, u, p, b, d, f, e, i)
        @results = {}
        super(sn, u, p, b, d, f, e, i)
    end

    def execute parameters, operation, step_mask
        if step_mask == 1
            @results = "U_DUT_MOTIVE_DEVICE_ID=#{find_device}"
            raise "Device activated failed :: Device is not activated, will not continue!" unless device_activated?
            set_device_lock "lock"
            return @results
        else
            if operation.match(/obj/i)
                #for solve too long queue
                loop_time = 60
                loop_count = 1
                start_wait_time = Time.now.to_i
                parameters.each do |parameter|
                    if Time.now.to_i > (start_wait_time + loop_time * loop_count)
                        loop_count += 1
                        logger.info "try exec command : #{@cwmp_conn_req}."
                        system "#{@cwmp_conn_req} "
                    end
                    @browser.get(queue_action(operation, add_object(parameter, operation)))
                    sleep 10
                    manage_device
                end
            elsif operation.match(/downld/i)
                if not @image_location == ""
                    @browser.get(queue_action(operation, ""))
                end
            else
                param_request = add_parameters parameters
                if param_request.nil?
                    logger.fatal "No valid parameters"
                    raise "FATAL :: No valid parameters"
                end
                @browser.get(queue_action(operation, param_request))
            end
            wait_for_queue_completion

            #if success?
            success?
            return @results = "Action status: #{@browser.current_page.parser.at_xpath("//history//entry//last-action-status").text} -- #{@browser.current_page.parser.at_xpath("//history//entry//last-action-substatus").text.strip}"
            #else
            #    raise "Motive Failed :: Action status: #{@browser.current_page.parser.at_xpath("//history//entry//last-action-status").text} -- #{@browser.current_page.parser.at_xpath("//history//entry//last-action-substatus").text.strip}"
            #end
        end
    end
end

# TODO Clean up the output methods. These are mostly quick and ugly methods.
def output_to_file filename, output
    result_file = File.open(filename, "w+")
    result_file.write("##########BEGIN result##########\n")
    result_file.write("#{output}\n")
    result_file.write("##########END result##########\n")
end

def output_to_console output
    puts "##########BEGIN result##########\n"
    puts "#{output}\n"
    puts "##########END result##########\n"
end

options = OpenStruct.new
options.base_url = "http://iiothdm13.iot.motive.com/hdm"
options.username = "actiontec"
options.password = "760nmary"
options.timeout = "300"
options.failOnCRFailure_flag = "false"
options.debug = 0
options.quiet = false
options.parameter_list = []
#options.cwmp_conn_request=''
options.max_retries = 15
options.image_location = ""

OptionParser.new do |opts|
    opts.banner = "Motive Client using Motive Lib2: An interface to Motive without using Internet Explorer\n -- Usage: #{File.basename($0)} [OPTIONS]"
    opts.separator "\nMotive specific options (these options should already be included inside the script, only change if necessary)"
    opts.on("--username USER", "Motive username") {|o| options.username = o }
    opts.on("--password PASS", "Motive password") {|o| options.password = o }
    opts.on("--base URL", "Sets the Motive ACS base URL") { |o| options.base_url = o }
    opts.separator "\nClient options"
    opts.on("-w", "--cwmp_conn_request REQ", "do cwmp connection request when waiting for queue") { |o| options.cwmp_conn_request = o }
    opts.on("-v", "--operation OPERATION", "Sets the parameter operation") { |o| options.operation = o }
    opts.on("-g", "--image_location IMAGE_LOCATION", "Sets the image location") { |o| options.image_location = o }
    opts.on("-i", "--deviceID DEVICE_ID", "Sets the device id") { |o| options.device_id = o }
    opts.on("-s", "--serial DEVICE_SERIAL", "Sets the device serial number if -i options is not used") { |o| options.device_serial = o }
    opts.on("-c", "--config FILE", "Load the specified file to read parameters from") { |o| options.parameters_file = o}
    opts.on("-p", "--parameters PARAMS", "Parameters to run if -c options is not used"){ |o| options.parameter_list << o.strip unless o.match(/^#/)}
    opts.on("-m", "--stepmask STEP_MASK",Integer, "choose what operation should be do") { |o| options.stepmask = o}
    opts.on("-f", "--failOnCRFailure FLAG", "differentiate failOnCRFailure type") { |o| options.failOnCRFailure_flag = o }
    #opts.on("-e", "--datamodel FILE", "the path of data model file") { |o| options.data_model = o }
    opts.separator "Logging options"
    opts.on("-o", "--result FILE", "Send the results to the file specified instead of STDOUT") { |o| options.results_file = o }
    opts.on("-l", "--log FILE", "Sets the client logging file") { |o| options.log_file = o }
    opts.on("-x", "--debug LEVEL", Integer, "Sets the debug level (1-5)") { |o| options.debug = o }
    opts.on("--quiet", "Squelches logging to the console, but will still write to the log file") { options.quiet = true }
    opts.on("--timeout SECONDS", "Specifies the SERVER TIMEOUT (will time out if no PINGs are received from the SERVER (in seconds)") {|o| options.timeout = o }
    opts.separator ""
    opts.on("-d DEPRECATED_OPTION", "This option isn't used, but here for compatibility") {|o| options.deprecated_value_set = o}
    #opts.on("--timeout DEPRECATED_OPTION", "This option isn't used, but here for compatibility") {|o| options.deprecated_value_set = o}
    opts.on_tail("-h", "--help", "Shows these help options") { puts opts; exit }
end.parse!(lazy_space_removal)

#raise "Operation type must be set!" unless options.operation
#raise "No device serial number specified!" unless options.device_serial

Logging.logger.root.add_appenders(Logging.appenders.file(options.log_file, :layout => LOGGING_FORMAT)) if options.log_file
Logging.logger.root.add_appenders(Logging.appenders.stdout(:layout => LOGGING_FORMAT)) if options.debug unless options.quiet
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


retry_times = 1

begin
    unless options.stepmask
        logger.fatal "Step mask must be set!"
        raise "FATAL :: Step mask must be set!"
    end
    unless options.device_serial || options.device_id
        logger.fatal "You must pass at least device serial number or device id!"
        raise "FATAL :: You must pass at least device serial number or device id!"
    end
    #    unless options.operation.match(/spv/i) && options.data_model 
    #        logger.fatal "The operation SPV need defined data model file!"
    #        raise "FATAL :: The operation SPV need defined data model file!"
    #    end if options.operation

    #    if MotiveLib.supported_operation? options.operation
    #        unless options.parameters
    #            logger.fatal "You must pass at least one parameter or a parameter file!"
    #            logger.fatal "Exiting."
    #            raise "FATAL :: You must pass at least one parameter or a parameter file"
    #        end
    logger.debug "Starting Mechanize browser agent"
    motive_client = MC.new(options.device_serial, options.username, options.password, options.base_url, options.device_id, options.failOnCRFailure_flag, options.timeout, options.image_location)
    #logger.info "options.cwmp_conn_request : #{options.cwmp_conn_request}"
    motive_client.setCwmpConnRequest(options.cwmp_conn_request) unless options.cwmp_conn_request.nil?

    motive_client.login
    output = motive_client.execute(options.parameters, options.operation, options.stepmask)
    if options.results_file
        output_to_file options.results_file, output
    else
        output_to_console output
    end
    #    else
    #        logger.fatal "Not a valid or supported RPC operation #{options.operation}"
    #        raise "FATAL :: Not a valid or supported RPC operation #{options.operation}"
    #    end
rescue Exception => e
    logger.debug "There is something wrong : #{e.message}"
    logger.debug "Ping ACS server"
    system "ping iiothdm13.iot.motive.com -c 10"
    unless e.message.match(/Connection Request Failed/i)
        if options.max_retries && (options.max_retries >= retry_times)
            logger.debug "Retry: counter -- #{retry_times}  max retries -- #{options.max_retries}"
            retry_times += 1
            retry
        end
    end
    if options.results_file
        output_to_file options.results_file, "!#{e.message}"
    else
        output_to_console "!#{e.message}"
    end
    exit 1
end
