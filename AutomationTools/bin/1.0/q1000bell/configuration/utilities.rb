# Module for Utilities section of Q1000

module Utilities
    def reboot
        return unless self.menu(:utilities, :reboot)
        @log.info("Reboot::Rebooting...")
        @ff.startClicker("OK")
        @ff.link(:id, "reboot_btn").click
        @log.info("Reboot::Sleeping for 2 minutes")
        sleep 120
        @ff.refresh
        @log.info("Reboot::Success")
    end

    def restore_defaults
        return unless self.menu(:utilities, :restore_defaults)
        @ff.startClicker("OK")
        case @user_choices[:restore_defaults]
        when /username/i
            # Restore default PPP username/pass
            #@ff.link(:href, "javascript:doRestoreFactoryDefaults(1);").click
            #self.please_wait
            #@log.info("Restore Defaults::PPP username and password set to default")
            @log.info("Warning::There is no option on latest Q1000H firmware to restore PPP username and password")
        when /wireless/i
            # Restore default wireless settings
            @ff.link(:href, "javascript:doRestoreFactoryDefaults(2);").click
            self.please_wait
            @log.info("Restore Defaults::Wireless settings restored to defaults")
        when /firewall/i
            # Restore default firewall settings
            @ff.link(:href, "javascript:doRestoreFactoryDefaults(3);").click
            self.please_wait
            @log.info("Restore Defaults::Firewall settings restored to defaults")
        when /factory/i
            # Restore modem to factory defaults
            @ff.link(:href, "javascript:doRestoreFactoryDefaults(4);").click
            self.please_wait
            @log.info("Restore Defaults::Factory defaults restored")
        end

    end

    # Possible lead to fixing firmware upgrade issues
    def firmware_file_upload(wait=5)
        sleep(wait)
        button = button.downcase
        jssh_command = "var length = getWindows().length; var win;var found=false;"
        jssh_command << "for(var i = 0; i < length; i++)"
        jssh_command << "{"
        jssh_command << " win = getWindows()[i];"
        jssh_command << " if(win.document.title == \"[JavaScript Application]\")"
        jssh_command << " {"
        jssh_command << " found = true; break;"
        jssh_command << " }"
        jssh_command << "}"
        jssh_command << "if(found)"
        jssh_command << "{"
        jssh_command << " var jsdocument = win.document;"
        jssh_command << " var dialog = jsdocument.getElementsByTagName(\"dialog\")[0];"
        jssh_command << " jsdocument.getElementsByTagName(\"textbox\")[0].value = \"#{@user_choices[:upgrade_firmware]}\";"
        jssh_command << " dialog.getButton(\"accept\").click();"
        jssh_command << "}"
        @ff.js_eval(jssh_command)
    end

    def upgrade_firmware
        return unless self.menu(:utilities, :upgrade_firmware)
        #@ff.frame("realpage").text_field(:id, "fileshow").set(@user_choices[:upgrade_firmware])
        Thread.new { self.firmware_file_upload }

        @log.info("Upgrade Firmware::Using upgrade file #{@user_choices[:upgrade_firmware]}")
        puts @ff.frame("realpage").text_field(:id, "fileshow").value
        #@ff.frame("realpage").link(:id, "upgradefirmware_btn").click
        sleep 50
        #self.please_wait
        @log.info("Upgrade Firmware::Upgrade successful. Firmware version is now #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/div/table/tbody/tr/td[2]/span").innerHTML.strip}")
    end

    def ping_test
        return unless self.menu(:utilities, :ping_test)
        @ff.text_field(:id, "url").set(@user_choices[:ping_test][0])
        @ff.text_field(:id, "packet_size").set(@user_choices[:ping_test][1]) if @user_choices[:ping_test][1]
        @ff.link(:id, "test_btn").click
        self.please_wait
        table_count = 2
        results = []
        results << @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr/th").join("\t").sub("\t", "\t\t\t\t\t")
        while table_count < 6
            results << @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{table_count}]/td").join("\t").delete(":")
            table_count += 1
        end
        results << @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[5]/tbody/tr/th").join("\t")
        results << @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[5]/tbody/tr[2]/td").join("\t")
        results.each { |x| @log.info("Ping Test::#{x}") }
    end

    def traceroute
        return unless self.menu(:utilities, :traceroute)
        @ff.text_field(:id, "url").set(@user_choices[:traceroute])
        @log.info "Traceroute::Running traceroute to #{@ff.text_field(:id, "url").value}"
        @ff.link(:id, "test_btn").click
        self.please_wait
        count = 3
        @log.info "Traceroute::Hop\tTime 1\tTime 2\tTime 3\tHost/IP Address"
        while @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{count}]/td[2]").exists?
            @log.info(@ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{count}]/td").join("\t"))
            count += 1
        end
    end

    def web_activity_log
        return unless self.menu(:utilities, :web_activity_log)
        if @user_choices[:web_activity_log].nil?
            count = 2
            @log.info "Web Activity Log::Date\tTime\t\tIP Address\tWebsite"
            while @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table/tbody/tr[#{count}]/td[2]").exists?
                @log.info "Web Activity Log::#{@ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table/tbody/tr[#{count}]/td").join("\t")}"
                count += 1
            end
        elsif @user_choices[:web_activity_log].match(/10|20|30/)
            @ff.radio(:id, "refresh_type_auto").set
            list_select("interval", @user_choices[:web_activity_log])
            @log.info("Web Activity Log::Automatic refresh interval time set to #{@ff.select_list(:id, "interval").value}")
        elsif @user_choices[:web_activity_log].match(/refresh/i)
            @ff.radio(:id, "refresh_type_manual").set
            @ff.link(:id, "refresh_btn").click
            @log.info("Web Activity Log::Manual refresh")
            count = 2
            @log.info "Web Activity Log::Date\tTime\t\tIP Address\tWebsite"
            while @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table/tbody/tr[#{count}]/td[2]").exists?
                @log.info "Web Activity Log::#{@ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table/tbody/tr[#{count}]/td").join("\t")}"
                count += 1
            end
        end
    end

    def time_zone
        return unless self.menu(:utilities, :time_zone)
        @ff.radio(:id, @user_choices[:time_zone].downcase.delete('^[a-z]')).set
        @ff.checkbox(:id, "daylight_savings").set if @user_choices[:time_zone].include?("+")
        @ff.checkbox(:id, "daylight_savings").clear if @user_choices[:time_zone].include?("-")
        apply_settings("Time Zone")
        @ff.radios.each { |x| @log.info("Time Zone::Current time zone set to #{x.id.capitalize}") if x.checked? }
        @ff.checkbox(:id, "daylight_savings").checked? ? @log.info("Time Zone::Day light savings enabled") : @log.info("Time Zone::Day light savings disabled")
    end
end