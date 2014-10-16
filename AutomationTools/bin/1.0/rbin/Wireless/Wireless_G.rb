################################################################
#     Wireless.rb
#     Author:          RuBingSheng, SuHe, WangZhiQing
#     Date:            since 2009.02.16
#     Contact:         Bru@actiontec.com
#     Discription:     Basic operation of Wireless Page
#     Input:           it depends
#     Output:          the result of operation
################################################################
$dir = File.dirname(__FILE__) 
require $dir+ '/../BasicUtility'

class Wireless_G < BasicUtility
  
  # Wireless page
  def wireless(rule_name, info)
    
    #execute super.wireless(rule_name, info) to go to Wireless Page
    super
    
    # settings and testing on the Wireless page
    # plsease add your code here...
    if info.key?('layout')
      case info['layout']
      when 'Wireless Status'
        WirelessStatus(rule_name, info)
      when 'Basic Security Settings'
        BasicSecuritySettings(rule_name, info)
      when 'Advanced Security Settings'
        AdvancedSecuritySettings(rule_name, info)
      else
        self.msg(rule_name, :error, '', 'layout undefined')
      end
    else
      self.msg(rule_name, :error, '', 'No layout key found')
    end
   
  end
  
  def WirelessStatus(rule_name, info)

    # Get to the "Wireless Status" page.
    begin
      @ff.link(:text, 'Wireless Status').click
      self.msg(rule_name, :info, 'Wireless Status page', 'Reached!')
    rescue
      self.msg(rule_name, :error, 'Wireless Status', 'Did not reach the page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('layout') &&
         info.has_key?('page') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'Wireless Status','Some key NOT found.')
      return
    end 
    
    # Output the result.
    
    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Radio Enabled' and 
           ( not t.text.include? 'Wireless Status') and
           t.row_count >= 5 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'Wireless Status','Did NOT find the target table.')
      return
    end
    
    # Find the row
    sTable.each do |row|
      
      # Output in to the result.
      self.msg(rule_name,'Wireless Status',row[1],row[2])
      
    end  
    
    # Output the result
    self.msg(rule_name,:info,'Wireless Status','SUCCESS')
   
  end

	# Get into Wireless Basic Security Setting Page
	# It will call two functions GoBasicSecuritySettingsPage
	# and DoSetup_BasicSecuritySettings 
  def BasicSecuritySettings(rule_name, info)

       if info.key?('page')
      case info['page']      
      when 'Basic Security Settings'
        GoBasicSecuritySettingsPage(rule_name, info)
        DoSetup_BasicSecuritySettings(rule_name, info)
      else
        self.msg(rule_name, :error, 'General()', 'page undefined')
      end
    else
      self.msg(rule_name, :error, 'General()', 'No page key found')
    end
   
 end
 
	# Function an event to click Basic Security Setting link
  def GoBasicSecuritySettingsPage(rule_name, info)
    ###
    begin
      @ff.link(:href, 'javascript:mimic_button(\'btn_tab_goto: 9120..\', 1)').click
    rescue	      
      self.msg(rule_name, :error, 'GoBasicSecuritySettingsPage()', 'Did not reach Basic Security Settings page')
      return
    end
  end
  
	# Entry to configure Basic Security Settings Page
	# It will call three functions DoSetup_BasicSecuriySettings_wirelesson, DoClickApply_SetBasicSecuriySettings
	# and DoBasicSecuritySettings_Infospit
  def DoSetup_BasicSecuritySettings(rule_name, info)
    # Turn Wireless ON
    if info.key?('Wireless')
      case info ['Wireless']
      when 'on'
        @ff.radio(:id, 'ws_on').set
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Wireless', "Wireless = "+info['Wireless'])
        DoSetup_BasicSecuriySettings_wirelesson(rule_name, info)
	puts "aaaa" 
       DoClickApply_SetBasicSecuriySettings(rule_name, info)
	puts "bbbb"
        DoBasicSecuritySettings_Infospit(rule_name, info)
	puts "cccc"
      when 'off'
        @ff.radio(:id, 'ws_off').set
        DoClickApply_SetBasicSecuriySettings(rule_name, info)
        DoBasicSecuritySettings_Infospit(rule_name, info)
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Wireless', "Wireless = "+info['Wireless'])
      else
        self.msg(rule_name, :error, 'BasicSecuritySettings()->Wireless', 'Wireless undefined')
      end
    else 
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Wireless', 'No Wireless key found in json') 
    end
  end
  
  # Output Basic Security Settings Page information into json file results
  def DoBasicSecuritySettings_Infospit(rule_name, info)
    
    # Find the table.
    sleep(10)
    @ff.refresh
    
    sTable = false

    @ff.tables.each do |t|
      if ( t.text.include? 'Current Wireless Status:' and
          ( t.text.include? 'Wireless Mode:') and
           ( not t.text.include? 'Apply') and
           t.row_count >= 10 )then
        sTable = t
        break
      end
    end

    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'Current Wireless Status','Did NOT find the target table.')
      return
    end
    
    i = 0
    # Find the row
    sTable.each do |row|
      i = i + 1
      if i == 1
        next
      end      
      # Output in to the result.
      self.msg(rule_name,'Basic Security Settings Current Wireless Status',row[1],(row[2].to_s.split(';')).last)
    end

  end
  
	# Click Apply for Basic Security Settings Page 
  def DoClickApply_SetBasicSecuriySettings(rule_name, info)
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors") 
       errorTable=@ff.tables[18]
       errorTable_rowcount=errorTable.row_count
       for i in 1..errorTable_rowcount-1
         self.msg(rule_name, :PageInfo_Error, "BasicSecuritySettings()->Apply (#{i})", errorTable.[](i).text)    
       end 
       self.msg(rule_name, :error, 'BasicSecuritySettings()->Apply', 'BasicSecuritySettings setup fault')
     else
       if @ff.contains_text("Attention") 
         errorTable=@ff.tables[18]
         errorTable_rowcount=errorTable.row_count
         for i in 1..errorTable_rowcount-1
           self.msg(rule_name, :PageInfo_Error, "BasicSecuritySettings()->Apply (#{i})", errorTable.[](i).text)    
         end 
         @ff.link(:text, 'Apply').click
         self.msg(rule_name, :result_info, 'BasicSecuritySettings()->Apply', 'BasicSecuritySettings sucessful with Attention')
       else
         self.msg(rule_name, :result_info, 'BasicSecuritySettings()->Apply', 'BasicSecuritySettings setup sucessful')
       end 
     end
  end  
  
	# To configure Basic Security Settings in Page according to the imported json file
  def DoSetup_BasicSecuriySettings_wirelesson(rule_name, info)
    # Change the SSID setting to any name or code you want
    if info.key?('SSID')
      @ff.text_field(:name, 'ssid').value=info['SSID']
      self.msg(rule_name, :info, 'BasicSecuritySettings()->SSID', "SSID = "+info['SSID'])  
    else
      self.msg(rule_name, :info, 'BasicSecuritySettings()->SSID', 'No SSID key found in json')    
    end
     
    # Channel
    if info.key?('Channel')
      case info ['Channel']
      when 'Automatic'
        @ff.select_list(:name, 'channel').select_value('-1')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])
      when '1'
        @ff.select_list(:name, 'channel').select_value('1')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])        
      when '2'
        @ff.select_list(:name, 'channel').select_value('2')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])            
      when '3'
        @ff.select_list(:name, 'channel').select_value('3')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '4'    
        @ff.select_list(:name, 'channel').select_value('4')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '5' 
        @ff.select_list(:name, 'channel').select_value('5')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '6'   
        @ff.select_list(:name, 'channel').select_value('6')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '7'
        @ff.select_list(:name, 'channel').select_value('7')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '8'
        @ff.select_list(:name, 'channel').select_value('8')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '9'
        @ff.select_list(:name, 'channel').select_value('9')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '10'
        @ff.select_list(:name, 'channel').select_value('10')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      when '11'      
        @ff.select_list(:name, 'channel').select_value('11')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', "Channel = "+info['Channel'])             
      end
    else
      self.msg(rule_name, :info, 'BasicSecuritySettings()->Channel', 'No Channel key found in json')
    end
     
    # Keep my channel selection during power cycle
    if info.key?('Keep my channel selection during power cycle')
      case info ['Keep my channel selection during power cycle']
        when 'on'
           @ff.checkbox(:name, 'keep_channel').set
           self.msg(rule_name, :info, 'BasicSecuritySettings()->Keep channel', "Keep channel = "+info['Keep my channel selection during power cycle'])
        else
           self.msg(rule_name, :error, 'BasicSecuritySettings()->Keep channel', 'Keep channel undefined')
        end
    else 
      self.msg(rule_name, :info, 'BasicSecuritySettings()->Keep channel', 'No Keep channel key found in json')        
    end
     
    # Click on the button next to WEP
    # WEP
    if info.key?('WEP')
      @ff.radio(:id, 'wep_on').set
      self.msg(rule_name, :info, 'BasicSecuritySettings()->WEP', "WEP = "+info['WEP'])   
    else
      self.msg(rule_name, :info, 'BasicSecuritySettings()->WEP', 'No WEP key found in json')  
    end
     
    # Click on the button next to WEP
    # Off
    if info.key?('Off')
      @ff.radio(:id, 'wep_off').set
      self.msg(rule_name, :info, 'BasicSecuritySettings()->Off', "Off = "+info['Off'])   
    else
      self.msg(rule_name, :info, 'BasicSecuritySettings()->Off', 'No Off key found in json')  
    end
     
    # Select a WEP Key
    if info.key?('Select a WEP Key')
      case info ['Select a WEP Key']
      when '64/40 bit'
        @ff.select_list(:id, 'wep_key_len').select_value('40')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Select a WEP Key', "WEP Key = "+info['Select a WEP Key'])   
      when '128/104 bit'
        @ff.select_list(:id, 'wep_key_len').select_value('104')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Select a WEP Key', "WEP Key = "+info['Select a WEP Key'])   
      end
    else
      self.msg(rule_name, :info, 'BasicSecuritySettings()->Select a WEP Key', 'No \"Select a WEP Key\" found in json')      
    end
     
    # Hex
    if info.key?('Hex')
      case info ['Hex']
      when 'on'
        @ff.select_list(:id, 'wep_key_code').select_value('0')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Select a Key Mode', 'A Hex')
      end
    else
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Select a Key Mode', 'Not a Hex')
    end
    
    # ASCII
    if info.key?('ASCII')
      case info ['ASCII']
      when 'on'
        @ff.select_list(:id, 'wep_key_code').select_value('1')
        self.msg(rule_name, :info, 'BasicSecuritySettings()->Select a Key Mode', 'A ASCII')
      end
    else
      self.msg(rule_name, :info, 'BasicSecuritySettings()->Select a Key Mode', 'Not a ASCII')
    end
    
    # Key Code
  
  end 
 
  #----------------------------------------------------------------------
  # AdvancedSecuritySettings(rule_name,info)
  # Author :Su He
  # Description: function of "Advanced Security Settings" under "Wireless 
  #              Settings" page.
  #              This is a inside function, will be called by function wireless() 
  #----------------------------------------------------------------------   
  def AdvancedSecuritySettings(rule_name, info)
    
    # Get to the "Advanced Security Settings" page.
    begin
      @ff.link(:text, 'Advanced Security Settings').click
      self.msg(rule_name, :info, 'Advanced Security Settings page', 'Reached!')
    rescue
      self.msg(rule_name, :error, 'Advanced Security Settings', 'Did not reach the page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('layout') &&
         info.has_key?('page') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'Advanced Security Settings','Some key NOT found.')
      return
    end   
    
    # Find the page and branch function.
    
    # ************* Begin *************
     
    case info['page']
      
    when '802mode' 
      # Click the "802.11b/g Mode"
      begin
        @ff.link(:text,'802.11b/g/n Mode').click
        self.msg(rule_name,:info,info['page'],'Clicked')
        _802mode(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'802mode\'','Page error under wireless.')
        return
      end      
      
    when 'wma'
      # Click the "Wireless MAC Authentication"
      begin
        @ff.link(:text,'Wireless MAC Authentication').click
        self.msg(rule_name,:info,info['page'],'Clicked')
        wma(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'wma\'','Page error under wireless.')
        return
      end
      
    when 'ssidb' 
      # Click the "SSID Broadcast"
      begin
        @ff.link(:text,'SSID Broadcast').click
        self.msg(rule_name,:info,info['page'],'Clicked')
        ssidb(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'ssidb\'','Page error under wireless.')
        return
      end
      
    when 'wpa2'
      # Click the "WPA2"
      begin
        @ff.radio(:id,'wpa2').set
        self.msg(rule_name,:info,info['page'],'Clicked')
        wpa2(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'wpa2\'','Page error under wireless.')
        return
      end      
      
    when 'wpa'
      # Click the "WPA"
      begin
        @ff.radio(:id,'wpa').set
        self.msg(rule_name,:info,info['page'],'Clicked')
        wpa(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'wpa\'','Page error under wireless.')
        return
      end
      
    when 'wep802r' 
      # Click the "WEP802R"
      begin
        @ff.radio(:id,'wep1').set
        self.msg(rule_name,:info,info['page'],'Clicked')
        wep802r(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'wep802r\'','Page error under wireless.')
        return
      end
      
    when 'wep'
      # Click the "WEP"
      begin
        @ff.radio(:id,'wep0').set
        self.msg(rule_name,:info,info['page'],'Clicked')
        wep(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'wep\'','Page error under wireless.')
        return
      end
                    
    when 'Other Advanced Wireless Options'
      # Click the "Other Advanced Wireless Options"
      begin
        
        @ff.link(:text,'Other Advanced Wireless Options').click
        # Confirm it   
        @ff.link(:text, 'Yes').click
        self.msg(rule_name,:info,info['page'],'Clicked')
        OtherAdvancedWirelessOptions(rule_name,info)
      rescue
        self.msg(rule_name,:error,'Advanced Security Settings \'Wireless Option\'','Page error under wireless.')
        return
      end
      
    else
      # Wrong here.
      self.msg(rule_name,:error,'Advanced Security Settings','No such page name.')
      return      
      
    end # end of case
         
    # ************* End *************
    
    # Output the result
    self.msg(rule_name,:info,'Advanced Security Settings','SUCCESS')
    
  end
  
  def OtherAdvancedWirelessOptions(rule_name, info)
    ###
    # When should this rule occur
    if info.key?('When should this rule occur')
      case info['When should this rule occur']
      when 'Always'
        @ff.select_list(:id, 'schdlr_rule_id').select_value('ALWAYS') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->When should this rule occur', "When should this rule occur = "+info['When should this rule occur'])
      else
        self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->When should this rule occur', 'When should this rule occur undefined')
      end
    else
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->When should this rule occur', 'No When should this rule occur key found')
    end
    
    # Network
    if info.key?('Network')
      case info['Network']
      when 'Broadband Connection'
        @ff.select_list(:id, 'network').select_value('1') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Network', "Network = "+info['Network'])
      when 'Network (Home/Office)'
        @ff.select_list(:id, 'network').select_value('2') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Network', "Network = "+info['Network'])
      when 'DMZ'
        @ff.select_list(:id, 'network').select_value('4') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Network', "Network = "+info['Network'])
      else
        self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->Network', 'Network undefined')
      end
    else
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Network', 'No Network key found')
    end
    
    # MTU
    if info.key?('MTU')
      case info['MTU']
      when 'Automatic'
        @ff.select_list(:id, 'mtu_mode').select_value('1')
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->MTU', 'MTU = '+info['MTU'])
      when 'Automatic by DHCP'
        @ff.select_list(:id, 'mtu_mode').select_value('2')
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->MTU', 'MTU = '+info['MTU'])
      when 'Manual'
        @ff.select_list(:id, 'mtu_mode').select_value('0')
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->MTU', 'MTU = '+info['MTU'])
        if info.key?('MTU Value')  
          @ff.text_field(:name, 'mtu').value=(info['MTU Value'])
          self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->MTU Value', 'MTU Value= '+info['MTU Value'])
        else
          self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->MTU Value', 'No MTU Value key found')
        end
      else
        self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->MTU', 'MTU undefined')
      end
    else
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->MTU', 'No MTU key found')
    end
    
    # Transmission Rate
    if info.key?('Transmission Rate')
      case info['Transmission Rate']
      when 'Auto'
        @ff.select_list(:id, 'transmission_rate').select_value('-1') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '1'
        @ff.select_list(:id, 'transmission_rate').select_value('1000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '2'
        @ff.select_list(:id, 'transmission_rate').select_value('2000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '5.5'
        @ff.select_list(:id, 'transmission_rate').select_value('5500') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '11'
        @ff.select_list(:id, 'transmission_rate').select_value('11000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '6'
        @ff.select_list(:id, 'transmission_rate').select_value('6000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '9'
        @ff.select_list(:id, 'transmission_rate').select_value('9000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '12'
        @ff.select_list(:id, 'transmission_rate').select_value('12000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '18'
        @ff.select_list(:id, 'transmission_rate').select_value('18000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '24'
        @ff.select_list(:id, 'transmission_rate').select_value('24000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '36'
        @ff.select_list(:id, 'transmission_rate').select_value('36000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '48'
        @ff.select_list(:id, 'transmission_rate').select_value('48000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      when '54'
        @ff.select_list(:id, 'transmission_rate').select_value('54000') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', "Transmission Rate = "+info['Transmission Rate'])
      else
        self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->Transmission Rate', 'Transmission Rate undefined')
      end
    else
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmission Rate', 'No Transmission Rate key found')
    end
    
    # Transmit Power
    if info.key?('Transmit Power')  
      @ff.text_field(:name, 'tx_power').value=(info['Transmit Power'])
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Transmit Power', 'Transmit Power= '+info['Transmit Power'])
    else
      self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->Transmit Power', 'No Transmit Power key found')
    end
    
    # CTS Protection Mode
    if info.key?('CTS Protection Mode')
      case info['CTS Protection Mode']
      when 'None'
        @ff.select_list(:id, 'cts_protection_mode').select_value('1') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->CTS Protection Mode', "CTS Protection Mode = "+info['CTS Protection Mode'])
      when 'Auto'
        @ff.select_list(:id, 'cts_protection_mode').select_value('3') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->CTS Protection Mode', "CTS Protection Mode = "+info['CTS Protection Mode'])
      else
        self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->CTS Protection Mode', 'CTS Protection Mode undefined')
      end
    else
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->CTS Protection Mode', 'No CTS Protection Mode key found')
    end
    
    #
    # CTS Protection Type
    if info.key?('CTS Protection Type')
      case info['CTS Protection Type']
      when 'cts-only'
        @ff.select_list(:id, 'cts_protection_type').select_value('0') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->CTS Protection Type', "CTS Protection Type = "+info['CTS Protection Type'])
      when 'rts_cts'
        @ff.select_list(:id, 'cts_protection_type').select_value('1') 
        self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->CTS Protection Type', "CTS Protection Type = "+info['CTS Protection Type'])
      else
        self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->CTS Protection Type', 'CTS Protection Type undefined')
      end
    else
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->CTS Protection Type', 'No CTS Protection Type key found')
    end
    
    # Frame Burst - Max Number
    if info.key?('Frame Burst - Max Number')  
      @ff.text_field(:name, 'frame_burst_max_number').value=(info['Frame Burst - Max Number'])
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Frame Burst - Max Number', 'Frame Burst - Max Number= '+info['Frame Burst - Max Number'])
    else
      self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->Frame Burst - Max Number', 'No Frame Burst - Max Number key found')
    end
    
    # Frame Burst - Burst Time
    if info.key?('Frame Burst - Burst Time')  
      @ff.text_field(:name, 'frame_burst_burst_time').value=(info['Frame Burst - Burst Time'])
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Frame Burst - Burst Time', 'Frame Burst - Burst Time= '+info['Frame Burst - Burst Time'])
    else
      self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->Frame Burst - Burst Time', 'No Frame Burst - Burst Time key found')
    end
    
    # Beacon Interval
    if info.key?('Beacon Interval')  
      @ff.text_field(:name, 'bcn_interval').value=(info['Beacon Interval'])
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Beacon Interval', 'Beacon Interval= '+info['Beacon Interval'])
    else
      self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->Beacon Interval', 'No Beacon Interval key found')
    end
    
    # DTIM Interval
    if info.key?('DTIM Interval')  
      @ff.text_field(:name, 'dtim_interval').value=(info['DTIM Interval'])
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->DTIM Interval', 'DTIM Interval= '+info['DTIM Interval'])
    else
      self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->DTIM Interval', 'No DTIM Interval key found')
    end
    
    # Fragmentation Threshold
    if info.key?('Fragmentation Threshold')  
      @ff.text_field(:name, 'fragmentation_threshold').value=(info['Fragmentation Threshold'])
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->Fragmentation Threshold', 'Fragmentation Threshold= '+info['Fragmentation Threshold'])
    else
      self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->Fragmentation Threshold', 'No Fragmentation Threshold key found')
    end
    
    # RTS Threshold
    if info.key?('RTS Threshold')  
      @ff.text_field(:name, 'rts_threshold').value=(info['RTS Threshold'])
      self.msg(rule_name, :info, 'OtherAdvancedWirelessOptions()->RTS Threshold', 'RTS Threshold= '+info['RTS Threshold'])
    else
      self.msg(rule_name, :error, 'OtherAdvancedWirelessOptions()->RTS Threshold', 'No RTS Threshold key found')
    end 
    ###
    if @ff.contains_text('Apply')
	@ff.link(:text,'Apply').click
    else
        self.msg(rule_name,:error,'Apply','Can not Apply the other Advanced Wireless Options configuration.')
	return
    end
    # Output the result
    self.msg(rule_name,:info,'OtherAdvancedWirelessOptions','SUCCESS')
  end
  
  #----------------------------------------------------------------------
  # wep(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by AdvancedSecuritySettings().
  #----------------------------------------------------------------------
  def wep(rule_name,info)
   
    # Now, Firefox should under "WEP Key" default page.
    # Check the page.
    if not @ff.text.include?'WEP Key'
      # Wrong here.
      self.msg(rule_name,:error,'wep()','Not reach the page.')
      return
    end   
    
    # Parse the json file.    

    # "Network Authentication"
    if info.has_key?('Network Authentication')
      
      case info['Network Authentication']
      
      when 'Open System Authentication'
        
        # Set "Open System Authentication"
        @ff.select_list(:name,'wl_auth').select_value("0")
        self.msg(rule_name,:info,'Network Authentication',info['Network Authentication'])
 
      when 'Shared Key Authentication'
        
        # Set "Shared Key Authentication"
        @ff.select_list(:name,'wl_auth').select_value("1")
        self.msg(rule_name,:info,'Network Authentication',info['Network Authentication'])
        
      when 'Both'
        
        # Set "Both"
        @ff.select_list(:name,'wl_auth').select_value("2")
        self.msg(rule_name,:info,'Network Authentication',info['Network Authentication'])        
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Network Authentication\'.')
        return
        
      end # end of case
      
    end # end of if
    
    # "Active"
    if info.has_key?('Active')
      
      case info['Active']
      
      when '1'
        
        # Set "1"
        @ff.radio(:id,'wep_active_0').set
        self.msg(rule_name,:info,'Active',info['Active'])
        
        # "Entry Method"
        if info.has_key?('Entry Method')
           
          case info['Entry Method']
          
          when 'Hex'
            
            # Set "Hex"
            @ff.select_list(:name,'0_8021x_mode_0').select_value("0")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
     
          when 'ASCII'
            
            # Set "ASCII"
            @ff.select_list(:name,'0_8021x_mode_0').select_value("1")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Entry Method\'.')
            return
            
          end # end of case
          
        end # end of if     

        # "Key Length"
        if info.has_key?('Key Length')
          
          case info['Key Length']
          
          when '64/40 bit'
            
            # Set "64/40 bi"
            @ff.select_list(:name,'0_8021x_key_len_0').select_value("40")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
            
          when '128/104 bit'
            
            # Set "128/104 bit"
            @ff.select_list(:name,'0_8021x_key_len_0').select_value("104")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Key Length\'.')
            return
            
          end # end of case
          
        end # end of if  

        # "Encryption Key"
        if info.has_key?('Encryption Key')
		if info['Entry Method'] == 'Hex' then 
          		@ff.text_field(:name,'0_8021x_key_hex_0').value = info['Encryption Key']
         	else	
			@ff.text_field(:name,'0_8021x_key_asc_0').value = info['Encryption Key']
		end
	   
          self.msg(rule_name,:info,'Encryption Key',info['Encryption Key'])
          
        end   
 
      when '2'
        
        # Set "2"
        @ff.radio(:id,'wep_active_1').set
        self.msg(rule_name,:info,'Active',info['Active'])
        
        # "Entry Method"
        if info.has_key?('Entry Method')
          
          case info['Entry Method']
          
          when 'Hex'
            
            # Set "Hex"
            @ff.select_list(:name,'0_8021x_mode_1').select_value("0")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
     
          when 'ASCII'
            
            # Set "ASCII"
            @ff.select_list(:name,'0_8021x_mode_1').select_value("1")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Entry Method\'.')
            return
            
          end # end of case
          
        end # end of if  

        # "Key Length"
        if info.has_key?('Key Length')
          
          case info['Key Length']
          
          when '64/40 bit'
            
            # Set "64/40 bi"
            @ff.select_list(:name,'0_8021x_key_len_1').select_value("40")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
     
          when '128/104 bit'
            
            # Set "128/104 bit"
            @ff.select_list(:name,'0_8021x_key_len_1').select_value("104")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Key Length\'.')
            return
            
          end # end of case
          
        end # end of if    
	sleep 5
        # "Encryption Key"
        if info.has_key?('Encryption Key')
		if info['Entry Method'] == 'Hex' then 
          		@ff.text_field(:name,'0_8021x_key_hex_1').value = info['Encryption Key']
         	else	
			@ff.text_field(:name,'0_8021x_key_asc_1').value = info['Encryption Key']
		end
	   
          self.msg(rule_name,:info,'Encryption Key',info['Encryption Key'])
          
        end        
        
      when '3'
        
        # Set "3"
        @ff.radio(:id,'wep_active_2').set
        self.msg(rule_name,:info,'Active',info['Active']) 
        
        # "Entry Method"
        if info.has_key?('Entry Method')
          
          case info['Entry Method']
          
          when 'Hex'
            
            # Set "Hex"
            @ff.select_list(:name,'0_8021x_mode_2').select_value("0")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
     
          when 'ASCII'
            
            # Set "ASCII"
            @ff.select_list(:name,'0_8021x_mode_2').select_value("1")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Entry Method\'.')
            return
            
          end # end of case
          
        end # end of if   

        # "Key Length"
        if info.has_key?('Key Length')
          
          case info['Key Length']
          
          when '64/40 bit'
            
            # Set "64/40 bi"
            @ff.select_list(:name,'0_8021x_key_len_2').select_value("40")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
     
          when '128/104 bit'
            
            # Set "128/104 bit"
            @ff.select_list(:name,'0_8021x_key_len_2').select_value("104")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Key Length\'.')
            return
            
          end # end of case
          
        end # end of if 

        # "Encryption Key"
        if info.has_key?('Encryption Key')
		if info['Entry Method'] == 'Hex' then 
          		@ff.text_field(:name,'0_8021x_key_hex_0').value = info['Encryption Key']
         	else	
			@ff.text_field(:name,'0_8021x_key_asc_0').value = info['Encryption Key']
		end
	   
          self.msg(rule_name,:info,'Encryption Key',info['Encryption Key'])
          
        end          
        
      when '4'
        
        # Set "4"
        @ff.radio(:id,'wep_active_3').set
        self.msg(rule_name,:info,'Active',info['Active'])   
        
        # "Entry Method"
        if info.has_key?('Entry Method')
          
          case info['Entry Method']
          
          when 'Hex'
            
            # Set "Hex"
            @ff.select_list(:name,'0_8021x_mode_3').select_value("0")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
     
          when 'ASCII'
            
            # Set "ASCII"
            @ff.select_list(:name,'0_8021x_mode_3').select_value("1")
            self.msg(rule_name,:info,'Entry Method',info['Entry Method'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Entry Method\'.')
            return
            
          end # end of case
          
        end # end of if  

        # "Key Length"
        if info.has_key?('Key Length')
          
          case info['Key Length']
          
          when '64/40 bit'
            
            # Set "64/40 bi"
            @ff.select_list(:name,'0_8021x_key_len_3').select_value("40")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
     
          when '128/104 bit'
            
            # Set "128/104 bit"
            @ff.select_list(:name,'0_8021x_key_len_3').select_value("104")
            self.msg(rule_name,:info,'Key Length',info['Key Length'])
            
          else
            
            # Wrong here
            self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Key Length\'.')
            return
            
          end # end of case
          
        end # end of if    
        
        # "Encryption Key"
        if info.has_key?('Encryption Key')
		if info['Entry Method'] == 'Hex' then 
          		@ff.text_field(:name,'0_8021x_key_hex_0').value = info['Encryption Key']
         	else	
			@ff.text_field(:name,'0_8021x_key_asc_0').value = info['Encryption Key']
		end
	   
          self.msg(rule_name,:info,'Encryption Key',info['Encryption Key'])
          
        end   
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wep()','Did NOT find the value in \'Active\'.')
        return
        
      end # end of case
      
    end # end of if   
    
    if @ff.contains_text('Apply')
	@ff.link(:text,'Apply').click
    else
        self.msg(rule_name,:error,'Apply','Can not Apply the wep configuration.')
	return
    end
    # Output the result
    self.msg(rule_name,:info,'WEP Key','SUCCESS')
    
  end
  
  #----------------------------------------------------------------------
  # wep802r(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by AdvancedSecuritySettings().
  #----------------------------------------------------------------------
  def wep802r(rule_name,info)
    
    # Now, Firefox should under "WEP+802.1x Radius Settings" default page.
    # Check the page.
    if not @ff.text.include?'WEP+802.1x Radius Settings'
      # Wrong here.
      self.msg(rule_name,:error,'wep802r()','Not reach the page.')
      return
    end   
    
    # Parse the json file. 
    
    # "Server IP"
    if info.has_key?('Server IP')
      
      begin
        octets = info['Server IP'].split('.')
        @ff.text_field(:name, 'radius_client_server_ip0').set(octets[0])
        @ff.text_field(:name, 'radius_client_server_ip1').set(octets[1])
        @ff.text_field(:name, 'radius_client_server_ip2').set(octets[2])
        @ff.text_field(:name, 'radius_client_server_ip3').set(octets[3])
        self.msg(rule_name,:info,'Server IP',info['Server IP'])
      rescue
        self.msg(rule_name,:error,'wep802r()','Can NOT setup Server IP address.')
        return
      end
      
    end
    
    # "Server Port"
    if info.has_key?('Server Port')
      
      @ff.text_field(:name,'radius_client_server_port').set(info['Server Port'])
      self.msg(rule_name,:info,'Server Port',info['Server Port'])
      
    end
    
    # "Shared Secret"
    if info.has_key?('Shared Secret')
      
      @ff.text_field(:index,6).set(info['Shared Secret'])
      self.msg(rule_name,:info,'Shared Secret',info['Shared Secret'])
      
    end   
    
    # Apply for the change.
    if @ff.contains_text('Apply')
        @ff.link(:text,'Apply').click
    else
	self.msg(rule_name,:error,'Apply','Can NOT Apply WPA setting.')
        return
    end

    # Output the result
    self.msg(rule_name,:info,'WEP+802.1x Radius Settings','SUCCESS')   
    
  end  
  
  #----------------------------------------------------------------------
  # wpa(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by AdvancedSecuritySettings().
  #----------------------------------------------------------------------
  def wpa(rule_name,info)
    
    # Now, Firefox should under "WPA" default page.
    # Check the page.
    if not @ff.text.include?'WPA'
      # Wrong here.
      self.msg(rule_name,:error,'wpa()','Not reach the page.')
      return
    end   
    
    # Parse the json file.   

    # "Authentication Method"
    if info.has_key?('Authentication Method')
      
      case info['Authentication Method']
      
      when 'Pre-Shared Key'
        
        # Set "Pre-Shared Key"
        @ff.select_list(:name,'wpa_sta_auth_type').select_value("1")
        self.msg(rule_name,:info,'Authentication Method',info['Authentication Method'])
 
      when '802.1X'
        
        # Set "802.1X"
        @ff.select_list(:name,'wpa_sta_auth_type').select_value("2")
        self.msg(rule_name,:info,'Authentication Method',info['Authentication Method'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa()','Did NOT find the value in \'Authentication Method\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Pre-Shared Key(ASCII/Hex)"
    if info.has_key?('Pre-Shared Key(ASCII/Hex)') and
       info['Authentication Method'] == "Pre-Shared Key"
      
      case info['Pre-Shared Key(ASCII/Hex)']
      
      when 'Hex'
        
        # Set "Hex"
        @ff.select_list(:name,'psk_representation').select_value("0")
        self.msg(rule_name,:info,'Pre-Shared Key(ASCII/Hex)',info['Pre-Shared Key(ASCII/Hex)'])
        
        # "Pre-Shared Key"
        if info.has_key?('Pre-Shared Key')
          
          @ff.text_field(:name,'wpa_sta_auth_shared_key_hex').set(info['Pre-Shared Key'])
          self.msg(rule_name,:info,'Pre-Shared Key',info['Pre-Shared Key'])
          
        end         
 
      when 'ASCII'
        
        # Set "ASCII"
        @ff.select_list(:name,'psk_representation').select_value("1")
        self.msg(rule_name,:info,'Pre-Shared Key(ASCII/Hex)',info['Pre-Shared Key(ASCII/Hex)'])
        
        # "Pre-Shared Key"
        if info.has_key?('Pre-Shared Key')
          
          @ff.text_field(:name,'wpa_sta_auth_shared_key').set(info['Pre-Shared Key'])
          self.msg(rule_name,:info,'Pre-Shared Key',info['Pre-Shared Key'])
          
        end         
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa()','Did NOT find the value in \'Pre-Shared Key(ASCII/Hex)\'.')
        return
        
      end # end of case
      
    end # end of if  
   
    # "Encryption Algorithm"
    if info.has_key?('Encryption Algorithm')
      
      case info['Encryption Algorithm']
      
      when 'TKIP'
        
        # Set "TKIP"
        @ff.select_list(:name,'wpa_cipher').select_value("1")
        self.msg(rule_name,:info,'Encryption Algorithm',info['Encryption Algorithm'])
 
      when 'AES'
        
        # Set "AES"
        @ff.select_list(:name,'wpa_cipher').select_value("2")
        self.msg(rule_name,:info,'Encryption Algorithm',info['Encryption Algorithm'])
        
      when 'TKIP and AES'
        
        # Set "TKIP and AES"
        @ff.select_list(:name,'wpa_cipher').select_value("3")
        self.msg(rule_name,:info,'Encryption Algorithm',info['Encryption Algorithm'])        
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa()','Did NOT find the value in \'Encryption Algorithm\'.')
        return
        
      end # end of case
      
    end # end of if    

    # "Group Key Update Interval"
    if info.has_key?('Group Key Update Interval')
      
      case info['Group Key Update Interval']
      
      when 'on'
        
        # Set "Group Key Update Interval"
        @ff.checkbox(:name,'is_grp_key_update').set
        self.msg(rule_name,:info,'Group Key Update Interval',info['Group Key Update Interval'])
        
        # "Seconds"
        if info.has_key?('Seconds')
          
          @ff.text_field(:name,'8021x_rekeying_interval').set(info['Seconds'])
          self.msg(rule_name,:info,'Seconds',info['Seconds'])
          
        end        
 
      when 'off'
        
        # Clear "Group Key Update Interval"
        @ff.checkbox(:name,'is_grp_key_update').clear
        self.msg(rule_name,:info,'Group Key Update Interval',info['Group Key Update Interval'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa()','Did NOT find the value in \'Group Key Update Interval\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "Server IP"
    if info.has_key?('Server IP')
      
      begin
        octets = info['Server IP'].split('.')
        @ff.text_field(:name, 'radius_client_server_ip0').set(octets[0])
        @ff.text_field(:name, 'radius_client_server_ip1').set(octets[1])
        @ff.text_field(:name, 'radius_client_server_ip2').set(octets[2])
        @ff.text_field(:name, 'radius_client_server_ip3').set(octets[3])
        self.msg(rule_name,:info,'Server IP',info['Server IP'])
      rescue
        self.msg(rule_name,:error,'wpa()','Can NOT setup Server IP address.')
        return
      end
      
    end
    
    # "Server Port"
    if info.has_key?('Server Port')
      
      @ff.text_field(:name,'radius_client_server_port').set(info['Server Port'])
      self.msg(rule_name,:info,'Server Port',info['Server Port'])
      
    end
    
    # "Shared Secret"
    if info.has_key?('Shared Secret')
      
      @ff.text_field(:index,6).set(info['Shared Secret'])
      self.msg(rule_name,:info,'Shared Secret',info['Shared Secret'])
      
    end     
    
    # Apply for the change.
    if @ff.contains_text('Apply')
        @ff.link(:text,'Apply').click
    else
	self.msg(rule_name,:error,'Apply','Can NOT Apply WPA setting.')
        return
    end
    # Output the result
    self.msg(rule_name,:info,'WPA','SUCCESS')     
      
  end
  
  #----------------------------------------------------------------------
  # wpa2(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by AdvancedSecuritySettings().
  #----------------------------------------------------------------------
  def wpa2(rule_name,info)    
    
    # Now, Firefox should under "WPA2" default page.
    # Check the page.
    if not @ff.text.include?'WPA2'
      # Wrong here.
      self.msg(rule_name,:error,'wpa2()','Not reach the page.')
      return
    end   
    
    # Parse the json file.   

    # "Authentication Method"
    if info.has_key?('Authentication Method')
      
      case info['Authentication Method']
      
      when 'Pre-Shared Key'
        
        # Set "Pre-Shared Key"
        @ff.select_list(:name,'wpa_sta_auth_type').select_value("1")
        self.msg(rule_name,:info,'Authentication Method',info['Authentication Method'])
 
      when '802.1X'
        
        # Set "802.1X"
        @ff.select_list(:name,'wpa_sta_auth_type').select_value("2")
        self.msg(rule_name,:info,'Authentication Method',info['Authentication Method'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa2()','Did NOT find the value in \'Authentication Method\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Pre-Shared Key(ASCII/Hex)"
    if info.has_key?('Pre-Shared Key(ASCII/Hex)') and
       info['Authentication Method'] == "Pre-Shared Key"
      
      case info['Pre-Shared Key(ASCII/Hex)']
      
      when 'Hex'
        
        # Set "Hex"
        @ff.select_list(:name,'psk_representation').select_value("0")
        self.msg(rule_name,:info,'Pre-Shared Key(ASCII/Hex)',info['Pre-Shared Key(ASCII/Hex)'])
        
        # "Pre-Shared Key"
        if info.has_key?('Pre-Shared Key')
          
          @ff.text_field(:name,'wpa_sta_auth_shared_key_hex').set(info['Pre-Shared Key'])
          self.msg(rule_name,:info,'Pre-Shared Key',info['Pre-Shared Key'])
          
        end         
 
      when 'ASCII'
        
        # Set "ASCII"
        @ff.select_list(:name,'psk_representation').select_value("1")
        self.msg(rule_name,:info,'Pre-Shared Key(ASCII/Hex)',info['Pre-Shared Key(ASCII/Hex)'])
        
        # "Pre-Shared Key"
        if info.has_key?('Pre-Shared Key')
          
          @ff.text_field(:name,'wpa_sta_auth_shared_key').set(info['Pre-Shared Key'])
          self.msg(rule_name,:info,'Pre-Shared Key',info['Pre-Shared Key'])
          
        end         
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa2()','Did NOT find the value in \'Pre-Shared Key(ASCII/Hex)\'.')
        return
        
      end # end of case
      
    end # end of if  
   
    # "Encryption Algorithm"
    if info.has_key?('Encryption Algorithm')
      
      case info['Encryption Algorithm']
      
      when 'TKIP'
        
        # Set "TKIP"
        @ff.select_list(:name,'wpa_cipher').select_value("1")
        self.msg(rule_name,:info,'Encryption Algorithm',info['Encryption Algorithm'])
 
      when 'AES'
        
        # Set "AES"
        @ff.select_list(:name,'wpa_cipher').select_value("2")
        self.msg(rule_name,:info,'Encryption Algorithm',info['Encryption Algorithm'])
        
      when 'TKIP and AES'
        
        # Set "TKIP and AES"
        @ff.select_list(:name,'wpa_cipher').select_value("3")
        self.msg(rule_name,:info,'Encryption Algorithm',info['Encryption Algorithm'])        
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa2()','Did NOT find the value in \'Encryption Algorithm\'.')
        return
        
      end # end of case
      
    end # end of if    

    # "Group Key Update Interval"
    if info.has_key?('Group Key Update Interval')
      
      case info['Group Key Update Interval']
      
      when 'on'
        
        # Set "Group Key Update Interval"
        @ff.checkbox(:name,'is_grp_key_update').set
        self.msg(rule_name,:info,'Group Key Update Interval',info['Group Key Update Interval'])
        
        # "Seconds"
        if info.has_key?('Seconds')
          
          @ff.text_field(:name,'8021x_rekeying_interval').set(info['Seconds'])
          self.msg(rule_name,:info,'Seconds',info['Seconds'])
          
        end        
 
      when 'off'
        
        # Clear "Group Key Update Interval"
        @ff.checkbox(:name,'is_grp_key_update').clear
        self.msg(rule_name,:info,'Group Key Update Interval',info['Group Key Update Interval'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wpa2()','Did NOT find the value in \'Group Key Update Interval\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "Server IP"
    if info.has_key?('Server IP')
      
      begin
        octets = info['Server IP'].split('.')
        @ff.text_field(:name, 'radius_client_server_ip0').set(octets[0])
        @ff.text_field(:name, 'radius_client_server_ip1').set(octets[1])
        @ff.text_field(:name, 'radius_client_server_ip2').set(octets[2])
        @ff.text_field(:name, 'radius_client_server_ip3').set(octets[3])
        self.msg(rule_name,:info,'Server IP',info['Server IP'])
      rescue
        self.msg(rule_name,:error,'wpa2()','Can NOT setup Server IP address.')
        return
      end
      
    end
    
    # "Server Port"
    if info.has_key?('Server Port')
      
      @ff.text_field(:name,'radius_client_server_port').set(info['Server Port'])
      self.msg(rule_name,:info,'Server Port',info['Server Port'])
      
    end
    
    # "Shared Secret"
    if info.has_key?('Shared Secret')
      
      @ff.text_field(:index,6).set(info['Shared Secret'])
      self.msg(rule_name,:info,'Shared Secret',info['Shared Secret'])
      
    end     
    
    # Apply for the change.
    if @ff.contains_text('Apply')
        @ff.link(:text,'Apply').click
    else
	self.msg(rule_name,:error,'Apply','Can NOT Apply WPA setting.')
        return
    end
    
    if  @ff.contains_text("Input Errors")
     errorTable=@ff.tables[18]
     errorTable_rowcount=errorTable.row_count
     for i in 1..errorTable_rowcount-1
       self.msg(rule_name, :PageInfo_Error, "DoSetup_General()->Apply (#{i})", errorTable.[](i).text)    
     end
    end

    # Output the result
    self.msg(rule_name,:info,'WPA2','SUCCESS')     
       
  end   

  #----------------------------------------------------------------------
  # ssidb(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by AdvancedSecuritySettings().
  #----------------------------------------------------------------------
  def ssidb(rule_name,info)
    
    # "Enable"
    if info.has_key?('Enable')
      
      case info['Enable']
      
      when 'on'
        
        # Set "Enable"
        @ff.radio(:id,'ssid_enable_type_1').set
        self.msg(rule_name,:info,'Enable',info['Enable'])
 
      when 'off'
        # Do nothing.
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'ssidb()','Did NOT find the value in \'Enable\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # "Disable"
    if info.has_key?('Disable')
      
      case info['Disable']
      
      when 'on'
        
        # Set "Enable"
        @ff.radio(:id,'ssid_enable_type_0').set
        self.msg(rule_name,:info,'Disable',info['Disable'])
 
      when 'off'
        # Do nothing.
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'ssidb()','Did NOT find the value in \'Disable\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # Apply for the change.
    @ff.link(:text,'Apply').click    

    # Output the result
    self.msg(rule_name,:info,'SSID Broadcast','SUCCESS') 
    
  end  
  
  #----------------------------------------------------------------------
  # wma(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by AdvancedSecuritySettings().
  #----------------------------------------------------------------------
  def wma(rule_name,info)
    
    # Now, Firefox should under "Wireless MAC Authentication" default page.
    # Check the page.
    if not @ff.text.include?'Wireless MAC Authentication'
      # Wrong here.
      self.msg(rule_name,:error,'wma()','Not reach the page.')
      return
    end   
    
    # Parse the json file. 
    
    # "Enable Access List"
    if info.has_key?('Enable Access List')
      
      case info['Enable Access List']
      
      when 'on'
        
        # Set "Enable"
        @ff.checkbox(:name,'wireless_mac_filter_enable').set
        self.msg(rule_name,:info,'Enable Access List',info['Enable Access List'])
 
      when 'off'

        # Clear "Enable"
        @ff.checkbox(:name,'wireless_mac_filter_enable').clear
        self.msg(rule_name,:info,'Enable Access List',info['Enable Access List'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wma()','Did NOT find the value in \'Enable Access List\'.')
        return
        
      end # end of case
      
    end # end of if
 
    # "Accept all devices listed below"
    if info.has_key?('Accept all devices listed below') and
       info['Enable Access List'] == "on"
      
      case info['Accept all devices listed below']
      
      when 'on'
        
        # Set "Enable"
        @ff.radio(:id,'mac1').set
        self.msg(rule_name,:info,'Accept all devices listed below',info['Accept all devices listed below'])
 
      when 'off'
        # Do nothing.
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wma()','Did NOT find the value in \'Accept all devices listed below\'.')
        return
        
      end # end of case
      
    end # end of if     
    
    # "Deny all devices listed below"
    if info.has_key?('Deny all devices listed below') and
       info['Enable Access List'] == "on"
      
      case info['Deny all devices listed below']
      
      when 'on'
        
        # Set "Enable"
        @ff.radio(:id,'mac3').set
        self.msg(rule_name,:info,'Deny all devices listed below',info['Deny all devices listed below'])
 
      when 'off'
        # Do nothing.
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'wma()','Did NOT find the value in \'Deny all devices listed below\'.')
        return
        
      end # end of case
      
    end # end of if    

    # "List"
    if info.has_key?('List') and
       info['Enable Access List'] == "on"      
      
      @ff.text_field(:id,'mac5').set(info['List'])
      self.msg(rule_name,:info,'List',info['List'])
      
      # Click add
      @ff.button(:text,"Add").click
      
    end   
    
    # Apply for the change.
    @ff.link(:text,'Apply').click

    # Output the result
    self.msg(rule_name,:info,'Wireless MAC Authentication','SUCCESS')       
    
  end
  
  #----------------------------------------------------------------------
  # _802mode(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by AdvancedSecuritySettings().
  #----------------------------------------------------------------------
  def _802mode(rule_name,info)
       
    # Now, Firefox should under "802.11b/g" default page.
    # Check the page.
    if not @ff.text.include?'802.11 Mode'
      # Wrong here.
      self.msg(rule_name,:error,'_802mode()','Not reach the page.')
      return
    end   
    
    # Parse the json file.   
    
    # "802.11 Mode"
    if info.has_key?('802.11 Mode')
      
      case info['802.11 Mode']
      
      when 'Compatibility Mode(802.11b/g/n)'
        
        @ff.select_list(:name,'wl_dot11_mode').select_value("1")
        self.msg(rule_name,:info,'802.11 Mode',info['802.11 Mode'])
 
      when 'Legacy Mode(802.11b/g)'
        
        @ff.select_list(:name,'wl_dot11_mode').select_value("2")
        self.msg(rule_name,:info,'802.11 Mode',info['802.11 Mode'])        
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'_802mode()','Did NOT find the value in \'802.11 Mode\'.')
        return
        
      end # end of case
      
    end # end of if  
    
    # Apply for the change.
    @ff.link(:text,'Apply').click    

    # Output the result
    self.msg(rule_name,:info,'802.11b/g','SUCCESS')     
    
  end  
  
end
