# Taking a look at this, these methods are used to jump into the WAN PPPoE settings, but do so in a very lengthy way. 
# An easier method would be to create all of this under MyNetwork. This is a project for a later date. 

module MyNetwork

	def my_network_jumper(rule_name, info)
		case info['section']
		when /network.?status/i
			self.network_status(rule_name, info)
		when /network.?connections/i
			self.network_connections(rule_name, info)
        end
	end

    def network_status(rule_name, info)
        #FixMe: Implement
    end

    def lan_side_network(rule_name, info)

    end

    def wan_side_config(rule_name, info)

    end

    def wan_pppoe(rule_name, info)
        #FixMe: Implement
    end

    def full_status(rule_name, info)
        #FixMe: Implement
    end


    # network type and name: network = lan-network_name  or wan-network_name. i.e., lan-network (home/office) .. partial acceptable - lan-network
    # underlying device: u_device = ethernet
    # directives =
    # full_status = item_get
    # "device": "broadband connection (coax)"
    def network_connections(rule_name, info)
        # Vars needed for this section
        top = 2
        value_link = nil
        basic_status = []
        full_status = []
        network_name_path = "/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[?]/td/table/tbody/tr/td[2]/table/tbody/tr/td[2]/a"
        network_status_path = "/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[?]/td[2]"
        network_edit = "/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[?]/td[3]/center/table/tbody/tr/td/a/img"
        connection_name_path = "/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[?]/td"
        connection_status_path = "/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[?]/td[2]"


        @ff.text_field(:name, "description").set(description)
        # Get to Network Connections page under My Network
        return if self.my_network_page(rule_name, 'network connections') == false

        # Advanced status - this is always either advanced or basic, so we do a negative test against basic to see if we're already on advanced
        @ff.link(:text, "Advanced >>").click unless @ff.link(:text, "Basic <<").exists?

        # Build the array of connections and their status. We will use this to locate the edit button later.
        current_value = top
        while @ff.element_by_xpath(network_name_path.sub("?", "#{current_value}")).exists?
            basic_status << "#{@ff.element_by_xpath(network_name_path.sub("?", "#{current_value}")).text} - #{@ff.element_by_xpath(network_status_path.sub("?", "#{current_value}")).text}"
            current_value += 1
        end

        # Output status information if requested
        if info['status'].match(/all/i)
            basic_status.each { |stat| self.msg(rule_name, :info, "My Network - Network Status", stat) }
        else
            basic_status.each { |stat| self.msg(rule_name, :info, "My Network - Network Status", stat) if info['status'].downcase.match(/#{stat.downcase}/) }
        end if info.has_key?("status")
        
        if info.has_key?("device")
            # Find the device to click on
            basic_status.each_index { |x| value_link = x+top if info['device'].downcase.match(/#{basic_status[x].downcase}/) }
            if value_link.nil?
                self.msg(rule_name, :error, "My Network - Network Connections", "Unable to find device specified: #{info['device']}")
                return
            end
            # And then click on it
            @ff.link(:xpath, network_edit.sub("?", "#{value_link}")).click

            # Change the name if requested
            if info.has_key?("name")
                @ff.text_field(:name, "description").set(info['name'])
                apply_settings(rule_name, "My Network - Network Connections")
                # If we change the name we need to rebuild the name list and go back to its status page
                current_value = top
                basic_status.clear
                while @ff.element_by_xpath(network_name_path.sub("?", "#{current_value}")).exists?
                    basic_status << "#{@ff.element_by_xpath(network_name_path.sub("?", "#{current_value}")).text} - #{@ff.element_by_xpath(network_status_path.sub("?", "#{current_value}")).text}"
                    current_value += 1
                end
                basic_status.each_index { |x| value_link = x+top if info['device'].downcase.match(/#{basic_status[x].downcase}/) }
                @ff.link(:xpath, network_edit.sub("?", "#{value_link}")).click
            end
            current_value = top
            while @ff.element_by_xpath(network_name_path.sub("?", "#{current_value}")).exists?
                full_status << "#{@ff.element_by_xpath(connection_name_path.sub("?", "#{current_value}")).text} - #{@ff.element_by_xpath(connection_status_path.sub("?", "#{current_value}")).text}"
                current_value += 1
            end
            connection_type = full_status
        end
        # "options": "-mtu #|auto|dhcp -autodetect on|off -privacy on|off -password string -cmratio 0-100"
        # "ip": "-none|ip|dhcp -overridesubnet

    end
    #
    # wrapper function to call common pppoe code with
    # an argument of ether
    #
    def pppoe_ether(rule_name, info)
        ether_port =0 # ethernet
        self.pppoe(rule_name,info,ether_port)
    end

    #
    # wrapper function to call common pppoe code with
    # an argument of coax
    #
    def pppoe_coax(rule_name, info)
        coax_port =1 # coax
        pppoe(rule_name,info,coax_port)
    end

    #
    #   pppoe functions page
    #
    def pppoe(rule_name, info, wanport)

        #puts "wanport =" + wanport.to_s

        # jump to the main page
        #out['main'] = self.mainpage(rule_name, info)
        self.mainpage(rule_name, info)

        # click the system monitoring page
        begin
            @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fstatus..\', 1)').click
        rescue
            self.msg(rule_name, :error, 'pppoe', 'Did not reach System Monitoring page')
            return
        end

        # click the advanced status button
        begin
            @ff.link(:text, 'Advanced Status').click
        rescue
            self.msg(rule_name, :error, 'pppoe', 'Did not reach Advanced Status Confirmation page')
            return
        end

        # and the are you sure
        begin
            @ff.link(:text, 'Yes').click
        rescue
            self.msg(rule_name, :error, 'pppoe', 'Did not reach Advanced Status page')
            return
        end

        # click the full status link
        begin
            @ff.link(:text, 'Full Status/System wide Monitoring of Connections').click
        rescue
            self.msg(rule_name, :error, 'pppoe', 'Did not reach Connection Monitoring page')
            return
        end

        # click the Wan PPPoe button
        begin
            # is this pppoe for the Wan ethernet port
            if wanport == 0
               @ff.link(:href, 'javascript:mimic_button(\'goto_dev: ppp0..\', 1)').click
            elsif wanport == 1
               @ff.link(:href, 'javascript:mimic_button(\'goto_dev: ppp1..\', 1)').click
            else 
                self.msg(rule_name, :error, 'pppoe', 'Must specify the ethernet or coax port')
                return
            end
        rescue
            self.msg(rule_name, :error, 'pppoe', 'Did not reach PPPoe  page')
            return
        end

        # set the name if provided
        click_apply = false
        if info['action'] == 'set'
           if info.key?('name')
               @ff.text_field(:name,'description').set(info['name'])
               click_apply = true
               #@ff.link(:text, 'Apply').click
           end
           if info.key?('enable')
              if info['enable'] == 0
                  begin
                   @ff.link(:text, 'Disable').click
                   click_apply = true
                   #@ff.link(:text, 'Apply').click
                  rescue => e
                  end
              end
              # and enable/disable as needed
              if info['enable'] == 1
                  begin
                  puts " attempting to enable"
                   @ff.link(:text, 'Enable').click
                  puts " enabled"
                   click_apply = true
                   #@ff.link(:text, 'Apply').click
                  rescue => e
                  #puts " got enable exception"
                  end
              end
             
          end   
        end
        if click_apply == true
            # click the Wan PPPoe button
            begin
                @ff.link(:text, 'Apply').click
                # is this pppoe for the Wan ethernet port
                if wanport == 0
                   @ff.link(:href, 'javascript:mimic_button(\'goto_dev: ppp0..\', 1)').click
                elsif wanport == 1
                   @ff.link(:href, 'javascript:mimic_button(\'goto_dev: ppp1..\', 1)').click
                else 
                    self.msg(rule_name, :error, 'pppoe', 'Must specify the ethernet or coax port')
                    return
                end
            rescue => e
                self.msg(rule_name, :error, 'pppoe', 'Did not reach PPPoe  page')
            end
        end
        # and  click the Settings link
        begin
            @ff.link(:text, 'Settings').click
        rescue
            self.msg(rule_name, :error, 'pppoe', 'Did not reach PPP0 settings page')
            return
        end

        case info['action']
           when 'set'
              begin
                   if info.key?('timeout')
                      begin
                          self.msg(rule_name, :info, 'pppoe-timeout',"timeout is " + info['timeout'].to_s)
                          @ff.text_field(:name, 'reconnect_time').set(info['timeout'])
                      rescue
                          self.msg(rule_name, :error, 'pppoe-timeout', 'Did not set reconnect_time')
                          # reconnect timeout does not always exist
                          # for example when ip mode is none
                          #return out
                      end
                   end
                   if info.key?('network')
                       #puts "checking network"
                       #puts "selection is" + info['network']
                       case info['network']
                       when 'Broadband'
                           @ff.select_list(:name, 'network').select_value('1')
                           self.msg(rule_name, :info, 'pppoe-network', "network type is " + info['network'])
                       when 'Network'
                           @ff.select_list(:name, 'network').select_value('2')
                           self.msg(rule_name, :info, 'pppoe-network', "network type is " + info['network'])
                       when 'DMZ'
                           #puts "doing DMZ"
                           @ff.select_list(:name, 'network').select_value('4')
                           self.msg(rule_name, :info, 'pppoe-network', "network type is " + info['network'])
                       else 
                           self.msg(rule_name, :warning, 'pppoe-network', "Unknown network selection" + info['network'].to_s)
                           # should this be an error and continue so 
                           # other options are processed RJS
                           #return out
                       end
                   end
                  if info.key?('mtu_mode')
                       #puts "checking mtu_mode"
                       #puts "selection is " + info['mtu_mode']
                       case info['mtu_mode']
                       when 'Automatic'
                           @ff.select_list(:name, 'mtu_mode').select_value('1')
                           self.msg(rule_name, :info, 'pppoe-mtu_mode', "mtu_mode is Automatic")
                       when 'Manual'
                           @ff.select_list(:name, 'mtu_mode').select_value('0')
                           self.msg(rule_name, :info, 'pppoe-mtu_mode', "mtu mode is manual") 
                           if info.key?('mtu')
                               @ff.text_field(:name, 'mtu').set(info['mtu'])
                           self.msg(rule_name, :info, 'pppoe-mtu', "mtu is " + info['mtu']) 
                           else  
                               @ff.text_field(:name, 'mtu').set('1492')
                              self.msg(rule_name, :info, 'pppoe-mtu', "mtu is default of 1492") 
                           end
                       else
                           self.msg(rule_name, :info, 'pppoe-mtu_mode', "Unknown mtu selection" + info['network'].to_s)
                           return
                       end
                   end
                   if info.key?('connection')
                       #puts "checking underlying connection"
                       #puts "selection is " + info['connection']
                       case info['connection']
                       when 'Network'
                           @ff.select_list(:id, 'depend_on_name').select_value('br0')
                           self.msg(rule_name, :info, 'pppoe-connection', "underlying connection is " + info['connection'])
                       when 'Ethernet'
                           @ff.select_list(:id, 'depend_on_name').select_value('eth0')
                           self.msg(rule_name, :info, 'pppoe-connection', "underlying connection is " + info['connection'])
                       when 'Broadband/Ethernet'
                           @ff.select_list(:id, 'depend_on_name').select_value('eth1')
                           self.msg(rule_name, :info, 'pppoe-connection', "underlying connection is " + info['connection'])
                       when 'Coax'
                           @ff.select_list(:id, 'depend_on_name').select_value('clink0')
                           self.msg(rule_name, :info, 'pppoe-connection', "underlying connection is " + info['connection'])
                       when 'Broadband/Coax'
                           @ff.select_list(:id, 'depend_on_name').select_value('clink1')
                           self.msg(rule_name, :info, 'pppoe-connection', "underlying connection is " + info['connection'])
                       when 'Wireless'
                           @ff.select_list(:id, 'depend_on_name').select_value('ath0')
                           self.msg(rule_name, :info, 'pppoe-connection', "underlying connection is " + info['connection'])
                       else
                           self.msg(rule_name, :warning, 'pppoe-connection', "Unknown undelying selection" + info['connection'].to_s)
                           return
                       end
                   end
        
                    # set service name if it is provided
                   if info.key?('service_name')
                       #puts "checking on service_name"
                       #puts "selection is " + info['service_name'].to_s
                      @ff.text_field(:name,'service_name').set(info['service_name'])
                   end     

                   # set on demand if it exists
                   if info.key?('on_demand')
                       #puts "checking on Demand"
                       #puts "selection is " + info['on_demand'].to_s
                       if not @ff.checkbox(:id,'on_demand_')
                           # on_demand does not always eist so
                           # ensure it is there before trying to set 
                           # or clear it. ip none causes this.
                           # should move ip settings check first.
                           
                           #puts "on Demand exists"
                           case info['on_demand']
                           when 1 
                               @ff.checkbox(:id, 'on_demand_').set
                           when 0
                               @ff.checkbox(:id, 'on_demand_').clear
                           else
                               self.msg(rule_name, :warning, 'pppoe-on_demand', "Unknown undelying selection" + info['on_demand'].to_s)
                           #return
                           end
                       end
                   end

                   #
                   # set login
                   #
                   if info.key?('login')
                       #puts "checking on login"
                       #puts "selection is " + info['login'].to_s
                       @ff.text_field(:name,'ppp_username').set(info['login'])
                   end

                   #
                   # set password
                   #
                   if info.key?('password')
                       @ff.text_field(:name,/ppp_password_/).set(info['password'])
                       @ff.text_field(:name,/ppp_password_retype_/).set(info['password'])
                   end

                   sec_meth=["auth_pap","auth_chap","auth_mschapv1","auth_mschapv2"]
                   sec_meth.each do |auth|
                       if info.key?(auth)
                           #puts "checking on " + auth
                           #puts "selection is " + info[auth].to_s
                           case info[auth]
                           when 1
                               @ff.checkbox(:id,auth + '_').set
                           when 0
                               @ff.checkbox(:id,auth + '_').clear
                           else
                               self.msg(rule_name, :error, 'pppoe-'+auth, "Unknown security selection" + info[auth].to_s)
                               return
                           end
                       end
                   end
                   comp_meth=["comp_bsd","comp_deflate"]
                   comp_meth.each do |comp|
                       if info.key?(comp)
                           #puts "checking on " + comp
                           case info[comp]
                           when 'Reject'
                               @ff.select_list(:id,comp).select_value('0')
                               #puts "selection is " + info[comp].to_s
                           when 'Allow'
                               @ff.select_list(:id,comp).select_value('1')
                               #puts "selection is " + info[comp].to_s
                           when 'Require'
                               @ff.select_list(:id,comp).select_value('2')
                               #puts "selection is " + info[comp].to_s
                           else
                               self.msg(rule_name, :error, 'pppoe-'+comp, "Unknown security selection" + info[comp].to_s)
                               return
                           end
                       end
                   end
                   if info.key?('ip_settings')
                       #puts "checking on ip_settings" 
                       case info['ip_settings']
                       when 'None'
                           @ff.select_list(:id,'ip_settings').select_value('0')
                           #puts "selection is None"
                       when 'Manual'
                           @ff.select_list(:id,'ip_settings').select_value('1')
                           #puts "selection is Manual" 
                           if info['override'] == 0
                               @ff.checkbox(:id, 'override_subnet_mask_').clear
                           elsif info['override'] == 1
                               @ff.checkbox(:id, 'override_subnet_mask_').set
                           end
                           if info['ip_address'].size > 0
                               octets=info['ip_address'].split('.')
                               @ff.text_field(:name, 'static_ip0').set(octets[0])
                               @ff.text_field(:name, 'static_ip1').set(octets[1])
                               @ff.text_field(:name, 'static_ip2').set(octets[2])
                               @ff.text_field(:name, 'static_ip3').set(octets[3])
                           end
                           if info['netmask'].size > 0
                               octets=info['netmask'].split('.')
                               @ff.text_field(:name, 'static_netmask_override0').set(octets[0])
                               @ff.text_field(:name, 'static_netmask_override1').set(octets[1])
                               @ff.text_field(:name, 'static_netmask_override2').set(octets[2])
                               @ff.text_field(:name, 'static_netmask_override3').set(octets[3])
                           end 
                       when 'Automatic'
                           @ff.select_list(:id,'ip_settings').select_value('2')
                           if info['override'] == 0
                               @ff.checkbox(:id, 'override_subnet_mask_').clear
                           elsif info['override'] == 1
                               @ff.checkbox(:id, 'override_subnet_mask_').set
                            end
                           if info['netmask'].size > 0
                               octets=info['netmask'].split('.')
                               @ff.text_field(:name, 'static_netmask_override0').set(octets[0])
                               @ff.text_field(:name, 'static_netmask_override1').set(octets[1])
                               @ff.text_field(:name, 'static_netmask_override2').set(octets[2])
                               @ff.text_field(:name, 'static_netmask_override3').set(octets[3])
                           end 
                           #puts "selection is Automatic"
                       else
                           self.msg(rule_name, :error, 'pppoe-'+comp, "Unknown ip selection" + info[comp].to_s)
                           return
                       end
                   end
                   if info.key?('dns_option')
                       #puts "checking dns_option" 
                       case info['dns_option']
                       when 'Manual'
                           @ff.select_list(:id,'dns_option').select_value('0')
                           #puts "selection is Manual"
                           if info['primary_dns'].size > 0
                               octets=info['primary_dns'].split('.')
                               @ff.text_field(:name, 'primary_dns0').set(octets[0])
                               @ff.text_field(:name, 'primary_dns1').set(octets[1])
                               @ff.text_field(:name, 'primary_dns2').set(octets[2])
                               @ff.text_field(:name, 'primary_dns3').set(octets[3])
                           end 
                           if info['secondary_dns'].size > 0
                               octets=info['secondary_dns'].split('.')
                               @ff.text_field(:name, 'secondary_dns0').set(octets[0])
                               @ff.text_field(:name, 'secondary_dns1').set(octets[1])
                               @ff.text_field(:name, 'secondary_dns2').set(octets[2])
                               @ff.text_field(:name, 'secondary_dns3').set(octets[3])
                           end 
                       when 'Automatic'
                           @ff.select_list(:id,'ip_settings').select_value('1')
                           #puts "selection is Automatic" 
                       when 'None'
                           @ff.select_list(:id,'ip_settings').select_value('2')
                           #puts "selection is None" 
                       end
                  end
                   if info.key?('routing_mode')
                       #puts "checking routing_mode" 
                       case info['routing_mode']
                       when 'Route'
                           @ff.select_list(:id,'route_level').select_value('1')
                           #puts "selection is Route"
                       when 'NAPT'
                           @ff.select_list(:id,'route_level').select_value('4')
                       end
                  end
                  if info.key?('route_metric')
                      @ff.text_field(:name, 'route_metric').set(info['route_metric'])
                  end
 
                  # check default route checkbox
                  if info['default_route'] == 0
                      @ff.checkbox(:id, 'default_route_').clear
                  elsif info['default_route'] == 1
                      @ff.checkbox(:id, 'default_route_').set
                  end
                  # check default route checkbox
                  if info['igmp'] == 0
                      @ff.checkbox(:id, 'is_igmp_enabled_').clear
                  elsif info['igmp'] == 1
                      @ff.checkbox(:id, 'is_igmp_enabled_').set
                  end

                  # check firewallcheckbox
                  begin
                  if info['firewall'] == 0
                      @ff.checkbox(:id, 'is_trusted_').clear
                  elsif info['firewall'] == 1
                      @ff.checkbox(:id, 'is_trusted_').set
  
                  end
                  rescue => e
                  # trap exceptions as firewall is not always there
                  end
              end 
              # set the apply
              begin
                  @ff.link(:text, 'Apply').click
              rescue
                  self.msg(rule_name, :error, 'pppoe', 'Did not reach advanced Status page')
                  return
              end
        when 'get':
              begin
                puts "doing get"
                out = {}
                out['action'] = 'get' 
                out['section'] = info['section']
                netval = @ff.select_list(:id,'network').value
                case netval
                when '1'
                    out['network'] = 'Broadband'
                when '2'
                    out['network'] = 'Network'
                when '4'
                    out['network'] = 'DMZ'
                end
                mtu = @ff.select_list(:id,'mtu_mode').value
                case mtu
                when '0'
                    out['mtu_mode'] = 'Manual'
                when '1'
                    out['mtu_mode'] = 'Automatic'
                end

                begin
                if  @ff.text_field(:name,'mtu')
                   out['mtu'] = @ff.text_field(:name, 'mtu').value
                end
                rescue => e
                end

                conn= @ff.select_list(:id,'depend_on_name').value
                case conn 
                when 'br0'
                    out['connection'] = 'Network'
                when 'eth0'
                    out['connection'] = 'Ethernet'
                when 'eth1'
                    out['connection'] = 'Broadband/Ethernet'
                when 'clink0'
                    out['connection'] = 'Coax'
                when 'clink1'
                    out['connection'] = 'Broadband/Coax'
                when 'ath0'
                    out['connection'] = 'Wireless'
                end

                if  @ff.checkbox(:id,'on_demand_')
                    if @ff.checkbox(:id,'on_demand_').checked?
                       out['on_demand'] = 1
                    else
                       out['on_demand'] = 0
                    end
                end

                out['login'] = @ff.text_field(:name,'ppp_username').value
                #out['password'] = @ff.text_field(:name,/ppp_password/).value
                out['password'] = "*******"

                sec_meth=["auth_pap","auth_chap","auth_mschapv1","auth_mschapv2"]
                sec_meth.each do |auth|
                    if  @ff.checkbox(:id,auth + '_').checked?
                       out[auth] = 1
                    else
                       out[auth] = 0
                    end
 
                end
                comp_meth=["comp_bsd","comp_deflate"]
                comp_meth.each do |comp|
                    case @ff.select_list(:id,comp).value
                    when '0'
                        out[comp] = 'Reject'
                    when '1'
                        out[comp] = 'Allow'
                    when '2'
                        out[comp] = 'Require'
                    end
                end
             
                case @ff.select_list(:id,'ip_settings').value
                when '0'
                    out['ip_settings'] = 'None'
                when '1'
                    out['ip_settings'] = 'Manual'
                when '2'
                    out['ip_settings'] = 'Automatic'
                end
               
                begin 
                if @ff.text_field(:name, 'static_ip0')
                out['ip_address'] = @ff.text_field(:name, 'static_ip0').value + '.' +
                                    @ff.text_field(:name, 'static_ip1').value + '.' +
                                    @ff.text_field(:name, 'static_ip2').value + '.' +
                                    @ff.text_field(:name, 'static_ip3').value 
                end
                rescue => e
                # trap the exception if these fields don't exist
                end
                
                begin
                #if  @ff.text_field(:name, 'static_netmask_override0')
                puts "building netmask"
                out['netmask'] = @ff.text_field(:name, 'static_netmask_override0').value + '.' +
                                    @ff.text_field(:name, 'static_netmask_override1').value + '.' +
                                    @ff.text_field(:name, 'static_netmask_override2').value + '.' +
                                    @ff.text_field(:name, 'static_netmask_override3').value 
                #end
                rescue => e
                # trap the exception if these fields don't exist
                end
                case @ff.select_list(:id,'dns_option').value
                when '0'
                    out['dns_option'] = 'Manual'
                when '1'
                    out['dns_option'] = 'Automatic'
                when '2'
                    out['dns_option'] = 'None'

                end

                begin
                #if  @ff.text_field(:name, 'static_netmask_override0')
                puts "building primary dns"
                out['primary_dns'] = @ff.text_field(:name, 'primary_dns0').value + '.' +
                                    @ff.text_field(:name, 'primary_dns1').value + '.' +
                                    @ff.text_field(:name, 'primary_dns2').value + '.' +
                                    @ff.text_field(:name, 'primary_dns3').value 
                rescue => e
                # trap the exception if these fields don't exist
                end

                begin
                #if  @ff.text_field(:name, 'static_netmask_override0')
                puts "building secondary dns"
                out['secondary_dns'] = @ff.text_field(:name, 'secondary_dns0').value + '.' +
                                    @ff.text_field(:name, 'secondary_dns1').value + '.' +
                                    @ff.text_field(:name, 'secondary_dns2').value + '.' +
                                    @ff.text_field(:name, 'secondary_dns3').value 
                rescue => e
                # trap the exception if these fields don't exist
                end

                if @ff.select_list(:id,'route_level').value == '1'
                    out['routing_mode'] = 'Route'
                end
                if @ff.select_list(:id,'route_level').value == '4'
                    out['routing_mode'] = 'NAPT'
                end
                out['route_metric'] =@ff.text_field(:name, 'route_metric').value

                if @ff.checkbox(:id, 'default_route_').checked?
                    out['default_route'] = 1
                else
                    out['default_route'] = 0
                end

                if @ff.checkbox(:id, 'is_igmp_enabled_').checked?
                    out['igmp'] = 1
                else
                    out['igmp'] = 0
                end

                begin
                    if @ff.checkbox(:id,'is_trusted_').checked?
                        out['firewall'] = 1
                    else
                        out['firewall'] = 0
                    end
                rescue => e
                # trap firewall not there exception
                end
            end
        end
        @out[rule_name] = out
        return
        #begin
        #    @ff.link(:text, 'Apply').click
        #rescue
        #    out['Error'] = 'Did not reach advanced Status page'
        #    return out
        #end
        #return out
    end
end