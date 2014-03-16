################################################################
#     MyNetwork.rb
#     Author:          RuBingSheng
#     Date:            since 2009.02.16
#     Contact:         Bru@actiontec.com
#     Discription:     Basic operation of My Network Page
#     Input:           it depends
#     Output:          the result of operation
################################################################

$dir = File.dirname(__FILE__) 
require $dir+ '/../BasicUtility'


class MyNetwork < BasicUtility
  
  # My Network  page
  def mynetwork(rule_name, info)
    
    #execute super.mynetwork(rule_name, info) to go to My Network  Page
    super
    
    # settings and testing on the My Network page
    # plsease add your code here...
    
    if info.key?('layout')
      case info['layout']
      when 'Network Status'
        NetworkStatus(rule_name, info)
      when 'Network Connections'
        NetworkConnections(rule_name, info)
      else
        self.msg(rule_name, :error, '', 'layout undefined')
      end
    else
      self.msg(rule_name, :error, '', 'No layout key found')
    end
    
  end
  
  def NetworkConnections(rule_name, info)
    # click the 'Network Connections' link 
    begin
      @ff.link(:text, 'Network Connections').click
    rescue
      self.msg(rule_name, :error, 'NetworkConnections()', 'Did not reach Network Connections page')
      return
    end
    # click Advanced button to expand all links
    if @ff.contains_text('Advanced >>')
      @ff.link(:text, 'Advanced >>').click
    end
    # select Page according to 'page' item in json file
    if info.key?('page')
      case info['page']      
      when 'Network (Home/Office)'
        # go to Network(Home/Office) Properties Page
        LanEthernet(rule_name, info)
        DoSetup_LanEthernet(rule_name, info)
      when 'Ethernet'
        # go to Ethernet Properties Page
        Ethernet(rule_name, info)
        DoSetup_Ethernet(rule_name, info)
      when 'Wireless Access Point'
        # go to Wireless Access Point Properties Page
        WirelessAccessPoint(rule_name, info)
        DoSetup_WirelessAccessPoint(rule_name, info)
      when 'Coax'
        # Begin: Modify by Robin Ru 2009/05/18
        # deal with enable and disable settings
        logoutflag=0
        if info.key?('Coax status')
          # click the 'Coax' link 
          begin
            @ff.link(:href, 'javascript:mimic_button(\'edit: clink0..\', 1)').click
          rescue
            self.msg(rule_name, :error, 'Coax()', 'Did not reach Coax page')
            return
          end
          case info ['Coax status']
          when 'Enable'
            if @ff.contains_text('Enable')
              @ff.link(:text, 'Enable').click
              @ff.link(:text, 'Apply').click
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "New Coax status = "+info['Coax status'])  
              return
            else
              logoutflag=1
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "Coax status = "+info['Coax status'])  
            end 
          when 'Disable'
            buttonTable=@ff.tables[20]
            if buttonTable.[](1).text=="Disable"
              @ff.link(:text, 'Disable').click
              @ff.link(:text, 'Apply').click
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "Coax status has been changed. Now Coax status = "+info['Coax status'])  
              return
            else
              logoutflag=1
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "Coax status = "+info['Coax status'])  
            end  
          end     
        end
        if logoutflag==0
          # go to Coax Properties Page
          Coax(rule_name, info)
          DoSetup_Coax(rule_name, info)
        end
      #End: Modify by Robin Ru 2009/05/18
      when 'Broadband Connection (Ethernet)'
        # go to Broadband Connection(Ethernet) Properties Page
        WanEthernet(rule_name, info)
        DoSetup_WanEthernet(rule_name, info)
      when 'Broadband Connection (Coax)'
        # Begin: Modify by Robin Ru 2009/05/18
        # deal with enable and disable settings
        logoutflag=0
        if info.key?('Coax status')
          # click the 'Coax' link 
          begin
            @ff.link(:href, 'javascript:mimic_button(\'edit: clink0..\', 1)').click
          rescue
            self.msg(rule_name, :error, 'Coax()', 'Did not reach Coax page')
            return
          end
          case info ['Coax status']
          when 'Enable'
            if @ff.contains_text('Enable')
              @ff.link(:text, 'Enable').click
              @ff.link(:text, 'Apply').click
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "Coax status has been changed. Now Coax status = "+info['Coax status'])  
              return
            else
              logoutflag=1
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "Coax status = "+info['Coax status'])  
            end 
          when 'Disable'
            buttonTable=@ff.tables[20]
            if buttonTable.[](1).text=="Disable"
              @ff.link(:text, 'Disable').click
              @ff.link(:text, 'Apply').click
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "New Coax status = "+info['Coax status'])  
              return
            else
              logoutflag=1
              self.msg(rule_name, :info, 'NetworkConnections()->Coax status', "Coax status = "+info['Coax status'])  
            end  
          end     
        end
        if logoutflag==0
          # go to Broadband Connection(Coax) Properties Page
          WanMoCA(rule_name, info)
          DoSetup_WanMoCA(rule_name, info)
        end
      # End: Modify by Robin Ru 2009/05/18
      when 'WAN PPPoE'
        # go to WAN PPPoE Properties Page
        WanPPPoE(rule_name, info)
        DoSetup_WanPPPoE(rule_name, info)
        # click Enable button
        if @ff.contains_text('Enable')
          @ff.link(:text, 'Enable').click
          self.msg(rule_name, :info, 'NetworkConnections()', 'PPPoE Enable')
        end
      when 'WAN PPPoE 2'
        # go to WAN PPPoE 2 Properties Page
        WanPPPoE2(rule_name, info)
        DoSetup_WanPPPoE2(rule_name, info)
        # click Enable button
        if @ff.contains_text('Enable')
          @ff.link(:text, 'Enable').click
          self.msg(rule_name, :info, 'NetworkConnections()', 'PPPoE Enable')
        end
      # Begin: deal with Bridge setup --add by Robin at 2009/05/14
      when 'Add'
        # go to Add Page and do setup 
        DoSetup_Add(rule_name, info)
      # End: deal with Bridge setup --add by Robin at 2009/05/14
      # Begin: deal with VLAN settings --added by Martin 
      when 'Ethernet VLAN 1'
        # go to VLAN setting Page and do setup 
        Ethernet_VLAN(rule_name, info)
        DoSetup_LanEthernet(rule_name, info)
      # End: deal with VLAN setting --added by Marin
      else
        self.msg(rule_name, :error, 'NetworkConnections()', 'page undefined')
      end
    else
      self.msg(rule_name, :error, 'NetworkConnections()', 'No page key found')
    end
  end
  
  def LanEthernet(rule_name, info)
    # go to Network(Home/Office) Properties Page from Network Connections Page
    # click the 'Network(Home/Office)' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: br0..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'LanEthernet()', 'Did not reach Network(Home/Office) page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'LanEthernet()', 'Did not reach Network (Home/Office) Properties page')
      return
    end
  end
  
  def Ethernet(rule_name, info)
    # go to Ethernet Properties Page from Network Connections Page
    # click the 'Ethernet' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: eth0..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'Ethernet()', 'Did not reach Ethernet page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'Ethernet()', 'Did not reach Ethernet Properties page')
      return
    end
  end
  
  def WirelessAccessPoint(rule_name, info)
    # go to Wireless Access Point Page from Network Connections Page
    # click the 'Wireless Access Point' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: ath0..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'WirelessAccessPoint()', 'Did not reach Wireless Access Point page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'WirelessAccessPoint()', 'Did not reach Wireless Access Point Properties page')
      return
    end
  end
  
  def Coax(rule_name, info)
    # go to Coax Page from Network Connections Page
    # click the 'Coax' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: clink0..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'Coax()', 'Did not reach Coax page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'Coax()', 'Did not reach Coax Properties page')
      return
    end
  end
  
  def WanEthernet(rule_name, info)
    # go to Broadband Connection(Ethernet) Properties Page from Network Connections Page
    # click the 'Broadband Connection(Ethernet)' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: eth1..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'WanEthernet()', 'Did not reach Broadband Connection(Ethernet) page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'WanEthernet()', 'Did not Broadband Connection(Ethernet) Properties page')
      return
    end
  end
  
  def WanMoCA(rule_name, info)
    # go to Broadband Connection(Coax) Properties Page from Network Connections Page
    # click the 'Broadband Connection(Coax)' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: clink1..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'WanMoCA()', 'Did not reach Broadband Connection(Coax) page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'WanMoCA()', 'Did not Broadband Connection(Coax) Properties page')
      return
    end
  end
  
  def WanPPPoE(rule_name, info)
    # go to WAN PPPoE Properties Page from Network Connections Page
    # click the 'WAN PPPoE' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: ppp0..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'WanPPPoE()', 'Did not reach WAN PPPoE page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'WanPPPoE()', 'Did not WAN PPPoE Properties page')
      return
    end
  end
  
  def WanPPPoE2(rule_name, info)
    # go to WAN PPPoE 2 Properties Page from Network Connections Page
    # click the 'WAN PPPoE 2' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: ppp1..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'WanPPPoE2()', 'Did not reach WAN PPPoE 2 page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'WanPPPoE2()', 'Did not WAN PPPoE 2 Properties page')
      return
    end
  end

  def Ethernet_VLAN(rule_name, info)
    # go to Ethernet VLAN 1 Properties Page from Network Connections Page
    # click the 'Ethernet VLAN 1' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: eth0.1..\', 1)').click
    rescue
       self.msg(rule_name, :error, 'Ethernet_VLAN()', 'Did not reach Ethernet VLAN page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'Ethernet_VLAN()', 'Did not reach Ethernet VLAN Properties page')
      return
    end
  end
  
  def DoSetup_LanEthernet(rule_name, info)
    if info.key?('Network')
      case info['Network']
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'network').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Network', 'Network = '+info['Network'])
        
        # Begin: deal with Bridge setup --add by Robin at 2009/05/13
        if info.key?('Bridge_Ethernet')
          case info['Bridge_Ethernet']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet undefined')
          end
        end
        if info.key?('Bridge_Ethernet_STP')
          case info['Bridge_Ethernet_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP undefined')
          end
        end
        
        if info.key?('Bridge_Broadband Connection (Ethernet)')
          case info['Bridge_Broadband Connection (Ethernet)']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth1').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth1').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet) undefined')
          end
        end
        if info.key?('Bridge_Broadband Connection (Ethernet)_STP')
          case info['Bridge_Broadband Connection (Ethernet)_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth1_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth1_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP undefined')
          end
        end
        
        if info.key?('Bridge_Coax')
          case info['Bridge_Coax']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax undefined')
          end
        end
        if info.key?('Bridge_Coax_STP')
          case info['Bridge_Coax_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP undefined')
          end
        end
        
        if info.key?('Bridge_Broadband Connection (Coax)')
          case info['Bridge_Broadband Connection (Coax)']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink1').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink1').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax) undefined')
          end
        end
        if info.key?('Bridge_Broadband Connection (Coax)_STP')
          case info['Bridge_Broadband Connection (Coax)_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink1_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink1_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP undefined')
          end
        end
        
        if info.key?('Bridge_Wireless Access Point')
          case info['Bridge_Wireless Access Point']
          when 'on'
            @ff.checkbox(:name, 'enslave_ath0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_ath0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point undefined')
          end
        end
        if info.key?('Bridge_Wireless Access Point_STP')
          case info['Bridge_Wireless Access Point_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_ath0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_ath0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP undefined')
          end
        end
        # End: deal with Bridge setup --add by Robin at 2009/05/13
              
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'No MTU key found')
        end
        
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end         
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address', "IP Address = "+info['IP Address'])
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'static_netmask0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask']) 
            end         
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Address'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', 'No DNS Server key found')
        end
        
        # IP Address Distribution
        if info.key?('IP Address Distribution')
            case info['IP Address Distribution']
            when 'Disabled'
              @ff.select_list(:id, 'dhcp_mode').select_value('0')     
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Relay'
              @ff.select_list(:id, 'dhcp_mode').select_value('2')
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
	      # Sir: begin
              # Author: Tom
              # Date: 2009.05.07                
       	    if info.key?('DR New IP Address')
		@ff.link(:href, 'javascript:mimic_button(\'dhcpr_add: br0..\', 1)').click
		self.msg(rule_name, :info, 'DoSetup_LanEthernet()->New IP Address DHCP Replay', 'Click New IP Address DHCP Relay')
		octets=info['DR New IP Address'].split('.')
		@ff.text_field(:name, 'dhcpr_server0').value=(octets[0])
		@ff.text_field(:name, 'dhcpr_server1').value=(octets[1])
		@ff.text_field(:name, 'dhcpr_server2').value=(octets[2])
		@ff.text_field(:name, 'dhcpr_server3').value=(octets[3])
		@ff.link(:text,'Apply').click
		self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Set DHCP Relay Host IP Address', "New IP Address = "+info['DR New IP Address'])
	    end
            when 'DHCP Server'
              @ff.select_list(:id, 'dhcp_mode').select_value('1')
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              if info.key?('Start IP Address') and info['Start IP Address'].size > 0
                octets=info['Start IP Address'].split('.')
                @ff.text_field(:name, 'start_ip0').value=(octets[0])
                @ff.text_field(:name, 'start_ip1').value=(octets[1])
                @ff.text_field(:name, 'start_ip2').value=(octets[2])
                @ff.text_field(:name, 'start_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
              end
              if info.key?('End IP Address') and info['End IP Address'].size > 0
                octets=info['End IP Address'].split('.')
                @ff.text_field(:name, 'end_ip0').value=(octets[0])
                @ff.text_field(:name, 'end_ip1').value=(octets[1])
                @ff.text_field(:name, 'end_ip2').value=(octets[2])
                @ff.text_field(:name, 'end_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->End IP Address', "End IP Address = "+info['End IP Address'])
              end
              if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
                octets=info['Subnet Mask'].split('.')
                @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
                @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
                @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
                @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
              end
              if info.key?('WINS Server') and info['WINS Server'].size > 0
                octets=info['WINS Server'].split('.')
                @ff.text_field(:name, 'wins0').value=(octets[0])
                @ff.text_field(:name, 'wins1').value=(octets[1])
                @ff.text_field(:name, 'wins2').value=(octets[2])
                @ff.text_field(:name, 'wins3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->WINS Server', "WINS Server = "+info['WINS Server'])
              end
              if info.key?('Lease Time in Minutes')
                @ff.text_field(:name, 'lease_time').value=(info['Lease Time in Minutes'])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])
              else
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Lease Time in Minutes', 'No Lease Time in Minutes key found')              
              end
              if info.key?('Provide Host Name If Not Specified by Client')
                case info['Provide Host Name If Not Specified by Client']
                when 'on'
                  @ff.checkbox(:name, 'create_hostname').set
                  self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=on')
                when 'off'
                  @ff.checkbox(:name, 'create_hostname').clear
                  self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client undefined')
                end
              else
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'No Provide Host Name If Not Specified by Client key found')
              end
              ###
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->IP Address Distribution', 'IP Address Distribution undefined')
            end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', 'No IP Address Distribution key found')
        end     
        
        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Routing Mode', 'Routing Mode undefined')
          end
        end
        
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Device Metric', "Device Metric = "+info['Device Metric'])
        end
        
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Default Route', 'Default Route=on')
            RouteSetting_LanEthernet(rule_name, info)          
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Default Route', 'Default Route undefined')
          end
        end
    	##############################	
    	# "New Route"
    	##############################	
      	if info.has_key?('Operation') then
      
	case info['Operation']
	  
	  when 'New route'
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
		
		if @ff.select_list(:name,'combo_device').include?(info['Name'])
			
		    @ff.select_list(:name,'combo_device').select(info['Name'])	
		    self.msg(rule_name,:info,'Name',info['Name'])
		else
		    self.msg(rule_name,:error,'Name','Can NOT find interface of configure \'Name\'.')
		end
            
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
			    #puts @ff.text_field(:name,row[7]).to_s
			    @ff.link(:href,row[7].link(:name,'route_remove').href).click
			    num += 1
			end
		    end	
		end # End of table;
		
		puts "There are #{num} route to be deleted"
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

	if info.key?('IP Address Edit')
	    sTable = false
	    @ff.tables.each do |t|
		if (t.text.include? 'Additional IP Addresses') and
		    (not t.text.include? 'Network (Home/Office) Properties') and
		    (not t.text.include? 'Internet Protocol') and
		    (t.row_count > 2) then
		    sTable = t
		    break
		end
	    end
	    i = 2
	    sTable.each do |row|
		row.links.each do |l|
		    if l.name.to_s.include? 'alias_edit' then
			if @ff.link(:href,l.href).exist? then
			    @ff.link(:href,l.href).click
			    @ff.text_field(:name,'ip3').value = 150 + i
			    i = i + 1
			    @ff.link(:text,'Apply').click
			    if @ff.text.include? 'Network Already Exists' then
				@ff.link(:text,'Apply').click
			    end
			end
			break
		    end
		end
		if i > info['IP Address Edit'].to_i + 1 then
		    break
		end
	    end
	    
	end

    
        if info.key?('Multicast - IGMP Proxy Internal')
          case info['Multicast - IGMP Proxy Internal']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=on')
            if info.key?('IGMP Query Version')
              case info['IGMP Query Version']
              when 'IGMPv1'
                @ff.select_list(:id, 'igmp_version').select_value('1') 
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version='+info['IGMP Query Version'])
              when 'IGMPv2'
                @ff.select_list(:id, 'igmp_version').select_value('2')
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version='+info['IGMP Query Version'])
              when 'IGMPv3'
                @ff.select_list(:id, 'igmp_version').select_value('3')
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version='+info['IGMP Query Version'])
              else
                self.msg(rule_name, :error, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version undefined')
              end
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->IGMP Query Version', 'No IGMP Query Version key found')
            end
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal undefined')
          end
        end
	###
      when 'Broadband Connection'
        @ff.select_list(:id, 'network').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Network', 'Network = '+info['Network'])
        
        # Begin: deal with Bridge setup --add by Robin at 2009/05/13
        if info.key?('Bridge_Ethernet')
          case info['Bridge_Ethernet']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet undefined')
          end
        end
        if info.key?('Bridge_Ethernet_STP')
          case info['Bridge_Ethernet_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP undefined')
          end
        end
        
        if info.key?('Bridge_Broadband Connection (Ethernet)')
          case info['Bridge_Broadband Connection (Ethernet)']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth1').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth1').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet) undefined')
          end
        end
        if info.key?('Bridge_Broadband Connection (Ethernet)_STP')
          case info['Bridge_Broadband Connection (Ethernet)_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth1_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth1_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP undefined')
          end
        end
        
        if info.key?('Bridge_Coax')
          case info['Bridge_Coax']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax undefined')
          end
        end
        if info.key?('Bridge_Coax_STP')
          case info['Bridge_Coax_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP undefined')
          end
        end
        
        if info.key?('Bridge_Broadband Connection (Coax)')
          case info['Bridge_Broadband Connection (Coax)']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink1').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink1').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax) undefined')
          end
        end
        if info.key?('Bridge_Broadband Connection (Coax)_STP')
          case info['Bridge_Broadband Connection (Coax)_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink1_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink1_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP undefined')
          end
        end
        
        if info.key?('Bridge_Wireless Access Point')
          case info['Bridge_Wireless Access Point']
          when 'on'
            @ff.checkbox(:name, 'enslave_ath0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_ath0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point undefined')
          end
        end
        if info.key?('Bridge_Wireless Access Point_STP')
          case info['Bridge_Wireless Access Point_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_ath0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_ath0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP undefined')
          end
        end
        # End: deal with Bridge setup --add by Robin at 2009/05/13      
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'No MTU key found')
        end
        
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end             
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address', "IP Address = "+info['IP Address'])
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'static_netmask0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask']) 
            end  
            if info.key?('Default Gateway') and info['Default Gateway'].size > 0
              octets=info['Default Gateway'].split('.')
              @ff.text_field(:name, 'static_gateway0').value=(octets[0])
              @ff.text_field(:name, 'static_gateway1').value=(octets[1])
              @ff.text_field(:name, 'static_gateway2').value=(octets[2])
              @ff.text_field(:name, 'static_gateway3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Default Gateway', "Default Gateway = "+info['Default Gateway']) 
            end        
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Address'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', 'No DNS Server key found')
        end
        
        # IP Address Distribution
        if info.key?('IP Address Distribution')
            case info['IP Address Distribution']
            when 'Disabled'
              @ff.select_list(:id, 'dhcp_mode').select_value('0')     
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Relay'
              @ff.select_list(:id, 'dhcp_mode').select_value('2')
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Server'
              @ff.select_list(:id, 'dhcp_mode').select_value('1')
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              if info.key?('Start IP Address') and info['Start IP Address'].size > 0
                octets=info['Start IP Address'].split('.')
                @ff.text_field(:name, 'start_ip0').value=(octets[0])
                @ff.text_field(:name, 'start_ip1').value=(octets[1])
                @ff.text_field(:name, 'start_ip2').value=(octets[2])
                @ff.text_field(:name, 'start_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
              end
              if info.key?('End IP Address') and info['End IP Address'].size > 0
                octets=info['End IP Address'].split('.')
                @ff.text_field(:name, 'end_ip0').value=(octets[0])
                @ff.text_field(:name, 'end_ip1').value=(octets[1])
                @ff.text_field(:name, 'end_ip2').value=(octets[2])
                @ff.text_field(:name, 'end_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->End IP Address', "End IP Address = "+info['End IP Address'])
              end
              if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
                octets=info['Subnet Mask'].split('.')
                @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
                @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
                @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
                @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
              end
              if info.key?('WINS Server') and info['WINS Server'].size > 0
                octets=info['WINS Server'].split('.')
                @ff.text_field(:name, 'wins0').value=(octets[0])
                @ff.text_field(:name, 'wins1').value=(octets[1])
                @ff.text_field(:name, 'wins2').value=(octets[2])
                @ff.text_field(:name, 'wins3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->WINS Server', "WINS Server = "+info['WINS Server'])
              end
              if info.key?('Lease Time in Minutes')
                @ff.text_field(:name, 'lease_time').value=(info['Lease Time in Minutes'])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])
              else
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Lease Time in Minutes', 'No Lease Time in Minutes key found')
              end
              if info.key?('Provide Host Name If Not Specified by Client')
                case info['Provide Host Name If Not Specified by Client']
                when 'on'
                  @ff.checkbox(:name, 'create_hostname').set
                  self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=on')
                when 'off'
                  @ff.checkbox(:name, 'create_hostname').clear
                  self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client undefined')
                end
              else
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'No Provide Host Name If Not Specified by Client key found')
              end
              ###
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->IP Address Distribution', 'IP Address Distribution undefined')
            end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', 'No IP Address Distribution key found')
        end     
        
        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Routing Mode', 'Routing Mode undefined')
          end
        end
        
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Device Metric', "Device Metric = "+info['Device Metric'])
        end
        
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Default Route', 'Default Route undefined')
          end
        end
        
        if info.key?('Multicast - IGMP Proxy Internal')
          case info['Multicast - IGMP Proxy Internal']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=on')
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal undefined')
          end
        end  
        
        # Internet Connection Firewall
        if info.key?('Internet Connection Firewall')
          case info['Internet Connection Firewall']
          when 'on'
            @ff.checkbox(:name, 'is_trusted').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Connection Firewall', 'Internet Connection Firewall=on')
          when 'off'
            @ff.checkbox(:name, 'is_trusted').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Connection Firewall', 'Internet Connection Firewall=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Internet Connection Firewall', 'Internet Connection Firewall undefined')
          end
        end  
        ###
      when 'DMZ'
        @ff.select_list(:id, 'network').select_value('4')
        self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Network', 'Network = '+info['Network'])
        
        # Begin: deal with Bridge setup --add by Robin at 2009/05/13
        if info.key?('Bridge_Ethernet')
          case info['Bridge_Ethernet']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Ethernet', 'Bridge_Ethernet undefined')
          end
        end
        if info.key?('Bridge_Ethernet_STP')
          case info['Bridge_Ethernet_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Ethernet_STP', 'Bridge_Ethernet_STP undefined')
          end
        end
        
        if info.key?('Bridge_Broadband Connection (Ethernet)')
          case info['Bridge_Broadband Connection (Ethernet)']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth1').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth1').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet) undefined')
          end
        end
        if info.key?('Bridge_Broadband Connection (Ethernet)_STP')
          case info['Bridge_Broadband Connection (Ethernet)_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_eth1_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_eth1_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Ethernet)_STP', 'Bridge_Broadband Connection (Ethernet)_STP undefined')
          end
        end
        
        if info.key?('Bridge_Coax')
          case info['Bridge_Coax']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Coax', 'Bridge_Coax undefined')
          end
        end
        if info.key?('Bridge_Coax_STP')
          case info['Bridge_Coax_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Coax_STP', 'Bridge_Coax_STP undefined')
          end
        end
        
        if info.key?('Bridge_Broadband Connection (Coax)')
          case info['Bridge_Broadband Connection (Coax)']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink1').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink1').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax) undefined')
          end
        end
        if info.key?('Bridge_Broadband Connection (Coax)_STP')
          case info['Bridge_Broadband Connection (Coax)_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_clink1_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_clink1_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Broadband Connection (Coax)_STP', 'Bridge_Broadband Connection (Coax)_STP undefined')
          end
        end
        
        if info.key?('Bridge_Wireless Access Point')
          case info['Bridge_Wireless Access Point']
          when 'on'
            @ff.checkbox(:name, 'enslave_ath0').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_ath0').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point undefined')
          end
        end
        if info.key?('Bridge_Wireless Access Point_STP')
          case info['Bridge_Wireless Access Point_STP']
          when 'on'
            @ff.checkbox(:name, 'enslave_ath0_stp').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP=on')
          when 'off'
            @ff.checkbox(:name, 'enslave_ath0_stp').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Bridge_Wireless Access Point_STP', 'Bridge_Wireless Access Point_STP undefined')
          end
        end
        # End: deal with Bridge setup --add by Robin at 2009/05/13
              
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->MTU', 'No MTU key found')
        end
        
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end             
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address', "IP Address = "+info['IP Address'])
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'static_netmask0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask']) 
            end         
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Address'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->DNS Server', 'No DNS Server key found')
        end
        
        # IP Address Distribution
        if info.key?('IP Address Distribution')
            case info['IP Address Distribution']
            when 'Disabled'
              @ff.select_list(:id, 'dhcp_mode').select_value('0')     
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Relay'
              @ff.select_list(:id, 'dhcp_mode').select_value('2')
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Server'
              @ff.select_list(:id, 'dhcp_mode').select_value('1')
              self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              if info.key?('Start IP Address') and info['Start IP Address'].size > 0
                octets=info['Start IP Address'].split('.')
                @ff.text_field(:name, 'start_ip0').value=(octets[0])
                @ff.text_field(:name, 'start_ip1').value=(octets[1])
                @ff.text_field(:name, 'start_ip2').value=(octets[2])
                @ff.text_field(:name, 'start_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
              end
              if info.key?('End IP Address') and info['End IP Address'].size > 0
                octets=info['End IP Address'].split('.')
                @ff.text_field(:name, 'end_ip0').value=(octets[0])
                @ff.text_field(:name, 'end_ip1').value=(octets[1])
                @ff.text_field(:name, 'end_ip2').value=(octets[2])
                @ff.text_field(:name, 'end_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->End IP Address', "End IP Address = "+info['End IP Address'])
              end
              if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
                octets=info['Subnet Mask'].split('.')
                @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
                @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
                @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
                @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
              end
              if info.key?('WINS Server') and info['WINS Server'].size > 0
                octets=info['WINS Server'].split('.')
                @ff.text_field(:name, 'wins0').value=(octets[0])
                @ff.text_field(:name, 'wins1').value=(octets[1])
                @ff.text_field(:name, 'wins2').value=(octets[2])
                @ff.text_field(:name, 'wins3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->WINS Server', "WINS Server = "+info['WINS Server'])
              end
              if info.key?('Lease Time in Minutes')
                @ff.text_field(:name, 'lease_time').value=(info['Lease Time in Minutes'])
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])
              else
                  self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Lease Time in Minutes', 'No Lease Time in Minutes key found')
              end
              if info.key?('Provide Host Name If Not Specified by Client')
                case info['Provide Host Name If Not Specified by Client']
                when 'on'
                  @ff.checkbox(:name, 'create_hostname').set
                  self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=on')
                when 'off'
                  @ff.checkbox(:name, 'create_hostname').clear
                  self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client undefined')
                end
              else
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Provide Host Name If Not Specified by Client', 'No Provide Host Name If Not Specified by Client key found')
              end
              ###
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->IP Address Distribution', 'IP Address Distribution undefined')
            end
        else
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IP Address Distribution', 'No IP Address Distribution key found')
        end     
        
        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Routing Mode', 'Routing Mode undefined')
          end
        end
        
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Device Metric', "Device Metric = "+info['Device Metric'])
        end
        
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Default Route', 'Default Route undefined')
          end
        end
        
        if info.key?('Multicast - IGMP Proxy Internal')
          case info['Multicast - IGMP Proxy Internal']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=on')
            if info.key?('IGMP Query Version')
              case info['IGMP Query Version']
              when 'IGMPv1'
                @ff.select_list(:id, 'igmp_version').select_value('1') 
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version='+info['IGMP Query Version'])
              when 'IGMPv2'
                @ff.select_list(:id, 'igmp_version').select_value('2')
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version='+info['IGMP Query Version'])
              when 'IGMPv3'
                @ff.select_list(:id, 'igmp_version').select_value('3')
                self.msg(rule_name, :info, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version='+info['IGMP Query Version'])
              else
                self.msg(rule_name, :error, 'DoSetup_LanEthernet()->IGMP Query Version', 'IGMP Query Version undefined')
              end
            else
              self.msg(rule_name, :error, 'DoSetup_LanEthernet()->IGMP Query Version', 'No IGMP Query Version key found')
            end
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal undefined')
          end
        end  
        ###
      else
        self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Network', 'Network undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_LanEthernet()->Network', 'No Network key found')
    end
    
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors") 
      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "DoSetup_LanEthernet()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'DoSetup_LanEthernet()->Apply', 'Network (Home/Office) Properties setup fault')
    else
      if @ff.contains_text("Attention") 
        errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo, "DoSetup_LanEthernet()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'DoSetup_LanEthernet()->Apply', 'Network (Home/Office) Properties setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'DoSetup_LanEthernet()->Apply', 'Network (Home/Office) Properties setup sucessful')
      end 
    end
  end
  
  def DoSetup_Ethernet(rule_name, info)
    if info.key?('action')
      case info['action']
      when 'set Internet Protocol'
        SetInternetProtocolMode_WanEthernet(rule_name, info)
      else
        self.msg(rule_name, :error, 'DoSetup_Ethernet()', 'action undefined')
      end
    else
      self.msg(rule_name, :error, 'DoSetup_Ethernet()', 'No action key found')
    end
  end
  
  def DoSetup_WirelessAccessPoint(rule_name, info)
    if info.key?('action')
      case info['action']
      when 'set Internet Protocol'
        SetInternetProtocolMode_WanEthernet(rule_name, info)
      else
        self.msg(rule_name, :error, 'DoSetup_WirelessAccessPoint()', 'action undefined')
      end
    else
      self.msg(rule_name, :error, 'DoSetup_WirelessAccessPoint()', 'No action key found')
    end
  end
  
  def DoSetup_Coax(rule_name, info)
    
    # Network
    if info.key?('Network')
      case info['Network']
      when 'Broadband Connection'
        @ff.select_list(:id, 'network').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Network', 'Network = '+info['Network']) 
        # only when network=Broadband Connection, we can set Internet Connection Firewall on/off
        if info.key?('Internet Connection Firewall')
          case info['Internet Connection Firewall']
          when 'on'
            @ff.checkbox(:name, 'is_trusted').set
            self.msg(rule_name, :info, 'DoSetup_Coax()->Internet Connection Firewall', 'Internet Connection Firewall=on')
          when 'off'
            @ff.checkbox(:name, 'is_trusted').clear
            self.msg(rule_name, :info, 'DoSetup_Coax()->Internet Connection Firewall', 'Internet Connection Firewall=off')
          else
            self.msg(rule_name, :error, 'DoSetup_Coax()->Internet Connection Firewall', 'Internet Connection Firewall undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_Coax()->Internet Connection Firewall', 'No Internet Connection Firewall key found')
        end
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'network').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Network', 'Network = '+info['Network'])
      when 'DMZ'
        @ff.select_list(:id, 'network').select_value('4')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Network', 'Network = '+info['Network'])
      else
        self.msg(rule_name, :error, 'DoSetup_Coax()->Network', 'Network undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_Coax()->Network', 'No Network key found')
    end
    
    # MTU
    if info.key?('MTU')
      case info['MTU']
      when 'Automatic'
        @ff.select_list(:id, 'mtu_mode').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_Coax()->MTU', 'MTU = '+info['MTU'])
      when 'Automatic by DHCP'
        @ff.select_list(:id, 'mtu_mode').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_Coax()->MTU', 'MTU = '+info['MTU'])
      when 'Manual'
        @ff.select_list(:id, 'mtu_mode').select_value('0')
        self.msg(rule_name, :info, 'DoSetup_Coax()->MTU', 'MTU = '+info['MTU'])
        if info.key?('MTU Value')  
          @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
          self.msg(rule_name, :info, 'DoSetup_Coax()->MTU Value', 'MTU Value= '+info['MTU Value'])
        else
          self.msg(rule_name, :error, 'DoSetup_Coax()->MTU Value', 'No MTU Value key found')
        end
      else
        self.msg(rule_name, :error, 'DoSetup_Coax()->MTU', 'MTU undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_Coax()->MTU', 'No MTU key found')
    end
    
    # Channel
    if info.key?('Channel')
      case info['Channel']
      when 'Automatic'
        @ff.select_list(:id, 'clink_channel').select_value('-1')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '1 - 1150MHz'
        @ff.select_list(:id, 'clink_channel').select_value('0')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '2 - 1200MHz'
        @ff.select_list(:id, 'clink_channel').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '3 - 1250MHz'
        @ff.select_list(:id, 'clink_channel').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '4 - 1300MHz'
        @ff.select_list(:id, 'clink_channel').select_value('3')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '5 - 1350MHz'
        @ff.select_list(:id, 'clink_channel').select_value('4')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '6 - 1400MHz'
        @ff.select_list(:id, 'clink_channel').select_value('5')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '7 - 1450MHz'
        @ff.select_list(:id, 'clink_channel').select_value('6')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      when '8 - 1500MHz'
        @ff.select_list(:id, 'clink_channel').select_value('7')
        self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'Channel = '+info['Channel'])
      else
        self.msg(rule_name, :error, 'DoSetup_Coax()->Channel', 'Channel undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_Coax()->Channel', 'No Channel key found')
    end
    
    # Privacy
    if info.key?('Privacy')
      case info['Privacy']
      when 'on'
        @ff.checkbox(:name, 'clink_privacy').set
        self.msg(rule_name, :info, 'DoSetup_Coax()->Privacy', 'Privacy=on')
      when 'off'
        @ff.checkbox(:name, 'clink_privacy').clear
        self.msg(rule_name, :info, 'DoSetup_Coax()->Privacy', 'Privacy=off')
      else
        self.msg(rule_name, :error, 'DoSetup_Coax()->Privacy', 'Privacy undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_Coax()->Privacy', 'No Privacy key found')
    end
    
    # Password
    if info.key?('Password')
      @ff.text_field(:name, 'clink_password').value=(info['Password'])
      self.msg(rule_name, :info, 'DoSetup_Coax()->Password', 'Password = '+info['Password'])
    else
      self.msg(rule_name, :info, 'DoSetup_Coax()->Password', 'No Password key found')
    end
    
    # CM Ratio
    if info.key?('CM Ratio')
      if info['CM Ratio'].to_i>=0 and info['CM Ratio'].to_i<=100
        @ff.select_list(:id, 'clink_cmratio').select_value(info['CM Ratio'])
        self.msg(rule_name, :info, 'DoSetup_Coax()->CM Ratio', 'CM Ratio = '+info['CM Ratio'])
      else
        self.msg(rule_name, :error, 'DoSetup_Coax()->CM Ratio', 'CM Ratio undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_Coax()->CM Ratio', 'No CM Ratio key found')
    end
    
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    sleep 15 
    @ff.refresh
    if  @ff.contains_text("Input Errors") 
      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "DoSetup_Coax()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'DoSetup_Coax()->Apply', 'Coax Properties setup fault')
    else
      if @ff.contains_text("Attention") 
        errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Attention, "DoSetup_Coax()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
	@ff.refresh
        self.msg(rule_name, :result_info, 'DoSetup_Coax()->Apply', 'Coax Properties setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'DoSetup_Coax()->Apply', 'Coax Properties setup sucessful')
      end 
    end

    # click 'Apply' button to complete setup again
  #  @ff.link(:text, 'Apply').click
  #  if  @ff.contains_text("Input Errors") 
  #    errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
  #    errorTable_rowcount=errorTable.row_count
  #    for i in 1..errorTable_rowcount-1
  #      self.msg(rule_name, :PageInfo_Error, "DoSetup_Coax()->Apply (#{i})", errorTable.[](i).text)    
  #    end 
  #    self.msg(rule_name, :error, 'DoSetup_Coax()->Apply', 'Coax Properties setup fault')
  #  else
  #    if @ff.contains_text("Attention") 
  #      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
  #      errorTable_rowcount=errorTable.row_count
  #      for i in 1..errorTable_rowcount-1
  #        self.msg(rule_name, :PageInfo_Attention, "DoSetup_Coax()->Apply (#{i})", errorTable.[](i).text)    
  #      end 
  #      @ff.link(:text, 'Apply').click
  #      self.msg(rule_name, :result_info, 'DoSetup_Coax()->Apply', 'Coax Properties setup sucessful with Attention')
  #    else
  #      self.msg(rule_name, :result_info, 'DoSetup_Coax()->Apply', 'Coax Properties setup sucessful')
  #    end 
  #  end
           
  end
  
  def DoSetup_WanEthernet(rule_name, info)
    #####
    if info.key?('Network')
      case info['Network']
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'network').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Network', 'Network = '+info['Network'])
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_WanEthernet()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'No MTU key found')
        end
        
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address', "IP Address = "+info['IP Address'])
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'static_netmask0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask']) 
            end  
            if info.key?('Default Gateway') and info['Default Gateway'].size > 0
              octets=info['Default Gateway'].split('.')
              @ff.text_field(:name, 'static_gateway0').value=(octets[0])
              @ff.text_field(:name, 'static_gateway1').value=(octets[1])
              @ff.text_field(:name, 'static_gateway2').value=(octets[2])
              @ff.text_field(:name, 'static_gateway3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Gateway', "Default Gateway = "+info['Default Gateway']) 
            end        
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Addresses'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', 'No DNS Server key found')
        end
        
        # IP Address Distribution
        if info.key?('IP Address Distribution')
            case info['IP Address Distribution']
            when 'Disabled'
              @ff.select_list(:id, 'dhcp_mode').select_value('0')     
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Relay'
              @ff.select_list(:id, 'dhcp_mode').select_value('2')
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Server'
              @ff.select_list(:id, 'dhcp_mode').select_value('1')
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              if info.key?('Start IP Address') and info['Start IP Address'].size > 0
                octets=info['Start IP Address'].split('.')
                @ff.text_field(:name, 'start_ip0').value=(octets[0])
                @ff.text_field(:name, 'start_ip1').value=(octets[1])
                @ff.text_field(:name, 'start_ip2').value=(octets[2])
                @ff.text_field(:name, 'start_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
              end
              if info.key?('End IP Address') and info['End IP Address'].size > 0
                octets=info['End IP Address'].split('.')
                @ff.text_field(:name, 'end_ip0').value=(octets[0])
                @ff.text_field(:name, 'end_ip1').value=(octets[1])
                @ff.text_field(:name, 'end_ip2').value=(octets[2])
                @ff.text_field(:name, 'end_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->End IP Address', "End IP Address = "+info['End IP Address'])
              end
              if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
                octets=info['Subnet Mask'].split('.')
                @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
                @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
                @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
                @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
              end
              if info.key?('WINS Server') and info['WINS Server'].size > 0
                octets=info['WINS Server'].split('.')
                @ff.text_field(:name, 'wins0').value=(octets[0])
                @ff.text_field(:name, 'wins1').value=(octets[1])
                @ff.text_field(:name, 'wins2').value=(octets[2])
                @ff.text_field(:name, 'wins3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->WINS Server', "WINS Server = "+info['WINS Server'])
              end
              if info.key?('Lease Time in Minutes')
                @ff.text_field(:name, 'lease_time').value=(info['Lease Time in Minutes'])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])
              else
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Lease Time in Minutes', 'No Lease Time in Minutes key found')
              end
              if info.key?('Provide Host Name If Not Specified by Client')
                case info['Provide Host Name If Not Specified by Client']
                when 'on'
                  @ff.checkbox(:name, 'create_hostname').set
                  self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=on')
                when 'off'
                  @ff.checkbox(:name, 'create_hostname').clear
                  self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client undefined')
                end
              else
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'No Provide Host Name If Not Specified by Client key found')
              end
            else
              self.msg(rule_name, :error, 'DoSetup_WanEthernet()->IP Address Distribution', 'IP Address Distribution undefined')
            end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', 'No IP Address Distribution key found')
        end    
 


        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Routing Mode', 'Routing Mode undefined')
          end
        end
        
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Device Metric', "Device Metric = "+info['Device Metric'])
        end
        
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Default Route', 'Default Route undefined')
          end
        end
        
        if info.key?('Multicast - IGMP Proxy Internal')
          case info['Multicast - IGMP Proxy Internal']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=on')
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal undefined')
          end
        end  
        ###
      when 'Broadband Connection'
        @ff.select_list(:id, 'network').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Network', 'Network = '+info['Network'])
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_WanEthernet()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'No MTU key found')
        end
        
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'No IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('0')     
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address', "IP Address = "+info['IP Address'])
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'static_netmask0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask']) 
            end  
            if info.key?('Default Gateway') and info['Default Gateway'].size > 0
              octets=info['Default Gateway'].split('.')
              @ff.text_field(:name, 'static_gateway0').value=(octets[0])
              @ff.text_field(:name, 'static_gateway1').value=(octets[1])
              @ff.text_field(:name, 'static_gateway2').value=(octets[2])
              @ff.text_field(:name, 'static_gateway3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Gateway', "Default Gateway = "+info['Default Gateway']) 
            end        
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Addresses'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', 'No DNS Server key found')
        end
        
        # IP Address Distribution
        if info.key?('IP Address Distribution')
            case info['IP Address Distribution']
            when 'Disabled'
              @ff.select_list(:id, 'dhcp_mode').select_value('0')     
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Relay'
              @ff.select_list(:id, 'dhcp_mode').select_value('2')
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Server'
              @ff.select_list(:id, 'dhcp_mode').select_value('1')
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              if info.key?('Start IP Address') and info['Start IP Address'].size > 0
                octets=info['Start IP Address'].split('.')
                @ff.text_field(:name, 'start_ip0').value=(octets[0])
                @ff.text_field(:name, 'start_ip1').value=(octets[1])
                @ff.text_field(:name, 'start_ip2').value=(octets[2])
                @ff.text_field(:name, 'start_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
              end
              if info.key?('End IP Address') and info['End IP Address'].size > 0
                octets=info['End IP Address'].split('.')
                @ff.text_field(:name, 'end_ip0').value=(octets[0])
                @ff.text_field(:name, 'end_ip1').value=(octets[1])
                @ff.text_field(:name, 'end_ip2').value=(octets[2])
                @ff.text_field(:name, 'end_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->End IP Address', "End IP Address = "+info['End IP Address'])
              end
              if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
                octets=info['Subnet Mask'].split('.')
                @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
                @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
                @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
                @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
              end
              if info.key?('WINS Server') and info['WINS Server'].size > 0
                octets=info['WINS Server'].split('.')
                @ff.text_field(:name, 'wins0').value=(octets[0])
                @ff.text_field(:name, 'wins1').value=(octets[1])
                @ff.text_field(:name, 'wins2').value=(octets[2])
                @ff.text_field(:name, 'wins3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->WINS Server', "WINS Server = "+info['WINS Server'])
              end
              if info.key?('Lease Time in Minutes')
                @ff.text_field(:name, 'lease_time').value=(info['Lease Time in Minutes'])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])
              else
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Lease Time in Minutes', 'No Lease Time in Minutes key found')
              end
              if info.key?('Provide Host Name If Not Specified by Client')
                case info['Provide Host Name If Not Specified by Client']
                when 'on'
                  @ff.checkbox(:name, 'create_hostname').set
                  self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=on')
                when 'off'
                  @ff.checkbox(:name, 'create_hostname').clear
                  self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client undefined')
                end
              else
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'No Provide Host Name If Not Specified by Client key found')
              end
            else
              self.msg(rule_name, :error, 'DoSetup_WanEthernet()->IP Address Distribution', 'IP Address Distribution undefined')
            end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', 'No IP Address Distribution key found')
        end 
    
       # Hugo add 05/11/2009
       # Deal with New IP Address for DHCP Relay
				if info.key?('DR New IP Address')
   				@ff.link(:href, 'javascript:mimic_button(\'dhcpr_add: eth1..\', 1)').click
					self.msg(rule_name, :info, 'DoSetup_WanEthernet()->New IP Address DHCP Replay', 'Click New IP Address DHCP Relay')
        	octets=info['DR New IP Address'].split('.')
        	@ff.text_field(:name, 'dhcpr_server0').value=(octets[0])
        	@ff.text_field(:name, 'dhcpr_server1').value=(octets[1])
        	@ff.text_field(:name, 'dhcpr_server2').value=(octets[2])
        	@ff.text_field(:name, 'dhcpr_server3').value=(octets[3])
        	@ff.link(:text,'Apply').click
					self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Set DHCP Relay Host IP Address', "New IP Address = "+info['DR New IP Address'])
       	end

        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          when 'NAPT'
            @ff.select_list(:id, 'route_level').select_value('4') 
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Routing Mode', 'Routing Mode undefined')
          end
        end
        
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Device Metric', "Device Metric = "+info['Device Metric'])
        end
        
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Default Route', 'Default Route undefined')
          end
        end
           	##############################	
    	# "New Route"
    	##############################	
      	if info.has_key?('Operation') then
      
	case info['Operation']
	  
	  when 'New route'
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
		
		if @ff.select_list(:name,'combo_device').include?(info['Name'])
			
		    @ff.select_list(:name,'combo_device').select(info['Name'])	
		    self.msg(rule_name,:info,'Name',info['Name'])
		else
		    self.msg(rule_name,:error,'Name','Can NOT find interface of configure \'Name\'.')
		end
            
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
			    #puts @ff.text_field(:name,row[7]).to_s
			    @ff.link(:href,row[7].link(:name,'route_remove').href).click
			    num += 1
			end
		    end	
		end # End of table;
		
		puts "There are #{num} route to be deleted"
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
 
        if info.key?('Multicast - IGMP Proxy Internal')
          case info['Multicast - IGMP Proxy Internal']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=on')
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal undefined')
          end
        end  
        
        # Internet Connection Firewall
        if info.key?('Internet Connection Firewall')
          case info['Internet Connection Firewall']
          when 'on'
            @ff.checkbox(:name, 'is_trusted').set
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Connection Firewall', 'Internet Connection Firewall=on')
          when 'off'
            @ff.checkbox(:name, 'is_trusted').clear
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Connection Firewall', 'Internet Connection Firewall=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Internet Connection Firewall', 'Internet Connection Firewall undefined')
          end
        end  
        ###
      when 'DMZ'
        @ff.select_list(:id, 'network').select_value('4')
        self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Network', 'Network = '+info['Network'])
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_WanEthernet()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->MTU', 'No MTU key found')
        end
        
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address', "IP Address = "+info['IP Address'])
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'static_netmask0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask']) 
            end  
            if info.key?('Default Gateway') and info['Default Gateway'].size > 0
              octets=info['Default Gateway'].split('.')
              @ff.text_field(:name, 'static_gateway0').value=(octets[0])
              @ff.text_field(:name, 'static_gateway1').value=(octets[1])
              @ff.text_field(:name, 'static_gateway2').value=(octets[2])
              @ff.text_field(:name, 'static_gateway3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Gateway', "Default Gateway = "+info['Default Gateway']) 
            end        
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Addresses'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->DNS Server', 'No DNS Server key found')
        end
        
        # IP Address Distribution
        if info.key?('IP Address Distribution')
            case info['IP Address Distribution']
            when 'Disabled'
              @ff.select_list(:id, 'dhcp_mode').select_value('0')     
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Relay'
              @ff.select_list(:id, 'dhcp_mode').select_value('2')
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Server'
              @ff.select_list(:id, 'dhcp_mode').select_value('1')
              self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              if info.key?('Start IP Address') and info['Start IP Address'].size > 0
                octets=info['Start IP Address'].split('.')
                @ff.text_field(:name, 'start_ip0').value=(octets[0])
                @ff.text_field(:name, 'start_ip1').value=(octets[1])
                @ff.text_field(:name, 'start_ip2').value=(octets[2])
                @ff.text_field(:name, 'start_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
              end
              if info.key?('End IP Address') and info['End IP Address'].size > 0
                octets=info['End IP Address'].split('.')
                @ff.text_field(:name, 'end_ip0').value=(octets[0])
                @ff.text_field(:name, 'end_ip1').value=(octets[1])
                @ff.text_field(:name, 'end_ip2').value=(octets[2])
                @ff.text_field(:name, 'end_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->End IP Address', "End IP Address = "+info['End IP Address'])
              end
              if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
                octets=info['Subnet Mask'].split('.')
                @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
                @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
                @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
                @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
              end
              if info.key?('WINS Server') and info['WINS Server'].size > 0
                octets=info['WINS Server'].split('.')
                @ff.text_field(:name, 'wins0').value=(octets[0])
                @ff.text_field(:name, 'wins1').value=(octets[1])
                @ff.text_field(:name, 'wins2').value=(octets[2])
                @ff.text_field(:name, 'wins3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->WINS Server', "WINS Server = "+info['WINS Server'])
              end
              if info.key?('Lease Time in Minutes')
                @ff.text_field(:name, 'lease_time').value=(info['Lease Time in Minutes'])
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])
              else
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Lease Time in Minutes', 'No Lease Time in Minutes key found')
              end
              if info.key?('Provide Host Name If Not Specified by Client')
                case info['Provide Host Name If Not Specified by Client']
                when 'on'
                  @ff.checkbox(:name, 'create_hostname').set
                  self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=on')
                when 'off'
                  @ff.checkbox(:name, 'create_hostname').clear
                  self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client undefined')
                end
              else
                self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Provide Host Name If Not Specified by Client', 'No Provide Host Name If Not Specified by Client key found')
              end
            else
              self.msg(rule_name, :error, 'DoSetup_WanEthernet()->IP Address Distribution', 'IP Address Distribution undefined')
            end
        else
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->IP Address Distribution', 'No IP Address Distribution key found')
        end     
        
        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          when 'NAPT'
            @ff.select_list(:id, 'route_level').select_value('4') 
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Routing Mode', 'Routing Mode undefined')
          end
        end
        
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Device Metric', "Device Metric = "+info['Device Metric'])
        end
        
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Default Route', 'Default Route undefined')
          end
        end
            	##############################	
    	# "New Route"
    	##############################	
      	if info.has_key?('Operation') then
      
	case info['Operation']
	  
	  when 'New route'
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
		
		if @ff.select_list(:name,'combo_device').include?(info['Name'])
			
		    @ff.select_list(:name,'combo_device').select(info['Name'])	
		    self.msg(rule_name,:info,'Name',info['Name'])
		else
		    self.msg(rule_name,:error,'Name','Can NOT find interface of configure \'Name\'.')
		end
            
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
			    #puts @ff.text_field(:name,row[7]).to_s
			    @ff.link(:href,row[7].link(:name,'route_remove').href).click
			    num += 1
			end
		    end	
		end # End of table;
		
		puts "There are #{num} route to be deleted"
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

        if info.key?('Multicast - IGMP Proxy Internal')
          case info['Multicast - IGMP Proxy Internal']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=on')
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal undefined')
          end
        end  
        ###
      else
        self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Network', 'Network undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_WanEthernet()->Network', 'No Network key found')
    end
    
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors")      
      #n=@ff.tables.length     
      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "DoSetup_WanEthernet()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'DoSetup_WanEthernet()->Apply', 'Broadband Connection (Ethernet) Properties setup fault')   
    else
      if @ff.contains_text("Attention") 
        errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Attention, "DoSetup_WanEthernet()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'DoSetup_WanEthernet()->Apply', 'Broadband Connection (Ethernet) Properties setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'DoSetup_WanEthernet()->Apply', 'Broadband Connection (Ethernet) Properties setup sucessful')
      end 
    end
    #####
  end
  
  def DoSetup_WanMoCA(rule_name, info)
    #####
    if info.key?('Network')
      case info['Network']
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'network').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Network', 'Network = '+info['Network'])
        ###
      when 'Broadband Connection'
        @ff.select_list(:id, 'network').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Network', 'Network = '+info['Network'])
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_WanMoCA()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanMoCA()->MTU', 'No MTU key found')
        end
        
        # Auto Detection/Privacy/Password
        if info.key?('Auto Detection')
          case info['Auto Detection']
          when 'on'
            @ff.radio(:id, 'coax1').set
            @ff.radio(:id, 'coax2').clear
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Auto Detection', 'Auto Detection=on')
          when 'off'
            @ff.radio(:id, 'coax2').set
            @ff.radio(:id, 'coax1').clear
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Auto Detection', 'Auto Detection=off')
            # Privacy
            if info.key?('Privacy')
              case info['Privacy']
              when 'on'
                @ff.checkbox(:name, 'clink_privacy').set
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Privacy', 'Privacy=on')
              when 'off'
                @ff.checkbox(:name, 'clink_privacy').clear
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Privacy', 'Privacy=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Privacy', 'Privacy undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Privacy', 'No Privacy key found')
            end
            # Password
            if info.key?('Password')
              @ff.text_field(:name, 'clink_password').value=(info['Password'])
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Password', "Password = "+info['Password'])
            else
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Password', 'No Password key found')
            end        
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Auto Detection', 'Auto Detection undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Auto Detection', 'No Auto Detection key found')
        end
        
        # CM Ratio
        if info.key?('CM Ratio')
          if info['CM Ratio'].to_i>=0 and info['CM Ratio'].to_i<=100
            @ff.select_list(:id, 'clink_cmratio').select_value(info['CM Ratio'])
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->CM Ratio', 'CM Ratio = '+info['CM Ratio'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->CM Ratio', 'CM Ratio undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanMoCA()->CM Ratio', 'No CM Ratio key found')
        end
        
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'No IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('0')     
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->IP Address', "IP Address = "+info['IP Address'])
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'static_netmask0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask']) 
            end  
            if info.key?('Default Gateway') and info['Default Gateway'].size > 0
              octets=info['Default Gateway'].split('.')
              @ff.text_field(:name, 'static_gateway0').value=(octets[0])
              @ff.text_field(:name, 'static_gateway1').value=(octets[1])
              @ff.text_field(:name, 'static_gateway2').value=(octets[2])
              @ff.text_field(:name, 'static_gateway3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Default Gateway', "Default Gateway = "+info['Default Gateway']) 
            end 
	  when 'NA'
	    ;
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Addresses'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanMoCA()->DNS Server', 'No DNS Server key found')
        end
        
        # IP Address Distribution
        if info.key?('IP Address Distribution')
            case info['IP Address Distribution']
            when 'Disabled'
              @ff.select_list(:id, 'dhcp_mode').select_value('0')     
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
            when 'DHCP Relay'
              @ff.select_list(:id, 'dhcp_mode').select_value('2')
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              
              # Sir: begin
              # Author: Sorrento
              # Date: 2009.04.28
              if info.key?("DR New IP Address")
                
                @ff.link(:href,'javascript:mimic_button(\'dhcpr_add: clink1..\', 1)').click
                
                octets=info['DR New IP Address'].split('.')
                @ff.text_field(:name, 'dhcpr_server0').value=(octets[0])
                @ff.text_field(:name, 'dhcpr_server1').value=(octets[1])
                @ff.text_field(:name, 'dhcpr_server2').value=(octets[2])
                @ff.text_field(:name, 'dhcpr_server3').value=(octets[3])
                
                @ff.link(:text,'Apply').click                
              end
              
              # Sir: end
              
            when 'DHCP Server'
              @ff.select_list(:id, 'dhcp_mode').select_value('1')
              self.msg(rule_name, :info, 'DoSetup_WanMoCA()->IP Address Distribution', "IP Address Distribution = "+info['IP Address Distribution'])
              if info.key?('Start IP Address') and info['Start IP Address'].size > 0
                octets=info['Start IP Address'].split('.')
                @ff.text_field(:name, 'start_ip0').value=(octets[0])
                @ff.text_field(:name, 'start_ip1').value=(octets[1])
                @ff.text_field(:name, 'start_ip2').value=(octets[2])
                @ff.text_field(:name, 'start_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
              end
              if info.key?('End IP Address') and info['End IP Address'].size > 0
                octets=info['End IP Address'].split('.')
                @ff.text_field(:name, 'end_ip0').value=(octets[0])
                @ff.text_field(:name, 'end_ip1').value=(octets[1])
                @ff.text_field(:name, 'end_ip2').value=(octets[2])
                @ff.text_field(:name, 'end_ip3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->End IP Address', "End IP Address = "+info['End IP Address'])
              end
              if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
                octets=info['Subnet Mask'].split('.')
                @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
                @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
                @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
                @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
              end
              if info.key?('WINS Server') and info['WINS Server'].size > 0
                octets=info['WINS Server'].split('.')
                @ff.text_field(:name, 'wins0').value=(octets[0])
                @ff.text_field(:name, 'wins1').value=(octets[1])
                @ff.text_field(:name, 'wins2').value=(octets[2])
                @ff.text_field(:name, 'wins3').value=(octets[3])
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->WINS Server', "WINS Server = "+info['WINS Server'])
              end
              if info.key?('Lease Time in Minutes')
                @ff.text_field(:name, 'lease_time').value=(info['Lease Time in Minutes'])
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Lease Time in Minutes', "Lease Time in Minutes = "+info['Lease Time in Minutes'])
              else
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Lease Time in Minutes', 'No Lease Time in Minutes key found')
              end
              if info.key?('Provide Host Name If Not Specified by Client')
                case info['Provide Host Name If Not Specified by Client']
                when 'on'
                  @ff.checkbox(:name, 'create_hostname').set
                  self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=on')
                when 'off'
                  @ff.checkbox(:name, 'create_hostname').clear
                  self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Provide Host Name If Not Specified by Client', 'Provide Host Name If Not Specified by Client undefined')
                end
              else
                self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Provide Host Name If Not Specified by Client', 'No Provide Host Name If Not Specified by Client key found')
              end
            else
              self.msg(rule_name, :error, 'DoSetup_WanMoCA()->IP Address Distribution', 'IP Address Distribution undefined')
            end
        else
          self.msg(rule_name, :info, 'DoSetup_WanMoCA()->IP Address Distribution', 'No IP Address Distribution key found')
        end     
        
        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          when 'NAPT'
            @ff.select_list(:id, 'route_level').select_value('4') 
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Routing Mode', 'Routing Mode undefined')
          end
        end
        
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Device Metric', "Device Metric = "+info['Device Metric'])
        end
        
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Default Route', 'Default Route undefined')
          end
        end
            	##############################	
    	# "New Route"
    	##############################	
      	if info.has_key?('Operation') then
      
	case info['Operation']
	  
	  when 'New route'
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
		
		if @ff.select_list(:name,'combo_device').include?(info['Name'])
			
		    @ff.select_list(:name,'combo_device').select(info['Name'])	
		    self.msg(rule_name,:info,'Name',info['Name'])
		else
		    self.msg(rule_name,:error,'Name','Can NOT find interface of configure \'Name\'.')
		end
            
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
			    #puts @ff.text_field(:name,row[7]).to_s
			    @ff.link(:href,row[7].link(:name,'route_remove').href).click
			    num += 1
			end
		    end	
		end # End of table;
		
		puts "There are #{num} route to be deleted"
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

        if info.key?('Multicast - IGMP Proxy Internal')
          case info['Multicast - IGMP Proxy Internal']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=on')
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Multicast - IGMP Proxy Internal', 'Multicast - IGMP Proxy Internal undefined')
          end
        end  
        
        # Internet Connection Firewall
        if info.key?('Internet Connection Firewall')
          case info['Internet Connection Firewall']
          when 'on'
            @ff.checkbox(:name, 'is_trusted').set
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Internet Connection Firewall', 'Internet Connection Firewall=on')
          when 'off'
            @ff.checkbox(:name, 'is_trusted').clear
            self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Internet Connection Firewall', 'Internet Connection Firewall=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Internet Connection Firewall', 'Internet Connection Firewall undefined')
          end
        end  
        ###
      when 'DMZ'
        @ff.select_list(:id, 'network').select_value('4')
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Network', 'Network = '+info['Network'])
        ###
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Network', 'Network undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Network', 'No Network key found')
    end
    
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors")      
      #n=@ff.tables.length
      # This is table 17 on the NCS firmware. Causes problems here. Could be globally fixed if the following was its own method instead of copy and pasted everywhere.
      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "DoSetup_WanMoCA()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Apply', 'Broadband Connection (Coax) Properties setup fault')   
    else
      if @ff.contains_text("Attention") 
        errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Attention, "DoSetup_WanMoCA()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'DoSetup_WanMoCA()->Apply', 'Broadband Connection (Coax) Properties setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'DoSetup_WanMoCA()->Apply', 'Broadband Connection (Coax) Properties setup sucessful')
      end 
    end
    #####
  end
  
  def DoSetup_WanPPPoE(rule_name, info)
    #####
    if info.key?('Network')
      case info['Network']
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'network').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Network', 'Network = '+info['Network'])
        ###
      when 'Broadband Connection'
        @ff.select_list(:id, 'network').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Network', 'Network = '+info['Network'])
        
        # special for Password Field part1
        mtu_mode_value=@ff.select_list(:id, 'mtu_mode').value
        @ff.select_list(:id, 'mtu_mode').select_value('1')
        
        # Login User Name
        if info.key?('Login User Name')
          @ff.text_field(:name, 'ppp_username').value=(info['Login User Name'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Login User Name', "Login User Name = "+info['Login User Name'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Login User Name', 'No Login User Name key found')
        end
        
        # Login Password
        if info.key?('Login Password')  
          if @ff.contains_text('Idle Time Before Hanging Up')
            @ff.text_field(:index, 5).value=(info['Login Password'])
          else
            @ff.text_field(:index, 4).value=(info['Login Password'])
          end         
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Login Password', "Login Password = "+info['Login Password'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Login Password', 'No Login Password key found')
        end
        
        # Retype Password
        if info.key?('Retype Password')  
          if @ff.contains_text('Idle Time Before Hanging Up')
            @ff.text_field(:index, 6).value=(info['Retype Password'])
          else
            @ff.text_field(:index, 5).value=(info['Retype Password'])
          end         
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Retype Password', "Retype Password = "+info['Retype Password'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Retype Password', 'No Retype Password key found')
        end
        
        # special for Password Field part2
        @ff.select_list(:id, 'mtu_mode').select_value(mtu_mode_value)
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->MTU', 'No MTU key found')
        end
        
        # Underlying Connection
        if info.key?('Underlying Connection')
          case info['Underlying Connection']
          when 'Network (Home/Office)'
            @ff.select_list(:id, 'depend_on_name').select_value('br0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Ethernet'
            @ff.select_list(:id, 'depend_on_name').select_value('eth0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Broadband Connection (Ethernet)'
            @ff.select_list(:id, 'depend_on_name').select_value('eth1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Coax'
            @ff.select_list(:id, 'depend_on_name').select_value('clink0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Broadband Connection (Coax)'
            @ff.select_list(:id, 'depend_on_name').select_value('clink1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Wireless Access Point'
            @ff.select_list(:id, 'depend_on_name').select_value('ath0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Underlying Connection', 'Underlying Connection undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Underlying Connection', 'No Underlying Connection key found')
        end
        
        # Service Name
        if info.key?('Service Name')
          @ff.text_field(:name, 'service_name').value=(info['Service Name'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Service Name', "Service Name = "+info['Service Name'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Service Name', 'No Service Name key found')
        end
        
        # On Demand        
        if info.key?('On Demand')
          case info['On Demand']
          when 'on'
            @ff.checkbox(:name, 'on_demand').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->On Demand', 'On Demand=on')
            # Idle Time Before Hanging Up
            if info.key?('Idle Time Before Hanging Up')
              @ff.text_field(:name, 'idle_time').value=(info['Idle Time Before Hanging Up'])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Idle Time Before Hanging Up', "Idle Time Before Hanging Up = "+info['Idle Time Before Hanging Up'])
            else
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Idle Time Before Hanging Up', 'No Idle Time Before Hanging Up key found')
            end
          when 'off'
            @ff.checkbox(:name, 'on_demand').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->On Demand', 'On Demand=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->On Demand', 'On Demand undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->On Demand', 'No On Demand key found')
        end
        
        # Time Between Reconnect Attempts
        if info.key?('Time Between Reconnect Attempts')
          @ff.text_field(:name, 'reconnect_time').value=(info['Time Between Reconnect Attempts'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Time Between Reconnect Attempts', "Time Between Reconnect Attempts = "+info['Time Between Reconnect Attempts'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Time Between Reconnect Attempts', 'No Time Between Reconnect Attempts key found')
        end
        
        # Support Unencrypted Password (PAP)
        if info.key?('Support Unencrypted Password (PAP)')
          case info['Support Unencrypted Password (PAP)']
          when 'on'
            @ff.checkbox(:name, 'auth_pap').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Unencrypted Password (PAP)', 'Support Unencrypted Password (PAP)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_pap').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Unencrypted Password (PAP)', 'Support Unencrypted Password (PAP)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Support Unencrypted Password (PAP)', 'Support Unencrypted Password (PAP) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Unencrypted Password (PAP)', 'No Support Unencrypted Password (PAP) key found')
        end
        
        # Support Challenge Handshake Authentication (CHAP)  
        if info.key?('Support Challenge Handshake Authentication (CHAP)')
          case info['Support Challenge Handshake Authentication (CHAP)']
          when 'on'
            @ff.checkbox(:name, 'auth_chap').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Challenge Handshake Authentication (CHAP)', 'Support Challenge Handshake Authentication (CHAP)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_chap').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Challenge Handshake Authentication (CHAP)', 'Support Challenge Handshake Authentication (CHAP)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Support Challenge Handshake Authentication (CHAP)', 'Support Challenge Handshake Authentication (CHAP) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Challenge Handshake Authentication (CHAP)', 'No Support Challenge Handshake Authentication (CHAP) key found')
        end
        
        # Support Microsoft CHAP (MS-CHAP)  
        if info.key?('Support Microsoft CHAP (MS-CHAP)')
          case info['Support Microsoft CHAP (MS-CHAP)']
          when 'on'
            @ff.checkbox(:name, 'auth_mschapv1').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Microsoft CHAP (MS-CHAP)', 'Support Microsoft CHAP (MS-CHAP)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_mschapv1').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Microsoft CHAP (MS-CHAP)', 'Support Microsoft CHAP (MS-CHAP)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Support Microsoft CHAP (MS-CHAP)', 'Support Microsoft CHAP (MS-CHAP) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Microsoft CHAP (MS-CHAP)', 'No Support Microsoft CHAP (MS-CHAP) key found')
        end
        
        # Support Microsoft CHAP Version 2 (MS-CHAP v2) 
        if info.key?('Support Microsoft CHAP Version 2 (MS-CHAP v2)')
          case info['Support Microsoft CHAP Version 2 (MS-CHAP v2)']
          when 'on'
            @ff.checkbox(:name, 'auth_mschapv2').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'Support Microsoft CHAP Version 2 (MS-CHAP v2)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_mschapv2').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'Support Microsoft CHAP Version 2 (MS-CHAP v2)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'Support Microsoft CHAP Version 2 (MS-CHAP v2) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'No Support Microsoft CHAP Version 2 (MS-CHAP v2) key found')
        end
        
        # BSD 
        if info.key?('BSD')
          case info['BSD']
          when 'Reject'
            @ff.select_list(:id, 'comp_bsd').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->BSD', "BSD = "+info['BSD'])
          when 'Allow'
            @ff.select_list(:id, 'comp_bsd').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->BSD', "BSD = "+info['BSD'])
          when 'Require'
            @ff.select_list(:id, 'comp_bsd').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->BSD', "BSD = "+info['BSD'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->BSD', 'BSD undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->BSD', 'No BSD key found')
        end
        
        # Deflate 
        if info.key?('Deflate')
          case info['Deflate']
          when 'Reject'
            @ff.select_list(:id, 'comp_deflate').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Deflate', "Deflate = "+info['Deflate'])
          when 'Allow'
            @ff.select_list(:id, 'comp_deflate').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Deflate', "Deflate = "+info['Deflate'])
          when 'Require'
            @ff.select_list(:id, 'comp_deflate').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Deflate', "Deflate = "+info['Deflate'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Deflate', 'Deflate undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Deflate', 'No Deflate key found')
        end   
               
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end             
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->IP Address', "IP Address = "+info['IP Address'])
            end
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end             
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Addresses'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->DNS Server', 'No DNS Server key found')
        end

        # Routing Mode
        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          when 'NAPT'
            @ff.select_list(:id, 'route_level').select_value('4') 
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Routing Mode', 'Routing Mode undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Routing Mode', 'No Routing Mode key found')
        end
        
        # Device Metric
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Device Metric', "Device Metric = "+info['Device Metric'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Device Metric', 'No Device Metric key found')        
        end
        
        # Default Route
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Default Route', 'Default Route undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Default Route', 'No Default Route key found')     
        end
        
        # Multicast - IGMP Proxy Default
        if info.key?('Multicast - IGMP Proxy Default')
          case info['Multicast - IGMP Proxy Default']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Multicast - IGMP Proxy Default', 'Multicast - IGMP Proxy Default=on')
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Multicast - IGMP Proxy Default', 'Multicast - IGMP Proxy Default=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Multicast - IGMP Proxy Default', 'Multicast - IGMP Proxy Default undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Multicast - IGMP Proxy Default', 'No Multicast - IGMP Proxy Default key found')     
        end  
        
        # Internet Connection Firewall
        if info.key?('Internet Connection Firewall')
          case info['Internet Connection Firewall']
          when 'on'
            @ff.checkbox(:name, 'is_trusted').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Internet Connection Firewall', 'Internet Connection Firewall=on')
          when 'off'
            @ff.checkbox(:name, 'is_trusted').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Internet Connection Firewall', 'Internet Connection Firewall=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Internet Connection Firewall', 'Internet Connection Firewall undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Internet Connection Firewall', 'No Internet Connection Firewall key found')   
        end  
        ###
      when 'DMZ'
        @ff.select_list(:id, 'network').select_value('4')
        self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Network', 'Network = '+info['Network'])
        ###
      else
        self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Network', 'Network undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_WanPPPoE()->Network', 'No Network key found')
    end
    
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors") 
      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "DoSetup_WanPPPoE()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'DoSetup_WanPPPoE()->Apply', 'WAN PPPoE Properties setup fault')
    else
      if @ff.contains_text("Attention") 
        errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Error, "DoSetup_WanPPPoE()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'DoSetup_WanPPPoE()->Apply', 'WAN PPPoE Properties setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'DoSetup_WanPPPoE()->Apply', 'WAN PPPoE Properties setup sucessful')
      end 
    end
    #####
  end
  
  def DoSetup_WanPPPoE2(rule_name, info)
    #####
    if info.key?('Network')
      case info['Network']
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'network').select_value('2')
        self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Network', 'Network = '+info['Network'])
        ###
      when 'Broadband Connection'
        @ff.select_list(:id, 'network').select_value('1')
        self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Network', 'Network = '+info['Network'])
        
        # special for Password Field part1
        mtu_mode_value=@ff.select_list(:id, 'mtu_mode').value
        @ff.select_list(:id, 'mtu_mode').select_value('1')
        
        # Login User Name
        if info.key?('Login User Name')
          @ff.text_field(:name, 'ppp_username').value=(info['Login User Name'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Login User Name', "Login User Name = "+info['Login User Name'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Login User Name', 'No Login User Name key found')
        end
        
        # Login Password
        if info.key?('Login Password')  
          if @ff.contains_text('Idle Time Before Hanging Up')
            @ff.text_field(:index, 5).value=(info['Login Password'])
          else
            @ff.text_field(:index, 4).value=(info['Login Password'])
          end         
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Login Password', "Login Password = "+info['Login Password'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Login Password', 'No Login Password key found')
        end
        
        # Retype Password
        if info.key?('Retype Password')  
          if @ff.contains_text('Idle Time Before Hanging Up')
            @ff.text_field(:index, 6).value=(info['Retype Password'])
          else
            @ff.text_field(:index, 5).value=(info['Retype Password'])
          end         
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Retype Password', "Retype Password = "+info['Retype Password'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Retype Password', 'No Retype Password key found')
        end
        
        # special for Password Field part2
        @ff.select_list(:id, 'mtu_mode').select_value(mtu_mode_value)
        
        # MTU
        if info.key?('MTU')
          case info['MTU']
          when 'Automatic'
            @ff.select_list(:id, 'mtu_mode').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->MTU', 'MTU = '+info['MTU'])
          when 'Automatic by DHCP'
            @ff.select_list(:id, 'mtu_mode').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->MTU', 'MTU = '+info['MTU'])
          when 'Manual'
            @ff.select_list(:id, 'mtu_mode').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->MTU', 'MTU = '+info['MTU'])
            if info.key?('MTU Value')  
              @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->MTU Value', 'MTU Value= '+info['MTU Value'])
            else
              self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->MTU Value', 'No MTU Value key found')
            end
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->MTU', 'MTU undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->MTU', 'No MTU key found')
        end
        
        # Underlying Connection
        if info.key?('Underlying Connection')
          case info['Underlying Connection']
          when 'Network (Home/Office)'
            @ff.select_list(:id, 'depend_on_name').select_value('br0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Ethernet'
            @ff.select_list(:id, 'depend_on_name').select_value('eth0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Broadband Connection (Ethernet)'
            @ff.select_list(:id, 'depend_on_name').select_value('eth1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Coax'
            @ff.select_list(:id, 'depend_on_name').select_value('clink0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Broadband Connection (Coax)'
            @ff.select_list(:id, 'depend_on_name').select_value('clink1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          when 'Wireless Access Point'
            @ff.select_list(:id, 'depend_on_name').select_value('ath0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Underlying Connection', 'Underlying Connection = '+info['Underlying Connection'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Underlying Connection', 'Underlying Connection undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Underlying Connection', 'No Underlying Connection key found')
        end
        
        # Service Name
        if info.key?('Service Name')
          @ff.text_field(:name, 'service_name').value=(info['Service Name'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Service Name', "Service Name = "+info['Service Name'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Service Name', 'No Service Name key found')
        end
        
        # On Demand        
        if info.key?('On Demand')
          case info['On Demand']
          when 'on'
            @ff.checkbox(:name, 'on_demand').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->On Demand', 'On Demand=on')
            # Idle Time Before Hanging Up
            if info.key?('Idle Time Before Hanging Up')
              @ff.text_field(:name, 'idle_time').value=(info['Idle Time Before Hanging Up'])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Idle Time Before Hanging Up', "Idle Time Before Hanging Up = "+info['Idle Time Before Hanging Up'])
            else
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Idle Time Before Hanging Up', 'No Idle Time Before Hanging Up key found')
            end
          when 'off'
            @ff.checkbox(:name, 'on_demand').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->On Demand', 'On Demand=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->On Demand', 'On Demand undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->On Demand', 'No On Demand key found')
        end
        
        # Time Between Reconnect Attempts
        if info.key?('Time Between Reconnect Attempts')
          @ff.text_field(:name, 'reconnect_time').value=(info['Time Between Reconnect Attempts'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Time Between Reconnect Attempts', "Time Between Reconnect Attempts = "+info['Time Between Reconnect Attempts'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Time Between Reconnect Attempts', 'No Time Between Reconnect Attempts key found')
        end
        
        # Support Unencrypted Password (PAP)
        if info.key?('Support Unencrypted Password (PAP)')
          case info['Support Unencrypted Password (PAP)']
          when 'on'
            @ff.checkbox(:name, 'auth_pap').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Unencrypted Password (PAP)', 'Support Unencrypted Password (PAP)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_pap').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Unencrypted Password (PAP)', 'Support Unencrypted Password (PAP)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Support Unencrypted Password (PAP)', 'Support Unencrypted Password (PAP) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Unencrypted Password (PAP)', 'No Support Unencrypted Password (PAP) key found')
        end
        
        # Support Challenge Handshake Authentication (CHAP)  
        if info.key?('Support Challenge Handshake Authentication (CHAP)')
          case info['Support Challenge Handshake Authentication (CHAP)']
          when 'on'
            @ff.checkbox(:name, 'auth_chap').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Challenge Handshake Authentication (CHAP)', 'Support Challenge Handshake Authentication (CHAP)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_chap').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Challenge Handshake Authentication (CHAP)', 'Support Challenge Handshake Authentication (CHAP)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Support Challenge Handshake Authentication (CHAP)', 'Support Challenge Handshake Authentication (CHAP) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Challenge Handshake Authentication (CHAP)', 'No Support Challenge Handshake Authentication (CHAP) key found')
        end
        
        # Support Microsoft CHAP (MS-CHAP)  
        if info.key?('Support Microsoft CHAP (MS-CHAP)')
          case info['Support Microsoft CHAP (MS-CHAP)']
          when 'on'
            @ff.checkbox(:name, 'auth_mschapv1').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP (MS-CHAP)', 'Support Microsoft CHAP (MS-CHAP)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_mschapv1').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP (MS-CHAP)', 'Support Microsoft CHAP (MS-CHAP)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP (MS-CHAP)', 'Support Microsoft CHAP (MS-CHAP) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP (MS-CHAP)', 'No Support Microsoft CHAP (MS-CHAP) key found')
        end
        
        # Support Microsoft CHAP Version 2 (MS-CHAP v2) 
        if info.key?('Support Microsoft CHAP Version 2 (MS-CHAP v2)')
          case info['Support Microsoft CHAP Version 2 (MS-CHAP v2)']
          when 'on'
            @ff.checkbox(:name, 'auth_mschapv2').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'Support Microsoft CHAP Version 2 (MS-CHAP v2)=on')
          when 'off'
            @ff.checkbox(:name, 'auth_mschapv2').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'Support Microsoft CHAP Version 2 (MS-CHAP v2)=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'Support Microsoft CHAP Version 2 (MS-CHAP v2) undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Support Microsoft CHAP Version 2 (MS-CHAP v2)', 'No Support Microsoft CHAP Version 2 (MS-CHAP v2) key found')
        end
        
        # BSD 
        if info.key?('BSD')
          case info['BSD']
          when 'Reject'
            @ff.select_list(:id, 'comp_bsd').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->BSD', "BSD = "+info['BSD'])
          when 'Allow'
            @ff.select_list(:id, 'comp_bsd').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->BSD', "BSD = "+info['BSD'])
          when 'Require'
            @ff.select_list(:id, 'comp_bsd').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->BSD', "BSD = "+info['BSD'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->BSD', 'BSD undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->BSD', 'No BSD key found')
        end
        
        # Deflate 
        if info.key?('Deflate')
          case info['Deflate']
          when 'Reject'
            @ff.select_list(:id, 'comp_deflate').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Deflate', "Deflate = "+info['Deflate'])
          when 'Allow'
            @ff.select_list(:id, 'comp_deflate').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Deflate', "Deflate = "+info['Deflate'])
          when 'Require'
            @ff.select_list(:id, 'comp_deflate').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Deflate', "Deflate = "+info['Deflate'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Deflate', 'Deflate undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Deflate', 'No Deflate key found')
        end   
               
        # Internet Protocol
        if info.key?('Internet Protocol')
          case info['Internet Protocol']
          when 'Obtain an IP Address Automatically'
            @ff.select_list(:id, 'ip_settings').select_value('2')     
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Internet Protocol', "Internet Protocol = "+info['Internet Protocol'])
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end             
          when 'Use the Following IP Address'
            @ff.select_list(:id, 'ip_settings').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Internet Protocol', "IP Address Distribution = "+info['Internet Protocol'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'static_ip0').value=(octets[0])
              @ff.text_field(:name, 'static_ip1').value=(octets[1])
              @ff.text_field(:name, 'static_ip2').value=(octets[2])
              @ff.text_field(:name, 'static_ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->IP Address', "IP Address = "+info['IP Address'])
            end
            # Override Subnet Mask
            if info.key?('Override Subnet Mask')
              case info['Override Subnet Mask']
              when 'on'
                @ff.checkbox(:name, 'override_subnet_mask').set
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'Override Subnet Mask=on')
              when 'off'
                @ff.checkbox(:name, 'override_subnet_mask').clear
                self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'Override Subnet Mask=off')
              else
                self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'Override Subnet Mask undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask', 'No Override Subnet Mask key found')
            end
            # Override Subnet Mask Address
            if info.key?('Override Subnet Mask Address') and info['Override Subnet Mask Address'].size > 0
              octets=info['Override Subnet Mask Address'].split('.')
              @ff.text_field(:name, 'static_netmask_override0').value=(octets[0])
              @ff.text_field(:name, 'static_netmask_override1').value=(octets[1])
              @ff.text_field(:name, 'static_netmask_override2').value=(octets[2])
              @ff.text_field(:name, 'static_netmask_override3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Override Subnet Mask Address', "Override Subnet Mask Address = "+info['Override Subnet Mask Address'])
            end             
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Internet Protocol', 'Internet Protocol undefined')
          end
        else
          self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Internet Protocol', 'No Internet Protocol key found')
        end
        
        # DNS Server
        if info.key?('DNS Server')
          case info['DNS Server']
          when 'Use the Following DNS Server Addresses'
            @ff.select_list(:id, 'dns_option').select_value('0')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->DNS Server', "DNS Server = "+info['DNS Server'])
            if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
               octets=info['Primary DNS Server'].split('.')
               @ff.text_field(:name, 'primary_dns0').value=(octets[0])
               @ff.text_field(:name, 'primary_dns1').value=(octets[1])
               @ff.text_field(:name, 'primary_dns2').value=(octets[2])
               @ff.text_field(:name, 'primary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
            end
            if info.key?('Secondary DNS Server') and info['Secondary DNS Server'].size > 0
               octets=info['Secondary DNS Server'].split('.')
               @ff.text_field(:name, 'secondary_dns0').value=(octets[0])
               @ff.text_field(:name, 'secondary_dns1').value=(octets[1])
               @ff.text_field(:name, 'secondary_dns2').value=(octets[2])
               @ff.text_field(:name, 'secondary_dns3').value=(octets[3])
               self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Secondary DNS Server', "Secondary DNS Server = "+info['Secondary DNS Server'])
            end
          when 'Obtain DNS Server Address Automatically'
            @ff.select_list(:id, 'dns_option').select_value('1')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->DNS Server', "DNS Server = "+info['DNS Server'])
          when 'No DNS Server'
            @ff.select_list(:id, 'dns_option').select_value('2')
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->DNS Server', "DNS Server = "+info['DNS Server'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->DNS Server', 'DNS Server undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->DNS Server', 'No DNS Server key found')
        end

        # Routing Mode
        if info.key?('Routing Mode')
          case info['Routing Mode']
          when 'Route'
            @ff.select_list(:id, 'route_level').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          when 'NAPT'
            @ff.select_list(:id, 'route_level').select_value('4') 
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Routing Mode', "Routing Mode = "+info['Routing Mode'])
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Routing Mode', 'Routing Mode undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Routing Mode', 'No Routing Mode key found')
        end
        
        # Device Metric
        if info.key?('Device Metric')
          @ff.text_field(:name, 'route_metric').value=(info['Device Metric'])
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Device Metric', "Device Metric = "+info['Device Metric'])
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Device Metric', 'No Device Metric key found')        
        end
        
        # Default Route
        if info.key?('Default Route')
          case info['Default Route']
          when 'on'
            @ff.checkbox(:name, 'default_route').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Default Route', 'Default Route=on')
          when 'off'
            @ff.checkbox(:name, 'default_route').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Default Route', 'Default Route=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Default Route', 'Default Route undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Default Route', 'No Default Route key found')     
        end
        
        # Multicast - IGMP Proxy Default
        if info.key?('Multicast - IGMP Proxy Default')
          case info['Multicast - IGMP Proxy Default']
          when 'on'
            @ff.checkbox(:name, 'is_igmp_enabled').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Multicast - IGMP Proxy Default', 'Multicast - IGMP Proxy Default=on')
          when 'off'
            @ff.checkbox(:name, 'is_igmp_enabled').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Multicast - IGMP Proxy Default', 'Multicast - IGMP Proxy Default=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Multicast - IGMP Proxy Default', 'Multicast - IGMP Proxy Default undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Multicast - IGMP Proxy Default', 'No Multicast - IGMP Proxy Default key found')     
        end  
        
        # Internet Connection Firewall
        if info.key?('Internet Connection Firewall')
          case info['Internet Connection Firewall']
          when 'on'
            @ff.checkbox(:name, 'is_trusted').set
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Internet Connection Firewall', 'Internet Connection Firewall=on')
          when 'off'
            @ff.checkbox(:name, 'is_trusted').clear
            self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Internet Connection Firewall', 'Internet Connection Firewall=off')           
          else
            self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Internet Connection Firewall', 'Internet Connection Firewall undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Internet Connection Firewall', 'No Internet Connection Firewall key found')   
        end  
        ###
      when 'DMZ'
        @ff.select_list(:id, 'network').select_value('4')
        self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Network', 'Network = '+info['Network'])
        ###
      else
        self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Network', 'Network undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_WanPPPoE2()->Network', 'No Network key found')
    end
    
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors") 
      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "DoSetup_WanPPPoE2()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'DoSetup_WanPPPoE2()->Apply', 'WAN PPPoE Properties setup fault')
    else
      if @ff.contains_text("Attention") 
        errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Error, "DoSetup_WanPPPoE2()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'DoSetup_WanPPPoE2()->Apply', 'WAN PPPoE Properties setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'DoSetup_WanPPPoE2()->Apply', 'WAN PPPoE Properties setup sucessful')
      end 
    end
    #####
  end
  
  def RouteSetting_LanEthernet(rule_name, info)
    begin
      #@ff.link(:href, 'javascript:mimic_button(\'add: 0_..\', 1)').click
      @ff.link(:href, 'javascript:mimic_button(\'route_add: ...\', 1)').click
    rescue
      self.msg(rule_name, :error, 'RouteSetting_LanEthernet()', 'Did not reach Route Settings page')
      return
    end    
    # Name(Route Settings)
    if info.key?('Name(Route Settings)')
      case info['Name(Route Settings)']
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'combo_device').select_value('br0') 
        self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Name(Route Settings)', "Name(Route Settings) = "+info['Name(Route Settings)'])
      when 'Broadband Connection (Ethernet)'
        @ff.select_list(:id, 'combo_device').select_value('eth1') 
        self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Name(Route Settings)', "Name(Route Settings) = "+info['Name(Route Settings)'])
      when 'Broadband Connection (Coax)'
        @ff.select_list(:id, 'combo_device').select_value('clink1') 
        self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Name(Route Settings)', "Name(Route Settings) = "+info['Name(Route Settings)'])
      when 'WAN PPPoE'
        @ff.select_list(:id, 'combo_device').select_value('ppp0') 
        self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Name(Route Settings)', "Name(Route Settings) = "+info['Name(Route Settings)'])
      when 'WAN PPPoE 2'
        @ff.select_list(:id, 'combo_device').select_value('ppp1') 
        self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Name(Route Settings)', "Name(Route Settings) = "+info['Name(Route Settings)'])
      else
        self.msg(rule_name, :error, 'RouteSetting_LanEthernet()->Name(Route Settings)', 'Name(Route Settings) undefined')
      end
    else
      self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Name(Route Settings)', 'No Name(Route Settings) key found')
    end
    
    # Destination(Route Settings)
    if info.key?('Destination(Route Settings)') and info['Destination(Route Settings)'].size > 0
       octets=info['Destination(Route Settings)'].split('.')
       @ff.text_field(:name, 'dest0').value=(octets[0])
       @ff.text_field(:name, 'dest1').value=(octets[1])
       @ff.text_field(:name, 'dest2').value=(octets[2])
       @ff.text_field(:name, 'dest3').value=(octets[3])
       self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Destination(Route Settings)', "Destination(Route Settings) = "+info['Destination(Route Settings)'])
    else
      self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Name(Route Settings)', 'No Name(Route Settings) key found')
    end
    
    # Netmask(Route Settings)
    if info.key?('Netmask(Route Settings)') and info['Netmask(Route Settings)'].size > 0
       octets=info['Netmask(Route Settings)'].split('.')
       @ff.text_field(:name, 'netmask0').value=(octets[0])
       @ff.text_field(:name, 'netmask1').value=(octets[1])
       @ff.text_field(:name, 'netmask2').value=(octets[2])
       @ff.text_field(:name, 'netmask3').value=(octets[3])
       self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Netmask(Route Settings)', "Netmask(Route Settings) = "+info['Netmask(Route Settings)'])
    else
      self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Netmask(Route Settings)', 'No Netmask(Route Settings) key found')
    end
    
    # Gateway(Route Settings)
    if info.key?('Gateway(Route Settings)') and info['Gateway(Route Settings)'].size > 0
       octets=info['Gateway(Route Settings)'].split('.')
       @ff.text_field(:name, 'gateway0').value=(octets[0])
       @ff.text_field(:name, 'gateway1').value=(octets[1])
       @ff.text_field(:name, 'gateway2').value=(octets[2])
       @ff.text_field(:name, 'gateway3').value=(octets[3])
       self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Gateway(Route Settings)', "Gateway(Route Settings) = "+info['Gateway(Route Settings)'])
    else
      self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Gateway(Route Settings)', 'No Gateway(Route Settings) key found')
    end
    
    # Metric(Route Settings)
    if info.key?('Metric(Route Settings)')  
      @ff.text_field(:name, 'metric').value=info['Metric(Route Settings)']
      self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Metric(Route Settings)', 'Metric(Route Settings)= '+info['Metric(Route Settings)'])
    else
      self.msg(rule_name, :info, 'RouteSetting_LanEthernet()->Metric(Route Settings)', 'No Metric(Route Settings) key found')
    end
    
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors")      
      #n=@ff.tables.length     
      errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "RouteSetting_LanEthernet()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'RouteSetting_LanEthernet()->Apply', 'Route setup fault')   
    else
      if @ff.contains_text("Attention") 
        errorTable = @ff.tables[18].row_count < 2 ? @ff.tables[17] : @ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Attention, "RouteSetting_LanEthernet()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'RouteSetting_LanEthernet()->Apply', 'RouteRoute setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'RouteSetting_LanEthernet()->Apply', 'Route setup sucessful')
      end 
    end
    
  end
  
  def SetDHCP_LanEthernet(rule_name, info)
    if info.key?('IP Address Distribution')
      case info['IP Address Distribution']
      when 'Disabled'
        @ff.select_list(:id, 'dhcp_mode').select_value('0')     
        @ff.link(:text, 'Apply').click
        #click 'Apply' butten in Attention for No DNS Servers Page
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :info, 'SetDHCP()', "IP Address Distribution = Disabled")
      when 'DHCP Relay'
        @ff.select_list(:id, 'dhcp_mode').select_value('2')
        @ff.link(:text, 'Apply').click
        #click 'Apply' butten in Attention for No DNS Servers Page
        sleep 2
        @ff.link(:text, 'Apply').click
        sleep 2
        self.msg(rule_name, :info, 'SetDHCP()', "IP Address Distribution = DHCP Relay")
      when 'DHCP Server'
        @ff.select_list(:id, 'dhcp_mode').select_value('1')
        if info.key?('Start IP Address') and info['Start IP Address'].size > 0
          octets=info['Start IP Address'].split('.')
          @ff.text_field(:name, 'start_ip0').value=(octets[0])
          @ff.text_field(:name, 'start_ip1').value=(octets[1])
          @ff.text_field(:name, 'start_ip2').value=(octets[2])
          @ff.text_field(:name, 'start_ip3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetDHCP()->Start IP Address', "Start IP Address = "+info['Start IP Address'])
        if info.key?('End IP Address') and info['End IP Address'].size > 0
          octets=info['End IP Address'].split('.')
          @ff.text_field(:name, 'end_ip0').value=(octets[0])
          @ff.text_field(:name, 'end_ip1').value=(octets[1])
          @ff.text_field(:name, 'end_ip2').value=(octets[2])
          @ff.text_field(:name, 'end_ip3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetDHCP()->End IP Address', "End IP Address = "+info['End IP Address'])
        if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
          octets=info['Subnet Mask'].split('.')
          @ff.text_field(:name, 'dhcp_netmask0').value=(octets[0])
          @ff.text_field(:name, 'dhcp_netmask1').value=(octets[1])
          @ff.text_field(:name, 'dhcp_netmask2').value=(octets[2])
          @ff.text_field(:name, 'dhcp_netmask3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetDHCP()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
        @ff.link(:text, 'Apply').click
        #click 'Apply' butten in Attention for No DNS Servers Page
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :info, 'SetDHCP()', "IP Address Distribution = DHCP Server")
      else
        self.msg(rule_name, :error, 'SetDHCP()', 'IP Address Distribution undefined')
      end
    else
      self.msg(rule_name, :error, 'SetDHCP()', 'No IP Address Distribution key found')
    end
  end
  
  def SetInternetProtocolMode_WanEthernet(rule_name, info)
    if info.key?('Internet Protocol')
      case info['Internet Protocol']
      when 'Obtain an IP Address Automatically'
        @ff.select_list(:id, 'ip_settings').select_value('2')     
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :info, 'SetInternetProtocolMode()->Internet Protocol', "Internet Protocol = Obtain an IP Address Automatically")
      when 'Use the Following IP Address'
        @ff.select_list(:id, 'ip_settings').select_value('1')
        if info.key?('IP Address') and info['IP Address'].size > 0
          octets=info['IP Address'].split('.')
          @ff.text_field(:name, 'static_ip0').value=(octets[0])
          @ff.text_field(:name, 'static_ip1').value=(octets[1])
          @ff.text_field(:name, 'static_ip2').value=(octets[2])
          @ff.text_field(:name, 'static_ip3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode()->IP Address', "IP Address = "+info['IP Address'])
        if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
          octets=info['Subnet Mask'].split('.')
          @ff.text_field(:name, 'static_netmask0').value=(octets[0])
          @ff.text_field(:name, 'static_netmask1').value=(octets[1])
          @ff.text_field(:name, 'static_netmask2').value=(octets[2])
          @ff.text_field(:name, 'static_netmask3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
        if info.key?('Default Gateway') and info['Default Gateway'].size > 0
          octets=info['Default Gateway'].split('.')
          @ff.text_field(:name, 'static_gateway0').value=(octets[0])
          @ff.text_field(:name, 'static_gateway1').value=(octets[1])
          @ff.text_field(:name, 'static_gateway2').value=(octets[2])
          @ff.text_field(:name, 'static_gateway3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode()->Default Gateway', "Default Gateway = "+info['Default Gateway'])
        if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
          octets=info['Primary DNS Server'].split('.')
          @ff.text_field(:name, 'primary_dns0').value=(octets[0])
          @ff.text_field(:name, 'primary_dns1').value=(octets[1])
          @ff.text_field(:name, 'primary_dns2').value=(octets[2])
          @ff.text_field(:name, 'primary_dns3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :info, 'SetInternetProtocolMode()', "IP Address Distribution = Use the Following IP Address")
      else
        self.msg(rule_name, :error, 'SetInternetProtocolMode()', 'Internet Protocol undefined')
      end
    else
      self.msg(rule_name, :error, 'SetInternetProtocolMode()', 'No Internet Protocol key found')
    end
  end
  
  
  def SetInternetProtocolMode_WanMoCA(rule_name, info)
    
    if info.key?('privacy') and info['privacy']=='on' and info.key?('privacy password')
       @ff.radio(:id, 'coax2').set
       @ff.checkbox(:name, 'clink_privacy').set
       @ff.text_field(:name, 'clink_password').value=(info['privacy password'])
       self.msg(rule_name, :info, 'SetInternetProtocolMode_WanMoCA()->privacy password', 'privacy password = '+info['privacy password'])
    else
       self.msg(rule_name, :error, 'SetInternetProtocolMode_WanMoCA()->privacy password', 'no privacy password info in JSON file, so do not setup privacy password!')
    end
    
    if info.key?('Internet Protocol')
      case info['Internet Protocol']
      when 'Obtain an IP Address Automatically'
        @ff.select_list(:id, 'ip_settings').select_value('2')     
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :info, 'SetInternetProtocolMode_WanMoCA()->Internet Protocol', "Internet Protocol = Obtain an IP Address Automatically")
      when 'Use the Following IP Address'
        @ff.select_list(:id, 'ip_settings').select_value('1')
        if info.key?('IP Address') and info['IP Address'].size > 0
          octets=info['IP Address'].split('.')
          @ff.text_field(:name, 'static_ip0').value=(octets[0])
          @ff.text_field(:name, 'static_ip1').value=(octets[1])
          @ff.text_field(:name, 'static_ip2').value=(octets[2])
          @ff.text_field(:name, 'static_ip3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode_WanMoCA()->IP Address', "IP Address = "+info['IP Address'])
        if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
          octets=info['Subnet Mask'].split('.')
          @ff.text_field(:name, 'static_netmask0').value=(octets[0])
          @ff.text_field(:name, 'static_netmask1').value=(octets[1])
          @ff.text_field(:name, 'static_netmask2').value=(octets[2])
          @ff.text_field(:name, 'static_netmask3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode_WanMoCA()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
        if info.key?('Default Gateway') and info['Default Gateway'].size > 0
          octets=info['Default Gateway'].split('.')
          @ff.text_field(:name, 'static_gateway0').value=(octets[0])
          @ff.text_field(:name, 'static_gateway1').value=(octets[1])
          @ff.text_field(:name, 'static_gateway2').value=(octets[2])
          @ff.text_field(:name, 'static_gateway3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode_WanMoCA()->Default Gateway', "Default Gateway = "+info['Default Gateway'])
        if info.key?('Primary DNS Server') and info['Primary DNS Server'].size > 0
          octets=info['Primary DNS Server'].split('.')
          @ff.text_field(:name, 'primary_dns0').value=(octets[0])
          @ff.text_field(:name, 'primary_dns1').value=(octets[1])
          @ff.text_field(:name, 'primary_dns2').value=(octets[2])
          @ff.text_field(:name, 'primary_dns3').value=(octets[3])
        end
        self.msg(rule_name, :info, 'SetInternetProtocolMode_WanMoCA()->Primary DNS Server', "Primary DNS Server = "+info['Primary DNS Server'])
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :info, 'SetInternetProtocolMode_WanMoCA()', "IP Address Distribution = Use the Following IP Address")
      else
        self.msg(rule_name, :error, 'SetInternetProtocolMode_WanMoCA()', 'Internet Protocol undefined')
      end
    else
      self.msg(rule_name, :error, 'SetInternetProtocolMode_WanMoCA()', 'No Internet Protocol key found')
    end
  end
  # Begin: deal with Bridge setup --add by Robin at 2009/05/14
  def DoSetup_Add(rule_name, info)
    #go to Add Page
    begin
      @ff.link(:href, 'javascript:mimic_button(\'add_conn: ...\', 1)').click
    rescue
      self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Advanced Connection page')
      return
    end
    
    if info.key?('Advanced Connection')
      case info['Advanced Connection']
      when 'Point-to-Point Protocol over Ethernet (PPPoE)'
        @ff.radio(:id, 'advanced_1').set
        self.msg(rule_name, :info, 'DoSetup_Add()->Advanced Connection', 'Advanced Connection = '+info['Advanced Connection'])
        # and then click 'Next' link
        begin
          @ff.link(:text, 'Next').click
        rescue
          self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Next page')
          return
        end
      when 'Network Bridging'
        @ff.radio(:id, 'advanced_7').set
        self.msg(rule_name, :info, 'DoSetup_Add()->Advanced Connection', 'Advanced Connection = '+info['Advanced Connection'])
        # and then click 'Next' link
        begin
          @ff.link(:text, 'Next').click
        rescue
          self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Next page')
          return
        end
        # now in Bridge Options Page
        if info.key?('Bridge Options')
           case info['Bridge Options']
           when 'Configure Existing Bridge (Recommended)'
             @ff.radio(:id, 'bridge_opt_1').set
             self.msg(rule_name, :info, 'DoSetup_Add()->Bridge Options', 'Bridge Options = '+info['Bridge Options'])
             # and then click 'Next' link
             begin
               @ff.link(:text, 'Next').click
             rescue
               self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Next page')
               return
             end
             # now in Configure Existing Bridge Page
              if info.key?('Bridge_Ethernet')
                case info['Bridge_Ethernet']
                when 'on'
                  @ff.checkbox(:name, 'enslave_eth0').set
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Ethernet', 'Bridge_Ethernet=on')
                when 'off'
                  @ff.checkbox(:name, 'enslave_eth0').clear
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Ethernet', 'Bridge_Ethernet=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Ethernet', 'Bridge_Ethernet undefined')
                end
              end              
              if info.key?('Bridge_Broadband Connection (Ethernet)')
                case info['Bridge_Broadband Connection (Ethernet)']
                when 'on'
                  @ff.checkbox(:name, 'enslave_eth1').set
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=on')
                when 'off'
                  @ff.checkbox(:name, 'enslave_eth1').clear
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet) undefined')
                end
              end              
              if info.key?('Bridge_Coax')
                case info['Bridge_Coax']
                when 'on'
                  @ff.checkbox(:name, 'enslave_clink0').set
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Coax', 'Bridge_Coax=on')
                when 'off'
                  @ff.checkbox(:name, 'enslave_clink0').clear
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Coax', 'Bridge_Coax=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Coax', 'Bridge_Coax undefined')
                end
              end              
              if info.key?('Bridge_Broadband Connection (Coax)')
                case info['Bridge_Broadband Connection (Coax)']
                when 'on'
                  @ff.checkbox(:name, 'enslave_clink1').set
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=on')
                when 'off'
                  @ff.checkbox(:name, 'enslave_clink1').clear
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax) undefined')
                end
              end              
              if info.key?('Bridge_Wireless Access Point')
                case info['Bridge_Wireless Access Point']
                when 'on'
                  @ff.checkbox(:name, 'enslave_ath0').set
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=on')
                when 'off'
                  @ff.checkbox(:name, 'enslave_ath0').clear
                  self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=off')           
                else
                  self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point undefined')
                end
              end
              # and then click 'Next' and 'finish' link
              begin
                @ff.link(:text, 'Next').click
                @ff.link(:text, 'Finish').click
              rescue
                self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not successful Configure Existing Bridge ')
                return
              end
           when 'Add a New Bridge'
             @ff.radio(:id, 'bridge_opt_2').set
             self.msg(rule_name, :info, 'DoSetup_Add()->Bridge Options', 'Bridge Options = '+info['Bridge Options']) 
             # and then click 'Next' link
             begin
               @ff.link(:text, 'Next').click
             rescue
               self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Next page')
               return
             end  
             # now in Configure Existing Bridge Page            
             if info.key?('Bridge_Broadband Connection (Ethernet)')
               case info['Bridge_Broadband Connection (Ethernet)']
               when 'on'
                 @ff.checkbox(:name, 'enslave_eth1').set
                 self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=on')
               when 'off'
                 @ff.checkbox(:name, 'enslave_eth1').clear
                 self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet)=off')           
               else
                 self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Broadband Connection (Ethernet)', 'Bridge_Broadband Connection (Ethernet) undefined')
               end
             end                           
             if info.key?('Bridge_Broadband Connection (Coax)')
               case info['Bridge_Broadband Connection (Coax)']
               when 'on'
                 @ff.checkbox(:name, 'enslave_clink1').set
                 self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=on')
               when 'off'
                 @ff.checkbox(:name, 'enslave_clink1').clear
                 self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax)=off')           
               else
                 self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Broadband Connection (Coax)', 'Bridge_Broadband Connection (Coax) undefined')
               end
             end              
             if info.key?('Bridge_Wireless Access Point')
               case info['Bridge_Wireless Access Point']
               when 'on'
                 @ff.checkbox(:name, 'enslave_ath0').set
                 self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=on')
               when 'off'
                 @ff.checkbox(:name, 'enslave_ath0').clear
                 self.msg(rule_name, :info, 'DoSetup_Add()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point=off')           
               else
                 self.msg(rule_name, :error, 'DoSetup_Add()->Bridge_Wireless Access Point', 'Bridge_Wireless Access Point undefined')
               end
             end
             # and then click 'Next' and 'finish' link
             begin
               @ff.link(:text, 'Next').click
               @ff.link(:text, 'Finish').click
             rescue
               self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not successful setup Add a New Bridge')
               return
             end
           else
             self.msg(rule_name, :error, 'DoSetup_Add()->Advanced Connection', 'Advanced Connection undefined')
           end
        end
      when 'VLAN Interface'
        @ff.radio(:id, 'advanced_8').set
        self.msg(rule_name, :info, 'DoSetup_Add()->Advanced Connection', 'Advanced Connection = '+info['Advanced Connection'])
        # and then click 'Next' link
        begin
          @ff.link(:text, 'Next').click
        rescue
          self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Next page')
          return
        end
	if info.key?('Underlying Device')
		case info['Underlying Device']
			when 'Ethernet'
				@ff.select_list(:name,'depend_on_name').select_value('eth0')
				self.msg(rule_name, :info, 'DoSetup_Add()->Underlying Device', 'Underlying Device=Ethernet')
			when  'Coax'
				@ff.select_list(:name,'depend_on_name').select_value('clink0')
				self.msg(rule_name, :info, 'DoSetup_Add()->Underlying Device', 'Underlying Device=Coax')
			when  'Broadband Connection (Ethernet)'
				@ff.select_list(:name,'depend_on_name').select_value('eth1')
				self.msg(rule_name, :info, 'DoSetup_Add()->Underlying Device', 'Underlying Device=Broadband Connection (Ethernet)')
			when  'Broadband Connection (Coax)'
				@ff.select_list(:name,'depend_on_name').select_value('clink1')
				self.msg(rule_name, :info, 'DoSetup_Add()->Underlying Device', 'Underlying Device=Broadband Connection (Coax)')
			when  'Network (Home/Office)'
				@ff.select_list(:name,'depend_on_name').select_value('br0')
				self.msg(rule_name, :info, 'DoSetup_Add()->Underlying Device', 'Underlying Device=Network (Home/Office)')
			when  'Wireless Access Point'
				@ff.select_list(:name,'depend_on_name').select_value('ath0')
				self.msg(rule_name, :info, 'DoSetup_Add()->Underlying Device', 'Underlying Device=Wireless Access Point')
		end
	else
		self.msg(rule_name, :error, 'DoSetup_Add()->Underlying Device', 'Underlying Device undefined')
	end
        if info.key?('VLAN ID')
        	@ff.text_field(:name, 'vid').value=info['VLAN ID']
		self.msg(rule_name, :info, 'DoSetup_Add()->VLAN ID', 'VLAN ID= '+info['VLAN ID'])
	else
		self.msg(rule_name, :error, 'DoSetup_Add()->VLAN ID', 'VLAN ID undefined')
        end
	# click 'Next' link
        begin
          	@ff.link(:text, 'Next').click
        rescue
          	self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Next page')
          	return
        end
	
        if info.key?('VLAN Ports')
        	case info['VLAN Ports']
               		when 'Port 1'
                 		@ff.checkbox(:name, 'vlan_port_num_eth0_0').set
                 		self.msg(rule_name, :info, 'DoSetup_Add()->VLAN Ports', 'Port 1=on')
               		when 'Port 2'
                 		@ff.checkbox(:name, 'vlan_port_num_eth0_1').set
                 		self.msg(rule_name, :info, 'DoSetup_Add()->VLAN Ports', 'Port 2=on')
               		when 'Port 3'
                 		@ff.checkbox(:name, 'vlan_port_num_eth0_2').set
                 		self.msg(rule_name, :info, 'DoSetup_Add()->VLAN Ports', 'Port 3=on')
               		when 'Port 4'
                 		@ff.checkbox(:name, 'vlan_port_num_eth0_3').set
                 		self.msg(rule_name, :info, 'DoSetup_Add()->VLAN Ports', 'Port 4=on')
		end
        else
        	self.msg(rule_name, :error, 'DoSetup_Add()->VLAN Ports', 'VLAN Ports undefined')
        end
	# click 'Next' link
        begin
          	@ff.link(:text, 'Next').click
        rescue
          	self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Next page')
          	return
        end
	@ff.checkbox(:name,'edit_connection').clear
	# click 'Finish' link
        begin
          	@ff.link(:text, 'Finish').click
        rescue
          	self.msg(rule_name, :error, 'DoSetup_Add()', 'Did not reach Finish page')
          	return
        end
      else
        self.msg(rule_name, :error, 'DoSetup_Add()->Advanced Connection', 'Advanced Connection undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_Add()->Advanced Connection', 'No Advanced Connection key found')
    end
  end
  #End: deal with Bridge setup --add by Robin at 2009/05/14
  def NetworkStatus(rule_name, info)
    if info.key?('action') and info['action']=='confirm'
      case info['link']
      when 'Access Shared Files'
        AccessSharedFiles(rule_name, info)
      when 'Website Blocking'
        WebsiteBlocking(rule_name, info)
      when 'Block Internet Services'
        BlockInternetServices(rule_name, info)
      when 'Enable Applications'
        EnableApplications(rule_name, info)
      when 'View Device Details'
        ViewDeviceDetails(rule_name, info)
      when 'Rename this Device'
        RenamethisDevice(rule_name, info)
      else
        self.msg(rule_name, :error, '', 'link undefined')
      end
    else
      self.msg(rule_name, :error, '', 'No action key found/action key error')
    end
  end
  
  
  def AccessSharedFiles(rule_name, info)
    ###
  end
  
  def WebsiteBlocking(rule_name, info)
    ###
    begin
      @ff.link(:text, 'Website Blocking').click
      sleep 3
    rescue
      self.msg(rule_name, :error, 'Website Blocking Page(Parental Control Page)', 'did not reach page')
      return
    end
    if @ff.contains_text('Parental Control')
      self.msg(rule_name, :info, 'Website Blocking Page(Parental Control Page)', 'reach page')
    else
      self.msg(rule_name, :error, 'Website Blocking Page(Parental Control Page)', 'did not reach page')
      return
    end  
  end
  
  def BlockInternetServices(rule_name, info)
    ###
    begin
      @ff.link(:text, 'Block Internet Services').click
      sleep 3
    rescue
      self.msg(rule_name, :error, 'Website Blocking Page(Parental Control Page)', 'did not reach page')
      return
    end
    if @ff.contains_text('Access Control')
      self.msg(rule_name, :info, 'Website Blocking Page(Parental Control Page)', 'reach page')
    else
      self.msg(rule_name, :error, 'Website Blocking Page(Parental Control Page)', 'did not reach page')
      return
    end  
  end
  
  def EnableApplications(rule_name, info)
    ###
  end
  
  def ViewDeviceDetails(rule_name, info)
    ###
  end
  
  def RenamethisDevice(rule_name, info)
    ###
  end
  
end
