# == Copyright
# (c) 2011 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

require 'rubygems'
gem 'watir', '~> 1.9'
require 'watir'
require 'digest/md5'
require 'motive_lib'
require 'nokogiri'

module MethodProxy
  def proxy_methods(*method_list)
    return @proxy_next_method = true if method_list.empty?
    method_list.delete_if {|set_method_name| proxy_method_call(set_method_name) if method_defined?(set_method_name) }
    @proxied_methods += method_list
  end

  private
  def proxy_method_call(called_method)
    old_method_name = instance_method(called_method)
    define_method(called_method) do |*args, &block|
      raise "Closing Motive session" if @close_session
      returned_value = old_method_name.bind(self).call(*args, &block)
      raise "Closing Motive session" if @close_session
      return returned_value
    end
  end

  def method_added(called_method)
    return super unless @proxied_methods.include?(called_method) || @proxy_next_method
    return super if @repeated == called_method
    @repeated = called_method
    proxy_method_call(called_method)
    @repeated = nil
    @proxy_next_method = false
    super
  end

  def self.extended(klass)
    klass.instance_variable_set(:@proxied_methods, [])
    klass.instance_variable_set(:@repeated, false)
    klass.instance_variable_set(:@proxy_next_method, false)
  end
end

class MotiveInterface < MotiveLib
  extend MethodProxy
  proxy_methods :device_lock, :device_log, :find_device, :login, :manage_device, :device_data_tab, :store_data_values, :refresh_xml_data, :queue_function, :save_function_queue, :wait_for_queue_completion, :add_parameters, :add_object
  attr_accessor :logs, :available_operations, :close_session, :expiration_timeout
  alias :login :login_to_motive

  def initialize(username, password, relay_logging=false, debug=false)
    @current_device_serial_number = ""
    @current_client = ""
    @logs = {:results => {}, :comm_log => {} }
    @close_session = false
    @relay_logging = relay_logging
    @expiration_timeout = 300
    super(username, password, debug)
  end

  def log msg
    logger.info msg
    @relay_logging.send_line("SERVER_LOG::#{msg}") if @relay_logging
  end

  def process(client_id, serial_number, operation, parameters, gcl=false)
    @current_client = client_id
    @system_settings[:retry_times] = 0

    begin
      unless login
        @close_session = true
        stop_browser
        log "Error logging in. Check the Motive username and password."
        @logs[:results] = "Error logging in. Check the Motive username and password."
        @logs[:comm_log] = "Error logging in. Check the Motive username and password."
        return true
      end
      case operation
      when /last_contact_time/i
        log "Finding last contact time for device #{serial_number}"
        if find_device serial_number
          manage_device
          @logs[:results] = @browser.span(:id, "deviceInfoLastContactTime").text.strip
        else
          @logs[:results] = "Unable to find device"
        end
      when /addcpe/i
        log "Adding CPE with serial number: #{serial_number}"
        @logs[:results] = add_device(serial_number, parameters.first)
        log @logs[:results]
      when /delcpe/i
        log "Deleting CPE with serial number: #{serial_number}"
        @logs[:results] = delete_device(serial_number) ? "Deleted CPE with serial number #{serial_number}" : "Unable to find device with serial number #{serial_number}"
        log @logs[:results]
      else
        log "Running #{operation} for #{serial_number}"
        if find_device serial_number
          log "Find device - beginning function queue process"
          manage_device
          unless @browser.span(:id, "deviceInfoActivationStatus").text.match(/activated/i)
            log "Device activation status is: #{@browser.span(:id, "deviceInfoActivationStatus").text}"
            @logs[:results] = "FATAL: #{@browser.span(:id, "deviceInfoActivationStatus").text}\nCan not run functions on this device!"
            return true
          end
          old_log = initialize_device gcl
          @logs[:results] = run_function(parameters, operation)
          @logs[:comm_log] = relinquish_device old_log
        else
          log "Unable to find device with serial number #{serial_number}"
          @logs[:results] = "Unable to find device. Removing from queue."
          @logs[:comm_log] = "Unable to find device. Removing from queue."
        end
      end
      stop_browser
      return true
    rescue Exception => e
      puts e.message
      if @close_session
        stop_browser
        return false
      else
        if @system_settings[:debug]
          debug_response = debug_mode e
          if debug_response == true
            retry
          else
            return debug_response
          end
        else
          if e.message.match(/Failed to find|Unable to locate/i)
            @logs[:results] = {"Failed" => e.message}
            @logs[:comm_log] = false
            relinquish_device false
            stop_browser
            return true
          end
          
          if @system_settings[:max_retries] == @system_settings[:retry_times]
            @logs[:results] = {"Failed" => "#{e.message}\nMaximum amount of retry attempts. Giving up."}
            stop_browser
            return true
          end
          @system_settings[:retry_times] += 1
          log "Page didn't load as expected. Refreshing and trying again."
          sleep 5
          unless login
            @close_session = true
            stop_browser
            log "Error logging in. Check the Motive username and password."
            @logs[:results] = "Error logging in. Check the Motive username and password."
            return false
          end
          retry
        end
      end
    end
  end

  private
  def enable; true; end
  def disable; false; end

  # Overwriting for session closing
  def wait_for_queue_completion(completion_wait_time)
    sleep 10
    Watir::Wait::until { @browser.table(:id, "action_history").text.match(/pending|running/i) }
    log "Waiting for queue completion"
    old_md5 = Digest::MD5.hexdigest(@browser.table(:id, "history_table").text)
    Watir::Wait::while(completion_wait_time) { raise "Closing Motive session" if @close_session; @browser.table(:id, "action_history").text.match(/pending|running/i) }
    Watir::Wait::while(completion_wait_time) { raise "Closing Motive session" if @close_session; md5_history_check old_md5 }
  end

  def refresh_xml_data
    @data_xml = Nokogiri::XML(@browser.html.slice(/<xml.*?<\/xml>/im).sub(/\sid=baselineData/, ''))
  end

  def initialize_device gcl=false
    rlog = false
    log "Locking device#{', and enabling device communication log' if gcl}"
    device_lock enable
    if gcl
      rlog = get_communication_log
      device_logging enable
    end
    return rlog
  end

  def relinquish_device gcl=false
    rlog = {}
    log "Unlocking device#{', and disabling device communication log' if gcl}"
    device_logging disable if gcl
    device_lock disable
    if gcl
      rlog = get_communication_log gcl
      device_logging enable
    end
    return rlog
  end

  def run_function(parameters, operation_type)
    if operation_type.match(/obj/i)
      device_data_tab
      refresh_xml_data
      @old_data = store_data_values(parameters, operation_type) if operation_type.match(/add/i)
      @old_data = store_data_values(parents_of(parameters), operation_type) if operation_type.match(/del/i)
      parameters.each do |parameter_name|
        queue_function AVAILABLE_OPERATIONS[operation_type]
        add_object parameter_name.split('=')[0]
        save_function_queue @expiration_timeout
      end
      # GPV to object add/delete fixes a known bug
      queue_function AVAILABLE_OPERATIONS["GPV"]
      refresh_xml_data
      (operation_type.match(/add/i) ? parameters.uniq : parents_of(parameters)).each do |parameter_name|
        add_parameter parameter_name.split('=')[0], parameter_name.split('=')[1]
      end
      close_dialog_with "Save"
      save_function_queue @expiration_timeout
      wait_for_queue_completion @expiration_timeout+60
    elsif operation_type.match(/action/i)
      parameters.each do |action_name|
        queue_action action_name
        save_function_queue @expiration_timeout
      end
      wait_for_queue_completion @expiration_timeout+60
      log "#{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 4).text} - #{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 5).text}"
      return "#{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 4).text} - #{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 5).text}"
    else
      queue_function AVAILABLE_OPERATIONS[operation_type]
      refresh_xml_data
      parameters.each { |parameter_name| add_parameter parameter_name.split('=')[0], parameter_name.split('=')[1] }
      close_dialog_with "Save"
      save_function_queue @expiration_timeout
      wait_for_queue_completion @expiration_timeout+60
    end

    if successful?
      log "#{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 4).text} - #{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 5).text}"
      device_data_tab
      sleep 10
      refresh_xml_data
      if operation_type.match(/obj/i)
        new_data = store_data_values(parameters, operation_type) if operation_type.match(/add/i)
        new_data = store_data_values(parents_of(parameters), operation_type) if operation_type.match(/del/i)
        return @old_data.diff(new_data)
      else
        return store_data_values(parameters, operation_type)
      end
    else
      log "#{AVAILABLE_OPERATIONS[operation_type]} state - Failed."
      return {"#{AVAILABLE_OPERATIONS[operation_type]} Operation" => "#{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 4).text} - #{@browser.table(:id, "history_table").row(:index, 2).cell(:index, 5).text}"}
    end
  end

  def debug_mode e
    puts "*** In debugging mode ***"
    while true
      print "\ndebug# "
      debug_cmd = STDIN.gets.chomp
      case debug_cmd
      when /skip/i
        puts "Skipping"
        cancel_dialog_action
        @browser.link(:href, /findDevices.do/).click
        manage_device
        relinquish_device
        return {"Failed" => "Force skip"}
      when /retry/i
        login
        return true
      when /backtrace/i
        puts e.message
        puts e.backtrace
      when /last_action/i
        puts e.backtrace
      when /restart/i
        stop_browser
        login
      when /all_text/i
        puts @browser.text
      when /element/i
        @browser.send debug_cmd.split(' ')[1], debug_cmd.split(' ')[2].to_sym, /#{Regexp.escape(debug_cmd.split(' ')[3])}/i
      when /xpath/i
        puts @data_xml.at_xpath(debug_cmd.split(' ')[1])
      when /data_out/i
        File.open(debug_cmd.split(' ')[1], 'w+').write(@browser.html.slice(/<xml.*?<\/xml>/im).sub(/\sid=baselineData/, ''))
      when /shutdown/i
        stop_browser
        exit
      else
        puts "Command \"#{debug_cmd}\" not supported"
      end
    end
  end
end
