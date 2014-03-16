module ParentalControl
    #
    # parental control functions main page
    #
    def parental_control(rule_name, info)
		self.parentalControlPage(rule_name, info)
        case info['action']
        when 'set'
            if info.has_key?('devices')
                if info['devices'].has_key?('add')
                    info['devices']['add'].each(' ') do |device|
                        begin
                            @ff.select_list(:name, 'wf_lan_comp_allbox').select_value(device.strip)
                        rescue
                            self.msg(rule_name, :warning, 'parental control-device', 'add '+device+' not found')
                        end
                    end
                    @ff.link(:name, /add_wf_dev/).click
                end
                if info['devices'].has_key?('remove')
                    info['devices']['remove'].each(' ') do |device|
                        begin
                            @ff.select_list(:name, 'wf_lan_comp_selbox').select_value(device.strip)
                        rescue
                            self.msg(rule_name, :warning, 'parental control-device', 'remove '+device+' not found')
                        end
                    end 
                    @ff.link(:name, /remove_wf_dev/).click
                end
            end
            
            if info.has_key?('limit')
                case info['limit']
                when 'block'
                    @ff.radio(:id, 'wf_filter_type0').set
                when 'allow'
                    @ff.radio(:id, 'wf_filter_type1').set
                when 'all'
                    @ff.radio(:id, 'wf_filter_type2').set
                else
                    self.msg(rule_name, :error, 'parental control-limit', info['limit']+' unknown')
                end
            end
            
            if info.has_key?('websites')
                if info['websites'].has_key?('add')
                    info['websites']['add'].each(' ') do |website|
                        @ff.text_field(:name, 'wf_website').set(website.strip)
                        @ff.link(:name, /add_wf_filter/).click
                    end
                    @ff.text_field(:name, 'wf_website').clear
                end
                if info['websites'].has_key?('remove')
                    info['websites']['remove'].each(' ') do |website|
                        @ff.select_list(:name, 'wf_filter_lstbox').select_value('Website:'+website.strip)
                    end
                    @ff.link(:name, /remove_wf_filter/).click
                end
            end
                
            if info.has_key?('keywords')
                if info['keywords'].has_key?('add')
                    info['keywords']['add'].each(' ') do |keyword|
                        @ff.text_field(:name, 'wf_keyword').set(keyword.strip)
                        @ff.link(:name, /add_wf_filter/).click
                    end
                end
                @ff.text_field(:name, 'wf_keyword').clear
                if info['keywords'].has_key?('remove')
                    info['keywords']['remove'].each(' ') do |keyword|
                        @ff.select_list(:name, 'wf_filter_lstbox').select_value('Keyword:'+keyword.strip)
                    end
                    @ff.link(:name, /remove_wf_filter/).click
                end
            end
            
            if info.has_key?('days')
                info['days'].each(' ') do |day|
                    case day.strip
                    when 'mon'
                        @ff.checkbox(:name, 'day_mon').set
                    when 'tue'
                        @ff.checkbox(:name, 'day_tue').set
                    when 'wed'
                        @ff.checkbox(:name, 'day_wed').set
                    when 'thu'
                        @ff.checkbox(:name, 'day_thu').set
                    when 'fri'
                        @ff.checkbox(:name, 'day_fri').set
                    when 'sat'
                        @ff.checkbox(:name, 'day_sat').set
                    when 'sun'
                        @ff.checkbox(:name, 'day_sun').set
                    else
                        self.msg(rule_name, :error, 'parental control-days', day+' unknown')
                    end
                end
            end
            
            if info.has_key?('times')
                if info['times'] == 'active'
                    @ff.radio(:id, 'is_enabling_0').set
                elsif info['times'] == 'inactive'
                    @ff.radio(:id, 'is_enabling_1').set
                else
                    self.msg(rule_name, :error, 'parental control-times', info['times']+' unknown')
                end
            end

            re_date = /(\d{1,2}):(\d{1,2})\s*([ap])m/i 
            if info.has_key?('start')
                re_date =~ info['start']
                re_out = Regexp.last_match
                @ff.select_list(:name, 'start_hour').select_value(sprintf('%.2d', re_out[1].to_i))
                @ff.select_list(:name, 'start_min').select_value(sprintf('%.2d', re_out[2].to_i))
                if re_out[3].downcase == 'a'
                    @ff.radio(:id, 'start_is_pm_0').set
                elsif re_out[3].downcase == 'p'
                    @ff.radio(:id, 'start_is_pm_1').set
                else
                    self.msg(rule_name, :error, 'parental control-start', 'am/pm incorrect')
                end
            end
        
            if info.has_key?('end')
                re_date =~ info['end']
                re_out = Regexp.last_match
                @ff.select_list(:name, 'end_hour').select_value(sprintf('%.2d', re_out[1].to_i))
                @ff.select_list(:name, 'end_min').select_value(sprintf('%.2d', re_out[2].to_i))
                if re_out[3].downcase == 'a'
                    @ff.radio(:id, 'end_is_pm_0').set
                elsif re_out[3].downcase == 'p'
                    @ff.radio(:id, 'end_is_pm_1').set
                else
                    self.msg(rule_name, :error, 'parental control-end', 'am/pm incorrect')
                end
            end
            
            if info.has_key?('rule_name')
                @ff.text_field(:name, 'wf_policy_name_advanced').set(info['rule_name'])
            else
                self.msg(rule_name, :warning, 'parental control-rule_name', 'not defined')
            end
        
            if info.has_key?('description')
                @ff.text_field(:name, 'wf_policy_desc_advanced').set(info['description'])
            end

            # apply
            @ff.link(:name, /merge_select/).click
            
            # yes we are sure
            if @ff.text.include? 'requires extra processing power'
                @ff.link(:text, 'Apply').click
                self.msg(rule_name, :info, 'parental control-add rule', 'Success')
            else
                self.msg(rule_name, :error, 'parental control-add rule', 'did not find confirmation marker text')
            end

        when 'remove'
            if not info.has_key?('rule_name')
                self.msg(rule_name, :error, 'parental control-remove rule', 'no rule_name defined')
                return
            end

            begin
                @ff.link(:text, 'Rule Summary').click
            rescue
                self.msg(rule_name, :error, 'parental control-remove rule', 'did not reach page')
                return
            end
            
            # hack. there should be an xpath to do this
            found = FALSE
            @ff.tables.each do |t|
                for i in 1..t.row_count
                    t[i].each do |cell|
                        begin
                            if cell.text.include? info['rule_name']
                                found = t
                            end
                        rescue
                            # they don't all have text
                        end
                    end
                end
            end
            if found != FALSE
                for i in 2..found.row_count
                    if found[i][1].text.include? info['rule_name']
                        found[i].link(:xpath, "//a[@title='Remove']").click
                        @ff.link(:text, 'OK').click
                    end
                end
            else
                self.msg(rule_name, :warning, 'parental control-remove rule', 'rule not found')
            end
            
        when 'get'
            begin
                @ff.link(:text, 'Rule Summary').click
            rescue
                self.msg(rule_name, :error, 'parental control-get', 'did not reach page')
                return
            end
            
            # hack. there should be an xpath to do this
            # find the innermost table with 'Rule Name' in it
            found = FALSE
            @ff.tables.each do |t|
                for i in 1..t.row_count
                    t[i].each do |cell|
                        begin
                            if cell.text.include? 'Rule Name'
                                found = t
                            end
                        rescue
                            # they don't all have text
                        end
                    end
                end
            end
            
            # walk all the found rules
            info_text = ['Rule Name:', 'Description:', 'Computer/Device', 'Allowed Website',  'Embedded Keyword:', 
                         'Schedule:']
            info_found = {}
            
            if found != FALSE
                for i in 2..found.row_count
                    self.msg(rule_name, :debug, 'parental control - get', 'found rule ' + found[i][1].text.to_s)
                    found[i].link(:xpath, "//a[@title='Edit']").click

                    out = {'action' => 'get', 'section' => 'parental_control'}
                    
                    devs = @ff.select_list(:name, 'wf_lan_comp_selbox').getAllContents
                    dev_string = ''
                    devs.each do |dev|
                      dev_string += dev + ' '
                    end
                    out['devices'] = { 'add', dev_string.strip }
                    
                    if @ff.radio(:id, 'wf_filter_type0').checked?
                        out['limit'] = 'block'
                    elsif @ff.radio(:id, 'wf_filter_type1').checked?
                        out['limit'] = 'allow'
                    elsif @ff.radio(:id, 'wf_filter_type2').checked?
                        out['limit'] = 'all'
                    end
                    
                    sites_keys = @ff.select_list(:name, 'wf_filter_lstbox').getAllContents
                    web_string = ''
                    key_string = ''
                    sites_keys.each do |site_key|
                        if site_key[0, 8] == 'Website:'
                            web_string += site_key[8, site_key.length] + ' '
                        end
                        if site_key[0, 8] == 'Keyword:'
                            key_string += site_key[8, site_key.length] + ' '
                        end
                    end
                    out['websites'] = { 'add', web_string.strip }
                    out['keywords'] = { 'add', key_string.strip }
                    
                    day_str = ''
                    if @ff.checkbox(:name, 'day_mon').checked?
                        day_str += 'mon '
                    end
                    
                    if @ff.checkbox(:name, 'day_tue').checked?
                        day_str += 'tue '
                    end
                    
                    if @ff.checkbox(:name, 'day_wed').checked?
                        day_str += 'wed '
                    end
                    
                    if @ff.checkbox(:name, 'day_thu').checked?
                        day_str += 'thu '
                    end
                    
                    if @ff.checkbox(:name, 'day_fri').checked?
                        day_str += 'fri '
                    end
                    
                    if @ff.checkbox(:name, 'day_sat').checked?
                        day_str += 'sat '
                    end
                    
                    if @ff.checkbox(:name, 'day_sun').checked?
                        day_str += 'sun '
                    end
                    
                    out['days'] = day_str.strip
                    
                    if @ff.radio(:id, 'is_enabling_0').checked?
                        out['times'] = 'active'
                    elsif @ff.radio(:id, 'is_enabling_1').checked?
                        out['times'] = 'inactive'
                    end
                    
                    stime = @ff.select_list(:name, 'start_hour').getSelectedItems[0] + ':'
                    stime += @ff.select_list(:name, 'start_min').getSelectedItems[0]
                    if @ff.radio(:id, 'start_is_pm_0').checked?
                        stime += 'am'
                    elsif @ff.radio(:id, 'start_is_pm_1').checked?
                        stime += 'pm'
                    end
                    out['start'] = stime
                    
                    etime = @ff.select_list(:name, 'end_hour').getSelectedItems[0] + ':'
                    etime += @ff.select_list(:name, 'end_min').getSelectedItems[0]
                    if @ff.radio(:id, 'end_is_pm_0').checked?
                        etime += 'am'
                    elsif @ff.radio(:id, 'end_is_pm_1').checked?
                        etime += 'pm'
                    end
                    out['end'] = etime
                    
                    out['rule_name'] = @ff.text_field(:name, 'wf_policy_name_advanced').value
                    p out['rule_name']
                    out['description'] = @ff.text_field(:name, 'wf_policy_desc_advanced').value
                    
                    @out[rule_name + '_' + out['rule_name']] = out
                    @ff.link(:text, 'Apply').click
                end
            end
        else
            self.msg(rule_name, :error, 'parental control-action', 'unknown/missing action')
            return
        end
        return
    end
end