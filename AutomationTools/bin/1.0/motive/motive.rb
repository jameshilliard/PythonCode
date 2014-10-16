=begin
Filename: motive.rb
Description: Classes related to automating the GUI operations on the 
			 Motive server
Author: "Hawking", modified by Kurt Liu
Date: 03/20/09
Pre-requisite: $debug is a global variable of class AutomationDebug
=end

require 'watir'
require 'timer'

# sleeps until the given boolean expression becomes true
def waitUntil
    until yield
        sleep 0.5
    end
end

class Login
    def initialize(ie, username, password)
		waitUntil { ie.text_field(:id, 'j_username').exists? }
        ie.text_field(:id, 'j_username').set(username)
        ie.text_field(:id, 'j_password').set(password)
        ie.form(:name, 'loginForm').submit
        if ie.text.include? 'Logon Error'
			$debug.log('error', "Login to Motive server fails")
            raise "Login to Motive server failed"
        end
    end
end

class Lock
    def initialize(ie)
        @ie = ie
		if @ie.span(:id, 'deviceInfoLockedStatus').text == 'Unlocked'
			waitUntil { @ie.button(:id, 'lockDeviceButton').enabled? }
			@ie.button(:id, 'lockDeviceButton').click
            waitUntil { @ie.span(:id, 'deviceInfoLockedStatus').text == 'Locked' }
        end
        if  @ie.span(:class, 'user_name').text.chomp(' [ Log Off ]') != @ie.span(:id, 'deviceInfoLockedBy').text
            $debug.log('error', "Unable to lock device")
			raise "Unable to lock device"
        end
    end
    def release
        @ie.button(:id, 'lockDeviceButton').click
    end
end

class Parameter
    def initialize(ie)
        @ie = ie
		@path = ""
    end
    def at(path)
        @path = path
    end
    def to(path)
        @path += '.' + path
    end
    def get(name)
		$debug.log('info', "Getting parameter: #{@path}.#{name}")
		@ie.frame(:id, 'dialogFrame').text_field(:id, 'selectedParameterName').set(@path + '.' + name)
		@ie.frame(:id, 'dialogFrame').button(:id, 'addValue_span').click
    end
    def set(type, name, value)
		$debug.log('info', "Setting parameter: #{@path}.#{name}")
        waitUntil { @ie.frame(:id, 'dialogFrame').select_list(:id, 'selectedParameterType').exists? }
        @ie.frame(:id, 'dialogFrame').select_list(:id, 'selectedParameterType').set(type)
        @ie.frame(:id, 'dialogFrame').text_field(:id, 'selectedParameterName').set(@path + '.' + name)
        @ie.frame(:id, 'dialogFrame').text_field(:id, 'selectedParameterValue').set(value)
        @ie.frame(:id, 'dialogFrame').button(:id, 'addValue_span').click
    end
end

class VerifyParameter
    def initialize(ie)
        @ie = ie
        repeat = true

		timer = Timer.new
		timer.start
		# Expand the entire parameter tree
		while @ie.image(:src, $motive_url + "/images/tree_closed_button.gif").exist?
			@ie.image(:src, $motive_url + "/images/tree_closed_button.gif").click
		end
		$debug.log('debug', "Time spent to expand parameter tree: " + 
					timer.elapsedTime + " seconds")
    end
    def at(path)
# These codes assume there is at least 2 dot (".") in the path,
#   which is not always true
=begin
		p = path.rindex('.')
        component1 = path[p+1..-1]
        _path = path[0..p-1]
        p = _path.rindex('.')
        component0 = _path[p+1..-1]
        if @ie.span(:text, component1).exists?
            if @ie.span(:text, component0).exists?
                @ie.span(:after? => @ie.span(:text, component0), :text => component1).click
            else
                @ie.span(:text, component1).click
            end
        else
            puts "Parameter #{path} not found"
            exit
        end
