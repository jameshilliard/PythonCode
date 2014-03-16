################################################################
#     Firewall.rb
#     Author:          RuBingSheng, SuHe
#     Date:            since 2009.02.16
#     Contact:         Bru@actiontec.com
#     Discription:     Basic operation of Firewall Page
#     Input:           it depends
#     Output:          the result of operation
################################################################
$dir = File.dirname(__FILE__) 
require $dir+ '/../BasicUtility'

class Firewall < BasicUtility
  
  # firewall functions main page
  def firewall(rule_name, info)
    
    #execute super.firewall(rule_name, info) to go to firewall Page
    super
    
    # settings and testing on the firewall page
    # plsease add your code here...
    
    if info.key?('layout')
      case info['layout']
      when 'General'
        General(rule_name, info)
      when 'Access Control'
        AccessControl(rule_name, info)
      when 'Port Forwarding'
        PortForwarding(rule_name, info)
      when 'DMZ Host'
        DMZHost(rule_name, info)
      when 'Port Triggering'
        PortTriggering(rule_name, info)
      when 'Remote Administration'
        RemoteAdministration(rule_name, info)
      when 'Static NAT'
        StaticNAT(rule_name, info)
      when 'Advanced Filtering'
        AdvancedFiltering(rule_name, info)
      when 'Security Log'
        SecurityLog(rule_name, info)
      else
        self.msg(rule_name, :error, '', 'layout undefined')
      end
    else
      self.msg(rule_name, :error, '', 'No layout key found')
    end
  
  end
  
 def General(rule_name, info)
   if info.key?('page')
     case info['page']      
     when 'General'
       GoGeneralPage(rule_name, info)
       DoSetup_General(rule_name, info)
     else
       self.msg(rule_name, :error, 'General()', 'page undefined')
     end
   else
     self.msg(rule_name, :error, 'General()', 'No page key found')
   end
 end

 def AccessControl(rule_name, info)
   if info.key?('page')
     case info['page']      
     when 'Access Control'
       GoAccessControlPage(rule_name, info)
       DoSetup_AccessControl(rule_name, info)
     else
       self.msg(rule_name, :error, 'AccessControl()', 'page undefined')
     end
   else
     self.msg(rule_name, :error, 'AccessControl()', 'No page key found')
   end
 end

 def PortForwarding(rule_name, info)
   if info.key?('page')
     case info['page']      
     when 'Port Forwarding'
       GoPortForwardingPage(rule_name, info)
       DoSetup_PortForwarding(rule_name, info)
     else
       self.msg(rule_name, :error, 'PortForwarding()', 'page undefined')
     end
   else
     self.msg(rule_name, :error, 'PortForwarding()', 'No page key found')
   end
 end

 def DMZHost(rule_name, info)
   if info.key?('page')
     case info['page']      
     when 'DMZ Host'
       GoDMZHostPage(rule_name, info)
       DoSetup_DMZHost(rule_name, info)
     else
       self.msg(rule_name, :error, 'DMZHost()', 'page undefined')
     end
   else
     self.msg(rule_name, :error, 'DMZHost()', 'No page key found')
   end
 end

  #----------------------------------------------------------------------
  # PortTriggering(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------
  def PortTriggering(rule_name, info)
    
    if info.key?('page')
      case info['page']      
      when 'Port Triggering'
        GoPortTriggeringPage(rule_name, info)
        DoSetup_PortTriggering(rule_name, info)
      else
        self.msg(rule_name, :error, 'PortTriggering()', 'page undefined')
      end
    else
      self.msg(rule_name, :error, 'PortTriggering()', 'No page key found')
    end
    
  end

  #----------------------------------------------------------------------
  # RemoteAdministration(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by firewall().
  #---------------------------------------------------------------------- 
  def RemoteAdministration(rule_name, info)
    
    if info.key?('page')
      case info['page']      
      when 'Remote Administration'
        GoRemoteAdministrationPage(rule_name, info)
        DoSetup_RemoteAdministration(rule_name, info)
      else
        self.msg(rule_name, :error, 'RemoteAdministration()', 'page undefined')
      end
    else
      self.msg(rule_name, :error, 'RemoteAdministration()', 'No page key found')
    end
    
  end

  #----------------------------------------------------------------------
  # StaticNAT(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------  
  def StaticNAT(rule_name, info)
    
    if info.key?('page')
      
      case info['page']   
        
      when 'Static NAT'
        GoStaticNATPage(rule_name, info)
        DoSetup_StaticNAT(rule_name, info)
        
      else
        self.msg(rule_name, :error, 'StaticNAT()', 'page undefined')
        
      end # end of case
      
    else
      self.msg(rule_name, :error, 'StaticNAT()', 'No page key found')
      
    end # end of if
    
  end

   #----------------------------------------------------------------------
  # AdvancedFiltering(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by firewall().
  #---------------------------------------------------------------------- 
  def AdvancedFiltering(rule_name, info)
   
    # Get to the " Advanced Filtering" page.
    begin
      @ff.link(:text, 'Advanced Filtering').click
      self.msg(rule_name, :info, 'Advanced Filtering page', 'Reached!')
    rescue
      self.msg(rule_name, :error, 'Advanced Filtering', 'Did not reach the page')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('layout') &&
         info.has_key?('page') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'Advanced Filtering','Some key NOT found.')
      return
    end     
    
           
    # ************* Begin *************
    
    case info['page']
      
    when 'network_input' 
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 0%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end
    
      # Add this rule.
      add_advanced_filtering(rule_name,info)
      
    when 'ethernet_input'   
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 1%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end      
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)
      
    when 'broadband_ethernet_input'  
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 2%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end       
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)        
      
    when 'coax_input'  
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 3%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end        
      
      # Add this rule.
      add_advanced_filtering(rule_name,info) 
      
    when 'broadband_coax_input'  
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 4%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end       
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)    
      
    when 'wireless_input'  
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 5%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end        
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)    
      
    when 'network_output'  
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 6%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end        
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)       
      
    when 'ethernet_output'    
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 7%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end         
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)   
       
    when 'broadband_ethernet_output'  
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 8%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end      
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)   
      
    when 'coax_output'   
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 9%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end        
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)     
      
    when 'broadband_coax_output'   
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 10%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end       
      
      # Add this rule.
      add_advanced_filtering(rule_name,info) 
      
    when 'wireless_output'   
      
      # Click the "network_input" button.
      begin
        @ff.link(:href,'javascript:mimic_button(\'add: 11%5F..\', 1)').click
      rescue
        self.msg(rule_name,:error,'Advance Filetering','No such link, you must reset the BHR before the case.')
        return
      end       
      
      # Add this rule.
      add_advanced_filtering(rule_name,info)     
       
    else
      
      # Wrong here.
      self.msg(rule_name,:error,'Advanced Filtering','No such page name.')
      return
      
    end # end of case
    
    # Output the result.
    self.msg(rule_name,:Result_Info,'Advanced Filtering','SUCCESS')
     
    # ************* End ****************
    
  end # end of def

  #----------------------------------------------------------------------
  # SecurityLog(rule_name, info)
  # Author:      Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------
  def SecurityLog(rule_name, info)
   
   if info.key?('page')
     
     case info['page']  
       
     when 'Security Log'
       GoSecurityLogPage(rule_name, info)
       DoSetup_SecurityLog(rule_name, info)
       
     when 'Security Log Settings'  
       go_security_log_settings(rule_name,info)
       do_setup_security_log_settings(rule_name,info)
       
     else
       self.msg(rule_name, :error, 'SecurityLog()', 'page undefined')
       
     end
     
   else
     
     self.msg(rule_name, :error, 'SecurityLog()', 'No page key found')
     
   end
   
  end
 
 def GoGeneralPage(rule_name, info)
   # go to General Page 
   # click the 'General' link 
   begin
     @ff.link(:href, 'javascript:mimic_button(\'btn_tab_goto: 9000..\', 1)').click
   rescue
     self.msg(rule_name, :error, 'GoGeneralPage()', 'Did not reach General page')
     return
   end
 end
 
 def DoSetup_General(rule_name, info)    
   # Firewall Mode
   if info.key?('Firewall Mode')
     case info['Firewall Mode']
     when 'Maximum Security'
       @ff.radio(:id, 'sec_level_3').set   
       self.msg(rule_name, :info, 'DoSetup_General()->Firewall Mode', 'Firewall Mode = '+info['Firewall Mode'])
     when 'Typical Security'
       @ff.radio(:id, 'sec_level_2').set
       self.msg(rule_name, :info, 'DoSetup_General()->Firewall Mode', 'Firewall Mode = '+info['Firewall Mode'])
     when 'Minimum Security'
       @ff.radio(:id, 'sec_level_1').set
       self.msg(rule_name, :info, 'DoSetup_General()->Firewall Mode', 'Firewall Mode = '+info['Firewall Mode'])
     else
       self.msg(rule_name, :error, 'DoSetup_General()->Firewall Mode', 'Firewall Mode undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_General()->Firewall Mode', 'No Firewall Mode key found')
   end
   # Block IP Fragments
   if info.key?('Block IP Fragments')
     case info['Block IP Fragments']
     when 'on'
       @ff.checkbox(:name, 'sec_block_ipfrags').set
       self.msg(rule_name, :info, 'DoSetup_General()->Block IP Fragments', 'Block IP Fragments=on')
     when 'off'
       @ff.checkbox(:name, 'sec_block_ipfrags').clear
       self.msg(rule_name, :info, 'DoSetup_General()->Block IP Fragments', 'Block IP Fragments=off')           
     else
       self.msg(rule_name, :error, 'DoSetup_General()->Block IP Fragments', 'Block IP Fragments undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_General()->Block IP Fragments', 'No Block IP Fragments key found')
   end
   # click 'Apply' button to complete setup
   @ff.link(:text, 'Apply').click
   if  @ff.contains_text("Input Errors") 
     errorTable=@ff.tables[18]
     errorTable_rowcount=errorTable.row_count
     for i in 1..errorTable_rowcount-1
       self.msg(rule_name, :PageInfo_Error, "DoSetup_General()->Apply (#{i})", errorTable.[](i).text)    
     end 
     self.msg(rule_name, :error, 'DoSetup_General()->Apply', 'Firewall General setup fault')
   else
     if @ff.contains_text("Attention") 
       errorTable=@ff.tables[18]
       errorTable_rowcount=errorTable.row_count
       for i in 1..errorTable_rowcount-1
         self.msg(rule_name, :PageInfo_Error, "DoSetup_General()->Apply (#{i})", errorTable.[](i).text)    
       end 
       @ff.link(:text, 'Apply').click
       self.msg(rule_name, :result_info, 'DoSetup_General()->Apply', 'Firewall General setup sucessful with Attention')
     else
       self.msg(rule_name, :result_info, 'DoSetup_General()->Apply', 'Firewall General setup sucessful')
     end 
   end
 end
 
 def GoAccessControlPage(rule_name, info)
   # go to Access Control Page 
   # click the 'Access Control' link 
   begin
     @ff.link(:href, 'javascript:mimic_button(\'btn_tab_goto: 9002..\', 1)').click
   rescue
     self.msg(rule_name, :error, 'GoAccessControlPage()', 'Did not reach Access Control page')
     return
   end
 end
 
  def DoSetup_AccessControl(rule_name, info)
    ###
    # ckick 'Add' link 
    begin
      #@ff.link(:href, 'javascript:mimic_button(\'add: 0_..\', 1)').click
      @ff.link(:name, 'add').click
    rescue
      self.msg(rule_name, :error, 'DoSetup_AccessControl()->Add', 'Did not reach Add Access Control Rule page')
      return
    end
    # Networked Computer / Device
    if info.key?('Networked Computer / Device')
      case info['Networked Computer / Device']
      when 'Any'
        @ff.select_list(:id, 'sym_net_obj_src').select_value('ANY') 
        self.msg(rule_name, :info, 'DoSetup_AccessControl()->Networked Computer / Device', "Networked Computer / Device = "+info['Networked Computer / Device'])
      when 'User Defined'
        @ff.select_list(:id, 'sym_net_obj_src').select_value('USER_DEFINED') 
        self.msg(rule_name, :info, 'DoSetup_AccessControl()->Networked Computer / Device', "Networked Computer / Device = "+info['Networked Computer / Device'])
        ###
        # Description
        if info.key?('Description')  
          @ff.text_field(:name, 'desc').value=info['Description']
          self.msg(rule_name, :info, 'DoSetup_AccessControl()->Description', 'Description= '+info['Description'])
        else
          self.msg(rule_name, :info, 'DoSetup_AccessControl()->Description', 'No Description key found')
        end
        # Add
        begin
          #@ff.link(:href, 'javascript:mimic_button(\'add: 0_..\', 1)').click
          @ff.link(:name, 'add').click
        rescue
          self.msg(rule_name, :error, 'DoSetup_AccessControl()->Add in Edit Network Object', 'Did not reach Edit Item page')
          return
        end
        # Network Object Type
        if info.key?('Network Object Type')
          case info['Network Object Type']
          when 'IP Address'
            @ff.select_list(:id, 'net_obj_type').select_value('1') 
            self.msg(rule_name, :info, 'DoSetup_AccessControl()->Network Object Type', "Network Object Type = "+info['Network Object Type'])
            if info.key?('IP Address') and info['IP Address'].size > 0
              octets=info['IP Address'].split('.')
              @ff.text_field(:name, 'ip0').value=(octets[0])
              @ff.text_field(:name, 'ip1').value=(octets[1])
              @ff.text_field(:name, 'ip2').value=(octets[2])
              @ff.text_field(:name, 'ip3').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_AccessControl()->IP Address', "IP Address = "+info['IP Address'])
            else
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->IP Address', 'No IP Address key found')
            end
            # click 'Apply' button in IP Address Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->IP Address Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->IP Address Apply', 'IP Address setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->IP Address Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->IP Address Apply', 'IP Address setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->IP Address Apply', 'IP Address setup sucessful')
              end 
            end      
            # click 'Apply' button in Edit Network Object Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful')
              end 
            end    
          when 'IP Subnet'
            @ff.select_list(:id, 'net_obj_type').select_value('16') 
            self.msg(rule_name, :info, 'DoSetup_AccessControl()->Network Object Type', "Network Object Type = "+info['Network Object Type'])
            if info.key?('Subnet IP Address') and info['Subnet IP Address'].size > 0
              octets=info['Subnet IP Address'].split('.')
              @ff.text_field(:name, 'subnet_00').value=(octets[0])
              @ff.text_field(:name, 'subnet_01').value=(octets[1])
              @ff.text_field(:name, 'subnet_02').value=(octets[2])
              @ff.text_field(:name, 'subnet_03').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_AccessControl()->Subnet IP Address', "Subnet IP Address = "+info['Subnet IP Address'])
            else
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Subnet IP Address', 'No Subnet IP Address key found')
            end
            if info.key?('Subnet Mask') and info['Subnet Mask'].size > 0
              octets=info['Subnet Mask'].split('.')
              @ff.text_field(:name, 'subnet_10').value=(octets[0])
              @ff.text_field(:name, 'subnet_11').value=(octets[1])
              @ff.text_field(:name, 'subnet_12').value=(octets[2])
              @ff.text_field(:name, 'subnet_13').value=(octets[3])
              self.msg(rule_name, :info, 'DoSetup_AccessControl()->Subnet Mask', "Subnet Mask = "+info['Subnet Mask'])
            else
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Subnet Mask', 'No Subnet Mask key found')
            end
            # click 'Apply' button in IP Address Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->IP Subnet Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->IP Subnet Apply', 'IP Subnet setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->IP Subnet Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->IP Subnet Apply', 'IP Subnet setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->IP Subnet Apply', 'IP Subnet setup sucessful')
              end 
            end      
            # click 'Apply' button in Edit Network Object Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful')
              end 
            end    
          when 'IP Range'
            @ff.select_list(:id, 'net_obj_type').select_value('2') 
            self.msg(rule_name, :info, 'DoSetup_AccessControl()->Network Object Type', "Network Object Type = "+info['Network Object Type'])  
            if info.key?('From IP Address') and info['From IP Address'].size > 0
              octets=info['From IP Address'].split('.')
              @ff.text_field(:name, 'range_00').value=octets[0]
              @ff.text_field(:name, 'range_01').value=octets[1]
              @ff.text_field(:name, 'range_02').value=octets[2]
              @ff.text_field(:name, 'range_03').value=octets[3]
              self.msg(rule_name, :info, 'DoSetup_AccessControl()->From IP Address', "From IP Address = "+info['From IP Address'])
            else
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->From IP Address', 'No From IP Address key found')
            end
            if info.key?('To IP Address') and info['To IP Address'].size > 0
              octets=info['To IP Address'].split('.')
              @ff.text_field(:name, 'range_10').value=octets[0]
              @ff.text_field(:name, 'range_11').value=octets[1]
              @ff.text_field(:name, 'range_12').value=octets[2]
              @ff.text_field(:name, 'range_13').value=octets[3]
              self.msg(rule_name, :info, 'DoSetup_AccessControl()->To IP Address', "To IP Address = "+info['To IP Address'])
            else
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->To IP Address', 'No To IP Address key found')
            end
            # click 'Apply' button in IP Range Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->IP Range Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->IP Range Apply', 'IP Range setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->IP Range Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->IP Range Apply', 'IP Range setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->IP Range Apply', 'IP Range setup sucessful')
              end 
            end      
            # click 'Apply' button in Edit Network Object Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful')
              end 
            end    
          when 'Host Name'
            @ff.select_list(:id, 'net_obj_type').select_value('8') 
            self.msg(rule_name, :info, 'DoSetup_AccessControl()->Network Object Type', "Network Object Type = "+info['Network Object Type'])
            if info.key?('Host Name')  
              @ff.text_field(:name, 'hostname').value=info['Host Name']
              self.msg(rule_name, :info, 'DoSetup_AccessControl()->Host Name', 'Host Name= '+info['Host Name'])
            else
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Host Name', 'No Host Name key found')
            end
            # click 'Apply' button 
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Host Name Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Host Name Apply', 'Host Name setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Host Name Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Host Name Apply', 'Host Name setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Host Name Apply', 'Host Name setup sucessful')
              end 
            end      
            # click 'Apply' button in Edit Network Object Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful')
              end 
            end         
          when 'DHCP Option'
            @ff.select_list(:id, 'net_obj_type').select_value('64') 
            self.msg(rule_name, :info, 'DoSetup_AccessControl()->Network Object Type', "Network Object Type = "+info['Network Object Type'])   
            if info.key?('Type ID')
              case info['Type ID']
              when 'Vendor Class ID'
                @ff.select_list(:id, 'dhcp_opt_code').select_value('60')
                self.msg(rule_name, :info, 'DoSetup_AccessControl()->Type ID', 'Type ID = '+info['Type ID'])
                if info.key?('Vendor Class ID')
                  @ff.text_field(:name, 'dhcp_opt_type').value=info['Vendor Class ID']
                  self.msg(rule_name, :info, 'DoSetup_AccessControl()->Vendor Class ID', "Vendor Class ID = "+info['Vendor Class ID'])
                else
                  self.msg(rule_name, :error, 'DoSetup_AccessControl()->Vendor Class ID', 'No Vendor Class ID key found')
                end        
              when 'Client ID'
                @ff.select_list(:id, 'dhcp_opt_code').select_value('61')
                self.msg(rule_name, :info, 'DoSetup_AccessControl()->Type ID', 'Type ID = '+info['Type ID'])
                if info.key?('Client ID')
                  @ff.text_field(:name, 'dhcp_opt_type').value=info['Client ID']
                  self.msg(rule_name, :info, 'DoSetup_AccessControl()->Client ID', "Client ID = "+info['Client ID'])
                else
                  self.msg(rule_name, :error, 'DoSetup_AccessControl()->Client ID', 'No Client ID key found')
                end
              when 'User Class ID'
                @ff.select_list(:id, 'dhcp_opt_code').select_value('77')
                self.msg(rule_name, :info, 'DoSetup_AccessControl()->Type ID', 'Type ID = '+info['Type ID'])
                if info.key?('User Class ID')
                  @ff.text_field(:name, 'dhcp_opt_type').value=info['User Class ID']
                  self.msg(rule_name, :info, 'DoSetup_AccessControl()->User Class ID', "User Class ID = "+info['User Class ID'])
                else
                  self.msg(rule_name, :error, 'DoSetup_AccessControl()->User Class ID', 'No User Class ID key found')
                end          
              else
                self.msg(rule_name, :error, 'DoSetup_AccessControl()->Type ID', 'Type ID undefined')
              end
            else
              self.msg(rule_name, :info, 'DoSetup_AccessControl()->Type ID', 'No Type ID key found')
            end
            # click 'Apply' button 
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Host Name Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Host Name Apply', 'Host Name setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Host Name Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Host Name Apply', 'Host Name setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Host Name Apply', 'Host Name setup sucessful')
              end 
            end      
            # click 'Apply' button in Edit Network Object Page
            @ff.link(:text, 'Apply').click
            if  @ff.contains_text("Input Errors")      
              #n=@ff.tables.length     
              errorTable=@ff.tables[18]
              errorTable_rowcount=errorTable.row_count
              for i in 1..errorTable_rowcount-1
                self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
              end 
              self.msg(rule_name, :error, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup fault')   
            else
              if @ff.contains_text("Attention") 
                errorTable=@ff.tables[18]
                errorTable_rowcount=errorTable.row_count
                for i in 1..errorTable_rowcount-1
                  self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Edit Network Object Apply (#{i})", errorTable.[](i).text)    
                end 
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful with Attention')
              else
                self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Edit Network Object Apply', 'Edit Network Object setup sucessful')
              end 
            end        
          else
            self.msg(rule_name, :info, 'DoSetup_AccessControl()->Network Object Type', 'Network Object Type undefined')
          end
        else
          self.msg(rule_name, :info, 'DoSetup_AccessControl()->Network Object Type', 'No Network Object Type key found')
        end
        ###
      else
        self.msg(rule_name, :info, 'DoSetup_AccessControl()->Networked Computer / Device', 'Networked Computer / Device undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_AccessControl()->Networked Computer / Device', 'No Networked Computer / Device key found')
    end
    # Protocol
    if info.key?('Protocol')
      case info['Protocol']
      when 'Any'
        @ff.select_list(:id, 'svc_service_combo').select_value('ANY') 
        self.msg(rule_name, :info, 'DoSetup_AccessControl()->Protocol', "Protocol = "+info['Protocol'])
      else
        self.msg(rule_name, :info, 'DoSetup_AccessControl()->Protocol', 'Protocol undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_AccessControl()->Protocol', 'No Protocol key found')
    end
    # When should this rule occur?
    if info.key?('When should this rule occur?')
      case info['When should this rule occur?']
      when 'Always'
        @ff.select_list(:id, 'schdlr_rule_id').select_value('ALWAYS') 
        self.msg(rule_name, :info, 'DoSetup_AccessControl()->When should this rule occur?', "When should this rule occur? = "+info['When should this rule occur?'])
      else
        self.msg(rule_name, :info, 'DoSetup_AccessControl()->When should this rule occur?', 'When should this rule occur? undefined')
      end
    else
      self.msg(rule_name, :info, 'DoSetup_AccessControl()->When should this rule occur?', 'No When should this rule occur? key found')
    end
    # click 'Apply' button to complete setup
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors")      
      #n=@ff.tables.length     
      errorTable=@ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "DoSetup_AccessControl()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'DoSetup_AccessControl()->Apply', 'Add Access Control Rule setup fault')   
    else
      if @ff.contains_text("Attention") 
        errorTable=@ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Attention, "DoSetup_AccessControl()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Apply', 'Add Access Control Rule setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'DoSetup_AccessControl()->Apply', 'Add Access Control Rule setup sucessful')
      end 
    end
    ###
  end
 
 def GoPortForwardingPage(rule_name, info)
   # go to Port Forwarding Page 
   # click the 'Port Forwarding' link 
   begin
     @ff.link(:href, 'javascript:mimic_button(\'btn_tab_goto: 9011..\', 1)').click
   rescue
     self.msg(rule_name, :error, 'GoPortForwardingPage()', 'Did not reach Port Forwarding page')
     return
   end
 end
 
 def DoSetup_PortForwarding(rule_name, info)
   #####
   # ckick 'Add' link 
   begin
     #@ff.link(:href, 'javascript:mimic_button(\'add: 0_..\', 1)').click
     @ff.link(:name, 'add').click
   rescue
     self.msg(rule_name, :error, 'DoSetup_PortForwarding()->Add', 'Did not reach Add Port Forwarding page')
     return
   end
   # Add Port Forwarding Rule
   # Specify Public IP Address
   if info.key?('Specify Public IP Address')
     case info['Specify Public IP Address']
     when 'on'
       @ff.checkbox(:name, 'specify_public_ip').set
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Specify Public IP Address', 'Specify Public IP Address=on')
       # Public IP Address
       if info.key?('Public IP Address') and info['Public IP Address'].size > 0
         octets=info['Public IP Address'].split('.')
         @ff.text_field(:name, 'public_ip0').set(octets[0])
         @ff.text_field(:name, 'public_ip1').set(octets[1])
         @ff.text_field(:name, 'public_ip2').set(octets[2])
         @ff.text_field(:name, 'public_ip3').set(octets[3])
         self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Public IP Address', "Public IP Address = "+info['Public IP Address'])
       else
         self.msg(rule_name, :error, 'DoSetup_PortForwarding()->Public IP Address', 'No Public IP Address key found')
       end
     when 'off'
       @ff.checkbox(:name, 'specify_public_ip').clear
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Specify Public IP Address', 'Specify Public IP Address=off')           
     else
       self.msg(rule_name, :error, 'DoSetup_PortForwarding()->Specify Public IP Address', 'Specify Public IP Address undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Specify Public IP Address', 'No Specify Public IP Address key found')
   end
   # Local Host
   if info.key?('Local Host')
     case info['Local Host']
     when 'Specify Address'
       @ff.select_list(:id, 'local_host_list').select_value('specify_address') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Local Host', "Local Host = "+info['Local Host'])
       # Local Host IP Address
       if info.key?('Local Host IP Address') and info['Local Host IP Address'].size > 0
         @ff.text_field(:name, 'local_host').set(info['Local Host IP Address'])
         self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Local Host IP Address', "Local Host IP Address = "+info['Local Host IP Address'])
       else
         self.msg(rule_name, :error, 'DoSetup_PortForwarding()->Local Host IP Address', 'No Local Host IP Address key found')
       end        
     else
       self.msg(rule_name, :error, 'DoSetup_PortForwarding()->Local Host', 'Local Host undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Local Host', 'No Local Host key found')
   end
   # Protocol
   if info.key?('Protocol')
     case info['Protocol']
     when 'Any'
       @ff.select_list(:id, 'svc_service_combo').select_value('ANY') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Protocol', "Protocol = "+info['Protocol'])
     else
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Protocol', 'Protocol undefined or need to extend in Ruby code')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Protocol', 'No Protocol key found')
   end
   # WAN Connection Type
   if info.key?('WAN Connection Type')
     case info['WAN Connection Type']
     when 'All Broadband Devices'
       @ff.select_list(:id, 'wan_device').select_value('all_wan') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->WAN Connection Type', "WAN Connection Type = "+info['WAN Connection Type'])
     when 'Broadband Connection (Ethernet)'
       @ff.select_list(:id, 'wan_device').select_value('eth1') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->WAN Connection Type', "WAN Connection Type = "+info['WAN Connection Type'])
     when 'Broadband Connection (Coax)'
       @ff.select_list(:id, 'wan_device').select_value('clink1') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->WAN Connection Type', "WAN Connection Type = "+info['WAN Connection Type'])
     when 'WAN PPPoE'
       @ff.select_list(:id, 'wan_device').select_value('ppp0') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->WAN Connection Type', "WAN Connection Type = "+info['WAN Connection Type'])
     when 'WAN PPPoE 2'
       @ff.select_list(:id, 'wan_device').select_value('ppp1') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->WAN Connection Type', "WAN Connection Type = "+info['WAN Connection Type'])
     else
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->WAN Connection Type', 'WAN Connection Type undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_PortForwarding()->WAN Connection Type', 'No WAN Connection Type key found')
   end
   # Forward to Port
   if info.key?('Forward to Port')
     case info['Forward to Port']
     when 'Same as Incoming Port'
       @ff.select_list(:id, 'fwd_port_combo').select_value('0') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Forward to Port', "Forward to Port = "+info['Forward to Port'])
     else
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Forward to Port', 'Forward to Port undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_PortForwarding()->Forward to Port', 'No Forward to Port key found')
   end
   # When should this rule occur
   if info.key?('When should this rule occur')
     case info['When should this rule occur']
     when 'Always'
       @ff.select_list(:id, 'schdlr_rule_id').select_value('ALWAYS') 
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->When should this rule occur', "When should this rule occur = "+info['When should this rule occur'])
     else
       self.msg(rule_name, :info, 'DoSetup_PortForwarding()->When should this rule occur', 'When should this rule occur undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_PortForwarding()->When should this rule occur', 'No When should this rule occur key found')
   end
   # click 'Apply' button to complete setup
   @ff.link(:text, 'Apply').click
   if  @ff.contains_text("Input Errors") 
     errorTable=@ff.tables[18]
     errorTable_rowcount=errorTable.row_count
     for i in 1..errorTable_rowcount-1
       self.msg(rule_name, :PageInfo_Error, "DoSetup_PortForwarding()->Apply (#{i})", errorTable.[](i).text)    
     end 
     self.msg(rule_name, :error, 'DoSetup_PortForwarding()->Apply', 'Add Port Forwarding Rule setup fault')
   else
     if @ff.contains_text("Attention") 
       errorTable=@ff.tables[18]
       errorTable_rowcount=errorTable.row_count
       for i in 1..errorTable_rowcount-1
         self.msg(rule_name, :PageInfo_Error, "DoSetup_PortForwarding()->Apply (#{i})", errorTable.[](i).text)    
       end 
       @ff.link(:text, 'Apply').click
       self.msg(rule_name, :result_info, 'DoSetup_PortForwarding()->Apply', 'Add Port Forwarding Rule setup sucessful with Attention')
     else
       self.msg(rule_name, :result_info, 'DoSetup_PortForwarding()->Apply', 'Add Port Forwarding Rule setup sucessful')
     end 
   end
   #####
 end
 
 def GoDMZHostPage(rule_name, info)
   # go to DMZ Host Page 
   # click the 'DMZ Host' link 
   begin
     @ff.link(:href, 'javascript:mimic_button(\'btn_tab_goto: 9016..\', 1)').click
   rescue
     self.msg(rule_name, :error, 'GoDMZHostPage()', 'Did not reach DMZ Host page')
     return
   end
 end
 
 def DoSetup_DMZHost(rule_name, info)
   # DMZ Host
   if info.key?('DMZ Host')
     case info['DMZ Host']
     when 'on'
       @ff.checkbox(:name, 'dmz_host_cb').set
       self.msg(rule_name, :info, 'DoSetup_DMZHost()->DMZ Host', 'DMZ Host=on')
     when 'off'
       @ff.checkbox(:name, 'dmz_host_cb').clear
       self.msg(rule_name, :info, 'DoSetup_DMZHost()->DMZ Host', 'DMZ Host=off')           
     else
       self.msg(rule_name, :error, 'DoSetup_DMZHost()->DMZ Host', 'DMZ Host undefined')
     end
   else
     self.msg(rule_name, :info, 'DoSetup_DMZHost()->DMZ Host', 'No DMZ Host key found')
   end
   # DMZ Host IP Address
   if info.key?('DMZ Host IP Address') and info['DMZ Host IP Address'].size > 0
     octets=info['DMZ Host IP Address'].split('.')
     @ff.text_field(:name, 'dmz_host_ip0').set(octets[0])
     @ff.text_field(:name, 'dmz_host_ip1').set(octets[1])
     @ff.text_field(:name, 'dmz_host_ip2').set(octets[2])
     @ff.text_field(:name, 'dmz_host_ip3').set(octets[3])
     self.msg(rule_name, :info, 'DoSetup_DMZHost()->DMZ Host IP Address', "DMZ Host IP Address = "+info['DMZ Host IP Address'])
   else
     self.msg(rule_name, :info, 'DoSetup_DMZHost()->DMZ Host IP Address', 'No DMZ Host IP Address key found')
   end
   # click 'Apply' button to complete setup
   @ff.link(:text, 'Apply').click
   if  @ff.contains_text("Input Errors") 
     errorTable=@ff.tables[18]
     errorTable_rowcount=errorTable.row_count
     for i in 1..errorTable_rowcount-1
       self.msg(rule_name, :PageInfo_Error, "DoSetup_DMZHost()->Apply (#{i})", errorTable.[](i).text)    
     end 
     self.msg(rule_name, :error, 'DoSetup_DMZHost()->Apply', 'DMZ Host setup fault')
   else
     if @ff.contains_text("Attention") 
       errorTable=@ff.tables[18]
       errorTable_rowcount=errorTable.row_count
       for i in 1..errorTable_rowcount-1
         self.msg(rule_name, :PageInfo_Error, "DoSetup_DMZHost()->Apply (#{i})", errorTable.[](i).text)    
       end 
       @ff.link(:text, 'Apply').click
       self.msg(rule_name, :result_info, 'DoSetup_DMZHost()->Apply', 'DMZ Host setup sucessful with Attention')
     else
       self.msg(rule_name, :result_info, 'DoSetup_DMZHost()->Apply', 'DMZ Host setup sucessful')
     end 
   end
 end
 
  #----------------------------------------------------------------------
  # GoPortTriggeringPage(rule_name, info)
  # Author :Su He
  # Description: Inside function, will be called by firewall().
  #----------------------------------------------------------------------  
  def GoPortTriggeringPage(rule_name, info)
   
    # Now, Firefox should under "Firewall Settings" default page.
    # Check the page.
    if not @ff.text.include?'Port Triggering'
      # Wrong here.
      self.msg(rule_name,:error,'GoPortTriggeringPage()','No such link.')
      return
    end
   
    begin
      # Click the link
      @ff.link(:text,'Port Triggering').click
      self.msg(rule_name,:info,'GoPortTriggeringPage()','SUCCESS')
    rescue
      self.msg(rule_name,:error,'GoPortTriggeringPage()','Wrong,no such link')
      return
    end     
    
  end
 
  #----------------------------------------------------------------------
  # DoSetup_PortTriggering(rule_name, info)
  # Author :Su He
  # Description: Inside function, will be called by firewall().
  #---------------------------------------------------------------------- 
  def DoSetup_PortTriggering(rule_name, info)
   
    # Now, Firefox should under "Port Triggering" default page.
    # Check the page.
    if not @ff.text.include?'Trigger opening of ports for incoming data'
      # Wrong here.
      self.msg(rule_name,:error,'DoSetup_PortTriggering()','No such link.')
      return
    end   
    
    # Parse the json file.
    
    # "User Defined"
    if info.has_key?('User Defined')
      
      case info['User Defined']
      
      when 'on'
        
        # Set "User Defined"
        @ff.refresh
        @ff.select_list(:name,'svc_service_combo').select_value("USER_DEFINED")
        
        # Check the page.
        if not @ff.text.include?'Edit Port Triggering Rule'
          self.msg(rule_name,:error,'Port Triggering','Did not enter the \'User Defined\' page.')
          return
        end
        
        self.msg(rule_name,:info,'User Defined',info['User Defined'])
 
      when 'off'
        
        # Clear "User Defined"
        # Do nothing here, when "off", terminal the function.
        self.msg(rule_name,:info,'User Defined',info['User Defined'])
        return
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Port Triggering','Did NOT find the value in \'User Defined\'.')
        return
        
      end # end of case
      
    else # else of if
      self.msg(rule_name,:error,'Port Triggering','This version must have\'User Defined\' option')
      return
      
    end # end of if  
    
    # "Service Name"
    if info.has_key?('Service Name')
      
      # Fill in the text
      @ff.text_field(:name,'svc_name').set(info['Service Name'])
      self.msg(rule_name,:info,'Service Name',info['Service Name'])
      
    end       
      
    # "New Trigger Ports"
    if info.has_key?('New Trigger Ports')
      
      case info['New Trigger Ports']
      
      when 'on'
        
        # Set "New Trigger Ports"
        @ff.refresh
        @ff.link(:text,'New Trigger Ports').click
        
        # Check the page.
        if not @ff.text.include?'Edit Service Server Ports'
          self.msg(rule_name,:error,'Port Triggering','Did not enter the \'Edit Service Server Ports\' page.')
          return
        end
        
        self.msg(rule_name,:info,'New Trigger Ports',info['New Trigger Ports'])
 
      when 'off'
        
        # Clear "User Defined"
        # Do nothing here, when "off", terminal the function.
        self.msg(rule_name,:info,'New Trigger Ports',info['New Trigger Ports'])
        self.msg(rule_name,:error,'New Trigger Ports','Not on')
        return
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Port Triggering','Did NOT find the value in \'New Trigger Ports\'.')
        return
        
      end # end of case
      
    else # else of if
      self.msg(rule_name,:error,'Port Triggering','This version must have\'New Trigger Ports\' option on')
      self.msg(rule_name,:error,'New Trigger Ports','Not on')
      return
      
    end # end of if  

    # "Trigger Ports(Other)"
    if info.has_key?('Trigger Ports(Other)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("-1")
        @ff.text_field(:name,'svc_entry_protocol_num').set(info['Trigger Ports(Other)'])
        self.msg(rule_name,:info,'Trigger Ports(Other)',info['Trigger Ports(Other)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Trigger Ports(Other)')
        return
      end
      
    end
    
    # "Trigger Ports(TCP)"
    if info.has_key?('Trigger Ports(TCP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("6")
        ports = info['Trigger Ports(TCP)'].split('/')
        
        case ports[0]
        when 'Any'
          @ff.select_list(:name,'port_src_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_src_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_src_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such trigger port tcp.')
          return
        end
        
        case ports[1]
        when 'Any'
          @ff.select_list(:name,'port_dst_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_dst_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_dst_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such trigger port tcp.')
          return
        end        
        
        self.msg(rule_name,:info,'Trigger Ports(TCP)',info['Trigger Ports(TCP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Trigger Ports(TCP)')
        return
      end
      
    end    
    
    # "Trigger Ports(UDP)"
    if info.has_key?('Trigger Ports(UDP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("17")
        ports = info['Trigger Ports(UDP)'].split('/')
        
        case ports[0]
        when 'Any'
          @ff.select_list(:name,'port_src_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_src_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_src_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such trigger port udp.')
          return
        end
        
        case ports[1]
        when 'Any'
          @ff.select_list(:name,'port_dst_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_dst_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_dst_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such trigger port udp.')
          return
        end        
        
        self.msg(rule_name,:info,'Trigger Ports(UDP)',info['Trigger Ports(UDP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Trigger Ports(UDP)')
        return
      end
      
    end     
    
    # "Trigger Ports(ICMP)"
    if info.has_key?('Trigger Ports(ICMP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("1")
        
        case info['Trigger Ports(ICMP)']
        when 'Echo Reply'
          @ff.select_list(:name,'icmp_combo').select_value("0")
        when 'Network Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("768")
        when 'Host Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("769")
        when 'Protocol Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("770")
        when 'Port Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("771")
        when 'Destination Network Unkown'
          @ff.select_list(:name,'icmp_combo').select_value("774")
        when 'Destination Host Unkown'
          @ff.select_list(:name,'icmp_combo').select_value("775")
        when 'Redirect for Network'
          @ff.select_list(:name,'icmp_combo').select_value("1280")
        when 'Redirect for Host'
          @ff.select_list(:name,'icmp_combo').select_value("1281")
        when 'Echo Request'
          @ff.select_list(:name,'icmp_combo').select_value("2048")
        else
          self.msg(rule_name,:error,'Port Triggering','No such trigger port icmp.')
          return
        end          
        
        self.msg(rule_name,:info,'Trigger Ports(ICMP)',info['Trigger Ports(ICMP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Trigger Ports(ICMP)')
        return
      end
      
    end    
    
    # "Trigger Ports(GRE)"
    if info.has_key?('Trigger Ports(GRE)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("47")
        
        case info['Trigger Ports(GRE)']
        when 'on'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').set  
        when 'off'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').clear
        else
          self.msg(rule_name,:error,'Port Triggering','No such \'Trigger Ports(GRE)\' value.')
          return
        end        
        
        self.msg(rule_name,:info,'Trigger Ports(GRE)',info['Trigger Ports(GRE)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Trigger Ports(GRE)')
        return
      end
      
    end    
    
    # "Trigger Ports(ESP)"
    if info.has_key?('Trigger Ports(ESP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("50")
        
        case info['Trigger Ports(ESP)']
        when 'on'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').set  
        when 'off'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').clear
        else
          self.msg(rule_name,:error,'Port Triggering','No such \'Trigger Ports(ESP)\' value.')
          return
        end        
        
        self.msg(rule_name,:info,'Trigger Ports(ESP)',info['Trigger Ports(ESP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Trigger Ports(ESP)')
        return
      end
      
    end   
    
    # "Trigger Ports(AH)"
    if info.has_key?('Trigger Ports(AH)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("51")
        
        case info['Trigger Ports(AH)']
        when 'on'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').set  
        when 'off'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').clear
        else
          self.msg(rule_name,:error,'Port Triggering','No such \'Trigger Ports(AH)\' value.')
          return
        end        
        
        self.msg(rule_name,:info,'Trigger Ports(AH)',info['Trigger Ports(AH)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Trigger Ports(AH)')
        return
      end
      
    end     
    
    # Apply for the trigger ports.
    @ff.link(:text,'Apply').click
    
    # "New Opened Ports"
    if info.has_key?('New Opened Ports')
      
      case info['New Opened Ports']
      
      when 'on'
        
        # Set "New Trigger Ports"
        @ff.refresh
        @ff.link(:text,'New Opened Ports').click
        
        # Check the page.
        if not @ff.text.include?'Edit Service Opened Ports'
          self.msg(rule_name,:error,'Port Triggering','Did not enter the \' Edit Service Opened Ports\' page.')
          return
        end
        
        self.msg(rule_name,:info,'New Opened Ports',info['New Opened Ports'])
 
      when 'off'
        
        # Clear "User Defined"
        # Do nothing here, when "off", terminal the function.
        self.msg(rule_name,:info,'New Opened Ports',info['New Opened Ports'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Port Triggering','Did NOT find the value in \'New Opened Ports\'.')
        return
        
      end # end of case
           
    end # end of if  

    # "Opened Ports(Other)"
    if info.has_key?('Opened Ports(Other)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("-1")
        @ff.text_field(:name,'svc_entry_protocol_num').set(info['Opened Ports(Other)'])
        self.msg(rule_name,:info,'Opened Ports(Other)',info['Opened Ports(Other)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Opened Ports(Other)')
        return
      end
      
    end
    
    # "Opened Ports(TCP)"
    if info.has_key?('Opened Ports(TCP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("6")
        ports = info['Opened Ports(TCP)'].split('/')
        
        case ports[0]
        when 'Any'
          @ff.select_list(:name,'port_src_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_src_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_src_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such opened port tcp.')
          return
        end
        
        case ports[1]
        when 'Any'
          @ff.select_list(:name,'port_dst_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_dst_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_dst_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such opened port tcp.')
          return
        end        
        
        self.msg(rule_name,:info,'Opened Ports(TCP)',info['Opened Ports(TCP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Opened Ports(TCP)')
        return
      end
      
    end    
    
    # "Opened Ports(UDP)"
    if info.has_key?('Opened Ports(UDP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("17")
        ports = info['Opened Ports(UDP)'].split('/')
        
        case ports[0]
        when 'Any'
          @ff.select_list(:name,'port_src_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_src_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_src_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such opened port udp.')
          return
        end
        
        case ports[1]
        when 'Any'
          @ff.select_list(:name,'port_dst_combo').select_value("3")
        when 'Single'
          @ff.select_list(:name,'port_dst_combo').select_value("1")
        when 'Range'
          @ff.select_list(:name,'port_dst_combo').select_value("2")
        else
          self.msg(rule_name,:error,'Port Triggering','No such opened port udp.')
          return
        end        
        
        self.msg(rule_name,:info,'Opened Ports(UDP)',info['Opened Ports(UDP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in opened Ports(UDP)')
        return
      end
      
    end     
    
    # "Opened Ports(ICMP)"
    if info.has_key?('Opened Ports(ICMP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("1")
        
        case info['Opened Ports(ICMP)']
        when 'Echo Reply'
          @ff.select_list(:name,'icmp_combo').select_value("0")
        when 'Network Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("768")
        when 'Host Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("769")
        when 'Protocol Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("770")
        when 'Port Unreachable'
          @ff.select_list(:name,'icmp_combo').select_value("771")
        when 'Destination Network Unkown'
          @ff.select_list(:name,'icmp_combo').select_value("774")
        when 'Destination Host Unkown'
          @ff.select_list(:name,'icmp_combo').select_value("775")
        when 'Redirect for Network'
          @ff.select_list(:name,'icmp_combo').select_value("1280")
        when 'Redirect for Host'
          @ff.select_list(:name,'icmp_combo').select_value("1281")
        when 'Echo Request'
          @ff.select_list(:name,'icmp_combo').select_value("2048")
        else
          self.msg(rule_name,:error,'Port Triggering','No such opened port icmp.')
          return
        end          
        
        self.msg(rule_name,:info,'Opened Ports(ICMP)',info['Opened Ports(ICMP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Opened Ports(ICMP)')
        return
      end
      
    end    
    
    # "Opened Ports(GRE)"
    if info.has_key?('Opened Ports(GRE)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("47")
        
        case info['Opened Ports(GRE)']
        when 'on'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').set  
        when 'off'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').clear
        else
          self.msg(rule_name,:error,'Port Triggering','No such \'Opened Ports(GRE)\' value.')
          return
        end        
        
        self.msg(rule_name,:info,'Opened Ports(GRE)',info['Opened Ports(GRE)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Opened Ports(GRE)')
        return
      end
      
    end    
    
    # "Opened Ports(ESP)"
    if info.has_key?('Opened Ports(ESP)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("50")
        
        case info['Opened Ports(ESP)']
        when 'on'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').set  
        when 'off'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').clear
        else
          self.msg(rule_name,:error,'Port Triggering','No such \'Opened Ports(ESP)\' value.')
          return
        end        
        
        self.msg(rule_name,:info,'Opened Ports(ESP)',info['Opened Ports(ESP)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Opened Ports(ESP)')
        return
      end
      
    end   
    
    # "Opened Ports(AH)"
    if info.has_key?('Opened Ports(AH)')
      
      begin
        @ff.select_list(:name,'svc_entry_protocol').select_value("51")
        
        case info['Opened Ports(AH)']
        when 'on'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').set  
        when 'off'
          @ff.checkbox(:name,'svc_entry_protocol_exclude').clear
        else
          self.msg(rule_name,:error,'Port Triggering','No such \'Opened Ports(AH)\' value.')
          return
        end        
        
        self.msg(rule_name,:info,'Opened Ports(AH)',info['Opened Ports(AH)'])
      rescue
        self.msg(rule_name,:error,'Port Triggering','Error in Opened Ports(AH)')
        return
      end
      
    end         
    
    # Apply for the opened ports
    @ff.link(:text,'Apply').click
    
    # Apply the change.
    begin
      @ff.link(:text,'Apply').click
      self.msg(rule_name,:info,'Apply for a \'Port Triggering\'.','CLICKED')
    rescue
      self.msg(rule_name,:error,'Port Triggering','Can NOT Apply the port triggering.')
      return
    end    
    
    # Error message?
    if @ff.text.include?'Input Errors'
      # Error here.
      
      # Find the table.
      sTable = false
      @ff.tables.each do |t|
        if ( t.text.include? 'Server Ports:' and 
             ( not t.text.include? 'Input Errors') and
             ( not t.text.include? 'Cancel') and
             t.row_count == 1 )then
          sTable = t
          break
        end
      end
      
      if sTable == false
        # Wrong here
        self.msg(rule_name,:error,'Port Triggering','Did NOT find the target table.')
        return
      end
      
      strError = sTable[1][2]
      
      self.msg(rule_name,:Result_Error,'Port Triggering',strError)
      return
      
    end    
    
    # Output the result
    self.msg(rule_name,:Result_Info,'Port Triggering','SUCCESS')
   
  end
 
  #----------------------------------------------------------------------
  # GoRemoteAdministrationPage(rule_name, info)
  # Author :Su He
  # Description: Inside function, will be called by firewall().
  #---------------------------------------------------------------------- 
  def GoRemoteAdministrationPage(rule_name, info)
   
    # Now, Firefox should under "Firewall Settings" default page.
    # Check the page.
    if not @ff.text.include?'Remote Administration'
      # Wrong here.
      self.msg(rule_name,:error,'GoRemoteAdministrationPage()','No such link.')
      return
    end
   
    begin
      # Click the link
      @ff.link(:text,'Remote Administration').click
      self.msg(rule_name,:info,'GoRemoteAdministrationPage()','SUCCESS')
    rescue
      self.msg(rule_name,:error,'GoRemoteAdministrationPage()','Wrong,no such link')
      return
    end    
   
  end
 
 
  #----------------------------------------------------------------------
  # DoSetup_RemoteAdministration(rule_name, info)
  # Author :Su He
  # Description: Inside function, will be called by firewall().
  #---------------------------------------------------------------------- 
  def DoSetup_RemoteAdministration(rule_name, info)
    
    # Now, Firefox should under "Remote Administration" default page.
    # Check the page.
    if not @ff.text.include?'Configure Remote Administration to the router'
      # Wrong here.
      self.msg(rule_name,:error,'DoSetup_RemoteAdministration()','No such link.')
      return
    end   
    
    # Parse the json file. 

    # "Using Primary Telnet Port (23)"
    if info.has_key?('Using Primary Telnet Port (23)')
      
      case info['Using Primary Telnet Port (23)']
      
      when 'on'
        
        # Set "Using Primary Telnet Port"
        @ff.checkbox(:name,'is_telnet_primary').set
        self.msg(rule_name,:info,'Using Primary Telnet Port (23)',info['Using Primary Telnet Port (23)'])
 
      when 'off'
        
        # Clear "Using Primary Telnet Port"
        @ff.checkbox(:name,'is_telnet_primary').clear
        self.msg(rule_name,:info,'Using Primary Telnet Port (23)',info['Using Primary Telnet Port (23)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Using Primary Telnet Port (23)\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secondary Telnet Port (8023)"
    if info.has_key?('Using Secondary Telnet Port (8023)')
      
      case info['Using Secondary Telnet Port (8023)']
      
      when 'on'
        
        # Set "Using Secondary Telnet Port"
        @ff.checkbox(:name,'is_telnet_secondary').set
        self.msg(rule_name,:info,'Using Secondary Telnet Port (8023)',info['Using Secondary Telnet Port (8023)'])
 
      when 'off'
        
        # Clear "Using Secondary Telnet Port"
        @ff.checkbox(:name,'is_telnet_secondary').clear
        self.msg(rule_name,:info,'Using Secondary Telnet Port (8023)',info['Using Secondary Telnet Port (8023)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Using Secondary Telnet Port (8023)\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secure Telnet over SSL Port"
    if info.has_key?('Using Secure Telnet over SSL Port (992)')
      
      case info['Using Secure Telnet over SSL Port (992)']
      
      when 'on'
        
        # Set "Using Secure Telnet over SSL Port"
        @ff.checkbox(:name,'is_telnet_ssl').set
        self.msg(rule_name,:info,'Using Secure Telnet over SSL Port (992)',info['Using Secure Telnet over SSL Port (992)'])
 
      when 'off'
        
        # Clear "Using Secure Telnet over SSL Port"
        @ff.checkbox(:name,'is_telnet_ssl').clear
        self.msg(rule_name,:info,'Using Secure Telnet over SSL Port (992)',info['Using Secure Telnet over SSL Port (992)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Using Secure Telnet over SSL Port (992)\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Primary HTTP Port (80)"
    if info.has_key?('Using Primary HTTP Port (80)')
      
      case info['Using Primary HTTP Port (80)']
      
      when 'on'
        
        # Set "Using Primary HTTP Port"
        @ff.checkbox(:name,'is_http_primary').set
        self.msg(rule_name,:info,'Using Primary HTTP Port (80)',info['Using Primary HTTP Port (80)'])
 
      when 'off'
        
        # Clear "Using Primary HTTP Port"
        @ff.checkbox(:name,'is_http_primary').clear
        self.msg(rule_name,:info,'Using Primary HTTP Port (80)',info['Using Primary HTTP Port (80)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Using Primary HTTP Port (80)\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secondary HTTP Port (8080)"
    if info.has_key?('Using Secondary HTTP Port (8080)')
      
      case info['Using Secondary HTTP Port (8080)']
      
      when 'on'
        
        # Set "Using Secondary HTTP Port"
        @ff.checkbox(:name,'is_http_secondary').set
        self.msg(rule_name,:info,'Using Secondary HTTP Port (8080)',info['Using Secondary HTTP Port (8080)'])
 
      when 'off'
        
        # Clear "Using Secondary HTTP Port"
        @ff.checkbox(:name,'is_http_secondary').clear
        self.msg(rule_name,:info,'Using Secondary HTTP Port (8080)',info['Using Secondary HTTP Port (8080)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Using Secondary HTTP Port (8080)\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Primary HTTPS Port (443)"
    if info.has_key?('Using Primary HTTPS Port (443)')
      
      case info['Using Primary HTTPS Port (443)']
      
      when 'on'
        
        # Set "Using Primary HTTPS Port"
        @ff.checkbox(:name,'is_https_primary').set
        self.msg(rule_name,:info,'Using Primary HTTPS Port (443)',info['Using Primary HTTPS Port (443)'])
 
      when 'off'
        
        # Clear "Using Primary HTTPS Port"
        @ff.checkbox(:name,'is_https_primary').clear
        self.msg(rule_name,:info,'Using Primary HTTPS Port (443)',info['Using Primary HTTPS Port (443)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Using Primary HTTPS Port (443)\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Using Secondary HTTPS Port (8443)"
    if info.has_key?('Using Secondary HTTPS Port (8443)')
      
      case info['Using Secondary HTTPS Port (8443)']
      
      when 'on'
        
        # Set "Using Secondary HTTPS Port (8443)"
        @ff.checkbox(:name,'is_https_secondary').set
        self.msg(rule_name,:info,'Using Secondary HTTPS Port (8443)',info['Using Secondary HTTPS Port (8443)'])
 
      when 'off'
        
        # Clear "Using Secondary HTTPS Port (8443)"
        @ff.checkbox(:name,'is_https_secondary').clear
        self.msg(rule_name,:info,'Using Secondary HTTPS Port (8443)',info['Using Secondary HTTPS Port (8443)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Using Secondary HTTPS Port (8443)\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)"
    if info.has_key?('Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)')
      
      case info['Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)']
      
      when 'on'
        
        # Set "Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)"
        @ff.checkbox(:name,'is_diagnostics_icmp').set
        self.msg(rule_name,:info,'Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)',info['Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)'])
 
      when 'off'
        
        # Clear "Allow Incoming WAN ICMP Echo Requests"
        @ff.checkbox(:name,'is_diagnostics_icmp').clear
        self.msg(rule_name,:info,'Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)',info['Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Allow Incoming WAN ICMP Echo Requests (e.g. pings and ICMP traceroute queries)\'.')
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
        self.msg(rule_name,:error,'DoSetup_RemoteAdministration','Did NOT find the value in \'Allow Incoming WAN UDP Traceroute Queries\'.')
        return
        
      end # end of case
      
    end # end of if    
    
    # Apply for the change
    @ff.link(:text,'Apply').click
    
    # Output the result.
    self.msg(rule_name,:info,"Set remote administration",'SUCCESS')   
  
  end

  #----------------------------------------------------------------------
  # GoStaticNATPage(rule_name, info)
  # Author :Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------  
  def GoStaticNATPage(rule_name, info)
    
    # Now, Firefox should under "Firewall Settings" default page.
    # Check the page.
    if not @ff.text.include?'Static NAT'
      # Wrong here.
      self.msg(rule_name,:error,'GoStaticNATPage()','No such link.')
      return
    end
   
    begin
      # Click the link
      @ff.link(:text,'Static NAT').click
      self.msg(rule_name,:info,'GoStaticNATPage()','SUCCESS')
    rescue
      self.msg(rule_name,:error,'GoStaticNATPage()','Wrong,no such link')
      return
    end 
    
  end
 
  #----------------------------------------------------------------------
  # DoSetup_StaticNAT(rule_name, info)
  # Author :Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------  
  def DoSetup_StaticNAT(rule_name, info)
    
    # Now, Firefox should under "Static NAT" default page.
    # Check the page.
    if not @ff.text.include?'Static IP Mapping Table'
      # Wrong here.
      self.msg(rule_name,:error,'DoSetup_StaticNAT()','No such link.')
      return
    end   
    
    # Parse the json file.
    
    # Add a "NAT" first.
    begin
      @ff.link(:text,'Add').click
      self.msg(rule_name,:info,'Add a \'NAT\'','CLICKED')
    rescue
      self.msg(rule_name,:error,'DoSetup_StaticNAT','Can NOT add a NAT')
      return
    end   
    
    # "Local Host"
    if info.has_key?('Local Host')
      
      begin
        # Choose the "Specify Address".
        @ff.select_list(:name,'local_host_list').select_value("specify_address")
        
        # Fill in the IP address.
        @ff.text_field(:name,'local_host').set(info['Local Host'])
        self.msg(rule_name,:info,'Local Host',info['Local Host'])
      rescue
        self.msg(rule_name,:error,'DoSetup_StaticNAT','Can NOT setup local host.')
        return
      end
      
    end 
    
    # "Public IP Address"
    if info.has_key?('Public IP Address')
      
      begin
        octets = info['Public IP Address'].split('.')
        @ff.text_field(:name, 'public_ip0').set(octets[0])
        @ff.text_field(:name, 'public_ip1').set(octets[1])
        @ff.text_field(:name, 'public_ip2').set(octets[2])
        @ff.text_field(:name, 'public_ip3').set(octets[3])
        self.msg(rule_name,:info,'Public IP Address',info['Public IP Address'])
      rescue
        self.msg(rule_name,:error,'DoSetup_StaticNAT','Can NOT setup public IP address.')
        return
      end
      
    end   
    
    # "WAN Connection Type"
    if info.has_key?('WAN Connection Type')
      
      begin
        # Choose the "WAN Connection Type".
        case info['WAN Connection Type']
        when 'All Broadband Devices'
          @ff.select_list(:name,'wan_device').select_value("all_wan")
        when 'Broadband Connection (Ethernet)'
          @ff.select_list(:name,'wan_device').select_value("eth1")
        when 'Broadband Connection (Coax)'
          @ff.select_list(:name,'wan_device').select_value("clink1")
        when 'WAN PPPoE'
          @ff.select_list(:name,'wan_device').select_value("ppp0")
        when 'WAN PPPoE 2'
          @ff.select_list(:name,'wan_device').select_value("ppp1")          
        else
          self.msg(rule_name,:error,'DoSetup_StaticNAT','NO such \'WAN Connection Type\' value.')
          return
        end

        self.msg(rule_name,:info,'WAN Connection Type',info['WAN Connection Type'])
      rescue
        self.msg(rule_name,:error,'DoSetup_StaticNAT','Can NOT setup \'WAN Connection Type\'.')
        return
      end
      
    end  
    
    # "Enable Port Forwarding For Static NAT"
    if info.has_key?('Enable Port Forwarding For Static NAT')
      
      begin
        case info['Enable Port Forwarding For Static NAT']
        when 'on'
          @ff.checkbox(:name,'static_nat_local_server_enabled').set
        when 'off'
          @ff.checkbox(:name,'static_nat_local_server_enabled').clear          
        else
          self.msg(rule_name,:error,'DoSetup_StaticNAT','NO such \'Enable Port Forwarding For Static NAT\' value.')
          return
        end
        
        self.msg(rule_name,:info,'Enable Port Forwarding For Static NAT',info['Enable Port Forwarding For Static NAT'])
        
      rescue
        self.msg(rule_name,:error,'DoSetup_StaticNAT','Can NOT setup \'Enable Port Forwarding For Static NAT\'.')
        return
      end
      
    end     
    
    # Apply the change.
    begin
      @ff.link(:text,'Apply').click
      self.msg(rule_name,:info,'Apply for a \'NAT\'','CLICKED')
    rescue
      self.msg(rule_name,:error,'DoSetup_StaticNAT','Can NOT Apply the NAT setup')
      return
    end     
    
    # Output the result
    self.msg(rule_name,:Result_Info,'Static NAT','SUCCESS')      
  
  end # end of def
 
 def GoAdvancedFilteringPage(rule_name, info)
   #  
 end
 
 def DoSetup_AdvancedFiltering(rule_name, info)
   #
 end
   
  #----------------------------------------------------------------------
  # GoSecurityLogPage(rule_name, info)
  # Author :Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------   
  def GoSecurityLogPage(rule_name, info)
   
    # Now, Firefox should under "Firewall Settings" default page.
    # Check the page.
    if not @ff.text.include?'Security Log'
      # Wrong here.
      self.msg(rule_name,:error,'GoSecurityLogPage()','No such link.')
      return
    end
   
    begin
      # Click the link
      @ff.link(:text,'Security Log').click
      self.msg(rule_name,:info,'GoSecurityLogPage()','SUCCESS')
    rescue
      self.msg(rule_name,:error,'GoSecurityLogPage()','Wrong,no such link')
      return
    end   
  
  end
 
  #----------------------------------------------------------------------
  # DoSetup_SecurityLog(rule_name, info)
  # Author :Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------   
  def DoSetup_SecurityLog(rule_name, info)
   
    # Now, Firefox should under "Security Log" default page.
    # Check the page.
    if not @ff.text.include?'Press the Refresh button to update the data'
      # Wrong here.
      self.msg(rule_name,:error,'DoSetup_SecurityLog()','No such link.')
      return
    end   
    
    # Parse the json file. 
    
    # "Clear Log"
    if info.has_key?('Clear Log')
      
      case info['Clear Log']
      
      when 'on'
        
        # Set "Clear Log"
        # Different version may be different here.
        begin
          @ff.link(:text,'Clear Log').click
        rescue
          self.msg(rule_name,:error,'Security Log','No \'Clear Log\' button in this version.')
          self.msg(rule_name,Result_Error,'Security Log','No \'Clear Log\' button in this version.')
          return
        end
        
        # Confirm it
        if @ff.text.include?'Attention'
          @ff.link(:text,'Apply').click
        end
        self.msg(rule_name,:info,'Clear Log',info['Clear Log'])
 
      when 'off'
        
        # Do nothing.
        self.msg(rule_name,:info,'Clear Log',info['Clear Log'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Security Log','Did NOT find the value in \'Clear Log\'.')
        return
        
      end # end of case
      
    end # end of if  

    # "Save Log"
    if info.has_key?('Save Log')
           
      begin
        # Click "Save Log"
        @ff.link(:text,'Save Log').click
        self.msg(rule_name,:info,'Save Log',info['Save Log'])
      rescue     
        # Wrong here
        self.msg(rule_name,:error,'Security Log','\'Save Log\' error.')
        return
      end
            
    end # end of if  

    # "Refresh"
    if info.has_key?('Refresh')
      
      case info['Refresh']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Refresh').click
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Security Log','Did NOT find the value in \'Refresh\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Hazard"
    if info.has_key?('Hazard')
      
      case info['Hazard']
      
      when 'on'
        
        # Set "Hazard"
        @ff.link(:text,'Hazard').click
        self.msg(rule_name,:info,'Hazard',info['Hazard'])
 
      when 'off'
        
        # Clear "Hazard"
        # Do nothing.
        self.msg(rule_name,:info,'Hazard',info['Hazard'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Security Log','Did NOT find the value in \'Hazard\'.')
        return
        
      end # end of case
      
    end # end of if   
    
    # Output the result here.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Time' and 
           t.text.include? 'Event' and
           ( not t.text.include? 'Press the Refresh button to update the data') and
           t.row_count >= 1 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'Security Log','Did NOT find the target table.')
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
      strEntry = "Log" + (iFlag - 1).to_s
      
      # Output in to the result.
      self.msg(rule_name,strEntry,'Time',row[1])
      self.msg(rule_name,strEntry,'Event',row[2])
      self.msg(rule_name,strEntry,'Event-Type',row[3])
      self.msg(rule_name,strEntry,'Details',row[4])
      
    end     

    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end

    # Output the result
    self.msg(rule_name,:Result_Info,'Security Log','SUCCESS')   
   
 end

  #----------------------------------------------------------------------
  # go_security_log_settings(rule_name, info)
  # Author :Su He
  # Discription: Inside function, will be called by firewall().
  #----------------------------------------------------------------------   
  def go_security_log_settings(rule_name, info)
   
    # Now, Firefox should under "Firewall Settings" default page.
    # Check the page.
    if not @ff.text.include?'Security Log'
      # Wrong here.
      self.msg(rule_name,:error,'go_security_log_settings()','No such link.')
      return
    end
   
    begin
      # Click the link
      @ff.link(:text,'Security Log').click
      @ff.link(:text,'Settings').click
      self.msg(rule_name,:info,'go_security_log_settings()','SUCCESS')
    rescue
      self.msg(rule_name,:error,'go_security_log_settings()','Wrong,no such link')
      return
    end   
  
  end 

  #----------------------------------------------------------------------
  # do_setup_security_log_settings(rule_name, info)
  # Author :Su He
  # Discription: Inside function, will be called by firewall().
  #---------------------------------------------------------------------- 
  def do_setup_security_log_settings(rule_name,info)
    
    # Now, Firefox should under "Log Settings" default page.
    # Check the page.
    if not @ff.text.include?'Log Settings'
      # Wrong here.
      self.msg(rule_name,:error,'do_setup_security_log_settings()','Not reach the page.')
      return
    end   
    
    # Parse the json file. 

    # ------------ Begin ---------------
    # "Accepted Incoming Connections"
    if info.has_key?('Accepted Incoming Connections')

      case info['Accepted Incoming Connections']
        
      when 'on'        
        begin
          # Set the check box "Accepted Incoming Connections"        
          @ff.checkbox(:name,'log_conn_acc_in').set
          self.msg(rule_name,:info,'Accepted Incoming Connections',info['Accepted Incoming Connections'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Accepted Incoming Connections\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Accepted Incoming Connections"        
          @ff.checkbox(:name,'log_conn_acc_in').clear
          self.msg(rule_name,:info,'Accepted Incoming Connections',info['Accepted Incoming Connections'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Accepted Incoming Connections\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Accepted Incoming Connections\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End ---------------      

    # ------------ Begin ---------------
    # "Accepted Outgoing Connections"
    if info.has_key?('Accepted Outgoing Connections')

      case info['Accepted Outgoing Connections']
        
      when 'on'        
        begin
          # Set the check box "Accepted Outgoing Connections"        
          @ff.checkbox(:name,'log_conn_acc_out').set
          self.msg(rule_name,:info,'Accepted Outgoing Connections',info['Accepted Outgoing Connections'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Accepted Outgoing Connections\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Accepted Outgoing Connections"        
          @ff.checkbox(:name,'log_conn_acc_out').clear
          self.msg(rule_name,:info,'Accepted Outgoing Connections',info['Accepted Outgoing Connections'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Accepted Outgoing Connections\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Accepted Outgoing Connections\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "All Blocked Connection Attempts"
    if info.has_key?('All Blocked Connection Attempts')

      case info['All Blocked Connection Attempts']
        
      when 'on'        
        begin
          # Set the check box "All Blocked Connection Attempts"        
          @ff.checkbox(:name,'log_conn_blk').set
          self.msg(rule_name,:info,'All Blocked Connection Attempts',info['All Blocked Connection Attempts'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'All Blocked Connection Attempts\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "All Blocked Connection Attempts"        
          @ff.checkbox(:name,'log_conn_blk').clear
          self.msg(rule_name,:info,'All Blocked Connection Attempts',info['All Blocked Connection Attempts'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'All Blocked Connection Attempts\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'All Blocked Connection Attempts\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Winnuke"
    if info.has_key?('Winnuke')

      case info['Winnuke']
        
      when 'on'        
        begin
          # Set the check box "Winnuke"        
          @ff.checkbox(:name,'log_winnuke').set
          self.msg(rule_name,:info,'Winnuke',info['Winnuke'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Winnuke\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Winnuke"        
          @ff.checkbox(:name,'log_winnuke').clear
          self.msg(rule_name,:info,'Winnuke',info['Winnuke'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Winnuke\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Winnuke\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Multicast/Broadcast"
    if info.has_key?('Multicast/Broadcast')

      case info['Multicast/Broadcast']
        
      when 'on'        
        begin
          # Set the check box "Multicast/Broadcast"        
          @ff.checkbox(:name,'log_broadcast').set
          self.msg(rule_name,:info,'Multicast/Broadcast',info['Multicast/Broadcast'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Multicast/Broadcast\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Multicast/Broadcast"        
          @ff.checkbox(:name,'log_broadcast').clear
          self.msg(rule_name,:info,'Multicast/Broadcast',info['Multicast/Broadcast'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Multicast/Broadcast\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Multicast/Broadcast\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Defragmentation Error"
    if info.has_key?('Defragmentation Error')

      case info['Defragmentation Error']
        
      when 'on'        
        begin
          # Set the check box "Defragmentation Error"        
          @ff.checkbox(:name,'log_badfrag').set
          self.msg(rule_name,:info,'Defragmentation Error',info['Defragmentation Error'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Defragmentation Error\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Defragmentation Error"        
          @ff.checkbox(:name,'log_badfrag').clear
          self.msg(rule_name,:info,'Defragmentation Error',info['Defragmentation Error'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Defragmentation Error\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Defragmentation Error\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Spoofed Connection"
    if info.has_key?('Spoofed Connection')

      case info['Spoofed Connection']
        
      when 'on'        
        begin
          # Set the check box "Spoofed Connection"        
          @ff.checkbox(:name,'log_spoofed').set
          self.msg(rule_name,:info,'Spoofed Connection',info['Spoofed Connection'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Spoofed Connection\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Spoofed Connection"        
          @ff.checkbox(:name,'log_spoofed').clear
          self.msg(rule_name,:info,'Spoofed Connection',info['Spoofed Connection'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Spoofed Connection\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Spoofed Connection\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Blocked Fragments"
    if info.has_key?('Blocked Fragments')

      case info['Blocked Fragments']
        
      when 'on'        
        begin
          # Set the check box "Blocked Fragments"        
          @ff.checkbox(:name,'log_frag').set
          self.msg(rule_name,:info,'Blocked Fragments',info['Blocked Fragments'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Blocked Fragments\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Blocked Fragments"        
          @ff.checkbox(:name,'log_frag').clear
          self.msg(rule_name,:info,'Blocked Fragments',info['Blocked Fragments'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Blocked Fragments\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Blocked Fragments\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Packet Ilegal Options"
    if info.has_key?('Packet Ilegal Options')

      case info['Packet Ilegal Options']
        
      when 'on'        
        begin
          # Set the check box "Packet Ilegal Options"        
          @ff.checkbox(:name,'log_illegal_ops').set
          self.msg(rule_name,:info,'Packet Ilegal Options',info['Packet Ilegal Options'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Packet Ilegal Options\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Packet Ilegal Options"        
          @ff.checkbox(:name,'log_illegal_ops').clear
          self.msg(rule_name,:info,'Packet Ilegal Options',info['Packet Ilegal Options'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Packet Ilegal Options\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Packet Ilegal Options\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Syn Flood"
    if info.has_key?('Syn Flood')

      case info['Syn Flood']
        
      when 'on'        
        begin
          # Set the check box "Syn Flood"        
          @ff.checkbox(:name,'log_synflood').set
          self.msg(rule_name,:info,'Syn Flood',info['Syn Flood'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Syn Flood\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Syn Flood"        
          @ff.checkbox(:name,'log_synflood').clear
          self.msg(rule_name,:info,'Syn Flood',info['Syn Flood'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Syn Flood\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Syn Flood\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "UDP Flood"
    if info.has_key?('UDP Flood')

      case info['UDP Flood']
        
      when 'on'        
        begin
          # Set the check box "UDP Flood"        
          @ff.checkbox(:name,'log_udpflood').set
          self.msg(rule_name,:info,'UDP Flood',info['UDP Flood'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'UDP Flood\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "UDP Flood"        
          @ff.checkbox(:name,'log_udpflood').clear
          self.msg(rule_name,:info,'UDP Flood',info['UDP Flood'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'UDP Flood\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'UDP Flood\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Echo Chargen"
    if info.has_key?('Echo Chargen')

      case info['Echo Chargen']
        
      when 'on'        
        begin
          # Set the check box "Echo Chargen"        
          @ff.checkbox(:name,'log_echo_chargen').set
          self.msg(rule_name,:info,'Echo Chargen',info['Echo Chargen'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Echo Chargen\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Echo Chargen"        
          @ff.checkbox(:name,'log_echo_chargen').clear
          self.msg(rule_name,:info,'Echo Chargen',info['Echo Chargen'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Echo Chargen\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Echo Chargen\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "ICMP Replay"
    if info.has_key?('ICMP Replay')

      case info['ICMP Replay']
        
      when 'on'        
        begin
          # Set the check box "ICMP Replay"        
          @ff.checkbox(:name,'log_icmpreplay').set
          self.msg(rule_name,:info,'ICMP Replay',info['ICMP Replay'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Replay\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "ICMP Replay"        
          @ff.checkbox(:name,'log_icmpreplay').clear
          self.msg(rule_name,:info,'ICMP Replay',info['ICMP Replay'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Replay\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'ICMP Replay\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "ICMP Redirect"
    if info.has_key?('ICMP Redirect')

      case info['ICMP Redirect']
        
      when 'on'        
        begin
          # Set the check box "ICMP Redirect"        
          @ff.checkbox(:name,'log_icmp_redirect').set
          self.msg(rule_name,:info,'ICMP Redirect',info['ICMP Redirect'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Redirect\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "ICMP Redirect"        
          @ff.checkbox(:name,'log_icmp_redirect').clear
          self.msg(rule_name,:info,'ICMP Redirect',info['ICMP Redirect'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Redirect\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'ICMP Redirect\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "ICMP Multicast"
    if info.has_key?('ICMP Multicast')

      case info['ICMP Multicast']
        
      when 'on'        
        begin
          # Set the check box "ICMP Multicast"        
          @ff.checkbox(:name,'log_icmp_multicast').set
          self.msg(rule_name,:info,'ICMP Multicast',info['ICMP Multicast'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Multicast\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "ICMP Multicast"        
          @ff.checkbox(:name,'log_icmp_multicast').clear
          self.msg(rule_name,:info,'ICMP Multicast',info['ICMP Multicast'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Multicast\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'ICMP Multicast\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "ICMP Flood"
    if info.has_key?('ICMP Flood')

      case info['ICMP Flood']
        
      when 'on'        
        begin
          # Set the check box "ICMP Flood"        
          @ff.checkbox(:name,'log_icmpflood').set
          self.msg(rule_name,:info,'ICMP Flood',info['ICMP Flood'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Flood\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "ICMP Flood"        
          @ff.checkbox(:name,'log_icmpflood').clear
          self.msg(rule_name,:info,'ICMP Flood',info['ICMP Flood'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'ICMP Flood\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'ICMP Flood\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Remote Administration Attempts"
    if info.has_key?('Remote Administration Attempts')

      case info['Remote Administration Attempts']
        
      when 'on'        
        begin
          # Set the check box "Remote Administration Attempts"        
          @ff.checkbox(:name,'log_remote_admin').set
          self.msg(rule_name,:info,'Remote Administration Attempts',info['Remote Administration Attempts'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Remote Administration Attempts\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Remote Administration Attempts"        
          @ff.checkbox(:name,'log_remote_admin').clear
          self.msg(rule_name,:info,'Remote Administration Attempts',info['Remote Administration Attempts'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Remote Administration Attempts\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Remote Administration Attempts\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Connection States"
    if info.has_key?('Connection States')

      case info['Connection States']
        
      when 'on'        
        begin
          # Set the check box "Connection States"        
          @ff.checkbox(:name,'log_conn_state').set
          self.msg(rule_name,:info,'Connection States',info['Connection States'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Connection States\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Connection States"        
          @ff.checkbox(:name,'log_conn_state').clear
          self.msg(rule_name,:info,'Connection States',info['Connection States'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Connection States\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Connection States\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 

    # ------------ Begin ---------------
    # "Prevent Log Overrun"
    if info.has_key?('Prevent Log Overrun')

      case info['Prevent Log Overrun']
        
      when 'on'        
        begin
          # Set the check box "Prevent Log Overrun"        
          @ff.checkbox(:name,'log_no_overrun').set
          self.msg(rule_name,:info,'Prevent Log Overrun',info['Prevent Log Overrun'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Prevent Log Overrun\'.')
          return
        end # end of begin
      
      when 'off'
        begin
          # Clear the check box "Prevent Log Overrun"        
          @ff.checkbox(:name,'log_no_overrun').clear
          self.msg(rule_name,:info,'Prevent Log Overrun',info['Prevent Log Overrun'])
        rescue
          self.msg(rule_name,:error,'do_setup_security_log_settings','Error in \'Prevent Log Overrun\'.')
          return
        end # end of begin   

      else
        # Wrong here
        self.msg(rule_name,:error,'do_setup_security_log_settings','No such value in\'Prevent Log Overrun\'. ')
        return
      
      end # end of case
        
    end # end of if
    # ------------ End --------------- 
       
    # Apply for the change.
    if @ff.text.include?'Apply'
      @ff.link(:text,'Apply').click
    end        

    # Output the result.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Time' and 
           t.text.include? 'Event' and
           ( not t.text.include? 'Press the Refresh button to update the data') and
           t.row_count >= 1 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'Security Log Settings','Did NOT find the target table.')
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
      strEntry = "Log" + (iFlag - 1).to_s
      
      # Output in to the result.
      self.msg(rule_name,strEntry,'Time',row[1])
      self.msg(rule_name,strEntry,'Event',row[2])
      self.msg(rule_name,strEntry,'Event-Type',row[3])
      self.msg(rule_name,strEntry,'Details',row[4])
      
    end     
    
    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end

    # Output the result
    self.msg(rule_name,:Result_Info,'Security Log Settings','SUCCESS')      
    
    
  end
  
  #----------------------------------------------------------------------
  # add_advanced_filtering(rule_name,info)(rule_name, info)
  # Author :Su He
  # Discription: function of "Traffic Priority" under "Qos" page.
  #              This is a inside function.
  #----------------------------------------------------------------------
  def add_advanced_filtering(rule_name,info)
    
    # Now, the page must be the "Add Advanced Filter" page.
    if not @ff.text.include?'Add Advanced Filter'
      # Wrong here
      self.msg(rule_name,:error,'add_advanced_filtering','Not in this page.')
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
        self.msg(rule_name,:error,'add_advanced_filtering','Source address wrong.')
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
        self.msg(rule_name,:error,'add_advanced_filtering','Destination Address wrong.')
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
        self.msg(rule_name,:error,'add_advanced_filtering','Protocol wrong.')
        return
      end    
      
    end    
    
    # "DSCP"
    if info.has_key?('DSCP')
      
      case info['DSCP']
      when 'on'
        @ff.checkbox(:name, 'dscp_check_box').set
        self.msg(rule_name,:info,'DSCP',info['DSCP'])
      else
        # Wrong here 
        self.msg(rule_name,:error,'add_advanced_filtering','DSCP wrong.')
        return
      end    
      
    end     
    
    # "Priority"
    if info.has_key?('Priority')
      
      @ff.checkbox(:name, 'prio_check_box').set
      
      case info['Priority']
        
      when 'on'
        # Do nothing here.
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
        self.msg(rule_name,:error,'add_advanced_filtering','No such option')
        return
      
      end # end of the case
      
      self.msg(rule_name, :info, 'Priority' , info['Priority'])
      
    end # end of if  
    
    # "Length"
    if info.has_key?('Length')
      
      case info['Length']
      when 'on'
        @ff.checkbox(:name, 'length_check_box').set
        self.msg(rule_name,:info,'Length',info['Length'])
      else
        # Wrong here 
        self.msg(rule_name,:error,'add_advanced_filtering','Length wrong.')
        return
      end    
      
    end     
    
    # "Operation"
    if info.has_key?('Operation')    
      
      case info['Operation']
        
      when 'Drop'
        @ff.select_list(:name, 'rule_operation').select_value("0")
      when 'Reject'
        @ff.select_list(:name, 'rule_operation').select_value("5")
      when 'Accept Connection'
        @ff.select_list(:name, 'rule_operation').select_value("1")
      when 'Accept Packet'
        @ff.select_list(:name, 'rule_operation').select_value("2")
      else
        # Wrong here.
        self.msg(rule_name,:error,'add_advanced_filtering','No such option')
        return
      
      end # end of the case
      
      self.msg(rule_name, :info, 'Operation', info['Operation'])
      
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
        self.msg(rule_name,:error,'add_advanced_filtering','Did NOT find the value in \'Log Packets Matched by This Rule\'.')
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
        self.msg(rule_name,:error,'add_advanced_filtering','Did NOT find the value in \'When should this rule occur\'.')
        return
        
      end # end of case
      
    end # end of if     

    # Apply for the change
    @ff.link(:text,'Apply').click
    @ff.wait
    
    # Attention?
    if @ff.text.include?'Attention'
      # Click the "Apply"
      self.msg(rule_name,:warning,'add_advanced_filtering','Cause an \'Attention\'.')
      @ff.link(:text,'Apply').click
    end
    
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
        self.msg(rule_name,:error,'add_advanced_filtering','Did NOT find the target table.')
        return
      end
      
      strError = sTable[1][2]
      
      self.msg(rule_name,:Result_Error,'add_advanced_filtering',strError)
      return
      
    end
    
    # Output the result
    self.msg(rule_name,:info,'add_advanced_filtering','SUCCESS')
    
  end # end of def.  
  
end
