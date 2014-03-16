# We can do quite a bit here if we clean the code up. There's things we no longer need
# because they are handled in other places. For instance, the scheduler, and the user 
# defined port adding. Marking this for clean up in the future. 

module Advanced
	def adv_jumper(rule_name, info)
		case info['section']
		when /qos|qual.*serv.*/i
			self.qos(rule_name, info)
		when /reboot/i
			self.reboot(rule_name, info)
		when /remote.*admin/i
			self.advanced_remote_admin(rule_name, info)
		when /local.admin/i
			self.local_admin(rule_name, info)
		when /static.nat/i
			self.static_nat(rule_name, info)
		when /ip.*distribution/i
			self.ipdistribution(rule_name, info)
		when /net.*object/i
			self.network_object(rule_name, info)
		when /diag.*/i
			self.diagnostics(rule_name, info)
		when /restore.*def.*/i
			self.restore_defaults(rule_name, info)
		when /mac.*clon.*/i
			self.mac_cloning(rule_name, info)
		when /arp.*table/i
			self.arp_table(rule_name, info)
		when /users/i
			self.users(rule_name, info)
		when /dyn.*dns/i
			self.dynDNS(rule_name, info)
		when /dns server/i
			self.dns_server(rule_name, info)
		when /network.*obj.*/
			self.network_objects(rule_name, info)
		when /upnp/i
			self.upnp(rule_name, info)
		when /sip/i
			self.sipALG(rule_name, info)
		when /mgcp/i
			self.mgcpALG(rule_name, info)
		when /proto/i
			self.protocols(rule_name, info)
		when /config.*file/i
			self.configuration_file(rule_name, info)
		when /system.*set/i
			self.system_settings(rule_name, info)
		when /port.*config/i
			self.port_configuration(rule_name, info)
		when /date|time/i
			self.date_and_time(rule_name, info)
		when /sched.*/i
			self.scheduler(rule_name, info)
		when /firm.*/i
            self.firmware(rule_name, info)
		when /routing/
			self.routing(rule_name, info)
		end
	end

    #
    # igmp
    # FixMe: Didn't write this, but it's ugly, broken, and ...
    # Not even sure why this is here. BHR2 doesn't have IGMP proxy under Advanced. 
	#  - IGMP now available in recent firmware versions under Advanced.
    def igmp(rule_name, info)

        # get to the advanced page
		if self.advancedpage(rule_name, 'igmp proxy') == false
			return
		end
        # and the igmp proxy page
        @ff.link(:text, 'IGMP Proxy').click
        
        case info['action']
        when 'set'
            
            # Enabled/Disabled
            if info.has_key?('proxy')
                case info['proxy'].downcase
                when 'enabled'
                    @ff.select_list(:id, 'sym_igmp_proxy_config').select_value('1')
                    self.msg(rule_name, :info, 'igmp_proxy', 'Enabled')
                when 'disabled'
                    @ff.select_list(:id, 'sym_igmp_proxy_config').select_value('0')
                    self.msg(rule_name, :info, 'igmp_proxy', 'Disabled')
                else
                    self.msg(rule_name, :error, 'igmp proxy', 'unknown option')
                    return
                end
            end

            # IGMPv1, IGMPv2 or IGMPv3
            if info.has_key?('version')
                case info['version']
                when 'IGMPv1'
                    @ff.select_list(:id, 'sym_igmp_proxy_qcm').select_value("1")
                    self.msg(rule_name, :info, 'igmp_version', 'IGMPv1')
                when 'IGMPv2'
                    @ff.select_list(:id, 'sym_igmp_proxy_qcm').select_value("2")
                    self.msg(rule_name, :info, 'igmp_version', 'IGMPv2')
                when 'IGMPv3'
                    @f.select_list(:id, 'sym_igmp_proxy_qcm').select_value("3")
                    self.msg(rule_name, :info, 'igmp_version', 'IGMPv3')
                else
                    self.msg(rule_name, :error, 'igmp_version', 'unknown version')
                end
            end
            
            # upstream and downstream routes have somewhat different info
            # no easy way to combine code
            if info.has_key?('upstream')
                u = info['upstream']
                if u.has_key?('add')
                    u['add'].each do |route|

                        @re_int_route =~ route.to_s
                        match = Regexp.last_match
                        
                        # we've got multiple links with 'New Multicast Address'
                        # on this page - fine the innermost upstream table
                        found = false
                        @ff.tables.each do |t|
                            if t.text.include? 'Upstream Multicast Filtering'
                                found = t
                            end
                        end
                        found.link(:text, 'New Multicast Address').click

                        # add the route
                        begin
                            @ff.select_list(:id, 'sym_upstream_mcf_intf').select_value(match[1])
                        rescue
                            self.msg(rule_name, :error, 'igmp-upstream', 'could not set interface name')
                            return
                        end
                        
                        # address
                        @ff.text_field(:name, 'sym_upstream_mcf_addr0').set(match[2])
                        @ff.text_field(:name, 'sym_upstream_mcf_addr1').set(match[3])
                        @ff.text_field(:name, 'sym_upstream_mcf_addr2').set(match[4])
                        @ff.text_field(:name, 'sym_upstream_mcf_addr3').set(match[5])

                        # mask
                        @ff.text_field(:name, 'sym_upstream_mcf_mask0').set(match[6])
                        @ff.text_field(:name, 'sym_upstream_mcf_mask1').set(match[7])
                        @ff.text_field(:name, 'sym_upstream_mcf_mask2').set(match[8])
                        @ff.text_field(:name, 'sym_upstream_mcf_mask3').set(match[9])
                        
                        @ff.link(:text, 'Apply').click

                        # look for the error page. if found, log it and back out
                        if @ff.text.include? 'Input Errors'
                            self.msg(rule_name, :error, 'igmp-route '+route.to_s, 'did not add route')
                            @ff.link(:text, 'Cancel').click
                            @ff.link(:text, 'Cancel').click
                        end
                    end
                end
                
                if u.has_key?('remove')
                    u['remove'].each do |route|

                        @re_int_route =~ route.to_s
                        match = Regexp.last_match
                        
                        # we've got multiple links with 'New Multicast Address'
                        # on this page - fine the innermost upstream table
                        found = false
                        @ff.tables.each do |t|
                            if t.text.include? 'Upstream Multicast Filtering'
                                found = t
                            end
                        end
                        
                        # on the correct table, find the right row
                        int_info = route[0].split(':')
                        route_info = int_info[1].split('/')
                        found.each do |row|
                            
                            # this needs to be expanded as new interfaces are discovered
                            case int_info[0]
                            when 'eth1'
                                long_int = 'Broadband Ethernet'
                            when 'clink1'
                                long_int = 'Broadband Coax'
                            when 'ppp1'
                                long_int = 'WAN PPPoE (over Coax)'
                            else
                                self.msg(rule_name, :error, 'upstream-remove', 'unknown interface: '+ data['interface'].to_s)
                                return
                            end
                            
                            # make sure the route info matches and then remove it
                            if row[1].to_s == long_int and row[2].to_s == route_info[0] and row[3].to_s == route_info[1]
                                row.link(:title, 'Remove').click
                            end
                        end
                    end
                end
            end
            
            if info.has_key?('downstream')
                d = info['downstream']
                if d.has_key?('add')
                    d['add'].each do |route, data|
                        if not data.has_key?('host')
                            self.msg(rule_name, :error, 'igmp-downstream', 'No valid host/mask found')
                            return
                        end
                        @re_int_route =~ route.to_s
                        match = Regexp.last_match
                        
                        @re_route =~ data['host']
                        hmatch = Regexp.last_match
                        
                        # we've got multiple links with 'New Multicast Address'
                        # on this page - fine the innermost downstream table
                        found = false
                        @ff.tables.each do |t|
                            if t.text.include? 'Downstream Multicast Filtering'
                                found = t
                            end
                        end
                        found.link(:text, 'New Multicast Address').click

                        # add the route
                        begin
                            @ff.select_list(:id, 'sym_downstream_mcf_intf').select_value(match[1])
                        rescue
                            self.msg(rule_name, :error, 'igmp-downstream', 'could not set interface name')
                            return
                        end
                        
                        # address
                        @ff.text_field(:name, 'sym_downstream_mcf_mcaddr0').set(match[2])
                        @ff.text_field(:name, 'sym_downstream_mcf_mcaddr1').set(match[3])
                        @ff.text_field(:name, 'sym_downstream_mcf_mcaddr2').set(match[4])
                        @ff.text_field(:name, 'sym_downstream_mcf_mcaddr3').set(match[5])

                        # mask
                        @ff.text_field(:name, 'sym_downstream_mcf_mcmask0').set(match[6])
                        @ff.text_field(:name, 'sym_downstream_mcf_mcmask1').set(match[7])
                        @ff.text_field(:name, 'sym_downstream_mcf_mcmask2').set(match[8])
                        @ff.text_field(:name, 'sym_downstream_mcf_mcmask3').set(match[9])
                        
                        # host
                        @ff.text_field(:name, 'sym_downstream_mcf_hostaddr0').set(hmatch[1])
                        @ff.text_field(:name, 'sym_downstream_mcf_hostaddr1').set(hmatch[2])
                        @ff.text_field(:name, 'sym_downstream_mcf_hostaddr2').set(hmatch[3])
                        @ff.text_field(:name, 'sym_downstream_mcf_hostaddr3').set(hmatch[4])

                        # host mask
                        @ff.text_field(:name, 'sym_downstream_mcf_hostmask0').set(hmatch[5])
                        @ff.text_field(:name, 'sym_downstream_mcf_hostmask1').set(hmatch[6])
                        @ff.text_field(:name, 'sym_downstream_mcf_hostmask2').set(hmatch[7])
                        @ff.text_field(:name, 'sym_downstream_mcf_hostmask3').set(hmatch[8])
                        
                        @ff.link(:text, 'Apply').click

                        # look for the error page. if found, log it and back out
                        if @ff.text.include? 'Input Errors'
                            self.msg(rule_name, :error, 'igmp-route '+route.to_s, 'did not add route')
                            @ff.link(:text, 'Cancel').click
                            @ff.link(:text, 'Cancel').click
                        end
                    end
                end
                
                if d.has_key?('remove')
                    d['remove'].each do |route, data|

                        @re_int_route =~ route.to_s
                        match = Regexp.last_match

                        if not data.has_key?('host')
                            self.msg(rule_name, :error, 'igmp-downstream', 'No valid host/mask found')
                            return
                        end
                        @re_route =~ data['host']
                        hmatch = Regexp.last_match
                        
                        # we've got multiple links with 'New Multicast Address'
                        # on this page - fine the innermost downstream table
                        found = false
                        @ff.tables.each do |t|
                            if t.text.include? 'Downstream Multicast Filtering'
                                found = t
                            end
                        end

                        # on the correct table, find the right row
                        int_info = route.split(':')
                        route_info = int_info[1].split('/')
                        host_info = data['host'].split('/')

                        found.each do |row|

                            # this needs to be expanded as new interfaces are discovered
                            case int_info[0]
                            when 'eth0-1'
                                long_int = 'LAN Ethernet 1'
                            when 'eth0-2'
                                long_int = 'LAN Ethernet 2'
                            when 'eth0-3'
                                long_int = 'LAN Ethernet 3'
                            when 'eth0-4'
                                long_int = 'LAN Ethernet 4'
                            when 'clink0'
                                long_int = 'LAN Coax'
                            else
                                self.msg(rule_name, :error, 'downstream-remove', 'unknown interface: '+ data['interface'].to_s)
                                return
                            end

                            # make sure the route info matches and then remove it
                            if row[1].to_s == long_int and \
                               row[2].to_s == route_info[0] and row[3].to_s == route_info[1] and \
                               row[4].to_s = host_info[0] and row[5].to_s == host_info[1]
                                row.link(:title, 'Remove').click
                            end
                        end
                    end
                end
            end
            
            # save things
            @ff.link(:text, 'Apply').click
            
        when 'get'
            
            out = {'action' => 'get', 'section' => 'igmp'}

            # turned on and version info?
            out['proxy'] = @ff.select_list(:id, 'sym_igmp_proxy_config').getSelectedItems[0]
            out['version'] = @ff.select_list(:id, 'sym_igmp_proxy_qcm').getSelectedItems[0]

            upstream = false
            downstream = false
            @ff.tables.each do |t|
                if t.text.include? 'Upstream Multicast Filtering'
                    upstream = t
                end
                if t.text.include? 'Downstream Multicast Filtering'
                    downstream = t
                end
            end

            # grab the upstream routes
            out['upstream'] = { 'add' => {} }
            upstream.each do |row|
                if row.link(:title, 'Edit').exists?
                    case row[1].text
                    when 'Broadband Ethernet'
                        int_name = 'eth1'
                    when 'Broadband Coax'
                        int_name = 'clink1'
                    when 'WAN PPPoE (over Coax)'
                        int_name =  'ppp1'
                    else
                        self.msg(rule_name, :error, 'igmp-get', 'bad upstream interface found - ' + row[1].text)
                        return
                    end
                    route_name = int_name + ':' + row[2].text + '/' + row[3].text
                    out['upstream']['add'][route_name] = 'unused value'
                end
            end

            # grab the downstream routes
            out['downstream'] = { 'add' => {} }
            downstream.each do |row|
                if row.link(:title, 'Edit').exists?
                    case row[1].text
                    when 'LAN Coax'
                        int_name = 'clink0'
                    when 'LAN Ethernet 1'
                        int_name = 'eth0-1'
                    when 'LAN Ethernet 2'
                        int_name = 'eth0-2'
                    when 'LAN Ethernet 3'
                        int_name = 'eth0-3'
                    when 'LAN Ethernet 4'
                        int_name = 'eth0-4'
                    else
                        self.msg(rule_name, :error, 'igmp-get', 'bad downstream interface found - ' + row[1].text)
                        return
                    end
                    route_name = int_name + ':' + row[2].text + '/' + row[3].text
                    host_name = row[4].text + '/' + row[5].text
                    out['downstream']['add'][route_name] = { 'host', host_name}
                end
            end
            
            @out[rule_name] = out
        else
            self.msg(rule_name, :error, 'igmp-action', 'unknown/missing action')
            return
        end	
    end
    #
    # reboot the router
    #
    def reboot(rule_name, info)
        
        # need the advanced page
        return if self.advancedpage(rule_name, 'reboot router') == false
        
        @ff.link(:text, 'Reboot Router').click
        
        unless @ff.text.include? 'Are you sure you want to reboot'
            self.msg(rule_name, :error, 'reboot', 'Did not find confirmation page')
            return
        end
        
        @ff.link(:text, 'OK').click
        self.msg(rule_name, :info, 'reboot', 'initiated')
        sleep 50
    end
    
    ###################
    # Firmware Upgrade#
    ###################
    # FixMe: wtf...
    def firmware(rule_name, info)
    
        if not info.has_key?('filename')
            self.msg(rule_name, :error, 'firmware', 'No firmware filename specified in configuration')
            return
        end
        
        # need the advanced page
		if self.advancedpage(rule_name, 'firmware upgrade') == false
			return
		end
        # click the firmware upgrade link
        begin
            @ff.link(:text, 'Firmware Upgrade').click
        rescue
            self.msg(rule_name, :error, 'firmware', 'Did not reach firmware upgrade page')
            return
        end
        
        # and the upgrade now link
        begin
            @ff.link(:text, 'Upgrade Now').click
        rescue
            self.msg(rule_name, :error, 'firmware', 'Did not reach upgrade now page')
            return
        end
        
        # set the firmware filename
        begin
            @ff.file_field(:name, "image").set(info['filename'])
        rescue
            self.msg(rule_name, :error, 'firmware', 'Did not set firmware file name')
            return
        end
        
        # click ok
        begin
            @ff.link(:text, 'OK').click
        rescue
            self.msg(rule_name, :error, 'firmware', 'Did not click firmware OK')
            return
        end
        
        # look for the successful upload text
        if not @ff.text.include? 'Do you want to reboot?'
            self.msg(rule_name, :error, 'advanced', 'Did not reach the reboot page')
            return
        end

        # click apply
        begin
            @ff.link(:text, 'Apply').click
        rescue
            self.msg(rule_name, :error, 'firmware', 'Did not click firmware Apply')
            return
        end
        
        # check for the wait message
        if not @ff.text.include? 'system is now being upgraded'
            self.msg(rule_name, :error, 'firmware', 'Did not see upgrading marker text')
            return
        end

        # give it some time to upgrade
        sleep 60
        @ff.refresh
        @ff.wait
        count = 0

        until count > 6 or @ff.text.include? 'is up again'
            count += 1
            sleep 5
        end
        if count == 7
            self.msg(rule_name, :error, 'firmware', 'Did not see login box after firmware upgrade')
            return
        end
        
        self.msg(rule_name, :info, 'firmware', 'Firmware upgrade success')
    end 
    	
	#####################
    # Schedule Rules    #  
    #####################
	
	def scheduler(rule_name, info)
		# find out if this is from advanced, or from another function. Advanced means we need to click add first
		newBaseRule = 0
		if info.has_key?('New Schedule')
			newBaseRule = 1
			# Click to advanced if this is a new rule, then go into the scheduler and add a new rule
			self.advancedpage(rule_name, info)
			@ff.link(:href, 'javascript:mimic_button(\'goto: 1410..\', 1)').click
			@ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
		end
		if info.has_key?('name')
			@ff.text_field(:name, 'schdlr_rule_name').set(info['name'])
		end
		if info.has_key?('action')
			info['action'].downcase == 'active' ? @ff.radio(:id, 'is_enabling_0').click : @ff.radio(:id, 'is_enabling_1').click
		end
		@ff.link(:href, 'javascript:mimic_button(\'time_add: -1..\', 1)').click
		if info.has_key?('days')
			daysSet = 7
			info['days'].downcase.include?('mon') ? @ff.checkbox(:id, 'day_mon_').click : daysSet-1
			info['days'].downcase.include?('tue') ? @ff.checkbox(:id, 'day_tue_').click : daysSet-1
			info['days'].downcase.include?('wed') ? @ff.checkbox(:id, 'day_wed_').click : daysSet-1
			info['days'].downcase.include?('thu') ? @ff.checkbox(:id, 'day_thu_').click : daysSet-1
			info['days'].downcase.include?('fri') ? @ff.checkbox(:id, 'day_fri_').click : daysSet-1
			info['days'].downcase.include?('sat') ? @ff.checkbox(:id, 'day_sat_').click : daysSet-1
			info['days'].downcase.include?('sun') ? @ff.checkbox(:id, 'day_sun_').click : daysSet-1
			if daysSet == 0
				self.msg(rule_name, :error, 'Scheduler', "No days for the scheduler to set!")
				return
			end
		else
			self.msg(rule_name, :error, 'Scheduler', "No days for the scheduler to set!")
			return
		end
		# Now we need to split the times
		if info.has_key?('times')
			times = info['times'].split(',')
			times.each do |time_set|
				# Add a new time range
				@ff.link(:href, 'javascript:mimic_button(\'hours_add: -1..\', 1)').click
				if time_set.include?('-')
                    temp_time = []
                    tc = 0
                    ct = Time.now.to_i
                    time_set.split('-').each do |t|
                        if t.match(/current/i)
                            temp_time[tc] = format_time(ct+(extract_offset(t.split(' ')[1], t.split(' ')[2])), 1)
                        else
                            temp_time[tc] = t
                        end
                        tc += 1
                    end
					@ff.text_field(:name, 'start_hour').set(temp_time[0].split(':')[0])
					@ff.text_field(:name, 'start_min').set(temp_time[0].split(':')[1])
					@ff.text_field(:name, 'end_hour').set(temp_time[1].split(':')[0])
					@ff.text_field(:name, 'end_min').set(temp_time[1].split(':')[1])
					# Apply this range
					@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
				else
					self.msg(rule_name, :error, 'Scheduler', "Ranges incorrect in config, unable to set schedule.")
					return
				end
			end
			# Okay, we're done adding times. Apply them
			@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
		else
			self.msg(rule_name, :error, 'Scheduler', "No times specified!")
			return
		end
		# Apply the rule if it's new, otherwise, if being called from somewhere else, return
		newBaseRule == 1 ? @ff.link(:href, 'javascript:mimic_button(\'onclick=').click : return
	end
	
    #####################
    # Remote Admin      #  
    #####################
	
	def remote_admin_helper(rule_name, info)
        # "set" : "-primary_http on -secondary_http off -primary_https on -secondary_https off -telnet on -secondary_telnet on -secure_telnet on"
		# General construction is: If turning on or off, check if already on or off, and then toggle if necessary, or output warning that it was already done.
        @ff.checkbox(:id, 'is_telnet_primary_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'Primary Telnet already turned on') : @ff.checkbox(:id, 'is_telnet_primary_').click if info['set'].match(/primary_telnet on/i)
        @ff.checkbox(:id, 'is_telnet_primary_').checked? ? @ff.checkbox(:id, 'is_telnet_primary_').click : self.msg(rule_name, :info, "Remote Administration", 'Primary Telnet already turned off') if info['set'].match(/primary_telnet off/i)
        @ff.checkbox(:id, 'is_telnet_secondary_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'Secondary Telnet already turned on') : @ff.checkbox(:id, 'is_telnet_secondary_').click if info['set'].match(/secondary_telnet on/i)
        @ff.checkbox(:id, 'is_telnet_secondary_').checked? ? @ff.checkbox(:id, 'is_telnet_secondary_').click : self.msg(rule_name, :info, "Remote Administration", 'Secondary Telnet already turned off') if info['set'].match(/secondary_telnet off/i)
        @ff.checkbox(:id, 'is_telnet_ssl_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'Secure Telnet already turned on') : @ff.checkbox(:id, 'is_telnet_ssl_').click if info['set'].match(/secure_telnet on/i)
        @ff.checkbox(:id, 'is_telnet_ssl_').checked? ? @ff.checkbox(:id, 'is_telnet_ssl_').click : self.msg(rule_name, :info, "Remote Administration", 'Secure Telnet already turned off') if info['set'].match(/secure_telnet off/i)
        @ff.checkbox(:id, 'is_http_primary_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'Primary HTTP already turned on') : @ff.checkbox(:id, 'is_http_primary_').click if info['set'].match(/primary_http on/i)
        @ff.checkbox(:id, 'is_http_primary_').checked? ? @ff.checkbox(:id, 'is_http_primary_').click : self.msg(rule_name, :info, "Remote Administration", 'Primary HTTP already turned off') if info['set'].match(/primary_http off/i)
        @ff.checkbox(:id, 'is_http_secondary_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'Secondary HTTP already turned on') : @ff.checkbox(:id, 'is_http_secondary_').click if info['set'].match(/secondary_http_ on/i)
        @ff.checkbox(:id, 'is_http_secondary_').checked? ? @ff.checkbox(:id, 'is_http_secondary_').click : self.msg(rule_name, :info, "Remote Administration", 'Secondary HTTP already turned off') if info['set'].match(/secondary_http off/i)
        @ff.checkbox(:id, 'is_https_primary_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'Primary HTTPS already turned on') : @ff.checkbox(:id, 'is_https_primary_').click if info['set'].match(/primary_https on/i)
        @ff.checkbox(:id, 'is_https_primary_').checked? ? @ff.checkbox(:id, 'is_https_primary_').click : self.msg(rule_name, :info, "Remote Administration", 'Primary HTTPS already turned off') if info['set'].match(/primary_https off/i)
        @ff.checkbox(:id, 'is_https_secondary_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'Secondary HTTPS already turned on') : @ff.checkbox(:id, 'is_https_secondary_').click if info['set'].match(/secondary_https on/i)
        @ff.checkbox(:id, 'is_https_secondary_').checked? ? @ff.checkbox(:id, 'is_https_secondary_').click : self.msg(rule_name, :info, "Remote Administration", 'Secondary HTTPS already turned off') if info['set'].match(/secondary_https off/i)
        @ff.checkbox(:id, 'is_diagnostics_icmp_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'WAN ICMP already turned on') : @ff.checkbox(:id, 'is_diagnostics_icmp_').click if info['set'].match(/wan_icmp on/i)
        @ff.checkbox(:id, 'is_diagnostics_icmp_').checked? ? @ff.checkbox(:id, 'is_diagnostics_icmp_').click : self.msg(rule_name, :info, "Remote Administration", 'WAN ICMP already turned off') if info['set'].match(/wan_icmp off/i)
        @ff.checkbox(:id, 'is_diagnostics_traceroute_').checked? ? self.msg(rule_name, :info, "Remote Administration", 'WAN UDP Traceroute already turned on') : @ff.checkbox(:id, 'is_diagnostics_traceroute_').click if info['set'].match(/traceroute on/i)
        @ff.checkbox(:id, 'is_diagnostics_traceroute_').checked? ? @ff.checkbox(:id, 'is_diagnostics_traceroute_').click : self.msg(rule_name, :info, "Remote Administration", 'WAN UDP Traceroute already turned off') if info['set'].match(/traceroute off/i)

        # string for creating a test file later, so we don't come back to this page to get the information
        # FixMe: There's probably a better way to construct this, most likely using inject, but I haven't thought of it yet.
        telnet_values = @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[3]/tbody/tr[1]/td/table/tbody/tr")
        web_values = @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[3]/tbody/tr[2]/td/table/tbody/tr")
        misc_values = @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[3]/tbody/tr[3]/td/table/tbody/tr")
        @dut_remote_admin << "-primary_http #{web_values[1].check_boxes[0].checked? ? "on" : "off"} #{web_values[1].text.delete('^[0-9]')}"
        @dut_remote_admin << " -primary_https #{web_values[3].check_boxes[0].checked? ? "on" : "off"} #{web_values[3].text.delete('^[0-9]')}"
        @dut_remote_admin << " -secondary_http #{web_values[2].check_boxes[0].checked? ? "on" : "off"} #{web_values[2].text.delete('^[0-9]')}"
        @dut_remote_admin << " -secondary_https #{web_values[4].check_boxes[0].checked? ? "on" : "off"} #{web_values[4].text.delete('^[0-9]')}"
        @dut_remote_admin << " -telnet #{telnet_values[1].check_boxes[0].checked? ? "on" : "off"} #{telnet_values[1].text.delete('^[0-9]')}"
        @dut_remote_admin << " -secondary_telnet #{telnet_values[2].check_boxes[0].checked? ? "on" : "off"} #{telnet_values[2].text.delete('^[0-9]')}"
        @dut_remote_admin << " -secure_telnet #{telnet_values[3].check_boxes[0].checked? ? "on" : "off"} #{telnet_values[3].text.delete('^[0-9]')}"
        @dut_remote_admin << " -wan_icmp #{misc_values[1].check_boxes[0].checked? ? "on" : "off"}"
        @dut_remote_admin << " -wan_udp_traceroute #{misc_values[2].check_boxes[0].checked? ? "on" : "off"}"
        @dut_remote_admin.strip!
        self.msg(rule_name, :info, "Remote Administration", "Current remote admin values after changes made: #{@dut_remote_admin}")
	end
	
	def advanced_remote_admin(rule_name, info)
		# Get to Advanced Page and then Remote Administration
		return unless self.advancedpage(rule_name, 'Remote Admin')
        unless info.has_key?("set")
            self.msg(rule_name, :error, "Advanced Remote Administration", "Configuration missing \"set\" key. Nothing to configure.")
            return
        end
		self.remote_admin_helper(rule_name, info)
		# Apply when it gets back
		@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
	end

    #####################
    # Local Admin       #  
    #####################
	
	def local_admin(rule_name, info)
		if self.advancedpage(rule_name, 'Local Admin') == false
			return
		end
# 		@ff.link(:href, 'javascript:mimic_button(\'goto: 9023..\', 1)').click
		if info.has_key?('primaryTelnet')
			if info['primaryTelnet'] == 'on'
				@ff.checkbox(:id, 'sec_incom_telnet_pri_').checked? ? self.msg(rule_name, :info, 'Local Administration', 'Primary Telnet already turned on') : @ff.checkbox(:id, 'sec_incom_telnet_pri_').set
			else
				@ff.checkbox(:id, 'sec_incom_telnet_pri_').checked? ? @ff.checkbox(:id, 'sec_incom_telnet_pri_').clear : self.msg(rule_name, :info, 'Local Administration', 'Primary Telnet already turned off')
			end
		end
		if info.has_key?('secondaryTelnet')
			if info['secondaryTelnet'] == 'on'
				@ff.checkbox(:id, 'sec_incom_telnet_sec_').checked? ? self.msg(rule_name, :info, 'Local Administration', 'Secondary Telnet already turned on') : @ff.checkbox(:id, 'sec_incom_telnet_sec_').set
			else
				@ff.checkbox(:id, 'sec_incom_telnet_sec_').checked? ? @ff.checkbox(:id, 'sec_incom_telnet_sec_').clear : self.msg(rule_name, :info, 'Local Administration', 'Secondary Telnet already turned off')
			end
		end
		if info.has_key?('secureTelnet')
			if info['secureTelnet'] == 'on'
				@ff.checkbox(:id, 'sec_incom_-secure_telnet_').checked? ? self.msg(rule_name, :info, 'Local Administration', 'Secure Telnet already turned on') : @ff.checkbox(:id, 'sec_incom_-secure_telnet_').set
			else
				@ff.checkbox(:id, 'sec_incom_-secure_telnet_').checked? ? @ff.checkbox(:id, 'sec_incom_-secure_telnet_').clear : self.msg(rule_name, :info, 'Local Administration', 'Secure Telnet already turned off')
			end
		end
		# Apply 
		@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
	end
	
	#####################
    # IP Distribution   #  
    #####################
	
	def ipdistribution(rule_name, info)
		# Get to advanced page and then ip address distribution
		if self.advancedpage(rule_name, 'IP Address Distribution') == false
			return
		end
		# The bridges can change, so select by text within the rule from the config
		if info.has_key?('network')
			@ff.link(:text, info['network']).click
		else
			# Or default to network home/office
            @ff.link(:text, "Network (Home/Office)").click
		end
		# Change the settings based on the the server type
		if info.has_key?('type')
			case info['type']
				when 'DHCP Server'
					# Set to server
					@ff.select_list(:id, 'dhcp_mode').set(info['type'])
					# Split the IP Address since it can be a range, and then type everything in
					if info['ipaddress'].include?('-')
						ipRange = info['ipaddress'].split('-')
						startIP = ipRange[0].split('.')
						endIP = ipRange[1].split('.')
						@ff.text_field(:name, 'start_ip0').set(startIP[0])
						@ff.text_field(:name, 'start_ip1').set(startIP[1])
						@ff.text_field(:name, 'start_ip2').set(startIP[2])
						@ff.text_field(:name, 'start_ip3').set(startIP[3])
						@ff.text_field(:name, 'end_ip0').set(endIP[0])
						@ff.text_field(:name, 'end_ip1').set(endIP[1])
						@ff.text_field(:name, 'end_ip2').set(endIP[2])
						@ff.text_field(:name, 'end_ip3').set(endIP[3])
					else
						self.msg(:error, rule_name, 'IP Address Distribution', 'No range specified for '+info['type'])
						return
					end
					# Set netmask. By default this fills in as 0.0.0.0, making it necessary
					if info.has_key?('netmask')
						netmask = info['netmask'].split('.')
						@ff.text_field(:name, 'dhcp_netmask0').set(netmask[0])
						@ff.text_field(:name, 'dhcp_netmask1').set(netmask[1])
						@ff.text_field(:name, 'dhcp_netmask2').set(netmask[2])
						@ff.text_field(:name, 'dhcp_netmask3').set(netmask[3])
					else
						self.msg(:error, rule_name, 'IP Address Distribution', 'Subnet Mask is required for '+info['type'])
						return
					end
					# WINS Server, if specified
					if info.has_key?('wins')
						wins = info['wins'].split('.')
						@ff.text_field(:name, 'wins0').set(wins[0])
						@ff.text_field(:name, 'wins1').set(wins[1])
						@ff.text_field(:name, 'wins2').set(wins[2])
						@ff.text_field(:name, 'wins3').set(wins[3])
					end
					# Lease time defaults to 1440, so isn't required. But if specified :
					if info.has_key?('leaseTime')
						@ff.text_field(:name, 'lease_time').set(info['leaseTime'])
					end
					# Provide a host name?
					if info.has_key?('provideHostnames')
						if info['provideHostnames']=='on'
							if @ff.checkbox(:id, 'create_hostname_').checked? == false
								@ff.checkbox(:id, 'create_hostname_').click
							end
						else
							if @ff.checkbox(:id, 'create_hostname_').checked? == true
								@ff.checkbox(:id, 'create_hostname_').click
							end
						end
					end
					# Apply settings
					@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
				when 'DHCP Relay'
					if info.has_key?('ipaddress')
						# Set to relay
						@ff.select_list(:id, 'dhcp_mode').set(info['type'])
						(info['ipaddress'].split(',')).each do |ipaddress|
							ip = ipaddress.split('.')
							@ff.link(:id, 'javascript:mimic_button(\'dhcpr_add: eth1..\', 1)').click
							@ff.text_field(:name, 'dhcpr_server0').set(ip[0])
							@ff.text_field(:name, 'dhcpr_server1').set(ip[1])
							@ff.text_field(:name, 'dhcpr_server2').set(ip[2])
							@ff.text_field(:name, 'dhcpr_server3').set(ip[3])
							# Apply new ip address for relay
							@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
						end
						# Apply settings
						@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
					else
						self.msg(:error, 'IP Address Distribution', 'No ip address for '+info['type'])
						return
					end
				when 'Disabled'
					@ff.select_list(:id, 'dhcp_mode').set(info['type'])
					# No options after disabling. Click apply and we are done here
					@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
			end
			if (@ff.text).include?('Press Apply to confirm')
				@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
			end
		else
			self.msg(:error, 'IP Address Distribution', 'No specified type for DHCP settings')
			return
		end
	end
	
	#####################
	# Network Objects   #  
	#####################
	
	# Method to create the actual object
	def createObject(rule_name, objectSet, calledFrom)
		# Set the object name if specified
		@ff.text_field(:name, 'desc').set(objectSet['description']) if objectSet.has_key?('description')
		# Click add
		@ff.link(:name, 'add').click
		# @ff.link(:href,'javascript:mimic_button(\'add: ...\', 1)').click
		# Okay, we're adding the network object type now, let's find out what it is and set it:
		case objectSet['type']
			when /IP.?Address/i
				# Select IP Address as the type
				@ff.select_list(:id, 'net_obj_type').select("IP Address")
				# Separate the ip address octects because it's 1 box per octect on the interface
				ipAddress=objectSet['start_address'].split('.')
				# And now apply those to their respective fields
				@ff.text_field(:name, 'ip0').set(ipAddress[0])
				@ff.text_field(:name, 'ip1').set(ipAddress[1])
				@ff.text_field(:name, 'ip2').set(ipAddress[2])
				@ff.text_field(:name, 'ip3').set(ipAddress[3])
			when /IP.?Subnet/i
				# Select IP Subnet as the type
				@ff.select_list(:id, 'net_obj_type').select("IP Subnet")
				# Separate the subnet ip address octects, and subnet mask octects because it's 1 box per octect on the interface
				ipAddress=objectSet['start_address'].split('.')
				netMask=objectSet['end_address'].split('.')
				# And now apply those to their respective fields; Subnet IP first
				@ff.text_field(:name, 'subnet_00').set(ipAddress[0])
				@ff.text_field(:name, 'subnet_01').set(ipAddress[1])
				@ff.text_field(:name, 'subnet_02').set(ipAddress[2])
				@ff.text_field(:name, 'subnet_03').set(ipAddress[3])
				# And now the subnet mask
				@ff.text_field(:name, 'subnet_10').set(netMask[0])
				@ff.text_field(:name, 'subnet_11').set(netMask[1])
				@ff.text_field(:name, 'subnet_12').set(netMask[2])
				@ff.text_field(:name, 'subnet_13').set(netMask[3])
			when /IP.?Range/i
				# Select IP Range as the type
				@ff.select_list(:id, 'net_obj_type').select("IP Range")
				# Separate the range ip addresses octects for both start and end to match the interface
				ipStart=objectSet['start_address'].split('.')
				ipEnd=objectSet['end_address'].split('.')
				# And now apply those to their respective fields; Subnet IP first
				@ff.text_field(:name, 'subnet_00').set(ipStart[0])
				@ff.text_field(:name, 'subnet_01').set(ipStart[1])
				@ff.text_field(:name, 'subnet_02').set(ipStart[2])
				@ff.text_field(:name, 'subnet_03').set(ipStart[3])
				# And now the end ip address of the range
				@ff.text_field(:name, 'subnet_10').set(ipEnd[0])
				@ff.text_field(:name, 'subnet_11').set(ipEnd[1])
				@ff.text_field(:name, 'subnet_12').set(ipEnd[2])
				@ff.text_field(:name, 'subnet_13').set(ipEnd[3])
			when /mac.?Address/i
				# Select mac Address for the type
				@ff.select_list(:id, 'net_obj_type').select("MAC Address")
				# Separate the actual mac
				macAddress=objectSet['start_address'].split(':')
				# If there's a NULL
				if objectSet.has_key?('end_address')
					objectSet['end_address']=='NULL' ? macMask='FF:FF:FF:FF:FF:FF'.split(':') : macMask=objectSet['end_address'].split(':')
				else
					macMask='FF:FF:FF:FF:FF:FF'.split(':')
				end
				# Set the mac address
				@ff.text_field(:name, 'mac0').set(macAddress[0])
				@ff.text_field(:name, 'mac1').set(macAddress[1])
				@ff.text_field(:name, 'mac2').set(macAddress[2])
				@ff.text_field(:name, 'mac3').set(macAddress[3])
				@ff.text_field(:name, 'mac4').set(macAddress[4])
				@ff.text_field(:name, 'mac5').set(macAddress[5])
				# And now the mac address mask
				@ff.text_field(:name, 'mac_mask0').set(macMask[0])
				@ff.text_field(:name, 'mac_mask1').set(macMask[1])
				@ff.text_field(:name, 'mac_mask2').set(macMask[2])
				@ff.text_field(:name, 'mac_mask3').set(macMask[3])
				@ff.text_field(:name, 'mac_mask4').set(macMask[4])
				@ff.text_field(:name, 'mac_mask5').set(macMask[5])
			when /Host.?Name/i
				# Select Host Name
				@ff.select_list(:id, 'net_obj_type').select("Host Name")
				# This one is easy, just set the host name from the value given in the config
				@ff.text_field(:name, 'hostname').set(objectSet['start_address'])
			when /DHCP.?Option/i
				# Select DHCP Option
				@ff.select_list(:id, 'net_obj_type').select("DHCP Option")
				# Quick selection between the DHCP options
				case objectSet['start_address']
					when /Vendor Class ID/i
						@ff.select_list(:value, '60')
						@ff.text_field(:name, 'dhcp_opt_type').set(objectSet['end_address'])
					when /Client ID/i
						@ff.select_list(:value, '61')
						@ff.text_field(:name, 'dhcp_opt_type').set(objectSet['end_address'])
					when /User Class ID/i
						@ff.select_list(:value, '77')
						@ff.text_field(:name, 'dhcp_opt_type').set(objectSet['end_address'])
				end
			else
				self.msg(rule_name, :error, 'Network Object creation','No object type specified; called from: '+calledFrom)
				exit
		end
		# okay, we're done. Let's apply back out to the origination screen now. Applying twice. 
		self.msg(rule_name, :debug, "Network Object Creation", "First network object apply")
		@ff.link(:text, "Apply").click
		self.msg(rule_name, :debug, "Network Object Creation", "Second network object apply")
		@ff.link(:text, "Apply").click
	end
	
	def network_object(rule_name, info)
		# Get to advanced page, and to network objects
		if self.advancedpage(rule_name, 'network objects') == false
			return
		end
		# Click add
		@ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
		# And send it to object creation
		createObject(rule_name, info, 'Network Objects')
	end
	
	#####################
	# Diagnostics       #  
	#####################
	
	def diagnostics(rule_name, info)
		# Jump to diagnostics
		testDone = false
		testInput = nil
		index = 0
		if self.advancedpage(rule_name, 'diagnostics') == false
			return
		end
		# Config file should indicate destination and amount of pings as:
		# 192.168.1.1*10
		if info.has_key?('destination')
			if info['destination'].include?('*')
				testInput = info['destination'].split('*')
				@ff.text_field(:name, 'ping_dest').set(testInput[0])
				@ff.text_field(:name, 'ping_num').set(testInput[1])
			else
				@ff.text_field(:name, 'ping_dest').set(info['destination'])
			end
			# Run the test now
			@ff.link(:text, 'Go').click
			# Wait for the test to complete
			while testDone == false
				sleep 2
				@ff.link(:text, 'Refresh').click
				@ff.wait
				@ff.text.match(/Testing/) == nil ? testDone = true : testDone = false
			end
			# If it fails lookup, show the info and return
			if @ff.text.include?('Address Resolving Failed')
				self.msg(rule_name, :info, 'Diagnostics', 'Unable to find host/URL/IP: ' + info['destination'])
				return
			end
			# Otherwise, grab table index 20 that contains our results
			# And log the results:
			statusText = @ff.table(:index, 20)
			result = String.new
			statusText.each do |results|
				if results[1].to_s.include?('Status') || results[1].to_s.include?('Packets') || results[1].to_s.include?('Round Trip Time')
					result+= sprintf('%s %s | ', results[1].to_s, results[0].to_s) 
				end
			end
			self.msg(rule_name, :info, 'Diagnostics', result)
		else
			# If we couldn't do anything, return
			self.msg(rule_name, :error, 'Diagnostics', 'No destination key in configuration file. Nothing to do.')
			return
		end
	end
	
	#####################
	# Restore Defaults  #  
	#####################
	
	def restore_defaults(rule_name, info)
		done = false
		cycle = 0
		# Get to the page
		if self.advancedpage(rule_name, 'restore defaults') == false
			return
		end
		#  No save file option right now, so this doesn't really do much
		# Place holders
		if info.has_key?('save') && info['save'] != ""
			@ff.link(:text, 'Save Configuration File').click
			# Do something
		end
		
		# Restore defaults 
		@ff.link(:href, 'javascript:mimic_button(\'onclick=').click
		@ff.link(:text, 'OK').click
		# Small timer before we check if it's really doing it, and reporting back
		sleep 2
		if @ff.text.include?('system is now restoring factory defaults')
			self.msg(rule_name, :info, 'Restore Defaults', 'Success!')
		end
		
		# Give it time, and then jump to the login_setup
		while not done
			if @ff.text.include?('Login Setup')
				done = true
			else
				cycle += 1
				# We are going to give it 50 seconds, if it's not back up, click login
				# and then break out of this loop. Send it to the login method, and if that fails
				# We end it
				if cycle > 25
					@ff.link(:href, 'javascript:mimic_button(\'onclick=')
					sleep 2
					break
				else
					sleep 2
				end
			end
		end
		self.login(rule_name, 'External Call')
	end
	
	#####################
	# MAC Cloning       #  
	#####################
	
	def mac_cloning(rule_name, info)
		# Get to the mac cloning page
		if self.advancedpage(rule_name, 'mac cloning') == false
			return
		end
		counter = 1
		placer = 2
		# Choose device if specified, otherwise inform of default setting
		if info.has_key?('device')
			if info['device'].match(/eth/i)
				@ff.select_list(:id, 'wan_devices_to_clone').select('eth1')
			elsif info['device'].match(/coax|moca|clink/i)
				@ff.select_list(:id, 'wan_devices_to_clone').select('clink1')
			else
				self.msg(rule_name, :error, 'MAC Cloning', 'No device value '+info['device'] +'; Moving on to next rule')
				return
			end
		else
			# Send an inform if we are using the default WAN device
			self.msg(rule_name, :info, 'MAC Cloning - WAN Device', 'Using default - ' + @ff.select_list(:id, 'wan_devices_to_clone').value)
		end
		
		# Insert : into the MAC ID if it exists and is correctly inputted
		if info.has_key?('mac')
			if info['mac'] =~ /\A([0-9a-fA-F][0-9a-fA-F]){6}\z/
				until counter == 6
					info['mac'].insert(placer,':')
					counter += 1
					placer += 3
				end
			end
			
			# Split the MAC into octects, and input if specified
			if info['mac'] =~ /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F]{2}\z/
				macOctects = info['mac'].split(':')
				for counter in 0..5
					@ff.text_field(:name, 'mac'+counter.to_s).set(macOctects[counter])
				end
			# Or maybe we're cloning the computer's mac id
			elsif info['mac'] =~ /clone/i
				if @ff.link(:text, 'Clone My MAC Address').exists?
					@ff.link(:text, 'Clone My MAC Address').click
				else
					self.msg(rule_name, :error, 'MAC Cloning', 'No link for \"Clone My MAC Address\" exists; Maybe you need to restore?')
					return
				end
			# Or maybe we're restoring
			elsif info['mac'] =~ /restore/i
				if @ff.link(:text, 'Restore Factory MAC Address').exists?
					@ff.link(:text, 'Restore Factory MAC Address').click
				else
					self.msg(rule_name, :error, 'MAC Cloning', 'No link for \"Restore Factory MAC Address\" exists; Maybe you need to clone?')
					return
				end
			# Or ... we aren't doing anything. 
			else
				self.msg(rule_name, :error, 'MAC Cloning', 'No valid MAC Address supplied.')
				return
			end
		# Or there is no mac key at all, so let's stop here
		else
			self.msg(rule_name, :error, 'MAC Cloning', 'No \"mac\" key provided.')
			return
		end
		
		# Click apply
		@ff.link(:text, 'Apply').click
		self.msg(rule_name, :info, 'MAC Cloning', 'Success!')
	end
	
	#####################
	# ARP Table         #  
	#####################
	
	def arp_table(rule_name, info)
		# Jump to the arp table page
		if self.advancedpage(rule_name, 'ARP Table') == false
			return
		end
		modeSet = nil
		# Find out what we are doing here
		if info.has_key?('action')
			case info['action']
			# If we are adding to the DHCP ACL
			when 'set':
				if info.has_key?('mode')
					if info['mode'].match(/allow|deny|disable/i) == nil
						self.msg(rule_name, :error, 'ARP Table - DHCP ACL', '\"mode\" key available, but no valid settings. Skipping configuration.')
						return
					else
						modeSet = false
						# Format "mode" so that we can find it in the list
						info['mode'].slice!(' ')
						info['mode'].downcase!
						info['mode'].capitalize!
					end
				else
					self.msg(rule_name, :error, 'ARP Table - DHCP ACL', 'Action \"set\" with no \"mode\" for DHCP Access Control. Skipping configuration.')
					return
				end
				if info.has_key?('add')
					# Separate the MAC ids if there is more than one
					info['add'].include?(';') ? macList = info['add'].split(';') : macList = info['add']
					macList.each do |mac|
						if @ff.link(:text, 'Add').exists?
							if modeSet == nil
								self.msg(rule_name, :error, 'ARP Table - DHCP ACL', 'Config says to add, but the \"mode\" is not specified and currently disabled. Skipping configuration.')
								return
							else
								@ff.link(:text, 'Add').click
							end
						elsif @ff.link(:href, 'javascript:mimic_button(\'goto: 9039..\', 1)').exists?
							@ff.link(:href, 'javascript:mimic_button(\'goto: 9039..\', 1)').click
							if modeSet == nil && @ff.select_list(:id, 'mac_filter_mode').value == '1'
								self.msg(rule_name, :error, 'ARP Table - DHCP ACL', 'Config says to add, but the \"mode\" is not specified in the config, and is currently disabled on the DUT. Skipping configuration.')
								return
							elsif modeSet==false
								@ff.select_list(:id, 'mac_filter_mode').select(info['mode'])
								modeSet = true
								self.msg(rule_name, :info, 'ARP Table - DHCP ACL', 'MAC Filtering Mode set to '+info['mode'])
							end
							@ff.link(:href, 'javascript:mimic_button(\'mac_filter_add: ...\', 1)').click
						elsif @ff.link(:href, 'javascript:mimic_button(\'mac_filter_add: ...\', 1)').exists?
							@ff.link(:href, 'javascript:mimic_button(\'mac_filter_add: ...\', 1)').click
						end
						# Format the MAC Address if it isn't already
						if mac =~ /\A([0-9a-fA-F][0-9a-fA-F]){6}\z/
							counter = 0
							placer = 2
							until counter == 5
								mac.insert(placer,':')
								counter += 1
								placer += 3
							end
						end
						# Split the MAC into octects, and input if specified
						if mac =~ /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F]{2}\z/
							macOctects = mac.split(':')
							for counter in 0..5
								@ff.text_field(:name, 'mac'+counter.to_s).set(macOctects[counter])
							end
							# Click Apply
							@ff.link(:text, 'Apply').click
							self.msg(rule_name, :info, 'ARP Table - DHCP ACL'+mac, mac+' added.')
						else
							@ff.link(:text, 'Cancel').click
							self.msg(rule_name, :warning, 'ARP Table - '+mac, mac + ' is not a valid MAC address - Skipping.')
						end
						# In case something horrible happened
						if @ff.text.include?('Input Errors')
							self.msg(rule_name, :error, 'Fatal-ARP Table', 'Unable to complete configuration. Something really wrong happened here..')
							return
						end
						# Check if we now need to set a mode
					end
					# If we're done and added more than one MAC to the list, we need to Apply one last time:
					@ff.link(:text, 'Apply') if @ff.link(:text, 'Apply').exists?
				# If we are just changing the mode ... if "Add" exists, we can't change the mode here. 
				elsif modeSet != nil
					if @ff.link(:href, 'javascript:mimic_button(\'goto: 9039..\', 1)').exists?
						@ff.link(:href, 'javascript:mimic_button(\'goto: 9039..\', 1)').click
						if modeSet==false
							@ff.select_list(:id, 'mac_filter_mode').select(info['mode'])
							@ff.link(:text, 'Apply').click
							modeSet = true
							self.msg(rule_name, :info, 'ARP Table - DHCP ACL', 'MAC Filtering Mode set to '+info['mode'])
						end
					end
				end
			when 'get':
				# Output "ARP Table"
				@ff.tables.each do |tableFinder|
					if tableFinder.text.include?('IP Address')
						set = 1
						tableFinder.each do |cellStructure|
							if cellStructure.text.match(/ip address|mac address|arp table|close|refresh/i) == nil && cellStructure[1] != ' ' && cellStructure[1]!=nil
								cellStructure[1].each_byte {|chars| puts chars }
								self.msg(rule_name, :info, 'Found Set '+set.to_s, (sprintf('IP Address: %s ; MAC Address: %s ; Device: %s',cellStructure[1],cellStructure[2],cellStructure[3])))
								set += 1
							end
						end
					end
				end
			else
				self.msg(rule_name, :error, 'ARP Table', 'No valid action specified. Check the configuration.')
				return
			end
		end
		self.msg(rule_name, :info, 'ARP Table', 'Success!')
	end
	
	#####################
	# Users             #  
	#####################
	
	def users(rule_name, info)
		# Get to users page under advanced
		if self.advancedpage(rule_name, 'users') == false
			return
		end
		# Format to add a user: add: full name, username, password, permissions, notification address(optional), system notify level, security level
		# We can do some defaults, but the commas should be there, so:
		# Example:   add: new user, newuser, newuser,,,,information
		# At the very least, we need the action (add), and the user name. If password is excluded, we will default to "password1"
		if info.has_key?('user')
			# Needs error checking
			if info['user'].match(/\Aadd:/)
				# Format the string
				user = (info['user'].sub!('add:','')).split(',')
				# Check if we are missing a full name or username, or password
				if user[0] == '' or user[1] == ''
					self.msg(rule_name, :error, 'Users','No full name and/or username provided. Check configuration.')
					return
				# Check if the user already exists
				elsif @ff.text.include?(user[1])
					self.msg(rule_name, :error, 'Users','Username '+user[1]+' already exists. Skipping configuration.')
					return
				end
				# Check for drop down menu items
				if !user[3]=~/administrator|limited/i && !user[3] == nil && !user[3] == ''
					self.msg(rule_name, :error, 'Users', 'Unknown option for Permissions: '+user[3])
					return
				elsif !user[5]=~/none|error|warning|information/i && !user[5] == nil && !user[5] == ''
					self.msg(rule_name, :error, 'Users', 'Unknown System Notify Level: '+user[5])
					return
				elsif !user[6]=~/none|error|warning|information/i && !user[6] == nil && !user[6] == ''
					self.msg(rule_name, :error, 'Users', 'Unknown System Notify Level: '+user[6])
					return
				end
				if user[2] == '' || user[2]==nil
					user[2] = 'password1'
					self.msg(rule_name, :info, 'Users - Password', 'No password given, setting to \'password1\'')
				end
				
				# Make sure drop down menus contain what the config will try to set
				
				# Fix strings so they match the drop down menus.
				user[3] = user[3].downcase.capitalize if !user[3] == '' && user[3] =~ /administrator|limited/i
				user[5] = user[5].downcase.capitalize if !user[5] == '' && user[5] =~ /none|error|warning|information/i
				user[6] = user[6].downcase.capitalize if !user[6] == '' && !user[6]==nil && user[6] =~ /none|error|warning|information/i
				# Begin add
				@ff.link(:href, 'javascript:mimic_button(\'user_add: ...\', 1)').click
				@ff.text_field(:name, 'fullname').set(user[0].strip)
				@ff.text_field(:name, 'username').set(user[1].strip)
				@ff.text_field(:name, /new_passwd/).set(user[2].strip)
				@ff.text_field(:name, /rt_new_passwd/).set(user[2].strip)
				@ff.select_list(:id, 'user_level').select(user[3].strip) if !user[3] == '' && !user[3] == nil
				@ff.text_field(:name, 'email').set(user[4].strip) if !user[4] == '' && !user[4] ==nil
				@ff.select_list(:id, 'user_level').select(user[5].strip) if !user[5] == '' && !user[5] == nil
				@ff.select_list(:id, 'user_level').select(user[6].strip) if !user[6] == '' && !user[6] == nil
				@ff.link(:text, 'Apply').click
				# Fatal exception
				if @ff.text.include?('Input Errors')
					self.msg(rule_name, :error, 'Fatal-Users', 'Either the username already exists and got past our checks, or something really bad happened. Check DUT.')
					@ff.link(:text, 'Cancel').click
					@ff.link(:text, 'Cancel').click
					@ff.link(:text, 'Close').click
					return
				else
					self.msg(rule_name, :info, 'Users', 'Finished adding user: '+user[1])
				end
			else
				self.msg(rule_name, :error, 'Users', 'No valid action in \"user\" key. Check configuration.')
				return
			end
		else
			self.msg(rule_name, :error, 'Users', 'No \"user\" key provided. Check configuration.')
			return
		end
	end

	#####################
	# Dynamic DNS       #
	#####################
	
	def dynDNS(rule_name, info)
		# Get to Dynamic DNS page
		if self.advancedpage(rule_name, 'dynamic dns') == false
			return
		end
		regSearch = false
		# Find out what we are doing here
		# String:   add: host name, connection, provider, username, password, system *, exchanger -backup -offline, ssl mode -validate-time
		# Example: add: actiontec, pppoe 2, dyndns.org, actiontec, premax1, static *, mail.exchange.actiontec.com -offline, chain
		# Notice that only works for dnydns.org and easydns.com ... The others are limited in their options
		if info.has_key?('add')
			if info['add'].match(/\Aadd:/)
				dyndns = (info['add'].sub!('add:', '')).split(',')
				# Variable checks for all the options
				if dyndns[0] == nil || dyndns[0]==''
					self.msg(rule_name, :error, 'Dynamic DNS', 'No host name provided.')
					return
				elsif dyndns[3] == '' || dyndns[4] == '' || dyndns[3] == nil || dyndns[4]==nil
					self.msg(rule_name, :error, 'Dynamic DNS', 'No user/pass provided.')
					return
				end
				# Check for empty default variables
				if dyndns[2] == '' || dyndns[2] == nil
					# Default to dyndns.org
					dyndns[2] = 'dyndns.org'
					# Message that we did so
					self.msg(rule_name, :info, 'Dynamic DNS - Provider', 'Using default provider: dyndns.org')
				end
				if dyndns[5] == '' || dyndns[5] == nil
					dyndns[5] = 'Dynamic DNS'
					self.msg(rule_name, :info, 'Dynamic DNS - System', 'Using default system: Dynamic DNS')
				end
				# Check for valid entries in the list - not case sensitive here
				if !dyndns[2] =~ /dyndns|no-ip|changeip|tzo|ods|easydns|zoneedit/i
					self.msg(rule_name, :error, 'Dynamic DNS', dyndns[2] + ' is not a valid provider. Check configuration.')
					return
				elsif !dyndns[5] =~ /dynamic|custom|static/i
					self.msg(rule_name, :error, 'Dyanmic DNS', dyndns[5] + ' is not a valid DNS System. Check configuration.')
					return
				end
				# If we made it this far, we can start the configuration
				@ff.link(:href, 'javascript:mimic_button(\'ddns_host_add: ...\', 1)').click
				
				# host name is always available
				@ff.text_field(:name, 'ddns_host').set(dyndns[0].strip)
				
				# Connection type
				(@ff.select_list(:id, 'ddns_device').getAllContents).each do |validate|
					if validate.match(Regexp.new(dyndns[1].downcase.strip, /i/)) != nil
						regSearch = validate
					end
				end
				@ff.select_list(:id, 'ddns_device').select(regSearch) if regSearch != false
				
				# Provider
				(@ff.select_list(:id, 'ddns_provider').getAllContents).each do |validate| 
					if validate.match(Regexp.new(dyndns[2].downcase.strip, /i/)) != nil
						regSearch = validate
					else
						regSearch = false
					end
				end
				@ff.select_list(:id, 'ddns_provider').select(regSearch) if regSearch != false
				
				# Username and Password
				@ff.text_field(:name, /ddns_username/i).set(dyndns[3].strip)
				@ff.text_field(:name, /ddns_password/i).set(dyndns[4].strip)
				
				# DDNS System + Wildcard
				if dyndns[5].include?('*')
					@ff.checkbox(:id, 'dyndns_wildcard_').set if @ff.checkbox(:id, 'dyndns_wildcard_').exists?
					dyndns[5].delete!('*')
				end
				if @ff.select_list(:id, 'ddns_system').exists?
					(@ff.select_list(:id, 'ddns_system').getAllContents).each do |validate| 
						if validate.match(Regexp.new(dyndns[5].downcase.strip, /i/)) != nil
							regSearch = validate
						else
							regSearch = false
						end
					end
					@ff.select_list(:id, 'ddns_system').select(regSearch) if regSearch != false
				end
				
				# Mail exchange -backup -offline options
				if dyndns[6].include?('-backup')
					@ff.checkbox(:id, 'dyndns_backup_mx_').set if @ff.checkbox(:id, 'dyndns_backup_mx_').exists?
					dyndns[6].sub!('-backup','')
				end
				if dyndns[6].include?('-offline')
					@ff.checkbox(:id, 'dyndns_offline_').set if @ff.checkbox(:id, 'dyndns_offline_').exists?
					dyndns[6].sub!('-offline','')
				end
				if @ff.text_field(:name, 'dyndns_mx').exists?
					@ff.text_field(:name, 'dyndns_mx').set(dyndns[6].strip) if @ff.text_field(:name, 'dyndns_mx').exists?
				end
				
				# SSL Mode
				if dyndns[7].include?('-')
					validTime = dyndns[7].split('-')
				else
					validTime = dyndns[7]
				end
				if @ff.select_list(:id, 'wget_ssl_val_mode').exists?
					(@ff.select_list(:id, 'wget_ssl_val_mode').getAllContents).each do |validate| 
						if validate.match(Regexp.new(validTime[0].downcase.strip, /i/)) != nil
							regSearch = validate
						else
							regSearch = false
						end
					end
					@ff.select_list(:id, 'wget_ssl_val_mode').select(regSearch) if regSearch != false
				end
				
				# Valid time
				if @ff.select_list(:id, 'wget_ssl_val_time').exists?
					(@ff.select_list(:id, 'wget_ssl_val_time').getAllContents).each do |validate| 
						if validate.match(Regexp.new(validTime[1].downcase.strip, /i/)) != nil
							regSearch = validate
						else
							regSearch = false
						end
					end
					@ff.select_list(:id, 'wget_ssl_val_time').select(regSearch) if regSearch != false
				end
				
				# Apply
				@ff.link(:text, 'Apply').click
				# Apply again if we get the Attention page
				if @ff.text.include?('Attention')
					@ff.link(:text, 'Apply').click
				end
				self.msg(rule_name, :info, 'Dynamic DNS', 'Success!')
			else
				self.msg(rule_name, :error, 'Dynamic DNS', 'Missing action option for Dynamic DNS. Check configuration.')
			end
		else
			self.msg(rule_name, :error, 'Dynamic DNS', 'Missing action option for Dynamic DNS. Check configuration.')
		end
	end

	#####################
	# DNS Server        #  
	#####################

	def dns_server(rule_name, info)
		if self.advancedpage(rule_name, 'DNS Server') == false
			return
		end
		if info.has_key?('add')
			if info['add'].match(/\A.*(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/)
				hostname = info['add'].split(',')
				ip = hostname[1].split('.')
				hostname[0].strip!
			else
				self.msg(rule_name, :error, 'DNS Server', 'Configuration for adding new DNS Entry doesn\'t include proper information. Check configuration.')
				return
			end
			@ff.link(:href, 'javascript:mimic_button(\'dns_add: ...\', 1)').click
			@ff.text_field(:name, 'hostname')
			for i in 0..3
				@ff.text_field(:name, 'ip'+i.to_s).set(ip[i].strip)
			end
			@ff.link(:text, 'Apply').click
			self.msg(rule_name, :error, 'DNS Server', 'Added host '+hostname[0])
		else
			self.msg(rule_name, :error, 'DNS Server', 'Missing action key \"add\".')
		end
	end

	#####################
	# Universal PnP     #  
	#####################

	def upnp(rule_name, info)
		if self.advancedpage(rule_name, 'upnp') == false
			return
		end
		if info.has_key?('upnp')
			if info['upnp'].include?('on')
				@ff.checkbox(:id, 'upnp_enabled_').set
			elsif info['upnp'].include?('off')
				@ff.checkbox(:id, 'upnp_enabled_').clear
			end
			if info['upnp'].match(/clean/i)
				@ff.checkbox(:id, 'upnp_rules_auto_clean_enabled_').set
			else
				@ff.checkbox(:id, 'upnp_rules_auto_clean_enabled_').clear
			end
			if info['upnp'].match(/all/)
				@ff.select_list(:name, 'wan_conns_to_publish').select_value('1')
			else
				@ff.select_list(:name, 'wan_conns_to_publish').select_value('0')
			end
			@ff.link(:text, 'Apply').click
			self.msg(rule_name, :info, 'UPnP', 'Success!')
		else
			self.msg(rule_name, :error, 'UPnP', 'Missing action key \"upnp\". Check configuration')
		end
	end
	
	#####################
	# System Settings   #  
	#####################

	def system_settings(rule_name, info)
		return if self.advancedpage(rule_name, 'system settings') == false
		# Based on variables by page definition. Everything is optional. 
		
		# Router status - "status" : "-host hostname -domain domainname"
		if info.has_key?('status')
			@ff.text_field(:name,'host_name').set(info['status'].slice(/-host.?\w+/i)) if info['status'].match(/-host/i)
			@ff.text_field(:name,'domain_name').set(info['status'].slice(/-domain.?\w+/i)) if info['status'].match(/-domain/i)
			self.msg(rule_name,:info,'Hostname and Domain', 'Changed to '+ info['status'])
		end
		# System access - "access" : "-auto +prompt +warn -session 7200 -users 10"
		if info.has_key?('access')
			lifetime = false
			con_users = false
			@ff.checkbox(:name,'auto_refresh').set if info['access'].match(/\+auto/)
			@ff.checkbox(:name,'auto_refresh').clear if info['access'].match(/-auto/)
			@ff.checkbox(:name,'prompt_lan_password').set if info['access'].match(/\+prompt/)
			@ff.checkbox(:name,'prompt_lan_password').clear if info['access'].match(/-prompt/)
			@ff.checkbox(:name,'confirm_needed').set if info['access'].match(/\+warn/)
			@ff.checkbox(:name,'confirm_needed').clear if info['access'].match(/-warn/)

			if info['access'].match(/session/)
				lifetime = info['access'].match(/session.*\D/).to_s.delete('^[0-9]').strip
                @ff.text_field(:name,'session_lifetime').set(lifetime) if lifetime.to_i < 60 or lifetime.to_i > 7200
			end
			
			if info['access'].match(/users/)
				con_users = info['access'].match(/users.*/).to_s.delete('^[0-9]').strip
                @ff.select_list(:name,/concurrent/).select(con_users) if conUsers.to_i < 1 or con_users.to_i > 10
			end
			
			self.msg(rule_name,:info,'Access Variables', 'Changed to '+ info['access'])
		end    
		
		# Administration ports - "ports" : "-primary_http 80 -secondary_http 8080 -primary_https 443 -secondary_https 8443 -telnet 23 -secondary_telnet 8023 -secure_telnet 992"
		if info.has_key?('ports')
			@ff.text_field(:name,'mng_port_http_primary').set(info['ports'].slice(/-primary_http.?\d{1,5}/i).delete('^[0-9]')) if info['ports'].match(/-primary_http.?\d{1,5}/i)
			@ff.text_field(:name,'mng_port_http_secondary').set(info['ports'].slice(/-secondary_http.?\d{1,5}/i).delete('^[0-9]')) if info['ports'].match(/-secondary_http.?\d{1,5}/i)
			@ff.text_field(:name,'mng_port_https_primary').set(info['ports'].slice(/-primary_https.?\d{1,5}/i).delete('^[0-9]')) if info['ports'].match(/-primary_https.?\d{1,5}/i)
			@ff.text_field(:name,'mng_port_https_secondary').set(info['ports'].slice(/-secondary_https.?\d{1,5}/i).delete('^[0-9]')) if info['ports'].match(/-secondary_https.?\d{1,5}/i)
			@ff.text_field(:name,'mng_port_telnet_primary').set(info['ports'].slice(/-telnet.?\d{1,5}/i).delete('^[0-9]')) if info['ports'].match(/-telnet.?\d{1,5}/i)
			@ff.text_field(:name,'mng_port_telnet_secondary').set(info['ports'].slice(/-secondary_telnet.?\d{1,5}/i).delete('^[0-9]')) if info['ports'].match(/-secondary_telnet.?\d{1,5}/i)
            @ff.text_field(:name,'mng_port_telnets').set(info['ports'].slice(/-secure_telnet.?\d{1,5}/i).delete('^[0-9]')) if info['ports'].match(/-secure_telnet.?\d{1,5}/i)
			self.msg(rule_name,:info,'Management Application Ports','Changed to ' + info['ports'])
		end
			                                                    
		# SSL Authentication options - "sslauth" : "-primary none -secondary none -telnet none"
 		if info.has_key?('sslauth')
			vars = info['sslauth'].sub(/\A-/,'').split('-')
			vars.each do |item|
				set = item.split(' ')
				tag = "mng_auth_https_primary" if set[0].match(/primary/i)
				tag = "mng_auth_https_secondary" if set[0].match(/second/i)
				tag = "mng_auth_-secure_telnet" if set[0].match(/telnet|secure/i)
				if validate(tag, set[1]) == false
					self.msg(rule_name, :error, "SSL Authentication Options", "Unable to find #{set[1]} in #{tag}")
					return
				end
			end
		end
		
		# System Logging options - "system_logging" : "-log on -lcn on -emailnotice 50 -buffersize 16 -remotenotify error" - 1-256
		if info.has_key?('system_logging')
			vars = info['system_logging'].sub(/\A-/,'').split('-')
			vars.each do |item|
				set = item.split(' ')
				case set[0].strip
				when 'log'
					@ff.checkbox(:id, "var_logging_enabled_").set if set[1].match(/on/i)
					@ff.checkbox(:id, "var_logging_enabled_").clear if set[1].match(/off/i)
				when 'lcn'
					@ff.checkbox(:id, "var_notify_enabled_").set if set[1].match(/on/i)
					@ff.checkbox(:id, "var_notify_enabled_").clear if set[1].match(/off/i)
				when 'emailnotice'
					set[1].gsub!(/\D/,'')
					if set[1].to_i > 100 or set[1].to_i < 1
						self.msg(rule_name, :error, "System Logging Options", "Invalid value #{set[1]} for Allowed Capacity Before Email Notification (1-100).")
						return
					else
						@ff.text_field(:name, "var_notify_limit").set(set[1])
					end
				when 'buffersize'
					set[1].gsub!(/\D/,'')
					if set[1].to_i > 100 or set[1].to_i < 1
						self.msg(rule_name, :error, "System Logging Options", "Invalid value #{set[1]} for System Log Buffer Size (1-256).")
						return
					else
						@ff.text_field(:name, "system_buf_size").set(set[1])
					end
				when 'remotenotify'
					if validate("system_notify_level", set[1]) == false
						self.msg(rule_name, :error, "SSL Authentication Options", "Unable to find #{set[1]} in Remote System Notify Level")
						return
					end
				when /ip/i
					ip = set[1].strip.split('.')
					@ff.text_field(:name, "syslog_remote_ip0").set(ip[0])
					@ff.text_field(:name, "syslog_remote_ip1").set(ip[1])
					@ff.text_field(:name, "syslog_remote_ip2").set(ip[2])
					@ff.text_field(:name, "syslog_remote_ip3").set(ip[3])
				end
			end
		end
		# Security Logging options - "security_logging" : "-lcn on -emailnotice 50 -buffersize 16 -remotenotify error" - 1-256		
		if info.has_key?('security_logging')
			vars = info['system_logging'].sub(/\A-/,'').split('-')
			vars.each do |item|
				set = item.split(' ')
				case set[0].strip
				when /lcn/i
					@ff.checkbox(:id, "fw_notify_enabled_").set if set[1].match(/on/i)
					@ff.checkbox(:id, "fw_notify_enabled_").clear if set[1].match(/off/i)
				when /emailnotice/i
					set[1].gsub!(/\D/,'')
					if set[1].to_i > 100 or set[1].to_i < 1
						self.msg(rule_name, :error, "System Logging Options", "Invalid value #{set[1]} for Allowed Capacity Before Email Notification (1-100).")
						return
					else
						@ff.text_field(:name, "fw_notify_limit").set(set[1])
					end
				when /buffersize/i
					set[1].gsub!(/\D/,'')
					if set[1].to_i > 100 or set[1].to_i < 1
						self.msg(rule_name, :error, "System Logging Options", "Invalid value #{set[1]} for Security Log Buffer Size (1-256).")
						return
					else
						@ff.text_field(:name, "security_buf_size").set(set[1])
					end
				when /remotenotify/i
					if validate("security_notify_level", set[1]) == false
						self.msg(rule_name, :error, "SSL Authentication Options", "Unable to find #{set[1]} in Remote Security Notify Level")
						return
					end
				when /ip/i
					ip = set[1].strip.split('.')
					@ff.text_field(:name, "security_remote_ip0").set(ip[0])
					@ff.text_field(:name, "security_remote_ip1").set(ip[1])
					@ff.text_field(:name, "security_remote_ip2").set(ip[2])
					@ff.text_field(:name, "security_remote_ip3").set(ip[3])
				end
			end
		end
		
		# Outgoing Mail Server options - "mail" : "-server server.ipor.domain -email from@emailaddress -port 25 -auth on"
		if info.has_key?('mail')
			vars = info['mail'].sub(/\A-/,'').split('-')
			vars.each do |item|
				set = item.split(' ')
				case set[0].strip
				when /server/i
					@ff.text_field(:name, "email_smtp_server").set(set[1].strip)
				when /email/i
					@ff.text_field(:name, "email_from_address").set(set[1].strip)
				when /port/i
					@ff.text_field(:name, "email_smtp_port").set(set[1].strip)
				when /auth/i
					@ff.checkbox(:id, "email_smtp_auth_enable_").set if set[1].match(/on/i)
					@ff.checkbox(:id, "email_smtp_auth_enable_").clear if set[1].match(/off/i)
				when /user/i
					@ff.text_field(:name, "email_smtp_username").set(set[1].strip)
				when /pass/i
					@ff.text_field(:name, /email_smtp_password/).set(set[1].strip)
				end
			end
		end
		
		# Auto WAN Detection options - "autowan" : "on -ppptimeout 30 -dhcptimeout 30 -cycles 2 -continuous on"
		if info.has_key?('autowan')
			vars = info['autowan'].sub(/\A-/,'').split('-')
			vars.each do |item|
				set = item.split(' ')
				case set[0].strip
				when /on/i
					@ff.checkbox(:id, "auto_wan_detection_enabled_").set
				when /off/i
					@ff.checkbox(:id, "auto_wan_detection_enabled_").clear
				when /ppptimeout/i
					@ff.text_field(:name, "ppp_timeout").set(set[1].strip)
				when /dhcptimeout/i
					@ff.text_field(:name, "dhcp_timeout").set(set[1].strip)
				when /cycles/i
					@ff.text_field(:name, "number_of_cycles").set(set[1].strip)
				when /continu/i
					@ff.checkbox(:id, "continuous_trying_").set if set[1].match(/on/i)
					@ff.checkbox(:id, "continuous_trying_").clear if set[1].match(/off/i)
				end
			end
		end
		# Apply for the change
		@ff.link(:text,'Apply').click
		self.msg(rule_name,:info,'System Settings','Success!')    
	end
	
	#####################
	# Port Configuration#  
	#####################
	# Options - "port_config" : "-1 auto -2 auto -3 auto -4 10 Half Duplex"
	def port_configuration(rule_name, info)
		if self.advancedpage(rule_name, "port config") == false
			return
		end
		if info.has_key?("port_config")
			info['port_config'].sub(/\A-/,'').split('-').each do |item|
				portNum = item.split(' ')[0].strip.to_i - 1
				port = item.split(' ')[1].strip
				if validate("port_name_#{portNum}", port) == false
					self.msg(rule_name, :error, "Port Configuration", "No such option in Port #{portNum} for #{port}")
					return
				end
			end
		else
			self.msg(rule_name, :error, "Port Configuration", "No \"port_config\" key included in configuration. Aborted.")
			return
		end
		@ff.link(:text, "Apply").click
		# It takes awhile to apply, adding this allows the script to continue without breaking. 
		sleep 2
		@ff.refresh
		self.msg(rule_name, :info, "Port Configuration", "Success")
	end
	
	#####################
	# Date and Time     #  
	#####################
	# Options - "set" : "-zone mountain -dst on -dststart 3/11 23:50 -dstend 11/11 12:20 -offset 60 -atu on -protocol tod -update 24"
	# Options - "get" : "-zone -dst -dststart -dstend -offset -atu -protocol -update"
	# Options - "server" : "add pool.ntp.org"
	# Options - "server" : "del pool.ntp.org"
	# Options - "clock" : "-date 3/14/2009 -time 15:15:15"
    def time_set(stime)
        self.msg("Time Parse/Set", :debug, "Date and Time - Time Set", "Passed time: #{stime}")
        @ff.text_field(:name, "hour").set(stime[0])
        @ff.text_field(:name, "min").set(stime[1])
        @ff.text_field(:name, "sec").set(stime[2]) if stime[2] != nil
    end
    def date_set(sdate)
        self.msg("Date Parse/Set", :debug, "Date and Time - Date Set", "Passed date: #{sdate}")
        if sdate[0].to_i > 0 and sdate[0].to_i < 13
            @ff.select_list(:id, "month").select_value("#{sdate[0].to_i-1}")
        else
            self.msg("Date Parse/Set", :error, "Date and Time", "Invalid month specified in configuration.")
            return
        end
        begin
            @ff.select_list(:id, "day").select_value("#{sdate[1]}")
        rescue
            self.msg("Date Parse/Set", :error, "Date and Time", "Invalid day specified for month chosen.")
            return
        end
        if validate("year", sdate[2]) == false
            self.msg("Date Parse/Set", :error, "Date and Time", "Invalid day specified for month chosen.")
            return
        end
    end
	def date_and_time(rule_name, info)
		return if self.advancedpage(rule_name, "date and time") == false
		if info.has_key?("set")
			vars = info['set'].sub(/\A-/,'').split('-')
			vars.each do |item|
				set = item.split(' ')
				case set[0].strip
				when /zone/i
					if validate("time_zone", set[1]) == false
						self.msg(rule_name, :error, "Date and Time", "Unable to find time zone #{set[1].strip}")
						return
					end
				when /dst\z/i
					@ff.checkbox(:id, "is_dl_sav_").set if set[1].match(/on/i)
					@ff.checkbox(:id, "is_dl_sav_").clear if set[1].match(/off/i)
				when /dststart/i
					dateSet = set[1].split('/')
					timeSet = set[2].split(':')
					if validate("dst_mon_start", getMonth(dateSet[0].to_i)) == false
						self.msg(rule_name, :error, "Date and Time", "Invalid month specified in configuration.")
						return
					end
					if validate("dst_day_start", dateSet[1]) == false
						self.msg(rule_name, :error, "Date and Time", "Invalid day specified for month chosen.")
						return
					end
					if timeSet[0].to_i > -1 and timeSet[0].to_i < 25
						@ff.text_field(:name, "dst_hour_start").set(timeSet[0])
					else
						self.msg(rule_name, :error, "Date and Time", "Invalid hour specified.")
						return
					end
					if timeSet[1].to_i > -1 and timeSet[1].to_i < 60
						@ff.text_field(:name, "dst_min_start").set(timeSet[1])
					else
						self.msg(rule_name, :error, "Date and Time", "Invalid minute specified.")
						return
					end
				when /dstend/i
					dateSet = set[1].split('/')
					timeSet = set[2].split(':')
					if validate("dst_mon_end", getMonth(dateSet[0].to_i)) == false
						self.msg(rule_name, :error, "Date and Time", "Invalid month specified in configuration.")
						return
					end
					if validate("dst_day_end", dateSet[1]) == false
						self.msg(rule_name, :error, "Date and Time", "Invalid day specified for month chosen.")
						return
					end
					if timeSet[0].to_i > -1 and timeSet[0].to_i < 25
						@ff.text_field(:name, "dst_hour_end").set(timeSet[0])
					else
						self.msg(rule_name, :error, "Date and Time", "Invalid hour specified.")
						return
					end
					if timeSet[1].to_i > -1 and timeSet[1].to_i < 60
						@ff.text_field(:name, "dst_min_end").set(timeSet[1])
					else
						self.msg(rule_name, :error, "Date and Time", "Invalid minute specified.")
						return
					end
				when /offset/i
					if set[1].to_i > 0 and set[1].to_i < 121
						@ff.text_field(:name, "dst_offset").set(set[1].strip)
					else
						self.msg(rule_name, :error, "Date and Time", "Invalid offset value. Must be between 1 and 120.")
						return
					end
				when /atu/i
					@ff.checkbox(:id, "is_tod_enabled_").set if set[1].match(/on/i)
					@ff.checkbox(:id, "is_tod_enabled_").clear if set[1].match(/off/i)
				when /protocol/i
					@ff.radio(:id, "tod_prot_type_1").click if set[1].match(/tod/i)
					@ff.radio(:id, "tod_prot_type_2").click if set[1].match(/ntp/i)
				when /update/i
					if set[1].to_i > 0 and set[1].to_i < 481
						@ff.text_field(:name, "tod_update_period").set(set[1].strip)
					else
						self.msg(rule_name, :error, "Date and Time", "Invalid update time frame. Must be between 1 and 480.")
						return
					end
				end
			end
			readableFlags = self.humanReadable("date and time", info['set'])
			readableFlags.sub(/\A\|/,'').split('|').each do |item|
				set = item.split('=')
				self.msg(rule_name, :info, "Date and Time Set: #{set[0]}", "#{set[1]}")
			end
		end
		if info.has_key?("get")
			#  "-time -zone -dst -dststart -dstend -offset -atu -protocol -update -ntpserver1"
			info['get'].split(" ").each do |item|
				case item
				when /time/i
					# FixMe: Implement this. 
				when /ntpserver1/i
					@ff.link(:href, "javascript:mimic_button('edit_time_server: 0..', 1)").click
					self.msg(rule_name, :info, "Date and Time - Get Time Server 1", "#{@ff.text_field(:href, "tod_server").getContents}")
					@ff.link(:text, "Cancel").click
				when /zone/i
					self.msg(rule_name, :info, "Date and Time - Get Time Zone", "#{@ff.select_list(:id, "time_zone").getSelectedItems[0]}")
				when /dst\z/i
					@ff.checkbox(:id, "is_dl_sav_").checked? ? enabled = "On" : enabled = "Off"
					self.msg(rule_name, :info, "Date and Time - Get Daylight Saving Time", "#{enabled}")
				when /dststart/i
					dstStartValue = sprintf("%s %s %s:%s", 	@ff.select_list(:id, "dst_mon_start").getSelectedItems[0],@ff.select_list(:id, "dst_day_start").getSelectedItems[0],@ff.text_field(:name, "dst_hour_start").getContents,@ff.text_field(:name, "dst_min_start").getContents)
					self.msg(rule_name, :info, "Date and Time - Get DST Start", "#{dstStartValue}")
				when /dstend/i
					dstEndValue = sprintf("%s %s %s:%s", 	@ff.select_list(:id, "dst_mon_end").getSelectedItems[0],@ff.select_list(:id, "dst_day_end").getSelectedItems[0],@ff.text_field(:name, "dst_hour_end").getContents,@ff.text_field(:name, "dst_min_end").getContents)
					self.msg(rule_name, :info, "Date and Time - Get DST End", "#{dstEndValue}")
				when /offset/i
					self.msg(rule_name, :info, "Date and Time - Get DST Offset", "#{@ff.text_field(:name, "dst_offset").getContents} Minutes")
				when /atu/i
					@ff.checkbox(:id, "is_tod_enabled_").checked? ? enabled = "On" : enabled = "Off"
					self.msg(rule_name, :info, "Date and Time - Get Automatic Time Update", "#{enabled}")
				when /protocol/i
					@ff.radio(:id, "tod_prot_type_2").checked? ? enabled = "NTP" : enabled = "TOD"
					self.msg(rule_name, :info, "Date and Time - Get Time Protocol", "#{enabled}")
				when /update/i
					self.msg(rule_name, :info, "Date and Time - Get Update Interval", "#{@ff.text_field(:name, "tod_update_period").getContents} Hours")
				end
			end
		end
		if info.has_key?("server")
			@ff.link(:href, "javascript:mimic_button('add_time_server: ...', 1)").click
			@ff.text_field(:name, "tod_server").set(set[1].strip)
			@ff.link(:text, "Apply").click
			self.msg(rule_name, :info, "Date and Time - Added Server:", "#{set[1].strip}")
		end
		if info.has_key?("clock")
			@ff.link(:text, "Clock Set").click
            if info['clock'] == "-current"
                ct = Time.now.to_i
                date_set(format_date(ct).split('/'))
                time_set(format_time(ct).split(':'))
            else
                info['clock'].split('-').each do |item|
                    set = item.sub(/\A-/, '').split(' ')
                    case set[0]
                    when /current/i
                        ct = Time.now.to_i
                        if set[1] == nil
                            date_set(format_date(ct).split('/'))
                            time_set(format_time(ct).split(':'))
                        else
                            date_set(format_date(ct+(extract_offset(set[1].strip,set[2].strip))).split('/'))
                            time_set(format_time(ct+(extract_offset(set[1].strip,set[2].strip))).split(':'))
                        end
                    when /date/i
                        date_set(set[1].split('/'))
                    when /time/i
                        time_set(set[1].split(':'))
                    end
                end
            end
			@ff.link(:text, "Apply").click
			info['clock'].sub(/\A\-/,'').split('-').each do |item|
				set = item.split(' ')
				self.msg(rule_name, :info, "Date and Time Clock Set: #{set[0].capitalize}", "#{set[1]}")
			end
		end
		@ff.link(:text, "Apply").click
		self.msg(rule_name, :info, "Date and Time", "Success")
	end

	#####################
	# Protocols         #
	#####################
	def protocols_port_helper(rule_name, ports_list, add_link)
		# split ports in the list
		ports = ports_list.split(';')
		ports.each do |tempport|
			# Begin add
			@ff.link(:href, add_link).click

			# Data gathering
			protocol = tempport.split(':')
			c_port = protocol[1].split(',')

			if protocol[0].match(/\A~/)
				protocol[0].sub!(/\A~/,'')
				@ff.checkbox(:id, 'svc_entry_protocol_exclude_').click
			end

			# FixMe: While this supports every protocol, the rest of this method doesn't. Need to fix it.
			if validate("svc_entry_protocol", protocol[0]) == false
				self.msg(rule_name, :error, "Port Helper", "Unable to add protocol: #{protocol[0]}")
				return
			end

			# Set source port
			if c_port[0].include?('-')
				@ff.select_list(:id, 'port_src_combo').select('Range')
				if c_port[0].include?('~')
					@ff.checkbox(:id, "port_src_exclude_").click
					c_port[0].delete!('~')
				end
				sourcePorts = c_port[0].split('-')
				@ff.text_field(:name, 'port_src_start').set(sourcePorts[0])
				@ff.text_field(:name, 'port_src_end').set(sourcePorts[1])
			elsif c_port[0].upcase != 'ANY'
				@ff.select_list(:id, 'port_src_combo').select('Single')
				if c_port[0].include?('~')
					@ff.checkbox(:id, "port_src_exclude_").click
					c_port[0].delete!('~')
				end
				@ff.text_field(:name, 'port_src_start').set(c_port[0])
			end
			# Set destination port
			if c_port[1].include?('-')
				@ff.select_list(:id, 'port_dst_combo').select('Range')
				if c_port[1].include?('~')
					@ff.checkbox(:id, "port_dst_exclude_").click
					c_port[1].delete!('~')
				end
				destPorts = c_port[1].split('-')
				@ff.text_field(:name, 'port_dst_start').set(destPorts[0])
				@ff.text_field(:name, 'port_dst_end').set(destPorts[1])
			elsif c_port[1].upcase != 'ANY'
				@ff.select_list(:id, 'port_dst_combo').select('Single')
				if c_port[1].include?('~')
					@ff.checkbox(:id, "port_dst_exclude_").click
					c_port[1].delete!('~')
				end
				@ff.text_field(:name, 'port_dst_start').set(c_port[1])
			end
			@ff.link(:text, 'Apply').click
		end
	end

    def protocols(rule_name, info)
        unless info.has_key?("ports")
            self.msg(rule_name, :error, "Protocols", "Missing key \"ports\" for the port list to add a service.")
            return
        end
        return if self.advancedpage(rule_name, "protocols") == false
        @ff.link(:href, "javascript:mimic_button('add:%20...',%201)").click
        self.msg(rule_name, :debug, "Protocols", "Setting service name and description")
        @ff.text_field(:name, 'svc_name').set(info['name']) if info.has_key?('name')
        @ff.text_field(:name, 'svc_desc').set(info['description']) if info.has_key?('description')
        self.msg(rule_name, :debug, "Protocols", "Adding ports")
        self.protocols_port_helper(rule_name, info['ports'], "javascript:mimic_button('add_server_ports:%20...',%201)")
        self.msg(rule_name, :debug, "Protocols", "Applying..")
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :info, "Protocols", "Successfully added.")
    end

	#####################
    # Quality of Service#
    #####################
#{
#	"rulename": {
#		"section": "advanced-qos-input|output",
#		"device": "network (home/office)",
#		"source": "",
#		"destination": "",
#		"services": "User Defined",
#		"ports": "",
#		"set": "-dscp ##:## -priority # -packet|data_length ##:## -connection|packet -log on",
#		"operation": "-dscp ##:##|auto -priority #",
#		"schedule": {
#
#		},
#		"scanbuild": "on"
#	}
#}

	def qos_helper(rule_name, info)
		# Add Source/Dest PCs. Notice we don't need to change these at all if they aren't present.
        # Source
		if info['source'].is_a?(Hash)
            @ff.select_list(:id, 'sym_net_obj_src').select("User Defined")
            createObject(rule_name, info['source'], "Quality of Service")
        else
            unless validate("sym_net_obj_src", info['source'])
                self.msg(rule_name, :error, "Quality of Service", "Unable to find source object #{info['source']}")
                return false
            end
        end if info.has_key?('source')

		# Destination
		if info['destination'].is_a?(Hash)
            @ff.select_list(:id, 'sym_net_obj_dst').select("User Defined")
            createObject(rule_name, info['destination'], "Quality of Service")
        else
            unless validate("sym_net_obj_dst", info['destination'])
                self.msg(rule_name, :error, "Quality of Service", "Unable to find destination object #{info['destination']}")
                return false
            end
        end if info.has_key?('destination')

		# Services
		info['services'].split(',').each do |svc|
            if svc.match(/user defined/i)
                @ff.select_list(:id, 'svc_service_combo').select('User Defined')
                @ff.text_field(:name, 'svc_name').set(rule_name)
                self.add_ports(rule_name, info['ports'], 'Quality of Service', 'javascript:mimic_button(\'add_server_ports: ...\', 1)')
                # Click apply when it comes back
                @ff.link(:text, 'Apply').click
            else
                unless validate("svc_service_combo", svc)
                    self.msg(rule_name, :error, 'Quality of Service', "Unable to find service named #{svc}")
                    return false
                end
            end
        end if info.has_key?('services')
#		"set": "-dscp ##:## -priority # -packet|data_length ##:## -connection|packet -log on",

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
                    self.msg(rule_name, :error, "Quality of Service", "Unable to find priority level #{item.split(' ')[1]}")
                    return false
                end
            when /packet|data_length/i
                @ff.checkbox(:id, "length_check_box_").click
                unless validate("length_check_type", item.split(' ')[0])
                    self.msg(rule_name, :error, "Quality of Service", "Unable to find length option #{item.split(' ')[0]}")
                    return false
                end
                @ff.text_field(:name, 'length_check_from').set(item.split(' ')[1].split(":")[0])
                @ff.text_field(:name, 'length_check_to').set(item.split(' ')[1].split(":")[1])
            when /connection|packet/i
                unless validate("qos_on_conn", item.strip)
                    self.msg(rule_name, :error, "Quality of Service", "Unable to find operation: #{item.strip}")
                    return false
                end
            when /log/i
                @ff.checkbox(:id, 'rule_log_').click
            end
        end if info.has_key?("set")
        
        #		"operation": "-dscp ##:##|auto -priority # -rx class -tx class",
        info["operation"].split('-').each do |item|
            case item
            when /dscp/i
                @ff.checkbox(:id, "set_dscp_check_").click
                @ff.select_list(:id, "set_dscp").select("Specify")
                if item.include?(":")
                    @ff.text_field(:name, "qos_dscp_edit").set(item.split(' ')[1].split(":")[0])
                    @ff.text_field(:name, "qos_dscp_mask").set(item.split(' ')[1].split(":")[1])
                else
                    @ff.text_field(:name, "qos_dscp_edit").set(item.split(' ')[1])
                end
            when /priority/i
                @ff.checkbox(:id, 'set_priority_').click
                unless validate("qos_8021p_combo", item.split(' ')[1])
                    self.msg(rule_name, :error, "Quality of Service", "Unable to find priority level #{item.split(' ')[1]}")
                    return false
                end
            when /tx/i
                @ff.checkbox(:id, "set_tx_class_").click
                @ff.select_list(:id, "qos_tx_class_combo").select(item.split(" ")[1])
            when /rx/i
                @ff.checkbox(:id, "set_rx_class_").click
                @ff.select_list(:id, "qos_rx_class_combo").select(item.split(" ")[1])
            end
        end

		# Schedule the rule
		if info['schedule'].is_a?(Hash)
            # Get it into the scheduler first, and then call the scheduler function
            @ff.select_list(:id, 'schdlr_rule_id').select('User Defined')
            self.scheduler(rule_name, info['schedule'])
            # Scheduler should have returned without applying the rule, so let's apply
            @ff.link(:text, 'Apply').click
        else
            unless validate("schdlr_rule_id", info['schedule'])
                self.msg(rule_name, :error, 'Quality of Service', "Unable to find schedule: #{info['schedule']['times']}")
                return false
            end
        end if info.has_key?('schedule')

		# Apply
		@ff.link(:text, 'Apply').click
		# This is the secondary apply in case you're blocking everything (intentionally, we hope) or changing the DHCP pool
		@ff.link(:text, 'Apply').click if @ff.contains_text('Press Apply to confirm')
        return true
	end

	def qos_traffic_priority(rule_name, info)
        unless info['section'].match(/out|in/i)
            self.msg(rule_name, :error, "Quality of Service", "\"Section\" must include whether rule is Input or Output type.")
            return
        end
        unless info.has_key?('device')
            self.msg(rule_name, :error, "Quality of Service", "No defined network device to add a rule to.")
            return
        end
        return unless self.advancedpage(rule_name, "qos")

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
            self.msg(rule_name, :error, "Quality of Service", "No defined network device available named #{info['device']}")
            return
        end

        add_link.sub!("#", "#{value_index}")

        # Click Add for the current rule
        @ff.link(:href, add_link).click
        # And now call the helper
        self.msg(rule_name, :info, "Quality of Service", "Successfully added") if qos_helper(rule_name, info)
	end

    def qos_traffic_shaping(rule_name, info)
        return unless self.advancedpage(rule_name, "qos")
        @ff.link(:text, "Traffic Shaping").click
        @ff.link(:text, "Add").click
        unless validate("sym_qos_traffic_device_combo",info['device'])
            self.msg(rule_name, :error, "QoS", "Failed to find correct device for traffic shaping rule")
            return false
        end
        @ff.link(:text, "Apply").click
        add_count = 0
        policy = :strict
        # "tx_policy": "-bandwidth # -serialization # -class|-strict -add name priority# minbandwidth_maxbandwidth% -default priority#"
        # "rx_policy": "-bandwidth # -add name priority# minbandwidth_maxbandwidth%"
        info['tx_policy'].split('-').each do |v|
            case v
            when /bandwidth/i
                @ff.select_list(:id, "qos_tx_shaping_bandwidth_mode").select("Specify")
                @ff.text_field(:name, "sym_qos_shaping_tx_bandwidth").set(v.delete('^[0-9]'))
                policy = :class
            when /serialization/i
                @ff.select_list(:id, "sym_qos_shaping_tcp_ser_combo").select("Enabled")
                @ff.text_field(:name, "sym_qos_shaping_tcp_ser_edit").set(v.delete('^[0-9]'))
            when /class/i
                unless policy == :class
                    self.msg(rule_name, :error, "Quality of Service", "Can't set to class based queue policy without a bandwidth limit set first.")
                    return
                end
            when /strict/i
                @ff.select_list(:id, "sym_qos_shaping_queue_policy_combo").select("Strict Priority") if policy == :class
            when /add/i
                @ff.link(:href, "javascript:mimic_button('qos_class_add:%200..',%201)").click
                shaping_class = v.split(" ")
                @ff.text_field(:name, "qos_class_name").set(shaping_class[1])
                add_count += 1
                @ff.link(:text, "Apply").click
                @ff.link(:href, "javascript:mimic_button('qos_class_edit:%200%5F#{add_count}..',%201)").click
                @ff.select_list(:id, "qos_class_priority").select(class_shaping[2])
                if class_shaping[3].include?("_")
                    @ff.text_field(:name, "qos_min_bandwidth").set(class_shaping[3].split("_")[0].delete('^[0-9]'))
                    @ff.select_list(:id, "qos_max_bandwidth_combo").select("Specify")
                    @ff.text_field(:name, "qos_min_bandwidth").set(class_shaping[3].split("_")[1].delete('^[0-9]'))
                else
                    @ff.text_field(:name, "qos_min_bandwidth").set(class_shaping[3].delete('^[0-9]'))
                end
                @ff.select_list(:id, "qos_is_precentage").select("Percent") if class_shaping[3].include?("%")
                # FixMe: Policy goes here
                # FixMe: Schedule goes here
                @ff.link(:text, "Apply").click
            when /default/i
                @ff.select_list(:id, "qos_class_priority").select(v.delete('^[0-9]'))
                # FixMe: Policy goes here
                @ff.link(:text, "Apply").click
            end
        end if info.has_key?("tx_policy")
        add_count = -1
        info['rx_policy'].split("-").each do |v|
            case v
            when /bandwidth/i
                @ff.select_list(:id, "qos_rx_shaping_bandwidth_mode").select("Specify")
                @ff.text_field(:name, "sym_qos_shaping_rx_bandwidth").set(v.delete('^[0-9]'))
                policy = :class
            when /add/i
                when /add/i
                @ff.link(:href, "javascript:mimic_button('qos_class_add:%201..',%201)").click
                shaping_class = v.split(" ")
                @ff.text_field(:name, "qos_class_name").set(shaping_class[1])
                add_count += 1
                @ff.link(:text, "Apply").click
                @ff.link(:href, "javascript:mimic_button('qos_class_edit:%201%5F#{add_count}..',%201)").click
                @ff.select_list(:id, "qos_class_priority").select(class_shaping[2])
                if class_shaping[3].include?("_")
                    @ff.text_field(:name, "qos_min_bandwidth").set(class_shaping[3].split("_")[0].delete('^[0-9]'))
                    @ff.select_list(:id, "qos_max_bandwidth_combo").select("Specify")
                    @ff.text_field(:name, "qos_min_bandwidth").set(class_shaping[3].split("_")[1].delete('^[0-9]'))
                else
                    @ff.text_field(:name, "qos_min_bandwidth").set(class_shaping[3].delete('^[0-9]'))
                end
                @ff.select_list(:id, "qos_is_precentage").select("Percent") if class_shaping[3].include?("%")
                # FixMe: Schedule goes here
                @ff.link(:text, "Apply").click
            end
        end if info.has_key?("rx_policy")
        apply_settings(rule_name, "QoS")
        self.msg(rule_name, :info, "QoS", "Successfully added traffic shaping rule")
    end
    def qos(rule_name, info)
        case info['section']
        when /traffic\s*priority/i
            self.qos_traffic_priority(rule_name, info)
        when /traffic\s*shaping/i
            self.qos_traffic_shaping(rule_name, info)
        when /dscp\s*settings/i
            self.qos_dscp_settings(rule_name, info)
        when /802.1p\s*settings/i
            self.qos_8021p_settings(rule_name, info)
        when /class\s*statistics/i
            self.qos_class_stats(rule_name, info)
        when /class\s*identifier/i
            self.qos_class_id(rule_name, info)
        end
    end
end