=end
		# clicks on the correct parameter from the table
		# This line takes a very long time to execute... from 1 min to 2 min
		timer = Timer.new
		@ie.span(:xpath, "//td[contains(@id, '#{path}')]/table/tbody/tr/td/span").click
		$debug.log('debug', "Time spent to select the correct parameter for verification: " +
					timer.elapsedTime + " seconds")
        @path = path
    end
    def to(path)
        @ie.span(:text, path).click
        @path += '.' + path
    end
	def readParameterValue(name)
        specifier = @path + '.' + name
        $debug.log('info', 'Reading value of : ' + specifier)

		waitTimeOut = 30
		# Make sure if the parameter cannot be found, return an error
		while (! @ie.cell(:id, specifier).exists?) && waitTimeOut >= 0
			sleep 0.5
			waitTimeOut -= 0.5
			if waitTimeOut <= 0
				$debug.log('error', "Reading parameter value timed out! Parameter name may not exist!")
				raise
			end
		end
		# waitUntil { @ie.cell(:id, specifier).exists? }
		
		# This is necessary due to some values are too long to be displayed on Motive
		#  so a separate text area actually displays the full text
		if @ie.text_field(:id, 'pv_' + specifier).exists?
            value = @ie.text_field(:id, 'pv_' + specifier).text
        else
            value = @ie.cell(:id, specifier).text
        end
		return value
	end
    def verify(name, value)
        specifier = @path + '.' + name
        $debug.log('info', 'Verifying: ' + specifier)
		waitUntil { @ie.cell(:id, specifier).exists? }
		read = @ie.cell(:id, specifier).text
=begin
        waitUntil { @ie.text_field(:id, 'pv_' + specifier).exists? ||
                     @ie.cell(:id, specifier).exists? }
        if @ie.text_field(:id, 'pv_' + specifier).exists?
            read = @ie.text_field(:id, 'pv_' + specifier).text
        else
            read = @ie.cell(:id, specifier).text
        end
=end
        if read != value
			$debug.log('error', "Parameter verification failed! Expecting #{value}, found #{read}")
			return false
		else
			$debug.log('debug', "Parameter verification succeeded")
			return true
        end
    end
end

