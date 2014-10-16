# Methods for items under Firewall. Everything but the Security Log is complete, including all sub functions for each section. 
# That means we have global calling for the scheduler, and adding network objects or ports on various pages. A clear testing plan
# for the system log would be required before implementing it, because there's no clear idea of what would be needed besides some 
# various functions that can be done by hand very easily. 
# Testing
module Firewall
	
	def firewall_jumper(rule_name, info)
		case info['section']
		when /general/i
			self.firewall_general(rule_name, info)
		when /port.*forward.*/i
			self.port_forwarding(rule_name, info)
		when /acc.*control/i
			self.access_control(rule_name, info)
		when /dmz.*/i
			self.dmz_host(rule_name, info)
        when /static.?nat/i
            self.static_nat(rule_name, info)
		when /port.*trig.*/i
			self.port_triggering(rule_name, info)
		when /remote/i
			self.firewall_remote_admin(rule_name, info)
		when /adv.*filter/i
			self.advanced_filtering(rule_name, info)
		end
	end
	
    #####################
    # Firewall - General#  
    #####################

    def firewall_general(rule_name, info)
		return if self.firewallpage(rule_name, 'general') == false
		# Set firewall level if specified
		if info.has_key?('set')
			if info['set'].match(/low|med|high|min|typical|max|frag/)
				@ff.radio(:id, 'sec_level_1').set if info['set'].match(/low|min/i)
				@ff.radio(:id, 'sec_level_2').set if info['set'].match(/med|typical/i)
				@ff.radio(:id, 'sec_level_3').set if info['set'].match(/high|max/i)
				@ff.checkbox(:id, 'sec_block_ipfrags_').clear if info['set'].match(/\-frag/i)
				@ff.checkbox(:id, 'sec_block_ipfrags_').set if info['set'].match(/\+frag/i)
				@ff.link(:text, 'Apply').click
				self.msg(rule_name, :info, 'Firewall - General', "Configured to: #{info['set']}")
			else
				self.msg(rule_name, :error, 'Firewall - General', 'No valid parameters to change firewall level. Check configuration.')
				return
			end
		end
		# Return and log firewall level if specified
		if info.has_key?('get')
			level = 'Unknown'
			fragments = 'Unknown setting for IP Fragments'
			if @ff.radio(:id, 'sec_level_1').checked? : level='Low'; end
			if @ff.radio(:id, 'sec_level_2').checked? : level='Typical'; end
			if @ff.radio(:id, 'sec_level_3').checked? : level='Maximum'; end
			@ff.checkbox(:id, 'sec_block_ipfrags_').checked? ? fragments = 'Blocking IP Fragments' : fragments = 'Not blocking IP Fragments'
			self.msg(rule_name, :info, 'Firewall - General', "Firewall currently set to #{level} and #{fragments}")
		end
		
    end
	
	#####################
	# Port Helper       #
	#####################
	# The port helper is to add ports in any instance. This should work for port triggering, access control, etc. 

	def add_ports(rule_name, portsList, calledFrom, addLink)
		# split ports in the list
		ports = portsList.split(';')
		ports.each do |tempport|
			# Begin add
			@ff.link(:href, addLink).click

			# Data gathering
			protocol = tempport.split(':')
			currentPort = protocol[1].split(',')

			# Add destination ports to port building list
			# FixMe: Need to add support for other protocols here. This also means additional test methods in utils.rb
			case protocol[0]
			when /tcp/i
				# Keeping source:destination format
				# Add ! in front if protocol is excluded, too
                if calledFrom.match(/port trig/i)
                    @portScanList_inbound['tcp_ports'] << "#{protocol[0].delete('^[a-zA-Z]')}:#{currentPort[1]}, " if calledFrom.match(/inbound/i)
                    @portScanList_outbound['tcp_ports'] << "#{protocol[0].delete('^[a-zA-Z]')}:#{currentPort[1]}, " if calledFrom.match(/outbound/i)
                else
                    @portScanList_inbound['tcp_ports'] << "!" if protocol[0].match(/~/)
                    @portScanList_inbound['tcp_ports'] << "#{currentPort[0]}:#{currentPort[1]}, "
                end
			when /udp/i
				# Keeping source:destination format
                if calledFrom.match(/port trig/i)
                    @portScanList_inbound['udp_ports'] << "#{protocol[0].delete('^[a-zA-Z]')}:#{currentPort[1]}, " if calledFrom.match(/inbound/i)
                    @portScanList_outbound['udp_ports'] << "#{protocol[0].delete('^[a-zA-Z]')}:#{currentPort[1]}, " if calledFrom.match(/outbound/i)
                else
                    @portScanList_inbound['udp_ports'] << "!" if protocol[0].match(/~/)
                    @portScanList_inbound['udp_ports'] << "#{currentPort[0]}:#{currentPort[1]}, "
                end
			end
			
			if protocol[0].match(/\A~/)
				protocol[0].sub!(/\A~/,'')
				@ff.checkbox(:id, 'svc_entry_protocol_exclude_').click
			end

			# FixMe: While this supports every protocol, the rest of this method doesn't. Need to fix it. 
			if validate("svc_entry_protocol", protocol[0]) == false
				self.msg(rule_name, :error, "Port Helper", "Unable to add protocol: " + protocol[0] + "; Called from #{calledFrom}")
				return
			end
			
			# Set source port
			if currentPort[0].include?('-')
				@ff.select_list(:id, 'port_src_combo').select('Range')
				if currentPort[0].include?('~')
					@ff.checkbox(:id, "port_src_exclude_").click
					currentPort[0].delete!('~')
				end
				sourcePorts = currentPort[0].split('-')
				@ff.text_field(:name, 'port_src_start').set(sourcePorts[0])
				@ff.text_field(:name, 'port_src_end').set(sourcePorts[1])
			elsif currentPort[0].upcase != 'ANY'
				@ff.select_list(:id, 'port_src_combo').select('Single')
				if currentPort[0].include?('~')
					@ff.checkbox(:id, "port_src_exclude_").click
					currentPort[0].delete!('~')
				end				
				@ff.text_field(:name, 'port_src_start').set(currentPort[0])
			end
			# Set destination port
			if currentPort[1].include?('-')
				@ff.select_list(:id, 'port_dst_combo').select('Range')
				if currentPort[1].include?('~')
					@ff.checkbox(:id, "port_dst_exclude_").click
					currentPort[1].delete!('~')
				end
				destPorts = currentPort[1].split('-')
				@ff.text_field(:name, 'port_dst_start').set(destPorts[0])
				@ff.text_field(:name, 'port_dst_end').set(destPorts[1])
			elsif currentPort[1].upcase != 'ANY'
				@ff.select_list(:id, 'port_dst_combo').select('Single')
				if currentPort[1].include?('~')
					@ff.checkbox(:id, "port_dst_exclude_").click
					currentPort[1].delete!('~')
				end				
				@ff.text_field(:name, 'port_dst_start').set(currentPort[1])
			end
			@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
		end
	end
	
    #####################
    # Access Controls   #  
    #####################

    def access_control(rule_name, info)
		# Get to access controls and check for security level on firewall-general
		phSection = ""
		if self.firewallpage(rule_name, 'general') == true
			# Check if firewall is on Maximum Security (High)
			@ff.radio(:id, 'sec_level_3').checked? == true ? maxSec = 1 : maxSec = 0
			if self.firewallpage(rule_name, 'access control') == false
				return
			end
		else
			return
		end
		# Add a rule and check for the Action key. Default is to block. 
		if info.has_key?('action')
			if info['action'] == 'block'
				@ff.link(:href, 'javascript:mimic_button(\'add: 0%5F..\', 1)').click
				phSection = "Access Control - Block"
			elsif info['action'] == 'allow'
				if maxSec == 1
					@ff.link(:href, 'javascript:mimic_button(\'add: 1%5F..\', 1)').click
					phSection = "Access Control - Allow"
				else
					self.msg(rule_name, :error, 'Access Control', 'Rule specifies to action \"Allow\" but Firewall is not set to maximum.')
					return
				end
			else
				self.msg(rule_name, :warning, 'Access Control', 'Rule contains \"Action\" variable but does not contain a valid entry. Default to blocking method.')
				phSection = "Access Control - Block"
				@ff.link(:href, 'javascript:mimic_button(\'add: 0%5F..\', 1)').click
			end
		else
			self.msg(rule_name, :warning, 'Access Control', 'No \"Action\" variable included. Default to blocking mode.')
			phSection = "Access Control - Block"
			@ff.link(:href, 'javascript:mimic_button(\'add: 0%5F..\', 1)').click
		end
		
        # choose a PC. 
		if info['device']['selection'].match(/User Defined/i)
			# User defined goes into a network object
			@ff.select_list(:id, 'sym_net_obj_src').select("User Defined")
			self.msg(rule_name, :debug, "Access Control", "Adding network object for Access Control")
			createObject(rule_name, info['device'], 'Access Control')
			self.msg(rule_name, :debug, "Access Control", "Finished adding network object")
		else
			# If it's not user defined, it doesn't matter, just select the device and move on. Verify it's in the list though: 
			if validate("sym_net_obj_src", info['device']['selection']) == FALSE
				self.msg(rule_name, :error, 'Access Control', "Unable to find host: #{info['device']['selection']}")
				return
			end
        end
		
		if info.has_key?('services')
			# Skipping a step ahead, put or make sure it is on "Show All Services" already
			availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
			if availableServices.include?('Show All Services')
				@ff.select_list(:name, 'svc_service_combo').select('Show All Services')
				availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
			end
			(info['services'].split(',')).each do |finder|
			# Services that get selected are case sensitive. 
			# Start by seeing if we're doing custom ports
				if finder.downcase == 'user defined'
					@ff.select_list(:id, 'svc_service_combo').select('User Defined')
					if info.has_key?('serviceName')
						@ff.text_field(:name, 'svc_name').set(info['serviceName'].gsub(" ", "_"))
					end
					self.add_ports(rule_name, info['ports'], phSection, 'javascript:mimic_button(\'add_server_ports: ...\', 1)')
					@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
				elsif availableServices.include?(finder)
					@ff.select_list(:id, 'svc_service_combo').select(finder)
				else
					self.msg(rule_name, :error, 'Access Control', "Unable to find port/service: " + finder)
					return
				end
			end
		else
			self.msg(rule_name, :error, 'Access Control', "No ports/services specified!")
			return
		end

		# Scheduling - by default it's Always, otherwise they can choose a schedule already done
		if info.has_key?('schedule')
			if info['schedule']['times'].include?(':')
				# Get it into the scheduler first, and then call the scheduler function
				@ff.select_list(:id, 'schdlr_rule_id').select('User Defined')
				self.scheduler(rule_name, info['schedule'])
				# Scheduler should have returned without applying the rule, so let's apply
				@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
            elsif info['schedule']['times'].match(/current/i)
                @ff.select_list(:id, 'schdlr_rule_id').select('User Defined')
                self.scheduler(rule_name, info['schedule'])
                @ff.link(:href, 'javascript:mimic_button(\'onclick=').click
			elsif info['schedule']['times'] != 'Always'
				availableTimes = @ff.select_list(:id, 'schdlr_rule_id').getAllContents
				if availableTimes.include?(info['schedule']['times'])
					@ff.select_list(:id, 'schdlr_rule_id').select(info['schedule']['times'])
				else
					self.msg(rule_name, :error, 'Access Control', "Unable to find schedule: " + info['schedule']['times'])
				end
			end
		end
		# Apply the entire rule
		@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
		# And if we got down this far, let's throw out a success message
		self.msg(rule_name, :info, 'Access Control', 'Successfully added')
		if info.has_key?('scanbuild')
			buildTest(rule_name, info, "port scan", phSection)
		end
    end

    #####################
    # Port Forwarding   #  
    #####################

    # Separate function to input the actual data into the port forwarding fields
    # This is specifically for the ability to enter multiple ports to one specified protocol so we
    # don't have to change the JSON files to conform to the new format.
    def pf_set(ip, protocol, ports, ftp=nil, wan=nil, schedule=nil)
        # Reset settings first since it doesn't clear the settings after each port forwarding rule applied. GUI bug?
        @ff.link(:text, "Reset").click
        # Determine ahead of time if we need to use advanced settings
        if ftp == nil && wan == nil && schedule == nil && ports.match(/,/) == nil
            on_advanced = FALSE
            # Click to Basic
            @ff.link(:text, "Basic <<").click if @ff.link(:text, "Basic <<").exists?
        else
            on_advanced = TRUE
            # Click to Advanced
            @ff.link(:text, "Advanced >>").click if @ff.link(:text, "Advanced >>").exists?
        end

        # Set IP
        if ip.match(/specify/i)
            self.msg("Port forwarding set", :debug, "Port Forwarding", "Setting to user defined IP: #{ip.delete('^[0-9.]')}")
            @ff.select_list(:id, "local_host_list").select_value("specify")
            @ff.text_field(:name, "Specify_ip").set(ip.delete('^[0-9.]'))
        else
            self.msg("Port forwarding set", :debug, "Port Forwarding", "Unspecified IP: #{ip}")
            if validate("local_host_list", ip) == FALSE
                self.msg("Port forwarding set", :error, 'Port Forwarding', "Host not found: #{ip}")
                return false
            end
        end

        # If protocol == nil then choose the service from the list and don't use custom
        if protocol == nil
            if validate("svc_service_combo", ports) == FALSE
                self.msg("Port forwarding set", :error, "Port forwarding: #{ports}", "Unable to find service specified.")
                return false
            else
                @ff.link(:text, "Apply").click
                self.msg("Port forwarding set", :warning, "Port forwarding: #{ports}", "Received an overlapping port error for this port list; Applied anyway.") if @ff.text.include?("Attention")
                @ff.link(:text, "Apply").click if @ff.text.include?("Attention")
                return true
            end
        else
            # Set ports to Custom
            @ff.select_list(:id, "svc_service_combo").select_value("USER_DEFINED")
            @ff.select_list(:id, "svc_entry_protocol").select("TCP") if protocol.match(/tcp/i)
            @ff.select_list(:id, "svc_entry_protocol").select("UDP") if protocol.match(/udp/i)
            @ff.select_list(:id, "svc_entry_protocol").select("Both") if protocol.match(/both/i)

            unless on_advanced
                # Set port numbers for basic settings
                @ff.text_field(:name, "port_range").set(ports.delete('^[0-9,\-]'))
            else
                if ports.include?(":")
                    unless ports.split(':')[0].match(/any/i)
                        @ff.select_list(:id, "combo_src_ports").select("Specify")
                        @ff.text_field(:name, "edit_src_ports").set(ports.split(':')[0])
                    else
                        @ff.select_list(:id, "combo_src_ports").select("Any")
                    end
                    unless ports.split(':')[1].match(/any/i)
                        @ff.select_list(:id, "combo_dst_ports").select("Specify")
                        @ff.text_field(:name, "edit_dst_ports").set(ports.split(':')[1])
                    else
                        @ff.select_list(:id, "combo_dst_ports").select("Any")
                    end
                else
                    @ff.select_list(:id, "combo_dst_ports").select("Specify")
                    @ff.text_field(:name, "edit_dst_ports").set(ports)
                end
            end
        end

        # Other advanced settings
        if on_advanced
            # WAN Device
            if validate("wan_device", wan) == FALSE
                self.msg("Port forwarding set", :error, "Port forward WAN device #{wan}", "WAN device not found.")
                return false
            end unless wan == nil

            # Forward to port
            unless ftp == nil
                # This is a firewatir bug, and is fixed in trunk, but for 1.6.2 we need to use select('text')
                @ff.select_list(:id, 'fwd_port_combo').select('Specify')
                @ff.text_field(:name, 'fwd_port').set(ftp)
            end

            # Scheduling
            unless schedule == nil
                unless schedule['times'] == "Always"
                    if validate("schdlr_rule_id", schedule['times']) == FALSE
                        self.msg("Port forwarding set", :error, 'Port Forwarding - Schedule', "Unable to find schedule: #{schedule['times']}")
                        return false
                    end
                else
                    # Get it into the scheduler first, and then call the scheduler function
                    @ff.select_list(:id, 'schdlr_rule_id').select('User Defined')
                    self.scheduler("Port forwarding set", schedule)
                    # Scheduler should have returned without applying the rule, so let's apply
                    @ff.link(:href, 'javascript:mimic_button(\'onclick=').click
                end
            end
        end

        # Apply settings
        @ff.link(:text, "Add").click
        self.msg("Port forwarding set", :warning, "Port forwarding: #{ports}", "Received an overlapping port error for this port list; Applied anyway.") if @ff.text.include?("Attention")
        @ff.link(:text, "Apply").click if @ff.text.include?("Attention")
        return true
    end
    
	def port_forwarding(rule_name, info)
		# Get to firewall page and then port forwarding
		return if self.firewallpage(rule_name, 'port forwarding') == false
        # Use the new port forwarding method if the version is > 20.9.0, otherwise use the old version.
        if @dut_information["Firmware Version"].gsub(/\.(?!\d+\z)/,'').to_f > 209.0
            # Begin new port forwarding code
            # Setup variables
            tip, tprot, tports, tftp, twan, tschedule = nil
            f_list = []
            no_source_list_tcp = ""
            no_source_list_udp = ""
            no_source_list_both = ""
            # Set the IP address
            if info.has_key?('host')
                tip = info['host']
                self.msg(rule_name, :debug, "Port Forwarding", "Forwarding IP - passing: #{tip} ; original #{info['host']}")
            else
                self.msg(rule_name, :error, 'Port Forwarding', "No host specified!")
                return
            end
            if info.has_key?('services')
                f_list = info['services'].split(',')
                if info['services'].match(/user defined/i)
                    info['ports'].split(';').each do |tp|
                        if tp.match(/\d+,\d+/)
                            # Source ports specified
                            f_list << "#{tp.split(':')[0].upcase};#{tp.delete('^[anyANY0-9,\-]').split(',')[0]}:#{tp.delete('^[anyANY0-9,\-]').split(',')[1]}"
                            @portScanList_inbound['tcp_ports'] << "#{tp.delete('^[anyANY0-9,\-]').split(',')[0]}:#{tp.delete('^[anyANY0-9,\-]').split(',')[1]}," if tp.match(/tcp|both/i)
                            @portScanList_inbound['udp_ports'] << "#{tp.delete('^[anyANY0-9,\-]').split(',')[0]}:#{tp.delete('^[anyANY0-9,\-]').split(',')[1]}," if tp.match(/udp|both/i)
                        else
                            # No source ports specified
                            no_source_list_tcp << tp.split(',')[1].delete('^[0-9\-]') + "," if tp.match(/tcp/i)
                            no_source_list_udp << tp.split(',')[1].delete('^[0-9\-]') + "," if tp.match(/udp/i)
                            no_source_list_both << tp.split(',')[1].delete('^[0-9\-]') + "," if tp.match(/both/i)
                            @portScanList_inbound['tcp_ports'] << "any:#{tp.delete('^[anyANY0-9,\-]').split(',')[1]}," if tp.match(/tcp|both/i)
                            @portScanList_inbound['udp_ports'] << "any:#{tp.delete('^[anyANY0-9,\-]').split(',')[1]}," if tp.match(/udp|both/i)
                        end
                    end
                    no_source_list_tcp.sub!(/,\z/,'')
                    no_source_list_udp.sub!(/,\z/,'')
                    no_source_list_both.sub!(/,\z/,'')
                end
            else
                self.msg(rule_name, :error, 'Port Forwarding', "No ports/services specified!")
                return
            end
            tftp = info['ForwardTo'] if info.has_key?('ForwardTo')
            twan = info['WANtype'] if info.has_key?('WANtype')
            tschedule = info['schedule'] if info.has_key?('schedule')
            puts f_list.inspect
            f_list.each do |f|
                if f.match(/user defined/i)
                    return unless pf_set(tip, "TCP", no_source_list_tcp, tftp, twan, tschedule) unless no_source_list_tcp.empty?
                    return unless pf_set(tip, "UDP", no_source_list_udp, tftp, twan, tschedule) unless no_source_list_udp.empty?
                    return unless pf_set(tip, "Both", no_source_list_both, tftp, twan, tschedule) unless no_source_list_both.empty?
                else
                    if f.include?(";")
                        return if pf_set(tip, f.split(';')[0], f.split(';')[1], tftp, twan, tschedule) == false
                    else
                        return if pf_set(tip, nil, f.strip, tftp, twan, tschedule) == false
                    end
                end
                # pf_set(ip, protocol, ports, ftp, wan, schedule)

            end
            
            self.msg(rule_name, :warning, "Port Forwarding - Unresolved", "Some rules came back as not being resolved. This may potentially be a bug or just a misconfiguration.") unless resolved(rule_name)
            buildTest(rule_name, info, "iperf", "Port Forwarding") if info.has_key?('scanbuild')
            buildTest(rule_name, info, "port scan", "Port Forwarding") if info.has_key?('scanbuild')
            # End new port forwarding code
        else 
            # Begin old port forwarding code for older builds.
            # Click add
            @ff.link(:href, 'javascript:mimic_button(\'add: 0%5F..\', 1)').click
            # Set specify public ip if it's included
            if info.has_key?('publicIP')
                publicIP = info['publicIP'].split('.')
                @ff.checkbox(:id, 'specify_public_ip_').click
                @ff.text_field(:name, 'public_ip0').set(publicIP[0])
                @ff.text_field(:name, 'public_ip1').set(publicIP[1])
                @ff.text_field(:name, 'public_ip2').set(publicIP[2])
                @ff.text_field(:name, 'public_ip3').set(publicIP[3])
            end

            # Setup hostname/host ip address
            if info.has_key?('host')
                if info['host'].include?('specify')
                    tempIP = info['host'].split(':')
                    ipAddress = tempIP[1].strip
                    @ff.select_list(:id, 'local_host_list').set('Specify Address')
                    @ff.text_field(:name, 'local_host').set(ipAddress)
                else
                    verifyList = @ff.select_list(:id, 'local_host_list').getAllContents
                    if verifyList.include?(info['host'])
                        @ff.select_list(:id, 'local_host_list').set(info['host'])
                    else
                        self.msg(rule_name, :error, 'Port Forwarding', "Host not found: " + info['host'])
                        return
                    end
                end
            else
                self.msg(rule_name, :error, 'Port Forwarding', "No host specified!")
                return
            end

            # Start port/service entries
            if info.has_key?('services')
                availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
                if availableServices.include?('Show All Services')
                    @ff.select_list(:name, 'svc_service_combo').select('Show All Services')
                    availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
                end
                (info['services'].split(',')).each do |finder|
                    # Services that get selected are case sensitive.
                    # Start by seeing if we're doing custom ports
                    if finder.downcase == 'user defined'
                        @ff.select_list(:id, 'svc_service_combo').select('User Defined')
                        if info.has_key?('serviceName')
                            @ff.text_field(:name, 'svc_name').set(info['serviceName'])
                        end
                        self.add_ports(rule_name, info['ports'], 'Port Forwarding', 'javascript:mimic_button(\'add_server_ports: ...\', 1)')
                        @ff.link(:href, 'javascript:mimic_button(\'onclick=').click
                    elsif availableServices.include?(finder)
                        @ff.select_list(:id, 'svc_service_combo').select(finder)
                    else
                        self.msg(rule_name, :error, 'Port Forwarding', "Unable to find port/service: " + finder)
                        return
                    end
                end
            else
                self.msg(rule_name, :error, 'Port Forwarding', "No ports/services specified!")
                return
            end

            # WAN Connection type
            if info.has_key?('WANtype')
                wantypes = @ff.select_list(:id, 'wan_device').getAllContents
                if wantypes.include?(info['WANtype'])
                    puts info['WANtype']
                    # @ff.select(:id, 'wan_device').set(info['WANtype'])
                    # This is a firewatir bug, and is fixed in trunk, but for 1.6.2 we need to use select('text')
                    @ff.select_list(:id, 'wan_device').select(info['WANtype'])
                else
                    self.msg(rule_name, :error, 'Port Forwarding', "Unable to find WAN Connection Type specified: "+info['WANtype'])
                    return
                end
            end

            # Forward to port
            if info.has_key?('ForwardTo')
                # This is a firewatir bug, and is fixed in trunk, but for 1.6.2 we need to use select('text')
                @ff.select_list(:id, 'fwd_port_combo').select('Specify')
                @ff.text_field(:name, 'fwd_port').set(info['ForwardTo'])
            end

            # Scheduling - by default it's Always, otherwise they can choose a schedule already done
            if info.has_key?('schedule')
                if info['schedule']['times'].include?(':')
                    # Get it into the scheduler first, and then call the scheduler function
                    @ff.select_list(:id, 'schdlr_rule_id').select('User Defined')
                    self.scheduler(rule_name, info['schedule'])
                    # Scheduler should have returned without applying the rule, so let's apply
                    @ff.link(:href, 'javascript:mimic_button(\'onclick=').click
                elsif info['schedule']['time'] != 'Always'
                    availableTimes = @ff.select_list(:id, 'schdlr_rule_id').getAllContents
                    if availableTimes.include?(info['schedule']['times'])
                        @ff.select_list(:id, 'schdlr_rule_id').select(info['schedule']['times'])
                    else
                        self.msg(rule_name, :error, 'Port Forwarding', "Unable to find schedule: " + info['schedule']['times'])
                    end
                end
            end
            # Apply the entire rule
            @ff.link(:href, 'javascript:mimic_button(\'onclick=').click
            # And if we got down this far, let's throw out a success message
            self.msg(rule_name, :info, 'Port Forwarding', 'Successfully added')
            self.msg(rule_name, :warning, "Port Forwarding", "Some rules came back as not being resolved. This may potentially be a bug or just a misconfiguration.") unless resolved(rule_name)
            buildTest(rule_name, info, "port scan", "Port Forwarding") if info.has_key?('scanbuild')
        end
        # End old port forwarding code
	end
	
    #####################
    # DMZ Hosting       #  
    #####################
	
	def dmz_host(rule_name, info)
		# Firewall settings, then DMZ hosting
		return if self.firewallpage(rule_name, 'dmz host') == false
		# Quick and easy. Make sure we know if it's going on or off, and that an ip is present if on
		if info.has_key?('action')
			if info['action']=='on'
				# find out if it's already on
				if @ff.checkbox(:id, 'dmz_host_cb_').checked? == true
					self.msg(rule_name, :warning, 'DMZ Host', "DMZ Host is already turned on.")
					dmzhost = 1
				else
					@ff.checkbox(:id, 'dmz_host_cb_').click
				end
			else
				# find out if it's already off
				if @ff.checkbox(:id, 'dmz_host_cb_').checked? == false
					self.msg(rule_name, :warning, 'DMZ Host', "DMZ Host is already turned off.")
					if info.has_key?('scanbuild')
						buildTest(rule_name, info, "port scan", "DMZ Host")
					end
					return
				else
					@ff.checkbox(:id, 'dmz_host_cb_').clear
					if info.has_key?('scanbuild')
						buildTest(rule_name, info, "port scan", "DMZ Host")
					end
					return
				end
			end
			if info.has_key?('ip')
				if dmzhost == 1
					self.msg(rule_name, :warning, 'DMZ Host', "DMZ already on, but changing IP address anyway.")
				end
				ipaddress = info['ip'].split('.')
				@ff.text_field(:name, 'dmz_host_ip0').set(ipaddress[0])
				@ff.text_field(:name, 'dmz_host_ip1').set(ipaddress[1])
				@ff.text_field(:name, 'dmz_host_ip2').set(ipaddress[2])
				@ff.text_field(:name, 'dmz_host_ip3').set(ipaddress[3])
			else
				self.msg(rule_name, :error, 'DMZ Host', "No IP specified for DMZ hosting!")
				return
			end
			# Apply rule
			@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
		else
			self.msg(rule_name, :error, 'DMZ Host', "No action specified for DMZ Hosting.")
			return
		end
		if info.has_key?('scanbuild')
			buildTest(rule_name, info, "port scan", "DMZ Host")
		end
	end
	
    #####################
    # Port Triggering   #  
    #####################
    
	def port_triggering(rule_name, info)
		# Get to firewall page and then port triggering
		return if self.firewallpage(rule_name, 'port triggering') == false
		# Put selection on show all services. Gather the list then input the items
		availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
		if availableServices.include?('Show All Services')
			@ff.select_list(:name, 'svc_service_combo').select('Show All Services')
			availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
		end
		if info.has_key?('services')
			(info['services'].split(',')).each do |service|
				if service.downcase == 'user defined'
					@ff.select_list(:name, 'svc_service_combo').select('User Defined')
					@ff.text_field(:name, 'svc_name').set(info['servicename'])
					# Jump to the port helper for both outgoing and incoming
					setRules = 0
					if info.has_key?('outgoing')
						setRules = 1
                        self.msg(rule_name, :info, "Port Triggering - Outbound", "Adding outbound trigger ports #{info['outgoing']}")
						self.add_ports(rule_name, info['outgoing'], 'Port Triggering Outbound', 'javascript:mimic_button(\'add_trigger_ports: ...\', 1)')
					end
					if info.has_key?('incoming')
						setRules = 1
                        self.msg(rule_name, :info, "Port Triggering - Inbound", "Adding inbound trigger ports #{info['incoming']}")
						self.add_ports(rule_name, info['incoming'], 'Port Triggering Inbound', 'javascript:mimic_button(\'add_opened_ports: ...\', 1)')
					end
					if setRules == 0 
						self.msg(rule_name, :error, 'Port Triggering', "User Defined option specified, but no incoming or outgoing ports in config.")
						return
					end
					@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
				else
					if availableServices.include?(service)
						@ff.select_list(:name, 'svc_service_combo').select(service)
					else
						self.msg(rule_name, :warning, 'Port Triggering', "Unable to find service " + service + "; Option is case sensitive.")
					end
				end
			end
		else
			self.msg(rule_name, :error, 'Port Triggering', "No services specified for this rule.")
			return
		end
        self.msg(rule_name, :info, "Port Triggering", "Success")
        if info.has_key?('scanbuild')
			buildTest(rule_name, info, "iperf", "Port Triggering")
		end
	end
	
    #####################
    # Remote Admin (FW) #  
    #####################
	
	def firewall_remote_admin(rule_name, info)
		# Firewall remote admin settings also use the function from advanced remote admin settings. 
		# So we get to the admin page and then call off to the other section under advanced.rb
        unless info.has_key?("set")
            self.msg(rule_name, :error, "Firewall Remote Administration", "Configuration missing \"set\" key. Nothing to configure.")
            return
        end
		return if self.firewallpage(rule_name, 'remote admin') == false
		self.remote_admin_helper(rule_name, info)
		# Apply when it gets back
		@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
		self.msg(rule_name, :info, "Firewall - Remote Administration", "Success")
		buildTest(rule_name, info, "remote admin", "Firewall_Remote Admin") if info.has_key?('scanbuild')
	end
	
	#####################
    # Static NAT        #  
    #####################
	
	def static_nat(rule_name, info)
		# Jump to firewall page and then static NAT
		return if self.firewallpage(rule_name, 'static nat') == false
		# click add
		@ff.link(:href, 'javascript:mimic_button(\'add: 0%5F..\', 1)').click
		
		# set local host
		if info.has_key?('host')
			if info['host'].include?('specify')
				tempIP = info['host'].split(':')
				ipAddress = tempIP[1].strip
				@ff.select_list(:id, 'local_host_list').set('Specify Address')
				@ff.text_field(:name, 'local_host').set(ipAddress)
			else
				verifyList = @ff.select_list(:id, 'local_host_list').getAllContents
				if verifyList.include?(info['host'])
					@ff.select_list(:id, 'local_host_list').set(info['host'])
				else
					self.msg(rule_name, :error, 'Static NAT', "Host not found: " + info['host'])
					return
				end
			end
		else
			self.msg(rule_name, :error, 'Static NAT', 'No local host specified; Cannot create rule.')
			return
		end

		# Set public ip, must be included. 
		if info.has_key?('publicIP')
			publicIP = info['publicIP'].split('.')
			@ff.text_field(:name, 'public_ip0').set(publicIP[0])
			@ff.text_field(:name, 'public_ip1').set(publicIP[1])
			@ff.text_field(:name, 'public_ip2').set(publicIP[2])
			@ff.text_field(:name, 'public_ip3').set(publicIP[3])
		else
			self.msg(:error, rule_name, 'Static NAT', 'No public IP specified; Cannot create rule.')
			return
		end
		
		# WAN Connection type
		if info.has_key?('WANtype')
			info['WANtype'] = "PPPoE 2" if info['WANtype'].match(/pppoe.?2/i)
			if validate("wan_device", info['WANtype']) == FALSE
				self.msg(rule_name, :error, 'Static NAT', "Unable to find WAN Connection Type specified: "+info['WANtype'])
				return
			end
		end
		
		# Port forwarding for static NAT
		if info.has_key?('services')
			@ff.checkbox(:id, 'static_nat_local_server_enabled_').click
			availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
			if availableServices.include?('Show All Services')
				@ff.select_list(:name, 'svc_service_combo').select('Show All Services')
				availableServices = @ff.select_list(:id, 'svc_service_combo').getAllContents
			end
			(info['services'].split(',')).each do |finder|
				# Services that get selected are case sensitive. 
				# Start by seeing if we're doing custom ports
				if finder.downcase == 'user defined'
					@ff.select_list(:id, 'svc_service_combo').select('User Defined')
					if info.has_key?('serviceName')
						@ff.text_field(:name, 'svc_name').set(info['serviceName'])
					end
					self.add_ports(rule_name, info['ports'], 'Static NAT', 'javascript:mimic_button(\'add_server_ports: ...\', 1)')
					# Click apply when it comes back
					@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
				elsif availableServices.include?(finder)
					@ff.select_list(:id, 'svc_service_combo').select(finder)
				else
					self.msg(rule_name, :error, 'Static NAT', "Unable to find port/service: " + finder)
					return
				end
			end
		end
		# Apply the Static NAT rule
		@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
	end
	
	#####################
    # Advanced Filtering#  
    #####################
