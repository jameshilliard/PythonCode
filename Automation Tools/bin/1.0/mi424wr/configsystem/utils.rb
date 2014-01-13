# General utilities, like clean up items. 

module CleanUp
	# Port triggering
    def port_triggering_cleanup(rule_name, remove)
        return if self.firewallpage(rule_name, 'Port Triggering') == false
        if remove.downcase == 'all'
            remove_list = []
            @ff.links.each { |t| remove_list << t.href if t.href.match(/remove/) }
            remove_list.each { |x| @ff.link(:href, x).click unless x.match(/remove: 0\./) || x.match(/remove: 1\./) }
        end
    end
    # Quality of Service
    def qos_cleanup(rule_name, remove)
        return unless self.advancedpage(rule_name, "qos")

        if remove.downcase == 'all'
            # Traffic priority
            remove_list = []
            @ff.links.each { |t| remove_list << t.href if t.href.match(/remove/) }
            remove_list.each { |x| @ff.link(:href, x).click }
            # Traffic shaping
            @ff.link(:text, "Traffic Shaping").click
            remove_list = []
            @ff.links.each { |t| remove_list << t.href if t.href.match(/remove/) }
            remove_list.each { |x| @ff.link(:href, x).click }
        end
    end
	# Port forwarding cleaner
	def portForwardCleanUp(rule_name, remove)
		return if self.firewallpage(rule_name, 'Port Forwarding') == false
		# There's two functions here. The first set will remove everything, the second will remove only specified options. 
		# This way we can do add/delete. However, this means that the config file must contain the correct
		# index numbers for the rule.
		if remove.downcase == 'all'
            while @ff.checkbox(:id, /_/).exists?
                cf = 0
                @ff.checkboxes.each { |c| c.click; cf += 1; break if cf > 20 }
                @ff.link(:text, 'Delete').click
            end
