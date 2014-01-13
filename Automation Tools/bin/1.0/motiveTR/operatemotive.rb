#--------------------------------------------------------------------------------------
#	File: mainmotive.rb
#	Name: shqa
#	Contact: shqa@actiontec.com
#
#
#
#	Copyright @ Actiontec Ltd.
#--------------------------------------------------------------------------------------
require 'rubygems'
require 'selenium/client'
require 'net/telnet'
$dir=File.dirname(__FILE__) + "/"

module OperateMotive

    def __initSelenium(hostAddr, classBrows) 
	@selenium = Selenium::Client::Driver.new \
	    :host => hostAddr,
	    :port => 4444,
	    :browser => classBrows,
	    :url => "https://xatechdm.xdev.motive.com/hdm/",
	    :timeout_in_second => 60
	    @selenium.start_new_browser_session
	    @selenium.window_maximize()
    end

    def __destroyBrowser
	 @selenium.close_current_browser_session
 	 #@selenium.close()
 	 @selenium.stop()
    end

    def __loginMotive(user, passwd)
	@selenium.open "login;jsessionid=kLhJLCcTTp1pR3yFqRsvyRwJtHx9S43lypDnhQqFZvD0nbhrKQ74!-791847717"
	@selenium.wait_for_page_to_load "30000" 
    
	@selenium.type "id=j_username", user if @selenium.is_element_present("id=j_username")
	@selenium.type "id=j_password", passwd if @selenium.is_element_present("id=j_password")
	if @selenium.is_element_present("class=hdm-button")
	    @selenium.click "class=hdm-button";
	    @selenium.wait_for_page_to_load "30000"
	end
	
    end

    def __logoutMotive
	@selenium.click("id=logoutLink")
    end

    def __delDevice(devname)
	avail_butt_disable = false
	while avail_butt_disable == false
		@selenium.click('dom=document.forms.objectListForm.objectItem')
		@log.msg(:info, "Check on device - #{devname}")

		if @selenium.is_element_present("xpath=/html/body/table/tbody/tr[4]/td/table/tbody/tr[2]/td[2]/div/div[3]/table/tbody/tr/td/button[4]/ul/li/span[@class='button']")
			avail_butt_disable = true
		else
			@log.msg(:info, "Disable button is grey....")
			@selenium.uncheck('dom=document.forms.objectListForm.objectItem')
			@log.msg(:info, "Uncheck on device - #{devname}")
			sleep 3	
		end
	end

	begin
		@selenium.click('dom=document.getElementById("delete_device_span")')
	rescue
		@log.msg(:error, "Disable button is grey....")
		return false
	end

	@log.msg(:info, "Click on Disable button....")

	if @selenium.is_text_present("Are you sure you want to delete the selected device?")
		@selenium.select_frame("index=1")
		begin
			@selenium.click("xpath=/html/body/table/tbody/tr[3]/td/button[2]/ul/li/span")
			@log.msg(:info, "Click on OK button to confirm....")
		rescue
			@log.msg(:error, "Fail to click on OK button....")
			return false
		end
	end

	@selenium.select_frame("relative=top")
	return true	
    end

    def __findDevice(devname)
	# go to Devices tab
	if @selenium.is_element_present("link=Devices")
		@selenium.click "link=Devices"
		@selenium.wait_for_page_to_load "10000"
	else
		@selenium.refresh
		@selenium.wait_for_page_to_load(30000)
		if @selenium.is_element_present("link=Devices")
			@selenium.click "link=Devices"
			@selenium.wait_for_page_to_load "10000"
		else
			@log.msg(:error, "Cannot go to tab - Devices....")
		end
	end

	# select find devices by serial numbers
	if @selenium.is_element_present("id=searchProfile")
		@selenium.select "id=searchProfile", "value=47"
		@selenium.is_something_selected("id=searchProfile")
	else
		@selenium.refresh
		@selenium.wait_for_page_to_load(30000)
		if @selenium.is_element_present("id=searchProfile")
			@selenium.select "id=searchProfile", "value=47"
			@selenium.is_something_selected("id=searchProfile")
		else
			@log.msg(:error, "Cannot find search drop list....")
		end
	end

	# import device serial number
	if @selenium.is_element_present("id=parameter_serialNumber")
		@selenium.type "id=parameter_serialNumber", devname
		@selenium.click "id=findDevices"
		@selenium.wait_for_page_to_load "10000"
	end

	# verify if can find this device
	if @selenium.is_element_present("link=#{devname}")
		return true
	else 
		return false
	end

    end

    def __manageDevice
	@log.msg(:info,"Click on button Manage....")
	if @selenium.is_element_present("id=disableDevice")
		@selenium.click "id=disableDevice" 
		@selenium.wait_for_page_to_load "3000"
		__lockDevice
		if __logDevice == false
			return false
		end
                return true
	end
	return false
    end

    def __logDevice
        # in order to click 'enable log' icon
	wait_count = 0
	while wait_count < 6
		if @selenium.is_element_present("xpath=/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/button[7]/img[@title='Enable communication logging for this device']")
			@selenium.click('dom=document.getElementById("enableDeviceLoggingButtonIcon")')
			@log.msg(:info, "Enable communication logging for this device....")
			count = 0
			while count < 6
				# ok button in pop-up window
				if @selenium.is_element_present('dom=document.getElementById("dialogFrame").contentWindow.document.getElementById("okButton_span")')
					count = 100
				else
					count += 1
					sleep 10
				end
			end
			if count == 6
				@log.msg(:error, "No confirm pop up window....")
				return false
			else
				@selenium.select_frame("index=2")
				@selenium.click("xpath=/html/body/table/tbody/tr[3]/td/button[2]/ul/li/span")
				@log.msg(:info, "Click button OK to confirm this operation....")
				@selenium.select_frame("relative=top")
				return true
			end
		elsif @selenium.is_element_present("xpath=/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/button[7]/img[@title='Disable communication logging for this device']")
			@log.msg(:info, "Already enabled communication logging for this device....")
			return true
		else
			wait_count += 1
			@log.msg(:info, "Hold 10 Secs to load page....")
			sleep 10
		end
	end
	if wait_count == 6
		@log.msg(:info, "Does not acquire fully Html code, Refresh the page....")
		@selenium.refresh
		@selenium.wait_for_page_to_load(30000)
		__logDevice
		return true
	end
    end

    def __activeDevice
	if @selenium.is_element_present("xpath=/html/body/table/tbody/tr[4]/td/table/tbody/tr[2]/td[2]/div/div[2]/table/tbody/tr[2]/td[8]/img[@alt='Activated']")
		@log.msg(:info, "Device is in Actived status....")
	else
		@log.msg(:info, "Device is in Deactived status, need to active it....")
		__doactDev
	end
    end

    def __doactDev
	@selenium.click('dom=document.getElementById("data_table").childNodes.item(0).childNodes.item(1).childNodes.item(2).childNodes.item(0)')
	@log.msg(:info, "Go into Edit Device page....")
	@selenium.wait_for_page_to_load(30000)
	@selenium.select "id=activated", "value=true"
	@log.msg(:info, "Select Yes in Activated drop list....")
	@selenium.click('dom=document.getElementById("saveButton_span")')
	@log.msg(:info, "Click on Update button....")
	@selenium.wait_for_page_to_load(30000)
    end

    def __lockDevice
        # lock status
        device_status = @selenium.get_text("deviceInfoLockedStatus")
        @log.msg(:info, "Lock icon status - #{device_status}")
        # Lock or Unlock toggle
	if device_status.match(/unlock/i)
		@log.msg(:info, "Click on lock icon....")
		@selenium.click "deviceInfoLockedImage"
		while device_status.match(/unlock/i)
			device_status = @selenium.get_text("deviceInfoLockedStatus")
			sleep 5
		end
		@log.msg(:info, "Lock icon status is changed - #{device_status}")
	else
		@log.msg(:info, "Leave it on locked state....")	
	end
    end

    def __gpv_root(gpv_value)
	gpv_timeout_value = 900
	# Acquire End time on the first line of Device History Frame
	flag_table = false
	while flag_table == false
		begin
			if @selenium.is_element_present('dom=document.getElementById("history_table").childNodes.item(0).childNodes.item(0).childNodes.item(0)') 
				flag_table = true
			else
				@log.msg(:info, "Wait for a while, the table does not exist....")
				sleep 2
			end
		rescue
			@log.msg(:info, "Wait for a while, no contents in table....")
			sleep 2
		end
	end


	if @selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/div/table/tbody/tr").to_i > 1
		toptime = @selenium.get_table("history_table.1.0")
	else
		toptime = nil
	end
	@log.msg(:info, "The latest value End Time - #{toptime}")

	num_lines = @selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div[1]/table/tbody/tr[1]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td/div[2]/div[1]/table/tbody/tr/td/div/table[@id='action_history']/tbody/tr").to_i - 1
	if num_lines != 0
		@log.msg(:info, "Oh! NO~~~~ There is(are) #{num_lines} line(s) in the queue, wait for a while")
		while num_lines > 0
			__waitPushes(toptime)
			num_lines -= 1
			toptime = @selenium.get_table("history_table.1.0")
		end 
		@log.msg(:info, "The latest value End Time changed - #{toptime}")
	end

        @log.msg(:info,"Turn to tab - Queue Action")
        @selenium.click "id=queuePolicyActionContainer"
	begin
        	@selenium.select "id=functionCombo", "value=-1"
	rescue
		@log.msg(:error, "Drop list frame not avaiable.....")
		return false	
	end
	@log.msg(:info, "Select drop list - All Functions....")

	begin
		@selenium.select "id=policyActionCombo", "value=16310"
	rescue
		@log.msg(:error, "Drop list frame not avaiable.....")
		return false
	end

	@log.msg(:info, "Select drop list - !gpv_root")
	
	exist_popwin = false
	@selenium.click('dom=document.getElementById("queueActionButton_span")')
	@log.msg(:info, "Click button - Queue") 

	wait_count = 0
	while wait_count < 5
		if @selenium.is_element_present("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[1]/td[@id='dialogHeader']")
			# handle timeout value on confirm box
			element_count = 0
			while element_count < 5
				if @selenium.is_element_present("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input")
					preValue = @selenium.get_value("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input")
					@log.msg(:info, "check: #{preValue}")
					element_count = 100
				else
					element_count += 1
					sleep 2
				end
			end

			@selenium.type("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input", gpv_timeout_value)  
			@log.msg(:info,"Changing value of 'Expiration Timeout' - #{gpv_timeout_value}")
	
			# handle checkbox
			@selenium.uncheck("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[5]/input[@name='failOnCRFailure']")
			@log.msg(:info,"Remove 'Fail on Connection Request Failure'")

			wait_count = 100
			@selenium.click "xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[3]/td[1]/button[1]/ul[1]/li[1]/span"
			@log.msg(:info, "Click on button Queue on confirm dialog box....")
		else
			wait_count += 1
			if wait_count == 1
				sleep 2
			else
				@log.msg(:warn,"Queue function option pop-up window is not here....")
				sleep 5
			end
		end

		if wait_count == 5
			@log.msg(:error, "Bad network traffic while getting 'queue option' window - Get Parameter Values")
			return false
		end
	end

	
	@selenium.click "id=queuedActionsContainer" if !@selenium.is_element_present("id=queuedActionsXMLContainer")
	@log.msg(:info, "Turn to tab sleep 200 - Queue....")
        
        __waitPushes(toptime)

	# This shows the state after queueing an item
	statusOfGPV = @selenium.get_table("history_table.1.3")
	substatusOfGPV = @selenium.get_table("history_table.1.4")
	@log.msg(:info, "Get the status of GPV node '#{gpv_value}' : #{statusOfGPV}")
	@log.msg(:info, "Get the status of GPV node '#{gpv_value}' : #{substatusOfGPV}")
	
	if statusOfGPV.chomp == "Success"
	    return true
	else
	    return false
	end
    end

    def __waitPushes(pre_toptime) 
	is_bhr2 = nil	
        ip_bhr2 = ENV['G_PROD_IP_BR0_0_0']
	if ENV['G_BUILD'] =~ /MI424WR-GEN2/m
         	#is_bhr2 = 'true'
		
		if ip_bhr2 == nil
			ip_bhr2 = '192.168.1.1/24'
		end
		arr_ip_bhr2 = ip_bhr2.split('/')
		ip_bhr2 = arr_ip_bhr2[0]
	end
	sleep_count = 1	
	first_time = 'true'

	if pre_toptime == nil
		while @selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/div/table/tbody/tr").to_i == 1
			if is_bhr2 == 'true' and first_time == 'true'
				__bhr2_tel(ip_bhr2)
				first_time = 'false'
			end

			if is_bhr2 == 'true' and sleep_count == 17
				sleep_count = 1
				__bhr2_tel(ip_bhr2)
			end

			sleep 30
			@log.msg(:info, "GPV_ROOT/SPV operation not finish, wait 30 Sec. for loading....")
			sleep_count += 1
		end	
	else
		# Wait for motive pushes the information across
		while (pre_toptime == @selenium.get_table("history_table.1.0"))
			if is_bhr2 == 'true' and sleep_count == 17
				sleep_count = 1
				__bhr2_tel(ip_bhr2)
			end

			sleep 30
			@log.msg(:info, "GPV_ROOT/SPV operation not finish, wait 30 Seconds for loading....")
			sleep_count += 1
		end
	end
    end

    def __bhr2_tel(ip_bhr2)

	client = Net::Telnet::new("Host" => ip_bhr2,
	                        "Port" => '23',
	                        'Timeout' => 300
	) {|c| print c}
	@log.msg(:info, "check ip_bhr2: #{ip_bhr2}")
	client.waitfor({}) { |c| print c; break if c.include? "Username" }
        username = ENV['U_USER']
        log.msg(:info, "check username: #{username}")
	client.puts(username)
	client.waitfor({}) { |c| print c; break if c.include? "Password" }
        passwd = ENV['U_PWD']
        log.msg(:info, "check passwd: #{passwd}")	
	client.puts(passwd)
	
	client.waitfor({}) { |c| print c; break if c.include? "Wireless Broadband Router" }
	client.puts("conf set /cwmp/periodic_inform/interval 30")
	client.waitfor({}) { |c| print c; break if c.include? "Wireless Broadband Router" }
	client.puts("cwmp session_stop") { |c| print c }
	sleep 2
	client.waitfor({}) { |c| print c; break if c.include? "Wireless Broadband Router" }
	client.puts("cwmp session_start")
	
	client.waitfor({}) { |c| print c; break if c.include? "Wireless Broadband Router" }
	client.puts("exit") { |c| print c; }
	STDOUT.flush
	client.close
    end

    def __gpv(gpv_value, exp_value)
	gpv_timeout_value = 900
        @log.msg(:info,"Turn to tab - Queue Function")
        @selenium.click "id=queueFuctionContainer"
        @selenium.select "id=actionCombo", "value=4"
	disablebutton_count = 0
	while disablebutton_count < 5
		if @selenium.is_element_present("class=disabledButton")
			@log.msg(:warn, "Button Queue is in DISABLE status. It is Motive site issue, wait for page refreshing....")
			@selenium.refresh
			@selenium.wait_for_page_to_load(30000)
			sleep 5
			disablebutton_count += 1
			@log.msg(:info,"Turn to tab again - Queue Function")
			@selenium.click "id=queueFuctionContainer"
			@selenium.select "id=actionCombo", "value=4"
		else
			@selenium.click "id=queueButton_span"
			@log.msg(:info,"Start the queue....")
			disablebutton_count = 100
		end
		
		if disablebutton_count == 5
			@log.msg(:error, "Motive site has issue....")
			return false
		end
	end

	finish_load = true
	count = 0
	while finish_load == true
	   text_include = @selenium.get_text("baselineData_tree")
	   if text_include.match(/InternetGateway/i) or text_include.match(/"Loading data"/i)
		@log.msg(:info, "Pop window exists....")
		finish_load = false
	   else
		@log.msg(:info, "Waiting for the pop window....")
		text_include = nil
		finish_load = true
		sleep 3
		if count == 40
			@log.msg(:warn, "Bad network traffic while getting pop window - Get Parameter Values")
			return false
		end
		count += 1
	   end
	end
	
	# Enter GPV value
	@log.msg(:info, "Import selected GPV value")
	if @selenium.is_text_present("Selected Parameter")
		@log.msg(:info,"Queue the node - #{gpv_value}")
		@selenium.select_frame("index=2")
		@selenium.type "xpath=/html/body/table/tbody/tr[2]/td/table/tbody/tr[2]/td/fieldset/table/form/tbody/tr[1]/td[2]/input[@id='selectedParameterName']","#{gpv_value}"
		@log.msg(:info, "import gpv parameter - #{gpv_value}")
	else
		@log.msg(:error, "There is no 'Selected Parameter' blank....")
	end
	
	# Add the value from above to the list
	@log.msg(:info,"Add the value from above to the queue list....")
	@selenium.click "xpath=/html/body/table/tbody/tr[2]/td/table/tbody/tr[2]/td/fieldset/table/form/tbody/tr[2]/td/button/ul/li/span"
	
	# Save the queue
	@log.msg(:info, "Click on button Save....")
	@selenium.click "xpath=/html/body/table/tbody/tr[3]/td/button[1]/ul/li/span"
	    	
	# Start the Queue
	@selenium.select_frame("relative=top")
	if @selenium.is_text_present("Queue")
		@log.msg(:info,"Click on button - Queue....")
		@selenium.click "id=queueActionButton_span"
	else
		@log.msg(:warn,"No button - Queue....")
	end

	wait_count = 0
	while wait_count < 5
		if @selenium.is_element_present("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[1]/td[@id='dialogHeader']")
			# handle timeout value on confirm box
			element_count = 0
			while element_count < 5
				if @selenium.is_element_present("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input")
					preValue = @selenium.get_value("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input")
					@log.msg(:info, "check: #{preValue}")
					element_count = 100
				else
					element_count += 1
					sleep 2
				end
			end

			@selenium.type("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input", gpv_timeout_value)  
			@log.msg(:info,"Changing value of 'Expiration Timeout' - #{gpv_timeout_value}")
	
			# handle checkbox
			@selenium.uncheck("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[5]/input[@name='failOnCRFailure']")
			@log.msg(:info,"Remove 'Fail on Connection Request Failure'")

			wait_count = 100
			@selenium.click "xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[3]/td[1]/button[1]/ul[1]/li[1]/span"
			@log.msg(:info, "Click on button Queue on confirm dialog box....")
		else
			wait_count += 1
			if wait_count == 1
				sleep 2
			else
				@log.msg(:warn,"Queue function option pop-up window is not here....")
				sleep 5
			end
		end

		if wait_count == 5
			@log.msg(:error, "Bad network traffic while getting 'queue option' window - Get Parameter Values")
			return false
		end
	end

	@selenium.click "id=queuedActionsContainer" if !@selenium.is_element_present("id=queuedActionsXMLContainer")
	@log.msg(:info, "Turn to tab - Queue....")

	while (@selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div[1]/table/tbody/tr[1]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td/div[2]/div[1]/table/tbody/tr/td/div/table[@id='action_history']/tbody/tr").to_i == 1)
		# wait till the table inform shows
		sleep 5
	end
	
	sleep 60
	# Wait for motive pushes the information across
	while (@selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div[1]/table/tbody/tr[1]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td/div[2]/div[1]/table/tbody/tr/td/div/table[@id='action_history']/tbody/tr").to_i > 1)

		num_lines = @selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div[1]/table/tbody/tr[1]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td/div[2]/div[1]/table/tbody/tr/td/div/table[@id='action_history']/tbody/tr").to_i - 1
		if num_lines != 0
			@log.msg(:info, "There are still #{num_lines} line(s) in the queue")
			@log.msg(:info, "The queue status is : #{@selenium.get_table("action_history.1.4")}, wait 15 sec for loading ...")
			sleep 15
		end
	end 
		
	# This shows the state after queueing an item
	statusOfGPV = @selenium.get_table("history_table.1.3")
	substatusOfGPV = @selenium.get_table("history_table.1.4")
	@log.msg(:info, "Get the status of GPV node '#{gpv_value}' : #{statusOfGPV}")
	@log.msg(:info, "Get the status of GPV node '#{gpv_value}' : #{substatusOfGPV}")
	
	if statusOfGPV.chomp == "Success"
	    return true
	else
	    return false
	end
    end

    def __parseGpv(gpv_value)
	subArr = gpv_value.split(/\./)
	dotCount = gpv_value.count '.'
	lenArr = subArr.length
	maxIndex = lenArr - 1	
	itera = 1

	if lenArr == dotCount + 1
		# that means to acquire parent node infomation A.B.C.D
		if maxIndex > 0
			subArr[0] = subArr[0] + "."
			while itera < maxIndex
				subArr[itera] = subArr[itera - 1] + subArr[itera] + "."
				itera += 1	
			end
			subArr[itera] = subArr[itera - 1] + subArr[itera] 
		end
		return subArr
	else
		# like node - A.B.C.D.
		@log.msg(:warn, "You are going to click '+' on parent node #{subArr[maxIndex]}")
		return false
	end

	return false
    end

    def __outputData(gpv_value)
	require $dir + 'ref_dev'
	@selenium.click "id=deviceDataTab" if @selenium.is_element_present("id=deviceDataTab")
	@log.msg(:info, "Turn to tab - Device Data....")

	# loading data
	finish_load = true
	count = 0
	while finish_load == true
	   text_include = @selenium.get_text("baselineData_tree")
	   if text_include.match(/InternetGateway/i)
		@log.msg(:info, "Finish Load....")
		finish_load = false
	   else
		@log.msg(:info, text_include)
		text_include = nil
		finish_load = true
		sleep 30
		if count == 5
			@log.msg(:warn, "Bad network traffic while getting pop window - Get Parameter Values")
			return false
		end
		count += 1
	   end
	end

	if __allParameter == false
		return false
	end

	# click treepane
	ret = __parseGpv(gpv_value)
	if ret == false
		@log.msg(:warn, "Please check you gpv parameter inputs. Please follow this kind of format - A.B.C")
		return false
	# no need to click root node
	else
		sizeArr = ret.length
		if sizeArr != 1
			i = 1
			while i < sizeArr
				@log.msg(:info, "Click node - #{ret[i]}")
				@selenium.click($data_locator[ret[i]])
				i += 1
			end
		end
	end

	# output the data
	count_lines = @selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/tr/td/table/tbody/tr[3]/td/div[2]/div[2]/table/tbody/tr[2]/td[2]/div/table/tbody/tr").to_i
	row_lines = 0
	col_lines = 0
	line_data = ''
	while row_lines < count_lines
		while col_lines < 5
			unit_data = @selenium.get_table("xpath=/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/tr/td/table/tbody/tr[3]/td/div[2]/div[2]/table/tbody/tr[2]/td[2]/div/table.#{row_lines}.#{col_lines}")
			line_data += " |" + unit_data + "| "
			col_lines += 1
		end
		@log.msg(:info, line_data)
		if row_lines > 0
			locator_head = 'dom=document.getElementById("baselineParameter_Value").childNodes.item(0).childNodes.item(0).childNodes.item('
			locator_mid = row_lines.to_s
			locator_end = ').childNodes.item(0)'
			locator = locator_head + locator_mid + locator_end 
			@selenium.click(locator)
			if @selenium.is_alert_present()
				@selenium.get_alert()
				@log.msg(:warn, "#{line_data} NOT FOUND IN DATA MODEL")
			end	
		end
		row_lines += 1
		col_lines = 0
		line_data = ''
	end

    end

    def __allParameter
	# choice show all parameters
	@selenium.select "id=filterParameterSelect", "value=all"
	@log.msg(:info, "Select Show All Parameters and wait page reload....")

	# collapse root tree
	@selenium.click('document.getElementById("1:InternetGatewayDevice").childNodes.item(0).childNodes.item(0).childNodes.item(0).childNodes.item(0).childNodes.item(0)')
	sleep 1
	count = 0
	while count < 6
		if @selenium.is_element_present("xpath=/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/tr/td/table/tbody/tr[3]/td/div[2]/div[2]/table/tbody/tr[2]/td/div/table/tbody/tr[2]/td/div/div/table/tbody/tr[2]/td[2]/table/tbody/tr/td/img[@src='https://xatechdm.xdev.motive.com/hdm/images/tree_open_button.gif']")
			@log.msg(:info, "Refresh done....")
			count = 100
		else
			@log.msg(:info, "Wait 15 sec for Refresh....")
			sleep 15
			count += 1
		end
	end

	if count == 6
		@log.msg(:error, "No response from motive after #{count*10} seconds or you don't have done GPV-ROOT yet....")
		return false
	end

	return true
    end

    def __spv(spv_parameter, value_parameter, type_parameter, expvalue_parameter, spv_timeout_value = 900)
	# Acquire End time on the first line of Device History Frame
	flag_table = false
	while flag_table == false
		begin
			if @selenium.is_element_present('dom=document.getElementById("history_table").childNodes.item(0).childNodes.item(0).childNodes.item(0)') 
				flag_table = true
			else
				@log.msg(:info, "Wait for a while, the table does not exist....")
				sleep 2
			end
		rescue
			@log.msg(:info, "Wait for a while, no contents in table....")
			sleep 2
		end
	end

	if @selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/div/table/tbody/tr").to_i > 1
		toptime = @selenium.get_table("history_table.1.0")
	else
		toptime = nil
	end
	@log.msg(:info, "The latest value End Time - #{toptime}")

	num_lines = @selenium.get_xpath_count("/html/body/table/tbody/tr[4]/td/table/tbody/tr/td/div/table/tbody/form/tr/td/div[1]/table/tbody/tr[1]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td/div[2]/div[1]/table/tbody/tr/td/div/table[@id='action_history']/tbody/tr").to_i - 1
	if num_lines != 0
		@log.msg(:info, "Oh! NO~~~~ There is(are) #{num_lines} line(s) in the queue, wait for a while")
		while num_lines > 0
			__waitPushes(toptime)
			num_lines -= 1
			toptime = @selenium.get_table("history_table.1.0")
		end
		@log.msg(:info, "The latest value End Time changed - #{toptime}")
	end

	@log.msg(:info,"Turn to tab - Queue Function")
        @selenium.click "id=queueFuctionContainer"
        @selenium.select "id=actionCombo", "value=5"
	disablebutton_count = 0
	while disablebutton_count < 5
		if @selenium.is_element_present("class=disabledButton")
			@log.msg(:warn, "Button Queue is in DISABLE status. It is Motive site issue, wait for page refreshing....")
			@selenium.refresh
			@selenium.wait_for_page_to_load(30000)
			sleep 5
			disablebutton_count += 1
			@log.msg(:info,"Turn to tab again - Queue Function")
			@selenium.click "id=queueFuctionContainer"
			@selenium.select "id=actionCombo", "value=5"
		else
			@selenium.click "id=queueButton_span"
			@log.msg(:info,"Start the queue....")
			disablebutton_count = 100
		end
		
		if disablebutton_count == 5
			@log.msg(:error, "Motive site has issue....")
			return false
		end
	end

	finish_load = true
	count = 0
	while finish_load == true
	   text_include = @selenium.get_text("baselineData_tree")
	   if text_include.match(/InternetGateway/i) or text_include.match(/"Loading data"/i)
		@log.msg(:info, "Pop window exists....")
		finish_load = false
	   else
		@log.msg(:info, "Waiting for the pop window....")
		text_include = nil
		finish_load = true
		sleep 3
		if count == 40
			@log.msg(:warn, "Bad network traffic while getting pop window - Get Parameter Values")
			return false
		end
		count += 1
	   end
	end

	# Enter SPV value
	@log.msg(:info, "SPV options in testing: #{spv_parameter}, #{value_parameter}, #{type_parameter}, #{expvalue_parameter}")
	if @selenium.is_text_present("Selected Parameter")
		while @selenium.is_element_present('dom=document.getElementById("dialogFrame").contentWindow.document.forms.newValueForm.selectedParameterName') == false
			@log.msg(:info, "Hold for a while....")
			sleep 2
		end

		@selenium.type 'dom=document.getElementById("dialogFrame").contentWindow.document.forms.newValueForm.selectedParameterName', "#{spv_parameter}"
		@log.msg(:info, "Import Parameter - #{spv_parameter}....")
		@selenium.type 'dom=document.getElementById("dialogFrame").contentWindow.document.forms.newValueForm.selectedParameterValue', "#{value_parameter}"
		@log.msg(:info, "Import Parameter value - #{value_parameter}....")
		select_drop = nil
		case type_parameter
			when 'string'
				select_drop = "value=string"
			when 'int'
				select_drop = "value=int"	
			when 'unsignedInt'
				select_drop = "value=unsignedInt"
			when 'dateTime'
				select_drop = "value=dateTime"
			when 'boolean'
				select_drop = "value=boolean"
			when 'base64'
				select_drop = "value=base64"
		else
			@log.msg(:error, "There is no this type #{type_parameter}....\n\t\t Only support string,int,unsignedInt,dateTime,boolean,base64")
			return false
		end
		@selenium.select 'dom=document.getElementById("dialogFrame").contentWindow.document.forms.newValueForm.selectedParameterType', select_drop
		@log.msg(:info, "Select Parameter type - #{type_parameter}....")	
	else
		@log.msg(:error, "There is no 'Selected Parameter' blank....")
	end

	# Add button
	@log.msg(:info, "Click on button Add....")
	@selenium.click 'dom=document.getElementById("dialogFrame").contentWindow.document.getElementById("addValue_span")'

	# Save button
	@log.msg(:info, "Click on button Save....")
	@selenium.click 'dom=document.getElementById("dialogFrame").contentWindow.document.getElementById("okButtton_span")'

	# Start the Queue
	@log.msg(:info, "Click on button - Queue....")
	@selenium.click 'dom=document.all.item("done_span",1)'

	wait_count = 0
	while wait_count < 5
		if @selenium.is_element_present("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[1]/td[@id='dialogHeader']")
			# handle timeout value on confirm box
			element_count = 0
			while element_count < 5
				if @selenium.is_element_present("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input")
					preValue = @selenium.get_value("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input")
					@log.msg(:info, "check: #{preValue}")
					element_count = 100
				else
					element_count += 1
					sleep 2
				end
			end

			@selenium.type("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[4]/input", spv_timeout_value)  
			@log.msg(:info,"Changing value of 'Expiration Timeout' - #{spv_timeout_value}")
	
			# handle checkbox
			@selenium.uncheck("xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[2]/td[2]/div[5]/input[@name='failOnCRFailure']")
			@log.msg(:info,"Remove 'Fail on Connection Request Failure'")

			wait_count = 100
			@selenium.click "xpath=/html/body/table[@id='dialogTable']/tbody[1]/tr[3]/td[1]/button[1]/ul[1]/li[1]/span"
			@log.msg(:info, "Click on button Queue on confirm dialog box....")
		else
			wait_count += 1
			if wait_count == 1
				sleep 2
			else
				@log.msg(:warn,"Queue function option pop-up window is not here....")
				sleep 5
			end
		end

		if wait_count == 5
			@log.msg(:error, "Bad network traffic while getting 'queue option' window - Get Parameter Values")
			return false
		end
	end

	@selenium.click "id=queuedActionsContainer" if !@selenium.is_element_present("id=queuedActionsXMLContainer")
	@log.msg(:info, "Turn to tab - Queue....")

	__waitPushes(toptime)

	# This shows the state after queueing an item
	statusOfSPV = @selenium.get_table("history_table.1.3")
	substatusOfSPV = @selenium.get_table("history_table.1.4")
	@log.msg(:info, "The status of operation SPV node '#{spv_parameter}' : #{statusOfSPV}")
	@log.msg(:info, "The status of operation SPV node '#{spv_parameter}' : #{substatusOfSPV}")
	
	if statusOfSPV.chomp == "Success"
	    return true
	else
	    return false
	end
    end

end