#{
#	"rulename": {
#		"section": "firewall-advanced filtering-input|output",
#		"device": "network (home/office)",
#		"source": "",
#		"destination": "",
#		"services": "User Defined",
#		"ports": "",
#		"set": "-dscp ##:## -priority # -packet|data_length ##:## -drop|accept_connection|accept_packet|reject -log on",
#		"schedule": {
#
#		},
#		"scanbuild": "on"
#	}
#}

	def advanced_filtering_helper(rule_name, info)
		# Add Source/Dest PCs. Notice we don't need to change these at all if they aren't present.
        # Source
		if info['source'].is_a?(Hash)
            @ff.select_list(:id, 'sym_net_obj_src').select("User Defined")
            createObject(rule_name, info['source'], "Advanced Filtering")
        else
            if validate("sym_net_obj_src", info['source'])
                self.msg(rule_name, :error, "Advanced Filtering", "Unable to find source object #{info['source']}")
                return false
            end
        end if info.has_key?('source')

		# Destination
		if info['destination'].is_a?(Hash)
            @ff.select_list(:id, 'sym_net_obj_dst').select("User Defined")
            createObject(rule_name, info['destination'], "Advanced Filtering")
        else
            if validate("sym_net_obj_dst", info['destination'])
                self.msg(rule_name, :error, "Advanced Filtering", "Unable to find destination object #{info['destination']}")
                return false
            end
        end if info.has_key?('destination')

		# Services
		info['services'].split(',').each do |svc|
            if svc.match(/user defined/i)
                @ff.select_list(:id, 'svc_service_combo').select('User Defined')
                @ff.text_field(:name, 'svc_name').set(rule_name)
                self.add_ports(rule_name, info['ports'], 'Advanced Filtering', 'javascript:mimic_button(\'add_server_ports: ...\', 1)')
                # Click apply when it comes back
                @ff.link(:text, 'Apply').click
            else
                if validate("svc_service_combo", svc)
                    self.msg(rule_name, :error, 'Advanced Filtering', "Unable to find service named #{svc}")
                    return false
                end
            end
        end if info.has_key?('services')