#			while @ff.link(:name, 'remove').exists?
#				@ff.link(:name, 'remove').click
#			end
			self.msg(rule_name, :info, 'Port Forward CleanUp', 'Finished cleaning.')
		elsif remove.include?('id:')
			removeID = remove.split(':')
			(removeID[1].split(',')).each do |index|
				index.strip!
				deleteLink = "javascript:mimic_button(\'remove: 0%5F" + index.to_s + "..\', 1)"
				begin
					@ff.link(:href, deleteLink).click
				rescue
					self.msg(rule_name, :warning, 'Port Forward CleanUp', 'Could not find index value: '+index.to_s+'; Continuing with deletion')
				end
			end
		else
			self.msg(rule_name, :error, 'Port Forward CleanUp', 'No specified action for Port Forward Clean up')
			return
		end
		self.msg(rule_name, :info, 'Port Forward CleanUp', 'Finished cleaning port forwarding rules')
	end
	# Static NAT Cleaner
	def staticNatCleanUp(rule_name, remove)
		if self.firewallpage(rule_name, 'Static NAT') == false
			return
		end
		# There's two functions here. The first set will remove everything, the second will remove only specified options. 
		# This way we can do add/delete. However, this means that the config file must contain the correct
		# index numbers for the rule.
		if remove.downcase == 'all'
			while @ff.link(:name, 'remove').exists?
				@ff.link(:name, 'remove').click
			end
			self.msg(rule_name, :info, 'Static NAT CleanUp', 'Finished cleaning.')
		elsif remove.include?('id:')
			removeID = remove.split(':')
			(removeID[1].split(',')).each do |index|
				index.strip!
				deleteLink = "javascript:mimic_button(\'remove: 0%5F" + index.to_s + "..\', 1)"
				begin
					@ff.link(:href, deleteLink).click
				rescue
					self.msg(rule_name, :warning, 'Static NAT CleanUp', 'Could not find index value: '+index.to_s+'; Continuing with deletion')
				end
			end
		else
			self.msg(rule_name, :error, 'Static NAT CleanUp', 'No specified action for Port Forward Clean up')
			return
		end
		self.msg(rule_name, :info, 'Static NAT CleanUp', 'Finished cleaning port forwarding rules')
	end
	
	# Access Controls cleaner
	def accessControlCleanUp(rule_name, remove)
		# Jump to firewall, get the and to access controls
		if self.firewallpage(rule_name, 'general') == true
			# Check if firewall is on Maximum Security (High)
			@ff.radio(:id, 'sec_level_3').checked? == true ? maxSec = 1 : maxSec = 0
			if self.firewallpage(rule_name, 'access control') == false
				return
			end
		else
			return
		end
		block = false
		allow = false
		# Access Control has two sections: block and allow. Further, when Allow is shown, it has preset rules. So we'll
		# want to create a specific function to remove all rules besides the predefined ones. To do this, the "remove"
		# key can have "allow: " and "block: " for the removal IDs. It can also be "all" which removes all the 
		# user defined rules, or "everything" which removes even the predefined rules for "Allow" 
		
		# Function to remove everything, including pre defined rules. 
		if remove.downcase == 'everything'
			while @ff.link(:name, 'remove').exists?
				@ff.link(:name, 'remove').click
			end
			self.msg(rule_name, :info, 'Access Control CleanUp', 'Finished cleaning.')
		# Remove custom ID tags
		elsif remove.include?('block:') || remove.include?('allow:')
			# Regular expression matching to split up allow/block rules in the same remove ID
			if remove.match(/\Ablock:.*allow:/) > nil
				removeTemp = remove.split('block:')
				removeID = removeTemp[1].split('allow:')
				block = 0
				allow = 1
			elsif remove.match(/\Aallow:.*block:/) > nil
				removeTemp = remove.split('allow:')
				removeID = removeTemp[1].split('block:')
				block = 1
				allow = 0
			elsif remove.match(/\Ablock:/) > nil
				removeID = remove.split('block:')
				block = 0
			elsif remove.match(/\Aallow:/) > nil
				removeID = remove.split('allow:')
				allow = 0
			else
				self.msg(rule_name, :error, 'Access Control CleanUp', 'No valid \"remove\" tag included. Valid options are \"block:\" or \"allow:\" or both')
				return
			end
			# Block rules are always available, so let's do those first: 
			if block != false
				if removeID[block].match(/all/i)
					while @ff.link(:href, /remove: 0%5F/).exists?
						@ff.link(:href, /remove: 0%5F/).click
					end
				else
					(removeID[block].split(',')).each do |index|
						index.strip!
						deleteLink = "javascript:mimic_button(\'remove: 0%5F" + index.to_s + "..\', 1)"
						if @ff.link(:href, deleteLink).exists?
							@ff.link(:href, deleteLink).click
						else
							self.msg(rule_name, :warning, 'Access Control CleanUp', 'Could not find index value: '+index.to_s+'; Continuing with deletion')
						end
					end
				end
			end
			# Now let's do the rules under Allow. Notice how we always do the block rules, and THEN do the firewall checking here? 
			# Blocked rules will ALWAYS be removed when specified, and Allow rules will ONLY be removed when the firewall is already
			# set to HIGH
			if allow != false
				if maxSec == 0
					self.msg(rule_name, :error, 'Access Control CleanUp', 'Firewall is not at Maximum Security (High). Cannot remove "Allow" rules')
					return
				end
				if removeID[allow].match(/all/i)
					while @ff.link(:href, /remove: 1%5F[^0-8]/).click
						@ff.link(:href, /remove: 1%5F[^0-8]/).click
					end
				else
					(removeID[allow].split(',')).each do |index|
						index.strip!
						deleteLink = "javascript:mimic_button(\'remove: 1%5F" + index.to_s + "..\', 1)"
						if @ff.link(:href, deleteLink).exists?
							@ff.link(:href, deleteLink).click
						else
							self.msg(rule_name, :warning, 'Access Control CleanUp', 'Could not find index value: '+index.to_s+'; Continuing with deletion')
						end
					end
				end
			end
		# lastly, the rule to remove all rules, and not delete the predefined rules under "Allow"
		elsif remove.downcase == 'all'
			if remove.downcase == 'all'
				while @ff.link(:href, /remove: 1%5F[^0-8]/).exists?
					@ff.link(:href, /remove: 1%5F[^0-8]/).click
				end
				while @ff.link(:href, /remove: 0%5F/).exists?
					@ff.link(:href, /remove: 0%5F/).click
				end
				self.msg(rule_name, :info, 'Access Control CleanUp', 'Finished cleaning.')
			end
		else
			self.msg(rule_name, :error, 'Access Control CleanUp', 'No specified action for Access Control Clean up')
			return
		end
		self.msg(rule_name, :info, 'Access Control CleanUp', 'Finished cleaning access control rules')
	end
	
	# Clean up selector. Redirects to specific page clean up parsers. 
	# FixMe: Need to add cleaners for advanced filtering, QoS, parental controls, port triggering, static NAT, users, scheduler, network objects, arp table
	def cleanup(rule_name, info)
		if info.has_key?('remove') && info.has_key?('cleaner')
			case info['cleaner']
			when /port.?forward/i
				portForwardCleanUp(rule_name, info['remove'])
			when /access.?control/i
				accessControlCleanUp(rule_name, info['remove'])
			when /static.?nat/i
				staticNatCleanUp(rule_name, info['remove'])
            when /port.?trigger/i
                port_triggering_cleanup(rule_name, "all")
            when /qos|quality.?of.?service/i
                qos_cleanup(rule_name, "all")
			end
		else
			self.msg(rule_name, :error, 'Clean Up', 'No \"Remove\" and/or \"Cleaner\" key for rule.')
			return
		end
	end
