require 'watir'

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
            $stderr.print 'Login to Motive server fails'
            exit
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
            $stderr.print 'Unable to lock device'
            exit
        end
    end
    def release
        @ie.button(:id, 'lockDeviceButton').click
    end
end

class Parameter
    def initialize(ie)
        @ie = ie
        puts 'Retrieving parameters ...'
    end
    def at(path)
        @path = path
    end
    def to(path)
        @path += '.' + path
    end
    def get(name)
        puts "Getting: #{@path}.#{name}"
        @ie.frame(:id, 'dialogFrame').text_field(:id, 'selectedParameterName').set(@path + '.' + name)
        @ie.frame(:id, 'dialogFrame').button(:id, 'addValue_span').click
    end
    def set(type, name, value)
        puts "Setting: #{@path}.#{name}"
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
        puts 'Expanding the device data tree ...'
        repeat = true
        while repeat
            repeat = false
            @ie.images.each do | image |
                if image.src =~ /tree_closed_button/
                    image.click
                    repeat = true
                end
            end
        end
    end
    def at(path)
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
            $stderr.print "Parameter #{path} not found"
            exit
        end
        @path = path
    end
    def to(path)
        @ie.span(:text, path).click
        @path += '.' + path
    end
    def verify(name, value)
        specifier = @path + '.' + name
        puts 'Verifying: ' + specifier
        waitUntil { @ie.text_field(:id, 'pv_' + specifier).exists? ||
                     @ie.cell(:id, specifier).exists? }
        if @ie.text_field(:id, 'pv_' + specifier).exists?
            read = @ie.text_field(:id, 'pv_' + specifier).text
        else
            read = @ie.cell(:id, specifier).text
        end
        if read != value
            puts " expected #{value}"
            puts " actual #{read}"
        end
    end
end

class Motive
    def initialize(username, password)
        $HIDE_IE = true
        @ie = Watir::IE.start('http://xatechdm.xdev.motive.com/hdm')
        @ie.speed = :fast
        puts 'Logging in to Motive server ...'
        Login.new(@ie, username, password)
        return Motive
    end
    def queueSubmit
        @ie.span(:id => 'done_span', :text => 'Queue').click
        @ie.frame(:id, 'dialogFrame').text_field(:id, 'expirationTimeOut').set('300')
        @ie.frame(:id, 'dialogFrame').button(:id, 'yes_span').click
        result = previous = @ie.table(:id, 'history_table').row_values(2)
        until result != previous
            begin
                result = @ie.table(:id, 'history_table').row_values(2)
            rescue
            end
        end
        return result
    end
    def selectDevice(serial)
        @ie.link(:href, 'http://xatechdm.xdev.motive.com/hdm/device/findDevices.do').click
        @ie.select_list(:id, 'searchProfile').set('Find Devices by Serial Number')
        puts "Locating device, serial: #{serial} ..."
        @ie.text_field(:id, 'parameter_serialNumber').set(serial)
        @ie.button(:id, 'findDevices_span').click
        if ! @ie.button(:id, 'disableDevice_span').exists?
            $stderr.print 'Unable to locate device'
            exit
        end
        puts 'Loading device data ...'
        @ie.button(:id, 'disableDevice_span').click
        @lock = Lock.new(@ie)
    end
    def upload(type, file)
        puts "Uploading #{file} ..."
        @ie.li(:id, 'queueFuctionContainer').fire_event('onclick')
        @ie.select_list(:id, 'actionCombo').set('Upload File')
        @ie.button(:id, 'queueButton_span').click
        @ie.select_list(:id, 'selectECL_Upload.FileType:0').set(type)
        @ie.text_field(:id, 'argument_Upload.Url:0').set('http://www.actiontec.com/motive/'+file)
        self.queueSubmit
    end
    def setFirmware(version, size)
        puts 'Setting firmware for upgrade ...'
        file = version + '.rmt'
        filename = 'BHR ' + version
        @firmware = filename
        @ie.link(:text, 'Firmware').click
        @ie.select_list(:id, 'searchDeviceTypeId').set('MI424WR-GEN2')
        @ie.button(:id, 'findFirmware_span').click
        if ! @ie.link(:text, filename).exists?
            puts 'Creating new firmware specification ...'
            @ie.button(:id, 'new_policy_span').click
            @ie.select_list(:id, 'firmwareDeviceTypeId').set('MI424WR-GEN2')
            @ie.text_field(:id, 'firmwareName').set(filename)
            @ie.text_field(:id, 'firmwareUrl').set('https://upgrade.actiontec.com/testverz/BHR2/' + file)
            @ie.text_field(:id, 'firmwareFileSize').set(size)
            @ie.text_field(:id, 'firmwareTargetFileName').set(file)
            @ie.button(:id, 'saveButton_span').click
        end
    end
    def upgradeFirmware
        puts "Upgrading firmware to #{@firmware} ..."
        @ie.li(:id, 'queueFuctionContainer').fire_event('onclick')
        @ie.select_list(:id, 'actionCombo').set('Firmware Update')
        @ie.button(:id, 'queueButton_span').click
        @ie.select_list(:id, 'firmwareCombo:0').set(@firmware)
        self.queueSubmit
    end
    def getConfiguration
        puts 'Retrieving configuration ...'
        @ie.li(:text, 'Device Data').fire_event('onclick')
        if @ie.span(:text, 'DeviceConfig').exists?
            @ie.span(:text, 'DeviceConfig').click
        else
            $stderr.print "Configuration data not found"
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
        puts 'Submitting request to device ...'
        @ie.frame(:id, 'dialogFrame').button(:id, 'okButtton_span').click
        self.queueSubmit
    end
    def verifyParameterValues
        @ie.li(:text, 'Device Data').fire_event('onclick')
        parameter = VerifyParameter.new(@ie)
    end
    def shutdown
        puts 'Shutting down connection ...'
        @lock.release
        @ie.span(:id => 'done_span', :text => 'Finished').click
        @ie.link(:text, 'Log Off').click
        @ie.close
    end
end
