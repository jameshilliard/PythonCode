# Module for advanced setup options for Q1000

module AdvancedSetup
    def services_blocking
        return unless self.menu(:advanced_setup, :services_blocking)

        # Adding
        if @user_choices[:services_blocking_add]
            @ff.select_list(:id, "lan_device").getAllContents.each { |value| @ff.select_list(:id, "lan_device").select(value) if value.match(/#{@user_choices[:services_blocking_add][0]}/i) }
            @log.info("Services Blocking::Adding #{@user_choices[:services_blocking_add][0]}, blocking flags #{@user_choices[:services_blocking_add][1]}")
            @ff.text_field(:id, "ip_address").set(@user_choices[:services_blocking_add][0]) if @ff.select_list(:id, "lan_device").value == "Manually Enter IP"
            @ff.checkbox(:name, "BlOcKsErViCe", "web").click if @user_choices[:services_blocking_add][1].match(/w/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "ftp").click if @user_choices[:services_blocking_add][1].match(/f/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "newsgroups").click if @user_choices[:services_blocking_add][1].match(/n/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "email").click if @user_choices[:services_blocking_add][1].match(/e/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "im").click if @user_choices[:services_blocking_add][1].match(/i/i)
            apply_settings("Services Blocking")
        end

        # Removal
        if @user_choices[:services_blocking_remove][0].match(/all/i)
            @log.info("Services Blocking::Removing all")
            while @ff.link(:id, "remove_btn").exists?
                @ff.link(:id, "remove_btn").click
            end
        else
            indices = []
            count = 2
            while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{ip_count}]/td[3]").exists?
                if @user_choices[:services_blocking_remove][1]
                    indices << count if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{ip_count}]/td[4]").innerHTML.match(/web/i) if @user_choices[:services_blocking_remove][1].match(/w/i)
                    indices << count if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{ip_count}]/td[4]").innerHTML.match(/ftp/i) if @user_choices[:services_blocking_remove][1].match(/f/i)
                    indices << count if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{ip_count}]/td[4]").innerHTML.match(/newsgroups/i) if @user_choices[:services_blocking_remove][1].match(/n/i)
                    indices << count if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{ip_count}]/td[4]").innerHTML.match(/e-mail/i) if @user_choices[:services_blocking_remove][1].match(/e/i)
                    indices << count if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{ip_count}]/td[4]").innerHTML.match(/im/i) if @user_choices[:services_blocking_remove][1].match(/i/i)
                else
                    # Assume all if no services specified
                    indices << count
                end if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{ip_count}]/td[3]").innerHTML.include?(@user_choices[:services_blocking_remove][0])
                count += 1
            end
            indices.each do |v|
                if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{v}]/td[5]").exists?
                    @log.info("Services Blocking::Removing #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{v}]/td[3]")} - #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{v}]/td[4]")}")
                    @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{v}]/td[5]").click
                end
            end
        end if @user_choices[:services_blocking_remove]
    end

    def website_blocking
        return unless self.menu(:advanced_setup, :website_blocking)
        # Add
        if @user_choices[:website_blocking_ip]
            @user_choices[:website_blocking_add].each do |site|
                ip_address = ""
                @ff.select_list(:id, "lan_device").getAllContents.each { |value| if value == @user_choices[:website_blocking_ip]; @ff.select_list(:id, "lan_device").select(value); ip_address = value; end }
                if @ff.select_list(:id, "lan_device").value == "Manually Enter IP Address"
                    @ff.text_field(:id, "ip_address").set(@user_choices[:website_blocking_ip])
                    ip_address = @ff.text_field(:id, "ip_address").value
                end
                @ff.text_field(:id, "BlOcKuRl").set(site)
                @log.info("Website Blocking::Adding #{site} for #{ip_address}")
                apply_settings("Website Blocking")
            end
        else
            @log.info("Website Blocking::Must specify IP/device with --website_blocking_ip")
        end if @user_choices[:website_blocking_add]

        # Remove
        if @user_choices[:website_blocking_remove][0].downcase == "all"
            # Remove all
            @log.info("Website Blocking::Removing all")
            while @ff.button(:id, /remove_btn/).exists?; @ff.button(:id, /remove_btn/).click; self.please_wait; end
        else
            # Build
            blocked_sites = []
            count = 2
            while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/div[4]/table/tbody/tr[#{count}]/td").exists?
                blocked_sites << @ff.elements_by_xpath("/html/body/div/div[3]/div[2]/form/div[4]/table/tbody/tr[#{count}]/td").join(" ").downcase.strip
                count += 1
            end
            @user_choices[:website_blocking_remove].each do |item|
                blocked_sites.reverse.each_index do |site|
                    if blocked_sites[site].match(/#{item}/i)
                        @log.info("Website Blocking::Removing #{blocked_sites[site]}")
                        @ff.button(:id, "remove_btn#{site}").click
                        self.please_wait
                        blocked_sites.delete_at(site)
                    end
                end
            end
        end if @user_choices[:website_blocking_remove]
    end

    def scheduling_access
        return unless self.menu(:advanced_setup, :scheduling_access)
        last_count = 2
        current_rules = []
        while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[2]").exists?
            current_rules << @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[2]").innerHTML
            last_count += 1
        end
        
        # Add
        if @user_choices[:scheduling_access_add]
            @ff.select_list(:id, "lan_device").getAllContents.each { |value| @ff.select_list(:id, "lan_device").select(value) if value.match(/#{@user_choices[:scheduling_access_add][0]}/i) }
            @log.info("Scheduling Access::Adding #{@user_choices[:scheduling_access_add]}")
            @ff.text_field(:id, "pc_name").set(@user_choices[:scheduling_access_add][0]) if @ff.select_list(:id, "pc_name").value == "Manually Enter MAC Address"
            @ff.checkbox(:id, "sc3").click if @user_choices[:scheduling_access_add][1].match(/sun/i)
            @ff.checkbox(:id, "sc4").click if @user_choices[:scheduling_access_add][1].match(/mon/i)
            @ff.checkbox(:id, "sc5").click if @user_choices[:scheduling_access_add][1].match(/tue/i)
            @ff.checkbox(:id, "sc6").click if @user_choices[:scheduling_access_add][1].match(/wed/i)
            @ff.checkbox(:id, "sc7").click if @user_choices[:scheduling_access_add][1].match(/thu/i)
            @ff.checkbox(:id, "sc8").click if @user_choices[:scheduling_access_add][1].match(/fri/i)
            @ff.checkbox(:id, "sc9").click if @user_choices[:scheduling_access_add][1].match(/sat/i)
            time_start = Time.parse(@user_choices[:scheduling_access_add][2].split("-")[0]).strftime("%I:%M %p").sub(/\A0/, '') rescue nil
            time_end = Time.parse(@user_choices[:scheduling_access_add][2].split("-")[1]).strftime("%I:%M %p").sub(/\A0/, '') rescue nil
            if time_start == nil || time_end == nil
                @log.error("Scheduling Access::Invalid time frame specified")
            else
                list_select("fromtime", time_start, :name)
                list_select("totime", time_end, :name)
            end
            @ff.link(:id, "add_btn").click
            @log.info("Scheduling Access::Added #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[1]").innerHTML} (#{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[2]").innerHTML}) #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[3]").innerHTML}, #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[4]").innerHTML}")
            current_rules << @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[2]").innerHTML
        end
        
        # Remove
        if @user_choices[:scheduling_access_remove]
            @log.info("Scheduling Access::Removing rules for #{@user_choices[:scheduling_access_remove]}")
            if @user_choices[:scheduling_access_remove].match(/all/i)
                count = 2
                while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{count}]/td[5]").exists?
                    @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{count}]/td[5]").click
                    count += 1
                end
            else
                while current_rules.rindex(@user_choices[:scheduling_access_remove])
                    i = current_rules.rindex(@user_choices[:scheduling_access_remove])
                    current_rules.delete_at(i)
                    @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[4]/tbody/tr[#{i+2}]/td[5]").click
                end
            end
        end
    end

    def broadband_settings
        return unless self.menu(:advanced_setup, :broadband_settings)
        case @user_choices[:broadband_settings][0]
        when /auto|ptm/i
            list_select("transport_mode", "PTM") if @user_choices[:broadband_settings][0].match(/ptm/i)
            list_select("transport_mode", "Auto Select") if @user_choices[:broadband_settings][0].match(/auto/i)
            @user_choices[:broadband_settings][1..-1].each do |option|
                case option
                when /vlan/i
                    @ff.text_field(:id, "vlanMuxId").set(option.split(':')[1])
                when /priority/i
                    list_select(:id, "vlanMuxPr").set(option.split(':')[1])
                when /mode/i
                    list_select("line_mode", option.split(':')[1].gsub('_', ' ').sub(/multimode/i, "Auto Select"))
                end
            end if @user_choices[:broadband_settings].length > 1
            apply_settings("Broadband Settings")
            @log.info("Broadband Settings::Currently set to #{@ff.select_list(:id, "transport_mode").value.strip}. Line mode: #{@ff.select_list(:id, "line_mode").value}")
            @log.info("Broadband Settings::(#{@ff.select_list(:id, "transport_mode").value.strip}) VLAN ID #{@ff.text_field(:id, "vlanMuxId").value}. VLAN priority #{@ff.select_list(:id, "vlanMuxPr").value}")
        when /atm/i
            list_select("transport_mode", "ATM")
            @user_choices[:broadband_settings][1..-1].each do |option|
                case option
                when /vpi/i
                    @ff.text_field(:id, "atm_paramenters_vpi").set(option.split(':')[1])
                when /vci/i
                    @ff.text_field(:id, "atm_paramenters_vci").set(option.split(':')[1])
                when /qos/i
                    list_select("atm_paramenters_qos", option.split(':')[1].gsub('_', ' '))
                when /pcr/i
                    @ff.text_field(:id, "atm_paramenters_pcr").set(option.split(':')[1])
                when /scr/i
                    @ff.text_field(:id, "atm_paramenters_scr").set(option.split(':')[1])
                when /mbs/i
                    @ff.text_field(:id, "atm_paramenters_mbs").set(option.split(':')[1])
                when /cdvt/i
                    @ff.text_field(:id, "atm_paramenters_cdvt").set(option.split(':')[1])
                when /encaps/i
                    list_select("atm_encapsulation_type", option.gsub('_', ' ').sub(/vcmux/i, "VC-Mux"))
                when /mode/i
                    list_select("atm_line_mode", option.split(':')[1].gsub('_', ' ').sub(/multimode/i, "Auto Select"))
                end
            end if @user_choices[:broadband_settings].length > 1
            @log.info("Broadband Settings::Set to use ATM. Line mode: #{@ff.select_list(:id, "atm_line_mode").value}")
            @log.info("Broadband Settings::(ATM) VPI/VCI is #{@ff.text_field(:id, "atm_paramenters_vpi").value}/#{@ff.text_field(:id, "atm_paramenters_vci").value}")
            @log.info("Broadband Settings::(ATM) PCR/SCR/MBS/CDVT is #{@ff.text_field(:id, "atm_paramenters_pcr").value}/#{@ff.text_field(:id, "atm_paramenters_scr").value}/#{@ff.text_field(:id, "atm_paramenters_mbs").value}/#{@ff.text_field(:id, "atm_paramenters_cdvt").value}")
            @log.info("Broadband Settings::(ATM) QoS set to #{@ff.select_list(:name, "atm_paramenters_qos").value}")
            @log.info("Broadband Settings::(ATM) Using encapsulation mode #{@ff.select_list(:id, "atm_encapsulation_type").value}")
        end if @user_choices[:broadband_settings]
        @ff.text_field(:id, "atm_paramenters_mtu").set(@user_choices[:broadband_settings_mtu]) if @user_choices[:broadband_settings_mtu] if @ff.select_list(:id, "transport_mode").value == "ATM"
        @ff.text_field(:id, "paramenters_mtu").set(@user_choices[:broadband_settings_mtu]) if @user_choices[:broadband_settings_mtu] if @ff.select_list(:id, "transport_mode").value == "PTM"
        @log.info("Broadband Settings::MTU currently #{@ff.select_list(:id, "transport_mode").value.match(/ptm|auto/i) ? @ff.text_field(:id, "paramenters_mtu").value : @ff.text_field(:id, "atm_paramenters_mtu").value}")
        apply_settings("Broadband Settings")
    end

    def dhcp_settings
        return unless self.menu(:advanced_setup, :dhcp_settings)
        if @user_choices[:dhcp_settings][0].match(/disable|off|no/i)
            @ff.radio(:name => "dhcp_server", :index => 2).set
            @log.info("DHCP Settings::DHCP disabled")
            #apply_settings("DHCP Settings")
        else
            @ff.radio(:name => "dhcp_server", :index => 1).set
            @log.info "DHCP Settings::DHCP enabled"
        end if @user_choices[:dhcp_settings]
        @ff.text_field(:name, "IPInterfaceIPAddress").set(@user_choices[:lan_ip_address][0]) if @user_choices[:lan_ip_address][0] if @user_choices[:lan_ip_address]
        @ff.text_field(:name, "SubnetMask").set(@user_choices[:dhcp_settings][2]) if @user_choices[:dhcp_settings][2] if @user_choices[:dhcp_settings]
        @ff.text_field(:name, "SubnetMask").set(@user_choices[:lan_ip_address][1]) if @user_choices[:lan_ip_address]
        @log.info "LAN IP Address::IP: #{@ff.text_field(:name, "IPInterfaceIPAddress").value}/#{@ff.text_field(:name, "SubnetMask").value}"
        if @ff.radio(:name => "dhcp_server", :index => 1).checked?
            @ff.text_field(:name, "MinAddress").set(@user_choices[:dhcp_settings][0]) if @user_choices[:dhcp_settings][0]
            @ff.text_field(:name, "MaxAddress").set(@user_choices[:dhcp_settings][1]) if @user_choices[:dhcp_settings][1]
            @log.info "DHCP Settings::DHCP range set to #{@ff.text_field(:name, "MinAddress").value}-#{@ff.text_field(:name, "MaxAddress").value}"
            if @user_choices[:dhcp_lease_time]
                @ff.text_field(:id, "day").set(@user_choices[:dhcp_lease_time].split(":")[0])
                @ff.text_field(:id, "hour").set(@user_choices[:dhcp_lease_time].split(":")[1])
                @ff.text_field(:id, "minute").set(@user_choices[:dhcp_lease_time].split(":")[2])
                @log.info "DHCP Settings::DHCP lease time set to #{@user_choices[:dhcp_lease_time].split(":")[0]} days, #{@user_choices[:dhcp_lease_time].split(":")[1]} hours, #{@user_choices[:dhcp_lease_time].split(":")[2]} minutes"
            end

            # The following is no longer an option, not sure where it went. Thank you software for randomly changing things.
            if @user_choices[:dhcp_dns][0].match(/dynamic/i)
                @ff.radio(:id, "dns_dynamic").set
                @log.info "DHCP Settings::DNS set to dynamic"
            else
                @ff.radio(:id, "dns_static").set
                @ff.text_field(:id, "dnsPrimary").set(@user_choices[:dhcp_dns][0]) if @user_choices[:dhcp_dns][0]
                @ff.text_field(:id, "dnsSecondary").set(@user_choices[:dhcp_dns][1]) if @user_choices[:dhcp_dns][1]
                @log.info "DHCP Settings::Static primary DNS is #{@ff.text_field(:id, "dnsPrimary")}, secondary DNS is #{@ff.text_field(:id, "dnsSecondary")}"
            end if @user_choices[:dhcp_dns]
        end if @user_choices[:dhcp_settings] 
        apply_settings("DHCP Settings")
    end

    def dhcp_reservation
        return unless self.menu(:advanced_setup, :dhcp_settings)
        unless @ff.radio(:name => "dhcp_server", :index => 2).checked?
            @ff.radio(:name => "reserve", :index => 2).set
            apply_settings("DHCP Reservation")
            @log.info("DHCP Reservation::Disabled")
        end if @user_choices[:dhcp_reservation][1].match(/disable/i)
        unless @ff.radio(:name => "reserve", :index => 1).checked?
            @ff.radio(:name => "reserve", :index => 1).set
            apply_settings("DHCP Reservation")
            @log.info("DHCP Reservation::Enabled")
        end unless @user_choices[:dhcp_reservation][1].match(/disable/i)
        return if @ff.radio(:name => "reserve", :index => 2).checked?
        return unless self.menu(:advanced_setup, :dhcp_reservation)
        last_count = 2
        current_rules = []
        while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{last_count}]/td[3]").exists?
            current_rules << @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{last_count}]/td[3]").innerHTML.downcase
            last_count += 1
        end
        unless @user_choices[:dhcp_reservation][1].match(/remove/i)
            @ff.select_list(:name, "mac_address").getAllContents.each { |value| @ff.select_list(:name, "mac_address").select(value) if value.match(/#{@user_choices[:dhcp_reservation][0]}/i) }
            @ff.text_field(:id, "mac_address_manual").set(@user_choices[:dhcp_reservation][0]) if @ff.select_list(:name, "mac_address").value.match(/manual/i)
            @ff.select_list(:id, "ip_address").select(@user_choices[:dhcp_reservation][1])
            apply_settings("DHCP Reservation")
            current_rules << @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{last_count}]/td[3]").innerHTML.downcase
            @log.info("DHCP Reservation::Added #{current_rules.last} with IP #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{last_count}]/td[4]").innerHTML}")
        else
            if @user_choices[:dhcp_reservation][0].match(/all/i)
                @log.info("DHCP Reservation::Removing all")
                current_rules.each_index do |remove_id|
                    @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{remove_id+2}]/td[5]/a").click if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{remove_id+2}]/td[5]").exists?
                end
            else
                @log.info("DHCP Reservation::Removing #{current_rules[current_rules.index(@user_choices[:dhcp_reservation][0].downcase)]}")
                @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{current_rules.index(@user_choices[:dhcp_reservation][0].downcase) + 2}]/td[5]/a").click if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[3]/tbody/tr[#{current_rules.index(@user_choices[:dhcp_reservation][0].downcase) + 2}]/td[5]").exists?
            end
        end
    end

    def wan_ip_address
        return unless self.menu(:advanced_setup, :wan_ip_address)
        case @user_choices[:wan_ip_address][0]
        when /pppoe/i
            list_select("isp_protocol_id", "PPPoE")
            @log.info("WAN IP Address::Protocol #{@ff.select_list(:id, "isp_protocol_id").value}")
            @user_choices[:wan_ip_address][0].include?("+") ? @ff.checkbox(:name, "pppautoconnect").set : @ff.checkbox(:name, "pppautoconnect").clear
            @ff.checkbox(:name, "pppautoconnect").checked? ? @log.info("WAN IP Address::PPP Autoconnect enabled") : @log.info("WAN IP Address::PPP Autoconnect disabled")
            if @user_choices[:ppp_username] || @user_choices[:ppp_password]
                @ff.checkbox(:name, "nouser").clear
                @ff.text_field(:name, "ppp_username").set(@user_choices[:ppp_username]) if @user_choices[:ppp_username]
                @log.info("WAN IP Address::Using PPP Username #{@ff.text_field(:name, "ppp_username").value}") if @user_choices[:ppp_username]
                @ff.text_field(:name, "ppp_password").set(@user_choices[:ppp_password]) if @user_choices[:ppp_password]
                @log.info("WAN IP Address::PPP password set to #{@user_choices[:ppp_password]}") if @user_choices[:ppp_password]
            else
                @log.info "WAN IP Address::No username or password specified, setting to not require one"
                @ff.checkbox(:name, "nouser").set
            end
            if @user_choices[:wan_ip_address][1]
                @ff.select_list(:name, "wanip").select("Single Static IP") unless @user_choices[:wan_ip_address][1].include?("/") unless @user_choices[:wan_ip_address][1].match(/dynamic/i)
                @ff.select_list(:name, "wanip").select("Dynamic IP (Default)") if @user_choices[:wan_ip_address][1].match(/dynamic/i)
                @ff.select_list(:name, "wanip").select("Block of Static IP Addresses") if @user_choices[:wan_ip_address][1].include?("/")
                if @ff.select_list(:name, "wanip").value.match(/singlestaticipadd/i)
                    @ff.text_field(:name, "singlestaticip").set(@user_choices[:wan_ip_address][1])
                    @log.info "WAN IP Address::Using single static IP #{@ff.text_field(:name, "singlestaticip").value}"
                elsif @ff.select_list(:name, "wanip").value.match(/blockstaticipadd/i)
                    @user_choices[:wan_ip_address][1].include?("+") ? @ff.checkbox(:name, "vipmode").set : @ff.checkbox(:name, "vipmode").clear
                    @user_choices[:wan_ip_address][1].delete!("+")
                    ip_info = IP.new(@user_choices[:wan_ip_address][1])
                    @ff.text_field(:name, "gatewayadd").set(ip_info.ip)
                    @ff.text_field(:name, "subnetmask").set(ip_info.netmask)
                    @log.info "WAN IP Address::Using block of static IP addresses. Gateway: #{@ff.text_field(:name, "gatewayadd").value}, Subnet Mask: #{@ff.text_field(:name, "subnetmask").value}"
                    @ff.checkbox(:name, "vipmode").checked? ? @log.info("WAN IP Address::VIP mode enabled") : @log.info("WAN IP Address::VIP mode disabled")
                end
            end
        when /pppoa/i
            list_select("isp_protocol_id", "PPPoA")
            @log.info("WAN IP Address::Protocol #{@ff.select_list(:id, "isp_protocol_id").value}")
            @user_choices[:wan_ip_address][0].include?("+") ? @ff.checkbox(:name, "pppautoconnect").set : @ff.checkbox(:name, "pppautoconnect").clear
            @ff.checkbox(:name, "pppautoconnect").checked? ? @log.info("WAN IP Address::PPP Autoconnect enabled") : @log.info("WAN IP Address::PPP Autoconnect disabled")
            if @user_choices[:ppp_username] || @user_choices[:ppp_password]
                @ff.checkbox(:name, "nouser").clear
                @ff.text_field(:name, "ppp_username").set(@user_choices[:ppp_username]) if @user_choices[:ppp_username]
                @log.info("WAN IP Address::Using PPP Username #{@ff.text_field(:name, "ppp_username").value}") if @user_choices[:ppp_username]
                @ff.text_field(:name, "ppp_password").set(@user_choices[:ppp_password]) if @user_choices[:ppp_password]
                @log.info("WAN IP Address::PPP password set to #{@user_choices[:ppp_password]}") if @user_choices[:ppp_password]
            else
                @log.info "WAN IP Address::No username or password specified, setting to not require one"
                @ff.checkbox(:name, "nouser").set
            end
            if @user_choices[:wan_ip_address][1]
                @ff.select_list(:name, "wanip").select("Single Static IP") unless @user_choices[:wan_ip_address][1].include?("/") unless @user_choices[:wan_ip_address][1].match(/dynamic/i)
                @ff.select_list(:name, "wanip").select("Dynamic IP (Default)") if @user_choices[:wan_ip_address][1].match(/dynamic/i)
                @ff.select_list(:name, "wanip").select("Block of Static IP Addresses") if @user_choices[:wan_ip_address][1].include?("/")
                if @ff.select_list(:name, "wanip").value.match(/singlestaticipadd/i)
                    @ff.text_field(:name, "singlestaticip").set(@user_choices[:wan_ip_address][1])
                    @log.info "WAN IP Address::Using single static IP #{@ff.text_field(:name, "singlestaticip").value}"
                elsif @ff.select_list(:name, "wanip").value.match(/blockstaticipadd/i)
                    @user_choices[:wan_ip_address][1].include?("+") ? @ff.checkbox(:name, "vipmode").set : @ff.checkbox(:name, "vipmode").clear
                    @user_choices[:wan_ip_address][1].delete!("+")
                    ip_info = IP.new(@user_choices[:wan_ip_address][1])
                    @ff.text_field(:name, "gatewayadd").set(ip_info.ip)
                    @ff.text_field(:name, "subnetmask").set(ip_info.netmask)
                    @log.info "WAN IP Address::Using block of static IP addresses. Gateway: #{@ff.text_field(:name, "gatewayadd").value}, Subnet Mask: #{@ff.text_field(:name, "subnetmask").value}"
                    @ff.checkbox(:name, "vipmode").checked? ? @log.info("WAN IP Address::VIP mode enabled") : @log.info("WAN IP Address::VIP mode disabled")
                end
            end
        when /transparent/i
            list_select("isp_protocol_id", "Transparent Bridging")
            @log.info "WAN IP Address::Setting to transparent bridging"
        when /dhcp/i
            list_select("isp_protocol_id", "DHCP")
            @log.info("WAN IP Address::Protocol #{@ff.select_list(:id, "isp_protocol_id").value}")
            unless @user_choices[:wan_ip_address][1].include?(":")
                @ff.text_field(:name, "host_name").set(@user_choices[:wan_ip_address][1].split(":")[0])
                @log.info("WAN IP Address::Using host name #{@ff.text_field(:name, "host_name").value}")
                @ff.text_field(:name, "domain_name").set(@user_choices[:wan_ip_address][1].split(":")[1])
                @log.info("WAN IP Address::Using domain name #{@ff.text_field(:name, "domain_name").value}")
            end if @user_choices[:wan_ip_address][1]
        when /static/i
            list_select("isp_protocol_id", "Static IP")
            @log.info("WAN IP Address::Protocol #{@ff.select_list(:id, "isp_protocol_id").value}")
            if @user_choices[:wan_ip_address][1].include?(":")
                @ff.text_field(:name, "ipadd").set(@user_choices[:wan_ip_address][1].split(":")[0].to_ip.ip)
                @log.info("WAN IP Address::Using host name #{@ff.text_field(:name, "ipadd").value}")
                @ff.text_field(:name, "submask").set(@user_choices[:wan_ip_address][1].split(":")[0].to_ip.netmask)
                @log.info("WAN IP Address::Using subnet mask #{@ff.text_field(:name, "submask").value}")
                @ff.text_field(:name, "gateadd").set(@user_choices[:wan_ip_address][1].split(":")[1])
                @log.info("WAN IP Address::Using gateway address #{@ff.text_field(:name, "gateadd").value}")
            end if @user_choices[:wan_ip_address][1]
        end if @user_choices[:wan_ip_address]

        # DNS Type
        if @user_choices[:wan_ip_address_dns][0].match(/dynamic/i)
            @ff.radio(:name => "dnstyp", :index => 1).set
            @log.info("WAN IP Address::Using dynamic DNS")
        else
            @ff.radio(:name => "dnstyp", :index => 2).set
            @ff.text_field(:name, "primarydns").set(@user_choices[:wan_ip_address_dns][0])
            @ff.text_field(:name, "secdns").set(@user_choices[:wan_ip_address_dns][1]) if @user_choices[:wan_ip_address_dns][1]
            @log.info("WAN IP Address::Using DNS servers: #{@ff.text_field(:name, "primarydns").value}, #{@ff.text_field(:name, "secdns").value}")
        end if @user_choices[:wan_ip_address_dns]

        apply_settings("WAN IP Address")
    end

    def igmp_proxy
        return unless self.menu(:advanced_setup, :wan_ip_address)
        @ff.radio(:name => "igmpproxy", :index => 1).set if @user_choices[:igmp_proxy]
        @ff.radio(:name => "igmpproxy", :index => 2).set unless @user_choices[:igmp_proxy]
        apply_settings("IGMP Proxy")
        @ff.radio(:name => "igmpproxy", :index => 1).checked? ? @log.info("IGMP Proxy::Enabled") : @log.info("IGMP Proxy::Disabled")
    end
    
    def dns_host_mapping
        return unless self.menu(:advanced_setup, :dns_host_mapping)
        current_rules = []
        last_count = 2
        # /html/body/div/div[3]/div[2]/form/div[11]/table/tbody/tr[2]/td[2]
        while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/div[11]/table/tbody/tr[#{last_count}]/td[2]").exists?
            current_rules << @ff.elements_by_xpath("/html/body/div/div[3]/div[2]/form/div[11]/table/tbody/tr[#{last_count}]/td").join(" ").downcase.strip
            last_count += 1
        end
        pp current_rules
        unless @user_choices[:dns_host_mapping][1].match(/remove/i)
            @ff.text_field(:id, "Hostname").set(@user_choices[:dns_host_mapping][0])
            @ff.text_field(:id, "IPAddress").set(@user_choices[:dns_host_mapping][1])
            apply_settings("DNS Host Mapping")
            current_rules << @ff.elements_by_xpath("/html/body/div/div[3]/div[2]/form/div[11]/table/tbody/tr[#{last_count}]/td").join(" ").downcase.strip
            @log.info "DNS Host Mapping::Added #{current_rules.last}"
        else
            if @user_choices[:dns_host_mapping][0].match(/all/i)
                @log.info("DNS Host Mapping::Removing all")
                while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/div[11]/table/tbody/tr[2]/td[5]/a").exists?
                    @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/div[11]/table/tbody/tr[2]/td[5]/a").click
                    self.please_wait
                end
            else
                current_rules.reverse.each_index do |site|
                    if current_rules[site].match(/#{@user_choices[:dns_host_mapping][0]}/i)
                        @log.info("DNS Host Mapping::Removing #{current_rules[site]}")
                        @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/div[11]/table/tbody/tr[#{site+2}]/td[5]/a").click
                        self.please_wait
                    end
                end
            end
        end
    end

    def dynamic_dns
        return unless self.menu(:advanced_setup, :dynamic_dns)
        if @user_choices[:dynamic_dns][0].match(/disable|off/i)
            @ff.radio(:id, "disabled").set
            apply_settings("Dynamic DNS")
            @log.info("Dynamic DNS::Disabled")
        else
            @ff.radio(:id, "enabled").set
            @ff.text_field(:name, "ddnsUsername").set(@user_choices[:dynamic_dns][0])
            @ff.text_field(:name, "ddnsPassword").set(@user_choices[:dynamic_dns][1])
            @ff.text_field(:name, "ddnsHostname").set(@user_choices[:dynamic_dns][2])
            apply_settings("Dynamic DNS")
            @log.info("Dynamic DNS::Enabled")
            @log.info("Dynamic DNS::Username: #{@ff.text_field(:name, "ddnsUsername").value}; Password: #{@user_choices[:dynamic_dns][1]}; Hostname: #{@ff.text_field(:name, "ddnsHostname").value}")
        end
    end

    def qos_upstream
        return unless self.menu(:advanced_setup, :qos_upstream)
        if @user_choices[:qos_upstream][0].match(/disable/i)
            @ff.radio(:name=>"QoSEnable", :index=>1).set
            apply_settings("QoS Upstream")
            @log.info("QoS Upstream::QoS upstream is now disabled")
        elsif @user_choices[:qos_upstream][0].match(/default/i)
            @ff.radio(:name=>"QoSEnable", :index=>0).set
            @ff.radio(:id, "on0").set
            apply_settings("QoS Upstream")
            @log.info("QoS Upstream::QoS upstream is now enabled for Qwest Default QoS")
        else
            @log.info("QoS Upstream::Adding custom QoS rule")
            @ff.radio(:name=>"QoSEnable", :index=>0).set
            @ff.radio(:id, "off0").set
            @user_choices[:qos_upstream].each do |option|
                case option
                when /name/i
                    @ff.text_field(:id, "name").set(option.split(":")[1])
                when /priority/i
                    list_select("prio", option.split(":")[1], :name)
                when /reserve/i
                    @ff.text_field(:id, "txtrate").set(option.split(":")[1])
                when /protocol/i
                    list_select("protocol", option.split(":")[1])
                when /tos/i
                    list_select("qo12", option.split(":")[1])
                when /source/i
                    @ff.select_list(:id, "ip_type").select_value("Custom")
                    source_info = option.split(":")[1].to_ip
                    source_ports = option.split(":")[2]
                    if @ff.select_list(:id, "protocol").value.match(/tcp|udp/i)
                        @ff.text_field(:name, "srcpt1").set(source_ports.split("-")[0])
                        @ff.text_field(:name, "srcpt2").set(source_ports.split("-")[1])
                    else
                        @log.info("QoS Upstream::Can't use port information for protocol #{@ff.select_list(:id, "protocol").value.strip}. Omitting information.")
                    end if source_ports
                    @ff.text_field(:name, "srcip").set(source_info.ip)
                    @ff.text_field(:name, "srcmask").set(source_info.netmask) unless source_info.netmask.nil?
                when /destination/i
                    @ff.select_list(:id, "dst_ip_type").select_value("Custom")
                    dst_info = option.split(":")[1].to_ip
                    dst_ports = option.split(":")[2]
                    if @ff.select_list(:id, "protocol").value.match(/tcp|udp/i)
                        @ff.text_field(:name, "dstpt1").set(dst_ports.split("-")[0])
                        @ff.text_field(:name, "dstpt2").set(dst_ports.split("-")[1])
                    else
                        @log.info("QoS Upstream::Can't use port information for protocol #{@ff.select_list(:id, "protocol").value.strip}. Omitting information.")
                    end if dst_ports
                    
                    @ff.text_field(:name, "dstip").set(dst_info.ip)
                    @ff.text_field(:name, "dstmask").set(dst_info.netmask) unless dst_info.netmask.nil?
                end
            end
            apply_settings("QoS Upstream")
        end
    end

    def qos_downstream
        return unless self.menu(:advanced_setup, :qos_downstream)
        if @user_choices[:qos_downstream][0].match(/disable/i)
            @ff.radio(:name=>"QoSEnable", :index=>1).set
            apply_settings("QoS Downstream")
            @log.info("QoS Downstream::QoS downstream is now disabled")
        elsif @user_choices[:qos_downstream][0].match(/default/i)
            @ff.radio(:name=>"QoSEnable", :index=>0).set
            @ff.radio(:id, "on0").set
            apply_settings("QoS Downstream")
            @log.info("QoS Downstream::QoS downstream is now enabled for Qwest Default QoS")
        else
            @log.info("QoS downstream::Adding custom QoS rule")
            @ff.radio(:name=>"QoSEnable", :index=>0).set
            @ff.radio(:id, "off0").set
            @user_choices[:qos_downstream].each do |option|
                case option
                when /name/i
                    @ff.text_field(:id, "name").set(option.split(":")[1])
                when /priority/i
                    list_select("qos_priority", option.split(":")[1])
                when /reserve/i
                    @ff.text_field(:id, "txtrate").set(option.split(":")[1])
                when /protocol/i
                    list_select("protocol", option.split(":")[1])
                when /tos/i
                    list_select("qo12", option.split(":")[1])
                when /source/i
                    @ff.select_list(:id, "ip_type").select_value("Custom")
                    source_info = option.split(":")[1].to_ip
                    source_ports = option.split(":")[2]
                    if @ff.select_list(:id, "protocol").value.match(/tcp|udp/i)
                        @ff.text_field(:name, "srcpt1").set(source_ports.split("-")[0])
                        @ff.text_field(:name, "srcpt2").set(source_ports.split("-")[1])
                    else
                        @log.info("QoS Downstream::Can't use port information for protocol #{@ff.select_list(:id, "protocol").value.strip}. Omitting information.")
                    end if source_ports
                    @ff.text_field(:name, "srcip").set(source_info.ip)
                    @ff.text_field(:name, "srcmask").set(source_info.netmask) unless source_info.netmask.nil?
                when /destination/i
                    @ff.select_list(:id, "dst_ip_type").select_value("Custom")
                    dst_info = option.split(":")[1].to_ip
                    dst_ports = option.split(":")[2]
                    if @ff.select_list(:id, "protocol").value.match(/tcp|udp/i)
                        @ff.text_field(:name, "dstpt1").set(dst_ports.split("-")[0])
                        @ff.text_field(:name, "dstpt2").set(dst_ports.split("-")[1])
                    else
                        @log.info("QoS Downstream::Can't use port information for protocol #{@ff.select_list(:id, "protocol").value.strip}. Omitting information.")
                    end if dst_ports

                    @ff.text_field(:name, "dstip").set(dst_info.ip)
                    @ff.text_field(:name, "dstmask").set(dst_info.netmask) unless dst_info.netmask.nil?
                end
            end
            apply_settings("QoS Downstream")
        end
    end

    
    def remote_gui
        return unless self.menu(:advanced_setup, :remote_gui)
        if @user_choices[:remote_gui].match(/disable/i)
            @ff.radio(:id, "remote_management_disabled").set
            @log.info "Remote GUI::Remote management turned off"
        else
            @ff.radio(:id, "remote_management_enabled").set
            @log.info "Remote GUI::Remote management turned on"
        end
        if @user_choices[:gui_info]
            @ff.text_field(:id, "admin_user_name").set(@user_choices[:gui_info][0])
            @ff.text_field(:id, "admin_password").set(@user_choices[:gui_info][1])
            @log.info("Remote GUI::GUI Username and password set to: #{@user_choices[:gui_info][0]}/#{@user_choices[:gui_info][1]}")
        end
        @ff.text_field(:id, "remote_management_port").set(@user_choices[:remote_gui].delete('^[0-9]')) if @user_choices[:remote_gui].match(/\d+/i)
        @log.info("Remote GUI::Remote management port set to #{@ff.text_field(:id, "remote_management_port").value}")
        list_select("remote_management_timeout", @user_choices[:remote_gui_timeout]) if @user_choices[:remote_gui_timeout]
        apply_settings("Remote GUI")
    end

    def remote_telnet
        return unless self.menu(:advanced_setup, :remote_telnet)
        unless @user_choices[:remote_telnet]
            @ff.radio(:id, "remote_management_disabled").set
            @log.info "Remote Telnet::Remote management turned off"
        else
            @ff.radio(:id, "remote_management_enabled").set
            @log.info "Remote Telnet::Remote management turned on"
        end
        if @user_choices[:telnet_info]
            @ff.text_field(:id, "admin_user_name").set(@user_choices[:telnet_info][0])
            @ff.text_field(:id, "admin_password").set(@user_choices[:telnet_info][1])
            @log.info("Remote Telnet::telnet Username and password set to: #{@user_choices[:telnet_info][0]}/#{@user_choices[:telnet_info][1]}")
        end
        list_select("remote_management_timeout", @user_choices[:remote_telnet_timeout]) if @user_choices[:remote_telnet_timeout]
        apply_settings("Remote Telnet")
    end

    def dynamic_routing
        if @user_choices[:dynamic_routing].match(/disable|off|no/i)
            return unless self.menu(:advanced_setup, :dynamic_routing)
            @ff.radio(:id, "rip_off").set
            apply_settings("Dynamic Routing")
            @log.info("Dynamic Routing::Disabled")
            return
        end
        @log.info("Dynamic Routing::NAT must be disabled first")
        return unless self.menu(:advanced_setup, :nat)
        @ff.radio(:id, "nat_off").set
        apply_settings("NAT")
        @ff.radio(:id, "nat_on").checked? ? @log.info("NAT::Enabled") : @log.info("NAT::Disabled")
        return unless self.menu(:advanced_setup, :dynamic_routing)
        @ff.radio(:id, "rip_on").set
        @ff.radio(:id, "rip_type_1").set if @user_choices[:dynamic_routing].match(/1/)
        @ff.radio(:id, "rip_type_2").set if @user_choices[:dynamic_routing].match(/2/)
        apply_settings("Dynamic Routing")
        @log.info("Dynamic Routing::Enabled")
        @log.info("Dynamic Routing::#{@ff.radio(:id, "rip_type_1").checked? ? 'Version 1' : 'Version 2'}")
    end

    def static_routing
        return unless self.menu(:advanced_setup, :static_routing)
        current_rules = []
        last_count = 2
        if @user_choices[:static_routing][0].match(/remove/i)
            while @ff.link(:id, "remove_btn").exists?; @ff.link(:id, "remove_btn").click; self.please_wait; end
            @log.info("Static Routing::All rules removed")
            return
        end
        while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[5]/tbody/tr[#{last_count}]/td[2]").exists?
            current_rules << "#{@ff.elements_by_xpath("/html/body/div/div[3]/div[2]/form/table[5]/tbody/tr[#{last_count}]/td").join("\t")}"
            last_count += 1
        end
        @ff.text_field(:id, "dstAddr").set(@user_choices[:static_routing][0]) if @user_choices[:static_routing][0]
        @ff.text_field(:id, "dstMask").set(@user_choices[:static_routing][1]) if @user_choices[:static_routing][1]
        @ff.text_field(:id, "dstGtwy").set(@user_choices[:static_routing][2]) if @user_choices[:static_routing][2]
        @ff.text_field(:id, "dstWanIf").set(@user_choices[:static_routing][3]) if @user_choices[:static_routing][3]
        apply_settings("Static Routing")
        current_rules << @ff.elements_by_xpath("/html/body/div/div[3]/div[2]/form/table[5]/tbody/tr[#{last_count}]/td").join("\t") if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[5]/tbody/tr[#{last_count}]/td").exists?
        @log.info("Static Routing::Current static routing rules - \nDestination IP\tSubnet Mask\tGateway IP\tDevice\n#{current_rules}")
    end

    def admin_password
        return unless self.menu(:advanced_setup, :admin_password)
        @ff.radio(:id, "admin_pw_state_off").set if @user_choices[:admin_password][0].match(/disable/i)
        @ff.radio(:id, "admin_pw_state_on").set unless @user_choices[:admin_password][0].match(/disable/i)
        if @ff.radio(:id, "admin_pw_state_on").checked?
            @ff.text_field(:id, "admin_user_name").set(@user_choices[:admin_password][0]) if @user_choices[:admin_password][0]
            @ff.text_field(:id, "admin_password").set(@user_choices[:admin_password][1]) if @user_choices[:admin_password][1]
        end
        apply_settings("Admin Password")
    end

    def port_forwarding
        # PROTOCOL:START-END,IP
        return unless self.menu(:advanced_setup, :port_forwarding)
        if @user_choices[:port_forwarding][0].match(/gre/i)
            @log.info "Port Forwarding::Using GRE"
            list_select("lan_port_protocol", "GRE")
            @ff.text_field(:id, "lan_port_ipaddress").set(@user_choices[:port_forwarding][1])
            @log.info "Port Forwarding::Forwarding to #{@user_choices[:port_forwarding][1]}"
        else
            protocol = @user_choices[:port_forwarding][0].slice!(/\A.*:/).delete(":")
            start_port = @user_choices[:port_forwarding][0].split("-")[0]
            end_port = @user_choices[:port_forwarding][0].split("-")[1]
            list_select("lan_port_protocol", protocol)
            @ff.text_field(:id, "lan_starting_port").set(start_port)
            @ff.text_field(:id, "lan_ending_port").set(end_port)
            @ff.text_field(:id, "lan_port_ipaddress").set(@user_choices[:port_forwarding][1])
            @log.info "Port Forwarding::Forwarding #{protocol} port #{start_port}-#{end_port} to #{@user_choices[:port_forwarding][1]}"
        end if @user_choices[:port_forwarding]

        if @user_choices[:port_forwarding_remote]
            @ff.text_field(:id, "remote_starting_port").set(@user_choices[:port_forwarding_remote][0].split("-")[0])
            @ff.text_field(:id, "remote_ending_port").set(@user_choices[:port_forwarding_remote][0].split("-")[1])
            @ff.text_field(:id, "remote_port_ipaddress").set(@user_choices[:port_forwarding_remote][1])
            @log.info "Port Forwarding::Accepting from remote ip/port-range #{@user_choices[:port_forwarding_remote][1]}/#{@user_choices[:port_forwarding_remote][0]}"
        end
        apply_settings("Port Forwarding") if @user_choices[:port_forwarding]
        
        while @ff.link(:id, "remove_btn").exists?
            @ff.link(:id, "remove_btn").click
        end if @user_choices[:port_forwarding_remove]
    end

    def applications
        return unless self.menu(:advanced_setup, :applications)
        if @user_choices[:applications]
            @ff.select_list(:id, "lan_device").getAllContents.each { |value| @ff.select_list(:id, "lan_device").select(value) if value.match(/#{@user_choices[:applications][0]}/i) }
            @ff.text_field(:id, "ip_address").set(@user_choices[:pplications][0]) if @ff.select_list(:id, "lan_device").value == "Manually Enter IP Address"
            if @user_choices[:applications][1].include?(":")
                list_select("category", @user_choices[:applications][1].split(":")[0])
                list_select("application", @user_choices[:applications][1].split(":")[1])
            else
                list_select("application", @user_choices[:applications][1])
            end
            @log.info("Applications::Adding #{@user_choices[:applications][0]} with application #{@ff.select_list(:id, "application").value}")
            apply_settings("Applications")
        end

        while @ff.link(:id, "remove_btn").exists?
            @ff.link(:id, "remove_btn").click
        end if @user_choices[:applications_remove]
    end

    def dmz_hosting
        return unless self.menu(:advanced_setup, :dmz_hosting)
        @ff.radio(:id, "on").set unless @user_choices[:dmz_hosting].match(/off|disable/i)
        @ff.radio(:id, "off").set if @user_choices[:dmz_hosting].match(/off|disable/i)
        if @ff.radio(:id, "on").checked?
            @ff.select_list(:id, "lan_device").getAllContents.each { |value| @ff.select_list(:id, "lan_device").select(value) if value.match(/#{@user_choices[:dmz_hosting]}/i) }
            @ff.text_field(:id, "ip_address").set(@user_choices[:dmz_hosting]) if @ff.select_list(:id, "lan_device").value == "Manually Enter IP Address"
            apply_settings("DMZ Hosting")
            @log.info("DMZ Hosting::DMZ turned on for device #{@user_choices[:dmz_hosting]}")
        else
            apply_settings("DMZ Hosting")
            @log.info("DMZ Hosting::Disabled")
        end
    end

    def firewall
        return unless self.menu(:advanced_setup, :firewall)
        case @user_choices[:firewall]
        when /disable/i
            @ff.radio(:id, "stealth_mode_disable").set
        when /off|nat/i
            @ff.radio(:id, "stealth_mode_enable").set if @ff.radio(:id, "stealth_mode_disable").checked?
            list_select("firewall_security_level", "Off")
        when /low/i
            @ff.radio(:id, "stealth_mode_enable").set if @ff.radio(:id, "stealth_mode_disable").checked?
            list_select("firewall_security_level", "Low")
        when /med/i
            @ff.radio(:id, "stealth_mode_enable").set if @ff.radio(:id, "stealth_mode_disable").checked?
            list_select("firewall_security_level", "Medium")
        when /high/i
            @ff.radio(:id, "stealth_mode_enable").set if @ff.radio(:id, "stealth_mode_disable").checked?
            list_select("firewall_security_level", "High")
        end if @user_choices[:firewall]
  
        if @user_choices[:firewall_services] && !@ff.radio(:id, "firewall_security_level_off").checked?
            valid_services = ["no entry", "no entry"]
            counter = 2
            while @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{counter}]/td").exists?
                valid_services << @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{counter}]/td").innerHTML.gsub(' ', '_').downcase
            end
            @user_choices[:firewall_services].each do |service|
                if valid_index = valid_services.index(service.split(":")[0].downcase)
                    service.split(":")[1].match(/on/i) ? @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[4]/input").set : @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[4]/input").clear
                    service.split(":")[2].match(/on/i) ? @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[5]/input").set : @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[5]/input").clear
                    @log.info("Firewall::Service #{service.split(":")[0]} traffic in turned #{service.split(":")[1]}, traffic out turned #{service.split(":")[2]}")
                else
                    @log.info("Firewall::Unable to find service named #{service.split(":")[0]}")
                end
            end
        end
        apply_settings("Firewall")
    end

    def nat
        return unless self.menu(:advanced_setup, :nat)
        @user_choices[:nat] ? @ff.radio(:id, "nat_on").set : @ff.radio(:id, "nat_off").set
        apply_settings("NAT")
        @ff.radio(:id, "nat_on").checked? ? @log.info("NAT::Enabled") : @log.info("NAT::Disabled")
    end

    def upnp
        return unless self.menu(:advanced_setup, :upnp)
        @user_choices[:upnp] ? @ff.radio(:id, "upnp_enable").set : @ff.radio(:id, "upnp_disable").set
        apply_settings("UPnP")
        @ff.radio(:id, "upnp_enable").checked? ? @log.info("UPnP::Enabled") : @log.info("UPnP::Disabled")
    end
end
