# == Copyright
# (c) 2011 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

class MotiveLib
  AVAILABLE_OPERATIONS = {
    "GPV" => "Get Parameter Values",
    "SPV" => "Set Parameter Values",
    "GPA" => "Get Parameter Attributes",
    "SPA" => "Set Parameter Attributes",
    "AddObj" => "Add Object",
    "DelObj" => "Delete Object",
    "ACTION" => "action",
    "ADDCPE" => "addcpe",
    "DELCPE" => "delcpe"
  }
  AVAILABLE_VALUES = {
    "GPV" => "value",
    "SPV" => "value",
    "GPA" => "notification",
    "SPA" => "notification",
    "AddObj" => "value",
    "DelObj" => "value",
  }
  ATTR_NOTIFICATIONS = %w[off passive active disable]

  def initialize(username, password, debug)
    @last_action = Time.now.to_i
    @system_settings = {
      :debug => debug,
      :max_retries => 2,
      :retry_times => 0,
      :last_failure => "",
      :motive_username => username,
      :motive_password => password
    }
    @data_xml = FALSE
    @browser=nil
  end

  def md5_history_check old_md5
    new_text = ""
    Watir::Wait::while { (new_text = @browser.table(:id, "history_table").text).empty? }
    Digest::MD5.hexdigest(new_text) == old_md5
  end

  def wait_for_queue_completion(completion_wait_time)
    sleep 10 # Work around for a Motive issue
    Watir::Wait::until { @browser.table(:id, "action_history").text.match(/pending|running/i) }
    log "Waiting for queue completion"
    old_md5 = Digest::MD5.hexdigest(@browser.table(:id, "history_table").text)
    Watir::Wait::while(completion_wait_time) { @browser.table(:id, "action_history").text.match(/pending|running/i) }
    Watir::Wait::while(completion_wait_time) { md5_history_check old_md5 }
  end

  def successful?
    log "Checking for successful run"
    @browser.table(:id, "history_table").row(:index, 2).cell(:index, 4).text.match(/success/i)
  end

  def add_parameter parameter_name, parameter_value=false
    log "Adding parameter #{parameter_name} #{parameter_value ? ' = ' + parameter_value : ''}"
    attr_action = parameter_name.match(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/) ? parameter_name.slice!(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i).strip : false
    @browser.frame(:id, "dialogFrame").text_field(:id, "selectedParameterName").set(parameter_name)
    if parameter_value
      type = @data_xml.at_xpath("//parameter[name='#{parameter_name}']//type")
      if type.nil?
        type = @data_xml.at_xpath("//parameter[name='#{parameter_name.gsub(/\.\d+\./, '.{i}.')}']//type")
        if type.nil?
          @browser.frame(:id, "dialogFrame").button(:text, "Cancel").click
          raise "Failed to find #{parameter_name} or the generic alternative #{parameter_name.gsub(/\.\d+\./, '.{i}.')} in the data model"
        end
      end
      @browser.frame(:id, "dialogFrame").text_field(:id, "selectedParameterValue").clear
      @browser.frame(:id, "dialogFrame").text_field(:id, "selectedParameterValue").set(parameter_value) unless parameter_value.match(/null_null/i)
      @browser.frame(:id, "dialogFrame").select_list(:id, "selectedParameterType").select(/\A#{type.text}/i)
    end
    if attr_action
      @browser.frame(:id, "dialogFrame").select_list(:id, "notificationValue").select(/\A#{attr_action}/i)
    end
    @browser.frame(:id, "dialogFrame").button(:text, "Add").click
  end

  def add_object parameter_name
    log "Setting object name to #{parameter_name}"
    @browser.text_field(:id, /ObjectName:0/).set(parameter_name)
    @browser.div(:id, "actionParametersContainer").button(:text, "Queue").click
  end

  def store_data_values parameters, op_type
    data_values = {}
    type_value = AVAILABLE_VALUES[op_type]
    log "Getting and storing data values for parameters"
    parameters.each do |p_name|
      attr_action = p_name.match(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/) ? p_name.slice!(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i).strip : false
      parameter_name = p_name.split('=')[0]
      log "Parsing #{parameter_name}"
      if parameter_name.match(/\.\z/)
        @data_xml.xpath("//item[@name='#{parameter_name.sub(/\.\z/, '')}']//parameter").each {|x| data_values[x.at_xpath('name').text] = x.at_xpath(type_value).text }
      else
        data_values[parameter_name] = @data_xml.at_xpath("//parameter[name='#{parameter_name}']//#{type_value}").text
      end
    end
    return data_values
  end

  def close_dialog_with button_text
    @browser.frame(:id, "dialogFrame").button(:text, button_text).click
    Watir::Wait::while { @browser.frame(:id, "dialogFrame").visible? }
  end

  def cancel_dialog_action
    @browser.frame(:id, "dialogFrame").button(:text, "Cancel").click if @browser.frame(:id, "dialogFrame").visible?
  end

  def wait_for_dialog
    Watir::Wait::until { @browser.frame(:id, "dialogFrame").visible? } rescue return false
    return true
  end

  def login_to_motive
    @browser = Watir::IE.new if @browser.nil?
    @browser = Watir::IE.new unless @browser.exists?
    @browser.speed = :zippy
    @browser.goto("https://xatechdm.xdev.motive.com/hdm")
    return true unless @browser.text_field(:id, "j_username").exists?
    log "Logging in"
    @browser.text_field(:id, "j_username").set(@system_settings[:motive_username])
    @browser.text_field(:id, "j_password").set(@system_settings[:motive_password])
    @browser.button(:text, "Log On").click
    return (not(@browser.text.include?("Logon Error")))
  end

  def find_device serial
    @browser.link(:href, /findDevices.do/).click
    @browser.select_list(:id, "searchProfile").select(/serial number/i)
    @browser.text_field(:name, "serialNumber").set(serial)
    @browser.button(:text, "Find Devices").click
    return (not(@browser.text.match(/no devices match/i)))
  end

  def manage_device
    log "Managing device"
    @browser.button(:text, "Manage").click
  end

  def device_lock state
    lock_state = state ? "lock" : "unlock"
    Watir::Wait::while { @browser.button(:id, "lockDeviceButton").disabled? }
    device_status = @browser.span(:id, "deviceInfoLockedStatus").text

    unless device_status.match(/^#{lock_state}/i)
      @browser.button(:id, "lockDeviceButton").click
      Watir::Wait::while { @browser.span(:id, "deviceInfoLockedStatus").text == device_status }
      device_status = @browser.span(:id, "deviceInfoLockedStatus").text
    end
    log "Lock status - #{device_status}"
  end

  def device_logging state
    log_state = state ? "enable" : "disable"
    Watir::Wait::while { @browser.button(:id, "enableDeviceLoggingButton").disabled? }
    device_status = @browser.button(:id, "enableDeviceLoggingButton").html.match(/Disable communication logging for this device/i) ? "Enabled" : "Disabled"

    unless device_status.match(/#{log_state}/i)
      @browser.button(:id, "enableDeviceLoggingButton").click
      wait_for_dialog
      close_dialog_with "OK"
      device_status = @browser.button(:id, "enableDeviceLoggingButton").html.match(/Disable communication logging for this device/i) ? "Enabled" : "Disabled"
    end
    log "Logging status - #{device_status}"
  end

  def device_data_tab
    @browser.refresh # Fixes a problem with device data being loaded and cached on page
    @browser.link(:text, "Device Data").click
    Watir::Wait::while(240) { @browser.text.match(/an error occurred while loading data/i) || @browser.div(:id, "baselineData_tree").text.empty? || @browser.text.match(/loading/i) }
    raise "Data failed to load" if @browser.text.match(/an error occurred while loading data/i)
  end

  def get_communication_log timestamp=false
    Watir::Wait::while { @browser.button(:id, "viewLogButton").disabled? }
    @browser.button(:id, "viewLogButton").click
    log_text = timestamp ? @browser.text_field(:id, "logContainter").text.index(timestamp) : @browser.text_field(:id, "logContainter").text[0..20]
    if log_text.is_a?(Integer)
      log_text = @browser.text_field(:id, "logContainter").text[0..(log_text-1)]
      log_text = @browser.text_field(:id, "logContainter").text if log_text.empty?
    end
    @browser.button(:text, "Finished").click
    Watir::Wait::while { @browser.button(:id, "lockDeviceButton").disabled? }
    return log_text
  end

  def queue_function(motive_function)
    log "Queueing for #{motive_function}"
    catch :disabled_action do
      @browser.div(:id, "actionParametersContainer").button(:text, "Cancel").click if @browser.div(:id, "actionParametersContainer").button(:text, "Cancel").visible?
      @browser.link(:text, "Queue Function").click
      Watir::Wait::until { @browser.select_list(:id, "actionCombo").exists? } rescue throw :disabled_action
      @browser.select_list(:id, "actionCombo").select(/select a function/i) unless @browser.select_list(:id, "actionCombo").getSelectedItems[0].match(/select a function/i)
      @browser.select_list(:id, "actionCombo").select(/#{motive_function}/i)
      Watir::Wait::while(10) { @browser.div(:id, "queueFuctionContainerContent").button(:id, "queueButton").class_name.match(/disabled/i) } rescue throw :disabled_action
      @browser.div(:id, "queueFuctionContainerContent").button(:id, "queueButton").click
      unless motive_function.match(/object/i)
        if wait_for_dialog
          Watir::Wait::while(240) { @browser.frame(:id, "dialogFrame").text.match(/loading data/i) }
        else
          @browser.div(:id, "actionParametersContainer").button(:text, "Cancel").click
          throw :disabled_action
        end
      end
    end
  end

  def queue_action(motive_function)
    log "Queueing for #{motive_function}"
    @browser.link(:text, "Queue Action").click
    Watir::Wait::until { @browser.select_list(:id, "policyActionCombo").exists? }
    @browser.select_list(:id, "policyActionCombo").select("#{motive_function}")
    @browser.div(:id, "queuePolicyActionContainerContent").button(:id, "queueActionButton").click
  end

  def delete_device(serial_number)
    return false unless find_device(serial_number)
    @browser.checkbox(:name, "objectItem").click
    @browser.span(:id, "delete_device_span").click
    close_dialog_with "OK"
    return true
  end

  def add_device(serial_number, device_type)
    # CVJA0471009797
    @browser.link(:href, /findDevices.do/).click
    @browser.span(:id, "new_span").click
    @browser.select_list(:id, "deviceType").select(device_type)
    @browser.text_field(:id, "serialNumber").set(serial_number)
    @browser.text_field(:name, "httpPublicUsername").set(serial_number)
    @browser.text_field(:name, "httpPublicPassword").set(serial_number)
    @browser.text_field(:name, "httpPublicPasswordConfirm").set(serial_number)
    @browser.text_field(:name, "connectionRequestUsername").set(serial_number)
    @browser.text_field(:name, "connectionRequestPassword").set(serial_number)
    @browser.text_field(:name, "connectionRequestPasswordConfirm").set(serial_number)
    @browser.span(:id, "saveButton_span").click
    if wait_for_dialog
      error_message = @browser.frame(:id, "dialogFrame").tables[1].text
      close_dialog_with "OK"
      return error_message
    else
      return "Added"
    end
  end

  def save_function_queue(timeout_value)
    log "Saving queue"
    @browser.div(:id, "actionParametersContainer").button(:text, "Queue").click
    wait_for_dialog
    set_timeout_to timeout_value
  end

  def set_timeout_to(timeout_value)
    Watir::Wait::until { @browser.frame(:id, "dialogFrame").checkbox(:name, "failOnCRFailure").exists? }
    log "Changing timeout value and removing fail on connection request failure"
    @browser.frame(:id, "dialogFrame").checkbox(:name, "failOnCRFailure").clear
    @browser.frame(:id, "dialogFrame").text_field(:name, "expirationTimeOut").set(timeout_value.to_s)
    close_dialog_with "Queue"
  end

  def parent_of parameter
    parameter_tree = parameter.is_a?(Array) ? parameter.first.split('.') : parameter.split('.')
    parent = parameter_tree[0] + '.' + (parameter_tree[1..-2].join('.'))
    return parent.sub(/\z/,'.').squeeze('.')
  end

  def parents_of parameters
    new_list = []
    parameters.each do |parameter|
      parameter_tree=parameter.split('.')
      parent = parameter_tree[0] + '.' + (parameter_tree[1..-2].join('.'))
      new_list << parent.sub(/\z/,'.').squeeze('.')
    end
    return new_list.uniq
  end

  def log msg
    puts "#{msg}"
  end

  def stop_browser
    @browser.close if @browser && @browser.exist? unless @browser.nil?
    @browser = nil
  end

  def supported_operation? operation
    if AVAILABLE_OPERATIONS.has_key?(operation) || AVAILABLE_OPERATIONS.has_value?(operation)
      return true
    else
      return false
    end
  end

  def supported_value_retrieval? value
    return true if @status_options.has_key?(value.downcase.to_sym)
    return false
  end

  def operation_name operation
    return operation if AVAILABLE_OPERATIONS.has_key?(operation)
    return AVAILABLE_OPERATIONS.key(operation) if AVAILABLE_OPERATIONS.has_value?(operation)
  end
end