class Motive
  def initialize(url, username, password)
    #$HIDE_IE = true
    @url = url
    @ie = Watir::IE.start(url)
    @ie.speed = :fast
    $debug.log('info', 'Logging in to Motive server ...')
    Login.new(@ie, username, password)
    return Motive
  end

  def queueSubmit
    @ie.span(:id => 'done_span', :text => 'Queue').click
    @ie.frame(:id, 'dialogFrame').text_field(:id, 'expirationTimeOut').set('300')
    @ie.frame(:id, 'dialogFrame').button(:id, 'yes_span').click

    timer = Timer.new
    # If the history table is empty, i.e. only 1 row, wait until
    #	the table is populated with request history i.e. 2 or more rows
    $debug.log('debug', 'Inside queueSubmit')
    if @ie.table(:id, 'history_table').row_count < 2
      waitUntil { @ie.table(:id, 'history_table').row_count >= 2}
      $debug.log('debug', "Time spent to submit request is " + timer.elapsedTime + " seconds")

      return @ie.table(:id, 'history_table').row_values(2)
      #until @ie.table(:id, 'history_table').row_count >= 2
      #  sleep 0.5
      #end
    else
			# TODO: There is an error here somewhere that looks like:
			#		unknown property or method `1'
			#		HRESULT error code:0x80020006
			#		Unknown name.
			#		However, this error doesn't occur every time...
			result = previous = @ie.table(:id, 'history_table').row_values(2)
			# Wait until the row has been updated with the new results
			until result != previous
				sleep 1
				# TODO:
				# For some reason a rescue clause is required here, or else an exception is thrown
				begin 
					result = @ie.table(:id, 'history_table').row_values(2)
				rescue
				end
			end
			$debug.log('debug', "Time spent to submit request is " + timer.elapsedTime + " seconds")
			return result
		end
  end

  def selectDevice(serial)
    @ie.link(:href, @url+"/device/findDevices.do").click
    @ie.select_list(:id, 'searchProfile').set('Find Devices by Serial Number')
    $debug.log('info', "Locating device, serial: #{serial}")
    @ie.text_field(:id, 'parameter_serialNumber').set(serial)
    @ie.button(:id, 'findDevices_span').click

    if ! @ie.button(:id, 'disableDevice_span').exists?
      $debug.log('error', 'Unable to locate device')
      exit
    end

    $debug.log('info', 'Loading device data ...')
    @ie.button(:id, 'disableDevice_span').click
    @lock = Lock.new(@ie)
  end

  def upload(type, file)
    $debug.log('info', "Uploading #{file}")
    @ie.li(:id, 'queueFuctionContainer').fire_event('onclick')
    @ie.select_list(:id, 'actionCombo').set('Upload File')
    @ie.button(:id, 'queueButton_span').click
    @ie.select_list(:id, 'selectECL_Upload.FileType:0').set(type)
    @ie.text_field(:id, 'argument_Upload.Url:0').set('http://www.actiontec.com/motive/'+file)
    self.queueSubmit
  end

  def setFirmware(version, size)
    $debug.log('info', 'Setting firmware for upgrade ...')
    file = version + '.rmt'
    filename = 'BHR ' + version
    @firmware = filename
    @ie.link(:text, 'Firmware').click
    @ie.select_list(:id, 'searchDeviceTypeId').set('MI424WR-GEN2')
    @ie.button(:id, 'findFirmware_span').click
    if ! @ie.link(:text, filename).exists?
      $debug.log('info', 'Creating new firmware specification')
      @ie.button(:id, 'new_policy_span').click
      @ie.select_list(:id, 'firmwareDeviceTypeId').set('MI424WR-GEN2')
      @ie.text_field(:id, 'firmwareName').set(filename)
      @ie.text_field(:id, 'firmwareUrl').set('https://upgrade.actiontec.com/testverz/BHR2/' + file)
      @ie.text_field(:id, 'firmwareFileSize').set(size)
      @ie.text_field(:id, 'firmwareTargetFileName').set(file)
      @ie.button(:id, 'saveButton_span').click
    end
  end

  def upgradeFirmware(ver)
    #$debug.log('info', "Upgrading firmware to #{@firmware} ...")
    @ie.li(:id, 'queueFuctionContainer').fire_event('onclick')
    @ie.select_list(:id, 'actionCombo').set('Firmware Update')
    @ie.button(:id, 'queueButton_span').click
    sleep(3)
    @ie.select_list(:id, 'firmwareCombo:0').set(ver)
    self.queueSubmit
  end

  def getConfiguration
    $debug.log('info', 'Retrieving configuration ...')
    @ie.li(:text, 'Device Data').fire_event('onclick')
    if @ie.span(:text, 'DeviceConfig').exists?
      @ie.span(:text, 'DeviceConfig').click
    else
      $debug.log('debug', 'Configuration data not found')
      return
    end

    return @ie.cell(:id, 'InternetGatewayDevice.DeviceConfig.ConfigFile').text
  end

  def getParameterValues
    @ie.li(:id, 'queueFuctionContainer').fire_event('onclick')
    @ie.select_list(:id, 'actionCombo').set('Get Parameter Values')
    @ie.button(:id, 'queueButton_span').click
    parameter = Parameter.new(@ie)
  end

  def setParameterValues
    @ie.li(:id, 'queueFuctionContainer').fire_event('onclick')
    @ie.select_list(:id, 'actionCombo').set('Set Parameter Values')
    @ie.button(:id, 'queueButton_span').click
    parameter = Parameter.new(@ie)
  end

  def parameterSubmit
    $debug.log('debug', 'Submitting request to device ...')
    @ie.frame(:id, 'dialogFrame').button(:id, 'okButtton_span').click
    self.queueSubmit
  end

  def verifyParameterValues
    @ie.li(:text, 'Device Data').fire_event('onclick')
    parameter = VerifyParameter.new(@ie)
  end

  def verifyParameterRequestStatus(submit_result)
    # TODO:
    # Find a better way to do this
    sleep 4 # force waiting for Motive to update results table

    # Verify GetParameterValue query returned 'Success'
    if submit_result[3] != 'Success' 
      $debug.log('error', "Function status is " + submit_result[3] + "!")
			return false
		else
			return true
		end
	end

  def shutdown
    $debug.log('info', 'Shutting down connection ...')
    @lock.release
    @ie.span(:id => 'done_span', :text => 'Finished').click
    @ie.link(:text, 'Log Off').click
    @ie.close
  end
end