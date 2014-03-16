# Login and menu module for Q1000H. Contains login method, apply settings method, please wait method, and list select methods. As well as the main method for starting firefox

module LoginMenu
    # Quick function to select an item from a list using a regular expression as a match for the real option name. Returns false and logs an error when a selection fails
	def list_select(tag_id, item, tag=:id)
		selection = false
		(@ff.select_list(tag, tag_id).getAllContents).each { |validate| selection = validate if validate.match(/#{item}/i) }
        if selection
            @ff.select_list(tag, tag_id).select(selection)
            return true
        else
            @log.error("List Select::Unable to find option #{item} within select list #{tag_id}")
            return false
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

    # JSSH code to do basic authentication
    def logon(wait=3)
        jssh_command = "var length = getWindows().length; var win;var found=false;"
        jssh_command << "for(var i = 0; i < length; i++)"
        jssh_command << "{"
        jssh_command << " win = getWindows()[i];"
        jssh_command << " if(win.document.title == \"Authentication Required\")"
        jssh_command << " {"
        jssh_command << " found = true; break;"
        jssh_command << " }"
        jssh_command << "}"
        jssh_command << "if(found)"
        jssh_command << "{"
        jssh_command << " var jsdocument = win.document;"
        jssh_command << " var dialog = jsdocument.getElementsByTagName(\"dialog\")[0];"
        jssh_command << " jsdocument.getElementsByTagName(\"textbox\")[0].value = \"#{@user_choices[:dut][1]}\";"
        jssh_command << " jsdocument.getElementsByTagName(\"textbox\")[1].value = \"#{@user_choices[:dut][2]}\";"
        jssh_command << " dialog.getButton(\"accept\").click();"
        jssh_command << "}\n"
        sleep(wait)
        $jssh_socket.send(jssh_command,0)
        read_socket()
        wait()
    end

    # Starts firefox and loads the DUT page as specified
    def start_firefox
        rt_count = 1
        waittime = 10
        @log.debug("Firefox Start::Running Firefox")
		begin
			if @user_choices[:firefox_profile]
				@ff = FireWatir::Firefox.new(:waitTime => waittime, :profile => @user_choices[:firefox_profile])
			else
				@ff = FireWatir::Firefox.new(:waitTime => waittime)
			end
			@ff.wait
            @log.debug("Firefox Start::Success")
            unless @logged_in
                @log.debug("Basic Authorization::Login thread started")
                Thread.new { self.logon }
                @logged_in = TRUE
            end if @user_choices[:dut].length > 2
            @ff.goto(@user_choices[:dut][0].ip)
            sleep 3 if @user_choices[:dut].length > 2
            @ff.link(:text, "Manual Setup").click if @ff.contains_text("What would you like to do?")
            return true
		rescue => ex
            if rt_count < 4
                @log.debug("Firefox Start::Firefox didn't start, or no connection to the JSSH server on port 9997 was validated, on attempt #{rt_count}. Trying again...")
                waittime += 5
                rt_count += 1
                retry
            else
                @log.fatal("Firefox Start::Giving up. Last error received: #{ex}")
                return false
            end
		end
    end

    # Please wait loop
    def please_wait
        @log.debug("Wait Loop::Waiting...")
        frames = TRUE
        if @ff.frame(:name, "realpage").contains_text(/please wait/i)
            sleep 20
            @ff.refresh
        end rescue frames = FALSE
        if @ff.frame(:name, "realpage").contains_text(/The DSL Router is rebooting/i)
            sleep 20
            @ff.refresh
        end rescue frames = FALSE
        while @ff.contains_text(/please wait/i)
            sleep 20
            @ff.refresh
        end unless frames
        while @ff.contains_text(/another management entity is currently configuring this unit/i)
            @log.debug("Wait Loop::Another management entity is currently configuring this unit - waiting on Q1000 management.")
            sleep 10
            @ff.refresh
        end if @ff.contains_text(/another management entity is currently configuring this unit/i)
        @log.debug("Wait Loop::Done waiting")
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
            if @ff.frame("realpage").exists?
                @ff.frame("realpage").link(:xpath, @menu_links[section.to_sym][:top]).click
            else
                @ff.link(:xpath, @menu_links[section.to_sym][:top]).click
            end
        end
        stat = false unless @ff.url.include?(@menu_links[section.to_sym][:top_url])
        if sub_section
            @log.debug("Menu::Jumping to #{sub_section.to_s}")
            @ff.link(:id, /#{@menu_links[section.to_sym][sub_section.to_sym]}/).click
            stat = @ff.url.include?(@menu_links[section.to_sym][sub_section.to_sym]) ? true : false
        end
        @log.info(@ff.html) if @user_choices[:rawhtml] if stat

        return stat
    end
end