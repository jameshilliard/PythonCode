# These are the options to jump to various parts of the BHR2. Basically the menu at the top.
# It also takes care of the "Are you sure?" pages so it doesn't have to be added separately to every
# new method that comes into existence. 

# This is further being changed to include the ability to select the side menu options. 
# Format for this will be topPageName(rule_name, section) - 
# In example: firewallPage(rule_name, 'Access Control') will bring it to Access Control under Firewall. 
# In addition, each page will check to make sure we are logged in by determining the page text. If we get
# logged out, hook back to the login function and then jump to the requested page. 

module TopMenu
    # Login page, and make sure we are on main page.

	def login(rule_name, info)
        if @dutinfo == nil
            info['address'] = IPCommon::ip_by_interface(info['address']) if info['address'].match(/eth/i)
            @dutinfo = IP.new(info['address']) if info.has_key?('address')
        end
        unless @dutinfo.is_valid?
            self.msg(rule_name, :error, "Login", "Missing IP address to log into from config or command line. Aborting.")
            return FALSE
        end

        @lanip = @dutinfo.ip
        unless info.is_a?(String)
            info.has_key?("username") ? @user = info['username'] : @user = 'admin'
            info.has_key?("password") ? @pass = info['password'] : @user = 'admin1'
        end

        begin
            @ff.goto(@dutinfo.url)
			if @ff.text.include?('Failed to Connect')
				# Check if the device was restored to defaults by going to http://192.168.1.1:80
				@ff.goto('http://192.168.1.1:80')
				# Error out if we can't get to a web site
				if @ff.text.include?('Failed to Connect')
					self.msg(rule_name, :error, 'Login', "Firefox failed to connect to #{@dutinfo.url} ; Check the configuration or the DUT.")
					@logged_in = FALSE
					exit
				# If we get to a website, and we can setup the device, do so
				elsif @ff.text.include?('Login Setup')
					self.login_setup
					# Override old values to match the defaults
					@dutinfo.url = 'http://192.168.1.1:80'
					@lanip = '192.168.1.1'
                elsif @ff.contains_text("Login")
                    self.msg(rule_name, :info, "Login", "Looks like the DUT was reset to default. Found a valid login page at 192.168.1.1")
                    @ff.text_field(:name, 'user_name').set(@user)
                    @ff.text_field(:name, 'passwd1').set(@pass) if @ff.text_field(:name, 'passwd1').exists?
                    @ff.link(:text, 'OK').click
				# If we get to any other page, let's not do anything. The user will have to correct it
				else
					self.msg(rule_name, :error, 'Login', "Found a page, but unsure if it's the correct one. Please check the configuration again.")
					@logged_in = FALSE
					exit
				end
			elsif @ff.text.include?('Login Setup')
                self.msg(rule_name, :debug, "Login", "Hit login setup page - Sending to login setup function.")
				self.login_setup
            elsif @ff.text_field(:name, "user_name").exists?
                @ff.text_field(:name, 'user_name').set(@user)
                @ff.text_field(:name, 'passwd1').set(@pass) if @ff.text_field(:name, 'passwd1').exists?
                @ff.link(:text, 'OK').click
                if @ff.contains_text("Router Status")
                    self.msg(rule_name, :info, "Login", "Successfully logged in.")
                    @logged_in = TRUE
                elsif @ff.contains_text("Login failed, please try again")
                    raise "Login failed. Check the supplied user name and password."
                end
			end
        rescue => ex
            self.msg(rule_name, :error, 'Login', 'Did not successfully login and get main page.')
            self.msg(rule_name, :fatal, "Login", ex.msg)
			@logged_in = FALSE
            exit
        end
        if @ff.contains_text("Router Status")
            unless @logged_in
                self.msg(rule_name, :info, "Login", "Session was stored, already logged in.")
                @logged_in = TRUE
            end
            # Populate @dut_information
            self.msg(rule_name, :info, "Login", "Grabbing DUT information.")
            self.get_system_info("Initial System Information Gather")
            return true
        end
	end
    
	# Method for new login information, if we just restored defaults or connected a new router
	def login_setup
        zone_select = "Other"

        # Another work around due to buggy BHR2 GUI... the time zone option resets the user/password fields because it does a refresh. Do timezone first.
        offset = Time.now.gmt_offset / 3600
        offset -= 1 if Time.now.zone.match(/MDT|PDT|EDT|CDT|AKDT|NDT|ADT|HADT/)
        zone = sprintf("%+05d", offset*100).insert(3,':')
		@ff.select_list(:id, 'time_zone').getAllContents.each { |v| zone_select = v if v.include?(zone) }
		@ff.select_list(:id, 'time_zone').select(zone_select) if @ff.select_list(:id, 'time_zone').exists?
        if zone_select == "Other"
            offset = (Time.now.gmt_offset / 60).to_s
            @ff.text_field(:name, "gmt_offset").set(offset)
        end
		@ff.text_field(:name, 'username').set(@user)
		@ff.text_field(:name, /password/).set(@pass)
		@ff.text_field(:name, /rt_password/).set(@pass)
		@ff.link(:text, 'OK').click

		if @ff.text.include?("Router Status")
            @logged_in = TRUE
            self.msg("Login Setup", :info, "Login Setup", "Successfully finished the login setup.")
        else
            self.msg("Login Setup", :error, "Login Setup", "Login setup failed. Check DUT.")
            raise
        end
	end
	
    def mainpage(rule_name, info)
		if @logged_in == TRUE
			begin
				# Just jump to main
				@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
			rescue
				# otherwise, we got logged out, let's log back in
				@logged_in = FALSE
				success = self.login(rule_name, info)
			end
		else
			self.login(rule_name, info)
		end
	end
    
	# Wireless Settings Page
	# Overview: Set to Wireless Settings, and then whatever menu option passed to us. 
	# In addition, if we are already on the page, don't do anything, because it's
	# redundant and unnecessary. 
	
	# Options: Basic, Advanced
    def wirelesspage(rule_name, section)
		# First we check if we are still on the login page
		if @ff.url.include?('page_login')
			self.mainpage(rule_name, 'main')
		end
		# Let's try clicking on wireless now. If it comes back to login, the session timed out. 
		begin
			@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fwireless..\', 1)').click
			# If logged out, let's try one more time. 
			if @ff.url.include?('page_login')
				begin
					self.mainpage(rule_name, 'main')
					@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fwireless..\', 1)').click
				rescue
					self.msg(rule_name, :error, 'Wireless - Page Jumper', 'Logged back in, but still unable to get to page requested.').click
					return false
				end
			end
		rescue
			# Something went wrong, error out and return message. 
			self.msg(rule_name, :error, 'Wireless - Page Jumper', 'Did not reach Wireless Settings page.')
			return false
		end
		if section.downcase == 'status'
			return true
		end
		# Now let's get to individual pages if necessary
		w_section = {	"basic" => "Basic Security Settings",
		                "advanced" => "Advanced Security Settings"
		            }
		begin
			@ff.link(:text, w_section[section.downcase]).click
			return true
		rescue
			self.msg(rule_name, :error, 'Wireless - Page Jumper', 'Unable to reach '+section)
			return false
		end
    end

	# My Network
	# Overview: Set to My Network page, and then whatever menu option passed to us.
	# In addition, if we are already on the page, don't do anything, because it's
	# redundant and unnecessary.

	# Options: Basic, Advanced
    def my_network_page(rule_name, section="network status")
		# First we check if we are still on the login page
		self.mainpage(rule_name, 'main') if @ff.url.include?('page_login')
		# Let's try clicking on wireless now. If it comes back to login, the session timed out.
		begin
			@ff.link(:href, "javascript:mimic_button('sidebar: actiontec%5Ftopbar%5FHNM..', 1)").click
			# If logged out, let's try one more time.
			if @ff.url.include?('page_login')
				begin
					self.mainpage(rule_name, 'main')
					@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fwireless..\', 1)').click
				rescue
					self.msg(rule_name, :error, 'Wireless - Page Jumper', 'Logged back in, but still unable to get to page requested.').click
					return false
				end
			end
		rescue
			# Something went wrong, error out and return message.
			self.msg(rule_name, :error, 'My Network', 'Did not reach My Network page.')
			return false
		end
		return true if section.match(/network status/i)

		# Now let's get to individual pages if necessary
		sections = {	"network connections" => "860",
		           }
		begin
			@ff.link(:href, 'javascript:mimic_button(\'btn_tab_goto: '+sections[section.downcase]+'..\', 1)').click
			return true
		rescue
			self.msg(rule_name, :error, 'Wireless - Page Jumper', 'Unable to reach '+section)
			return false
		end
    end

	# Firewall Page
	# Overview: Set to Firewall, and then whatever menu option passed to us. 
	# In addition, if we are already on the page, don't do anything, because it's
	# redundant and unnecessary. 
	
	# Options: General, Access Control, Port Forwarding, DMZ Host, Port Triggering, 
	# Remote Administation, Static NAT, Advanced Filtering, Security Log
	def firewallpage(rule_name, section)
		# First we check if we are still on the login page
		self.mainpage(rule_name, 'main') if @ff.url.include?('page_login')
		# Let's try clicking on firewall now. If it comes back to login, the session timed out. 
		begin
			@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5FJ%5Ffirewall..\', 1)').click
			# If logged out, let's try one more time. 
			if @ff.url.include?('page_login')
				begin
					self.mainpage(rule_name, 'main')
					@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5FJ%5Ffirewall..\', 1)').click
				rescue
					self.msg(rule_name, :error, 'Firewall - Page Jumper', 'Logged back in, but still unable to get to page requested.').click
					return false
				end
			end
		rescue
			# Something went wrong, error out and return message. 
			self.msg(rule_name, :error, 'Firewall - Page Jumper', 'Did not reach page main Firewall page.')
			return false
		end   
        # Yes, we're sure
        begin
            @ff.link(:text, 'Yes').click
			if section.downcase == 'general'
				return true
			end
        rescue
            # Something went wrong, error out and return message. 
            self.msg(rule_name, :error, 'Firewall - Page Jumper', 'did not reach page')
            return false
        end
		# Now let's get to individual pages if necessary
		fw_section = {	"access control" => "Access Control",
		                "port forwarding" => "Port Forwarding",
						"dmz host" => "DMZ Host",
		                "port triggering" => "Port Triggering",
		                "remote admin" => "Remote Administration",
		                "static nat" => "Static NAT",
		                "advanced filtering" => "Advanced Filtering",
		                "security log" => "Security Log"
                     }
		begin
			@ff.link(:text, fw_section[section.downcase]).click
			return true
		rescue
			self.msg(rule_name, :error, 'Firewall - Page Jumper', 'Unable to reach '+section)
			return false
		end
    end

    #
    # Parental Control
    #
    def parentalControlpage(rule_name, info)    
        # jump to the main page
        self.mainpage(rule_name, info)
        
        # click the parental control page
        begin
            @ff.link(:href, /actiontec%5Ftopbar%5Fparntl%5Fcntrl/).click
        rescue
            self.msg(rule_name, :error, 'parental control-main', 'did not reach page')
            return
        end
    end
	
	#
	# Advanced
	#
    def advancedpage(rule_name, section)
		# First we check if we are still on the login page
		self.mainpage(rule_name, 'main') if @ff.url.include?('page_login')
		# Let's try clicking on advanced now. If it comes back to login, the session timed out. 
		begin
			@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fadv%5Fsetup..\', 1)').click
			# If logged out, let's try one more time. 
			begin
                self.mainpage(rule_name, 'main')
                @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fadv%5Fsetup..\', 1)').click
            rescue
                self.msg(rule_name, :error, 'Advanced - Page Jumper', 'Logged back in, but still unable to get to page requested.').click
                return false
            end if @ff.url.include?('page_login')
		rescue
			# Something went wrong, error out and return message. 
			self.msg(rule_name, :error, 'Advanced - Page Jumper', 'Unable to reach main Advanced page.')
			return false
		end   
        # Yes, we're sure
        begin
            @ff.link(:text, 'Yes').click
			if section.downcase == 'general'
				return true
			end		
        rescue
            # Something went wrong, error out and return message. 
            self.msg(rule_name, :error, 'Advanced - Page Jumper', 'No confirmation page appeared.')
            return false
		end
		# Now let's get to individual pages if necessary...
		# Using a hash instead of case selection, this makes it easier to read, and modify later 
		# notice that some are shortened
		adv_section = {	"diagnostics" => "Diagnostics",
						"restore defaults" => "Restore Defaults",
						"reboot router" => "Reboot Router",
						"mac cloning" => "MAC Cloning",
						"arp table" => "ARP Table",
						"users" => "Users",
						"qos" => "Quality of Service(QoS)",
						"local admin" => "Local Administration",
						"remote admin" => "Remote Administration",
						"dynamic dns" => "Dynamic DNS",
						"dns server" => "DNS Server",
						"config file" => "Configuration File",
						"system settings" => "System Settings",
						"port config" => "Port Configuration",
						"network objects" => "Network Objects",
						"upnp" => "Universal Plug and Play",
						"sip alg" => "SIP ALG",
						"mgcp alg" => "MGCP ALG",
						"protocols" => "Port Forwarding Rules",
						"date and time" => "Date and Time",
						"scheduler rules" => "Scheduler Rules",
						"routing" => "Routing",
						"ip address distribution" => "IP Address Distribution",
                        "firmware upgrade" => "Firmware Upgrade" }
		begin
			@ff.link(:text, adv_section[section.downcase]).click
			return true
		rescue
			self.msg(rule_name, :error, 'Advanced - Page Jumper', 'Unable to reach '+section)
			return false
		end
	end
	
    #
    # System Monitoring
    #
    def sysmonpage(rule_name, section=nil)
		self.mainpage(rule_name, 'main') if @ff.url.include?('page_login')
		# Let's try clicking on System Monitoring now. If it comes back to login, the session timed out. 
		begin
			@ff.link(:href, /actiontec%5Ftopbar%5Fstatus../).click
			# If logged out, let's try one more time. 
			if @ff.url.include?('page_login')
				begin
					self.mainpage(rule_name, 'main')
					@ff.link(:href, /actiontec%5Ftopbar%5Fstatus../).click
					return true
				rescue
					self.msg(rule_name, :error, 'System Monitoring', 'Logged back in, but still unable to get to page requested.').click
					return false
				end
            else
                return true
            end
		rescue
			# Something went wrong, error out and return message. 
			self.msg(rule_name, :error, 'System Monitoring', 'Unable to get to page.')
			return false
		end   
	end

	# Extended logout code with some insurance.
	# Should help alleviate some random logout issues, or at least help track the reasons we run into them down.
	def logout(rule_name, info="")
		#click logout
		if @ff.link(:text, 'Logout').exists?
			@ff.link(:text, 'Logout').click
			self.msg(rule_name, :info, 'Logout', 'Success')
			@logged_in = FALSE
			@logged_in = FALSE
        else
			self.msg(rule_name, :info, 'Logout', 'No logout link on current page.')
            self.msg(rule_name, :debug, "Logout", "Jumping to main to find a logout link...")
            if @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').exists?
                self.mainpage(rule_name, 'Logout insurance jump.')
                @ff.link(:text, 'Logout').click
            else
                self.msg(rule_name, :debug, "Logout", "Link to main page doesn't exist. Finding alternative..")
                self.msg(rule_name, :debug, "Logout", "Current URL: #{@ff.url} ; Current page spew: #{@ff.text}")
                if @ff.link(:text, /logout/i).exists?
                    self.msg(rule_name, :debug, "Logout", "Found a logout link using a regular expression.")
                    @ff.link(:text, /logout/i).click
                    self.msg(rule_name, :info, 'Logout', 'Success')
                elsif @ff.link(:text, /main/i).exists?
                    self.msg(rule_name, :debug, "Logout", "Found a link back to main.")
                    @ff.link(:text, /main/i).click
                    if @ff.link(:text, /logout/i).exists?
                        self.msg(rule_name, :debug, "Logout", "Logging out now...")
                        @ff.link(:text, /logout/i).click
                        self.msg(rule_name, :info, 'Logout', 'Success')
                    end
                elsif @ff.link(:text, /cancel/i).exists?
                    self.msg(rule_name, :debug, "Logout", "Looks like we're on a page with a cancel button. Cancelling and attempting a log out...")
                    @ff.link(:text, /cancel/i).click
                    self.msg(rule_name, :debug, "Logout", "Hitting \"cancel\" led to #{@ff.url}")
                    if @ff.link(:text, /logout/i).exists?
                        self.msg(rule_name, :debug, "Logout", "Logging out now...")
                        @ff.link(:text, /logout/i).click
                        self.msg(rule_name, :info, 'Logout', 'Success')
                    end
                elsif @ff.link(:text, /ok/i).exists?
                    self.msg(rule_name, :debug, "Logout", "Looks like we're on a page with an OK button. Clicking OK and attempting a log out...")
                    @ff.link(:text, /ok/i).click
                    self.msg(rule_name, :debug, "Logout", "Hitting \"cancel\" led to #{@ff.url}")
                    if @ff.link(:text, /logout/i).exists?
                        self.msg(rule_name, :debug, "Logout", "Logging out now...")
                        @ff.link(:text, /logout/i).click
                        self.msg(rule_name, :info, 'Logout', 'Success')
                    end
                elsif @ff.link(:text, /confirm/i).exists?
                    self.msg(rule_name, :debug, "Logout", "Looks like we're on a page with a confirmation button. Unexpected. Confirming and attempting a log out...")
                    @ff.link(:text, /confirm/i).click
                    self.msg(rule_name, :debug, "Logout", "Hitting \"cancel\" led to #{@ff.url}")
                    if @ff.link(:text, /logout/i).exists?
                        self.msg(rule_name, :debug, "Logout", "Logging out now...")
                        @ff.link(:text, /logout/i).click
                        self.msg(rule_name, :info, 'Logout', 'Success')
                    end
                elsif @ff.link(:text, /apply/i).exists?
                    self.msg(rule_name, :debug, "Logout", "Looks like we're on a page with an apply button. Unexpected. Applying and attempting a log out...")
                    @ff.link(:text, /apply/i).click
                    self.msg(rule_name, :debug, "Logout", "Hitting \"cancel\" led to #{@ff.url}")
                    if @ff.link(:text, /logout/i).exists?
                        self.msg(rule_name, :debug, "Logout", "Logging out now...")
                        @ff.link(:text, /logout/i).click
                        self.msg(rule_name, :info, 'Logout', 'Success')
                    end
                else
                    self.msg(rule_name, :fatal, "Logout", "Not seeing a way out of this. Check page URL and contents.")
                    self.msg(rule_name, :fatal, 'Logout', 'Failed')
                end
            end
		end
	end
end


