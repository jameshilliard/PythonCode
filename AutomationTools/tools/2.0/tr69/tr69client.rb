#!/usr/bin/env ruby
# == Copyright
# (c) 2011 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# Interacts with the TR69 server
# date--filename:line_number--method--priority> message\n
# Log layout "%d--%F:%L--%M--%l> %m"

$exit_status = 0

$: << File.dirname(__FILE__)
$: << "./common"

require 'rubygems'
require 'ip_utils'
require 'optparse'
require 'eventmachine'
require 'logging'
include Logging.globally

LOGGING_LEVEL = [:fatal, :error, :warn, :info, :debug]
ATTR_NOTIFICATIONS = %w[off passive active disable]
RPC_FORMATS = [/\A(\w+\.?)+\z/, /\A(\w+\.?)+=.+\z/, /\A(?:#{ATTR_NOTIFICATIONS.join '|'})\s(\w+\.?)+\z/]
RPC_KEYS = {:AddObj => 0, :DelObj => 0, :GPV => 0, :SPV => 1, :GPA => 0, :SPA => 2, :LCT => 0}
LOGGING_FORMAT = Logging.layouts.pattern.new(:pattern => "%d--%F:%4L--%M--%5l> %m\n", :date_pattern => "%Y/%m/%d %H:%M:%S")

options = {:debug_level=>0, :timeout => 60, :relay_server_logs => true}

class TR69Client < EventMachine::Connection
  include EM::P::LineText2
  attr_accessor :options

  def post_init
    @data = ""
    @set_op_type = true
    @set_comm_log = true
    @ask_for_relay = true
    @parameter_index = 0
    @get_log_type = false
    @stored_log_data = []
    @getting_device_log = false
    @getting_results = false
    @executed = false
  end

  def set_vars(opts)
    @options = opts
    @parameters = @options.has_key?(:parameter_file) ? File.open(@options[:parameter_file]).readlines : @options[:parameter]
    @parameters.delete_if {|x| x.nil? || x.match(/^#/) || x.strip.empty?}
    @regexp_check = RPC_FORMATS[RPC_KEYS[@options[:operation].to_sym]] rescue RPC_FORMATS[0]
    comm_inactivity_timeout = opts[:timeout]
    pending_connect_timeout = 15
    @parameters = ["NoneRequired"] if @options[:operation].match(/delcpe/i)
  end

  def parse_log data
    case data
    when /unable to find device/i
      $exit_status = -4
    when /failure.*not available/i
      $exit_status = -3
    when /failed to find/i
      $exit_status = -2
    when /expiration/i
      $exit_status = -1
    end
    if data.match /end #{@get_log_type} log/i
      if @options.has_key?("#{@get_log_type.downcase}_log".to_sym)
        File.open(@options["#{@get_log_type.downcase}_log".to_sym], "w+").write(@stored_log_data.join "\n")
      else
        @stored_log_data.each {|l| logger.info l; puts l}
      end
      @stored_log_data = []
      logger.debug "End #{@get_log_type.downcase} log"
      @get_log_type = false
    else
      @stored_log_data << data.rstrip
    end
  end

  def receive_line data
    if @get_log_type
      parse_log data
    else
      case data.strip.chomp
      when /BEGIN\s(.+)\sLOG/i
        @get_log_type = $1
        @stored_log_data = []
        logger.debug "Receiving #{@get_log_type} log"
      when /PING/
        logger.debug "Ping received - responding"
        @data.sub!(/ping/i, '')
        send_line "pong"
      when /server_log/i
        logger.debug data.strip
      when /TR69Server/i
        if @options[:device_serial_number]
          @data = ""
          logger.debug "Connected"
          @connection_time = Time.now.to_i
          send_line "device #{@options[:device_serial_number]}"
          logger.info "Set device serial to #{@options[:device_serial_number]}"
          @options[:device_serial_number] = false
        elsif @options[:expiration_timeout]
          logger.debug "Setting expiration timeout to #{@options[:expiration_timeout]}"
          send_line "expiration #{@options[:expiration_timeout]}"
          @options[:expiration_timeout] = false
        elsif @options[:operation].match(/addcpe|delcpe/i)
          if @set_op_type
            logger.debug "Running #{@options[:operation]}"
            @set_op_type = false
            logger.info "Set operation type to: #{@options[:operation]}"
            send_line "operation #{@options[:operation]}"
          elsif @parameters[@parameter_index]
            if @options[:operation].match(/add/i)
              send_line "parameter #{@parameters.first.strip}"
            else
              send_line "parameter NoneRequired"
            end
            @parameter_index+=1
          elsif @ask_for_relay && @options[:relay_server_logs]
            @ask_for_relay = false
            logger.debug "Relaying server logging"
            send_line "relay_log"
          else
            logger.info "Sending execute directive"
            send_line "execute"
            @executed = true
          end
        elsif @options[:operation].match(/lct/i)
          logger.debug "Getting last contact time"
          @set_op_type = false
          @ask_for_relay = false
          logger.info "Set operation type to: #{@options[:operation]}"
          send_line "contact_time"
        else
          if @parameters[@parameter_index].nil?
            unless @executed
              logger.info "Sending execute directive"
              send_line "execute"
              @executed = true
            end
          elsif @ask_for_relay && @options[:relay_server_logs]
            @ask_for_relay = false
            logger.debug "Relaying server logging"
            send_line "relay_log"
          elsif @set_op_type
            @set_op_type = false
            logger.info "Set operation type to: #{@options[:operation]}"
            send_line "operation #{@options[:operation]}"
          elsif @options.has_key?(:comm_log) && @set_comm_log
            @set_comm_log = false
            logger.debug "Set to receive communication log"
            send_line "comm_log"
          else
            if @parameters[@parameter_index].strip.match(@regexp_check)
              logger.debug "Adding parameter: #{@parameters[@parameter_index]}"
              send_line "parameter #{@parameters[@parameter_index].strip}"
            elsif @options[:operation].match(/action/i)
              logger.debug "Adding parameter: #{@parameters[@parameter_index]}"
              send_line "parameter #{@parameters[@parameter_index].strip}"
            else
              logger.error "Parameter #{@parameters[@parameter_index].strip} does not match the required format for the operation #{@options[:operation]}"
              logger.error "Skipping #{@parameters[@parameter_index].strip}"
            end
            @parameter_index+=1
          end
        end
      when /Last contact time was: /i
        logger.debug "Received LCT of #{data}"
        if @options.has_key?(:result_log)
          File.open(@options[:result_log], "w+").write(data)
        else
          logger.info data
          puts data
        end
      when /Finished processing/i
        logger.debug "Disconnecting"
        send_line "/quit"
        EventMachine::stop_event_loop
      when /Processing .*/i
        logger.debug "Server state #{data}"
      when /^OK\s\b(.*?)\b(?:$|\s(.*))/
        logger.debug "Server acknowledged #{$1} #{$2 ? $2 : ''}"
      when /^ERR\s\b(.*?)\b(?:$|\s(.*))/
        logger.fatal "Server rejected #{$1} #{$2 ? $2 : ''}"
        logger.fatal "Check your options! Exiting."
        send_line "/quit"
        EventMachine::stop_event_loop
      else
        logger.debug "Received - #{data.strip}"
      end
    end
  end

  def send_line data
    send_data "#{data}\n"
  end

  def unbind
    exit $exit_status
  end
end

ARGV.options do |opts|
  opts.banner = "TR69 Client: An interface to the Motive automation server. Usage: #{File.basename($0)} [OPTIONS]"
  opts.separator ""
  opts.on("-d", "--interface IP", "Interface name or IP address to listen on and the port. i.e. 127.0.0.1:6001") {|o| options[:server] = o}
  opts.on("-c", "--config FILE", "Specifices a parameter configuration file") {|o| options[:parameter_file] = o}
  opts.on("-s", "--serial NUMBER", "Sets the device serial number to use") {|o| options[:device_serial_number] = o}
  opts.on("-p", "--parameter TR69_PARAMETER", "Parameter to pass to the TR69 server") {|o| options[:parameter] = o.split(",")}
  opts.on("-f", "--diff FILE", "Specifies the file for the diff communication log") {|o| options[:comm_log] = o}
  opts.on("-l", "--log FILE", "Specifies the file for the debug log") {|o| options[:log_file] = o}
  opts.on("-v", "--operation OPERATION_TYPE", "Only run parameters with specific operation from configuration file") {|o| options[:operation] = o}
  opts.on("-x", "--debug LEVEL", "Specifies the debug level (0-4, where 4 is the most verbosity)") {|o| options[:debug_level] = o.to_i}
  opts.on("-o", "--result FILE", "Specifies the result output file") {|o| options[:result_log] = o}
  opts.on("--expiration TIMEOUT", "Specifies the Motive EXPIRATION TIMEOUT in seconds. 300 is default.") { |o| options[:expiration_timeout] = o.to_i}
  opts.on("--timeout SECONDS", "Specifies the SERVER TIMEOUT (will time out if no PINGs are received from the SERVER (in seconds)") {|o| options[:timeout] = o.to_i}
  opts.on("--no-relay", "Doesn't request a relay of the server logs") { |o| options[:relay_server_logs] = false }
  opts.on("-h", "--help", "Shows these help options") { puts opts; exit }
end.parse!

Logging.logger.root.level = LOGGING_LEVEL[options[:debug_level]]
Logging.logger.root.trace = true
Logging.logger['TR69Client'].trace = true

if options[:log_file]
  Logging.logger.root.add_appenders(Logging.appenders.file(options[:log_file], :layout => LOGGING_FORMAT))
else
  Logging.logger.root.add_appenders(Logging.appenders.stdout(:layout => LOGGING_FORMAT))
end

logger.info "Connecting to #{options[:server].ip} on port #{options[:server].port}"

EventMachine::run do
  EventMachine::connect options[:server].ip, options[:server].port, TR69Client do |client|
    client.set_vars(options)
  end
end
exit $exit_status
