# Login and menu module for Q1000 (Qwest)

module LoginMenu
    
	def list_select(tag_id, item, tag=:id)
		selection = false
		(@ff.select_list(tag, tag_id).getAllContents).each { |validate| selection = validate if validate.match(/#{item}/i) != nil }
        if selection.length == 0
            @log.error("List Select::Unable to find option #{item} within select list #{tag_id}")
            return false
        else
            @ff.select_list(tag, tag_id).select(selection)
            return true
        end
	end

    # Presses the apply button on all pages
    def apply_settings(section, override=false)
        if @user_choices[:apply]
            last_url = @ff.url
            @log.debug("#{section} Apply::Attempting to apply settings")
            apply_btn = "apply_btn"
            apply_btn = "applyandreboot_btn" if @ff.link(:id, "applyandreboot_btn").exists?
            apply_btn = "add_btn" if @ff.link(:id, "add_btn").exists?
            apply_btn = override if override
            @ff.frame(:name, "realpage").link(:id, apply_btn).click rescue @ff.link(:id, apply_btn).click
            if @ff.contains_text("Press Apply to confirm")
                @log.debug("#{section} Apply::Confirmation page reached. Pressing 'Apply' again")
                @ff.link(:id, apply_btn).click
                @ff.refresh
            end
            self.please_wait
            if @ff.text.empty?
                sleep 20
                @ff.refresh
                @ff.goto(last_url) if @ff.text.empty?
            end
            @log.info("#{section} Apply::Successfully saved settings")
        else
            @log.info("#{section} Apply::Not applying settings per command line switch (sleeping for 20 seconds)")
            sleep 20
        end
    end
    
    # New code for new authentication method on Qwest Q1000
    def logon(access_url)
        retries = 0
        raise "No username and/or password provided, but a login page is requiring them before continuing configuration. Exiting." unless @user_choices[:dut][1] && @user_choices[:dut][2]
        while @ff.text.match(/Enter an admin username and password/i)
            raise "Tried logging in 3 times unsuccessfully. Giving up and exiting." if retries > 3
            @ff.text_field(:id, "admin_user_name").set(@user_choices[:dut][1])
            @ff.text_field(:id, "admin_password").set(@user_choices[:dut][2])
            @ff.link(:id, "apply_btn").click
            @ff.link(:href, /#{access_url}/).click
        end
    end

    def menu(section, sub_section = false)
        stat = true
        if @menu_links[section.to_sym].nil?
            @log.fatal("Menu::Invalid or not implemented main section specified (#{section.to_s})")
            return false
        end
        if @menu_links[section.to_sym][sub_section.to_sym].nil?
            @log.fatal("Menu::Invalid or not implemented sub section specified (#{section.to_s}->#{sub_section.to_s})")
            return false
        end if sub_section
        
        @log.debug("Menu::Jumping to #{section.to_s}")

        if section.to_sym == :tr69
            @ff.goto("#{@user_choices[:dut][0]}/#{@menu_links[section.to_sym][:top]}")
        else
            @ff.link(:href, /#{@menu_links[section.to_sym][:top]}/).click
            self.logon("#{@menu_links[section.to_sym][:top]}") if @ff.text.match(/Enter an admin username and password/i)
        end

        stat = false unless @ff.url.include?(@menu_links[section.to_sym][:top])

        if sub_section
            @log.debug("Menu::Jumping to #{sub_section.to_s}")
            @ff.link(:href, /#{@menu_links[section.to_sym][sub_section.to_sym]}/).click
            stat = @ff.url.include?(@menu_links[section.to_sym][sub_section.to_sym]) ? true : false
        end
        @log.info(@ff.html) if @user_choices[:rawhtml] if stat
        return stat
    end
end