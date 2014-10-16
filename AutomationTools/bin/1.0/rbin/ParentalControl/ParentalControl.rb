################################################################
#     ParentalControl.rb
#     Author:          RuBingSheng
#     Date:            since 2009.02.16
#     Contact:         Bru@actiontec.com
#     Discription:     Basic operation of Parental Control Page
#     Input:           it depends
#     Output:          the result of operation
################################################################


$dir = File.dirname(__FILE__) 
require $dir+ '/../BasicUtility'

class ParentalControl < BasicUtility
  
  # Parental Control page
  def parentalcontrol(rule_name, info)
    
    #execute super.parentalcontrol(rule_name, info) to go to Parental Control Page
    
    super
    # settings and testing on the  Parental Control page
    # plsease add your code here...
    
    if info.key?('layout')
      case info['layout']
      when 'Parental Control'
        ParentalControlPage(rule_name, info)
      when 'Rule Summary'
        RuleSummaryPage(rule_name, info)
      else
        self.msg(rule_name, :error, '', 'layout undefined')
      end
    else
      self.msg(rule_name, :error, '', 'No layout key found')
    end 
    
  end
  
  def ParentalControlPage(rule_name, info)
    #####
    
    # temp code for extend
    # device_array=@ff.select_list(:id, 'wf_lan_comp_allbox').options()
    
    # Step 1. Select the Networked Computer/Device for this Allow or Block Rule.
    begin
      if info.key?('Selected Devices')
        if @ff.select_list(:id, 'wf_lan_comp_allbox').include?(info['Selected Devices']) 
          @ff.select_list(:id, 'wf_lan_comp_allbox').select_value(info['Selected Devices'])
        else
          self.msg(rule_name, :error, 'ParentalControlPage()->Selected Devices', 'Selected Devices not exist')
        end
      else 
        self.msg(rule_name, :error, 'ParentalControlPage()->Selected Devices', 'No Selected Devices key found')
      end
    rescue
      self.msg(rule_name, :error, 'ParentalControlPage()->Selected Devices', 'Selected Devices not exist')
      return
    end
    # click 'Add' butten
    begin
      @ff.link(:name, ' onclick=\"add_wf_dev();\"').click
    rescue
      self.msg(rule_name, :error, 'ParentalControlPage()->Add Selected Devices', 'Add Selected Devices Fault')
      return
    end
    
    # Step 2. Create the Parental Control Rules and Schedules.
    # Limit Access by
    if info.key?('Limit Access by')
      case info['Limit Access by']
      when 'Block the following Websites and Embedded Keywords within a Website'
        @ff.radio(:id, 'wf_filter_type0').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'Limit Access by = '+info['Limit Access by'])
        # add Website
        if info.key?('Website')
	    website_Array=info['Website'].split(';')
            website_Array_Count=website_Array.length
            for i in 0..website_Array_Count-1
              #@ff.text_field(:name, 'wf_website').set(website_Array[i].strip)
              @ff.text_field(:name, 'wf_website').value=(website_Array[i].strip)
	      @ff.startClicker("ok")
              @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
	      popup_information = @ff.get_popup_text
	      if not popup_information.empty?
	          self.msg(rule_name, :info,'Web add alert information',popup_information)	
	      end
            end
          self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Website)', 'Website = '+info['Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Website', 'No Website key found')
        end
	
	if info.key?('MltWebsites')
	    web_num=info['MltWebsites'].to_i
	    m=web_num/250
	    n=web_num - m*250
	    m=m + 1
	    for i in 1..m
		for j in 1..n
		    url = "10.10." + i.to_s + "0." + (80+j).to_s
		    @ff.text_field(:name, 'wf_website').value = url
		    @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
		end
	    end
	    self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Website)', info['MltWebsites'] + 'Websites')
	end

	if info.key?('MltKeywords')
	    key_num=info['MltKeywords'].to_i
	    for j in 1..key_num
		key = "tstformlt" + j.to_s
		@ff.text_field(:name, 'wf_keyword').value=key
		@ff.link(:name, ' onclick=\"add_wf_filter();\"').click
	    end
	    self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Keyword)', info['MltKeywords'] + 'Keywords')
	end

        # add Embedded keyword within a Website
        if info.key?('Embedded keyword within a Website')
	    keyword_Array=info['Embedded keyword within a Website'].split(';')
            keyword_Array_Count=keyword_Array.length
            for i in 0..keyword_Array_Count-1
              #@ff.text_field(:name, 'wf_keyword').set(keyword_Array[i].strip)
	      @ff.startClicker("ok")
              @ff.text_field(:name, 'wf_keyword').value=(keyword_Array[i].strip)
              @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
	      popup_information = @ff.get_popup_text
	      if not popup_information.empty?
	          self.msg(rule_name, :info,'Web add alert information',popup_information)	
	      end
            end
            self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Embedded keyword within a Website)', 'Embedded keyword within a Website = '+info['Embedded keyword within a Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Embedded keyword within a Website', 'No Embedded keyword within a Website key found')
        end
      when 'Allow the following Websites and Embedded Keywords within a Website'
        @ff.radio(:id, 'wf_filter_type1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'Limit Access by = '+info['Limit Access by'])
        # add Website
        if info.key?('Website')
          website_Array=info['Website'].split(';')
          website_Array_Count=website_Array.length
          for i in 0..website_Array_Count-1
            #@ff.text_field(:name, 'wf_website').set(website_Array[i].strip)
	    @ff.text_field(:name, 'wf_website').value=(website_Array[i].strip)
	    @ff.startClicker("ok")
            @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
	    popup_information = @ff.get_popup_text
	    if not popup_information.empty?
		self.msg(rule_name, :info,'Web add alert information',popup_information)	
	    end
	  end
          self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Website)', 'Website = '+info['Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Website', 'No Website key found')
        end
        # add Embedded keyword within a Website
        if info.key?('Embedded keyword within a Website')
          keyword_Array=info['Embedded keyword within a Website'].split(';')
          keyword_Array_Count=keyword_Array.length
          for i in 0..keyword_Array_Count-1
            #@ff.text_field(:name, 'wf_keyword').set(keyword_Array[i].strip)
            @ff.text_field(:name, 'wf_keyword').value=(keyword_Array[i].strip)
	    @ff.startClicker("ok")
            @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
	    popup_information = @ff.get_popup_text
	    if not popup_information.empty?
		self.msg(rule_name, :info,'Web add alert information',popup_information)	
	    end 
	  end
          self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Embedded keyword within a Website)', 'Embedded keyword within a Website = '+info['Embedded keyword within a Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Embedded keyword within a Website', 'No Embedded keyword within a Website key found')
        end
      when 'Blocking ALL Internet Access'
        @ff.radio(:id, 'wf_filter_type2').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'Limit Access by = '+info['Limit Access by'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Limit Access by', 'Limit Access by undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'No Limit Access by key found')
    end
    # Create Schedule
    #  Days
    if info.key?('Monday')
      case info['Monday']
      when 'on'
        @ff.checkbox(:name, 'day_mon').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Monday', 'Monday=on')
      when 'off'
        @ff.checkbox(:name, 'day_mon').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Monday', 'Monday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Monday', 'Monday undefined')
      end
    end
    if info.key?('Tuesday')
      case info['Tuesday']
      when 'on'
        @ff.checkbox(:name, 'day_tue').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Tuesday', 'Tuesday=on')
      when 'off'
        @ff.checkbox(:name, 'day_tue').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Tuesday', 'Tuesday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Tuesday', 'Tuesday undefined')
      end
    end
    if info.key?('Wednesday')
      case info['Wednesday']
      when 'on'
        @ff.checkbox(:name, 'day_wed').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Wednesday', 'Wednesday=on')
      when 'off'
        @ff.checkbox(:name, 'day_wed').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Wednesday', 'Wednesday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Wednesday', 'Wednesday undefined')
      end
    end
    if info.key?('Thursday')
      case info['Thursday']
      when 'on'
        @ff.checkbox(:name, 'day_thu').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Thursday', 'Thursday=on')
      when 'off'
        @ff.checkbox(:name, 'day_thu').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Thursday', 'Thursday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Thursday', 'Thursday undefined')
      end
    end
    if info.key?('Friday')
      case info['Friday']
      when 'on'
        @ff.checkbox(:name, 'day_fri').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Friday', 'Friday=on')
      when 'off'
        @ff.checkbox(:name, 'day_fri').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Friday', 'Friday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Friday', 'Friday undefined')
      end
    end
    if info.key?('Saturday')
      case info['Saturday']
      when 'on'
        @ff.checkbox(:name, 'day_sat').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Saturday', 'Saturday=on')
      when 'off'
        @ff.checkbox(:name, 'day_sat').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Saturday', 'Saturday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Saturday', 'Saturday undefined')
      end
    end
    if info.key?('Sunday')
      case info['Sunday']
      when 'on'
        @ff.checkbox(:name, 'day_sun').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Sunday', 'Sunday=on')
      when 'off'
        @ff.checkbox(:name, 'day_sun').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Sunday', 'Sunday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Sunday', 'Sunday undefined')
      end
    end
    # Times
    if info.key?('Times Rule')
      case info['Times Rule']
      when 'Rule will be Active at the Scheduled Time'
        @ff.radio(:id, 'is_enabling_0').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Times Rule', 'Times Rule = '+info['Times Rule'])
      when 'Rule will be InActive at the Scheduled Time'
        @ff.radio(:id, 'is_enabling_1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Times Rule', 'Times Rule = '+info['Times Rule'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Times Rule', 'Times Rule undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Times Rule', 'No Times Rule key found')
    end
    # Start time Hour
    if info.key?('Start time Hour')
      case info['Start time Hour']
      when '01'
        @ff.select_list(:id, 'start_hour').select_value('1')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '02'
        @ff.select_list(:id, 'start_hour').select_value('2')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '03'
        @ff.select_list(:id, 'start_hour').select_value('3')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '04'
        @ff.select_list(:id, 'start_hour').select_value('4')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '05'
        @ff.select_list(:id, 'start_hour').select_value('5')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '06'
        @ff.select_list(:id, 'start_hour').select_value('6')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '07'
        @ff.select_list(:id, 'start_hour').select_value('7')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '08'
        @ff.select_list(:id, 'start_hour').select_value('8')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '09'
        @ff.select_list(:id, 'start_hour').select_value('9')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '10'
        @ff.select_list(:id, 'start_hour').select_value('10')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '11'
        @ff.select_list(:id, 'start_hour').select_value('11')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '12'
        @ff.select_list(:id, 'start_hour').select_value('12')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Start time Hour', 'Start time Hour undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'No Start time Hour key found')
    end
    # Start time Minute
    if info.key?('Start time Minute')
      case info['Start time Minute']
      when '00'
        @ff.select_list(:id, 'start_min').select_value('0')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      when '15'
        @ff.select_list(:id, 'start_min').select_value('15')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      when '30'
        @ff.select_list(:id, 'start_min').select_value('30')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      when '45'
        @ff.select_list(:id, 'start_min').select_value('45')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Start time Minute', 'Start time Minute undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'No Start time Minute key found')
    end
    # Start time AM/PM
    if info.key?('Start time AM_PM')
      case info['Start time AM_PM']
      when 'AM'
        @ff.radio(:id, 'start_is_pm_0').set   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time AM_PM', 'Start time AM_PM = '+info['Start time AM_PM'])
      when 'PM'
        @ff.radio(:id, 'start_is_pm_1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time AM_PM', 'Start time AM_PM = '+info['Start time AM_PM'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Start time AM_PM', 'Start time AM_PM undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Start time AM_PM', 'No Start time AM_PM key found')
    end
    # End time Hour
    if info.key?('End time Hour')
      case info['End time Hour']
      when '01'
        @ff.select_list(:id, 'end_hour').select_value('1')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '02'
        @ff.select_list(:id, 'end_hour').select_value('2')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '03'
        @ff.select_list(:id, 'end_hour').select_value('3')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '04'
        @ff.select_list(:id, 'end_hour').select_value('4')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '05'
        @ff.select_list(:id, 'end_hour').select_value('5')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '06'
        @ff.select_list(:id, 'end_hour').select_value('6')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '07'
        @ff.select_list(:id, 'end_hour').select_value('7')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '08'
        @ff.select_list(:id, 'end_hour').select_value('8')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '09'
        @ff.select_list(:id, 'end_hour').select_value('9')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '10'
        @ff.select_list(:id, 'end_hour').select_value('10')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '11'
        @ff.select_list(:id, 'end_hour').select_value('11')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '12'
        @ff.select_list(:id, 'end_hour').select_value('12')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->End time Hour', 'End time Hour undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'No End time Hour key found')
    end
    # End time Minute
    if info.key?('End time Minute')
      case info['End time Minute']
      when '00'
        @ff.select_list(:id, 'end_min').select_value('0')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      when '15'
        @ff.select_list(:id, 'end_min').select_value('15')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      when '30'
        @ff.select_list(:id, 'end_min').select_value('30')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      when '45'
        @ff.select_list(:id, 'end_min').select_value('45')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->End time Minute', 'End time Minute undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'No End time Minute key found')
    end
    # End time AM/PM
    if info.key?('End time AM_PM')
      case info['End time AM_PM']
      when 'AM'
        @ff.radio(:id, 'end_is_pm_0').set   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time AM_PM', 'End time AM_PM = '+info['End time AM_PM'])
      when 'PM'
        @ff.radio(:id, 'end_is_pm_1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->End time AM_PM', 'End time AM_PM = '+info['End time AM_PM'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->End time AM_PM', 'End time AM_PM undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->End time AM_PM', 'No End time AM_PM key found')
    end
    # Create Rule Name
    if info.key?('Rule Name')  
      @ff.text_field(:name, 'wf_policy_name_advanced').set(info['Rule Name'])
      #@ff.text_field(:name, 'wf_policy_name_advanced').value=(info['Rule Name'])
      self.msg(rule_name, :info, 'ParentalControlPage()->Rule Name', 'Rule Name= '+@ff.text_field(:name,'wf_policy_name_advanced').value.to_s)
    else
      self.msg(rule_name, :error, 'ParentalControlPage()->Rule Name', 'No Rule Name key found')
    end
    if info.key?('Description')  
      #@ff.text_field(:name, 'wf_policy_desc_advanced').set(info['Description'])
      @ff.text_field(:name, 'wf_policy_desc_advanced').value=(info['Description'])
      self.msg(rule_name, :info, 'ParentalControlPage()->Description', 'Description= '+info['Description'])
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Description', 'No Description key found')
    end
    
    # Step 3. Click the Apply button to save and apply your settings.
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors")      
      #n=@ff.tables.length     
      errorTable=@ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "ParentalControlPage()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'ParentalControlPage()->Apply', 'Parental Control setup fault')   
    else
      if @ff.contains_text("Attention") 
        errorTable=@ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Attention, "ParentalControlPage()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'ParentalControlPage()->Apply', 'Parental Control setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'ParentalControlPage()->Apply', 'Parental Control setup sucessful')
      end 
    end
    #####
  end

## Tom add this function at 2009.06.03
  def RuleSummaryPage(rule_name, info)
    begin
	@ff.link(:text, 'Rule Summary').click
	self.msg(rule_name, :info, 'Rule Summary', 'Reached page \'Rule Summary\'.')	
    end
    #@ff.link(:href, 'javascript:mimic_button(\'wf_policy_edit: 0..\', 1)').click
    sTable = false
    begin
	@ff.tables.each do |t|
	    if ( t.text.include? 'Rule Name' and
		t.text.include? 'Description' and 
		( not t.text.include? 'Rule Summary') and
		t.row_count >= 1  )then
		sTable = t
		break
	    end
	end
	if sTable == false
	# Wrong here
	    self.msg(rule_name,:error,'Rule Summary','Did NOT find the target table.')
	    return
	end
    end
    pc = false
    begin
	if info.key?('Selected Devices')
	pc = info['Selected Devices']
	end
    end
    begin
	sTable.each do |row|
	    if ( row.text.include? pc )then
		if info.key?('action') then
		    if info['action'] == 'delete' then
			row.link(:name,'wf_policy_remove').click
			@ff.link(:text, 'OK').click
			self.msg(rule_name, :info, 'Delete Rule','Delete ' + pc + ' Success')
			return
		    end
		end
		row.link(:name, 'wf_policy_edit').click
	    end
	end
    end

    begin
    if info.key?('Limit Access by')
      case info['Limit Access by']
      when 'Block the following Websites and Embedded Keywords within a Website'
        @ff.radio(:id, 'wf_filter_type0').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'Limit Access by = '+info['Limit Access by'])
        # add Website
        if info.key?('Website')
          website_Array=info['Website'].split(';')
          website_Array_Count=website_Array.length
          for i in 0..website_Array_Count-1
            #@ff.text_field(:name, 'wf_website').set(website_Array[i].strip)
            @ff.text_field(:name, 'wf_website').value=(website_Array[i].strip)
            @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
          end
          self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Website)', 'Website = '+info['Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Website', 'No Website key found')
        end
        # add Embedded keyword within a Website
        if info.key?('Embedded keyword within a Website')
          keyword_Array=info['Embedded keyword within a Website'].split(';')
          keyword_Array_Count=keyword_Array.length
          for i in 0..keyword_Array_Count-1
            #@ff.text_field(:name, 'wf_keyword').set(keyword_Array[i].strip)
            @ff.text_field(:name, 'wf_keyword').value=(keyword_Array[i].strip)
            @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
          end
          self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Embedded keyword within a Website)', 'Embedded keyword within a Website = '+info['Embedded keyword within a Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Embedded keyword within a Website', 'No Embedded keyword within a Website key found')
        end
      when 'Allow the following Websites and Embedded Keywords within a Website'
        @ff.radio(:id, 'wf_filter_type1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'Limit Access by = '+info['Limit Access by'])
        # add Website
        if info.key?('Website')
          website_Array=info['Website'].split(';')
          website_Array_Count=website_Array.length
          for i in 0..website_Array_Count-1
            #@ff.text_field(:name, 'wf_website').set(website_Array[i].strip)
            @ff.text_field(:name, 'wf_website').value=(website_Array[i].strip)
            @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
          end
          self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Website)', 'Website = '+info['Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Website', 'No Website key found')
        end
        # add Embedded keyword within a Website
        if info.key?('Embedded keyword within a Website')
          keyword_Array=info['Embedded keyword within a Website'].split(';')
          keyword_Array_Count=keyword_Array.length
          for i in 0..keyword_Array_Count-1
            #@ff.text_field(:name, 'wf_keyword').set(keyword_Array[i].strip)
            @ff.text_field(:name, 'wf_keyword').value=(keyword_Array[i].strip)
            @ff.link(:name, ' onclick=\"add_wf_filter();\"').click
          end
          self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by (Embedded keyword within a Website)', 'Embedded keyword within a Website = '+info['Embedded keyword within a Website'])
        else
          self.msg(rule_name, :info, 'ParentalControlPage()->Embedded keyword within a Website', 'No Embedded keyword within a Website key found')
        end
      when 'Blocking ALL Internet Access'
        @ff.radio(:id, 'wf_filter_type2').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'Limit Access by = '+info['Limit Access by'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Limit Access by', 'Limit Access by undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Limit Access by', 'No Limit Access by key found')
    end
    
    # Add by Hugo to handle keyword Remove
    if info.key?('Remove_Keyword')
      rmkeyword_Array=info['Remove_Keyword'].split(';')
      rmkeyword_Array_Count=rmkeyword_Array.length
      for i in 0..rmkeyword_Array_Count-1
				if @ff.select_list(:name, 'wf_filter_lstbox').include?(rmkeyword_Array[i].strip)
             @ff.select_list(:name, 'wf_filter_lstbox').select_value(rmkeyword_Array[i].strip)
             @ff.link(:name, ' onclick=\"remove_wf_filter();\"').click
				else
          self.msg(rule_name, :error, 'ParentalControlPage()->Remove Keyword', 'Error keyword')
        end
      end
		else
			self.msg(rule_name, :info, 'ParentalControlPage()->Remove Keyword', 'No key found')
    end
    
    # Create Schedule
    #  Days
    if info.key?('Monday')
      case info['Monday']
      when 'on'
        @ff.checkbox(:name, 'day_mon').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Monday', 'Monday=on')
      when 'off'
        @ff.checkbox(:name, 'day_mon').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Monday', 'Monday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Monday', 'Monday undefined')
      end
    end
    if info.key?('Tuesday')
      case info['Tuesday']
      when 'on'
        @ff.checkbox(:name, 'day_tue').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Tuesday', 'Tuesday=on')
      when 'off'
        @ff.checkbox(:name, 'day_tue').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Tuesday', 'Tuesday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Tuesday', 'Tuesday undefined')
      end
    end
    if info.key?('Wednesday')
      case info['Wednesday']
      when 'on'
        @ff.checkbox(:name, 'day_wed').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Wednesday', 'Wednesday=on')
      when 'off'
        @ff.checkbox(:name, 'day_wed').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Wednesday', 'Wednesday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Wednesday', 'Wednesday undefined')
      end
    end
    if info.key?('Thursday')
      case info['Thursday']
      when 'on'
        @ff.checkbox(:name, 'day_thu').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Thursday', 'Thursday=on')
      when 'off'
        @ff.checkbox(:name, 'day_thu').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Thursday', 'Thursday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Thursday', 'Thursday undefined')
      end
    end
    if info.key?('Friday')
      case info['Friday']
      when 'on'
        @ff.checkbox(:name, 'day_fri').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Friday', 'Friday=on')
      when 'off'
        @ff.checkbox(:name, 'day_fri').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Friday', 'Friday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Friday', 'Friday undefined')
      end
    end
    if info.key?('Saturday')
      case info['Saturday']
      when 'on'
        @ff.checkbox(:name, 'day_sat').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Saturday', 'Saturday=on')
      when 'off'
        @ff.checkbox(:name, 'day_sat').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Saturday', 'Saturday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Saturday', 'Saturday undefined')
      end
    end
    if info.key?('Sunday')
      case info['Sunday']
      when 'on'
        @ff.checkbox(:name, 'day_sun').set
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Sunday', 'Sunday=on')
      when 'off'
        @ff.checkbox(:name, 'day_sun').clear
        self.msg(rule_name, :info, 'DoSetup_WanMoCA()->Sunday', 'Sunday=off')           
      else
        self.msg(rule_name, :error, 'DoSetup_WanMoCA()->Sunday', 'Sunday undefined')
      end
    end
    # Times
    if info.key?('Times Rule')
      case info['Times Rule']
      when 'Rule will be Active at the Scheduled Time'
        @ff.radio(:id, 'is_enabling_0').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Times Rule', 'Times Rule = '+info['Times Rule'])
      when 'Rule will be InActive at the Scheduled Time'
        @ff.radio(:id, 'is_enabling_1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Times Rule', 'Times Rule = '+info['Times Rule'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Times Rule', 'Times Rule undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Times Rule', 'No Times Rule key found')
    end
    # Start time Hour
    if info.key?('Start time Hour')
      case info['Start time Hour']
      when '01'
        @ff.select_list(:id, 'start_hour').select_value('1')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '02'
        @ff.select_list(:id, 'start_hour').select_value('2')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '03'
        @ff.select_list(:id, 'start_hour').select_value('3')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '04'
        @ff.select_list(:id, 'start_hour').select_value('4')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '05'
        @ff.select_list(:id, 'start_hour').select_value('5')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '06'
        @ff.select_list(:id, 'start_hour').select_value('6')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '07'
        @ff.select_list(:id, 'start_hour').select_value('7')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '08'
        @ff.select_list(:id, 'start_hour').select_value('8')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '09'
        @ff.select_list(:id, 'start_hour').select_value('9')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '10'
        @ff.select_list(:id, 'start_hour').select_value('10')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '11'
        @ff.select_list(:id, 'start_hour').select_value('11')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      when '12'
        @ff.select_list(:id, 'start_hour').select_value('12')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'Start time Hour = '+info['Start time Hour'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Start time Hour', 'Start time Hour undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Start time Hour', 'No Start time Hour key found')
    end
    # Start time Minute
    if info.key?('Start time Minute')
      case info['Start time Minute']
      when '00'
        @ff.select_list(:id, 'start_min').select_value('0')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      when '15'
        @ff.select_list(:id, 'start_min').select_value('15')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      when '30'
        @ff.select_list(:id, 'start_min').select_value('30')     
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      when '45'
        @ff.select_list(:id, 'start_min').select_value('45')   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'Start time Minute = '+info['Start time Minute'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Start time Minute', 'Start time Minute undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Start time Minute', 'No Start time Minute key found')
    end
    # Start time AM/PM
    if info.key?('Start time AM_PM')
      case info['Start time AM_PM']
      when 'AM'
        @ff.radio(:id, 'start_is_pm_0').set   
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time AM_PM', 'Start time AM_PM = '+info['Start time AM_PM'])
      when 'PM'
        @ff.radio(:id, 'start_is_pm_1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->Start time AM_PM', 'Start time AM_PM = '+info['Start time AM_PM'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->Start time AM_PM', 'Start time AM_PM undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->Start time AM_PM', 'No Start time AM_PM key found')
    end
    # End time Hour
    if info.key?('End time Hour')
      case info['End time Hour']
      when '01'
        @ff.select_list(:id, 'end_hour').select_value('1')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '02'
        @ff.select_list(:id, 'end_hour').select_value('2')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '03'
        @ff.select_list(:id, 'end_hour').select_value('3')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '04'
        @ff.select_list(:id, 'end_hour').select_value('4')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '05'
        @ff.select_list(:id, 'end_hour').select_value('5')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '06'
        @ff.select_list(:id, 'end_hour').select_value('6')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '07'
        @ff.select_list(:id, 'end_hour').select_value('7')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '08'
        @ff.select_list(:id, 'end_hour').select_value('8')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '09'
        @ff.select_list(:id, 'end_hour').select_value('9')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '10'
        @ff.select_list(:id, 'end_hour').select_value('10')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '11'
        @ff.select_list(:id, 'end_hour').select_value('11')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      when '12'
        @ff.select_list(:id, 'end_hour').select_value('12')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'End time Hour = '+info['End time Hour'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->End time Hour', 'End time Hour undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->End time Hour', 'No End time Hour key found')
    end
    # End time Minute
    if info.key?('End time Minute')
      case info['End time Minute']
      when '00'
        @ff.select_list(:id, 'end_min').select_value('0')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      when '15'
        @ff.select_list(:id, 'end_min').select_value('15')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      when '30'
        @ff.select_list(:id, 'end_min').select_value('30')     
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      when '45'
        @ff.select_list(:id, 'end_min').select_value('45')   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'End time Minute = '+info['End time Minute'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->End time Minute', 'End time Minute undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->End time Minute', 'No End time Minute key found')
    end
    # End time AM/PM
    if info.key?('End time AM_PM')
      case info['End time AM_PM']
      when 'AM'
        @ff.radio(:id, 'end_is_pm_0').set   
        self.msg(rule_name, :info, 'ParentalControlPage()->End time AM_PM', 'End time AM_PM = '+info['End time AM_PM'])
      when 'PM'
        @ff.radio(:id, 'end_is_pm_1').set
        self.msg(rule_name, :info, 'ParentalControlPage()->End time AM_PM', 'End time AM_PM = '+info['End time AM_PM'])
      else
        self.msg(rule_name, :error, 'ParentalControlPage()->End time AM_PM', 'End time AM_PM undefined')
      end
    else
      self.msg(rule_name, :info, 'ParentalControlPage()->End time AM_PM', 'No End time AM_PM key found')
    end
        
    # Step 3. Click the Apply button to save and apply your settings.
    @ff.link(:text, 'Apply').click
    if  @ff.contains_text("Input Errors")      
      #n=@ff.tables.length     
      errorTable=@ff.tables[18]
      errorTable_rowcount=errorTable.row_count
      for i in 1..errorTable_rowcount-1
        self.msg(rule_name, :PageInfo_Error, "ParentalControlPage()->Apply (#{i})", errorTable.[](i).text)    
      end 
      self.msg(rule_name, :error, 'ParentalControlPage()->Apply', 'Parental Control setup fault')   
    else
      if @ff.contains_text("Attention") 
        errorTable=@ff.tables[18]
        errorTable_rowcount=errorTable.row_count
        for i in 1..errorTable_rowcount-1
          self.msg(rule_name, :PageInfo_Attention, "ParentalControlPage()->Apply (#{i})", errorTable.[](i).text)    
        end 
        @ff.link(:text, 'Apply').click
        self.msg(rule_name, :result_info, 'ParentalControlPage()->Apply', 'Parental Control setup sucessful with Attention')
      else
        self.msg(rule_name, :result_info, 'ParentalControlPage()->Apply', 'Parental Control setup sucessful')
      end 
    end
    end
    #####
    #####
  end
  
end
