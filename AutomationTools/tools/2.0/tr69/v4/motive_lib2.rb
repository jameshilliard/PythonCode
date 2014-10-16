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
#   Andy Liu (aliu@actiontec.com)
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
    # @return [Object] The Mechanize object, held here in case raw processing is necessary
    attr_reader :browser

    # Creates a new session to interact with Motive.
    # Requires the device serial number, the Motive username, password,
    # and the base motive URL.
    #
    # @example Create a new session
    #    MotiveLib.new("00247BE01AD0", "ps_training", "actiontec135", "http://xatechdm.xdev.motive.com/hdm", "11840")
    def initialize(device_serial, motive_username, motive_password, base_url, device_id, failOnCRFailure_flag, timeout, image_location)
        @locations = OpenStruct.new
        @functions = OpenStruct.new


        @device_id = device_id.nil? ? "" : device_id 
        @result_flag = 0
        @serial_number = device_serial.nil? ? "" : device_serial
        @image_location = image_location.nil? ? "" : image_location
        @motive_username = motive_username
        @motive_password = motive_password
        @wget_url=nil

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

        @functions.gpv = "&expirationTimeOut=#{timeout.strip}&failOnCRFailure=#{failOnCRFailure_flag.strip.downcase}&actionComboString=Get+Parameter+Values&actionCombo=4&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound4=false&parameterTableType=0&requiredFieldsFunction4=parameterData:0&showConfirmDialog=on"
        @functions.spv = "&expirationTimeOut=#{timeout.strip}&failOnCRFailure=#{failOnCRFailure_flag.strip.downcase}&actionComboString=Set+Parameter+Values&actionCombo=5&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound5=false&parameterTableType=1&requiredFieldsFunction5=parameterData:0&showConfirmDialog=on"
        @functions.gpa = "&expirationTimeOut=#{timeout.strip}&failOnCRFailure=#{failOnCRFailure_flag.strip.downcase}&actionComboString=Get+Parameter+Attributes&actionCombo=10&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound10=false&parameterTableType=0&requiredFieldsFunction10=parameterData:0&showConfirmDialog=on"
        @functions.spa = "&expirationTimeOut=#{timeout.strip}&failOnCRFailure=#{failOnCRFailure_flag.strip.downcase}&actionComboString=Set+Parameter+Attributes&actionCombo=11&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound11=false&parameterTableType=3&requiredFieldsFunction11=parameterData:0&showConfirmDialog=on"
        @functions.addobj = "&expirationTimeOut=#{timeout.strip}&failOnCRFailure=#{failOnCRFailure_flag.strip.downcase}&actionComboString=Add+Object&actionCombo=6&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound6=false&requiredFieldsFunction6=AddObject.ObjectName%3A0&showConfirmDialog=on"
        @functions.delobj = "&expirationTimeOut=#{timeout.strip}&failOnCRFailure=#{failOnCRFailure_flag.strip.downcase}&actionComboString=Delete+Object&actionCombo=7&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound7=false&requiredFieldsFunction7=DeleteObject.ObjectName%3A0&showConfirmDialog=on"
        @functions.downld = "&expirationTimeOut=#{timeout.strip}&failOnCRFailure=#{failOnCRFailure_flag.strip.downcase}&actionComboString=Download+File&actionCombo=8&delete__queuedActionId=&delete__queuedActionDeviceId=&delete__queuedActionFunctionName=&policyActionCombo=1061&policyActionId=&queuedActionscurrentTab=queueFuctionContainer&isDeviceTypeBound8=false&choiceTypeECL_Download.Filetype%3A0=select&selectECL_Download.Filetype%3A0=1+Firmware+Upgrade+Image&textECL_Download.Filetype%3A0=&Download.Url%3A0=#{image_location.strip}&Download.Username%3A0=&Download.Password%3A0=&Download.Filesize%3A0=0&Download.TargetFilename%3A0=&Download.DelaySeconds%3A0=&Download.SuccessURL%3A0=&Download.FailureURL%3A0=&requiredFieldsFunction8=Download.Filetype%3A0%2CDownload.Url%3A0%2CDownload.Filesize%3A0&showConfirmDialog=on"

        @browser = Mechanize.new {|a| a.user_agent_alias = "Windows IE 7" }
        @browser.idle_timeout = 2
        @browser.keep_alive = false
    end

    #
    #
    #
    #
    def setCwmpConnRequest(req)
        @cwmp_conn_req = req
        logger.info "set cwmp connection request command : #{@cwmp_conn_req}"
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
        logger.debug "queue action : \n #{@locations.queue_action}deviceID=#{@device_id}#{tstring}#{params}"
        return "#{@locations.queue_action}deviceID=#{@device_id}#{tstring}#{params}"
    end

    # Loads the device management page for the specified device ID.
    # @return [Object] Mechanize browser page for the managed device
    def manage_device
        logger.debug "Jumping to device management page"
        @browser.get("#{@locations.manage}&deviceID=#{@device_id}")
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
        param_combination_string = []
        parameters.each_index do |i|
            param_combination_string[i] = ""
            parameter_name, parameter_set = parameters[i].split("=")
            parameter_name.strip!
            parameter_set.strip! if parameter_set
            attr_notification = parameter_name.match(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i) ? parameter_name.slice!(/^(#{ATTR_NOTIFICATIONS.join '|'})\s/i).strip : false
            logger.info "Adding parameter #{parameter_name}#{parameter_set ? ' = ' + parameter_set : ''}"
            if parameter_set
                parameter_value , parameter_type = parameter_set.split("::%#")
                logger.debug "Adding as type #{parameter_type}"
                parameter_value = "" if parameter_value == "NULL_NULL"
                param_combination_string[i] << "&parameterType#{i}:0=#{parameter_type}&parameterValue#{i}:0=#{parameter_value}"
            end
            param_combination_string[i] << "&parameterName#{i}:0=#{parameter_name}"
            param_combination_string[i] << "&attributeName#{i}:0=notification&attributeValue#{i}:0=#{attr_notification}" if attr_notification
        end
        return nil if param_combination_string.empty?
        param_combination_string << "&parameterCount:0=#{parameters.length}"
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
        logger.debug "Creating parameters string"
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
        begin
            @browser.get("#{@locations.login}")
            if @browser.current_page.form('loginForm').nil?
                logger.info("Already logged in")
                return
            end
            @browser.current_page.form('loginForm').j_username = @motive_username
            @browser.current_page.form('loginForm').j_password = @motive_password
            @browser.submit(@browser.current_page.form('loginForm'), @browser.current_page.form('loginForm').buttons.first)
        rescue Exception => ex
            logger.error "Login failed :: #{ex}"
            raise "Login failed :: #{ex}"
        end
        logger.info("Login successful")
    end

    # Finds the device ID and stores it in the private instance var +@device_id+.
    # This must be called the first time for any new instantiated method
    # by your own routines. It's done automatically when changing the serial
    # number with change_device.
    # @raise Errors when it cannot find the device ID from the serial number provided
    # @see #change_device
    def find_devicex
        logger.debug "Finding device"
        begin
            if not @device_id.empty?
                    logger.info "User define :: device ID - #{@device_id}"
                    return @device_id 
                end
                
            @browser.get(@locations.find)
            @browser.current_page.form("selectSearchProfile").field("searchProfile").option_with(:text => /by Serial Number/).select
            @browser.current_page.form("selectSearchProfile").add_field!("serialNumber", @serial_number)
            @browser.submit(@browser.current_page.form("selectSearchProfile"), @browser.current_page.form("selectSearchProfile").buttons[0])
            unique_device = true
            @browser.current_page.parser.xpath("//table[@id='data_table']//td/a").each do |dev|
                if dev.text.include?(@serial_number)
                    if unique_device
                        @device_id = dev.parent.parent.at_xpath("//button[@id='disableDevice']").attribute('onclick').value.slice(/'.*(?=')/).delete('^[0-9]')
                        unique_device = false
                    else
                        raise "More than one device found with serial number #{@serial_number}"
                    end
                end
            end
            if @device_id.empty?
                raise "No device found with serial number #{@serial_number}"
            end
        rescue Exception => ex
            logger.fatal "Find device failed :: #{ex}"
            raise "Find device failed :: #{ex}"
        end
        logger.info "Found device :: device ID - #{@device_id}"
        return @device_id
    end
    
    
    ## modified by Rayofox 2013/05/27 , new Motive Server HDM 4.0
    def find_device
        logger.debug "Finding device"
        begin
            if not @device_id.empty?
                return @device_id
            end

            ## Find Device
            @browser.get(@locations.find)
            @browser.current_page.form("selectSearchProfile").field("searchProfile").option_with(:text => /Find All TR-069 Devices/).select
            #@browser.current_page.form("selectSearchProfile").add_field!("serialNumber", @serial_number)
            @browser.submit(@browser.current_page.form("selectSearchProfile"), @browser.current_page.form("selectSearchProfile").buttons[0])
            logger.info("=== to find device")
            unique_device = true
            @browser.get(@locations.find + '?sort=lastContactTime&asc=false')
            
            ## Find the max page number
            max_page = 1
            @browser.current_page.links_with(:href => /pageNumber/).each do |link|
                #logger.info("=== page_id = #{link.href}")
                page_id = link.href.delete('^[0-9]').to_i
                if page_id > max_page
                    max_page = page_id
                end
            end
            logger.info("=== max_page_id = #{max_page}")

            ## Enum each page to find device
            page_id = 0
            while page_id < max_page do
                page_id += 1
                logger.info("=== Find Device in page #{page_id}")
                @browser.get(@locations.find + '?pageNumber=#{page_id}')
                ##
                @browser.current_page.parser.xpath("//table[@id='data_table']//td/a").each do |dev|
                    if dev.text.include?(@serial_number)
                        #logger.info("=== #{dev}")
                        if unique_device
                            #logger.info("=== #{dev['href']}")
                            @device_id = dev['href'].slice(/deviceID=(\d*)/).delete('^[0-9]')

                            logger.info("=== find device_id = #{@device_id}")
                            #unique_device = false
                            break
                        else
                            raise "More than one device found with serial number #{@serial_number}"
                        end
                    end
                end
                if not @device_id.empty?
                    break
                    #raise "No device found with serial number #{@serial_number}"
                end


            end
    
            ## check the find result
            if @device_id.empty?
                raise "No device found with serial number #{@serial_number}"
            end
        rescue Exception => ex
            logger.fatal "Find device failed :: #{ex}"
            raise "Find device failed :: #{ex}"
        end
        logger.info "Found device :: device ID - #{@device_id}"
        return @device_id
    end


    # Locks or unlocks the device ID.
    # @example Lock
    #   set_device_lock "lock"
    # @example Unlock
    #   set_device_lock "unlock"
    def set_device_lock state
        logger.debug "Lock device"
        begin
            device_status = get_device_status("captured").match(/true/i) ? "Locked" : "Unlocked"
            logger.debug "Setting device lock to '#{state}'. Current state is '#{device_status.downcase}'."
            last_Captured_By = get_device_status("lastCapturedBy")
            logger.debug "The device is locked by '#{last_Captured_By}' at last. Current user is '#{@motive_username}'."
            if device_status.eql?("Locked")
                unless @motive_username.eql?(last_Captured_By)
                    raise "Device(#{@serial_number}) is locked by '#{last_Captured_By}'. Current user is '#{@motive_username}'."
                end
            end
            unless device_status.match(/^#{state}/i)
                @browser.get("#{@locations.lock}&deviceID=#{@device_id}&status=#{state}")
                device_status = get_device_status("captured").match(/true/i) ? "Locked" : "Unlocked"
            end
        rescue Exception => ex
            logger.fatal "Lock device failed :: #{ex}"
            raise "Lock device failed :: #{ex}"
        end
        logger.info "Device lock set to '#{device_status.downcase}'"
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
        max_polls = 20
        poll_counter = 1
        wait_time = 30
        max_cwmp_conn_req = 3
        cwmp_conn_req_counter = 1

        #while @browser.get("#{@locations.current_queue}&deviceID=#{@device_id}").body.match(/pending|running/i)
        begin
            while true
                pg = @browser.get("#{@locations.current_queue}&deviceID=#{@device_id}")
                logger.debug " queue page body :\n"+pg.body

                break if not pg.body.match(/pending|running/i) 

                # try do wget to DUT ,send connection request
                if  not pg.body.match(/running/i) 
                    if not @cwmp_conn_req.nil?
                        if (poll_counter -1) % 3 == 0
                            wait_time = 10
                            max_polls = 60
                            if max_cwmp_conn_req >= cwmp_conn_req_counter
                                logger.info "try exec command : #{@cwmp_conn_req}. count : #{cwmp_conn_req_counter}"
                                unless system "#{@cwmp_conn_req} "
                                    cwmp_conn_req_counter += 1
                                end
                            else
                                raise "Connection Request Failed!"
                            end
                        end
                    end
                end
                if poll_counter == max_polls
                    raise "Queue maximum wait time hit. Aborting."
                end
                if timeout && (Time.now.to_i > (start_wait_time+timeout))
                    raise "Queue timeout hit. Aborting wait cycle."
                else
                    logger.debug "Check queue timeout. count : #{poll_counter}"
                end
                sleep wait_time # Motive uses a poll interval of 60,000ms, we do not want to exceed that poll.
                poll_counter += 1 # Motive also uses a poll maximum of 30. We do not want to exceed the poll count either.
            end
        rescue Exception => ex
            logger.fatal "Wait for queue completion failed :: #{ex}"
            raise "Wait for queue completion failed :: #{ex}"
        end
        return true
    end

    # Checks the device history
    # @return [true,false] True when successful, otherwise false
    def success?
        @browser.get("#{@locations.queue_history}&deviceID=#{@device_id}")
        #        logger.debug "result page body: \n" + @browser.current_page.body
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

    # find parameter's the type of value
    def find_leaf_type node, node_path, index
        node.each do |x|
            if x.at_xpath("//parameters/parameter[parameterName='#{node_path[index]}']/parameterType//text()").to_s.strip.match(/object/i)
                subnode = x.xpath("//parameters/parameter[parameterName='#{node_path[index]}']")
                if index+1 < node_path.length
                    return find_leaf_type subnode, node_path, index+1
                else
                    logger.error "<#{node_path.join('.')}> is NOT a leaf node"
                    raise "ERROR :: <#{node_path.join('.')}> is NOT a leaf node"
                end
            else
                leaf_type = x.at_xpath("//parameters/parameter[parameterName='#{node_path[index]}']/parameterType//text()").to_s.strip
                if leaf_type.empty?
                    logger.error "<#{node_path.join('.')}> not found in data model"
                    raise "ERROR :: <#{node_path.join('.')}> not found in data model"
                else
                    logger.debug "#{node_path.join('.')} type -- #{x.at_xpath("//parameters/parameter[parameterName='#{node_path[index]}']/parameterType//text()").to_s.strip}"
                    type = x.at_xpath("//parameters/parameter[parameterName='#{node_path[index]}']/parameterType//text()").to_s.strip
                    return type
                end
            end
        end
    end
end
