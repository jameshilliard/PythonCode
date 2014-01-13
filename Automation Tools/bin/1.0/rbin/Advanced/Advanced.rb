#*****************************************************************
#
#     File:        Advanced.rb
#     Author:      Su He
#     Date:        2009.02.20
#     Contact:     shqa@actiontec.com
#     Discription: Advanced part configuration of BHR2 test case
#     Input:       N\A
#     Output:      the configuration of Advanced test case of test plan
#              
#*****************************************************************

$dir = File.dirname(__FILE__) 
require $dir+ '/../BasicUtility'


class Advanced < BasicUtility
  
  #----------------------------------------------------------------------
  # advanced(rule_name,info)
  # Description: main function of advanced options page
  #              All function under "Advanced" page need enter here.
  #----------------------------------------------------------------------  
  def advanced(rule_name, info)
    
    # Offset under "Advanced" will be called here.
    
    # Check for "Advanced", here the letter case is sensitive.
    if info.has_key?('section')
      if info['section'] != "advanced"
        self.msg(rule_name,:eroor,'advanced','Json block did NOT have \'Advanced\' value.')
        return
      end
    else
      # No "section" key.
      self.msg(rule_name,:error,'advanced','Json block did NOT have \'section\' key.')
      return
    end
    
    # Check for the key "subsection"
    if info.has_key?('subsection')
      
      case info['subsection']
        when 'Diagnostics'
          diagnostics(rule_name,info)
        when 'Restore Defaults'
          restore_defaults(rule_name,info)
        when 'Reboot Router'
          reboot_router(rule_name,info)
        when 'MAC Cloning'
          mac_cloning(rule_name,info)
        when 'ARP Table'
          arp_table(rule_name,info)
        when 'Users'
          users(rule_name,info)
        when 'Quality of Service(QoS)'
          qos(rule_name,info)
        when 'IGMP Proxy'
          igmp(rule_name,info)
        when 'Local Administration'
          local_administration(rule_name,info)
        when 'Remote Administration'
          remote_administration(rule_name,info)
        when 'Dynamic DNS'
          dynamic_dns(rule_name,info)
        when 'DNS Server'
          dns_server(rule_name,info)
        when 'Network Objects'
          network_objects(rule_name,info)
        when 'Universal Plug and Play'
          universal_plug_and_play(rule_name,info)
        when 'SIP ALG'
          sip_alg(rule_name,info)
        when 'MGCP ALG'
          mgcp_alg(rule_name,info)
        when 'Protocols'
          protocols(rule_name,info)
        when 'Configuration File'
          configuration_file(rule_name,info)
        when 'System Settings'
          system_settings(rule_name,info)
        when 'Port Configuration'
          port_configuration(rule_name,info)
        when 'Date and Time'
          date_and_time(rule_name,info)
        when 'Scheduler Rules'
          scheduler_rules(rule_name,info)
        when 'Firmware Upgrade'
          firmware_upgrade(rule_name,info)
        when 'Routing'
          routing(rule_name,info)
        when 'IP Address Distribution'
          ip_address_distribution(rule_name,info)
        else
          # Wrong here.
          self.msg(rule_name,:error,'advanced','No subsection case')
      end # end case 
    
    else
    
      # No "subsection" key.
      self.msg(rule_name,:error,'advanced','json block did NOT have \'subsection\' key.')
      return
      
    end # end of if info...
    
  end # end of def
  
  #----------------------------------------------------------------------
  # goto_advanced(rule_name,info)
  # Discription: Jump to the advanced options page
  #----------------------------------------------------------------------  
  def goto_advanced(rule_name, info)
  
    # Click the advanced link.
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5Fadv%5Fsetup../).click
    rescue
      self.msg(rule_name, :error, 'Goto Advanced', 'Did not reach "Advanced" page')
      return
    end

    # Look for the confirmation page's text   
    if not @ff.text.include? 'Any changes made in this section'
      self.msg(rule_name, :error, 'Goto Advanced', 'Did not reach are you sure page')
      return
    end
  
    # Sure?
    begin
      @ff.link(:text, 'Yes').click
    rescue
      self.msg(rule_name, :error, 'Goto Advanced', 'Did not reach confirmation page')
      return
    end
  
    self.msg(rule_name, :info, 'Goto Advanced', 'Reached the main \'Advanced\' page')
    
  end # end of def


  # *********************************
  #   IGMP Proxy section: BEGIN
  # *********************************
  
  #----------------------------------------------------------------------------
  # igmp(rule_name, info)
  # Description: Function of "IGMP Proxy" under "Advanced" page.
  #----------------------------------------------------------------------------
  def igmp(rule_name, info)

    # Go to the advanced page
    self.goto_advanced(rule_name, info)
    
    # Get to the "Diagnostics" page.
    begin
      @ff.link(:text, 'IGMP Proxy').click
      self.msg(rule_name, :info, 'Go to \'IGMP Proxy\' page', 'Done!')
    rescue
      self.msg(rule_name, :error, 'Go to \'IGMP Proxy\' page', 'Wrong!')
      return
    end    
     
    # Check for the keys
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'igmp','Some key NOT found.')
      return
    end   
    
    # "IGMP Proxy (Enable/Disable)"
    if info.has_key?('IGMP Proxy (Enable/Disable)')
      case info['IGMP Proxy (Enable/Disable)']
      when 'Enabled'
        @ff.select_list(:id, 'sym_igmp_proxy_config').select_value('1')
        self.msg(rule_name, :info, 'IGMP Proxy (Enable/Disable)', 'Enabled')
      when 'Disabled'
        @ff.select_list(:id, 'sym_igmp_proxy_config').select_value('0')
        self.msg(rule_name, :info, 'IGMP Proxy (Enable/Disable)', 'Disabled')
      else
        self.msg(rule_name, :error, 'igmp proxy', 'unknown option')
        return
      end
    end  
    
   # IGMPv1, IGMPv2 or IGMPv3?
    if info.has_key?('IGMP Proxy Querier Version')
      case info['IGMP Proxy Querier Version']
      when 'IGMPv1'
        @ff.select_list(:id, 'sym_igmp_proxy_qcm').select_value("1")
        self.msg(rule_name, :info, 'IGMP Proxy Querier Version', 'IGMPv1')
      when 'IGMPv2'
        @ff.select_list(:id, 'sym_igmp_proxy_qcm').select_value("2")
        self.msg(rule_name, :info, 'IGMP Proxy Querier Version', 'IGMPv2')
      when 'IGMPv3'
        @ff.select_list(:id, 'sym_igmp_proxy_qcm').select_value("3")
        self.msg(rule_name, :info, 'IGMP Proxy Querier Version', 'IGMPv3')
      else
        self.msg(rule_name, :error, 'IGMP Proxy Querier Version', 'unknown version')
      end
    end  
    
    # Output the result in page.
    
    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Upstream Interface' and
           t.text.include? 'Upstream Multicast Filtering' and 
           ( not t.text.include? 'IGMP Proxy Querier Version') and
           t.row_count > 2 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'IGMP Proxy','Did NOT find the target table.')
      return
    end
    
    i = 0
    # Find the row
    sTable.each do |row|
      
      # not for first line
      if row.text.include?'Upstream Multicast Filtering' then
        next
      end
      
      # not for second line
      if row.text.include?'Upstream Interface' then
        next
      end      
      
      # not for last line
      if row.text.include?'New Multicast Address' then
        next
      end
      
      i = i+1
      strUpstreamInterface = "Upstream Interface" + i.to_s
      strMulticastAddress = "Multicast Address" + i.to_s
      strIPSubnet = "IP Subnet" + i.to_s
      
      # Find the cell
      self.msg(rule_name,:info,strUpstreamInterface,row[1])
      self.msg(rule_name,:info,strMulticastAddress,row[2])
      self.msg(rule_name,:info,strIPSubnet,row[3])
      
    end
    
    # Apply for the change.
    @ff.link(:text,'Apply').click
    
    # Output the result.
    self.msg(rule_name,:info,'IGMP Proxy','SUCCESS')    
    
  end # end of def
 
  
  #----------------------------------------------------------------------------
  # igmp_prototype(rule_name, info)
  # Discription: Prototype of function "IGMP Proxy", written by Gordon, remain
  #              here for use.
  #----------------------------------------------------------------------------
  def igmp_prototype(rule_name, info)

    # get to the advanced page
    self.goto_advanced(rule_name, info)
    
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
    
  
  # *********************************
  #   IGMP Proxy section: END
  # *********************************

        
  # *************************
  #   QOS section: BEGIN
  # *************************

   def qos_add_host(rule_name,data)
            host_list = data.split(',')
            self.msg(rule_name, :debug, 'qos_add_host', "host_list" +host_list.to_s)
            host_list.each do |host|
            self.msg(rule_name, :debug, 'qos_add_host', "processing host" +host.to_s)
           @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
           @ff.select_list(:name, 'net_obj_type').select_value('8')
            if host.size > 0
               self.msg(rule_name, :debug, 'qos_add_host', "set host" +host)
               @ff.text_field(:name, 'hostname').set(host.strip)
               @ff.link(:text, 'Apply').click
            end
           end
        end

        def qos_add_dhcp_option(rule_name,data)

            dhcp_list = data.split(',')
            self.msg(rule_name, :debug, 'qos_add_dhcp_option', "dhcp_list" +dhcp_list.to_s)
            dhcp_list.each do |dhcp|
            self.msg(rule_name, :debug, 'qos_add_dhcp_option', "processing dhcp_option" +dhcp.to_s)
           @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
           @ff.select_list(:name, 'net_obj_type').select_value('64')
            if dhcp.size > 0
               dhcp_opts=dhcp.split(':')
               if dhcp_opts[0] == "Vendor"
                  @ff.select_list(:name, 'dhcp_opt_code').select_value('60')
               end
               if dhcp_opts[0] == "Client"
                  @ff.select_list(:name, 'dhcp_opt_code').select_value('61')
               end
               if dhcp_opts[0] == "User"
                  @ff.select_list(:name, 'dhcp_opt_code').select_value('77')
               end
               self.msg(rule_name, :debug, 'qos_add_dhcp_option', "set dhcp" +dhcp)
               @ff.text_field(:name, 'dhcp_opt_type').set(dhcp_opts[1].strip)
               @ff.link(:text, 'Apply').click
            end
           end
       end
  
  #----------------------------------------------------------------------------------
  # qos_add_ip
  # Discription: Inside functions, add ip item.
  #----------------------------------------------------------------------------------
  def qos_add_ip(rule_name,data)
    
    addr_list = data.split(',')
    self.msg(rule_name, :debug, 'qos_add_rule', "addr_list" +addr_list.to_s)
    
    addr_list.each do |ip_data|
      
      self.msg(rule_name, :debug, 'qos_add_rule', "processing address" +ip_data.to_s)
      @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
      @ff.select_list(:name, 'net_obj_type').select_value('1')
      
      if ip_data.size > 0
        
         self.msg(rule_name, :debug, 'qos_add_rule', "set ip address" +ip_data)
         str_ip_data = ip_data.strip
         octets=str_ip_data.split('.')
         @ff.text_field(:name, 'ip0').set(octets[0])
         @ff.text_field(:name, 'ip1').set(octets[1])
         @ff.text_field(:name, 'ip2').set(octets[2])
         @ff.text_field(:name, 'ip3').set(octets[3])
         @ff.link(:text, 'Apply').click
         
      end # end of if
   
    end # end of each
    
  end # end of def...
  
  #----------------------------------------------------------------------------------
  # qos_add_2_ip
  # Discription: Inside functions, add IP range or IP subnet.
  #----------------------------------------------------------------------------------
  def qos_add_2_ip(rule_name,data,sub_or_range)
  
    if sub_or_range == 1
        addr_list = data.split(',')
        input_base = 'subnet'
        select_val ='16'
    else
        addr_list = data.split(',')
        input_base = 'range'
        select_val ='2'
    end
    
    self.msg(rule_name, :debug, 'qos_add_rule', "addr_list" +addr_list.to_s)
    
    addr_list.each do |dual_ip_data|
      
      self.msg(rule_name, :debug, 'qos_add_rule', "processing address" +dual_ip_data.to_s)
      @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
      @ff.select_list(:name, 'net_obj_type').select_value(select_val)
      ip_data=dual_ip_data.split('/')
      
      if ip_data[0].size > 0 and ip_data[1].size > 0
        
         self.msg(rule_name, :debug, 'qos_add_rule', "set ip " + input_base +": " \
                                                   + ip_data[0] + "/" + ip_data[1])
         str_ip_data = ip_data[0].strip
         octets=str_ip_data.split('.')
         @ff.text_field(:name, input_base +'_00').set(octets[0])
         @ff.text_field(:name, input_base +'_01').set(octets[1])
         @ff.text_field(:name, input_base +'_02').set(octets[2])
         @ff.text_field(:name, input_base +'_03').set(octets[3])
         
         # set the subnet or range
         str_ip_data = ip_data[1].strip
         octets=str_ip_data.split('.')
         @ff.text_field(:name, input_base +'_10').set(octets[0])
         @ff.text_field(:name, input_base +'_11').set(octets[1])
         @ff.text_field(:name, input_base +'_12').set(octets[2])
         @ff.text_field(:name, input_base +'_13').set(octets[3])
  
         @ff.link(:text, 'Apply').click
         
       end # end of if..
          
    end # end of each...

  end # end of def...
 
  #----------------------------------------------------------------------------------
  # qos_add_mac
  # Discription: Inside functions, add mac address.
  #----------------------------------------------------------------------------------
  def qos_add_mac(rule_name,data)
    
    addr_list = data.split(',')
    self.msg(rule_name, :debug, 'qos_add_rule', "addr_list" +addr_list.to_s)
    
    addr_list.each do |dual_mac_data|
      
      self.msg(rule_name, :debug, 'qos_add_rule', "processing mac address" +dual_mac_data.to_s)
      
      @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
      @ff.select_list(:name, 'net_obj_type').select_value("4")
      mac_data=dual_mac_data.split('/')
      
      if mac_data.length > 0 and mac_data.length < 3
         
        if mac_data[0].size > 0 
           self.msg(rule_name, :debug, 'qos_add_rule', "set mac " + mac_data[0])
           str_mac_data = mac_data[0].strip
           octets=str_mac_data.split(':')
           @ff.text_field(:name, 'mac0').set(octets[0])
           @ff.text_field(:name, 'mac1').set(octets[1])
           @ff.text_field(:name, 'mac2').set(octets[2])
           @ff.text_field(:name, 'mac3').set(octets[3])
           @ff.text_field(:name, 'mac4').set(octets[4])
           @ff.text_field(:name, 'mac5').set(octets[5])
        end # end of if...
        
       end # end of if mac_data.len...
       
       if mac_data.length == 2
         
         if mac_data[1].size > 0
           
           self.msg(rule_name, :debug, 'qos_add_rule', "set mac mask" + mac_data[1])
           # set the mask
           str_mac_data = mac_data[1].strip
           octets=str_mac_data.split(':')
           @ff.text_field(:name, 'mac_mask0').set(octets[0])
           @ff.text_field(:name, 'mac_mask1').set(octets[1])
           @ff.text_field(:name, 'mac_mask2').set(octets[2])
           @ff.text_field(:name, 'mac_mask3').set(octets[3])
           @ff.text_field(:name, 'mac_mask4').set(octets[4])
           @ff.text_field(:name, 'mac_mask5').set(octets[5])
           
         end

       end
          
       @ff.link(:text, 'Apply').click
           
     end # end of addr_list.each...
     
  end # end of def...

