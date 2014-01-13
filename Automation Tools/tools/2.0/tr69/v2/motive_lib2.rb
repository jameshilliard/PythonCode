require 'rubygems'
require 'mechanize'
require 'ostruct'
require 'logging'
include Logging.globally unless defined?(logger)

# Library for communicating with Motive ACS using Mechanize 2.0+
# Holds the main Motive functions. You can access this in your own scripts
# by making it a super class of your own defined class.
#
# This will output a log with the Logging gem via the global logger.
#
# ==Supports the following operations:
# * Get Parameter Values
# * Set Parameter Values
# * Get Parameter Attributes
# * Set Parameter Attributes
# * Add Object
# * Delete Object
# =author
#   Chris Born (cborn@actiontec.com)
# =copyright
#   Copyright (c) 2011 Actiontec Electronics, Inc.
class MotiveLib
  AVAILABLE_OPERATIONS = {
    "gpv" => "Get Parameter Values",
    "spv" => "Set Parameter Values",
    "gpa" => "Get Parameter Attributes",
    "spa" => "Set Parameter Attributes",
    "addobj" => "Add Object",
    "delobj" => "Delete Object"
  }
  AVAILABLE_VALUES = {
    "gpv" => "value",
    "spv" => "value",
    "gpa" => "notification",
    "spa" => "notification",
    "addobj" => "value",
    "delobj" => "value"
  }
  ATTR_NOTIFICATIONS = ["off", "passive", "active", "disable"]
  STATUS_OPTIONS = {
    :activation_status => "activationStatus",
    :lct => "lastContactTime",
    :lat => "lastActivationTime",
    :xml_data => "xml_data"
  }
  # @return [Hash{String => String}] Holds the results of the operation after it's completed
  attr_reader :results
  # @return [String, false] Holds the communication log of the device (when enabled). False if it's disabled.
  attr_reader :comm_log
  # @return [Object] The Mechanize object, held here in case raw processing is necessary
  attr_reader :browser

  # Creates a new session to interact with Motive.
  # Requires the device serial number, the Motive username, password,
  # and the base motive URL.
  #
  # @example Create a new session
  #    MotiveLib.new("CVJA1234567890", "joe_user", "joe_pass", "http://xatechdm.xdev.motive.com/hdm")
  def initialize(device_serial, motive_username, motive_password, base_url)
    @locations = OpenStruct.new
    @functions = OpenStruct.new

    @device_id = ""
    @comm_log = ""
    @comm_log_timestamp = false
    @serial_number = device_serial
    @motive_username = motive_username
    @motive_password = motive_password

    @locations.base = base_url.sub(/\/\z/, '')
    @locations.login = "#{@locations.base}/welcome/welcome.do"
    @locations.manage = "#{@locations.base}/SingleDeviceMgmt/getDevice.do?"
    @locations.data_model = "#{@locations.base}/DeviceType/getDataRecordXML.do?getUnusedParameters=true"
    @locations.data_record = "#{@locations.base}/DeviceType/getDataRecordXML.do?getUnusedParameters=false"
    @locations.log = "#{@locations.base}/communicationLog/getLog.do?viewSingleDevice=true&deviceTypeList=564&radViewLog=1&logFilterSelection=1&detailedLogLevel="
    @locations.find = "#{@locations.base}/device/findDevices.do"
    @locations.lock = "#{@locations.base}/xmlHttpDevice.do?operation=lockDevice"
    @locations.logging = "#{@locations.base}/xmlHttpDevice.do?operation=setDeviceLogLevel"
    @locations.queue_action = "#{@locations.base}/SingleDeviceMgmt/queueAction.do?"
    @locations.queue_history = "#{@locations.base}/xmlHttp.do?operation=getDeviceHistory"
    @locations.current_queue = "#{@locations.base}/xmlHttp.do?operation=getQueuedActions"

    @functions.gpv = "&expirationTimeOut=300&failOnCRFailure=false&actionComboString=Get+Parameter+Values&actionCombo=4&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound4=false&parameterTableType=0&requiredFieldsFunction4=parameterData:0&showConfirmDialog=on"
    @functions.spv = "&expirationTimeOut=300&failOnCRFailure=false&actionComboString=Set+Parameter+Values&actionCombo=5&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound5=false&parameterTableType=1&requiredFieldsFunction5=parameterData:0&showConfirmDialog=on"
    @functions.gpa = "&expirationTimeOut=300&failOnCRFailure=false&actionComboString=Get+Parameter+Attributes&actionCombo=10&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound10=false&parameterTableType=0&requiredFieldsFunction10=parameterData:0&showConfirmDialog=on"
    @functions.spa = "&expirationTimeOut=300&failOnCRFailure=false&actionComboString=Set+Parameter+Attributes&actionCombo=11&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound11=false&parameterTableType=3&requiredFieldsFunction11=parameterData:0&showConfirmDialog=on"
    @functions.addobj = "&expirationTimeOut=300&failOnCRFailure=false&actionComboString=Add+Object&actionCombo=6&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound6=false&requiredFieldsFunction6=AddObject.ObjectName%3A0&showConfirmDialog=on"
    @functions.delobj = "&expirationTimeOut=300&failOnCRFailure=false&actionComboString=Delete+Object&actionCombo=7&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound7=false&requiredFieldsFunction7=DeleteObject.ObjectName%3A0&showConfirmDialog=on"

    @browser = Mechanize.new {|a| a.user_agent_alias = "Windows IE 7" }
  end

  # Queue's an action as specified. Uses the initialed variant
  # (gpv, spa, addobj, and so on) along with the parameter list.
  # @param [String] action Defines the action as the abbreviated version (such as 'gpv' or 'spa')
  # @param [String] params Parameter string.
  # @see #add_parameters
  # @see #add_object
  # @return [String] Parameter string to be used in a browser.get operation.
  def queue_action action, params
    logger.debug "Finding operation string for #{action}"
    tstring = @functions.send(action.strip.downcase)
    raise "No such action #{action}." if tstring.nil?
    return "#{@locations.queue_action}deviceID=#{@device_id}#{tstring}#{params}"
  end

  # Changes the device serial number, and nulls out the other options that
  # were gathered during the session for the old serial number.
  # Will then automatically log back in to Motive, and find the
  # corresponding device ID
  # @param [String] serial device serial number
  def change_device serial
    logger.debug "Updating to device serial number #{serial}"
    @comm_log = ""
    @comm_log_timestamp = false
    @results = {}
    @serial_number = serial
    login
    find_device
  end

  # Updates the Motive user name or password, or both, and then logs in if necessary.
  # If a string is passed, only the username is updated.
  #
  # @param [Hash{Symbol => String}, String] info Hash or String containing Motive user information
  # @option info [String] :username Username
  # @option info [String] :password Password
  def update_motive_info info
    logger.debug "Updating motive information with #{info}"
    if info.is_a? Hash
      @motive_username = info[:username] if info[:username]
      @motive_password = info[:password] if info[:password]
    else
      @motive_username = info
    end
    login
  end

  # Loads the device management page for the specified device ID.
  # @return [Object] Mechanize browser page for the managed device
  def manage_device
    logger.debug "Jumping to device management page"
    @browser.get("#{@locations.manage}&deviceID=#{@device_id}")
  end

  # Gets the full device communication log.
  # @return [String] Unfiltered text of the communication log as seen in Motive.
  def device_comm_log
    logger.debug "Getting device communication log"
    @browser.get("#{@locations.log}&serialNumber=#{@serial_number}&deviceID=#{@device_id}").parser.at_xpath("//textarea[@id='logContainter']").text
  end

  # Retrieves the device data for results
  # @return [Object] Nokogiri object of the device data XML
  def device_data
    #logger.debug "Receiving device data"
    #@browser.get("#{@locations.data_record}&deviceID=#{@device_id}").parser
    max_ATTEMPTS = 3
    attempts = 0
    isokey = 0
    begin
        logger.debug "Receiving device data -- retry #{attempts}"
        temp_data_xml=@browser.get("#{@locations.data_record}&deviceID=#{@device_id}").parser
        isokey = 1
        return temp_data_xml
    rescue Exception => ex
        logger.info "try failed : #{ex}"
        attempts = attempts + 1
        retry if(attempts < max_ATTEMPTS)
    end

    if isokey==0
        #raise "Error"
        logger.error "try Receiving device data expired!"
        exit 1
    end

  end

  # Retrieves the data model when queueing a new parameter
  # @return [Object] Nokogiri object of the device data model XML
  def device_data_model
    #logger.debug "Loading device data model"
    #@browser.get("#{@locations.data_model}&deviceID=#{@device_id}").parser
    max_ATTEMPTS = 3
    attempts = 0
    isokey = 0
    begin
        logger.debug "Loading device data model -- retry #{attempts}"
        temp_data_xml=@browser.get("#{@locations.data_model}&deviceID=#{@device_id}").parser
        isokey = 1
        return temp_data_xml
    rescue Exception => ex
        logger.info "try failed : #{ex}"
        attempts = attempts + 1
        retry if(attempts < max_ATTEMPTS)
    end

    if isokey==0
        #raise "Error"
        logger.error "try loading device data model expired!"
        exit 1
    end
  end

  # Returns the device data for results, but without being passed through Nokogiri
  # @return raw XML of the device data
  def device_data_raw
    logger.debug "Receiving device data"
    @browser.get("#{@locations.data_record}&deviceID=#{@device_id}").body
  end

  # Returns a hash of the data after the operation is completed.
  # For parameter values and objects this is the value in the data model for the
  # parameters. For parameter attributes, it's the notification value.
  # @param [Array] parameters Array of parameters as they would be passed to Motive
  # @param [String] op_type Abbreviation string of the device operation to retrieve the correct values for the parameters passed
  # @return hash of data values in format of "ParameterString" => Value
  def store_data_values parameters, op_type
    logger.debug "Storing device data values"
    data_values = {}
    type_value = AVAILABLE_VALUES[op_type.strip.downcase]
    data_xml = device_data
    logger.debug "Getting and storing data values for parameters"
    parameters.each do |p_name|
      parameter_name = p_name.split('=')[0]
      parameter_name.strip!
      attr_notification = parameter_name.match(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i) ? parameter_name.slice!(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i).strip : false
      logger.debug "Parsing #{parameter_name}"
      if parameter_name.match(/\.\z/)
        data_xml.xpath("//item[@name='#{parameter_name.sub(/\.\z/, '')}']//parameter").each do |x| 
            begin
                data_values[x.at_xpath('name').text] = x.at_xpath(type_value).text
            rescue Exception => e
                logger.warn("#{parameter_name} not found. Skipping.")
                data_values[x.at_xpath('name').text] = "WARNING: parameter is not found in data model."
            end
        end
      else
        begin
            data_values[parameter_name] = data_xml.at_xpath("//parameter[name='#{parameter_name}']//#{type_value}").text
        rescue 
            logger.warn("#{parameter_name} not found. Skipping.")
            data_values[parameter_name] = "WARNING: parameter is not found in data model."
        end
      end
    end
    logger.debug "Finished storing data values"
    return data_values
  end

  # Parses the communication log. On the first call it will
  # find the last time stamp. On the second call, it will
  # store all data from the beginning to the time stamp it found
  # earlier.
  # @see #comm_log
  def parse_communication_log
    logger.debug "Parsing communication log"
    temp_log = device_comm_log
    log_text = @comm_log_timestamp ? temp_log.index(@comm_log_timestamp) : temp_log[0..20]
    if log_text.is_a?(Integer)
      logger.debug "Storing communicating log for the latest time stamp"
      log_text = temp_log[0..(log_text-1)]
      log_text = temp_log if log_text.empty?
      @comm_log = log_text.dup
    else
      logger.debug "Found last time stamp as #{log_text}"
      @comm_log_timestamp = log_text.dup
    end
  end

  # Adds parameters. This ONLY works for values and attributes.
  # @param [Array] parameters Array of parameters used in the following formats:
  # @example GPV or GPA
  #   add_parameters ["InternetGatewayDevice.LANDevice.", "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID"]
  # @example SPV
  #   add_parameters ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID=someSSID", "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Channel=9"]
  # @example SPA
  #   add_parameters ["active InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Channel", "off InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID"]
  # @note This doesn't do parameter checking for you. If, for instance, you run a GPV and your parameter has a value set to it
  #   you might end up with some strange results. Please be aware.
  # @return [String] Parameters string
  # @return [nil] If no parameters were added
  # @see #add_object
  def add_parameters parameters
    logger.debug "Creating parameters string"
    data_xml = device_data_model
    param_combination_string = []
    index_subtraction = 0
    parameters.each_index do |i|
      param_combination_string[i] = ""
      parameter_name, parameter_value = parameters[i].split("=")
      parameter_name.strip!
      parameter_value.strip! if parameter_value
      attr_notification = parameter_name.match(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i) ? parameter_name.slice!(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i).strip : false
      logger.info "Adding parameter #{parameter_name}#{parameter_value ? ' = ' + parameter_value : ''}"
      if parameter_value
        type = data_xml.at_xpath("//parameter[name='#{parameter_name}']//type")
        if type.nil?
          type = data_xml.at_xpath("//parameter[name='#{parameter_name.gsub(/\.\d+\./, '.{i}.')}']//type")
          if type.nil?
            index_subtraction+=1
            logger.warn "Failed to find #{parameter_name} or the generic alternative #{parameter_name.gsub(/\.\d+\./, '.{i}.')} in the data model"
            logger.warn "Skipping #{parameter_name}"
            next
          end
        end
        logger.debug "Adding as type #{type.text}"
        param_combination_string[i] << "&parameterType#{i-index_subtraction}:0=#{type.text}&parameterValue#{i}:0=#{parameter_value}"
      end
      param_combination_string[i] << "&parameterName#{i-index_subtraction}:0=#{parameter_name}"
      param_combination_string[i] << "&attributeName#{i-index_subtraction}:0=notification&attributeValue#{i}:0=#{attr_notification}" if attr_notification
    end
    return nil if param_combination_string.empty?
    param_combination_string << "&parameterCount:0=#{parameters.length-index_subtraction}"
    return param_combination_string.join
  end

  # Adds objects. This will only add one object at a time, so it requires
  # multiple calls for multiple objects. This MUST be queued individually for each object!
  # Adds parameters. This ONLY works for values and attributes.
  # @param [String] object Object string
  # @param [String] action The action to take - either addobj, or delobj
  # @example AddObj
  #   add_object "InternetGatewayDevice.Layer3Forwarding.Forwarding."
  # @example DelObj
  #   add_object "InternetGatewayDevice.Layer3Forwarding.Forwarding.1"
  # @return [String] Object string
  # @see #add_parameters
  def add_object object, action
    object_string = ""
    object_name, object_label = object.split("=")
    object_action = action.match(/add/i) ? "AddObject" : "DeleteObject"
    logger.debug "#{object_action} on #{object_name} (#{object_label})"

    object_string << "&#{object_action}.ObjectName:0=#{object_name}"
    object_string << "&#{object_action}.ObjectLabel:0=#{object_label}" if object_label unless object_action == "DeleteObject"
    return object_string
  end

  # This will get the login location URL derived from the base URL,
  # and then proceed to login if a login is found.
  def login
    logger.debug("Logging in")
    @browser.get("#{@locations.login}")
    if @browser.current_page.form('loginForm').nil?
      logger.debug("Already logged in")
      return
    end
    @browser.current_page.form('loginForm').j_username = @motive_username
    @browser.current_page.form('loginForm').j_password = @motive_password
    begin
        @browser.submit(@browser.current_page.form('loginForm'), @browser.current_page.form('loginForm').buttons.first)
    rescue Exception => ex
          logger.error "Error: #{ex}"
          #raise "Login failed"
          exit 1
    end

    logger.info("Login successful")
  end

  # Finds the device ID and stores it in the private instance var +@device_id+.
  # This must be called the first time for any new instantiated method
  # by your own routines. It's done automatically when changing the serial
  # number with change_device.
  # @raise Errors when it cannot find the device ID from the serial number provided
  # @see #change_device
  def find_device
    logger.debug "Finding device"
    @browser.get(@locations.find)
    @browser.current_page.form("selectSearchProfile").field("searchProfile").option_with(:text => /by Serial Number/).select
    @browser.current_page.form("selectSearchProfile").add_field!("serialNumber", @serial_number)
    @browser.submit(@browser.current_page.form("selectSearchProfile"), @browser.current_page.form("selectSearchProfile").buttons[0])
    @browser.current_page.parser.xpath("//table[@id='data_table']//td/a").each do |dev|
      @device_id = dev.parent.parent.at_xpath("//button[@id='disableDevice']").attribute('onclick').value.slice(/'.*(?=')/).delete('^[0-9]') if dev.text.include?(@serial_number)
    end
    if @device_id.empty?
      logger.fatal "No device found with serial number #{@serial_number}"
      raise "No device found with serial number #{@serial_number}"
    end
    logger.info "Found device ID - #{@device_id}"
  end

  # Locks or unlocks the device ID.
  # @example Lock
  #   set_device_lock "lock"
  # @example Unlock
  #   set_device_lock "unlock"
  def set_device_lock state
    device_status = get_device_status("captured").match(/true/i) ? "Locked" : "Unlocked"
    logger.debug "Setting device lock to '#{state}'. Current state is '#{device_status.downcase}'"
    unless device_status.match(/^#{state}/i)
      @browser.get("#{@locations.lock}&deviceID=#{@device_id}&status=#{state}")
      device_status = get_device_status("captured").match(/true/i) ? "Locked" : "Unlocked"
    end
    logger.info "Device lock set to '#{device_status.downcase}'"
  end

  # Enables or disables device communicating logger.
  # @example Enable device logging
  #   device_logging "enable"
  # @example Disable device logging
  #   device_logging "disable"
  def device_logging state
    device_status = get_device_status("loggingEnabled").match(/true/i) ? "Enabled" : "Disabled"
    logger.debug "Setting device logging to '#{state}'. Current state is '#{device_status.downcase}'"
    unless device_status.match(/^#{state}/i)
      @browser.get("#{@locations.logging}&deviceID=#{@device_id}&status=#{state}")
      device_status = get_device_status("loggingEnabled").match(/true/i) ? "Enabled" : "Disabled"
    end
    logger.info "Device logging set to '#{device_status.downcase}'"
  end

  # Returns the device status variable specified.
  def get_device_status optvar
    logger.debug "Checking device status for #{optvar}"
    return @browser.get("#{@locations.base}/ajax.do?operation=getDeviceById&deviceId=#{@device_id}").body.slice(/#{optvar}:.*/).sub("#{optvar}:", '').strip.gsub(/\A'|',\z|,\z/,'') rescue nil
  end

  # Waits for the queue to empty, for a maximum of 1800 seconds.
  # @param [Integer] timeout Sets the timeout value if requested. This is meant if you want a wait time lower than the absolute maximum poll time.
  # @return [true, nil] True if the wait was successful, nil if the wait time was exceeded
  def wait_for_queue_completion timeout=nil
    # Queued: //action//caller-id, History: //entry//policy-id
    logger.info "Waiting for queue completion"
    start_wait_time = Time.now.to_i
    max_polls = 30
    poll_counter = 1
    while @browser.get("#{@locations.current_queue}&deviceID=#{@device_id}").body.match(/pending|running/i)
      if poll_counter == max_polls
        logger.fatal "Queue maximum wait time hit. Aborting."
        return nil
      end
      if timeout && (Time.now.to_i > (start_wait_time+timeout))
        logger.fatal "Queue timeout hit. Aborting wait cycle."
        return nil
      end
      sleep 60 # Motive uses a poll interval of 60,000ms, we do not want to exceed that poll.
      poll_counter += 1 # Motive also uses a poll maximum of 30. We do not want to exceed the poll count either.
    end
    return true
  end

  # Checks the device history
  # @return [true,false] True when successful, otherwise false
  def success?
    @browser.get("#{@locations.queue_history}&deviceID=#{@device_id}")
    logger.info "Action status: #{@browser.current_page.parser.at_xpath("//history//entry//last-action-status").text} -- #{@browser.current_page.parser.at_xpath("//history//entry//last-action-substatus").text.strip}"
    return (@browser.current_page.parser.at_xpath("//history//entry//last-action-status").text.match(/success/i) ? true : false)
  end

  # Checks if a device is activated
  # @return [true,false] True when activated, false for any other status
  def device_activated?
    logger.debug "Checking activation status"
    device_status = get_device_status("activationStatus")
    logger.info "Device activation status: #{device_status}"
    return device_status == "Activated"
  end

  # Helper method to return the immediate parent of the passed parameter string
  # @param [Array, String] parameter If an Array is passed, will only find the parent of the first element
  # @return [String] Parent parameter String
  # @example Find the parent of InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID
  #   parent_of "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID" #=> "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1."
  # @example Find the parent of InternetGatewayDevice.LANDevice.1.
  #   parent_of "InternetGatewayDevice.LANDevice.1.WLANConfiguration.1." #=> "InternetGatewayDevice.LANDevice."
  def parent_of parameter
    parameter_tree = parameter.is_a?(Array) ? parameter.first.split('.') : parameter.split('.')
    parent = parameter_tree[0] + '.' + (parameter_tree[1..-2].join('.'))
    return parent.sub(/\z/,'.').squeeze('.')
  end

  # Same as #parent_of, but will find all parents of an entire Array of parameters.
  # @see #parent_of
  def parents_of parameters
    new_list = []
    parameters.each do |parameter|
      parameter_tree=parameter.split('.')
      parent = parameter_tree[0] + '.' + (parameter_tree[1..-2].join('.'))
      new_list << parent.sub(/\z/,'.').squeeze('.')
    end
    return new_list.uniq
  end

  # Checks to see if the passed operation is a supported operation type
  # @return [true,false] True if supported, false if not
  def self.supported_operation? operation
    if AVAILABLE_OPERATIONS.has_key?(operation.downcase) || AVAILABLE_OPERATIONS.has_value?(operation)
      return true
    else
      return false
    end
  end

  # Checks to see if the passed value retrieval is supported
  # (Such as Last Contact Time, and Activation Status)
  # @return [true,false] True if supported, false if not
  def self.supported_value_retrieval? value
    return true if STATUS_OPTIONS.has_key?(value.downcase.to_sym)
    return false
  end
end