end

module TestBuilder
	def buildTest(rule_name, info, type, sect)
        return unless @output_test_file
        return if info['scanbuild'].match(/off/i)
		case type
        when /remote admin/i
            self.msg(rule_name, :info, "Building Test", "Building a test config for remote administration.")
            self.msg(rule_name, :debug, "Building Test", "Using WAN IP of #{@dut_information["Broadband IP Address"]}")
            buildOutput(rule_name, "type", type)
            buildOutput(rule_name, "wanip", @dut_information["Broadband IP Address"])
            buildOutput(rule_name, "administration_ports", @dut_remote_admin)
            buildTestCase
        when /iperf/i
            if sect.match(/port trig/i)
                self.msg(rule_name, :debug, "Building Test", "Building test scenario for Port Triggering using IPerf.")
                buildOutput(rule_name, "type", "iperf -all")
                buildOutput(rule_name, "outbound_ip", "--remote-ip")
                buildOutput(rule_name, "inbound_ip", self.system_information(rule_name, 'ip address'))
                buildOutput(rule_name, "iperf_server", "REMOTE")
                buildOutput(rule_name, "outbound", "#{@portScanList_outbound['tcp_ports'].sub(/, \z/, '')},#{@portScanList_outbound['udp_ports'].sub(/, \z/, '')}".sub(/\A,/, '').sub(/, \z|,\z/, ''))
                buildOutput(rule_name, "inbound", "#{@portScanList_inbound['tcp_ports'].sub(/, \z/, '')},#{@portScanList_inbound['udp_ports'].sub(/, \z/, '')}".sub(/\A,/, '').sub(/, \z|,\z/, ''))
                buildOutput(rule_name, "from", sect)
                buildOutput(rule_name, "max_root_threads", 5)
                buildTestCase("#{@output_test_file}iperf_test.json")
            elsif sect.match(/port forw/i)
                @output_test_file.sub!(/\.json/i, "") if @output_test_file.match(/\.json/i)
				self.msg(rule_name, :debug, "Building Test", "Building test scenario for Port Forwarding using IPerf.")
				buildOutput(rule_name, "type", "iperf -all")
                buildOutput(rule_name, "ltp", info['ForwardTo']) if info['ForwardTo']
                buildOutput(rule_name, "iperf_server", "LOCAL")
				buildOutput(rule_name, "local_ip", info['host'].delete('^[0-9.]'))
                buildOutput(rule_name, "inbound_ip", self.system_information(rule_name, 'ip address'))
                buildOutput(rule_name, "outbound", "")
                buildOutput(rule_name, "inbound", "#{@portScanList_inbound['tcp_ports'].sub(/, \z/, '').gsub('any','TCP')},#{@portScanList_inbound['udp_ports'].sub(/, \z/, '').gsub('any','UDP')}".sub(/\A,/, '').sub(/, \z|,\z/, '').squeeze(','))
				buildOutput(rule_name, "from", sect)
                buildOutput(rule_name, "max_root_threads", 5)
				buildTestCase("#{@output_test_file}_iperf.json")
            end
		when /port.?scan/i
			if sect.match(/dmz host/i)
				self.msg(rule_name, :debug, "Building Test", "Building test scenario from DMZ Host rule.")
				optlist = Dir.entries("#{@port_lists}").delete_if { |x| x.match(/\A\./) }
				portlist = optlist[rand(optlist.length)]
				self.msg(rule_name, :debug, "Building Test", "Using random port list file - #{portlist}")
				contents = read_portlist_file("#{@port_lists}/#{portlist}")
				contents[contents.keys[0]]["wanip"] = @dut_information["Broadband IP Address"]
				contents[contents.keys[0]]["action"] = info['action']
				contents[contents.keys[0]]["config"] = info.to_s
                contents[contents.keys[0]]["from"] = sect
                contents[contents.keys[0]]["type"] = "port scan -scatter"
				buildTestCase(nil,contents)
			elsif sect.match(/static nat/i)
				self.msg(rule_name, :debug, "Building Test", "Using stored ports from configuration for port scan testing.")
				incomingip = info['publicIP']
				self.msg(rule_name, :debug, "Building Test", "Received WAN IP of #{incomingip}")
				outgoingip = info['host'].gsub(/[^0-9\.]/,'')
				self.msg(rule_name, :debug, "Building Test", "Using LAN/Outgoing IP of #{outgoingip}")
				buildOutput(rule_name, "type", type)
				buildOutput(rule_name, "lanip", outgoingip)
				buildOutput(rule_name, "wanip", incomingip)
				optlist = Dir.entries("#{@port_lists}").delete_if { |x| x.match(/\A\./) }
				portlist = optlist[rand(optlist.length)]
				self.msg(rule_name, :debug, "Building Test", "Using random port list file - #{portlist}")
				contents = read_portlist_file("#{@port_lists}/#{portlist}")
				buildOutput(rule_name, "udp_ports", "#{@portScanList_inbound['udp_ports']}#{contents[contents.keys[0]]["udp_ports"]}")
				buildOutput(rule_name, "tcp_ports", "#{@portScanList_inbound['tcp_ports']}#{contents[contents.keys[0]]["tcp_ports"]}")
				buildOutput(rule_name, "from", sect)
				buildOutput(rule_name, "config", info.to_s)
				buildTestCase
			else
                @output_test_file.sub!(/\.json/i, "") if @output_test_file.match(/\.json/i)
				self.msg(rule_name, :debug, "Building Test", "Using stored ports from configuration for port scan testing.")
				self.msg(rule_name, :debug, "Building Test", "Received WAN IP of #{@dut_information["Broadband IP Address"]}")
				info.has_key?('outgoingip') ? outgoingip = info['outgoingip'] : outgoingip = @lanip
				self.msg(rule_name, :debug, "Building Test", "Using LAN/Outgoing IP of #{outgoingip}")
				buildOutput(rule_name, "type", type)
				buildOutput(rule_name, "lanip", outgoingip)
				buildOutput(rule_name, "wanip", @dut_information["Broadband IP Address"])
				@portScanList_inbound['udp_ports'].sub!(/, \z/, '')
				@portScanList_inbound['tcp_ports'].sub!(/, \z/, '')
				buildOutput(rule_name, "udp_ports", @portScanList_inbound['udp_ports'].sub(/,\z/, ''))
				buildOutput(rule_name, "tcp_ports", @portScanList_inbound['tcp_ports'].sub(/,\z/, ''))
				buildOutput(rule_name, "from", sect)
				buildOutput(rule_name, "config", info.to_s)
				buildTestCase("#{@output_test_file}_nmap.json")
			end
		end
	end
	
	def read_portlist_file(filename)
		self.msg("Reading Port List File", :debug, "", "Loading #{filename} and parsing.")
		begin
			json = JSON.parse!(File.open(filename).read)
		rescue JSON::ParserError => ex
			puts "Error: Cannot parse " + filename
			puts "#{ex.message}"
			return false
		end
		self.msg("Reading Port List File", :debug, "", "Finished parsing.")
		return json
	end
	
	def buildOutput(rule, section, msg)
		self.msg("Building Test Output", :debug, "", "Adding to test system build file: #{rule}::#{section} - #{msg}")
		if not @builder.has_key?(rule)
			@builder[rule] = {section => msg}
		else
			@builder[rule][section] = msg
		end
	end

	def buildTestCase(filename=nil, contents=nil)
        filename = @output_test_file if filename == nil
		if contents == nil 
			buildoutput = JSON.pretty_generate(@builder)
		else
			buildoutput = JSON.pretty_generate(contents)
		end
		self.msg("Saving Test File", :debug, "JSON Save", "Saving test system build file as #{filename}")
		begin
			f = File.open(filename, 'w')
			buildoutput.each do |line|
				f.write(line)
			end
			f.close
		rescue
			self.msg("Saving Test File", :error, "JSON Save", "Could not write JSON output file #{filename}")
			exit
		end
	end