#		"set": "-dscp ##:## -priority # -packet|data_length ##:## -drop|accept_connection|accept_packet|reject -log on",

        # Set operator options
		info["set"].split('-').each do |item|
            case item
            when /dscp/i
                @ff.checkbox(:id, 'dscp_check_box_').click
                @ff.text_field(:name, 'dscp_check_val').set(item.split(' ')[1].split(":")[0])
                @ff.text_field(:name, 'dscp_check_mask').set(item.split(' ')[1].split(":")[1])
            when /priority/i
                @ff.checkbox(:id, 'prio_check_box_').click
                unless validate("prio_check_combo", item.split(' ')[1])
                    self.msg(rule_name, :error, "Advanced Filtering", "Unable to find priority level #{item.split(' ')[1]}")
                    return false
                end
            when /packet|data_length/i
                @ff.checkbox(:id, "length_check_box_").click
                unless validate("length_check_type", item.split(' ')[0])
                    self.msg(rule_name, :error, "Advanced Filtering", "Unable to find length option #{item.split(' ')[0]}")
                    return false
                end
                @ff.text_field(:name, 'length_check_from').set(item.split(' ')[1].split(":")[0])
                @ff.text_field(:name, 'length_check_to').set(item.split(' ')[1].split(":")[1])
            when /drop|accept_connection|accept_packet|reject/i
                unless validate("rule_operation", item.strip)
                    self.msg(rule_name, :error, "Advanced Filtering", "Unable to find operation: #{item.strip}")
                    return false
                end
            when /log/i
                @ff.checkbox(:id, 'rule_log_').click
            end
        end if info.has_key?("set")

		# Schedule the rule
		if info['schedule'].is_a?(Hash)
            # Get it into the scheduler first, and then call the scheduler function
            @ff.select_list(:id, 'schdlr_rule_id').select('User Defined')
            self.scheduler(rule_name, info['schedule'])
            # Scheduler should have returned without applying the rule, so let's apply
            @ff.link(:text, 'Apply').click
        else
            unless validate("schdlr_rule_id", info['schedule'])
                self.msg(rule_name, :error, 'Advanced Filtering', "Unable to find schedule: " + info['schedule']['times'])
                return false
            end
        end if info.has_key?('schedule')
        
		# Apply
		@ff.link(:text, 'Apply').click
		# This is the secondary apply in case you're blocking everything (intentionally, we hope) or changing the DHCP pool
		@ff.link(:text, 'Apply').click if @ff.contains_text('Press Apply to confirm')
        return true
	end

	def advanced_filtering(rule_name, info)
        unless info['section'].match(/out|in/i)
            self.msg(rule_name, :error, "Advanced Filtering", "\"Section\" must include whether rule is Input or Output type.")
            return
        end
        unless info.has_key?('device')
            self.msg(rule_name, :error, "Advanced Filtering", "No defined network device to add a rule to.")
            return
        end
        return unless self.firewallpage(rule_name, "Advanced Filtering")

        # Containers for input/output rules
        valid_input_rules = get_rule_set(2, 3)
        valid_output_rules = get_rule_set(3, 4)

        # Base link for "Add"
        add_link = "javascript:mimic_button('add: #%5F..', 1)"

        if info['section'].match(/input/i)
            value_index = valid_input_rules.index(valid_input_rules.select {|x| x.downcase.include?(info['device'].downcase)}.to_s)
        elsif info['section'].match(/output/i)
            value_index = valid_output_rules.index(valid_input_rules.select {|x| x.downcase.include?(info['device'].downcase)}.to_s)
        end

        if value_index.nil?
            self.msg(rule_name, :error, "Advanced Filtering", "No defined network device available named #{info['device']}")
            return
        end

        add_link.sub!("#", "#{value_index}")

        # Click Add for the current rule
        @ff.link(:href, add_link).click
        # And now call the helper
        self.msg(rule_name, :info, "Advanced Filtering", "Successfully added") if advanced_filtering_helper(rule_name, info)
	end
end