def qos_user_defined_proto(rule_name,proto_info)
  
     self.msg(rule_name, :debug, 'qos_add_rule', "usser defined info = " +proto_info.to_s)
     @ff.select_list(:name, 'svc_service_combo').select("User Defined")
       self.msg(rule_name, :debug, 'qos_add_rule', "selected user defined")
       #@ff.link(:href, 'javascript:mimic_button(\'add: '+idx.to_s+'%5F..\', 1)').click
       #@ff.link(:href,'javascript:mimic_button(\'add_server_ports: ...\',1)').click
       proto_info.each do |proto_instance| 
          @ff.link(:text,'Add Server Ports').click
          proto_vals =  proto_instance.split(':')
          if proto_vals[0] == 'tcp' or proto_vals[0] == '~tcp' or
             proto_vals[0] == 'udp' or proto_vals[0] == '~udp' 
             # forms are tcp:sport,dport
             # tcp:sport-sport,port
             # tcp:sport-sport,dport-dport
             # tcp:sport-sport,dport
             # each of thiese can alos be precedded by a tilde (~)
             # to signify exclusion
             # e.g. ~tcp:~10-20,~30-40
  
             tcp_ports = proto_vals[1].split(',') 
  
             # select udp or tcp
             if proto_vals[0].include?('tcp')
                 @ff.select_list(:name, 'svc_entry_protocol').select('TCP')
             elsif proto_vals[0].include?('udp')
                 @ff.select_list(:name, 'svc_entry_protocol').select('UDP')
             end
             # check to see if protocol is excluded
             if proto_vals[0].include?('~')
                 @ff.label(:for, 'svc_entry_protocol_exclude_').click
                 self.msg(rule_name, :debug, 'qos_add_rule', "set proto exlude")
             end
  
             # deal with the src ports
             # is this a single port definition or Range
             exclude = false
              self.msg(rule_name, :debug, 'qos_add_rule', "src port= "+ tcp_ports[0])
             if tcp_ports[0].include?('any')
                 @ff.select_list(:name, 'port_dst_combo').select('Any')
             else
                 if tcp_ports[0].include?('~')
                     # src ports/range are excluded strip the ~ before
                     # configuring the port numbers
                     exclude = true
                     tcp_ports[0].delete!('~')
                 end
                 if tcp_ports[0].include?('-')
                     @ff.select_list(:name, 'port_src_combo').select('Range')
                      range= tcp_ports[0].split('-') 
                     @ff.text_field(:name, 'port_src_start').set(range[0].strip)
                     @ff.text_field(:name, 'port_src_end').set(range[1].strip)
                 elsif tcp_ports[0] != 'any'
                     @ff.select_list(:name, 'port_src_combo').select('Single')
                     @ff.text_field(:name, 'port_src_start').set(tcp_ports[0].strip)
                 end
                 if exclude == true
                     # src ports/range are excluded set exclude which is 
                     # available after single or range is selected
                     @ff.label(:for, 'port_src_exclude_').click
                 end
              end
              self.msg(rule_name, :debug, 'qos_add_rule', "set src port")
  
             # deal with the destination ports
             # is this a single port definition or Range
             exclude = false
             if tcp_ports[1].include?('any')
                 @ff.select_list(:name, 'port_dst_combo').select('Any')
             else
                 if tcp_ports[1].include?('~')
                     # src ports/range are excluded strip the ~ before 
                     # configuring the port numbers
                     exclude = true
                     tcp_ports[1].delete!('~')
                 end
                 if tcp_ports[1].include?('-')
                     @ff.select_list(:name, 'port_dst_combo').select('Range')
                     range= tcp_ports[1].split('-') 
                     @ff.text_field(:name, 'port_dst_start').set(range[0].strip)
                     @ff.text_field(:name, 'port_dst_end').set(range[1].strip)
                 else
                     @ff.select_list(:name, 'port_dst_combo').select('Single')
                     @ff.text_field(:name, 'port_dst_start').set(tcp_ports[1].strip)
                 end
                 if exclude == true
                    # dest ports/range are excluded chck excluded which is avail
                    # once range or single is selected
                    @ff.label(:for, 'port_dst_exclude_').click
                    self.msg(rule_name, :debug, 'qos_add_rule', "set dst exclude")
                 end
             end
             @ff.link(:text, 'Apply').click
          end # end tcp or udp
          if proto_vals[0].include?('icmp')
              @ff.select_list(:name, 'svc_entry_protocol').select('ICMP')
              if proto_vals[0].include?('~')
                     # icmp is excluded
                     @ff.label(:for,'svc_entry_protocol_exclude_').click
              end
              if  proto_vals[1].include?('Other')
                  @ff.select_list(:name, 'icmp_combo').select('Other')
                  types = proto_vals[1].split(",")
                  @ff.text_field(:name, 'icmp_type').set(types[1].strip)
                  @ff.text_field(:name, 'icmp_code').set(types[2].strip)
                  
              else
                  types =@ff.select_list(:name, 'icmp_combo').getAllContents
                 if types.include?(proto_vals[1])
                     @ff.select_list(:name, 'icmp_combo').select(proto_vals[1])
                 else
                    self.msg(rule_name, :debug, 'qos_add_rule', "icmp message type " + proto_vals[1] + " not found")
                    self.msg(rule_name, :error, 'qos_add_rule', "icmp message type " + proto_vals[1] + " not found")
  
                 end
              
              end
          @ff.link(:text, 'Apply').click
          end # end icmp
          if proto_vals[0].include?('GRE')
              @ff.select_list(:name, 'svc_entry_protocol').select('GRE')
              if proto_vals[0].include?('~')
                     # icmp is excluded
                     @ff.label(:for,'svc_entry_protocol_exclude_').click
              end
              @ff.link(:text, 'Apply').click
          end
          if proto_vals[0].include?('ESP')
              @ff.select_list(:name, 'svc_entry_protocol').select('ESP')
              if proto_vals[0].include?('~')
                     # icmp is excluded
                     @ff.label(:for,'svc_entry_protocol_exclude_').click
              end
              @ff.link(:text, 'Apply').click
          end
          if proto_vals[0].include?('AH')
              @ff.select_list(:name, 'svc_entry_protocol').select('AH')
              if proto_vals[0].include?('~')
                     # icmp is excluded
                     @ff.label(:for,'svc_entry_protocol_exclude_').click
              end
              @ff.link(:text, 'Apply').click
          end
          if proto_vals[0].include?('Other')
              @ff.select_list(:name, 'svc_entry_protocol').select('Other')
              if proto_vals[0].include?('~')
                     # icmp is excluded
                     @ff.label(:for,'svc_entry_protocol_exclude_').click
              end
              @ff.text_field(:name, 'svc_entry_protocol_num').set(proto_vals[1].strip)
              @ff.link(:text, 'Apply').click
          end
      end
      @ff.link(:text, 'Apply').click
  end

  def  qos_scheduler(rule_name,rules)
    
    #puts 'qos_scheduler rule name is'+ rule_name
    self.msg(rule_name, :debug, 'qos_scheduler', 'called qos_scheduler')
    rules.each do |sched_rule_name,rule_data|
        self.msg(rule_name, :debug, 'qos_scheduler', 'doing rule' +sched_rule_name)
        @ff.text_field(:name, 'schdlr_rule_name').set(sched_rule_name.strip)
        if rule_data.has_key?('active')
               if rule_data['active'] ==1
                   @ff.label(:for,'is_enabling_0').click
               elsif rule_data['active'] == 0
                   @ff.label(:for,'is_enabling_1').click
               end
               self.msg(rule_name, :debug, 'qos_scheduler', 'doing rule' +sched_rule_name + "active")
            @ff.link(:text, 'Add Rule Schedule').click
            if rule_data.has_key?('days')
                self.msg(rule_name, :debug, 'qos_scheduler', 'doing rule' +sched_rule_name + "days")
                rule_data['days'].each do |spec|
                   if spec == "Monday"
                      @ff.label(:for,'day_mon_').click
                   elsif spec == "Tuesday"
                      @ff.label(:for,'day_tue_').click 
                   elsif spec == "Wednesday"
                      @ff.label(:for,'day_wed_').click 
                   elsif spec == "Thursday"
                      @ff.label(:for,'day_thu_').click 
                   elsif spec == "Friday"
                      @ff.label(:for,'day_fri_').click 
                   elsif spec == "Saturday"
                      @ff.label(:for,'day_sat_').click 
                   elsif spec == "Sunday"
                      @ff.label(:for,'day_sun_').click 
                   end #end each day
                   self.msg(rule_name, :debug, 'qos_scheduler', 'doing rule' +sched_rule_name + spec.to_s)
                end
                if rule_data.has_key?('hours')
                       self.msg(rule_name, :debug, 'qos_scheduler', 'doing rule' +sched_rule_name + "hours")
                    rule_data['hours'].each do |spec|
                       self.msg(rule_name, :debug, 'qos_scheduler', 'doing rule' +sched_rule_name + spec.to_s)
                       @ff.link(:text, 'New Hours Range Entry').click
                       times = spec.split(',')
                       start_time = times[0].split(':')
                       end_time = times[1].split(':')
                       @ff.text_field(:name, 'start_hour').set(start_time[0].strip)
                       @ff.text_field(:name, 'start_min').set(start_time[1].strip)
                       @ff.text_field(:name, 'end_hour').set(end_time[0].strip)
                       @ff.text_field(:name, 'end_min').set(end_time[1].strip)
                       @ff.link(:text, 'Apply').click
                    end # end each timespec
                end  #end if hours
            @ff.link(:text, 'Apply').click
            end # end if days
        end  # end if active
    end  # end each rule
    @ff.link(:text, 'Apply').click
  end

  #----------------------------------------------------------------------------------
  # qos_add_rule
  # Discription: Inside function for adding 1 qos rule
  #----------------------------------------------------------------------------------
  def qos_add_rule(rule_name,rule_id,data,qkey)
            # RJS
            # add code to check to see if we are tying to add a rule that already exists
            # if so exit with a warning message
            # 
            base = qkey + '-rule-' + rule_id +'-'
            if data.has_key?('source')
               self.msg(rule_name,:debug, "qos_add", "found source:"+ data['source'].to_s)
               if data['source'] == "any"
                   self.msg(rule_name, :debug, 'qos_add_rule', "found any")
                   @ff.select_list(:name, 'sym_net_obj_src').select_value('ANY')
                   #@ff.link(:text, 'Apply').click
                   self.msg(rule_name, :info, base + 'source-any', 'done')
               else
               sources = data['source']
               sources.each do |source,src_info|
                  self.msg(rule_name, :info, base + 'source-' +source, 'done')
                   if source == 'ip_address' 
                       self.msg(rule_name, :debug, 'qos_add_rule', src_info)
                       @ff.select_list(:name, 'sym_net_obj_src').select_value('USER_DEFINED')
                       qos_add_ip(rule_name,src_info)
                       @ff.link(:text, 'Apply').click
                   elsif source == 'ip_subnet' 
                       self.msg(rule_name, :debug, 'qos_add_rule', "subnet = " +src_info)
                       @ff.select_list(:name, 'sym_net_obj_src').select_value('USER_DEFINED')
                       qos_add_2_ip(rule_name,src_info,1)
                       @ff.link(:text, 'Apply').click
                   elsif source =='ip_range'
                       self.msg(rule_name, :debug, 'qos_add_rule', "range = " +src_info)
                       @ff.select_list(:name, 'sym_net_obj_src').select_value('USER_DEFINED')
                       qos_add_2_ip(rule_name,src_info,2)
                       @ff.link(:text, 'Apply').click
                   elsif source =='mac'
                       self.msg(rule_name, :debug, 'qos_add_rule', "mac = " +src_info)
                       @ff.select_list(:name, 'sym_net_obj_src').select_value('USER_DEFINED')
                       qos_add_mac(rule_name,src_info)
                       self.msg(rule_name, :debug, 'qos_add_rule', "mac is done ")
                       @ff.link(:text, 'Apply').click
                   elsif source =='host'
                       self.msg(rule_name, :debug, 'qos_add_rule', "host = " +src_info)
                       @ff.select_list(:name, 'sym_net_obj_src').select_value('USER_DEFINED')
                       qos_add_host(rule_name,src_info)
                       @ff.link(:text, 'Apply').click
                   elsif source =='dhcp_option'
                       self.msg(rule_name, :debug, 'qos_add_rule', "dhcp = " +src_info)
                       @ff.select_list(:name, 'sym_net_obj_src').select_value('USER_DEFINED')
                       qos_add_dhcp_option(rule_name,src_info)
                       @ff.link(:text, 'Apply').click
                   elsif source =='discovered_hosts'
                       self.msg(rule_name, :debug, 'qos_add_rule', "discovered_hosts " + src_info)
                       host_list = src_info.split(',')
                       self.msg(rule_name, :debug, 'qos_add_host', "host_list" +host_list.to_s)
                       disc_host= @ff.select_list(:name, 'sym_net_obj_src').getAllContents
                       # for each host int the config data scan the select list to see if that
                       # host is in the pull down. If so select it, if not print an error
                       #
                       host_list.each do |host|
                           found = false
                           self.msg(rule_name, :debug, 'qos_add_host', "processing host" +host.to_s)
                            disc_host.each do |el|
                              if host.strip == el
                                  @ff.select_list(:name, 'sym_net_obj_src').select(el)
                                  found = true
                              end
                           end 
                           if found == false
                               self.msg(rule_name, :error, 'qos_add_rule', "cannot find discovered_hosts " + host.strip)
                           end
                      end

                       #@ff.link(:text, 'Apply').click
                   end
                end
                end
            end
            if data.has_key?('destination')
               self.msg(rule_name,:debug,"qos_add", " found destination:")
               self.msg(rule_name, :debug, 'qos_add_rule', data['destination'])
               if data['destination'] == "any"
                   @ff.select_list(:name, 'sym_net_obj_dst').select_value('ANY')
                   #@ff.link(:text, 'Apply').click
                   self.msg(rule_name, :info, base + 'dest-any', 'done')
               else
               dests = data['destination']
               dests.each do |dest,dest_info|
                   self.msg(rule_name, :info, base + 'dest-'+dest, 'done')
                   if dest =='ip_address'
                       self.msg(rule_name, :debug, 'qos_add_rule', dest_info)
                       @ff.select_list(:name, 'sym_net_obj_dst').select_value('USER_DEFINED')
                       qos_add_ip(rule_name,dest_info)
                       @ff.link(:text, 'Apply').click
                   elsif dest =='ip_subnet'
                       self.msg(rule_name, :debug, 'qos_add_rule', "subnet = " +dest_info)
                       @ff.select_list(:name, 'sym_net_obj_dst').select_value('USER_DEFINED')
                       qos_add_2_ip(rule_name,dest_info,1)
                       @ff.link(:text, 'Apply').click
                   elsif dest =='ip_range'
                       self.msg(rule_name, :debug, 'qos_add_rule', "range = " +dest_info)
                       @ff.select_list(:name, 'sym_net_obj_dst').select_value('USER_DEFINED')
                       qos_add_2_ip(rule_name,dest_info,2)
                       @ff.link(:text, 'Apply').click
                   elsif dest =='mac'
                       self.msg(rule_name, :debug, 'qos_add_rule', "mac = " +dest_info)
                       @ff.select_list(:name, 'sym_net_obj_dst').select_value('USER_DEFINED')
                       qos_add_mac(rule_name,dest_info)
                       self.msg(rule_name, :debug, 'qos_add_rule', "mac is done ")
                       @ff.link(:text, 'Apply').click
                   elsif dest =='host'
                       self.msg(rule_name, :debug, 'qos_add_rule', "host = " +dest_info)
                       @ff.select_list(:name, 'sym_net_obj_dst').select_value('USER_DEFINED')
                       qos_add_host(rule_name,dest_info)
                       @ff.link(:text, 'Apply').click
                   elsif dest =='dhcp_option'
                       self.msg(rule_name, :debug, 'qos_add_rule', "dhcp = " +dest_info)
                       @ff.select_list(:name, 'sym_net_obj_dst').select_value('USER_DEFINED')
                       qos_add_dhcp_option(rule_name,dest_info)
                       @ff.link(:text, 'Apply').click
                   elsif dest =='discovered_hosts'
                       self.msg(rule_name, :debug, 'qos_add_rule', "discovered_hosts " + dest_info)
                       host_list = dest_info.split(',')
                       self.msg(rule_name, :debug, 'qos_add_host', "host_list" +host_list.to_s)
                       disc_host= @ff.select_list(:name, 'sym_net_obj_dst').getAllContents
                       # for each host int the config data scan the select list to see if that
                       # host is in the pull down. If so select it, if not print an error
                       #
                       host_list.each do |host|
                           found = false
                           self.msg(rule_name, :debug, 'qos_add_host', "processing host" +host.to_s)
                            disc_host.each do |el|
                              if host.strip == el
                                  @ff.select_list(:name, 'sym_net_obj_dst').select(el)
                                  found = true
                              end
                           end
                           if found == false
                               self.msg(rule_name, :error, 'qos_add_rule', "cannot find discovered_hosts " + host.strip)
                           end
                      end

                       #@ff.link(:text, 'Apply').click
                   end

                   end
                end
            end
            if data.has_key?('protocol')
               self.msg(rule_name,:debug,"qos_add", " found protocol:")
               protos =@ff.select_list(:name, 'svc_service_combo').getAllContents
               if protos.include?("Show All Services")
                    self.msg(rule_name,:debug,"qos_add", " displaying all services:")
                     @ff.select_list(:name, 'svc_service_combo').select("Show All Services")
               end
               protos =@ff.select_list(:name, 'svc_service_combo').getAllContents
               protocols = data['protocol']
               protocols.each do |proto,proto_info|
                   self.msg(rule_name, :info, base + 'protocol-'+ proto, 'done')
                   if proto  == 'named' 
                       self.msg(rule_name, :debug, 'qos_add_rule', "named info = " +proto_info.to_s)
                       proto_info.each do |proto_instance| 
                           if protos.include?(proto_instance)
                               @ff.select_list(:name, 'svc_service_combo').select(proto_instance)
                           else
                              self.msg(rule_name,:debug,"qos_add", "protocol  " + proto_instance.to_s + " not found")
                           end
                       end
                   end
                   if proto  == 'user_defined' 
                       qos_user_defined_proto(rule_name,proto_info)
                   end
               end
            end
            if data.has_key?('dscp')
               self.msg(rule_name,:debug,"qos_add", " found dscp:")
               @ff.checkbox(:id, 'dscp_check_box_').set
               dscp_vals =  data['dscp'].split(',')
               if dscp_vals.length == 2
                   @ff.text_field(:name, 'dscp_check_val').set(dscp_vals[0].strip) 
                   @ff.text_field(:name, 'dscp_check_mask').set(dscp_vals[1].strip) 
                   self.msg(rule_name, :info, base + 'dscp' , 'done')
               else
                   self.msg(rule_name,:error,"qos_add", " must specify dscp and mask")
               end 
            end
            if data.has_key?('priority')
               self.msg(rule_name,:debug,"qos_add", " found priority:")
               @ff.checkbox(:id, 'prio_check_box_').set
               regx=Regexp.new data['priority']
               @ff.select_list(:name, 'prio_check_combo').select_value(regx)
               self.msg(rule_name, :info, base + 'priority' , 'done')
            end
            if data.has_key?('packet_length')
               self.msg(rule_name,:debug,"qos_add", " found packet_length:")
               @ff.checkbox(:id, 'length_check_box_').set
               @ff.select_list(:name, 'length_check_type').select_value("0")
               len_vals =  data['packet_length'].split(',')
               if len_vals.length == 2
                   @ff.text_field(:name, 'length_check_from').set(len_vals[0].strip) 
                   @ff.text_field(:name, 'length_check_to').set(len_vals[1].strip) 
                   self.msg(rule_name, :info, base + 'packet_length' , 'done')
               else
                   self.msg(rule_name,:error,"qos_add", " must specify from and to lengths for packet_length")
               end 
            end
            if data.has_key?('data_length')
               self.msg(rule_name,:debug,"qos_add", " found data_length:")
               @ff.checkbox(:id, 'length_check_box_').set
               @ff.select_list(:name, 'length_check_type').select_value("1")
               len_vals =  data['data_length'].split(',')
               if len_vals.length == 2
                   @ff.text_field(:name, 'length_check_from').set(len_vals[0].strip) 
                   @ff.text_field(:name, 'length_check_to').set(len_vals[1].strip) 
                   self.msg(rule_name, :info, base + 'data_length' , 'done')
               else
                   self.msg(rule_name,:error,"qos_add", " must specify from and to lengths data_length")
               end 
            end
            if data.has_key?('dscp_auto')
               self.msg(rule_name,:debug,"qos_add", " found specify_dscp:")
               @ff.checkbox(:id, 'length_check_box_').set
               self.msg(rule_name, :info, base + 'dscp_auto' , 'done')
            end
            if data.has_key?('set_dscp')
               self.msg(rule_name,:debug,"qos_add", " found specify_dscp:")
               @ff.checkbox(:id, 'set_dscp_check_').set
               if data['set_dscp'] == 'auto'
                  @ff.select_list(:name, 'set_dscp').select_value("1")
               else
                  @ff.select_list(:name, 'set_dscp').select_value("2")
                   dscp_vals =  data['set_dscp'].split(',')
                   if dscp_vals.length == 2
                       @ff.text_field(:name, 'qos_dscp_edit').set(dscp_vals[0].strip) 
                       @ff.text_field(:name, 'qos_dscp_mask').set(dscp_vals[1].strip) 
                   else
                       self.msg(rule_name,:error,"qos_add", " must specify dscp and mask when setting dscp vals")
                   end 
               end 
               self.msg(rule_name, :info, base + 'set_dscp' , 'done')
            end
            if data.has_key?('set_priority')
               self.msg(rule_name,:debug,"qos_add", " found set_priority:")
               @ff.checkbox(:id, 'set_priority_').set
               regx=Regexp.new data['set_priority']
               @ff.select_list(:name, 'qos_8021p_combo').select_value(regx)
               self.msg(rule_name, :info, base + 'set_priority' , 'done')
            end
            if data.has_key?('apply')
               self.msg(rule_name,:debug,"qos_add", " found apply:")
               if data['apply'] == "packet"
                 @ff.select_list(:name, 'qos_on_conn').select_value("0")
               end
               if data['apply'] == "connection"
                 @ff.select_list(:name, 'qos_on_conn').select_value("1")
               end
               self.msg(rule_name, :info, base + 'apply' , 'done')
                 
            end
            if data.has_key?('logging')
               self.msg(rule_name,:debug,"qos_add", " found logging:")
               if data['logging'] == 1
                   @ff.checkbox(:id, 'rule_log_').set
               end
               if data['logging'] == 0
                   @ff.checkbox(:id, 'rule_log_').clear
               end
               self.msg(rule_name, :info, base + 'logging' , 'done')
            end
            # rjs
            # do when here
            if data.has_key?('when')
               self.msg(rule_name,:debug,"qos_rule", " found when")
               if data['when'] == 'always'
                 @ff.select_list(:name, 'schdlr_rule_id').select("Always")
               else
                 @ff.select_list(:name, 'schdlr_rule_id').select("User Defined")
                 qos_scheduler(rule_name,data['when'])
               end
               self.msg(rule_name, :info, base + 'scheduler' , 'done')
             end
            #
            @ff.link(:text, 'Apply').click
        end

  #----------------------------------------------------------------------
  # qos_add_traffic_shaping()
  # Discription: In QoS part, add the traffic shapping for the device,  
  #              and should be called by function qos().
  #----------------------------------------------------------------------
  def qos_add_traffic_shaping(rule_name, data, info)
    
    # Note: To prevent error on multiple call, you should go back the main.
    
    # Go to the advanced page.
    self.goto_advanced(rule_name, info)
        
    # Go to the qos page.
    begin
      @ff.link(:text, 'Quality of Service(QoS)').click
      self.msg(rule_name, :info, 'Qos', 'Reached page Qos')
    rescue
      self.msg(rule_name, :error, 'Qos', 'Did not reach Qos page')
      return
    end
                
    # Go to the "Traffic Shaping" page.
    begin
      @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
      self.msg(rule_name,:info,'Traffic Shaping','Reached page: Traffic Priority')
    rescue
      self.msg(rule_name,:error,'Traffic Shaping','Did not reach the page')
      return
    end
          
    # 
    # Note: Now,we are under the page of traffic shaping.
    #
    
    # Step One: Check if the device has been added, if so delete it.
    
    # Step Two: Add Device Traffic Shaping.
    
    # Click the "add" button.
    @ff.link(:name,'add').click
    # Confirm it.
    if not @ff.text.include? 'Add Device Traffic Shaping'
      self.msg(rule_name,:error,'QoS Add Traffic Shaping','Did not reach the page')
      return
    end
    
    # Choose the device.
    if data.has_key?('device')
      
      # Note: This name should be correspondent with the web.
      case data['device']    
      when "network"  
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('br0')   
      when "ethernet"      
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('eth0')           
      when "broadband_ethernet"       
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('eth1')              
      when "coax"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('clink0')
      when "broadband_coax"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('clink1')
      when "wireless"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('ath0')
      when "wan_pppoe"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('ppp0')
      when "wan_pppoe2"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('ppp1')
      when "default_lan"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('Default LAN')
      when "default_wan"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('Default WAN')
      when "default_DMZ"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('Default DMZ')
      when "all"
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('All Devices')
      else
        # Whenever come here, there is something wrong with the program.
        self.msg(rule_name,:error,'Add Device','Device name unmatched.')
        puts "Add Traffic Shaping: Device name unmatched."
        return
      end # end of case
      
      #Go to the 'Edit Device Traffic Shaping page'.
      @ff.link(:text,'Apply').click
      # Confirm it.
      if not @ff.text.include? 'Tx Traffic Shaping'
        self.msg(rule_name,:error,'QoS Add Traffic Shaping','Did not reach the page')
        return
      end
      
    end # end of if
    
    # Step Three: Edit Device Traffic Shaping
    
    # Setup the bandwidth.
    if data.has_key?('tx_bandwidth')
      
      case data['tx_bandwidth']
      when "Unlimited"
        # Unlimited  
        @ff.select_list(:name,'qos_tx_shaping_bandwidth_mode').select_value('2')
      else
        # Specify
        @ff.select_list(:name,'qos_tx_shaping_bandwidth_mode').select_value('0')
        
        # Fill in the bandwidth value
        # *** Note: ***
        # Here you MUST wait until the new page come out, so to confirm it.
        if not @ff.text.include? 'Kbps'
          self.msg(rule_name,:error,'QoS set bandwidth','Did not fill in the bandwidth')
          return
        end
        
        @ff.text_field(:name,'sym_qos_shaping_tx_bandwidth').set(data['tx_bandwidth'])
      end
      
      # Apply for the change.
      @ff.link(:text,'Apply').click
      # Confirm it.
      if not @ff.text.include? 'DSCP Settings'
        self.msg(rule_name,:error,'Setup Bandwidth','Did not succeed.')
        return
      end
      
    end # end of if data...
    
    # Output one message to confirm one traffic shaping.
    self.msg(rule_name,:info,'Add one traffic shapping','OK')
    
  end # end of def

  #----------------------------------------------------------------------
  # qos_DHCP_settings()
  # Discription: Inside functions, will be called by main function.
  #----------------------------------------------------------------------
  def qos_DHCP_settings(rule_name, info)
    #
  end
  
  #----------------------------------------------------------------------
  # qos_8021p_settings()
  # Discription: Inside functions, will be called by main function.
  #----------------------------------------------------------------------
  def qos_8021p_settings(rule_name, info)
    #
  end  
  
  #----------------------------------------------------------------------
  # qos_class_statistics()
  # Discription: Inside functions, will be called by main function.
  #----------------------------------------------------------------------
  def qos_class_statistics(rule_name, info)
    #
  end
  
  #----------------------------------------------------------------------
  # qos_class_identifier()
  # Discription: Inside functions, will be called by main function.
  #----------------------------------------------------------------------
  def qos_class_identifier(rule_name, info)
    #
  end
  
  

  #----------------------------------------------------------------------
  # qos_prototype(rule_name, info)
  # Discription: Main function of Quality of Service(QoS) prototype.
  #----------------------------------------------------------------------
  def qos_prototype(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the Quality of Service(Qos) page.
    begin
      @ff.link(:text, 'Quality of Service(QoS)').click
      self.msg(rule_name, :info, 'Qos', 'Reached page Qos')
    rescue
      self.msg(rule_name, :error, 'Qos', 'Did not reach Qos page')
      return
    end
    
    case info['action']
      
    when 'set'
        
      # ------------ Begin of Traffic Shaping --------------
        
      # Define a device array which is used in traffic shapping.
      # Note: This Array MUST correspond with the Web page ID!
      #       So this code is NOT robust, Whenever the web page 
      #       has been changed, you MUST revise this arry.
   
      # Go to the advanced page.
      self.goto_advanced(rule_name, info)
  
      # Go to the qos page.
      begin
        @ff.link(:text, 'Quality of Service(QoS)').click
        self.msg(rule_name, :info, 'Qos', 'Reached page Qos')
      rescue
        self.msg(rule_name, :error, 'Qos', 'Did not reach Qos page')
        return
      end
          
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'Traffic Shaping','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'Traffic Shaping','Did not reach the page')
        return
      end
        
      qosDevice=["network",
                  "ethernet",
                  "broadband_ethernet",
                  "coax",
                  "broadband_coax",
                  "wireless",
                  "wan_pppoe",
                  "wan_pppoe2",
                  "default_lan",
                  "default_wan",
                  "default_DMZ",
                  "all"]
      
      # Do Traffic Shapping.
      if info.key?("traffic_shaping")
        
        # Enter the Traffic Shaping configuration.
        devGroup = info["traffic_shaping"].sort
        
        # Traverse the device group.
        # Mind: the parameter name is specified.
        devGroup.each do |id,data|
          
          # "data" is one device 
          if data.has_key?('device')
            devName = data['device']
          end
  
          # Check the device name.
          if qosDevice.include?(devName)
            # OK
            self.msg(rule_name, :info, 'QoSDevice', 'Found the device')
          else
            # There is no device as refered.
            self.msg(rule_name,:error,'QoSDevice','Not found the device')
          end # end of if
          
          # Is there already exists?
          # Note: Need to add code here. 
          
          # Call the function to add the traffic shaping.
          # Note: Now, we get the page of traffic shaping.
          qos_add_traffic_shaping(rule_name,data,info)
          
        end # end of devGroup.each...
        
      end # end of if info.key...
      
      # ------------- End of Traffic Shaping ---------------

    
      # ************* Begin of Traffic Priority *************
      
      # Define a rule array for traffic priority
      # Note: This Array MUST correspond with the Web page ID!
      #       So this code is NOT robust, Whenever the web page 
      #       has been changed, you MUST revise this arry.
      qos_keys=["network_input",
                "ethernet_input",
                "broadband_ethernet_input",
                "coax_input",
                "broadband_coax_input",
                "wireless_input",
                "network_output",
                "ethernet_output",
                "broadband_ethernet_output",
                "coax_output",
                "broadband_coax_output",
                "wireless_output"]
                
      # Traverse this array list.
      qos_keys.each do |qkey|
        
          # "qkey" now is a rule name. 
        
          # Get to the advanced page.
          self.goto_advanced(rule_name, info)
  
          # Get to the qos page.
          begin
            @ff.link(:text, 'Quality of Service(QoS)').click
            self.msg(rule_name, :info, 'Qos', 'Reached page Qos')
          rescue
            self.msg(rule_name, :error, 'Qos', 'Did not reach Qos page')
            return
          end
          
          # Go to the "Traffic Priority" page.
          begin
            @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
            self.msg(rule_name,:info,'Traffic Priority','Reached page: Traffic Priority')
          rescue
            self.msg(rule_name,:error,'Traffic Priority','Did not reach the page')
            return
          end
          
          if info.key?(qkey) # Is there a device named as qkey?
            
                 idx = qos_keys.index(qkey) # index of the qkey
                 rule_group = info[qkey] # the device part
                 
                 # Clean the existent rules.
                 if rule_group.has_key?('clean')
                   
                     if rule_group['clean'] == 1
                       
                        # Mind:The debug information can't be output except the debug model.
                        self.msg(rule_name, :debug, 'qos_add', 'found clean')
                        sleep 5
                        #regx=Regexp.new 'javascript:mimic_button(\'remove: '+idx.to_s+'%5F'
                        regx=Regexp.new 'remove: '+idx.to_s+'%5F'
                        #puts regx.to_s
                        while @ff.link(:href, regx).exists?
                        self.msg(rule_name, :debug, 'qos_add', 'removing link')
                        @ff.link(:href, regx).click
                        sleep 5
                        end
                        self.msg(rule_name, :debug, 'qos_add', 'done cleaning')
                        
                    end # end of if rule_group['clean']...
                    
                 end # end of rule_group.has...
                 
                 # Add the rules.
                 if rule_group.has_key?('Rules')
                   
                     rule_list=rule_group['Rules'].sort # rule list array
                     
                     rule_list.each do |rule_id,data|
                     
                          if data.has_key?('task')
                            
                            case data['task']                                                          
                              
                            when 'add'
                                    regx=Regexp.new 'remove: '+idx.to_s+'%5F'+rule_id
                                    if  @ff.link(:href, regx).exists?
                                        self.msg(rule_name, :debug, 'qos_add', qkey.to_s + ' rule id ' + rule_id + ' exists and cannont be added again')
                                        self.msg(rule_name, :error, 'qos_add', qkey.to_s + ' rule id ' + rule_id + ' exists and cannont be added again')
                                    else
                                        @ff.link(:href, 'javascript:mimic_button(\'add: '+idx.to_s+'%5F..\', 1)').click
                                       #self.msg(rule_name, :info, qkey +'-'+rule_id, 'adding rule '+ rule_id)
                                       qos_add_rule(rule_name,rule_id,data,qkey)
                                   end
                                   
                              
                            when 'delete'
                              
                            when 'edit'
                              
                            when 'move_up'
                              
                            when 'move_down'
                              
                              
                            end # end of case...
                            
                          end # end of if...
                          
                     end # end of rule.list.each...
                     
                 end # end of rule_group.has_key?...
                 
           end # end of info.key?...
           
       end # end of qos_keys.each...
       
       # ************* End of Traffic Priority ****************
         
    end # end of case info['action']...
        
  end # end of def qos...
  
  #----------------------------------------------------------------------
  # qos(rule_name, info)
  # Discription: Main function of Quality of Service(QoS) prototype.
  #----------------------------------------------------------------------
  def qos(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the Quality of Service(Qos) page.
    begin
      @ff.link(:text, 'Quality of Service(QoS)').click
      self.msg(rule_name, :info, 'qos', 'Reached page Qos')
    rescue
      self.msg(rule_name, :error, 'qos', 'Did not reach Qos page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') &&
         info.has_key?('page') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'qos','Some key NOT found.')
      return
    end     
    
           
    # ************* Begin *************
    
    case info['page']
      
    when 'network_input'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 0%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)
      
    when 'ethernet_input'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 1%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end      
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)  
      
    when 'broadband_ethernet_input'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 2%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end       
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)        
      
    when 'coax_input'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 3%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end       
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info) 
      
    when 'broadband_coax_input'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 4%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end        
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)    
      
    when 'wireless_input'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 5%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end       
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)    
      
    when 'network_output'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
            
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 6%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end        
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)       
      
    when 'ethernet_output'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 7%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end       
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)   
       
    when 'broadband_ethernet_output'
       
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 8%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end      
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)   
      
    when 'coax_output'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 9%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end       
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)     
      
    when 'broadband_coax_output'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
      @ff.link(:href,'javascript:mimic_button(\'add: 10%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end       
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info) 
      
    when 'wireless_output'
      
      # Go to the "Traffic Priority" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9053..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Priority')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 11%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'qos','No such link, you need reset BHR befor this case.')
        return
      end       
      
      # Add this rule.
      qos_add_traffic_priority(rule_name,info)
      
    when 'network'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end 
      
      # Click the "Add" button
      @ff.link(:text,'Add').click
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)
      
    when 'ethernet'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click    
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'broadband_ethernet'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click    
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'coax'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click  
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'broadband_coax'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click  
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'wireless'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click  
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'wan_pppoe'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click    
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'wan_pppoe2'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click   
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'default_lan'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click    
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'default_wan'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click   
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'default_DMZ'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click   
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
      
    when 'all'
      
      # Go to the "Traffic Shaping" page.
      begin
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9056..\', 1)').click
        self.msg(rule_name,:info,'qos','Reached page: Traffic Shaping')
      rescue
        self.msg(rule_name,:error,'qos','Did not reach the page')
        return
      end
      
      # Click the "Add" button
      @ff.link(:text,'Add').click  
      
      # Add the traffic shaping
      qos_add_traffic_shaping_temp(rule_name,info)      
       
    else
      
      # Wrong here.
      self.msg(rule_name,:error,'qos','No such page name.')
      return
      
    end # end of case
    
    # Output the result.
    self.msg(rule_name,:info,'Quality of Service(QoS)','SUCCESS')
     
    # ************* End ****************
        
  end # end of def qos...  
  
  #----------------------------------------------------------------------
  # qos_add_traffic_priority(rule_name,info)(rule_name, info)
  # Discription: function of "Traffic Priority" under "Qos" page.
  #              This is a inside function.
  #----------------------------------------------------------------------
  def qos_add_traffic_priority(rule_name,info)
    
    # Now, the page must be the "Add Traffic Priority Rule"
    if not @ff.text.include?'Add Traffic Priority Rule'
      # Wrong here
      self.msg(rule_name,:error,'qos_add_traffic_priority','Not in this page.')
      return
    end
    
    # "Source Address"
    if info.has_key?('Source Address')
      
      case info['Source Address']
      when 'Any'
        @ff.select_list(:name, 'sym_net_obj_src').select_value('ANY')
        self.msg(rule_name,:info,'Source Address',info['Source Address'])
      else
        # Wrong here 
        self.msg(rule_name,:error,'qos','Source address wrong.')
        return
      end    
      
    end    
    
    # "Destination Address"
    if info.has_key?('Destination Address')
      
      case info['Destination Address']
      when 'Any'
        @ff.select_list(:name, 'sym_net_obj_dst').select_value('ANY')
        self.msg(rule_name,:info,'Destination Address',info['Destination Address'])
      else
        # Wrong here 
        self.msg(rule_name,:error,'qos','Destination Address wrong.')
        return
      end    
      
    end  
    
    # "Protocol"
    if info.has_key?('Protocol')
      
      case info['Protocol']
      when 'Any'
        @ff.select_list(:name, 'svc_service_combo').select_value('ANY')
        self.msg(rule_name,:info,'Protocol',info['Protocol'])
      else
        # Wrong here 
        self.msg(rule_name,:error,'qos','Protocol wrong.')
        return
      end    
      
    end    
    
    # "Priority"
    if info.has_key?('Priority')
      
      @ff.checkbox(:id, 'prio_check_box_').set
      
      case info['Priority']
        
      when '0'
        @ff.select_list(:name, 'prio_check_combo').select_value("0 (Queue 0 - Low)")
      when '1'
        @ff.select_list(:name, 'prio_check_combo').select_value("1 (Queue 0 - Low)")
      when '2'
        @ff.select_list(:name, 'prio_check_combo').select_value("2 (Queue 0 - Low)")
      when '3'
        @ff.select_list(:name, 'prio_check_combo').select_value("3 (Queue 0 - Low)")
      when '4'
        @ff.select_list(:name, 'prio_check_combo').select_value("4 (Queue 1 - Medium)")
      when '5'
        @ff.select_list(:name, 'prio_check_combo').select_value("5 (Queue 1 - Medium)")
      when '6'
        @ff.select_list(:name, 'prio_check_combo').select_value("6 (Queue 2 - High)")
      when '7'
        @ff.select_list(:name, 'prio_check_combo').select_value("7 (Queue 2 - High)")
      else
        # Wrong here.
        self.msg(rule_name,:error,'qos_add_traffic_priority','No such option')
        return
      
      end # end of the case
      
      self.msg(rule_name, :info, 'Priority' , info['Priority'])
      
    end # end of if  
    
    # "Set Priority"
    if info.has_key?('Set Priority')
      
      @ff.checkbox(:name, 'set_priority').set
      
      case info['Set Priority']
        
      when '0'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("0 (Queue 0 - Low)")
      when '1'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("1 (Queue 0 - Low)")
      when '2'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("2 (Queue 0 - Low)")
      when '3'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("3 (Queue 0 - Low)")
      when '4'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("4 (Queue 1 - Medium)")
      when '5'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("5 (Queue 1 - Medium)")
      when '6'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("6 (Queue 2 - High)")
      when '7'
        @ff.select_list(:name, 'qos_8021p_combo').select_value("7 (Queue 2 - High)")
      else
        # Wrong here.
        self.msg(rule_name,:error,'qos_add_traffic_priority','No such option')
        return
      
      end # end of the case
      
      self.msg(rule_name, :info, 'Priority' , info['Priority'])
      
    end # end of if    

    # "Apply QoS on"
    if info.has_key?('Apply QoS on')
      
      case info['Apply QoS on']
      
      when 'Connection'
        
        # Set "Connection"
        @ff.select_list(:name,'qos_on_conn').select_value("1")
        self.msg(rule_name,:info,'Apply QoS on',info['Apply QoS on'])
 
      when 'Packet'
        
        # Set "Packet"
        @ff.select_list(:name,'qos_on_conn').select_value("0")
        self.msg(rule_name,:info,'Apply QoS on',info['Apply QoS on'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'qos_add_traffic_priority','Did NOT find the value in \'Apply QoS on\'.')
        return
        
      end # end of case
      
    end # end of if  

    # "Log Packets Matched by This Rule"
    if info.has_key?('Log Packets Matched by This Rule')
      
      case info['Log Packets Matched by This Rule']
      
      when 'on'
        
        # Set "Log Packets Matched by This Rule"
        @ff.checkbox(:name,'rule_log').set
        self.msg(rule_name,:info,'Log Packets Matched by This Rule',info['Log Packets Matched by This Rule'])
 
      when 'off'
        
        # Clear "Log Packets Matched by This Rule"
        @ff.checkbox(:name,'rule_log').clear
        self.msg(rule_name,:info,'Log Packets Matched by This Rule',info['Log Packets Matched by This Rule'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'qos_add_traffic_priority','Did NOT find the value in \'Log Packets Matched by This Rule\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "When should this rule occur"
    if info.has_key?('When should this rule occur')
      
      case info['When should this rule occur']
      
      when 'Always'
        
        # Set "Always"
        @ff.select_list(:name,'schdlr_rule_id').select_value("ALWAYS")
        self.msg(rule_name,:info,'When should this rule occur',info['When should this rule occur'])
 
      else
        
        # Wrong here
        self.msg(rule_name,:error,'qos_add_traffic_priority','Did NOT find the value in \'When should this rule occur\'.')
        return
        
      end # end of case
      
    end # end of if     

    # Apply for the change
    @ff.link(:text,'Apply').click
    @ff.wait
    
    # Error message?
    if @ff.text.include?'Input Errors'
      # Error here.
      
      # Find the table.
      sTable = false
      @ff.tables.each do |t|
        if ( t.text.include? 'QoS:' and 
             ( not t.text.include? 'Input Errors') and
             ( not t.text.include? 'Cancel') and
             t.row_count == 2 )then
          sTable = t
          break
        end
      end
      
      if sTable == false
        # Wrong here
        self.msg(rule_name,:error,'qos_add_traffic_priority','Did NOT find the target table.')
        return
      end
      
      strError = sTable[1][2]
      
      self.msg(rule_name,:PageInfo_Error,'Qos',strError)
      return
      
    end
    
    # Output the result
    self.msg(rule_name,:info,'Qos Add Traffic Priority','SUCCESS')
    
  end # end of def.
  
  #----------------------------------------------------------------------
  # qos_add_traffic_shaping_temp(rule_name,info)
  # Discription: In QoS part, add the traffic shapping for the device,  
  #              and should be called by function qos(),this is a temp version.
  #----------------------------------------------------------------------
  def qos_add_traffic_shaping_temp(rule_name,info)
    
    # Note: now under the "Add Device Traffic Shaping" page.
    # Confirm it.
    if not @ff.text.include? 'Add Device Traffic Shaping'
      self.msg(rule_name,:error,'QoS Add Traffic Shaping','Did not reach the page')
      return
    end
    
    # Choose the device.
    if info.has_key?('page')
      
      # Note: This name should be correspondent with the web.
      case info['page']   
        
      when "network"  
        begin
          @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('br0')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end
        
      when "ethernet" 
        begin
         @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('eth0')      
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end        
             
      when "broadband_ethernet" 
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('eth1')              
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end     
        
      when "coax"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('clink0')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end     
        
      when "broadband_coax"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('clink1')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end  
        
      when "wireless"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('ath0')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end   
        
      when "wan_pppoe"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('ppp0')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end   
        
      when "wan_pppoe2"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('ppp1')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end  
        
      when "default_lan"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('Default LAN')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end          
        
      when "default_wan"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('Default WAN')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end  
        
      when "default_DMZ"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('Default DMZ')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end   
        
      when "all"
        begin
        @ff.select_list(:name,'sym_qos_traffic_device_combo').select_value('All Devices')
        rescue
          self.msg(rule_name,:error,'Traffic Shaping','No such device.')
          return
        end    
        
      else
        # Whenever come here, there is something wrong with the program.
        self.msg(rule_name,:error,'Add Device','Device name unmatched.')
        return
      end # end of case
      
      #Go to the 'Edit Device Traffic Shaping page'.
      @ff.link(:text,'Apply').click
      # Confirm it.
      if not @ff.text.include? 'Tx Traffic Shaping'
        self.msg(rule_name,:error,'QoS Add Traffic Shaping','Did not reach the page')
        return
      end
      
    end # end of if
    
    # Edit Device Traffic Shaping
    
    # Setup the Tx bandwidth.
    if info.has_key?('Tx Bandwidth')
      
      case info['Tx Bandwidth']
      when "Unlimited"
        # Unlimited  
        @ff.select_list(:name,'qos_tx_shaping_bandwidth_mode').select_value('2')
      when 'Specify'
        # Specify
        @ff.select_list(:name,'qos_tx_shaping_bandwidth_mode').select_value('0')
      else
        # Wrong here.
        self.msg(rule_name,:error,'QoS add traffic priority','No such Tx bandwith option')
      end
         
    end # end of if if...
    
    # "Tx Kbps"
    if info.has_key?('Tx Kbps')
      
      # Fill in the bandwidth value
      # *** Note: ***
      # Here you MUST wait until the new page come out, so to confirm it.
      if not @ff.text.include? 'Kbps'
        self.msg(rule_name,:error,'QoS set bandwidth','Did not fill in the bandwidth')
        return
      end
      
      @ff.text_field(:name,'sym_qos_shaping_tx_bandwidth').set(info['Tx Kbps'])
    
    end
  
    # "TCP Serialization"
    if info.has_key?('TCP Serialization')
      
      case info['TCP Serialization']
      
      when 'Enabled'
        
        # Set "TCP Serialization"
        @ff.select_list(:name,'sym_qos_shaping_tcp_ser_combo').select_value("2")
        self.msg(rule_name,:info,'TCP Serialization',info['TCP Serialization'])
 
      when 'Disabled'
        
        # Clear "TCP Serialization"
        @ff.select_list(:name,'sym_qos_shaping_tcp_ser_combo').select_value("0")
        self.msg(rule_name,:info,'TCP Serialization',info['TCP Serialization'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Qos Traffic Shaping','Did NOT find the value in \'TCP Serialization\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Queue Policy"
    if info.has_key?('Queue Policy')
      
      case info['Queue Policy']
      
      when 'Class Based'
        
        # Set "Class Based"
        @ff.select_list(:name,'sym_qos_shaping_queue_policy_combo').select_value("0")
        self.msg(rule_name,:info,'Queue Policy',info['Queue Policy'])
 
      when 'Strict Priority'
        
        # Set "Strict Priority"
        @ff.select_list(:name,'sym_qos_shaping_queue_policy_combo').select_value("1")
        self.msg(rule_name,:info,'Queue Policy',info['Queue Policy'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Qos Traffic Shaping','Did NOT find the value in \'Queue Policy\'.')
        return
        
      end # end of case
      
    end # end of if  

    # Setup the Rx bandwidth.
    if info.has_key?('Rx Bandwidth')
      
      case info['Rx Bandwidth']
      when "Unlimited"
        # Unlimited  
        @ff.select_list(:name,'qos_rx_shaping_bandwidth_mode').select_value('2')
      when 'Specify'
        # Specify
        @ff.select_list(:name,'qos_rx_shaping_bandwidth_mode').select_value('0')
      else
        # Wrong here.
        self.msg(rule_name,:error,'QoS add traffic priority','No such Rx bandwith option')
      end
         
    end # end of if if...
    
    # "Rx Kbps"
    if info.has_key?('Rx Kbps')
      
      # Fill in the bandwidth value
      # *** Note: ***
      # Here you MUST wait until the new page come out, so to confirm it.
      if not @ff.text.include? 'Kbps'
        self.msg(rule_name,:error,'QoS set bandwidth','Did not fill in the bandwidth')
        return
      end
      
      @ff.text_field(:name,'sym_qos_shaping_rx_bandwidth').set(info['Rx Kbps'])
    
    end 
   
    # Apply for the change.
    @ff.link(:text,'Apply').click
    # Confirm it.
    if not @ff.text.include? 'DSCP Settings'
      self.msg(rule_name,:error,'Add one traffic shapping','Did not succeed.')
      return
    end
    
    # Apply
    @ff.link(:text,'Apply').click
    
    # Output one message to confirm one traffic shaping.
    self.msg(rule_name,:info,'Add one traffic shapping','OK')
    
  end # end of def  
    
  # *************************
  #   QOS section: END
  # *************************
    

  #----------------------------------------------------------------------
  # diagnostics(rule_name, info)
  # Discription: function of "Diagnostics" under "Advance" page.
  #----------------------------------------------------------------------
  def diagnostics(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Diagnostics" page.
    begin
      @ff.link(:text, 'Diagnostics').click
      self.msg(rule_name, :info, 'Go to \'Diagnostics\' page', 'Done!')
    rescue
      self.msg(rule_name, :error, 'Go to \'Diagnostics\' page', 'Wrong!')
      return
    end
    
    # Check for the keys
    if ( info.has_key?('section') &&
         info.has_key?('subsection') &&
         info.has_key?('Destination') &&
         info.has_key?('Number of pings') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'users','Some key NOT found.')
      return
    end    
    
    # Parse the json file.
    
    # Fill in the "Destination" text field.
    @ff.text_field(:name,'ping_dest').set(info['Destination'])
    self.msg(rule_name,:info,'Destincation',info['Destination'])

    # Fill in the "Number of pings" text field.
    @ff.text_field(:name,'ping_num').set(info['Number of pings'])
    self.msg(rule_name,:info,'Number of pings',info['Number of pings'])
    
    # Click "go"
    @ff.link(:text,'Go').click
    self.msg(rule_name,:info,'Go','Clicked')
    
    # Wait for the result.
    sleep 0.5
    @ff.refresh
    @ff.wait
    
    count = 0
    while count <= 6
    
      # Ping over?
      @ff.link(:text,'Refresh').click
      if @ff.text.include?'Test Succeeded' or @ff.text.include?'Test Failed'
        self.msg(rule_name,:info,'Diagnostics Result','Generated')
        break
      end
      
      count += 1
      sleep 5
      
    end
    
    if count == 7     
      self.msg(rule_name, :error, 'diagnostics', '\'Go\' time out.')
      return      
    end  
    
    # Now, parse the ping result
    
    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if t.text.include? 'Status'
        sTable = t
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'diagnostics','Did NOT find the target table.')
      return
    end
    
    # Find the row
    sTable.each do |row|
      
      # Find the cell
      
      # Output "Status"
      if row.text.include? 'Status'
        self.msg(rule_name,:info,'Status',row[2])
      end
      
      # Output "Packets"
      if row.text.include? 'Packets'
        self.msg(rule_name,:info,'Packets',row[2])
      end
      
      # Output "Round Trip Time"
      if row.text.include? 'Round Trip Time'
        self.msg(rule_name,:info,'Round Trip Time',row[2])
      end
      
    end
    
    # Output results
    self.msg(rule_name,:info,'Diagnostics','Success')
    
    # Close
    @ff.link(:text,'Close').click
    
  end # end of def  

  #----------------------------------------------------------------------
  # restore_defaults(rule_name, info)
  # Discription: function of "Restore Defaults" under "Advance" page.
  #----------------------------------------------------------------------
  def restore_defaults(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Restore Defaults" page.
    begin
      @ff.link(:text, 'Restore Defaults').click
      self.msg(rule_name, :info, 'Restore Defaults', 'Reached page \'Restore Defaults\'.')
    rescue
      self.msg(rule_name, :error, 'Restore Defaults', 'Did not reach \'Restore Defaults\' page')
      return
    end
    
    # Check for the keys
    if ( info.has_key?('section') &&
         info.has_key?('subsection') &&
         info.has_key?('Save Configuration File') &&
         info.has_key?('Restore Defaults') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'restore_defaults','Some key NOT found.')
      return
    end    
    
    # Parse the json file.

    # "Save Configuration File"
    case info['Save Configuration File']
    
    when 'on'
      
      # Click the button "Save Configuration File"
      @ff.link(:text,'Save Configuration File').click
      self.msg(rule_name,:info,'Save Configuration File','Done')
        
    when 'off'
      
      # Do nothing
      
    else
      
      # Wrong here
      self.msg(rule_name,:error,'restore_defaults','No such \'Save Configuration File\' option.')
      return
    
    end # end of case
    
    # "Restore Defaults"
    case info['Restore Defaults']
    
    when 'on'
      
      # Click the button "Restore Defaults"
      @ff.link(:href,'javascript:mimic_button(\'onclick=').click
      
      # Confirm page
      if @ff.text.include?'Are you sure you want to revert'
        @ff.link(:href,'javascript:mimic_button(\'onclick=').click
      end
      
      # Resetting?
      if @ff.text.include?'Please wait, system is now restoring factory defaults...'
        # Reseting..
        self.msg(rule_name,:info,'Rebooting','Rebooting')
      end 
      
      # wait for rebooting...
      
      # give it some time to reboot
    
      count = 0
      while count <= 10
        
        # Rebooting...
        if @ff.text.include?'User Name'
          self.msg(rule_name,:info,'Restore Defaults','SUCCESS')
          break
        end
        
        count += 1
        sleep 5
        
      end
      
      @ff.refresh
      
      if @ff.text.include?'User Name'
        self.msg(rule_name,:info,'Restore Defaults','SUCCESS')
        return
      end
      
      if count == 11    
        self.msg(rule_name, :error, 'Restore Defaults', 'Did not reboot.')
        return      
      end      
        
    when 'off'
      
      # Do nothing
      
    else
      
      # Wrong here
      self.msg(rule_name,:error,'restore_defaults','No such \'Restore Defaults\' option.')
      return
    
    end # end of case    
    
  end # end of def  

  #----------------------------------------------------------------------
  # reboot_router(rule_name, info)
  # Discription: function of "Reboot Router" under "Advance" page.
  #----------------------------------------------------------------------
  def reboot_router(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Reboot Router" page.
    begin
      @ff.link(:text, 'Reboot Router').click
      self.msg(rule_name, :info, 'Reboot Router', 'Reached page \'Reboot Router\'.')
    rescue
      self.msg(rule_name, :error, 'Reboot Router', 'Did not reach \'Reboot Router\' page')
      return
    end
    
    # Check for the keys
    if ( info.has_key?('section') &&
         info.has_key?('subsection') &&
         info.has_key?('Reboot Router') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'reboot_router','Some key NOT found.')
      return
    end      
    
    # Parse the "json" file.
    case info['Reboot Router']
      
    when 'on'
      
      # Click the "OK" button.
      @ff.link(:href,'javascript:mimic_button(\'onclick=').click
      
      # Confirm it
      if @ff.text.include?'Please wait, system is now rebooting...'
        self.msg(rule_name,:info,'Executing reboot','Rebooting')
      end
	
      return 
      # wait for rebooting...
      
      # give it some time to reboot
    
      
      count = 0
      while count <= 10
        
        # Rebooting...
        if @ff.text.include?'User Name'
          self.msg(rule_name,:info,'Reboot Router','SUCCESS')
          break
        end
        
        count += 1
        sleep 5
        
      end
      
      @ff.refresh
      
      if @ff.text.include?'User Name'
        self.msg(rule_name,:info,'Reboot Router','SUCCESS')
        return
      end
      
      if count == 11    
        self.msg(rule_name, :error, 'Reboot Router', 'Did not reboot.')
        return      
      end      
      
    when 'off'
      #
      self.msg(rule_name,:info,'Executing reboot','NOT DONE')
    else
      # Wrong here!
      self.msg(rule_name,:error,'reboot_router','No such value in \'Reboot Router\'.')
      return
      
    end
    
  end # end of def  

  #----------------------------------------------------------------------
  # mac_cloning(rule_name, info)
  # Discription: function of "MAC Cloning" under "Advance" page.
  #----------------------------------------------------------------------
  def mac_cloning(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "MAC Cloning" page.
    begin
      @ff.link(:text, 'MAC Cloning').click
      self.msg(rule_name, :info, 'MAC Cloning', 'Reached page \'MAC Cloning\'.')
    rescue
      self.msg(rule_name, :error, 'MAC Cloning', 'Did not reach \'MAC Cloning\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'mac_cloning','Some key NOT found.')
      return
    end
    
    # "Set MAC of Device"
    if info.has_key?('Set MAC of Device')

        # Choose the device.
        case info['Set MAC of Device']
          
        when 'Broadband Connection (Ethernet)'
          @ff.select_list(:name,'wan_devices_to_clone').select_value("eth1")  
        when 'Broadband Connection (Coax)'
          @ff.select_list(:name,'wan_devices_to_clone').select_value("clink1")
        else
          # error here
          self.msg(rule_name,:error,'mac_cloning','Could NOT choose the device.')
        end # end of case
        
    self.msg(rule_name,:info,'Set MAC of Device',info['Set MAC of Device'])
      
    end
    
    # "To Physical Address"
    if info.has_key?('To Physical Address')
      
      # Fill in the blank with the specified MAC address.
      octets = info['To Physical Address'].split(':')
      @ff.text_field(:name, 'mac0').set(octets[0])
      @ff.text_field(:name, 'mac1').set(octets[1])
      @ff.text_field(:name, 'mac2').set(octets[2])
      @ff.text_field(:name, 'mac3').set(octets[3])
      @ff.text_field(:name, 'mac4').set(octets[4])
      @ff.text_field(:name, 'mac5').set(octets[5])  
      
      self.msg(rule_name,:info,'To Physical Address',info['To Physical Address'])
      
    end    
    
    # "Clone My MAC Address"
    if info.has_key?('Clone My MAC Address')
      
      case info['Clone My MAC Address']
        
      when 'on'
        
        # Check if there is this button.
        if @ff.text.include?'Clone My MAC Address'
          
          # Click the button "Clone My MAC Address"
          @ff.link(:text,'Clone My MAC Address').click
                 
        end
        
        self.msg(rule_name,:info,'Clone my MAC address',info['Clone My MAC Address'])
        
      when 'off'
        # Do nothing.
      else
        # Wrong here.
        self.msg(rule_name,:error,'mac_cloning','No such value in \'Clone My MAC Address\'.')
        return
        
      end # end of case
      
    end
    
    # "Restore Factory MAC Address"
    if info.has_key?('Restore Factory MAC Address')
      
      case info['Restore Factory MAC Address']
        
      when 'on'
        
        # Check if there is this button.
        if @ff.text.include?'Restore Factory MAC Address'
          
          # Click the button "Clone My MAC Address"
          @ff.link(:text,'Restore Factory MAC Address').click
          
        end
        
        self.msg(rule_name,:info,'Restore Factory MAC Addresss',info['Restore Factory MAC Address'])        
        
      when 'off'
        # Do nothing.
      else
        # Wrong here.
        self.msg(rule_name,:error,'mac_cloning','No such value in \'Restore Factory MAC Address\'.')
        return
        
      end # end of case
      
    end
    
    # "Apply"
    if info.has_key?('Apply')
      
      case info['Apply']
        
      when 'on'
        
        # Check if there is this button.
        if @ff.text.include?'Apply'
          
          # Click the button "Applys"
          @ff.link(:text,'Apply').click
          self.msg(rule_name,:info,'Apply',info['Apply'])
          
        end
        
      when 'off'
        # Do nothing.
      else
        # Wrong here.
        self.msg(rule_name,:error,'mac_cloning','No such value in \'Apply\'.')
        return
        
      end # end of case
      
    end    
    
  end # end of def  

  #----------------------------------------------------------------------
  # arp_table(rule_name, info)
  # Discription: function of "ARP Table" under "Advance" page.
  #              This function will get the ARP table content and output.
  #----------------------------------------------------------------------
  def arp_table(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "ARP Table" page.
    begin
      @ff.link(:text, 'ARP Table').click
      self.msg(rule_name, :info, 'arp_table', 'Reached page \'ARP Table\'.')
    rescue
      self.msg(rule_name, :error, 'arp_table', 'Did not reach \'ARP Table\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'arp_table','Some key NOT found.')
      return
    end
    
    # Parse the json file
    
    # Refresh
    @ff.link(:text,'Refresh').click
    self.msg(rule_name,:info,'Refresh','DONE')
    
    # Output the ARP table.
    
    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if t.text.include? 'IP Address'
        sTable = t
      end
    end # end of each
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'arp_table','Did NOT find the target table.')
      return
    end
    
    # Find the row
    rowIndex = 0

    sTable.each do |row|
    
      # Find the cell
      
      # Output "ARP Table"
      if not ( row.text.include?'ARP Table' or row.text.include?'IP Address' )
        
        strIPAddress = "IP Address"
        strMACAddress = "MAC Address"
        strDevice = "Device"
        
        rowIndex += 1
        strIPAddress = strIPAddress + rowIndex.to_s()
        strMACAddress = strMACAddress + rowIndex.to_s()
        strDevice = strDevice + rowIndex.to_s()
        
	self.msg(rule_name,:info,row[1],row[2])
        
      end # end of if
      
    end # end of each   
    
    # Output "SUCCESS"
    self.msg(rule_name,:info,'ARP Table','SUCCESS')
    
    # Close the subsection
    @ff.link(:text,'Close').click
    
  end # end of def
  
  #----------------------------------------------------------------------
  # users(rule_name, info)
  # Discription: function of "Users" under "Advance" page.
  #----------------------------------------------------------------------
  def users(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Users" page.
    begin
      @ff.link(:text, 'Users').click
      self.msg(rule_name, :info, 'users', 'Reached page \'Users\'.')
    rescue
      self.msg(rule_name, :error, 'users', 'Did not reach \'Users\' page')
      return
    end

    if (info.has_key?('Delete User'))
	sTable = false
	@ff.tables.each do |t|
	    if (t.text.include? 'Full Name') and
	        (not t.text.include? 'The Users page provides') and
	        (t.row_count > 2) then
	        sTable = t
	        break
	    end
	end
	if sTable == false
        # Wrong here
	    self.msg(rule_name,:error,'Delete User','Did NOT find the target table.')
	    return
	end
	sTable.each do |row|
	    if (row[2].to_s == info['Delete User'])
		row.link(:name,'remove').click
		if @ff.text.include? 'Attention'
		    @ff.link(:text,'Apply').click
		end
		if @ff.text.include? 'Input Errors'
		   sTable = false
		    @ff.tables.each do |t|
			if ( t.text.include? ':' and 
				( not t.text.include? 'Input Errors') and
				( not t.text.include? 'Cancel') and
				t.row_count >= 1 )then
					sTable = t
				break
			end
		    end
      
		    if sTable == false
			self.msg(rule_name,:error,'Users','Did NOT find the target table.')
			return
		    end
      
		    sTable.each do |row|
        
			if row[1] == "" or row[2] == nil
			    next
			end
        
			self.msg(rule_name,:error,row[1],row[2])
        
		    end
       
		    # Click the "cancel"
		    @ff.link(:text,'Cancel').click
		    return
       
 
		end
		self.msg(rule_name,:info,'Delete User','Delete ' + row[3].to_s + ' User Success')
	    end
	end
	return	
    end

    if (info.has_key?('Edit User'))
	sTable = false
	@ff.tables.each do |t|
	    if (t.text.include? 'Full Name') and
	        (not t.text.include? 'The Users page provides') and
	        (t.row_count > 2) then
	        sTable = t
	        break
	    end
	end
	if sTable == false
        # Wrong here
	    self.msg(rule_name,:error,'Edit User','Did NOT find the target table.')
	    return
	end
	sTable.each do |row|
	    if (row[2].to_s == info['Edit User'])
		row.link(:name,'edit').click
		self.msg(rule_name,:info,'Edit User','start to edit user')
	    end
	end
    end
    
    # Check the key.
    if ( not info.has_key?('Edit User'))
        if ( info.has_key?('Full Name') &&
             info.has_key?('User Name') ) then
          # Right,go on.
        else
          self.msg(rule_name,:error,'users','Some key NOT found.')
          return
        end
        
        # Parse the json file
          
        # Add a user here.
        @ff.link(:text,"New User").click
    
    end
    # Enter the user's information
    
    # Full Name
    @ff.text_field(:name,'fullname').value = info['Full Name']
    self.msg(rule_name,:info,'fullname',info['Full Name'])
    
    # User Name
    @ff.text_field(:name,'username').value = info['User Name']
    self.msg(rule_name,:info,'username',info['User Name'])
    
    # New Password & Retype New Password
    @ff.text_field(:index,3).set(info['New Password'])  
    @ff.text_field(:index,4).set(info['Retype New Password'])
    self.msg(rule_name,:info,'Password',info['New Password'])
    
    # Permission
    case info['Permission']
      
    when 'Administrator'
      @ff.select_list(:name,'user_level').select("Administrator")
      self.msg(rule_name,:info,'Permissions','Administrator')
    when 'Limited'
      @ff.select_list(:name,'user_level').select("Limited")
      self.msg(rule_name,:info,'Permissions','Limited')
    else
      # Wrong here
      self.msg(rule_name,:error,'Permissions','Wrong Permissions')
      return
    end  
     
    # Notification Address
    if info.has_key?('Notification Address')
      @ff.text_field(:name,'email').set(info['Notification Address'])
      self.msg(rule_name,:info,'Notification Address',info['Notification Address'])
    end
    
    # System Notify Level
    case info['System Notify Level']
    when 'None'  
      @ff.select_list(:name,'email_system_notify_level').set_value("15")
    when 'Error'
      @ff.select_list(:name,'email_system_notify_level').set_value("3")
    when 'Warning'
      @ff.select_list(:name,'email_system_notify_level').set_value("4")
    when 'Information'
      @ff.select_list(:name,'email_system_notify_level').set_value("6")
    else
      # Wrong here
      self.msg(rule_name,:error,'users','Some key NOT found in System Notify Level.')
      return           
    end
    
    # System Notify Level
    case info['Security Notify Level']
    when 'None'  
      @ff.select_list(:name,'email_security_notify_level').set_value("15")
    when 'Error'
      @ff.select_list(:name,'email_security_notify_level').set_value("3")
    when 'Warning'
      @ff.select_list(:name,'email_security_notify_level').set_value("4")
    when 'Information'
      @ff.select_list(:name,'email_security_notify_level').set_value("6")
    else
      # Wrong here
      self.msg(rule_name,:error,'users','Some key NOT found in System Notify Level.')
      return           
    end
    
    # Apply the new user.
    @ff.link(:text,'Apply').click
    
    # Jump out an "attention" message?
    if @ff.text.include? 'Attention'
      @ff.link(:text,'Apply').click
    end

    if @ff.text.include? 'Input Errors'
      self.msg(rule_name,:error,'Input Errors','Input Errors')	
      @ff.link(:text,'Cancel').click
    end

    
    # Close
    if @ff.text.include? 'Close'
      @ff.link(:text,'Close').click
    end
    
    self.msg(rule_name,:info,'Users','SUCCESS')
    
    return   
     
  end # end of def
  
  #----------------------------------------------------------------------
  # local_administration(rule_name, info)
  # Discription: function of "Local Administration" under "Advance" page.
  #----------------------------------------------------------------------
  def local_administration(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Local Administration" page.
    begin
      @ff.link(:text, 'Local Administration').click
      self.msg(rule_name, :info, 'Local Administration', 'Reached page \'Local Administration\'.')
    rescue
      self.msg(rule_name, :error, 'Local Administration', 'Did not reach \'Local Administration\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'local_administration','Some key NOT found.')
      return
    end  
    
    # Parse the json file.
    
    # "Using Primary Telnet Port"
    if info.has_key?('Using Primary Telnet Port')
      
      case info['Using Primary Telnet Port']
      
      when 'on'
        
        # Set "Using Primary Telnet Port (23)".
        @ff.checkbox(:name,'sec_incom_telnet_pri').set
        self.msg(rule_name,:info,'Using Primary Telnet Port',info['Using Primary Telnet Port'])
 
      when 'off'
        
        # Clear "Using Primary Telnet Port (23)".
        @ff.checkbox(:name,'sec_incom_telnet_pri').clear
        self.msg(rule_name,:info,'Using Primary Telnet Port',info['Using Primary Telnet Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Using Primary Telnet Port\'.')
        return
        
      end # end of case
      
    end # end of if
    
    # "Using Secondary Telnet Port"
    if info.has_key?('Using Secondary Telnet Port')
      
      case info['Using Secondary Telnet Port']
      
      when 'on'
        
        # Set "Using Primary Telnet Port (23)".
        @ff.checkbox(:name,'sec_incom_telnet_sec').set
        self.msg(rule_name,:info,'Using Secondary Telnet Port',info['Using Secondary Telnet Port'])
 
      when 'off'
        
        # Clear "Using Primary Telnet Port (23)".
        @ff.checkbox(:name,'sec_incom_telnet_sec').clear
        self.msg(rule_name,:info,'Using Secondary Telnet Port',info['Using Secondary Telnet Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Using Secondary Telnet Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secure Telnet over SSL Port"
    if info.has_key?('Using Secure Telnet over SSL Port')
      
      case info['Using Secure Telnet over SSL Port']
      
      when 'on'
        
        # Set "Using Primary Telnet Port (23)".
        @ff.checkbox(:name,'sec_incom_telnets').set
        self.msg(rule_name,:info,'Using Secure Telnet over SSL Port',info['Using Secure Telnet over SSL Port'])
 
      when 'off'
        
        # Clear "Using Primary Telnet Port (23)".
        @ff.checkbox(:name,'sec_incom_telnets').clear
        self.msg(rule_name,:info,'Using Secure Telnet over SSL Port',info['Using Secure Telnet over SSL Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Using Secure Telnet over SSL Port\'.')
        return
        
      end # end of case
      
    end # end of if  

    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Output the result.
    self.msg(rule_name,:info,'Set Local Administration','SUCCESS')
    
  end # end of def
  
  #----------------------------------------------------------------------
  # remote_administration(rule_name, info)
  # Discription: function of "Remote Administration" under "Advance" page.
  #----------------------------------------------------------------------
  def remote_administration(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Remote Administration" page.
    begin
      @ff.link(:text, 'Remote Administration').click
      self.msg(rule_name, :info, 'Remote Administration', 'Reached page \'Remote Administration\'.')
    rescue
      self.msg(rule_name, :error, 'Remote Administration', 'Did not reach \'Remote Administration\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'local_administration','Some key NOT found.')
      return
    end  
    
    # Parse the json file.
    
    # "Using Primary Telnet Port"
    if info.has_key?('Using Primary Telnet Port')
      
      case info['Using Primary Telnet Port']
      
      when 'on'
        
        # Set "Using Primary Telnet Port"
        @ff.checkbox(:name,'is_telnet_primary').set
        self.msg(rule_name,:info,'Using Primary Telnet Port',info['Using Primary Telnet Port'])
 
      when 'off'
        
        # Clear "Using Primary Telnet Port"
        @ff.checkbox(:name,'is_telnet_primary').clear
        self.msg(rule_name,:info,'Using Primary Telnet Port',info['Using Primary Telnet Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Using Primary Telnet Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secondary Telnet Port"
    if info.has_key?('Using Secondary Telnet Port')
      
      case info['Using Secondary Telnet Port']
      
      when 'on'
        
        # Set "Using Secondary Telnet Port"
        @ff.checkbox(:name,'is_telnet_secondary').set
        self.msg(rule_name,:info,'Using Secondary Telnet Port',info['Using Secondary Telnet Port'])
 
      when 'off'
        
        # Clear "Using Secondary Telnet Port"
        @ff.checkbox(:name,'is_telnet_secondary').clear
        self.msg(rule_name,:info,'Using Secondary Telnet Port',info['Using Secondary Telnet Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Using Secondary Telnet Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secure Telnet over SSL Port"
    if info.has_key?('Using Secure Telnet over SSL Port')
      
      case info['Using Secure Telnet over SSL Port']
      
      when 'on'
        
        # Set "Using Secure Telnet over SSL Port"
        @ff.checkbox(:name,'is_telnet_ssl').set
        self.msg(rule_name,:info,'Using Secure Telnet over SSL Port',info['Using Secure Telnet over SSL Port'])
 
      when 'off'
        
        # Clear "Using Secure Telnet over SSL Port"
        @ff.checkbox(:name,'is_telnet_ssl').clear
        self.msg(rule_name,:info,'Using Secure Telnet over SSL Port',info['Using Secure Telnet over SSL Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Using Secure Telnet over SSL Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Primary HTTP Port"
    if info.has_key?('Using Primary HTTP Port')
      
      case info['Using Primary HTTP Port']
      
      when 'on'
        
        # Set "Using Primary HTTP Port"
        @ff.checkbox(:name,'is_http_primary').set
        self.msg(rule_name,:info,'Using Primary HTTP Port',info['Using Primary HTTP Port'])
 
      when 'off'
        
        # Clear "Using Primary HTTP Port"
        @ff.checkbox(:name,'is_http_primary').clear
        self.msg(rule_name,:info,'Using Primary HTTP Port',info['Using Primary HTTP Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Using Primary HTTP Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secondary HTTP Port"
    if info.has_key?('Using Secondary HTTP Port')
      
      case info['Using Secondary HTTP Port']
      
      when 'on'
        
        # Set "Using Secondary HTTP Port"
        @ff.checkbox(:name,'is_http_secondary').set
        self.msg(rule_name,:info,'Using Secondary HTTP Port',info['Using Secondary HTTP Port'])
 
      when 'off'
        
        # Clear "Using Secondary HTTP Port"
        @ff.checkbox(:name,'is_http_secondary').clear
        self.msg(rule_name,:info,'Using Secondary HTTP Port',info['Using Secondary HTTP Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Using Secondary HTTP Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Primary HTTPS Port"
    if info.has_key?('Using Primary HTTPS Port')
      
      case info['Using Primary HTTPS Port']
      
      when 'on'
        
        # Set "Using Primary HTTPS Port"
        @ff.checkbox(:name,'is_https_primary').set
        self.msg(rule_name,:info,'Using Primary HTTPS Port',info['Using Primary HTTPS Port'])
 
      when 'off'
        
        # Clear "Using Primary HTTPS Port"
        @ff.checkbox(:name,'is_https_primary').clear
        self.msg(rule_name,:info,'Using Primary HTTPS Port',info['Using Primary HTTPS Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Using Primary HTTPS Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secondary HTTPS Port"
    if info.has_key?('Using Secondary HTTPS Port')
      
      case info['Using Secondary HTTPS Port']
      
      when 'on'
        
        # Set "Using Secondary HTTPS Port"
        @ff.checkbox(:name,'is_https_secondary').set
        self.msg(rule_name,:info,'Using Secondary HTTPS Port',info['Using Secondary HTTPS Port'])
 
      when 'off'
        
        # Clear "Using Secondary HTTPS Port"
        @ff.checkbox(:name,'is_https_secondary').clear
        self.msg(rule_name,:info,'Using Secondary HTTPS Port',info['Using Secondary HTTPS Port'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Using Secondary HTTPS Port\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Allow Incoming WAN ICMP Echo Requests"
    if info.has_key?('Allow Incoming WAN ICMP Echo Requests')
      
      case info['Allow Incoming WAN ICMP Echo Requests']
      
      when 'on'
        
        # Set "Allow Incoming WAN ICMP Echo Requests"
        @ff.checkbox(:name,'is_diagnostics_icmp').set
        self.msg(rule_name,:info,'Allow Incoming WAN ICMP Echo Requests',info['Allow Incoming WAN ICMP Echo Requests'])
 
      when 'off'
        
        # Clear "Allow Incoming WAN ICMP Echo Requests"
        @ff.checkbox(:name,'is_diagnostics_icmp').clear
        self.msg(rule_name,:info,'Allow Incoming WAN ICMP Echo Requests',info['Allow Incoming WAN ICMP Echo Requests'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Allow Incoming WAN ICMP Echo Requests\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Allow Incoming WAN UDP Traceroute Queries"
    if info.has_key?('Allow Incoming WAN UDP Traceroute Queries')
      
      case info['Allow Incoming WAN UDP Traceroute Queries']
      
      when 'on'
        
        # Set "Allow Incoming WAN UDP Traceroute Queries"
        @ff.checkbox(:name,'is_diagnostics_traceroute').set
        self.msg(rule_name,:info,'Allow Incoming WAN UDP Traceroute Queries',info['Allow Incoming WAN UDP Traceroute Queries'])
 
      when 'off'
        
        # Clear "Allow Incoming WAN UDP Traceroute Queries"
        @ff.checkbox(:name,'is_diagnostics_traceroute').clear
        self.msg(rule_name,:info,'Allow Incoming WAN UDP Traceroute Queries',info['Allow Incoming WAN UDP Traceroute Queries'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'remote_administration','Did NOT find the value in \'Allow Incoming WAN UDP Traceroute Queries\'.')
        return
        
      end # end of case
      
    end # end of if    
    
    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Output the result.
    self.msg(rule_name,:info,"Set remote administration",'SUCCESS')
    
  end # end of def
  

  #----------------------------------------------------------------------
  # dynamic_dns(rule_name, info)
  # Discription: function of "Dynamic DNS" under "Advance" page.
  #----------------------------------------------------------------------
    def dynamic_dns(rule_name, info)

        # Get to the advanced page.
	self.goto_advanced(rule_name, info)
    
    	# Get to the "Dynamic DNS" page.
    	begin
  		@ff.link(:text, 'Dynamic DNS').click
      	    	self.msg(rule_name, :info, 'Dynamic DNS', 'Reached page \'Dynamic DNS\'.')
	rescue
	    	self.msg(rule_name, :error, 'Dynamic DNS', 'Did not reach \'Dynamic DNS\'.')
	   	 return
   	end

   	# Check the key.
   	if ( info.has_key?('section') && info.has_key?('subsection') ) then
        	# Right,go on;
   	else
        	self.msg(rule_name,:error,'Dynamic DNS', 'Some key NOT found.')
    		return
    	end # End of if

    # ###############################################
    # The operation key are divided from three cases;
    # case one   : delete a record;
    #      two   : add a record;
    #      three : add multi-record;
    #      four  : upate the status of recor;
    # ###############################################
    if info.has_key?('Operation')
	
    case info['Operation']
	  
	# ##########################  
      	# case one: delete a record;
      	# ##########################
	when 'delete'

		if @ff.text.include?info['Host Name'] and info['Host Name'] != " " then

	    		str_href = @ff.link(:text,info['Host Name']).href
			str_href.gsub!('edit','remove')
			@ff.link(:href,str_href).click
		else
			self.msg(rule_name,:error,'Host Name','Con NOT find the value in \'Host Name\'.')
		end
	# ##########################	
      	# Case two: add a record;
      	# ##########################
      	when 'add'

		# Delete the same Entry,'Remove')
 		if @ff.text.include?info['Host Name'] and info['Host Name'] != " " then
	    		str_href = @ff.link(:text,info['Host Name']).href
			str_href.gsub!('edit','remove')
			@ff.link(:href,str_href).click
		end # End of if	
 	    
		# Add an new Dynamic DNS Entry;
	    	@ff.link(:text,'New Dynamic DNS Entry').click
	    	self.msg(rule_name,:info,'Add Dynamic DNS Entry','CLICKED')

	    	# Fill in the "Host Name"
	    	if info.has_key?('Host Name') 
	    
	        	@ff.text_field(:name,'ddns_host').value = info['Host Name']
	        	self.msg(rule_name,:info,'Host Name',info['Host Name'])
	    	else
	        	self.msg(rule_name,:error,'Host Name','Con NOT find the value in \'Host Name\'.')
	    	end # End of if

	    	# Select list in the "Connection"
	    	if info.has_key?('Connection')
	
	          case info['Connection']
	    
	        	when 'Broadband Connection (Ethernet)'

		    		# Set connection is 'Broadband Connection (Ethernet)'
	            		@ff.select_list(:name,'ddns_device').select("Broadband Connection (Ethernet)")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])
	        	
	        	when 'WAN Ethernet' 

		    		# Set connection is 'Broadband Connection (Ethernet)'
	            		@ff.select_list(:name,'ddns_device').select("WAN Ethernet")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])
	        	
			when 'Broadband Connection (Coax)'
	            		
				# Set connection is 'Broadband Connection (Coax)'
	            		@ff.select_list(:name,'ddns_device').select("Broadband Connection (Coax)")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])

	        	when 'WAN PPPoE'

	            		# Set connection is 'WAN PPPoE'
	            		@ff.select_list(:name,'ddns_device').select("WAN PPPoE")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])

	        	when 'WAN PPPoE 2'

	            		# Set connection is 'WAN PPPoE 2'
	            		@ff.select_list(:name,'ddns_device').select("WAN PPPoE 2")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])
	                else 

		   	 	# Wrong
		   	 	self.msg(rule_name,:error,'connection','Did NOT find the value in \'Connection\'.')
		   		 return
	    
	       	 	end # End of case connection;

	    	end # End of if connection;

	    	# Select list in the "provider"
	    	if info.has_key?('Provider')
	
	      	  case info['Provider']
	    
	    		when 'dyndns.org'

				# Set provider to 'dyndns.org'
	       			@ff.select_list(:name,'ddns_provider').select("dyndns.org")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	   		when 'no-ip.com'

				# Set provider to 'no-ip.com'
	        		@ff.select_list(:name,'ddns_provider').select("no-ip.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'changeip.com'

				# Set provider to 'changeip.com '
	        		@ff.select_list(:name,'ddns_provider').select("changeip.com ")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'tzo.com'

				# Set provider to 'tzo.com'
	       			@ff.select_list(:name,'ddns_provider').select("tzo.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'ods.org'

				# Set provider to 'ods.org'
	        		@ff.select_list(:name,'ddns_provider').select("ods.org")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'easydns.com'

				# Set provider to 'easydns.com'
	       			@ff.select_list(:name,'ddns_provider').select("easydns.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'zoneedit.com'

				# Set provider to 'zoneedit.com'
	        		@ff.select_list(:name,'ddns_provider').select("zoneedit.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		else 
				# Wrong
				self.msg(rule_name,:error,'connection','Did NOT find the value in \'Provider\'.')
				return
	    
	    		end # End of case provider;

		end # End of if provider;

		if info.has_key?('User Name') then
	   
	   		@ff.text_field(:name,'ddns_username').value = info['User Name']
	   		self.msg(rule_name,:info,'User Name',info['User Name'])
		end # end of if

		if info.has_key?('Password') then
	    		@ff.text_field(:type,'password').set(info['Password'])
	    		self.msg(rule_name,:info,'Password',info['Password'])
		end # end of if
	

		# Select list in the "Dynamic DNS System"
		if info.has_key?('Dynamic DNS System')
	
	   	  case info['Dynamic DNS System']
	    
	   		when 'Dynamic DNS'

				# Set 'Dynamic DNS'
	        		@ff.select_list(:name,'ddns_system').select("Dynamic DNS")
	        		self.msg(rule_name,:info,'Dynamic DNS System',info['Dynamic DNS System'])
	
	    		when 'Static DNS'

				# Set 'Static DNS'
	        		@ff.select_list(:name,'ddns_system').select("Static DNS")
	        		self.msg(rule_name,:info,'Dynamic DNS System',info['Dynamic DNS System'])

	    		when 'Custom DNS'

				# Set 'Custom DNS'
	        		@ff.select_list(:name,'ddns_system').select("Custom DNS")
	        		self.msg(rule_name,:info,'Dynamic DNS System',info['Dynamic DNS System'])

    	    		else 

				# Wrong
				self.msg(rule_name,:error,'Dynamic DNS System','Did NOT find the value in \'Dynamic DNS System\'.')
				return
	    
	    		end # End of case Dynamic DNS system;

		end # End of if Dynamic DNS system;

		# Set wildcard to 'on' or 'off'
		if info.has_key?('Wildcard')
        
	    		# Enable wildcard 
	    	  case info['Wildcard']
	  
	   		when 'on'
	  
				@ff.checkbox(:name,'dyndns_wildcard').set
				self.msg(rule_name,:info,'Wildcard',info['Wildcard'])    
	  
	     		# Disable wildcard
	     		when 'off'
	
				@ff.checkbox(:name,'dyndns_wildcard').clear	
				self.msg(rule_name,:info,'Wildcard',info['Wildcard'])
	    		else
				# wrong here
				self.msg(rule_name,:error,'Wildcard','Did NOT find the value in \'Wildcard\'.')
		
	  	   end # End of case wildcard

		end # End of if wildcard

		# Set backup mx to 'on' or 'off'
		if info.has_key?('Backup MX')
        
	    	# Enable backup mx
	    	case info['Backup MX']
	  
	   		when 'on'
	  
				@ff.checkbox(:name,'dyndns_backup_mx').set
				self.msg(rule_name,:info,'backup mx',info['Backup MX'])    
	  
	     		# Disable backup mx
	     		when 'off'
	
				@ff.checkbox(:name,'dyndns_backup_mx').clear	
				self.msg(rule_name,:info,'backup mx',info['Backup MX'])
	    		else
				# wrong here
				self.msg(rule_name,:error,'Backup MX','Did NOT find the value in \'backup MX\'.')
		
	  	   end # End of case backup mx

		 end # End of if backup Mx

		# Set offline to 'on' or 'off'
		if info.has_key?('Backup MX')
        
	    	# Enable backup mx
	    	case info['Offline']
	  
	   		when 'on'
	  
				@ff.checkbox(:name,'dyndns_offline').set
				self.msg(rule_name,:info,'offline',info['Offline'])    
	  
	     		# Disable offline
	     		when 'off'
	
				@ff.checkbox(:name,'dyndns_offline').clear	
				self.msg(rule_name,:info,'offline',info['Offline'])
	    		else
				# wrong here
				self.msg(rule_name,:error,'Offline','Did NOT find the value in \'Offline\'.')
		
	  	   end # End of case offline

		 end # End of if offline

		# Apply for the change;
		@ff.link(:text,'Apply').click
    if @ff.text.include?'Input Errors'
        # Error here.
      
        # Find the table.
        sTable = false
        @ff.tables.each do |t|
			if ( t.text.include? ':' and 
				( not t.text.include? 'Input Errors') and
				( not t.text.include? 'Cancel') and
				t.row_count >= 1 )then
					sTable = t
				break
			end
		end
      
		if sTable == false
        # Wrong here
			self.msg(rule_name,:error,'System Settings','Did NOT find the target table.')
			return
		end
      
		sTable.each do |row|
        
			if row[1] == "" or row[2] == nil
			next
			end
        
			self.msg(rule_name,:error,row[1],row[2])
        
		end
       
		# Click the "cancel"
		@ff.link(:text,'Cancel').click
       
		return
      
    end 
		# Jump out the "Input Errors"?
		if @ff.text.include?'Input Errors' then

			@ff.link(:text,'Cancel').click
 	    		self.msg(rule_name,:error,'Dynamic_DNS','Input content may not correct.')
	   		return
		else
	  		self.msg(rule_name,:info,'Dynamic DNS','SUCCESS')
	
		end # End of case


	    # Add Dynamic DNS entry ok.
	    #
	    # close the page
	    #@ff.link(:text,'Close').click
	# ##########################	
      	# Case three: add multi record;
      	# ##########################
      	when 'multihost'
		
	    if info.has_key?('Loop Number')
			
	    for i in 1..info['Loop Number'].to_i	
		
		# Delete the Entry as same,'Remove')
 		#if @ff.text.include? info['Host Name'] and info['Host Name'] != " " then
	    	#	str_href = @ff.link(:text,info['Host Name']).href
		#	str_href.gsub!('edit','remove')
		#	@ff.link(:href,str_href).click
		#end # End of if	

		# Add an new Dynamic DNS Entry;
	    	@ff.link(:text,'New Dynamic DNS Entry').click
	    	self.msg(rule_name,:info,'Add Dynamic DNS Entry','CLICKED')

	    	# Fill in the "Host Name"
	    	if info.has_key?('Host Name') 
	    
	        	@ff.text_field(:name,'ddns_host').value = info['Host Name'] + i.to_s
	        	self.msg(rule_name,:info,'Host Name',info['Host Name'] + i.to_s)
	    	else
	        	self.msg(rule_name,:error,'Host Name','Con NOT find the value in \'Host Name\'.')

	    	end # End of if

	    	# Select list in the "Connection"
	    	if info.has_key?('Connection')
	
	          case info['Connection']
	    
	        	when 'WAN Ethernet'

		    		# Set connection is 'Broadband Connection (Ethernet)'
	            		@ff.select_list(:name,'ddns_device').select("WAN Ethernet")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])
			when 'Broadband Connection (Ethernet)'	        	

		    		# Set connection is 'Broadband Connection (Ethernet)'
	            		@ff.select_list(:name,'ddns_device').select("Broadband Connection (Ethernet)")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])

	        	when 'Broadband Connection (Coax)'

	            		# Set connection is 'Broadband Connection (Coax)'
	            		@ff.select_list(:name,'ddns_device').select("Broadband Connection (Coax)")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])

	        	when 'WAN PPPoE'

	            		# Set connection is 'WAN PPPoE'
	            		@ff.select_list(:name,'ddns_device').select("WAN PPPoE")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])

	        	when 'WAN PPPoE 2'

	            		# Set connection is 'WAN PPPoE 2'
	            		@ff.select_list(:name,'ddns_device').select("WAN PPPoE 2")
	            		self.msg(rule_name,:info,'Connection',info['Connection'])
	                else 

		   	 	# Wrong
		   	 	self.msg(rule_name,:error,'connection','Did NOT find the value in \'Connection\'.')
		   		 return
	    
	       	 	end # End of case connection;

	    	end # End of if connection;

	    	# Select list in the "provider"
	    	if info.has_key?('Provider')
	
	      	  case info['Provider']
	    
	    		when 'dyndns.org'

				# Set provider to 'dyndns.org'
	       			@ff.select_list(:name,'ddns_provider').select("dyndns.org")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	   		when 'no-ip.com'

				# Set provider to 'no-ip.com'
	        		@ff.select_list(:name,'ddns_provider').select("no-ip.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'changeip.com'

				# Set provider to 'changeip.com '
	        		@ff.select_list(:name,'ddns_provider').select("changeip.com ")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'tzo.com'

				# Set provider to 'tzo.com'
	       			@ff.select_list(:name,'ddns_provider').select("tzo.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'ods.org'

				# Set provider to 'ods.org'
	        		@ff.select_list(:name,'ddns_provider').select("ods.org")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'easydns.com'

				# Set provider to 'easydns.com'
	       			@ff.select_list(:name,'ddns_provider').select("easydns.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		when 'zoneedit.com'

				# Set provider to 'zoneedit.com'
	        		@ff.select_list(:name,'ddns_provider').select("zoneedit.com")
	        		self.msg(rule_name,:info,'Provider',info['Provider'])

	    		else 
				# Wrong
				self.msg(rule_name,:error,'connection','Did NOT find the value in \'Provider\'.')
				return
	    
	    		end # End of case provider;

		end # End of if provider;

		if info.has_key?('User Name') then
	   
	   		@ff.text_field(:name,'ddns_username').value = info['User Name']
	   		self.msg(rule_name,:info,'User Name',info['User Name'])
		end # end of if

		if info.has_key?('Password') then
	    		@ff.text_field(:type,'password').set(info['Password'])
	    		self.msg(rule_name,:info,'Password',info['Password'])
		end # end of if
	

		# Select list in the "Dynamic DNS System"
		if info.has_key?('Dynamic DNS System')
	
	   	  case info['Dynamic DNS System']
	    
	   		when 'Dynamic DNS'

				# Set 'Dynamic DNS'
	        		@ff.select_list(:name,'ddns_system').select("Dynamic DNS")
	        		self.msg(rule_name,:info,'Dynamic DNS System',info['Dynamic DNS System'])
	
	    		when 'Static DNS'

				# Set 'Static DNS'
	        		@ff.select_list(:name,'ddns_system').select("Static DNS")
	        		self.msg(rule_name,:info,'Dynamic DNS System',info['Dynamic DNS System'])

	    		when 'Custom DNS'

				# Set 'Custom DNS'
	        		@ff.select_list(:name,'ddns_system').select("Custom DNS")
	        		self.msg(rule_name,:info,'Dynamic DNS System',info['Dynamic DNS System'])

    	    		else 

				# Wrong
				self.msg(rule_name,:error,'Dynamic DNS System','Did NOT find the value in \'Dynamic DNS System\'.')
				return
	    
	    		end # End of case Dynamic DNS system;

		end # End of if Dynamic DNS system;

		# Set wildcard to 'on' or 'off'
		if info.has_key?('Wildcard')
        
	    		# Enable wildcard 
	    	  case info['Wildcard']
	  
	   		when 'on'
	  
				@ff.checkbox(:name,'dyndns_wildcard').set
				self.msg(rule_name,:info,'Wildcard',info['Wildcard'])    
	  
	     		# Disable wildcard
	     		when 'off'
	
				@ff.checkbox(:name,'dyndns_wildcard').clear	
				self.msg(rule_name,:info,'Wildcard',info['Wildcard'])
	    		else
				# wrong here
				self.msg(rule_name,:error,'Wildcard','Did NOT find the value in \'Wildcard\'.')
		
	  	   end # End of case wildcard

		end # End of if wildcard

		# Apply for the change;
		@ff.link(:text,'Apply').click
	        
		# need to logout when multi-login 
		#@ff.select_list(:name,'logout').select("Logout")
		#self.msg(rule_name,:info,'Logout','Logout the page of DUT.')
		#@ff.link(:name,'logout').click	
		#self.msg(rule_name,:info,'Logout','Logout the page of DUT.')
	
		# Jump out the "Input Errors"?
		if @ff.text.include?'Input Errors' then

			@ff.link(:text,'Cancel').click
 	    		self.msg(rule_name,:error,'Dynamic_DNS','Input content may not correct.')
	   		return
		else
	  		self.msg(rule_name,:info,'Dynamic DNS','SUCCESS')
	
		end # End of if
		
		    
	    end # End of loop;

	    # Add Dynamic DNS entry ok.
	    #
	    # close the page
	    @ff.link(:text,'Close').click
	  end # End of case
 	
	# ###########################
      	# case four: update a record;
      	# ###########################
	when 'update'

	    if @ff.text.include?info['Host Name'] then

	        begin
           		@ff.link(:href, 'javascript:mimic_button(\'ddns_host_update: 0..\', 1)').click
			self.msg(rule_name,:info,'update','Update the status of host name')    
       		rescue
			self.msg(rule_name,:error,'update','Con NOT find the link of update ')
           		return
       		end  
     
       		# Waiting for update
       		sleep 10

       		# To Click Refresh to see if the status has been changed
       		begin
          		@ff.link(:text, "Refresh").click
			self.msg(rule_name,:info,'refresh','refrash the status of host name') 
       		rescue
          		self.msg(rule_name,:error,'refresh','Con NOT find the link of refresh ')
          		return
       		end

       		if @ff.text.match 'Updated' then
          		self.msg(rule_name,:info,'status','The status of \'hostname\' is successful')
       		else
          		self.msg(rule_name,:error,'status','The status of \'hostname\' is fail ')
       		end

			
	    else
		self.msg(rule_name,:error,'Host Name','Con NOT find the value in \'Host Name\'.')
	    end
	    #################################
	    ##read the dns server's status###
	    #################################
	when 'read the status'
	    sTable = false
	    @ff.tables.each do |t|
		if ( t.text.include? 'Host Name' and
		    ( not t.text.include? 'Domain Name Server') and
		    t.row_count > 1 )then
		    sTable = t
		   break
		end
	    end
	    if sTable == false
      # Wrong here
		self.msg(rule_name,:error,'read ddns status','Did NOT find the target table.')
	    else
		sTable.each do |row|
		    if ((not row.text.include? 'Host Name') and (not row.text.include? 'New Dynamic DNS Entry'))
		    self.msg(rule_name,:info,row[1].to_s.gsub(':',''),row[2].to_s);
		end
	    end
	end
    
    # Find the row
    

	else
      		self.msg(rule_name,:error,'dns_server','Not right the operation to execute')
      		return
    	
	end  # End of case;

    end # End of operation;
	
  end # End of def


  #----------------------------------------------------------------------
  # dns_server(rule_name, info)
  # Discription: function of "DNS Server" under "Advance" page.
  #----------------------------------------------------------------------
  def dns_server(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "DNS Server" page.
    begin
      @ff.link(:text, 'DNS Server').click
      self.msg(rule_name, :info, 'DNS Server', 'Reached page \'DNS Server\'.')
    rescue
      self.msg(rule_name, :error, 'DNS Server', 'Did not reach \'DNS Server\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'dns_server','Some key NOT found.')
      return
    end     
    
    # Add DNS Server?
    if ( info.has_key?('Host Name') &&
         info.has_key?('IP Address') ) then
         
      # Right,go on.
      
      if @ff.text.include? info['Host Name'] then
	    str_href = @ff.link(:text,info['Host Name']).href
	    str_href.gsub!("edit","remove")
	    @ff.link(:href,str_href).click
      end
    

      # Add a DNS server here.
      @ff.link(:text,'Add DNS Entry').click
      self.msg(rule_name,:info,'Add DNS Entry','CLICKED')
      
      # Fill in the "Host Name"
      @ff.text_field(:name,'hostname').set(info['Host Name'])
      self.msg(rule_name,:info,'Host Name',info['Host Name'])
      
      # Fill in the "IP Address"
      octets = info['IP Address'].split('.')
      @ff.text_field(:name, 'ip0').set(octets[0])
      @ff.text_field(:name, 'ip1').set(octets[1])
      @ff.text_field(:name, 'ip2').set(octets[2])
      @ff.text_field(:name, 'ip3').set(octets[3])
      self.msg(rule_name,:info,'IP Address',info['IP Address'])
      
      # Apply for the change
      @ff.link(:text,'Apply').click
      
      # Jump out the "Input Errors"?
      if @ff.text.include?'Input Errors' then
        @ff.link(:text,'Cancel').click
        @ff.link(:text,'Close').click
        self.msg(rule_name,:error,'dns_server','Input content may not correct.')
        return
      else
        self.msg(rule_name,:info,'DNS Server','SUCCESS')
      end
      
      # Add DNS entry OK.
      
      # Close the page
      @ff.link(:text,'Close').click
      
    else
      self.msg(rule_name,:error,'dns_server','Some key NOT found.')
      return
    end    
    
  end # end of def
  
  #----------------------------------------------------------------------
  # network_objects(rule_name, info)
  # Discription: function of "Network Objects" under "Advance" page.
  #----------------------------------------------------------------------
  def network_objects(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Network Objects" page.
    begin
      @ff.link(:text, 'Network Objects').click
      self.msg(rule_name, :info, 'Network Objects', 'Reached page \'Network Objects\'.')
    rescue
      self.msg(rule_name, :error, 'Network Objects', 'Did not reach \'Network Objects\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') && info.has_key?('Description') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'Network Objects','Some key NOT found.')
      return
    end
          
    # Click "Add" button. 
    @ff.link(:text,'Add').click
    self.msg(rule_name,:info,'Add a network object','CLICKED')
    
    # Fill in the "Discription".
    @ff.text_field(:name,'desc').set(info['Description'])
    self.msg(rule_name,:info,'Description',info['Description'])
    
    # Add "Items"
    self.msg(rule_name,:info,'Begin adding network object items','done!')
    
    if info.has_key?('IP Address') then
      
      # Add ip address
      network_objects_add_ip(rule_name,info['IP Address'])
      self.msg(rule_name,:info,'Add ip address',info['IP Address'])
    
    end
      
    if ( info.has_key?('Subnet IP Address') &&
         info.has_key?('Subnet Mask') )then
      
      strSubnet = info['Subnet IP Address'] + "/" + info['Subnet Mask']
      
      # Add ip subnet
      network_objects_add_2_ip(rule_name,strSubnet,1)
      self.msg(rule_name,:info,'Add ip subnet',strSubnet)

    
    end
          
    if ( info.has_key?('From IP Address') &&
         info.has_key?('To IP Address') ) then
      
      strIPRange = info['From IP Address'] + "/" + info['To IP Address']
      
      # Add ip range
      self.msg(rule_name,:info,'Add ip range',strIPRange)
      network_objects_add_2_ip(rule_name,strIPRange,2)

    end

    if info.has_key?('MAC Address') && info.has_key?('MAC Mask') then
      
      strMAC = info['MAC Address'] + "/" + info['MAC Mask']
      
      # Add mac
      self.msg(rule_name,:info,'Add mac',strMAC)
      network_objects_add_mac(rule_name,strMAC)
      
    end
    
    if info.has_key?('Host Name') then     
      
      # Add host
      self.msg(rule_name,:info,'Add mac',info['Host Name'])
      network_objects_add_host(rule_name,info['Host Name'])
      
    end
    
    if info.has_key?('Vendor Class ID')
      
      strDHCP = "Vendor:" + info['Vendor Class ID'].to_s
      
      # Add dhcp option
      self.msg(rule_name,:info,'Add dhcp option',strDHCP)
      network_objects_add_dhcp_option(rule_name,strDHCP)           
              
    end
    
    if info.has_key?('Client ID')
      
      strDHCP = "Client:" + info['Client ID'].to_s
      
      # Add dhcp option
      self.msg(rule_name,:info,'Add dhcp option',strDHCP)
      network_objects_add_dhcp_option(rule_name,strDHCP)           
              
    end    
    
    if info.has_key?('User Class ID')
      
      strDHCP = "User:" + info['User Class ID'].to_s
      
      # Add dhcp option
      self.msg(rule_name,:info,'Add dhcp option',strDHCP)
      network_objects_add_dhcp_option(rule_name,strDHCP)           
              
    end     
           
    # Apply for the network ojects.
    if @ff.text.include?'Apply'
      @ff.link(:text,'Apply').click
    end
    
    # Jump out "error" message?
    if @ff.text.include?'Input Errors'
      # Wrong here
      self.msg(rule_name,:error,'Network Objects','Error occurred on web page.')
      return
    end
    
    # Close the page.
    @ff.link(:text,'Close').click
    self.msg(rule_name,:info,'Network Objects','SUCCESS')
    # Now, will go to main "Advanced" page.
    
  end # end of def
  
  #---------------------------------------------------------------------
  # network_objects_add_ip(rule_name,data)
  # Description: Inside function, will be called by network_objects()
  #              Add an IP for a specified network object item. 
  #---------------------------------------------------------------------
  def network_objects_add_ip(rule_name,data)
    
    addr_list = data.split(',')
    self.msg(rule_name, :debug, 'network_objects_add_ip', "addr_list" +addr_list.to_s)
    
    addr_list.each do |ip_data|
      
      self.msg(rule_name, :debug, 'network_objects_add_ip', "processing address" +ip_data.to_s)
      @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
      @ff.select_list(:name, 'net_obj_type').select_value('1')
      
      if ip_data.size > 0
        
         self.msg(rule_name, :debug, 'network_objects_add_ip', "set ip address" +ip_data)
         str_ip_data = ip_data.strip
         octets=str_ip_data.split('.')
         @ff.text_field(:name, 'ip0').set(octets[0])
         @ff.text_field(:name, 'ip1').set(octets[1])
         @ff.text_field(:name, 'ip2').set(octets[2])
         @ff.text_field(:name, 'ip3').set(octets[3])
         @ff.link(:text, 'Apply').click
         
      end # end of if
   
    end # end of each
    
  end # end of def

  #----------------------------------------------------------------------------------
  # network_objects_add_2_ip
  # Discription: Inside functions, will be called by network_objects().
  #              Add IP range or IP subnet for network objects item.
  #----------------------------------------------------------------------------------
  def network_objects_add_2_ip(rule_name,data,sub_or_range)
  
    if sub_or_range == 1
        addr_list = data.split(',')
        input_base = 'subnet'
        select_val ='16'
    else
        addr_list = data.split(',')
        input_base = 'range'
        select_val ='2'
    end
    
    self.msg(rule_name, :debug, 'network_objects_add_2_ip', "addr_list" +addr_list.to_s)
    
    addr_list.each do |dual_ip_data|
      
      self.msg(rule_name, :debug, 'network_objects_add_2_ip', "processing address" +dual_ip_data.to_s)
      @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
      @ff.select_list(:name, 'net_obj_type').select_value(select_val)
      ip_data=dual_ip_data.split('/')
      
      if ip_data[0].size > 0 and ip_data[1].size > 0
        
         self.msg(rule_name, :debug, 'network_objects_add_2_ip', "set ip " + input_base +": " \
                                                   + ip_data[0] + "/" + ip_data[1])
         str_ip_data = ip_data[0].strip
         octets=str_ip_data.split('.')
         @ff.text_field(:name, input_base +'_00').set(octets[0])
         @ff.text_field(:name, input_base +'_01').set(octets[1])
         @ff.text_field(:name, input_base +'_02').set(octets[2])
         @ff.text_field(:name, input_base +'_03').set(octets[3])
         
         # set the subnet or range
         str_ip_data = ip_data[1].strip
         octets=str_ip_data.split('.')
         @ff.text_field(:name, input_base +'_10').set(octets[0])
         @ff.text_field(:name, input_base +'_11').set(octets[1])
         @ff.text_field(:name, input_base +'_12').set(octets[2])
         @ff.text_field(:name, input_base +'_13').set(octets[3])
  
         @ff.link(:text, 'Apply').click
         
       end # end of if..
          
    end # end of each...

  end # end of def...
  
  #----------------------------------------------------------------------------------
  # network_objects_add_mac
  # Description: Inside functions, will be called by network_objects()
  #              Add mac address for network objects item.
  #----------------------------------------------------------------------------------
  def network_objects_add_mac(rule_name,data)
    
    addr_list = data.split(',')
    self.msg(rule_name, :debug, 'network_objects_add_mac', "addr_list" +addr_list.to_s)
    
    addr_list.each do |dual_mac_data|
      
      self.msg(rule_name, :debug, 'network_objects_add_mac', "processing mac address" +dual_mac_data.to_s)
      
      @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
      @ff.select_list(:name, 'net_obj_type').select_value("4")
      mac_data=dual_mac_data.split('/')
      
      if mac_data.length > 0 and mac_data.length < 3
         
        if mac_data[0].size > 0 
           self.msg(rule_name, :debug, 'network_objects_add_mac', "set mac " + mac_data[0])
           str_mac_data = mac_data[0].strip
           octets=str_mac_data.split(':')
           @ff.text_field(:name, 'mac0').set(octets[0])
           @ff.text_field(:name, 'mac1').set(octets[1])
           @ff.text_field(:name, 'mac2').set(octets[2])
           @ff.text_field(:name, 'mac3').set(octets[3])
           @ff.text_field(:name, 'mac4').set(octets[4])
           @ff.text_field(:name, 'mac5').set(octets[5])
        end # end of if...
        
       end # end of if mac_data.len...
       
       if mac_data.length == 2
         
         if mac_data[1].size > 0
           
           self.msg(rule_name, :debug, 'network_objects_add_mac', "set mac mask" + mac_data[1])
           # set the mask
           str_mac_data = mac_data[1].strip
           octets=str_mac_data.split(':')
           @ff.text_field(:name, 'mac_mask0').set(octets[0])
           @ff.text_field(:name, 'mac_mask1').set(octets[1])
           @ff.text_field(:name, 'mac_mask2').set(octets[2])
           @ff.text_field(:name, 'mac_mask3').set(octets[3])
           @ff.text_field(:name, 'mac_mask4').set(octets[4])
           @ff.text_field(:name, 'mac_mask5').set(octets[5])
           
         end

       end
          
       @ff.link(:text, 'Apply').click
           
     end # end of addr_list.each...
     
  end # end of def...
 
  #----------------------------------------------------------------------
  # network_objects_add_host()
  # Description: Inside function, will be called by network_objects()
  #              Add a host for a specified item.
  #----------------------------------------------------------------------
  def network_objects_add_host(rule_name,data)
    
    host_list = data.split(',')
    self.msg(rule_name, :debug, 'network_objects_add_host', "host_list" +host_list.to_s)
    host_list.each do |host|
    self.msg(rule_name, :debug, 'network_objects_add_host', "processing host" +host.to_s)
   
    @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
    @ff.select_list(:name, 'net_obj_type').select_value('8')
    
    if host.size > 0
       self.msg(rule_name, :debug, 'network_objects_add_host', "set host" +host)
       @ff.text_field(:name, 'hostname').set(host.strip)
       @ff.link(:text, 'Apply').click
    end
   
  end
  
  end # end of def
  
  #----------------------------------------------------------------------
  # network_objects_add_dhcp_option()
  # Description: Inside function, will be called by network_objects()
  #              Add a host for a specified item.
  #----------------------------------------------------------------------
  def network_objects_add_dhcp_option(rule_name,data)

    dhcp_list = data.split(',')
    self.msg(rule_name, :debug, 'network_objects_add_dhcp_option', "dhcp_list" +dhcp_list.to_s)
    
    dhcp_list.each do |dhcp|
      
      self.msg(rule_name, :debug, 'network_objects_add_dhcp_option', "processing dhcp_option" +dhcp.to_s)
      
      @ff.link(:href, 'javascript:mimic_button(\'add: ...\', 1)').click
      @ff.select_list(:name, 'net_obj_type').select_value('64')
      
      if dhcp.size > 0
        
         dhcp_opts=dhcp.split(':')
         
         if dhcp_opts[0] == "Vendor"
            @ff.select_list(:name, 'dhcp_opt_code').select_value('60')
         end
         
         if dhcp_opts[0] == "Client"
            @ff.select_list(:name, 'dhcp_opt_code').select_value('61')
         end
         
         if dhcp_opts[0] == "User"
            @ff.select_list(:name, 'dhcp_opt_code').select_value('77')
         end
         
         self.msg(rule_name, :debug, 'network_objects_add_dhcp_option', "set dhcp" +dhcp)
         
         @ff.text_field(:name, 'dhcp_opt_type').set(dhcp_opts[1].to_s)
         @ff.link(:text, 'Apply').click
         
       end # end of if
     
    end # end of each
    
  end # end of def
  
  #----------------------------------------------------------------------
  # universal_plug_and_play(rule_name, info)
  # Description: function of "Universal Plug and Play" under "Advance" page.
  #----------------------------------------------------------------------
  def universal_plug_and_play(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Universal Plug and Play" page.
    begin
      @ff.link(:text, 'Universal Plug and Play').click
      self.msg(rule_name, :info, 'Universal Plug and Play', 'Reached page \'Universal Plug and Play\'.')
    rescue
      self.msg(rule_name, :error, 'Universal Plug and Play', 'Did not reach \'Universal Plug and Play\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'local_administration','Some key NOT found.')
      return
    end 
    
    # Parese the json file.
    
    # "Allow Other Network Users to Control Wireless Broadband Router\'s Network Features"
    if info.has_key?('Allow Other Network Users to Control Wireless Broadband Router\'s Network Features')
      
      case info['Allow Other Network Users to Control Wireless Broadband Router\'s Network Features']
      
      when 'on'
        
        # Set "Allow Other Network Users to Control Wireless Broadband Router\'s Network Features"
        @ff.checkbox(:name,'upnp_enabled').set
        self.msg(rule_name,:info,'Allow Other Network Users to Control Wireless Broadband Router\'s Network Features',info['Allow Other Network Users to Control Wireless Broadband Router\'s Network Features'])
 
      when 'off'
        
        # Clear "Allow Other Network Users to Control Wireless Broadband Router\'s Network Features"
        @ff.checkbox(:name,'upnp_enabled').clear
        self.msg(rule_name,:info,'Allow Other Network Users to Control Wireless Broadband Router\'s Network Features',info['Allow Other Network Users to Control Wireless Broadband Router\'s Network Features'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Allow Other Network Users to Control Wireless Broadband Router\'s Network Features\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # "Enable Automatic Cleanup of Old Unused UpnP Services"
    if info.has_key?('Enable Automatic Cleanup of Old Unused UpnP Services')
      
      case info['Enable Automatic Cleanup of Old Unused UpnP Services']
      
      when 'on'
        
        # Set "Enable Automatic Cleanup of Old Unused UpnP Services"
        @ff.checkbox(:name,'upnp_rules_auto_clean_enabled').set
        self.msg(rule_name,:info,'Enable Automatic Cleanup of Old Unused UpnP Services',info['Enable Automatic Cleanup of Old Unused UpnP Services'])
 
      when 'off'
        
        # Clear "Enable Automatic Cleanup of Old Unused UpnP Services"
        @ff.checkbox(:name,'upnp_rules_auto_clean_enabled').clear
        self.msg(rule_name,:info,'Enable Automatic Cleanup of Old Unused UpnP Services',info['Enable Automatic Cleanup of Old Unused UpnP Services'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Enable Automatic Cleanup of Old Unused UpnP Services\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Publish Only the Main WAN Connection"
    if info.has_key?('Publish Only the Main WAN Connection')
      
      case info['Publish Only the Main WAN Connection']
      
      when 'on'
        
        # Set "Publish Only the Main WAN Connection"
        @ff.select_list(:name,'wan_conns_to_publish').select_value("0")
        self.msg(rule_name,:info,'Publish Only the Main WAN Connection',info['Publish Only the Main WAN Connection'])
 
      when 'off'
        
        # Clear "Publish Only the Main WAN Connection"
        # Do nothing.
        self.msg(rule_name,:info,'Publish Only the Main WAN Connection',info['Publish Only the Main WAN Connection'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Publish Only the Main WAN Connection\'.')
        return
        
      end # end of case
      
    end # end of if   
    
    # "Publish All WAN Connections"
    if info.has_key?('Publish All WAN Connections')
      
      case info['Publish All WAN Connections']
      
      when 'on'
        
        # Set "Publish All WAN Connections"
        @ff.select_list(:name,'wan_conns_to_publish').select_value("1")
        self.msg(rule_name,:info,'Publish All WAN Connections',info['Publish All WAN Connections'])
 
      when 'off'
        
        # Clear "Publish All WAN Connections"
        # Do nothing.
        self.msg(rule_name,:info,'Publish All WAN Connections',info['Publish All WAN Connections'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Publish All WAN Connections\'.')
        return
        
      end # end of case
      
    end # end of if   

  # Apply for the change.
  @ff.link(:text,'Apply').click
  self.msg(rule_name,:info,'Universal Plug and Play','SUCCESS')
    
  end # end of def

  #----------------------------------------------------------------------
  # sip_alg(rule_name, info)
  # Discription: function of "SIP ALG" under "Advance" page.
  #----------------------------------------------------------------------
  def sip_alg(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "SIP ALG" page.
    begin
      @ff.link(:text, 'SIP ALG').click
      self.msg(rule_name, :info, 'SIP ALG', 'Reached page \'SIP ALG\'.')
    rescue
      self.msg(rule_name, :error, 'SIP ALG', 'Did not reach \'SIP ALG\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'sip_alg','Some key NOT found.')
      return
    end 
    
    # Parese the json file.

    # "Enable"
    if info.has_key?('Enable')
      
      case info['Enable']
      
      when 'on'
        
        # Set "Enable"
        @ff.radio(:id,'sip_alg_enable_1').set
        self.msg(rule_name,:info,'Enable',info['Enable'])
 
      when 'off'
        
        # Clear "Enable"
        @ff.radio(:id,'sip_alg_enable_1').clear
        self.msg(rule_name,:info,'Enable',info['Enable'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'sip_alg','Did NOT find the value in \'Enable\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # "Disable"
    if info.has_key?('Disable')
      
      case info['Disable']
      
      when 'on'
        
        # Set "Disable"
        @ff.radio(:id,'sip_alg_enable_0').set
        self.msg(rule_name,:info,'Disable',info['Disable'])
 
      when 'off'
        
        # Clear "Disable"
        @ff.radio(:id,'sip_alg_enable_0').clear
        self.msg(rule_name,:info,'Disable',info['Disable'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'sip_alg','Did NOT find the value in \'Disable\'.')
        return
        
      end # end of case
      
    end # end of if   

    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Confirm it
    if @ff.text.include?'Attention'
      
      @ff.link(:text,'Apply').click
      
      # wait for rebooting...
      
      # give it some time to reboot
    
      count = 0
      while count <= 10
        
        # Rebooting...
        if @ff.text.include?'is up again'
          self.msg(rule_name,:info,'SIP ALG','SUCCESS')
          break
        end
        
        count += 1
        sleep 5
        
      end
      
      @ff.refresh
      
      if @ff.text.include?'is up again'
        self.msg(rule_name,:info,'SIP ALG','SUCCESS')
        return
      end
      
      if count == 11    
        self.msg(rule_name, :error, 'sip_alg', 'Did not reboot.')
        return      
      end 
    
    end
  
  end # end of def

  #----------------------------------------------------------------------
  # mgcp_alg(rule_name, info)
  # Discription: function of "MGCP ALG" under "Advance" page.
  #----------------------------------------------------------------------
  def mgcp_alg(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "MGCP ALG" page.
    begin
      @ff.link(:text, 'MGCP ALG').click
      self.msg(rule_name, :info, 'MGCP ALG', 'Reached page \'MGCP ALG\'.')
    rescue
      self.msg(rule_name, :error, 'MGCP ALG', 'Did not reach \'MGCP ALG\' page')
      return
    end
    
   # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'mgcp_alg','Some key NOT found.')
      return
    end 
    
    # Parese the json file.

    # "Enable"
    if info.has_key?('Enable')
      
      case info['Enable']
      
      when 'on'
        
        # Set "Enable"
        @ff.radio(:id,'mgcp_alg_enable_1').set
        self.msg(rule_name,:info,'Enable',info['Enable'])
 
      when 'off'
        
        # Clear "Enable"
        @ff.radio(:id,'mgcp_alg_enable_1').clear
        self.msg(rule_name,:info,'Enable',info['Enable'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'mgcp_alg','Did NOT find the value in \'Enable\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # "Disable"
    if info.has_key?('Disable')
      
      case info['Disable']
      
      when 'on'
        
        # Set "Disable"
        @ff.radio(:id,'mgcp_alg_enable_0').set
        self.msg(rule_name,:info,'Disable',info['Disable'])
 
      when 'off'
        
        # Clear "Disable"
        @ff.radio(:id,'mgcp_alg_enable_0').clear
        self.msg(rule_name,:info,'Disable',info['Disable'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'mgcp_alg','Did NOT find the value in \'Disable\'.')
        return
        
      end # end of case
      
    end # end of if   

    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Confirm it
    if @ff.text.include?'Attention'
      
      @ff.link(:text,'Apply').click
      
      # wait for rebooting...
      
      # give it some time to reboot
    
      count = 0
      while count <= 10
        
        # Rebooting...
        if @ff.text.include?'is up again'
          self.msg(rule_name,:info,'MGCP ALG','SUCCESS')
          break
        end
        
        count += 1
        sleep 5
        
      end
      
      @ff.refresh
      
      if @ff.text.include?'is up again'
        self.msg(rule_name,:info,'MGCP ALG','SUCCESS')
        return
      end
      
      if count == 11    
        self.msg(rule_name, :error, 'mgcp_alg', 'Did not reboot.')
        return      
      end 
    
    end    
    
  end # end of def

  #----------------------------------------------------------------------
  # protocols(rule_name, info)
  # Discription: function of "Protocols" under "Advance" page.
  #----------------------------------------------------------------------
  def protocols(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Protocols" page.
    begin
      @ff.link(:text, 'Protocols').click
      self.msg(rule_name, :info, 'Protocols', 'Reached page \'Protocols\'.')
    rescue
      self.msg(rule_name, :error, 'Protocols', 'Did not reach \'Protocols\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'protocols','Some key NOT found.')
      return
    end 
    
    # Parse the json file.
    
    # "Advanced"
    if info.has_key?('Advanced')
      
      case info['Advanced']
      
      when 'on'
        
        # Set "Advanced"
        if @ff.text.include?'Basic <<' then
          @ff.link(:text,'Basic <<').click
        end

        self.msg(rule_name,:info,'Advanced',info['Advanced'])
 
      when 'off'
        
        # Clear "Advanced"
        # Do nothing.
        self.msg(rule_name,:info,'Advanced',info['Advanced'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'protocols','Did NOT find the value in \'Advanced\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # "Basic"
    if info.has_key?('Basic')
      
      case info['Basic']
      
      when 'on'
        
        # Set "Basic"
        if @ff.text.include?'Advanced >>' then
          @ff.link(:text,'Advanced >>').click
        end

        self.msg(rule_name,:info,'Basic',info['Basic'])
 
      when 'off'
        
        # Clear "Advanced"
        # Do nothing.
        self.msg(rule_name,:info,'Basic',info['Basic'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'protocols','Did NOT find the value in \'Basic\'.')
        return
        
      end # end of case
      
    end # end of if  

    # Output the table.
    
    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Protocols' and
           t.text.include? 'Ports' and 
           ( not t.text.include? 'Below is') and
           t.row_count > 3 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'protocols','Did NOT find the target table.')
      return
    end
    
    # Find the row
    sTable.each do |row|
      
      # not for first line
      if row[1].text.include?'Protocols' then
        next
      end
      
      # not for last line
      if row[1].text.include?'Add' then
        next
      end
      
      # Find the cell
      self.msg(rule_name,:info,row[1],row[2])      
      
    end
    
    
    # Close the page
    @ff.link(:text,'Close').click
    
    # Output the result
    self.msg(rule_name,:info,'Protocols','SUCCEESS')
    
  end # end of def
  
  #----------------------------------------------------------------------
  # configuration_file(rule_name, info)
  # Discription: function of "Configuration File" under "Advance" page.
  #----------------------------------------------------------------------
  def configuration_file(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Configuration File" page.
    begin
      @ff.link(:text, 'Configuration File').click
      self.msg(rule_name, :info, 'Configuration File', 'Reached page \'Configuration File\'.')
    rescue
      self.msg(rule_name, :error, 'Configuration File', 'Did not reach \'Configuration File\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'configuration_file','Some key NOT found.')
      return
    end   
    
    if info.has_key?('Save Configuration File') then 
      
      # Click the button "Save Configuration File"
      @ff.link(:text,'Save Configuration File').click
      self.msg(rule_name,:info,'Save Configuration File','Done')
      
      # Process the popups.
    end
    
    if info.has_key?('Load Configuration File') then
      
      # Click the button "Load Configuration File"
      @ff.link(:text,'Load Configuration File').click
      
      # set the file path
      begin
        @ff.file_field(:name, "rgconf_file").set(info['Load Configuration File'])
        @ff.link(:text,'Apply').click
      rescue
        self.msg(rule_name, :error, 'configuration_file', 'Did not load configuration file')
        return
      end
      
      if @ff.text.include?'Input Errors'
        # Wrong
        self.msg(rule_name,:error,'configuration_file','Input errors!')
        return
      end
      
      # Click "Apply"
      begin
        @ff.link(:text, 'Apply').click
      rescue
        self.msg(rule_name, :error, 'configuration_file', 'Did not click Apply')
        return
      end
      
      # Waiting for reboot.
      count = 0
      while count <= 10
        
        # Rebooting...
        if @ff.text.include?'is up again'
          self.msg(rule_name,:info,'Configuration File','SUCCESS')
          break
        end
        
        count += 1
        sleep 5
        
      end
      
      @ff.refresh
      
      if @ff.text.include?'is up again'
        self.msg(rule_name,:info,'Configuration File','SUCCESS')
        return
      end
      
      if count == 11    
        self.msg(rule_name, :error, 'Configuration File', 'Did not reboot.')
        return      
      end 
      
    end
    # Output the result.
    self.msg(rule_name,:info,'Configuration File','SUCCESS')
    
  end # end of def
  
  #----------------------------------------------------------------------
  # system_settings(rule_name, info)
  # Discription: function of "System Settings" under "Advance" page.
  #----------------------------------------------------------------------
  def system_settings(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "System Settings" page.
    begin
      @ff.link(:text, 'System Settings').click
      self.msg(rule_name, :info, 'System Settings', 'Reached page \'System Settings\'.')
    rescue
      self.msg(rule_name, :error, 'System Settings', 'Did not reach \'System Settings\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'local_administration','Some key NOT found.')
      return
    end 
    
    # Parse the file.
    
    # "Wireless Broadband Router\'s Hostname"
    if info.has_key?('Wireless Broadband Router\'s Hostname')
      
      @ff.text_field(:name,'host_name').value=(info['Wireless Broadband Router\'s Hostname'])
      self.msg(rule_name,:info,'Wireless Broadband Router\'s Hostname',info['Wireless Broadband Router\'s Hostname'])
      
    end
    
    # "Local Domain"
    if info.has_key?('Local Domain')
      
      #
      @ff.text_field(:name,'domain_name').value=(info['Local Domain'])
      self.msg(rule_name,:info,'Local Domain',info['Local Domain'])
      
    end
    
    # "Automatic Refresh of System Monitoring Web Pages"
    if info.has_key?('Automatic Refresh of System Monitoring Web Pages')
      
      #
      case info['Automatic Refresh of System Monitoring Web Pages']
      when 'on'
        #
        @ff.checkbox(:name,'auto_refresh').set
      when 'off'
        #
        @ff.checkbox(:name,'auto_refresh').clear
      else
        self.msg(rule_name,:error,'system_settings','No such auto refresh value.')
        return
      end
      
      self.msg(rule_name,:info,'Automatic Refresh of System Monitoring Web Pages',info['Automatic Refresh of System Monitoring Web Pages'])
      
    end  
    
    # "Prompt for Password When Accessing via LAN"
    if info.has_key?('Prompt for Password When Accessing via LAN')
      
      case info['Prompt for Password When Accessing via LAN']
      
      when 'on'
        
        # Set "Prompt for Password When Accessing via LAN"
        @ff.checkbox(:name,'prompt_lan_password').set
        self.msg(rule_name,:info,'Prompt for Password When Accessing via LAN',info['Prompt for Password When Accessing via LAN'])
 
      when 'off'
        
        # Clear "Prompt for Password When Accessing via LAN"
        @ff.checkbox(:name,'prompt_lan_password').clear
        self.msg(rule_name,:info,'Prompt for Password When Accessing via LAN',info['Prompt for Password When Accessing via LAN'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Prompt for Password When Accessing via LAN\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Warn User Before Configuration Changes"
    if info.has_key?('Warn User Before Configuration Changes')
      
      case info['Warn User Before Configuration Changes']
      
      when 'on'
        
        # Set "Warn User Before Configuration Changes"
        @ff.checkbox(:name,'confirm_needed').set
        self.msg(rule_name,:info,'Warn User Before Configuration Changes',info['Warn User Before Configuration Changes'])
 
      when 'off'
        
        # Clear "Warn User Before Configuration Changes"
        @ff.checkbox(:name,'confirm_needed').clear
        self.msg(rule_name,:info,'Warn User Before Configuration Changes',info['Warn User Before Configuration Changes'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Warn User Before Configuration Changes\'.')
        return
        
      end # end of case
      
    end # end of if   
    
    # "Session Lifetime"
    if info.has_key?('Session Lifetime')
      
      #
      @ff.text_field(:name,'session_lifetime').value=(info['Session Lifetime'])
      self.msg(rule_name,:info,'Session Lifetime',info['Session Lifetime'])
      
    end    
    
    # "Configure number of concurrent users that can be logged into the router"
    if info.has_key?('Configure number of concurrent users that can be logged into the router')
      
      #
      @ff.select_list(:name,'concurrent users').set_value(info['Configure number of concurrent users that can be logged into the router'])
      self.msg(rule_name,:info,'Configure number of concurrent users that can be logged into the router',info['Configure number of concurrent users that can be logged into the router'])
      
    end    
    
    # "Primary HTTP Management Port"
    if info.has_key?('Primary HTTP Management Port')
      
      #
      @ff.text_field(:name,'mng_port_http_primary').value=(info['Primary HTTP Management Port'])
      self.msg(rule_name,:info,'Primary HTTP Management Port',info['Primary HTTP Management Port'])
      
    end   
    
    # "Secondary HTTP Management Port"
    if info.has_key?('Secondary HTTP Management Port')
      
      #
      @ff.text_field(:name,'mng_port_http_secondary').value=(info['Secondary HTTP Management Port'])
      self.msg(rule_name,:info,'Secondary HTTP Management Port',info['Secondary HTTP Management Port'])
      
    end    
    
    # "Primary HTTPS Management Port"
    if info.has_key?('Primary HTTPS Management Port')
      
      #
      @ff.text_field(:name,'mng_port_https_primary').value=(info['Primary HTTPS Management Port'])
      self.msg(rule_name,:info,'Primary HTTPS Management Port',info['Primary HTTPS Management Port'])
      
    end    
    
    # "Secondary HTTPS Management Port"
    if info.has_key?('Secondary HTTPS Management Port')
      
      #
      @ff.text_field(:name,'mng_port_https_secondary').value=(info['Secondary HTTPS Management Port'])
      self.msg(rule_name,:info,'Secondary HTTPS Management Port',info['Secondary HTTPS Management Port'])
      
    end   
    
    # "Primary Telnet Port"
    if info.has_key?('Primary Telnet Port')
      
      #
      @ff.text_field(:name,'mng_port_telnet_primary').value=(info['Primary Telnet Port'])
      self.msg(rule_name,:info,'Primary Telnet Port',info['Primary Telnet Port'])
      
    end   
    
    # "Secondary Telnet Port"
    if info.has_key?('Secondary Telnet Port')
      
      #
      @ff.text_field(:name,'mng_port_telnet_secondary').value=(info['Secondary Telnet Port'])
      self.msg(rule_name,:info,'Secondary Telnet Port',info['Secondary Telnet Port'])
      
    end      
    # "Primary HTTPS Management Client Authentication"
    if info.has_key?('Primary HTTPS Management Client Authentication')
      
      case info['Primary HTTPS Management Client Authentication']
      when 'None'
        @ff.select_list(:name,'mng_auth_https_primary').select_value("1")
      when 'Optional'
        @ff.select_list(:name,'mng_auth_https_primary').select_value("2")
      when 'Required'
        @ff.select_list(:name,'mng_auth_https_primary').select_value("3")
      else
        # Wrong here.
        self.msg(rule_name,:error,'System Settings','No such \'Primary HTTPS Management Client Authentication\' value.')
        return
      end # end of case
      
      self.msg(rule_name,:info,'Primary HTTPS Management Client Authentication',info['Primary HTTPS Management Client Authentication'])
      
    end 
    
    # "Secondary HTTPS Management Client Authentication"
    if info.has_key?('Secondary HTTPS Management Client Authentication')
      
      case info['Secondary HTTPS Management Client Authentication']
      when 'None'
        @ff.select_list(:name,'mng_auth_https_secondary').select_value("1")
      when 'Optional'
        @ff.select_list(:name,'mng_auth_https_secondary').select_value("2")
      when 'Required'
        @ff.select_list(:name,'mng_auth_https_secondary').select_value("3")
      else
        # Wrong here.
        self.msg(rule_name,:error,'System Settings','No such \'Secondary HTTPS Management Client Authentication\' value.')
        return
      end # end of case
      
      self.msg(rule_name,:info,'Secondary HTTPS Management Client Authentication',info['Secondary HTTPS Management Client Authentication'])
      
    end   
    
    # "Secure Telnet over SSL Client Authentication"
    if info.has_key?('Secure Telnet over SSL Client Authentication')
      
      case info['Secure Telnet over SSL Client Authentication']
      when 'None'
        @ff.select_list(:name,'mng_auth_telnets').select_value("1")
      when 'Optional'
        @ff.select_list(:name,'mng_auth_telnets').select_value("2")
      when 'Required'
        @ff.select_list(:name,'mng_auth_telnets').select_value("3")
      else
        # Wrong here.
        self.msg(rule_name,:error,'System Settings','No such \'Secure Telnet over SSL Client Authentication\' value.')
        return
      end # end of case
      
      self.msg(rule_name,:info,'Secure Telnet over SSL Client Authentication',info['Secure Telnet over SSL Client Authentication'])
      
    end  
    
    # "System Enable Logging"
    if info.has_key?('System Enable Logging')
      
      case info['System Enable Logging']
      
      when 'on'
        
        # Set "System Enable Logging"
        @ff.checkbox(:name,'var_logging_enabled').set
        self.msg(rule_name,:info,'System Enable Logging',info['System Enable Logging'])
 
      when 'off'
        
        # Clear "System Enable Logging"
        @ff.checkbox(:name,'var_logging_enabled').clear
        self.msg(rule_name,:info,'System Enable Logging',info['System Enable Logging'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'System Settings','Did NOT find the value in \'System Enable Logging\'.')
        return
        
      end # end of case
      
    end # end of if  
    
    @ff.wait

    # "System Low Capacity Notification Enabled"
    if info.has_key?('System Low Capacity Notification Enabled') and
       info['System Enable Logging'] == "on"
      
      case info['System Low Capacity Notification Enabled']
      
      when 'on'
        
        # Set "System Low Capacity Notification Enabled"
        @ff.checkbox(:name,'var_notify_enabled').set
        self.msg(rule_name,:info,'System Low Capacity Notification Enabled',info['System Low Capacity Notification Enabled'])
        
        # "System Allowed Capacity Before Email Notification"
        if info.has_key?('System Allowed Capacity Before Email Notification')
      
          begin
            @ff.text_field(:name,'var_notify_limit').value=(info['System Allowed Capacity Before Email Notification'])
            self.msg(rule_name,:info,'System Allowed Capacity Before Email Notification',info['System Allowed Capacity Before Email Notification'])
          rescue
            self.msg(rule_name,:info,'System Settings','No such text field : \'System Allowed Capacity Before Email Notification\'')
            return
          end
      
        end 
 
      when 'off'
        
        # Clear "System Low Capacity Notification Enabled"
        @ff.checkbox(:name,'var_notify_enabled').clear
        self.msg(rule_name,:info,'System Low Capacity Notification Enabled',info['System Low Capacity Notification Enabled'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'System Settings','Did NOT find the value in \'System Low Capacity Notification Enabled\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # "System System Log Buffer Size"
    if info.has_key?('System System Log Buffer Size') and
       info['System Enable Logging'] == "on"

      @ff.text_field(:name,'system_buf_size').value=(info['System System Log Buffer Size'])
      self.msg(rule_name,:info,'System System Log Buffer Size',info['System System Log Buffer Size'])
      
    end    
    
    # "System Remote System Notify Level"
    if info.has_key?('System Remote System Notify Level') and
       info['System Enable Logging'] == "on"
      
      case info['System Remote System Notify Level']
      when 'Warning'
        @ff.select_list(:name,'system_notify_level').select("Warning")
      when 'None'
        @ff.select_list(:name,'system_notify_level').select("None")
      when 'Error'
        @ff.select_list(:name,'system_notify_level').select("Error")
      when 'Information'
        @ff.select_list(:name,'system_notify_level').select("Information")        
      else
        # Wrong here.
        self.msg(rule_name,:error,'System Settings','No such \'System Remote System Notify Level\' value.')
        return
      end # end of case
      
      self.msg(rule_name,:info,'System Remote System Notify Level',info['System Remote System Notify Level'])
      
    end 
    # "Remote System Host IP Address"
    #if info.has_hey?('Remote System Host IP Address') 

        if info.has_key?('Remote System Host IP Address') and info['Remote System Host IP Address'].size > 0
                octets=info['Remote System Host IP Address'].split('.')
                @ff.text_field(:name, 'syslog_remote_ip0').value=(octets[0])
                @ff.text_field(:name, 'syslog_remote_ip1').value=(octets[1])
                @ff.text_field(:name, 'syslog_remote_ip2').value=(octets[2])
                @ff.text_field(:name, 'syslog_remote_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'Remote System Host IP Address', info['Remote System Host IP Address'])
         end 
    # "Security Low Capacity Notification Enabled"
    if info.has_key?('Security Low Capacity Notification Enabled')
      
      case info['Security Low Capacity Notification Enabled']
      
      when 'on'
        
        # Set "Security Low Capacity Notification Enabled"
        @ff.checkbox(:name,'fw_notify_enabled').set
        self.msg(rule_name,:info,'Security Low Capacity Notification Enabled',info['Security Low Capacity Notification Enabled'])
        
        # "Security Allowed Capacity Before Email Notification"
        if info.has_key?('Security Allowed Capacity Before Email Notification') and
          @ff.text.include?'Allowed Capacity Before Email Notification'
           
          @ff.text_field(:name,'fw_notify_limit').value=(info['Security Allowed Capacity Before Email Notification'])
          self.msg(rule_name,:info,'Security Allowed Capacity Before Email Notification',info['Security Allowed Capacity Before Email Notification'])
      
        end  
 
      when 'off'
        
        # Clear "Security Low Capacity Notification Enabled"
        @ff.checkbox(:name,'fw_notify_enabled').clear
        self.msg(rule_name,:info,'Security Low Capacity Notification Enabled',info['Security Low Capacity Notification Enabled'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'System Settings','Did NOT find the value in \'Security Low Capacity Notification Enabled\'.')
        return
        
      end # end of case
      
    end # end of if    
    
    # "Security Security Log Buffer Size"
    if info.has_key?('Security Security Log Buffer Size') and
       @ff.text.include?'Security Log Buffer Size'
      
      @ff.text_field(:name,'security_buf_size').value=(info['Security Security Log Buffer Size'])
      self.msg(rule_name,:info,'Security Security Log Buffer Size',info['Security Security Log Buffer Size'])
      
    end    
    
    # "Security Remote Security Notify Level"
    if info.has_key?('Security Remote Security Notify Level') and
       @ff.text.include?'Remote Security Notify Level'
      
      case info['Security Remote Security Notify Level']
      when 'Warning'
        @ff.select_list(:name,'security_notify_level').select("Warning")
      when 'None'
        @ff.select_list(:name,'security_notify_level').select("None")
      when 'Error'
        @ff.select_list(:name,'security_notify_level').select("Error")
      when 'Information'
        @ff.select_list(:name,'security_notify_level').select("Information")        
      else
        # Wrong here.
        self.msg(rule_name,:error,'System Settings','No such \'Security Remote Security Notify Level\' value.')
        return
      end # end of case
      
      self.msg(rule_name,:info,'Security Remote Security Notify Level',info['Security Remote Security Notify Level'])
      
    end   

    # "Remote System Host IP Address"

        if info.has_key?('Remote Security Host IP Address') and info['Remote Security Host IP Address'].size > 0
                octets=info['Remote Security Host IP Address'].split('.')
                @ff.text_field(:name, 'security_remote_ip0').value=(octets[0])
                @ff.text_field(:name, 'security_remote_ip1').value=(octets[1])
                @ff.text_field(:name, 'security_remote_ip2').value=(octets[2])
                @ff.text_field(:name, 'security_remote_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'Remote Security Host IP Address', info['Remote Security Host IP Address'])
         end
    
    # "Outgoing Server"
    if info.has_key?('Outgoing Server') and
       @ff.text.include?'Server'
      
      @ff.text_field(:name,'email_smtp_server').value=(info['Outgoing Server'])
      self.msg(rule_name,:info,'Outgoing Server',info['Outgoing Server'])
      
    end    
    
    # "Outgoing From Email Address"
    if info.has_key?('Outgoing From Email Address') and
       @ff.text.include?'From Email Address'
      
      @ff.text_field(:name,'email_from_address').value=(info['Outgoing From Email Address'])
      self.msg(rule_name,:info,'Outgoing From Email Address',info['Outgoing From Email Address'])
      
    end  
    
    # "Outgoing Port"
    if info.has_key?('Outgoing Port') and
       @ff.text.include?'Port'
      
      @ff.text_field(:name,'email_smtp_port').value=(info['Outgoing Port'])
      self.msg(rule_name,:info,'Outgoing Port',info['Outgoing Port'])
      
    end   
    
    # "Auto WAN Detection Enabled"
    if info.has_key?('Auto WAN Detection Enabled')
      
      case info['Auto WAN Detection Enabled']
      
      when 'on'
        
        # Set "Auto WAN Detection Enabled"
        @ff.checkbox(:name,'auto_wan_detection_enabled').set
        self.msg(rule_name,:info,'Auto WAN Detection Enabled',info['Auto WAN Detection Enabled'])
 
      when 'off'
        
        # Clear "Security Low Capacity Notification Enabled"
        @ff.checkbox(:name,'auto_wan_detection_enabled').clear
        self.msg(rule_name,:info,'Auto WAN Detection Enabled',info['Auto WAN Detection Enabled'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'System Settings','Did NOT find the value in \'Auto WAN Detection Enabled\'.')
        return
        
      end # end of case
      
    end # end of if    

    # "Auto WAN Detection PPP Timeout"
    if info.has_key?('PPP Timeout') and 
       @ff.text.include?'PPP Timeout'
      
      @ff.text_field(:name,'ppp_timeout').value=(info['PPP Timeout'])
      self.msg(rule_name,:info,'Auto WAN Detection PPP Timeout',info['PPP Timeout'])
      
    end  
    
    # "Auto WAN Detection DHCP Timeout"
    if info.has_key?('DHCP Timeout') and
       @ff.text.include?'DHCP Timeout'
          
      @ff.text_field(:name,'dhcp_timeout').value=(info['DHCP Timeout'])
      self.msg(rule_name,:info,'Auto WAN Detection DHCP Timeout',info['DHCP Timeout'])
      
    end    
    
    # "Auto WAN Detection Number of Cycles"
    if info.has_key?('Number of Cycles') and
       @ff.text.include?'Number of Cycles'
      
      @ff.text_field(:name,'number_of_cycles').value=(info['Number of Cycles'])
      self.msg(rule_name,:info,'Auto WAN Detection Number of Cycles',info['Number of Cycles'])
      
    end 
    
    # "Auto Detection Continuous Trying"
    if info.has_key?('Auto Detection Continuous Trying') and
       @ff.text.include?'Auto Detection Continuous Trying'
      
      case info['Auto Detection Continuous Trying']
      
      when 'on'
        
        # Set "Auto Detection Continuous Trying"
        @ff.checkbox(:name,'continuous_trying').set
        self.msg(rule_name,:info,'Auto Detection Continuous Trying',info['Auto Detection Continuous Trying'])
 
      when 'off'
        
        # Clear "Auto Detection Continuous Trying"
        @ff.checkbox(:name,'continuous_trying').clear
        self.msg(rule_name,:info,'Auto Detection Continuous Trying',info['Auto Detection Continuous Trying'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'System Settings','Did NOT find the value in \'Auto Detection Continuous Trying\'.')
        return
        
      end # end of case
      
    end # end of if    
    
    # Apply for the change
    @ff.link(:text,'Apply').click
   
     # Error message?
    if @ff.text.include?'Input Errors'
      # Error here.
      
      # Find the table.
      sTable = false
      @ff.tables.each do |t|
        if ( t.text.include? ':' and 
             ( not t.text.include? 'Input Errors') and
             ( not t.text.include? 'Cancel') and
             t.row_count >= 1 )then
          sTable = t
          break
        end
      end
      
      if sTable == false
        # Wrong here
        self.msg(rule_name,:error,'System Settings','Did NOT find the target table.')
        return
      end
      
      sTable.each do |row|
        
        if row[1] == "" or row[2] == nil
          next
        end
        
        self.msg(rule_name,:error,row[1],row[2])
        
      end
       
      # Click the "cancel"
      @ff.link(:text,'Cancel').click
       
      return
      
    end    
    
    if @ff.text.include?'Apply'
	@ff.link(:text,'Apply').click
    end

    self.msg(rule_name,:info,'System Settings','SUCCEESS')    
    
  end # end of def

  #----------------------------------------------------------------------
  # port_configuration(rule_name, info)
  # Discription: function of "Port Configuration" under "Advance" page.
  #----------------------------------------------------------------------
  def port_configuration(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Port Configuration" page.
    begin
      @ff.link(:text, 'Port Configuration').click
      self.msg(rule_name, :info, 'Port Configuration', 'Reached page \'Port Configuration\'.')
    rescue
      self.msg(rule_name, :error, 'Port Configuration', 'Did not reach \'Port Configuration\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'local_administration','Some key NOT found.')
      return
    end 
    
    # parse the json file.
   
    # Add by Hugo 07/31/2009; missing WAN Port
    # "WAN Port"
    if info.has_key?('WAN Port')
      
      case info['WAN Port']
      
      when 'Auto'
        
        # Set "Auto"
        @ff.select_list(:name,'port_eth1_0').select_value("0")
        self.msg(rule_name,:info,'WAN Port',info['WAN Port'])
 
      when '10 Half Duplex'
        
        # Set "10 Half Duplex"
        @ff.select_list(:name,'port_eth1_0').select_value("1")
        self.msg(rule_name,:info,'WAN Port',info['WAN Port'])
        
      when '10 Full Duplex'
        
        # Set "10 Full Duplex"
        @ff.select_list(:name,'port_eth1_0').select_value("2")
        self.msg(rule_name,:info,'WAN Port',info['WAN Port'])
        
      when '100 Half Duplex'
        
        # Set "100 Half Duplex"
        @ff.select_list(:name,'port_eth1_0').select_value("3")
        self.msg(rule_name,:info,'WAN Port',info['WAN Port'])
               
      when '100 Full Deplex'
        
        # Set "100 Full Duplex"
        @ff.select_list(:name,'port_eth1_0').select_value("4")
        self.msg(rule_name,:info,'WAN Port',info['WAN Port'])
        
      else
    
        # Wrong here
        self.msg(rule_name,:error,'port_configuration','Did NOT find the value in \'WAN Port\'.')
        return
        
      end # end of case
      
    end # end of if  
 

    # "Port1"
    if info.has_key?('Port1')
      
      case info['Port1']
      
      when 'Auto'
        
        # Set "Auto"
        @ff.select_list(:name,'port_eth0_0').select_value("0")
        self.msg(rule_name,:info,'Port1',info['Port1'])
 
      when '10 Half Duplex'
        
        # Set "10 Half Duplex"
        @ff.select_list(:name,'port_eth0_0').select_value("1")
        self.msg(rule_name,:info,'Port1',info['Port1'])
        
      when '10 Full Duplex'
        
        # Set "10 Full Duplex"
        @ff.select_list(:name,'port_eth0_0').select_value("2")
        self.msg(rule_name,:info,'Port1',info['Port1'])
        
      when '100 Half Duplex'
        
        # Set "100 Half Duplex"
        @ff.select_list(:name,'port_eth0_0').select_value("3")
        self.msg(rule_name,:info,'Port1',info['Port1'])
               
      when '100 Full Deplex'
        
        # Set "100 Full Duplex"
        @ff.select_list(:name,'port_eth0_0').select_value("4")
        self.msg(rule_name,:info,'Port1',info['Port1'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'port_configuration','Did NOT find the value in \'Port1\'.')
        return
        
      end # end of case
      
    end # end of if  

    # "Port2"
    if info.has_key?('Port2')
      
      case info['Port2']
      
      when 'Auto'
        
        # Set "Auto"
        @ff.select_list(:name,'port_eth0_1').select_value("0")
        self.msg(rule_name,:info,'Port2',info['Port2'])
 
      when '10 Half Duplex'
        
        # Set "10 Half Duplex"
        @ff.select_list(:name,'port_eth0_1').select_value("1")
        self.msg(rule_name,:info,'Port2',info['Port2'])
        
      when '10 Full Duplex'
        
        # Set "10 Full Duplex"
        @ff.select_list(:name,'port_eth0_1').select_value("2")
        self.msg(rule_name,:info,'Port2',info['Port2'])
        
      when '100 Half Duplex'
        
        # Set "100 Half Duplex"
        @ff.select_list(:name,'port_eth0_1').select_value("3")
        self.msg(rule_name,:info,'Port2',info['Port2'])
               
      when '100 Full Deplex'
        
        # Set "100 Full Duplex"
        @ff.select_list(:name,'port_eth0_1').select_value("4")
        self.msg(rule_name,:info,'Port2',info['Port2'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'port_configuration','Did NOT find the value in \'Port2\'.')
        return
        
      end # end of case
      
    end # end of if    
    
    # "Port3"
    if info.has_key?('Port3')
      
      case info['Port3']
      
      when 'Auto'
        
        # Set "Auto"
        @ff.select_list(:name,'port_eth0_2').select_value("0")
        self.msg(rule_name,:info,'Port3',info['Port3'])
 
      when '10 Half Duplex'
        
        # Set "10 Half Duplex"
        @ff.select_list(:name,'port_eth0_2').select_value("1")
        self.msg(rule_name,:info,'Port3',info['Port3'])
        
      when '10 Full Duplex'
        
        # Set "10 Full Duplex"
        @ff.select_list(:name,'port_eth0_2').select_value("2")
        self.msg(rule_name,:info,'Port3',info['Port3'])
        
      when '100 Half Duplex'
        
        # Set "100 Half Duplex"
        @ff.select_list(:name,'port_eth0_2').select_value("3")
        self.msg(rule_name,:info,'Port3',info['Port3'])
               
      when '100 Full Deplex'
        
        # Set "100 Full Duplex"
        @ff.select_list(:name,'port_eth0_2').select_value("4")
        self.msg(rule_name,:info,'Port3',info['Port3'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'port_configuration','Did NOT find the value in \'Port3\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Port4"
    if info.has_key?('Port4')
      
      case info['Port4']
      
      when 'Auto'
        
        # Set "Auto"
        @ff.select_list(:name,'port_eth0_3').select_value("0")
        self.msg(rule_name,:info,'Port4',info['Port4'])
 
      when '10 Half Duplex'
        
        # Set "10 Half Duplex"
        @ff.select_list(:name,'port_eth0_3').select_value("1")
        self.msg(rule_name,:info,'Port4',info['Port4'])
        
      when '10 Full Duplex'
        
        # Set "10 Full Duplex"
        @ff.select_list(:name,'port_eth0_3').select_value("2")
        self.msg(rule_name,:info,'Port4',info['Port4'])
        
      when '100 Half Duplex'
        
        # Set "100 Half Duplex"
        @ff.select_list(:name,'port_eth0_3').select_value("3")
        self.msg(rule_name,:info,'Port4',info['Port4'])
               
      when '100 Full Deplex'
        
        # Set "100 Full Duplex"
        @ff.select_list(:name,'port_eth0_3').select_value("4")
        self.msg(rule_name,:info,'Port4',info['Port4'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'port_configuration','Did NOT find the value in \'Port4\'.')
        return
        
      end # end of case
      
    end # end of if  
    
    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Making change will cause the "Attention" page.
    if @ff.text.include?'Attention'
      @ff.link(:text,'Apply').click
      
      # Wait for 30 seconds
      sleep 30
    end

    # Output the result
    self.msg(rule_name,:info,'Port Configuration','SUCCESS')
    
  end # end of def
  
  #----------------------------------------------------------------------
  # date_and_time(rule_name, info)
  # Discription: function of "Date and Time" under "Advance" page.
  #----------------------------------------------------------------------
  def date_and_time(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Date and Time" page.
    begin
      @ff.link(:text, 'Date and Time').click
      self.msg(rule_name, :info, 'Date and Time', 'Reached page \'Date and Time\'.')
    rescue
      self.msg(rule_name, :error, 'Date and Time', 'Did not reach \'Date and Time\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'date_and_time','Some key NOT found.')
      return
    end
    
    # Clock Set Add by Robin 2009.4.17
    if info.has_key?('action')      
      case info['action']
      when 'Clock SET'
        @ff.link(:text, 'Clock Set').click
        # hour
        if info.key?('hour')  
          @ff.text_field(:name, 'hour').value=(info['hour'])
          self.msg(rule_name, :info, 'date_and_time()->hour', 'hour= '+info['hour'])
        else
          self.msg(rule_name, :info, 'date_and_time()->hour', 'No hour key found')
        end
        # minute
        if info.key?('minute')  
          @ff.text_field(:name, 'min').value=(info['minute'])
          self.msg(rule_name, :info, 'date_and_time()->minute', 'minute= '+info['minute'])
        else
          self.msg(rule_name, :info, 'date_and_time()->minute', 'No minute key found')
        end
        # sec
        if info.key?('sec')  
          @ff.text_field(:name, 'sec').value=(info['sec'])
          self.msg(rule_name, :info, 'date_and_time()->sec', 'sec= '+info['sec'])
        else
          self.msg(rule_name, :info, 'date_and_time()->sec', 'No sec key found')
        end
        # year
        if info.key?('year')
          @ff.select_list(:id, 'year').select_value(info['year']) 
          self.msg(rule_name, :info, 'date_and_time()->year', "year = "+info['year'])
        else
          self.msg(rule_name, :info, 'date_and_time()->year', 'year undefined')
        end
        # month
        if info.key?('month')
          case info['month']
          when 'Jan'
            @ff.select_list(:id, 'month').select_value('0') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Feb'
            @ff.select_list(:id, 'month').select_value('1') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Mar'
            @ff.select_list(:id, 'month').select_value('2') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Apr'
            @ff.select_list(:id, 'month').select_value('3') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'May'
            @ff.select_list(:id, 'month').select_value('4') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Jun'
            @ff.select_list(:id, 'month').select_value('5') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Jul'
            @ff.select_list(:id, 'month').select_value('6') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Aug'
            @ff.select_list(:id, 'month').select_value('7') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Sep'
            @ff.select_list(:id, 'month').select_value('8') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Oct'
            @ff.select_list(:id, 'month').select_value('9') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Nov'
            @ff.select_list(:id, 'month').select_value('10') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          when 'Dec'
            @ff.select_list(:id, 'month').select_value('11') 
            self.msg(rule_name, :info, 'date_and_time()->month', "month = "+info['month'])
          else
            self.msg(rule_name, :info, 'date_and_time()->month', 'month undefined')
          end
        end
        # day
        if info.key?('day')
          @ff.select_list(:id, 'day').select_value(info['day']) 
          self.msg(rule_name, :info, 'date_and_time()->day', "day = "+info['day'])
        else
          self.msg(rule_name, :info, 'date_and_time()->day', 'day undefined')
        end
        # click 'Apply' button to complete setup
        @ff.link(:text, 'Apply').click
	if not @ff.text.include?('Input Errors') then
	    self.msg(rule_name,:info,'Set Time','SUCCESS')
        else
	   @ff.tables.each do |t|
		if ( (t.text.include? 'value') and (not t.text.include? 'Input Errors')) then
		    t.each do |row|
			if row.text.include? 'value' then
			    self.msg(rule_name,:error,row[1].to_s.gsub(':',''),row[2]);
			end
		    end
		end
	   end
        end
	return
      else
        self.msg(rule_name,:error,'Date and Time','Did NOT find the value in \'action\'.')
        return    
      end # end of case   
    end # end of if 
    
    # "Time Zone"
    if info.has_key?('Time Zone')
      
      case info['Time Zone']
      
      when 'Other'
        
        # Set "Other"
        @ff.select_list(:name,'time_zone').select_value("")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])
 
      when 'Alaska_Time'
        
        # Set "Alaska_Time"
        @ff.select_list(:name,'time_zone').select_value("Alaska_Time")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])
        
      when 'Central_Time'
        
        # Set "Central_Time"
        @ff.select_list(:name,'time_zone').select_value("Central_Time")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])   
        
      when 'Eastern_Time'
        
        # Set "Eastern_Time"
        @ff.select_list(:name,'time_zone').select_value("Eastern_Time")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])         
 
      when 'Greenwich_Mean_Time'
        
        # Set "Greenwich_Mean_Time"
        @ff.select_list(:name,'time_zone').select_value("Greenwich_Mean_Time")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])  
        
      when 'Hawaii_Time'
        
        # Set "Hawaii_Time"
        @ff.select_list(:name,'time_zone').select_value("Hawaii_Time")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])         
 
      when 'Mountain_Time'
        
        # Set "Mountain_Time"
        @ff.select_list(:name,'time_zone').select_value("Mountain_Time")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])  
 
      when 'Pacific_Time'
        
        # Set "Pacific_Time"
        @ff.select_list(:name,'time_zone').select_value("Pacific_Time")
        self.msg(rule_name,:info,'Time Zone',info['Time Zone'])  
 
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Date and Time','Did NOT find the value in \'Time Zone\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "GMT Offset"
    if info.has_key?('GMT Offset')
      
      # Is there?
      if not @ff.text.include?'GMT Offset'
        # Error here.
        self.msg(rule_name,:error,'Date and Time','No option \'GMT Offset\'.')
        return
      end
      
      # Set "GMT Offset"
      @ff.text_field(:name,'gmt_offset').set(info['GMT Offset'])
      self.msg(rule_name,:info,'GMT Offset',info['GMT Offset'])
      
    end
    
    # "Daylight Enable"
    if info.has_key?('Daylight Enable')
      
      case info['Daylight Enable']
      
      when 'on'
        
        # Set "Daylight Enable"
        @ff.checkbox(:name,'is_dl_sav').set
        self.msg(rule_name,:info,'Daylight Enable',info['Daylight Enable'])
 
      when 'off'
        
        # Clear "Daylight Enable"
        @ff.checkbox(:name,'is_dl_sav').clear
        self.msg(rule_name,:info,'Daylight Enable',info['Daylight Enable'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'date_and_time','Did NOT find the value in \'Daylight Enable\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Start Month"
    if info.has_key?('Start Month')
      
      case info['Start Month']
      
      when 'Jan'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("0")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
 
      when 'Feb'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("1")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
 
      when 'Mar'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("2")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
 
      when 'Apr'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("3")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
   
      when 'May'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("4")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
         
      when 'Jun'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("5")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
       
      when 'Jul'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("6")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
        
      when 'Aug'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("7")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
         
      when 'Sep'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("8")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
        
      when 'Oct'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("9")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
          
      when 'Nov'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("10")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])
    
      when 'Dec'
        
        # Set "Start Month"
        @ff.select_list(:name,'dst_mon_start').select_value("11")
        self.msg(rule_name,:info,'Start Month',info['Start Month'])         
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Start Month\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Start Date"
    if info.has_key?('Start Date')
      
      case info['Start Date']
      
      when '1'
        @ff.select_list(:name,'dst_day_start').select_value("1")
      when '2'
        @ff.select_list(:name,'dst_day_start').select_value("2")
      when '3'
        @ff.select_list(:name,'dst_day_start').select_value("3")
      when '4'
        @ff.select_list(:name,'dst_day_start').select_value("4")
      when '5'
        @ff.select_list(:name,'dst_day_start').select_value("5")
      when '6'
        @ff.select_list(:name,'dst_day_start').select_value("6")
      when '7'
        @ff.select_list(:name,'dst_day_start').select_value("7")
      when '8'
        @ff.select_list(:name,'dst_day_start').select_value("8")
      when '9'
        @ff.select_list(:name,'dst_day_start').select_value("9")
      when '10'
        @ff.select_list(:name,'dst_day_start').select_value("10")
      when '11'
        @ff.select_list(:name,'dst_day_start').select_value("11")
      when '12'
        @ff.select_list(:name,'dst_day_start').select_value("12")
      when '13'
        @ff.select_list(:name,'dst_day_start').select_value("13")
      when '14'
        @ff.select_list(:name,'dst_day_start').select_value("14")
      when '15'
        @ff.select_list(:name,'dst_day_start').select_value("15")
      when '16'
        @ff.select_list(:name,'dst_day_start').select_value("16")
      when '17'
        @ff.select_list(:name,'dst_day_start').select_value("17")
      when '18'
        @ff.select_list(:name,'dst_day_start').select_value("18")
      when '19'
        @ff.select_list(:name,'dst_day_start').select_value("19")
      when '20'
        @ff.select_list(:name,'dst_day_start').select_value("20")
      when '21'
        @ff.select_list(:name,'dst_day_start').select_value("21")
      when '22'
        @ff.select_list(:name,'dst_day_start').select_value("22")
      when '23'
        @ff.select_list(:name,'dst_day_start').select_value("23")
      when '24'
        @ff.select_list(:name,'dst_day_start').select_value("24")
      when '25'
        @ff.select_list(:name,'dst_day_start').select_value("25")
      when '26'
        @ff.select_list(:name,'dst_day_start').select_value("26")
      when '27'
        @ff.select_list(:name,'dst_day_start').select_value("27")  
      when '28'
        @ff.select_list(:name,'dst_day_start').select_value("28")
      when '29'
        @ff.select_list(:name,'dst_day_start').select_value("29")
      when '30'
        @ff.select_list(:name,'dst_day_start').select_value("30")
      when '31'
        @ff.select_list(:name,'dst_day_start').select_value("31")        
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'Start Date\'.')
        return
        
      end # end of case
      
      self.msg(rule_name,:info,'Start Date',info['Start Date'])
      
    end # end of if  

    # "Start Hour"
    if info.has_key?('Start Hour')
      
      # Set
      @ff.text_field(:name,'dst_hour_start').set(info['Start Hour'])
      self.msg(rule_name,:info,'Start Hour',info['Start Hour'])
      
    end 
    
    # "Start Minute"
    if info.has_key?('Start Minute')
      
      # Set
      @ff.text_field(:name,'dst_min_start').set(info['Start Minute'])
      self.msg(rule_name,:info,'Start Minute',info['Start Minute'])
      
    end    
    
    # "End Month"
    if info.has_key?('End Month')
      
      case info['End Month']
      
      when 'Jan'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("0")
        self.msg(rule_name,:info,'End Month',info['End Month'])
 
      when 'Feb'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("1")
        self.msg(rule_name,:info,'End Month',info['End Month'])
 
      when 'Mar'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("2")
        self.msg(rule_name,:info,'End Month',info['End Month'])
 
      when 'Apr'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("3")
        self.msg(rule_name,:info,'End Month',info['End Month'])
   
      when 'May'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("4")
        self.msg(rule_name,:info,'End Month',info['End Month'])
         
      when 'Jun'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("5")
        self.msg(rule_name,:info,'End Month',info['End Month'])
       
      when 'Jul'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("6")
        self.msg(rule_name,:info,'End Month',info['End Month'])
        
      when 'Aug'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("7")
        self.msg(rule_name,:info,'End Month',info['End Month'])
         
      when 'Sep'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("8")
        self.msg(rule_name,:info,'End Month',info['End Month'])
        
      when 'Oct'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("9")
        self.msg(rule_name,:info,'End Month',info['End Month'])
          
      when 'Nov'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("10")
        self.msg(rule_name,:info,'End Month',info['End Month'])
    
      when 'Dec'
        
        # Set "End Month"
        @ff.select_list(:name,'dst_mon_end').select_value("11")
        self.msg(rule_name,:info,'End Month',info['End Month'])         
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'End Month\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "End Date"
    if info.has_key?('End Date')
      
      case info['End Date']
      
      when '1'
        @ff.select_list(:name,'dst_day_end').select_value("1")
      when '2'
        @ff.select_list(:name,'dst_day_end').select_value("2")
      when '3'
        @ff.select_list(:name,'dst_day_end').select_value("3")
      when '4'
        @ff.select_list(:name,'dst_day_end').select_value("4")
      when '5'
        @ff.select_list(:name,'dst_day_end').select_value("5")
      when '6'
        @ff.select_list(:name,'dst_day_end').select_value("6")
      when '7'
        @ff.select_list(:name,'dst_day_end').select_value("7")
      when '8'
        @ff.select_list(:name,'dst_day_end').select_value("8")
      when '9'
        @ff.select_list(:name,'dst_day_end').select_value("9")
      when '10'
        @ff.select_list(:name,'dst_day_end').select_value("10")
      when '11'
        @ff.select_list(:name,'dst_day_end').select_value("11")
      when '12'
        @ff.select_list(:name,'dst_day_end').select_value("12")
      when '13'
        @ff.select_list(:name,'dst_day_end').select_value("13")
      when '14'
        @ff.select_list(:name,'dst_day_end').select_value("14")
      when '15'
        @ff.select_list(:name,'dst_day_end').select_value("15")
      when '16'
        @ff.select_list(:name,'dst_day_end').select_value("16")
      when '17'
        @ff.select_list(:name,'dst_day_end').select_value("17")
      when '18'
        @ff.select_list(:name,'dst_day_end').select_value("18")
      when '19'
        @ff.select_list(:name,'dst_day_end').select_value("19")
      when '20'
        @ff.select_list(:name,'dst_day_end').select_value("20")
      when '21'
        @ff.select_list(:name,'dst_day_end').select_value("21")
      when '22'
        @ff.select_list(:name,'dst_day_end').select_value("22")
      when '23'
        @ff.select_list(:name,'dst_day_end').select_value("23")
      when '24'
        @ff.select_list(:name,'dst_day_end').select_value("24")
      when '25'
        @ff.select_list(:name,'dst_day_end').select_value("25")
      when '26'
        @ff.select_list(:name,'dst_day_end').select_value("26")
      when '27'
        @ff.select_list(:name,'dst_day_end').select_value("27")  
      when '28'
        @ff.select_list(:name,'dst_day_end').select_value("28")
      when '29'
        @ff.select_list(:name,'dst_day_end').select_value("29")
      when '30'
        @ff.select_list(:name,'dst_day_end').select_value("30")
      when '31'
        @ff.select_list(:name,'dst_day_end').select_value("31")        
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'','Did NOT find the value in \'End Date\'.')
        return
        
      end # end of case
      
      self.msg(rule_name,:info,'End Date',info['End Date'])
      
    end # end of if  

    # "End Hour"
    if info.has_key?('End Hour')
      
      # Set
      @ff.text_field(:name,'dst_hour_end').set(info['End Hour'])
      self.msg(rule_name,:info,'End Hour',info['End Hour'])
      
    end 
    
    # "End Minute"
    if info.has_key?('End Minute')
      
      # Set
      @ff.text_field(:name,'dst_min_end').set(info['End Minute'])
      self.msg(rule_name,:info,'End Minute',info['End Minute'])
      
    end 
    
    # "Offset"
    if info.has_key?('Offset')
      
      # Set
      @ff.text_field(:name,'dst_offset').set(info['Offset'])
      self.msg(rule_name,:info,'Offset',info['Offset'])
      
    end 
    
    # "Automatic Enabled"
    if info.has_key?('Automatic Enabled')
      
      case info['Automatic Enabled']
      
      when 'on'
        
        # Set "Automatic Enabled"
        @ff.checkbox(:name,'is_tod_enabled').set
        self.msg(rule_name,:info,'Automatic Enabled',info['Automatic Enabled'])
 
      when 'off'
        
        # Clear "Automatic Enabled"
        @ff.checkbox(:name,'is_tod_enabled').clear
        self.msg(rule_name,:info,'Automatic Enabled',info['Automatic Enabled'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Date and Time','Did NOT find the value in \'Automatic Enabled\'.')
        return
        
      end # end of case
      
    end # end of if  

    # "Time Of Day"
    if info.has_key?('Time Of Day')
      
      case info['Time Of Day']
      
      when 'on'
        
        # Set "Time Of Day"
        @ff.radio(:id,'tod_prot_type_1').set
        self.msg(rule_name,:info,'Time Of Day',info['Time Of Day'])
 
      when 'off'
        
        # Clear "Time Of Day"
        @ff.radio(:id,'tod_prot_type_1').clear
        self.msg(rule_name,:info,'Time Of Day',info['Time Of Day'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Date and Time','Did NOT find the value in \'Time Of Day\'.')
        return
        
      end # end of case
      
    end # end of if    
    
    # "Network Time Protocol"
    if info.has_key?('Network Time Protocol')
      
      case info['Network Time Protocol']
      
      when 'on'
        
        # Set "Network Time Protocol"
        @ff.radio(:id,'tod_prot_type_2').set
        self.msg(rule_name,:info,'Network Time Protocol',info['Network Time Protocol'])
 
      when 'off'
        
        # Clear "Network Time Protocol"
        @ff.radio(:id,'tod_prot_type_2').clear
        self.msg(rule_name,:info,'Network Time Protocol',info['Network Time Protocol'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Date and Time','Did NOT find the value in \'Network Time Protocol\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Update Every"
    if info.has_key?('Update Every')
      
      #
      @ff.text_field(:name,'tod_update_period').set(info['Update Every'])
      self.msg(rule_name,:info,'Update Every',info['Update Every'])
      
    end  
    
    # "Sync Now"
    if info.has_key?('Sync Now')
      
      case info['Sync Now']
      
      when 'on'
        
        # Set "Sync Now"
        @ff.link(:text,'Sync Now').click
        @ff.wait
        self.msg(rule_name,:info,'Sync Now',info['Sync Now'])
 
      when 'off'
        
        # Clear "Sync Now"
        # Do nothing here.
        self.msg(rule_name,:info,'Sync Now',info['Sync Now'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Date and Time','Did NOT find the value in \'Sync Now\'.')
        return
        
      end # end of case
      
    end # end of if        
    
    if info.has_key?('Remove Time Server')
	@ff.links.each do |l|
	    if ( l.href.to_s.include? 'remove_time_server') then
		@ff.link(:href,l.href.to_s).click
	    end
	end
    end
    if info.has_key?('Add Time Server')
	@ff.link(:href,'javascript:mimic_button(\'add_time_server: ...\', 1)').click
	@ff.text_field(:name,'tod_server').value = info['Add Time Server']
	@ff.link(:text,'Apply').click
    end
    
    if info.has_key?('Add Multi Time Servers')
    	for i in 0...info['Add Multi Time Servers'].to_i
	    @ff.link(:href,'javascript:mimic_button(\'add_time_server: ...\', 1)').click
	    @ff.text_field(:name,'tod_server').value = "ntp.testurl" + i.to_s + ".com"
	    @ff.link(:text,'Apply').click
	end
    end

    
    if info.has_key?('Read Sync Status')
	@ff.tables.each do |t|
	    if ( (t.text.include? 'Status') and (t.text.include? 'Time Server') and (t.row_count > 5)) then
		t.each do |row|
		    if row.text.include? 'Status' then
			self.msg(rule_name,:info,row[1].to_s.gsub(':',''),row[2])	
		    end
		end
	    end
	end
    end

    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Output the result
    if not @ff.text.include?('Input Errors') then
	self.msg(rule_name,:info,'Date and Time','SUCCESS')
    else
	@ff.tables.each do |t|
	    if ( (t.text.include? 'value') and (not t.text.include? 'Input Errors')) then
		t.each do |row|
		    if row.text.include? 'value' then
			self.msg(rule_name,:error,row[1].to_s.gsub(':',''),row[2])
		    end
		end
	    end
	end
    end
 
  end # end of def
  
  #----------------------------------------------------------------------
  # scheduler_rules(rule_name, info)
  # Discription: function of "Scheduler Rules" under "Advance" page.
  #----------------------------------------------------------------------
  def scheduler_rules(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Scheduler Rules" page.
    begin
      @ff.link(:text, 'Scheduler Rules').click
      self.msg(rule_name, :info, 'Scheduler Rules', 'Reached page \'Scheduler Rules\'.')
    rescue
      self.msg(rule_name, :error, 'Scheduler Rules', 'Did not reach \'Scheduler Rules\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'scheduler_rules','Some key NOT found.')
      return
    end  
    
    # Parse the json file
      
    # Add a scheduler rule here.
    
    # Click the "Add" button under scheduler rule main page.
    @ff.link(:text,'Add').click
    self.msg(rule_name,:info,'Add a scheduler rule','Begin')
    
    # Confirm it
    if not @ff.text.include? 'Set Rule Schedule'
      self.msg(rule_name,:error,'scheduler_rules','Did not reach the \'Set Rule Schedule\' page')
      return
    end
    
    # Set the rule name
    @ff.text_field(:name,'schdlr_rule_name').set(info['Rule Name'])
    self.msg(rule_name,:info,'Rule Name',info['Rule Name'])
    
    # Active?
    case info['Rule will be Active at the Scheduled Time']
      
    when "on"
      # Active
      @ff.radio(:id,'is_enabling_0').set
    when "off"
      # Inactive
      @ff.radio(:id,'is_enabling_0').clear
    else
      # Wong here
      self.msg(rule_name,:error,'scheduler_rules','Ambigurous on active or inactive.')
      return
    end # end of case
    self.msg(rule_name,:info,'Rule will be Active at the Scheduled Time',info['Rule will be Active at the Scheduled Time'])
    
    # Active?
    case info['Rule will be inactive at the Scheduled Time']
      
    when "on"
      # Active
      @ff.radio(:id,'is_enabling_1').set
    when "off"
      # Inactive
      @ff.radio(:id,'is_enabling_1').clear
    else
      # Wong here
      self.msg(rule_name,:error,'scheduler_rules','Ambigurous on active or inactive.')
      return
    end # end of case
    self.msg(rule_name,:info,'Rule will be inactive at the Scheduled Time',info['Rule will be inactive at the Scheduled Time'])
        
    # Click the "Add Rule Schedule" button.
    @ff.link(:text,'Add Rule Schedule').click
    
    # Setup the days.
      
    self.msg(rule_name, :debug, 'scheduler_rules', 'doing rule days begin')
      
    if info.has_key?('Monday')
      if info['Monday'] == 'on'
        @ff.label(:for,'day_mon_').click
      end
    end
    
    if info.has_key?('Tuesday')
      if info['Tuesday'] == 'on'
        @ff.label(:for,'day_tue_').click
      end
    end    
    
    if info.has_key?('Wednesday')
      if info['Wednesday'] == 'on'
        @ff.label(:for,'day_wed_').click
      end
    end      

    if info.has_key?('Thursday')
      if info['Thursday'] == 'on'
        @ff.label(:for,'day_thu_').click
      end
    end     
    
    if info.has_key?('Friday')
      if info['Friday'] == 'on'
        @ff.label(:for,'day_fri_').click
      end
    end   
    
    if info.has_key?('Saturday')
      if info['Saturday'] == 'on'
        @ff.label(:for,'day_sat_').click
      end
    end    
    
    if info.has_key?('Sunday')
      if info['Sunday'] == 'on'
        @ff.label(:for,'day_sun_').click
      end
    end    
           
    self.msg(rule_name, :debug, 'scheduler_rules', 'doing rule days end')
    self.msg(rule_name,:info,'Add days','OK')
    
    # Setup the hours
    if info.has_key?('Start Time') and info.has_key?('End Time')
      
       self.msg(rule_name, :debug, 'scheduler_rules', 'doing rule hours: begin' )     
         
       # Click "New Hours Range Entry".
       @ff.link(:text, 'New Hours Range Entry').click
  
       start_time = info['Start Time'].split(':')
       end_time = info['End Time'].split(':')
       
       @ff.text_field(:name, 'start_hour').set(start_time[0].strip)
       @ff.text_field(:name, 'start_min').set(start_time[1].strip)
       @ff.text_field(:name, 'end_hour').set(end_time[0].strip)
       @ff.text_field(:name, 'end_min').set(end_time[1].strip)
       
       # Apply for the "hours"
       @ff.link(:text, 'Apply').click
         
       
       self.msg(rule_name, :debug, 'scheduler_rules', 'doing rule hours: end' )
       self.msg(rule_name,:info,'Add hours','OK')
                
    end  #end if hours
     
    # Apply for the days and hours
    @ff.link(:text, 'Apply').click
    
    # Apply for the rules
    @ff.link(:text,'Apply').click
    
    # Close the "Scheduler Rules" page
    @ff.link(:text,'Close').click
    
    self.msg(rule_name,:info,'Add a scheduler rule','End')
    self.msg(rule_name,:info,'Scheduler Rules','SUCCESS')
    
  end # end of def

  #----------------------------------------------------------------------
  # firmware_upgrade(rule_name, info)
  # Discription: function of "Firmware Upgrade" under "Advance" page.
  #----------------------------------------------------------------------
  def firmware_upgrade(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Firmware Upgrade" page.
    begin
      @ff.link(:text, 'Firmware Upgrade').click
      self.msg(rule_name, :info, 'Firmware Upgrade', 'Reached page \'Firmware Upgrade\'.')
    rescue
      self.msg(rule_name, :error, 'Firmware Upgrade', 'Did not reach \'Firmware Upgrade\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') )then
      # Right,go on.
    else
      self.msg(rule_name,:error,'users','Some key NOT found.')
      return
    end
    
    # Begin parsing the json file.
    
    # "Automatic check"
    if info.has_key?('Automatic check') then
      
      case info['Automatic check']
        
      when 'Automatically Check for New Versions and Upgrade Wireless Broadband Router'
        
        @ff.select_list(:name,'wan_upgrade_type').select_value("1")
        self.msg(rule_name,:info,'Automatic check',info['Automatic check'])
        
        # Fill in the check hours
        if info.has_key?('check hours') then
          @ff.text_field(:name,'check_interval').set(info['check hours'])
          self.msg(rule_name,:info,'check hours',info['check hours'])
        end
        
        # Fill in the URL
        if info.has_key?('URL') then
          @ff.text_field(:name,'check_url').set(info['URL'])
          self.msg(rule_name,:info,'URL',info['URL'])
        end        
        
      when 'Automatically Check for New Versions and Notify via Email'
        
        @ff.select_list(:name,'wan_upgrade_type').select_value("2")
        self.msg(rule_name,:info,'Automatic check',info['Automatic check'])
        
        # Fill in the check hours
        if info.has_key?('check hours') then
          @ff.text_field(:name,'check_interval').set(info['check hours'])
          self.msg(rule_name,:info,'check hours',info['check hours'])
        end
        
        # Fill in the URL
        if info.has_key?('URL') then
          @ff.text_field(:name,'check_url').set(info['URL'])
          self.msg(rule_name,:info,'URL',info['URL'])
        end         
        
      when 'Automatic Check Disabled'
        
        @ff.select_list(:name,'wan_upgrade_type').select_value("3")
        self.msg(rule_name,:info,'Automatic check',info['Automatic check'])
        
        # Fill in the check hours
        if info.has_key?('check hours') then
          @ff.text_field(:name,'check_interval').set(info['check hours'])
          self.msg(rule_name,:info,'check hours',info['check hours'])
        end
        
        # Fill in the URL
        if info.has_key?('URL') then
          @ff.text_field(:name,'check_url').set(info['URL'])
          self.msg(rule_name,:info,'URL',info['URL'])
        end         
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'firmware_upgrade','Did not have the \'Automatic check\' option ')
        return
        
      end # end of case
      
    end # end of if
    
    # Apply for this change, then go to "Check Now"
    @ff.link(:text,'Apply').click
#Tom add 2009.5.20 for output the upgrade from the internet 
#information    
    if @ff.text.include? 'Attention' then
	@ff.link(:text,'Apply').click
    end
    sleep 5

    # Get to the "Firmware Upgrade" page.
    begin
      @ff.link(:text, 'Firmware Upgrade').click
      self.msg(rule_name, :info, 'Firmware Upgrade', 'Reached page \'Firmware Upgrade\'.')
    rescue
      self.msg(rule_name, :error, 'Firmware Upgrade', 'Did not reach \'Firmware Upgrade\' page')
      return
    end    
    
    # "Check Now"
    if info.has_key?('Check Now') then
      
      case info['Check Now']
      
      when 'on'
      
        # Check now
        @ff.link(:text,'Check Now').click 
        self.msg(rule_name,:info,'Check Now','Done!')
	sleep 10
	@ff.refresh
#Tom add 2009.5.20 for output the upgrade from the internet 
#information      
	sTable = false
	@ff.tables.each do |t|
	    if ( t.text.include? 'Status' and 
		( not t.text.include? 'Upgrade From the Internet') and
		#( not t.text.include? 'Check Now') and
		t.row_count >= 1 ) then
		    sTable = t
		    break
	    end
	end
	if sTable == false then
      # Wrong here
	    self.msg(rule_name,:error,'Upgrade Chenck Now','Did NOT find the target table.')
	else
	    sTable.each do |row|
		if row.text.include? 'Status' then
		    self.msg(rule_name,:info,'Status',row[1]);
		end
	    end
	end

	sTable = false
	@ff.tables.each do |t|
	    if ( t.text.include? 'Internet Version' and 
		( not t.text.include? 'Upgrade From the Internet') and
		#( not t.text.include? 'Check Now') and
		t.row_count >= 1 ) then
		    sTable = t
		    break
	    end
	end
	if sTable == false then
      # Wrong here
	    self.msg(rule_name,:error,'Upgrade Chenck Now','Did NOT find the target table.')
	else
	    sTable.each do |row|
		if row.text.include? 'Internet Version' then
		    self.msg(rule_name,:info,'Internet Version',row[1]);
		end
	    end
	end

      when 'off'
        
        # Don't check now
        # Do nothing.
        self.msg(rule_name,:info,'Check Now','NOT Done!')
        
      else
        
        # Wrong here.
        self.msg(rule_name,:error,'firmware_upgrade','No such \'Check Now\' option.')
        return
        
      end # end of case 
      
    end # end of if
    
    # "Force Upgrade"
    if info.has_key?('Force Upgrade') then
      
      case info['Force Upgrade']
      
      when 'on'
      
#Tom add 2009.5.20 for output the upgrade from the internet 
#information      
	sTable = false
	@ff.tables.each do |t|
	    if ( t.text.include? 'Status' and 
		( not t.text.include? 'Upgrade From the Internet') and
		#( not t.text.include? 'Check Now') and
		t.row_count >= 1 ) then
		    sTable = t
		    break
	    end
	end
	if sTable == false then
      # Wrong here
	    self.msg(rule_name,:error,'Upgrade Chenck Now','Did NOT find the target table.')
	else
	    sTable.each do |row|
		if row.text.include? 'Status' then
		    self.msg(rule_name,:info,'Status',row[1]);
		end
	    end
	end

	sTable = false
	@ff.tables.each do |t|
	    if ( t.text.include? 'Internet Version' and 
		( not t.text.include? 'Upgrade From the Internet') and
		#( not t.text.include? 'Check Now') and
		t.row_count >= 1 ) then
		    sTable = t
		    break
	    end
	end
	if sTable == false then
      # Wrong here
	    self.msg(rule_name,:error,'Upgrade Chenck Now','Did NOT find the target table.')
	else
	    sTable.each do |row|
		if row.text.include? 'Internet Version' then
		    self.msg(rule_name,:info,'Internet Version',row[1]);
		end
	    end
	end
	@ff.link(:text,'Force Upgrade').click 
        self.msg(rule_name,:info,'Force Upgrade','Done!')
	sleep 10

        
      when 'off'
        
        # Don't check now
        # Do nothing.
        self.msg(rule_name,:info,'Force Upgrade','NOT Done!')
        
      else
        
        # Wrong here.
        self.msg(rule_name,:error,'firmware_upgrade','No such \'Force Upgrade\' option.')
        return
        
      end # end of case 
      
    end # end of if    
    
    # Read firmware location
    if info.has_key?('Firmware Location') then
      strLot = info['Firmware Location']
      self.msg(rule_name,:info,'Firmware Location',info['Firmware Location'])
    else
      self.msg(rule_name,:info,'Firmware Location','NOT Done')
    end
    
    # "Upgrade Now"
    if info.has_key?('Upgrade Now') then
      
      case info['Upgrade Now']
      
      when 'on'
      
        # Check now
        firmware_upgrade_manual(rule_name,info,strLot)
        self.msg(rule_name,:info,'Check now by manual','Done')
        
      when 'off'
        
        # Don't check now
        # Do nothing.
        self.msg(rule_name,:info,'Check now by manual','NOT Done')
        
      else
        
        # Wrong here.
        self.msg(rule_name,:error,'firmware_upgrade','No such \'Upgrade Now\' option.')
        return
        
      end # end of case 
      
    end # end of if     
    
  end # end of def
  
  #----------------------------------------------------------------------
  # firmware_upgrade_manual(rule_name, info)
  # Discription: function of "Firmware Upgrade" under "Advance" page.
  #----------------------------------------------------------------------
  def firmware_upgrade_manual(rule_name,info,strLot)
    
    # Under the page "Firmware Upgrade"?
    if not @ff.text.include? 'Firmware Upgrade'
      
      # Go to "Firmware Upgrade" page.

      # Get to the advanced page.
      self.goto_advanced(rule_name, info)
      
      # Get to the "Firmware Upgrade" page.
      begin
        @ff.link(:text, 'Firmware Upgrade').click
        self.msg(rule_name, :info, 'firmware_upgrade_manual', 'Reached page \'Firmware Upgrade\'.')
      rescue
        self.msg(rule_name, :error, 'firmware_upgrade_manual', 'Did not reach \'Firmware Upgrade\' page')
        return
      end
    
    end
    
    # Click the "upgrade now" link
    begin
        @ff.link(:text, 'Upgrade Now').click
    rescue
      self.msg(rule_name, :error, 'firmware_upgrade_manual', 'Did not reach upgrade now page')
      return
    end
    self.msg(rule_name,:info,'Click Upgrade Now','Done')
    
    # set the firmware filename
    begin
      @ff.file_field(:name, "image").set(strLot)
    rescue
      self.msg(rule_name, :error, 'firmware_upgrade_manual', 'Did not set firmware file name')
      return
    end
    
    # Click ok
    begin
      @ff.link(:text, 'OK').click
    rescue
      self.msg(rule_name, :error, 'firmware_upgrade_manual', 'Did not click firmware OK')
      return
    end
    
    # look for the successful upload text
    if not @ff.text.include? 'Do you want to reboot?'
      #Tom add 2009.5.21 to show the output error
      if @ff.text.include? 'Input Errors' then
	sTable = false
	@ff.tables.each do |t|
	    if ( t.text.include? 'Upgrade File' and 
		( not t.text.include? 'Input Errors') and
		#( not t.text.include? 'Check Now') and
		t.row_count >= 1 ) then
		    sTable = t
		    break
	    end
	end
	if sTable == false then
	# Wrong here
	    self.msg(rule_name,:error,'Upgrade Chenck Now','Did NOT find the target table.')
	else
	    sTable.each do |row|
		if row.text.include? 'Upgrade File' then
		    error_type = row[1].to_s().delete(":");
		    error_info = row[2].to_s().delete(".");
		    self.msg(rule_name,:error,error_type,error_info);
		end
	    end
	end
      else
	self.msg(rule_name, :error, 'firmware_upgrade_manual', 'Did not reach the reboot page')
      end
      return
      
    end

    # Click "Apply"
    begin
      @ff.link(:text, 'Apply').click
    rescue
      self.msg(rule_name, :error, 'firmware_upgrade_manual', 'Did not click firmware Apply')
      return
    end
    
    # Check for the wait message
    if not @ff.text.include? 'system is now being upgraded'
      self.msg(rule_name, :error, 'firmware_upgrade_manual', 'Did not see upgrading marker text')
      return
    end

    # give it some time to upgrade
    sleep 60
    @ff.refresh
    @ff.wait

    while not (@ff.text.include? 'is up again' or @ff.text.include? 'Login Setup' or @ff.text.include? 'User Name:')
	sleep 5
	@ff.refresh
	@ff.wait
    end
    self.msg(rule_name, :info, 'firmware_upgrade_manual', 'Firmware upgrade success') 
    
  end
  
  #----------------------------------------------------------------------
  # routing(rule_name, info)
  # Discription: function of "Routing" under "Advance" page.
  #----------------------------------------------------------------------
   def routing(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "Routing" page.
    begin
        @ff.link(:text, 'Routing').click
        self.msg(rule_name, :info, 'routing', 'Reached page \'Routing\'.')
    rescue
        self.msg(rule_name, :error, 'routing', 'Did not reach \'Routing\' page')
        return
    end
      
    # Check the key.
    if ( info.has_key?('section') and info.has_key?('subsection') ) then
        # Right,go on.
    else
        self.msg(rule_name,:error,'routing','Some key NOT found.')
        return
    end
    
    if info.has_key?('Operation') then
      
	case info['Operation']
	
    	##############################	
    	# "New Route"
    	##############################	
      	when 'New route'
	    begin
		@ff.link(:text,'New Route').click
		self.msg(rule_name,:info,'Operation','Reached page of \'Operation\' route.')
	    rescue
	puts "baby"
		self.msg(rule_name,:error,'Operation','Can not \'Operation\' route page.')	
		return
	    end
	    
	    if @ff.text.include?'Route Settings' then
		# Right,go on;
	    else
		self.msg(rule_name,:error,'Route Setting','Does NOT Enter Route Setting page.')
		return
	    end
	    # Select name for route;
	    if info.has_key?('Name')
		
		case info['Name']
		
		    when 'Broadband Connection (Ethernet)'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("Broadband Connection (Ethernet)")	
			self.msg(rule_name,:info,'Name',info['Name'])

		    when 'Broadband Connection (Coax)'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("Broadband Connection (Coax)")	
			self.msg(rule_name,:info,'Name',info['Name'])

		    when 'WAN PPPoE'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("WAN PPPoE)")	
			self.msg(rule_name,:info,'Name',info['Name'])
	
		    when 'WAN PPPoE 2'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("WAN PPPoE 2")	
			self.msg(rule_name,:info,'Name',info['Name'])

		    when 'Network (Home/Office)'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("Network (Home/Office)")	
			self.msg(rule_name,:info,'Name',info['Name'])
		    else 
			
			# Wrong
			self.msg(rule_name,:error,'Name','Can NOT configure \'Name\'.')
			return
		    
		    end # End of case
            end # End of 'Name'
	    if info.has_key?('Destination') and info['Destination'].size > 0
		
		octets=info['Destination'].split('.')
		@ff.text_field(:name,'dest0').value=(octets[0])
		@ff.text_field(:name,'dest1').value=(octets[1])
		@ff.text_field(:name,'dest2').value=(octets[2])
		@ff.text_field(:name,'dest3').value=(octets[3])
		self.msg(rule_name,:info,'Doset_destination',"Destination = "+info['Destination'])

	    end
	    if info.has_key?('Netmask') and info['Netmask'].size > 0
		
		octets=info['Netmask'].split('.')
		@ff.text_field(:name,'netmask0').value=(octets[0])
		@ff.text_field(:name,'netmask1').value=(octets[1])
		@ff.text_field(:name,'netmask2').value=(octets[2])
		@ff.text_field(:name,'netmask3').value=(octets[3])
		self.msg(rule_name,:info,'Doset_Netmask',"Netmask = "+info['Netmask'])

	    end
	    if info.has_key?('Gateway') and info['Gateway'].size > 0
		
		octets=info['Gateway'].split('.')
		@ff.text_field(:name,'gateway0').value=(octets[0])
		@ff.text_field(:name,'gateway1').value=(octets[1])
		@ff.text_field(:name,'gateway2').value=(octets[2])
		@ff.text_field(:name,'gateway3').value=(octets[3])
		self.msg(rule_name,:info,'Doset_gateway',"Gateway = "+info['Gateway'])

	    end
	    if info.has_key?('Metric') then
		
		@ff.text_field(:name,'metric').value=info['Metric']
		self.msg(rule_name,:info,'Set metric','Metric value is \'Metric\'.')
	    else
		self.msg(rule_name,:error,'Set metric','Can Not set metric value to \'Metric\'.')
		return
	    end
	    
	    # Apply to save new route;		
	    @ff.link(:text,'Apply').click
	    self.msg(rule_name,:info,'Apply','\'Apply\' to save new route.')

	    if @ff.text.include?'Input Errors'
		
		# Find table
		sTable = false
		@ff.tables.each do |t|
		    
		    if ( t.text.include? ':' and
			(not t.text.include? 'Input Errors') and 
			(not t.text.include? 'Cancel') and
			t.row_count >= 1 ) then
				sTable = t
			break
		    end
		end
		# Wrong here
	        if sTable == false
		    self.msg(rule_name,:error,'New route','Did NOT find the target table.')
		    return
		end
		
		sTable.each do |row|
			
		    if row[1] == "" or row[2] == nil
		    next
		    end
	
		    self.msg(rule_name,:error,row[1],row[2])
		end

		# Cancel
		@ff.link(:text,'Cancel').click
		return
	    
	    end  # end of 'Input Error'			
	##############################	
    	# "Multi Route"
    	##############################	
      	when 'Multi route'
	    
	    if info.has_key?('Max route') then
		self.msg(rule_name,:info,'Multi route','Go on adding multi-route and Max route is : \'Max route\'.')
	    end
	    count=1	
	    
	    if info.has_key?('Destination') and info['Destination'].size > 0
		octets=info['Destination'].split('.')

		octets2=(octets[2]).to_i
		#puts "#{octets2}"
		octets3=(octets[3]).to_i
		#puts "#{octets3}"
		self.msg(rule_name,:info,'Get address of destination',"Destination = "+info['Destination'])
	    end
	    
	    while count <= info['Max route'].to_i 
	    #for i in octets3.to_i..info['Max route'].to_i
		begin
		    @ff.link(:text,'New Route').click
		    self.msg(rule_name,:info,'Operation','Reached page of \'Operation\' route.')
		rescue
		    self.msg(rule_name,:error,'Operation','Can not \'Operation\' route page.')	
		    return
		end
	    
		if @ff.text.include?'Route Settings' then
		   # Right,go on;
		else
		    self.msg(rule_name,:error,'Route Setting','Does NOT Enter Route Setting page.')
		    return
		end
		# Select name for route;
		if info.has_key?('Name')
		
		    case info['Name']
		
		    when 'Broadband Connection (Ethernet)'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("Broadband Connection (Ethernet)")	
			self.msg(rule_name,:info,'Name',info['Name'])

		    when 'Broadband Connection (Coax)'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("Broadband Connection (Coax)")	
			self.msg(rule_name,:info,'Name',info['Name'])

		    when 'WAN PPPoE'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("WAN PPPoE)")	
			self.msg(rule_name,:info,'Name',info['Name'])
	
		    when 'WAN PPPoE 2'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("WAN PPPoE 2")	
			self.msg(rule_name,:info,'Name',info['Name'])

		    when 'Network (Home/Office)'

			# Set name to 'Broadband Connection (Ethernet)'
			@ff.select_list(:name,'combo_device').select("Network (Home/Office)")	
			self.msg(rule_name,:info,'Name',info['Name'])
		    else 
			
			# Wrong
			self.msg(rule_name,:error,'Name','Can NOT configure \'Name\'.')
			return
		    
		    end # End of case
		end # End of 'Name'
		if info.has_key?('Destination') and info['Destination'].size > 0
		
		   octets=info['Destination'].split('.')

		    @ff.text_field(:name,'dest0').value=(octets[0])
		    @ff.text_field(:name,'dest1').value=(octets[1])
		    @ff.text_field(:name,'dest2').value=octets2.to_i
		    @ff.text_field(:name,'dest3').value=octets3.to_i
		    self.msg(rule_name,:info,'Doset_destination',"Destination = "+info['Destination'])

		end
		if info.has_key?('Netmask') and info['Netmask'].size > 0
		
		    octets=info['Netmask'].split('.')
		    @ff.text_field(:name,'netmask0').value=(octets[0])
		    @ff.text_field(:name,'netmask1').value=(octets[1])
		    @ff.text_field(:name,'netmask2').value=(octets[2])
		    @ff.text_field(:name,'netmask3').value=(octets[3])
		    self.msg(rule_name,:info,'Doset_Netmask',"Netmask = "+info['Netmask'])

		end
		if info.has_key?('Gateway') and info['Gateway'].size > 0
		
		    octets=info['Gateway'].split('.')
		    @ff.text_field(:name,'gateway0').value=(octets[0])
		    @ff.text_field(:name,'gateway1').value=(octets[1])
		    @ff.text_field(:name,'gateway2').value=(octets[2])
		    @ff.text_field(:name,'gateway3').value=(octets[3])
		    self.msg(rule_name,:info,'Doset_gateway',"Gateway = "+info['Gateway'])

		end
		if info.has_key?('Metric') then
		
		    @ff.text_field(:name,'metric').value=info['Metric']
		    self.msg(rule_name,:info,'Set metric','Metric value is \'Metric\'.')
		else
		    self.msg(rule_name,:error,'Set metric','Can Not set metric value to \'Metric\'.')
		    return
		end # End of if

		# Apply to save new route;		
		@ff.link(:text,'Apply').click
		self.msg(rule_name,:info,'Apply','\'Apply\' to save new route.')

		if @ff.text.include?'Input Errors'
		
		   # Find table
		    sTable = false
		    @ff.tables.each do |t|
		    
			 if ( t.text.include? ':' and
			    (not t.text.include? 'Input Errors') and 
			    (not t.text.include? 'Cancel') and
			    t.row_count >= 1 ) then
				   sTable = t
			    break
			 end
		    end
		    # Wrong here
		    if sTable == false
			self.msg(rule_name,:error,'New route','Did NOT find the target table.')
			return
		    end
		
		    sTable.each do |row|
			
			if row[1] == "" or row[2] == nil
			next
			end
	
			self.msg(rule_name,:error,row[1],row[2])
		    end

		    # Cancel
		    @ff.link(:text,'Cancel').click
		    return
	    
		end  # end of 'Input Error'
		
		count = count + 1
		puts "Adding the No.#{count} route."
		octets3 = octets3 + 1
		#puts octets3
		# re-setup ipaddress when the ipaddress over 254;
		if octets3 == 255 then
		    octets3 = 1
		    octets2 = octets2 + 1
		end
	 end # End of while

    	##############################	
    	# "del Route"
    	##############################
      	when 'del route'
		
	    if @ff.text.include?'Routing Table'
		
		# Find route table
		sTable = false
		@ff.tables.each do |t|
		    if ( t.text.include? 'Routing Table' and 
			(not t.text.include? 'Routing Protocols') and 
			(not t.text.include? 'IGMP') and
			(not t.text.include? 'Domain Routing') and 
			t.row_count >= 2 ) then
				sTable = t
			break
		    end
		end
		
		# Wrong here
		if sTable == false
			
			self.msg(rule_name,:error,'Del route','Can NOT find right route table.')
			return
		end

		num = 0
		sTable.each do |row|
		    if row[7] != nil then
			# row[7].links.each do |l|
			#     puts l.name
			# end
			if row[7].link(:name,'route_remove').exist?
			    #puts "haha"
			    #puts @ff.text_field(:name,row[7]).to_s
			    @ff.link(:href,row[7].link(:name,'route_remove').href).click
			end
		    end	
				# Output the result
				#self.msg(rule_name,:info,'Name' + num.to_s,row[1])
				#self.msg(rule_name,:info,'Destination' + num.to_s,row[2])
				#self.msg(rule_name,:info,'Gateway' + num.to_s,row[3])
				#self.msg(rule_name,:info,'Netmask' + num.to_s,row[4])
				#self.msg(rule_name,:info,'Metric' + num.to_s,row[5])
				#self.msg(rule_name,:info,'Status' + num.to_s,row[5])
				#num = num + 1
		end # End of table;

            end # End of 'Del route'

		# pasre the table of route
		# delete these
		self.msg(rule_name,:info,'Del route','Delete the list is successful. ')
	else
        	# Wrong here.
        	self.msg(rule_name,:error,'routing','No \'New Route\' key.')
        	return
      	end # End of Case

    end # End of 'Operation'
    
    #-------------------------------------------#
    # "Internet Group Management Protocol(IGMP)"
    #-------------------------------------------#
    if info.has_key?('Internet Group Management Protocol(IGMP)') then
	# "Internet Group Management Protocol(IGMP)"
      	case info['Internet Group Management Protocol(IGMP)']
      	 
	    when 'on'
        	# Select mcast_enabled
        	@ff.checkbox(:name,'mcast_enabled').set
        	self.msg(rule_name,:info,'Internet Group Management Protocol(IGMP)','on')
      	    when 'off'
        	# Don't select it.
        	@ff.checkbox(:name,'mcast_enabled').clear
        	self.msg(rule_name,:info,'Internet Group Management Protocol(IGMP)','off')
            else
        	# Wrong here.
        	self.msg(rule_name,:error,'routing','No \'Internet Group Management Protocol(IGMP)\' key.')
        	return
      	end

    end # End of 'IGMP'

    #-------------------------------------------#
    # "Domain Routing"
    #-------------------------------------------#
    if info.has_key?('Domain Routing') then
      	
	# "Internet Group Management Protocol(IGMP)"
      	case info['Domain Routing']
            
	    when 'on'
        	# Select it
        	@ff.checkbox(:name,'dns_routing_enabled').set
        	self.msg(rule_name,:info,'Domain Routing','on')
            when 'off'
        	# Don't select it.
        	@ff.checkbox(:name,'dns_routing_enabled').clear
        	self.msg(rule_name,:info,'Domain Routing','off')
      	    else
        	# Wrong here.
        	self.msg(rule_name,:error,'routing','No \'Domain Routing\' key.')
        	return
      	    end

    end # End of 'Domain Routing'
    
    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Jump out an "attention" message?
    if @ff.text.include? 'Attention'
      	@ff.link(:text,'Apply').click
    end
    
    # routing success
    self.msg(rule_name,:info,'Routing','SUCCESS')

    
  end # end of def  
  #----------------------------------------------------------------------
  # ip_address_distribution(rule_name, info)
  # Discription: function of "IP Address Distribution" under "Advance" page.
  #----------------------------------------------------------------------
  def ip_address_distribution(rule_name, info)

    # Get to the advanced page.
    self.goto_advanced(rule_name, info)
    
    # Get to the "IP Address Distribution" page.
    begin
      @ff.link(:text, 'IP Address Distribution').click
      self.msg(rule_name, :info, 'IP Address Distribution', 'Reached page \'IP Address Distribution\'.')
    rescue
      self.msg(rule_name, :error, 'IP Address Distribution', 'Did not reach \'IP Address Distribution\' page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('subsection') )then
      # Right,go on.
    else
      self.msg(rule_name,:error,'ip_address_distribution','Some key NOT found.')
      return
    end
    
    # Begin parsing the json file.
    
    # Output the table.
    
    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Name' and 
           t.text.include? 'Service' and
           ( not t.text.include? 'IP Address Distribution') and
           ( not t.text.include? 'Close') and
           t.row_count >= 2 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'ip_address_distribution','Did NOT find the target table.')
      return
    end
    
    iFlag = 0
    strEntry = ""
    
    # Find the row
    sTable.each do |row|
      
      iFlag = iFlag + 1
      
      # not for first line
      if iFlag == 1
        next
      end
      strEntry = "IP" + (iFlag - 1).to_s
      
      # Output in to the result.
      self.msg(rule_name,strEntry,'Name',row[1])
      self.msg(rule_name,strEntry,'Service',row[2])
      self.msg(rule_name,strEntry,'Subnet Mask',row[3])
      self.msg(rule_name,strEntry,'Dynamic IP Range',row[4])
      
    end     

    if info.has_key?('Name')
      case info['Name']
      when 'Network (Home/Office)'
        DoNetworkHomeOfficePage(rule_name, info)
      when 'Broadband Connection (Ethernet)'
        DoBroadbandConnectionEthernetPage(rule_name, info)
      when 'Broadband Connection (Coax)'
        DoBroadbandConnectionCoaxPage(rule_name, info)
      when 'Connection List'
        DoConnectionList(rule_name, info)
      when 'Access Control'
        DoAccessControl(rule_name, info)
      else
        self.msg(rule_name, :error, '', 'No Name undefined')
      end 
    else
      self.msg(rule_name, :error, '', 'No layout key found')
    end
      
    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end
    
    # Output the result
    self.msg(rule_name,:Result_Info,'ip_address_distribution','SUCCESS')        
    
  end # end of def
  
  def DoNetworkHomeOfficePage(rule_name, info)
    begin
      @ff.link(:text, 'Network (Home/Office)').click
      self.msg(rule_name,:info,'Network(Home/Office)','Reach into Network(Home/Office)')
    rescue
      self.msg(rule_name, :error, 'DoNetworkHomeOfficePage()', 'Cannot reach NetworkHomeOfficePage')
      return
    end
    DoDHCPSettings(rule_name, info)    
  end # end of DoNetworkHomeOfficePage
  
  def DoBroadbandConnectionEthernetPage(rule_name, info)
    begin
#      @ff.link(:text, 'Broadband Connection (Ethernet)').click
      @ff.link(:href, 'javascript:mimic_button(\'edit: eth1..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'Broadband Connection (Ethernet)', 'Broadband Connection (Ethernet)')
      return
    end
    DoDHCPSettings(rule_name, info) 
  end # end of DoBroadbandConnectionEthernetPage
  
  def DoBroadbandConnectionCoaxPage(rule_name, info)
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: clink1..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'DoNetworkHomeOfficePage()', 'Broadband Connection (Coax)')
      return
    end
    DoDHCPSettings(rule_name, info) 
  end # end of DoBroadbandConnectionCoaxPage
 
  def DoConnectionList(rule_name, info)
    begin
      @ff.link(:text, 'Connection List').click
    rescue
      self.msg(rule_name, :error, 'DoConnectionList()', 'Click Connection List button')
    end

    if info.key?('DHCP OUTPUT')
      case info ['DHCP OUTPUT']
       when 'on'
           @ff.tables.each do |l|
             if  ( l.text.include? 'Host Name' ) &&
                      ( not l.text.include? 'DHCP Connections' ) then
               count=l.row_count - 1
               self.msg(rule_name, :info, "NumberRow", count - 1)
               for i in 2..count
                    self.msg(rule_name, :info, "Connection (#{i - 1})", l.row_values(i))
               end
             end
            
       end
      end
     end

     if info.key?('DHCP EDIT CONN STATIC')
       case info ['DHCP EDIT CONN STATIC']
        when 'on'
           @ff.tables.each do |t|
             if  ( t.text.include? 'Host Name' ) &&
                      ( not t.text.include? 'DHCP Connections' ) then
               count=t.row_count - 1
               for i in 2..count
                 celllink=t[i][2].text
                 begin
                   @ff.link(:href, "javascript:mimic_button('edit: #{celllink}..', 1)").click
                   self.msg(rule_name, :info, 'Click dhcp connection', 'Reach into dhcp connection')
                 rescue
                   self.msg(rule_name, :error, 'Click dhcp connection', 'Do not find the dhcp connection link')
                   return
                 end

                 begin
                   @ff.checkbox(:name, 'is_stat_lease').set
                   self.msg(rule_name, :info, 'Choice static lease type', 'Choice it')
                 rescue
                   self.msg(rule_name, :error, 'Choice static lease type', 'Cannot choice it')
                   return
                 end

                 @ff.link(:text, 'Apply').click
               end
             end
            end

        when 'off'
           @ff.tables.each do |t|
             if  ( t.text.include? 'Host Name' ) &&
                      ( not t.text.include? 'DHCP Connections' ) then
               count=t.row_count - 1
               for i in 2..count
                 celllink=t[i][2].text
                 begin
                   @ff.link(:href, "javascript:mimic_button('edit: #{celllink}..', 1)").click
                   self.msg(rule_name, :info, 'Click dhcp connection', 'Reach into dhcp connection')
                 rescue
                   self.msg(rule_name, :error, 'Click dhcp connection', 'Do not find the dhcp connection link')
                   return
                 end

                 begin
                   @ff.checkbox(:name, 'is_stat_lease').clear
                   self.msg(rule_name, :info, 'Choice static lease type', 'Choice it')
                 rescue
                   self.msg(rule_name, :error, 'Choice static lease type', 'Cannot choice it')
                   return
                 end

                 @ff.link(:text, 'Apply').click
               end
             end
            end
       end
     end

     if info.key?('DHCP NEW STATIC CONN')
       case info['DHCP NEW STATIC CONN'] 
        when 'on'
         @ff.link(:text, 'New Static Connection').click
         if info.key?('Host Name')
            @ff.text_field(:name, 'hostname').value=(info['Host Name'])
            self.msg(rule_name, :info, 'Host Name', info['Host Name'])
         end
         if info.key?('IP Address')
            octets=info['IP Address'].split('.')
            @ff.text_field(:name, 'ip0').value=(octets[0])
            @ff.text_field(:name, 'ip1').value=(octets[1])
            @ff.text_field(:name, 'ip2').value=(octets[2])
            @ff.text_field(:name, 'ip3').value=(octets[3])
            self.msg(rule_name, :info, 'IP Address ', info['IP Address'])
         end
         if info.key?('MAC Address')
            octets=info['MAC Address'].split(':')
            @ff.text_field(:name, 'mac0').value=(octets[0])
            @ff.text_field(:name, 'mac1').value=(octets[1])
            @ff.text_field(:name, 'mac2').value=(octets[2])
            @ff.text_field(:name, 'mac3').value=(octets[3])
            @ff.text_field(:name, 'mac4').value=(octets[4])
            @ff.text_field(:name, 'mac5').value=(octets[5])
            self.msg(rule_name, :info, 'MAC Address ', info['MAC Address'])
         end
       end

       @ff.link(:text, 'Apply').click
        if  @ff.contains_text("Input Errors")
            errorTable=@ff.tables[18]
            errorTable_rowcount=errorTable.row_count
            for i in 1..errorTable_rowcount-1
              self.msg(rule_name, :PageInfo_Error, "DoConnectionList()->Apply (#{i})", errorTable.[](i).text)
            end
            self.msg(rule_name, :error, 'DoConnectionList()->Apply', 'DoConnectionList setup fault')
        else
            if @ff.contains_text("Attention")
               errorTable=@ff.tables[18]
               errorTable_rowcount=errorTable.row_count
               for i in 1..errorTable_rowcount-1
                 self.msg(rule_name, :PageInfo_Error, "DoConnectionList()->Apply (#{i})", errorTable.[](i).text)    
               end
               @ff.link(:text, 'Apply').click
               self.msg(rule_name, :result_info, 'DoConnectionList()->Apply', 'DoConnectionList sucessful with Attention')
            else
              self.msg(rule_name, :result_info, 'DoConnectionList()->Apply', 'DoConnectionList setup sucessful')
            end
        end
       end

     if info.key?('DHCP CONN NUM')
       num=info['DHCP CONN NUM'].split(',')
       loopstart=num[0].to_i
       loopnum=num[1].to_i
      
       j=0
       jj=9
       k=0
       kk=9
 
       if ( loopstart <= 1 )
           loopstart = 2
       end

       for i in loopstart..loopnum
         # standard testbed pc1 testport reserved 200 as its ip address, so switch it
         if ( i == 200 )
            k=1
            next
         end
         @ff.link(:text, 'New Static Connection').click

         @ff.text_field(:name, 'hostname').value='host' + i.to_s

         @ff.text_field(:name, 'ip0').value=192
         @ff.text_field(:name, 'ip1').value=168
         @ff.text_field(:name, 'ip2').value=1
         @ff.text_field(:name, 'ip3').value=i

         @ff.text_field(:name, 'mac0').value='00'
         @ff.text_field(:name, 'mac1').value='ff'
         @ff.text_field(:name, 'mac2').value='ff'

         # mac3
         if ( i < 210 && i >200 )
           @ff.text_field(:name, 'mac3').value='0' + k.to_s
           k+=1
         elsif ( i < 255 && i >= 210 )
           kk+=1
           @ff.text_field(:name, 'mac3').value=kk
         else
           @ff.text_field(:name, 'mac3').value='ff' 
         end

         # mac4         
         if ( i < 110 && i >= 100 )
            @ff.text_field(:name, 'mac4').value='0' + j.to_s
            j+=1
            sleep 1
         elsif ( i < 200 && i >= 110 )
            jj+=1
            @ff.text_field(:name, 'mac4').value=jj
         else
            @ff.text_field(:name, 'mac4').value='ff'            
         end

         # mac5
         if ( i < 10 )
            @ff.text_field(:name, 'mac5').value='0' + i.to_s
         elsif ( i < 100 && i >= 10 )
            @ff.text_field(:name, 'mac5').value=i
         else
            @ff.text_field(:name, 'mac5').value='ff'
         end
 
       @ff.link(:text, 'Apply').click
        if  @ff.contains_text("Input Errors")
            errorTable=@ff.tables[18]
            errorTable_rowcount=errorTable.row_count
            for i in 1..errorTable_rowcount-1
              self.msg(rule_name, :PageInfo_Error, "DoConnectionList()->Apply (#{i})", errorTable.[](i).text)
            end
            self.msg(rule_name, :error, 'DoConnectionList()->Apply', 'DoConnectionList setup fault')
        else
            if @ff.contains_text("Attention")
               errorTable=@ff.tables[18]
               errorTable_rowcount=errorTable.row_count
               for i in 1..errorTable_rowcount-1
                 self.msg(rule_name, :PageInfo_Error, "DoConnectionList()->Apply (#{i})", errorTable.[](i).text)    
               end
               @ff.link(:text, 'Apply').click
               self.msg(rule_name, :result_info, 'DoConnectionList()->Apply', 'DoConnectionList sucessful with Attention')
            else
              self.msg(rule_name, :result_info, 'DoConnectionList()->Apply', 'DoConnectionList setup sucessful')
            end
        end

       end # loopnum end
       self.msg(rule_name, :result_info, 'DoConnectionList()->Add New Static connection', 'Done')
     end        

  end

  def DoAccessControl(rule_name, info)
      @ff.link(:text, 'Access Control').click
      self.msg(rule_name, :info, 'DoAccessControl', 'Click Access Control')
      if info.key?('MAC Filtering Mode')
           case info ['MAC Filtering Mode']
              when 'Allow'
                 @ff.select_list(:name, 'mac_filter_mode').select('Allow')
                 self.msg(rule_name, :info, 'DHCP Access Control->', 'Select Allow')

                 if info.key?('Filtering MAC Address')
                   @ff.link(:text, 'New MAC Address').click
                   octets=info['Filtering MAC Address'].split(':')
                   @ff.text_field(:name, 'mac0').value=(octets[0])
                   @ff.text_field(:name, 'mac1').value=(octets[1])
                   @ff.text_field(:name, 'mac2').value=(octets[2])
                   @ff.text_field(:name, 'mac3').value=(octets[3])
                   @ff.text_field(:name, 'mac4').value=(octets[4])
                   @ff.text_field(:name, 'mac5').value=(octets[5])
                 end

                 if info.key?('MAC Range')
                   num=info['MAC Range'].split(',')
                   loopstart=num[0].to_i
                   loopnum=num[1].to_i

                   j=0
                   jj=9
                   k=0
                   kk=9

                   for i in loopstart..loopnum
                      @ff.link(:text, 'New MAC Address').click

                      @ff.text_field(:name, 'mac0').value='00'
                      @ff.text_field(:name, 'mac1').value='ff'
                      @ff.text_field(:name, 'mac2').value='ff'

                      # mac3
                      if ( i < 210 && i >200 )
                         @ff.text_field(:name, 'mac3').value='0' + k.to_s
                         k+=1
                      elsif ( i < 255 && i >= 210 )
                         kk+=1
                         @ff.text_field(:name, 'mac3').value=kk
                      else
                         @ff.text_field(:name, 'mac3').value='ff'
                      end

                      # mac4         
                      if ( i < 110 && i >= 100 )
                         @ff.text_field(:name, 'mac4').value='0' + j.to_s
                         j+=1
                         sleep 1
                      elsif ( i < 200 && i >= 110 )
                         jj+=1
                         @ff.text_field(:name, 'mac4').value=jj
                      else
                         @ff.text_field(:name, 'mac4').value='ff'
                      end

                      # mac5
                      if ( i < 10 )
                         @ff.text_field(:name, 'mac5').value='0' + i.to_s
                      elsif ( i < 100 && i >= 10 )
                         @ff.text_field(:name, 'mac5').value=i
                      else
                         @ff.text_field(:name, 'mac5').value='ff'
                      end
                      @ff.link(:text, 'Apply').click
                   end
                 end

              when 'Deny'
                 @ff.select_list(:name,'mac_filter_mode').select('Deny')
                 self.msg(rule_name, :info, 'DHCP Access Control->', 'Select Deny')
                 @ff.link(:text, 'New MAC Address').click
                 if info.key?('Filtering MAC Address')
                   octets=info['Filtering MAC Address'].split(':')
                   @ff.text_field(:name, 'mac0').value=(octets[0])
                   @ff.text_field(:name, 'mac1').value=(octets[1])
                   @ff.text_field(:name, 'mac2').value=(octets[2])
                   @ff.text_field(:name, 'mac3').value=(octets[3])
                   @ff.text_field(:name, 'mac4').value=(octets[4])
                   @ff.text_field(:name, 'mac5').value=(octets[5])
                 end
                 @ff.link(:text, 'Apply').click
           end
      end
      @ff.link(:text, 'Apply').click
  end

  def DoDHCPSettings(rule_name, info)
    if info.key?('IP Address Distribution')
      case info ['IP Address Distribution']
      when 'Disabled'
        @ff.select_list(:name, 'dhcp_mode').select_value('0')
      when 'DHCP Server'
        @ff.select_list(:name, 'dhcp_mode').select_value('1')
      when 'DHCP Relay'  
        @ff.select_list(:name, 'dhcp_mode').select_value('2')
      end     
    end
   
		if info.key?('New IP Address')
			 @ff.link(:text, 'New IP Address').click
    	 if info.key?('New IP Address') and info['New IP Address'].size > 0
       		octets=info['New IP Address'].split('.')
       		@ff.text_field(:name, 'dhcpr_server0').value=(octets[0])
       		@ff.text_field(:name, 'dhcpr_server1').value=(octets[1])
       		@ff.text_field(:name, 'dhcpr_server2').value=(octets[2])
       		@ff.text_field(:name, 'dhcpr_server3').value=(octets[3])
       		self.msg(rule_name, :info, 'New IP Address', info['New IP Address'])
    	 end
    	@ff.link(:text, 'Apply').click
    	if  @ff.contains_text("Input Errors") 
      	 errorTable=@ff.tables[18]
       	errorTable_rowcount=errorTable.row_count
       	for i in 1..errorTable_rowcount-1
        	 self.msg(rule_name, :PageInfo_Error, "DoDHCPSettings()->Apply (#{i})", errorTable.[](i).text)    
       	end 
       	self.msg(rule_name, :error, 'DoDHCPSettings()->Apply', 'DoDHCPSettings setup fault')
     	else
      	 if @ff.contains_text("Attention") 
        	 errorTable=@ff.tables[18]
         	errorTable_rowcount=errorTable.row_count
         	for i in 1..errorTable_rowcount-1
          	 self.msg(rule_name, :PageInfo_Error, "DoDHCPSettings()->Apply (#{i})", errorTable.[](i).text)    
         	end 
         	@ff.link(:text, 'Apply').click
         	self.msg(rule_name, :result_info, 'DoDHCPSettings()->Apply', 'DoDHCPSettings sucessful with Attention')
       else
         self.msg(rule_name, :result_info, 'DoDHCPSettings()->Apply', 'DoDHCPSettings setup sucessful')
       end 
     end
		end	
 
    if info.key?('Start IP Address') and info['Start IP Address'].size > 0
       octets=info['Start IP Address'].split('.')
       @ff.text_field(:name, 'start_ip0').value=(octets[0])
       @ff.text_field(:name, 'start_ip1').value=(octets[1])
       @ff.text_field(:name, 'start_ip2').value=(octets[2])
       @ff.text_field(:name, 'start_ip3').value=(octets[3])
       self.msg(rule_name, :info, 'Start IP Address', info['Start IP Address'])
    end
    
    if info.key?('End IP Address') and info['End IP Address'].size > 0
       octets=info['End IP Address'].split('.')
       @ff.text_field(:name, 'end_ip0').value=(octets[0])
       @ff.text_field(:name, 'end_ip1').value=(octets[1])
       @ff.text_field(:name, 'end_ip2').value=(octets[2])
       @ff.text_field(:name, 'end_ip3').value=(octets[3])
       self.msg(rule_name, :info, 'End IP Address', info['End IP Address'])
    end
      
    if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
       octets=info['Subnet Mask'].split('.')
       @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
       @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
       @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
       @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
       self.msg(rule_name, :info, 'Subnet Mask', info['Subnet Mask'])
    end
    
    if info.key?('WINS Server') and info['WINS Server'].size > 0
      octets=info['WINS Server'].split('.')
      @ff.text_field(:name, 'wins0').value=(octets[0])
      @ff.text_field(:name, 'wins1').value=(octets[1])
      @ff.text_field(:name, 'wins2').value=(octets[2])
      @ff.text_field(:name, 'wins3').value=(octets[3])
      self.msg(rule_name, :info, 'WINS Server', info['WINS Server'])
   end
    
    if info.key?('Lease Time in Minutes')
      @ff.text_field(:name, 'lease_time').value=info['Lease Time in Minutes']
      self.msg(rule_name, :info, 'Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])   
    end
    
    if info.key?('Provide Host Name If Not Specified by Client')
      case info ['Provide Host Name If Not Specified by Client']
      when 'on'
        @ff.checkbox(:name, 'create_hostname').set
        self.msg(rule_name, :info, 'Provide Host Name If Not Specified by Client', 'set on')  
      when
        @ff.checkbox(:name, 'create_hostname').clear
        self.msg(rule_name, :info, 'Provide Host Name If Not Specified by Client', 'set off')
      end   
    end
    
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors") 
       errorTable=@ff.tables[18]
       errorTable_rowcount=errorTable.row_count
       for i in 1..errorTable_rowcount-1
	    self.msg(rule_name, :PageInfo_Error, "DoDHCPSettings()->Apply (#{i})", errorTable.[](i).text)    
       end 
       self.msg(rule_name, :error, 'DoDHCPSettings()->Apply', 'DoDHCPSettings setup fault')
     else
       if @ff.contains_text("Attention") 
         errorTable=@ff.tables[18]
         errorTable_rowcount=errorTable.row_count
         for i in 1..errorTable_rowcount-1
           #self.msg(rule_name, :PageInfo_Error, "DoDHCPSettings()->Apply (#{i})", errorTable.[](i).text)    
         end 
         @ff.link(:text, 'Apply').click
         self.msg(rule_name, :result_info, 'DoDHCPSettings()->Apply', 'DoDHCPSettings sucessful with Attention')
       else
         self.msg(rule_name, :result_info, 'DoDHCPSettings()->Apply', 'DoDHCPSettings setup sucessful')
       end 
     end
    
  end # end of DoDHCPSettings
  
end # end of class