end

module Utility
    def apply_settings(rule_name, section, end_sleep = 5)
        sleep_count = 0
        self.msg(rule_name, :info, section, "Applying Settings")
        @ff.link(:text, "Apply").click
        if @ff.contains_text("Press Apply to confirm")
            self.msg(rule_name, :info, section, "Applying Settings - Confirmation Page confirmed.")
            @ff.link(:text, "Apply").click
        end
        if @ff.contains_text("Please wait while we apply")
            while @ff.contains_text("Please wait while we apply")
                if sleep_count > end_sleep
                    self.msg(rule_name, :error, section, "Wait time for applying settings exceeded (#{sleep_count*end_sleep} seconds.) Aborting the wait.")
                    return
                end
                sleep(5)
                sleep_count += 1
                @ff.refresh
            end
        end
    end
    def get_id_set
        # rules container
        valid_rules = []
        marker = 2
        # Loop variables for finding input/output rules
        while new_element = @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[3]/tbody/tr[#{marker}]/td[2]")[0]
            valid_rules << new_element.text.downcase
            marker += 1
        end
        # return what we found
        return valid_rules
    end
    def get_priority_set
        # rules container
        valid_rules = []
        marker = 2
        # Loop variables for finding input/output rules
        while new_element = @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[4]/tbody/tr[#{marker}]/td")[0]
            valid_rules << new_element.text.downcase
            marker += 1
        end
        # return what we found
        return valid_rules
    end

    # Method to get input and output rule sets
    def get_rule_set(t_index, id_marker)
        # rules container
        valid_rules = []

        # Loop variables for finding input/output rules
        while new_element = @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[#{t_index}]/tbody/tr/td/table/tbody/tr[#{id_marker}]/td/b/font/b")[0]
            valid_rules << new_element.text.downcase
            id_marker += 1
        end
        # return what we found
        return valid_rules
    end

    # Returns a string in the format of HH:MM:SS from the epoch time passed.
    def format_time(epochtime, exclude_seconds = nil)
        t = Time.at(epochtime).to_a
        return sprintf("%d:%d", t[2], t[1]) unless exclude_seconds == nil
        return sprintf("%d:%d:%d", t[2], t[1], t[0])
    end

    # Returns a string in the format of MM/DD/YYYY from the epoch time passed.
    def format_date(epochtime)
        t = Time.at(epochtime).to_a
        return sprintf("%d/%d/%d", t[4], t[3], t[5])
    end

    # Returns the extracted offset time from a string in seconds
    def extract_offset(orgin, f)
        # Offset should be in +# min/hour/day format
        offset = orgin.strip.sub(/\A\+/, '').to_i
        m = 1
        case f.strip
        when /min/i
            m = 60
        when /hour/i
            m = 3600
        when /day/i
            m = 86400
        end
        return offset*m
    end

    # Validates a regular expression from a firewatir select_list, selects the object, and returns the selection chosen.
	def validate(tag_id, item, tag=:id)
		selection = ""
		(@ff.select_list(tag, tag_id).getAllContents).each { |validate| selection = validate if validate.match(Regexp.new(item.strip, /i/)) != nil }
        return false if selection.length == 0
		@ff.select_list(tag, tag_id).select(selection)
		return selection
	end

    # Returns the current month in short hand notation from an integer 1-12.
	def getMonth(value)
		months = ["Begin", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
		if value > 0 and value < 13
			return months[value]
		else
			return "Unknown Month"
		end
	end

    # Returns a set of human readable notation from a set of flags used in a config file.
	def humanReadable(section, flags)
		case section
		when /date|time/i
			#"set" : "-zone mountain -dst on -dststart 3/11 23:50 -dstend 11/11 12:20 -offset 60 -atu on -protocol tod -update 24"
			flags.gsub!(/-/, "|")
			flags.sub!(/mountain/i, "Mountain Time GMT-07:00")
			flags.sub!(/pacific/i, "Pacific Time GMT-08:00")
			flags.sub!(/hawaii/i, "Hawaii Time GMT-10:00")
			flags.sub!(/greenwich/i, "Greenwich Mean Time GMT+00:00")
			flags.sub!(/eastern/i, "Eastern Time GMT-05:00")
			flags.sub!(/central/i, "Central Time GMT-06:00")
			flags.sub!(/alaska/i, "Alaska Time GMT-09:00")
			flags.sub!(/update/i, "Update Time Interval (Hours)=")
			flags.sub!(/zone/i, "Time Zone=")
			flags.sub!(/dst /i, "Daylight Savings Time=")
			flags.sub!(/dststart/i, "Daylight Savings Start Time=")
			flags.sub!(/dstend/i, "Daylight Savings End Time=")
			flags.sub!(/offset/i, "Daylight Savings Time Offset=")
			flags.sub!(/atu/i, "Automatic Time Update=")
			flags.sub!(/protocol/i, "Protocol=")
			flags.sub!(/tod/i, "Time Of Day (TOD)=")
			flags.sub!(/ntp |ntp\z|\Antp/i, "Network Time Protocol (NTP)=")
			return flags
		end
	end
	
	# Returns TRUE of the corresponding rule has resolved, FALSE if not.
	def resolved(rule_name)
		done = FALSE
		count = 1
		while not done
			@ff.refresh
			values = getDataCell("Computer", "Unresolved")
			if values == FALSE
				self.msg(rule_name, :warning, "Resolved?", "Unable to find a valid table. Was this called correctly?")
				return FALSE
			elsif values.to_s == ""
				self.msg(rule_name, :info, "Resolved?", "Showing no unresolved items.")
				return TRUE
			elsif values.to_s.include?("Unresolved")
				if count == 1
					self.msg(rule_name, :warning, "Unresolved items refresh", "Showing one or more items unresolved. Sleeping for 5 and refreshing.")
					sleep 5
					count += 1
				else
					done = TRUE
					self.msg(rule_name, :warning, "Resolved?", "Items are showing as unresolved. This is quite possibly a failure. Please check the following items: ")
					for i in 1..values.length
						self.msg(rule_name, :warning, "Unresolved #{i}", "Computer/Device: #{values[i][1]} -> IP: #{values[i][2]} Ports: #{values[i][4]}")
					end
					return FALSE
				end
			end
		end
	end
	
	# Returns information in a given table that starts with topText, and in a datacell of row,column, where topText is cell 1,1.
	# Accepts list separated by a semi-colon. 
	# getDataCell("Computer/Device", "3,6") will return the WAN Connection Type of rule 1 on port forwarding page.
	# You can also specify a text value, and each row with the text value will be sent back. 
	def getDataCell(topText, datacell)
		found = false
		@ff.tables.each do |t|
			if t.text.include?(topText)
				found = t
			end
		end
		if found != false
			if datacell.match(/\d+,\d+/)
				values = ""
				datacell.split(';').each do |cell|
					values << "#{found[cell.split(',')[0].to_i][cell.split(',')[1].to_i].text},"
				end
				values.sub!(/,\z/,'')
			else
				values = []
				for i in 1..found.row_count
					if found[i].text.downcase.match(Regexp.new(datacell.downcase.strip))
						values[i] = found[i]
					end
				end
			end
		else
			return FALSE
		end
		return values
	end
end

module Searcher
	def page_search(pages="")
		validList = ""
		if pages == ""
			for i in 1..9999
				@ff.goto("http://192.168.1.1/index.cgi?active_page=#{i}")
				if @ff.text == ""
					self.msg(rule_name, :debug, "Saving Built Test", "Waiting for Kernel Panic")
					sleep 30
				elsif @ff.text.include?("Login")
					self.login("Page Searcher", 'External Call')
					@ff.goto("http://192.168.1.1/index.cgi?active_page=#{i}")
					if @ff.text == ""
						self.msg(rule_name, :debug, "Saving Built Test", "Waiting for Kernel Panic")
						sleep 30
					elsif @ff.text.match(/failed to connect/i)
						i-=1
					elsif not @ff.text.include?("Close")
						if @ff.text.match(/config/i)
							self.msg(rule_name, :debug, "Saving Built Test", "!!Found related CONFIG page!!")
							validList << "!!CONFIG!! "
						end
						self.msg(rule_name, :debug, "Saving Built Test", "Adding: http://192.168.1.1/index.cgi?active_page=#{i}")
						validList << "http://192.168.1.1/index.cgi?active_page=#{i}\n"
					end
				elsif @ff.text.match(/failed to connect/i)
					i-=1
				elsif not @ff.text.include?("Close")
					if @ff.text.match(/config/i)
						self.msg(rule_name, :debug, "Saving Built Test", "!!Found related CONFIG page!!")
						validList << "!!CONFIG!! "
					end
					validList << "http://192.168.1.1/index.cgi?active_page=#{i}\n"
					self.msg(rule_name, :debug, "Saving Built Test", "Adding: http://192.168.1.1/index.cgi?active_page=#{i}")
				end
			end
			puts validList
		else
			pages.delete!(' ')
			validPages = ""
			pages.split(',').each do |page|
				@ff.goto("http://192.168.1.1/index.cgi?active_page=#{page}")
				if @ff.text.match(/Failed to connect/i)
					self.msg(rule_name, :debug, "Saving Built Test", "#{page} was not valid.")
				elsif @ff.text.match(/close/i)
					self.msg(rule_name, :debug, "Saving Built Test", "#{page} was not valid.")
				elsif @ff.text == ""
					self.msg(rule_name, :debug, "Saving Built Test", "#{page} caused a kernel panic, marking as not valid and waiting for system reboot.")
					sleep 30
				else
					validPages << "http://192.168.1.1/index.cgi?active_page=#{page}\n"
				end
			end
		end
	end
end