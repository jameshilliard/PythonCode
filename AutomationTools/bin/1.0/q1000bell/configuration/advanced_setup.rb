# Module for advanced setup options for Q1000H NCS/Bell

module AdvancedSetup
    def services_blocking
        return unless self.menu(:advanced_setup, :services_blocking)

        current_rules = []
        count = 2
        current_rules << "Device  \tIP\tService Blocked"
        # /html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[2]/td[2]
        while @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{count}]/td").length > 0
            current_rules << @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{count}]/td").join(" ").strip
            count += 1
        end unless @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[2]/td").join(" ").strip.match(/no entries/i)

        # Adding
        if @user_choices[:services_blocking_add]
            @ff.select_list(:id, "lan_device").getAllContents.each { |value| @ff.select_list(:id, "lan_device").select(value) if value.match(/#{@user_choices[:services_blocking_add][0]}/i) }
            @log.info("Services Blocking::Adding #{@user_choices[:services_blocking_add][0]}, blocking flags #{@user_choices[:services_blocking_add][1]}")
            @ff.text_field(:id, "ip_address").set(@user_choices[:services_blocking_add][0]) if @ff.select_list(:id, "lan_device").value.match(/manual/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "web").click if @user_choices[:services_blocking_add][1].match(/w/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "ftp").click if @user_choices[:services_blocking_add][1].match(/f/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "newsgroups").click if @user_choices[:services_blocking_add][1].match(/n/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "email").click if @user_choices[:services_blocking_add][1].match(/e/i)
            @ff.checkbox(:name, "BlOcKsErViCe", "im").click if @user_choices[:services_blocking_add][1].match(/i/i)
            apply_settings("Services Blocking")
            while @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{count}]/td").length > 0
                current_rules << @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{count}]/td").join(" ").strip
                count += 1
            end
            @log.info("Services Blocking::Current rules: \n#{current_rules.join("\n")}")
        end

        # Removal
        if @user_choices[:services_blocking_remove][0].match(/all/i)
            @log.info("Services Blocking::Removing all")
            while @ff.link(:id, "remove_btn").exists?
                @ff.link(:id, "remove_btn").click
                self.please_wait
            end
        else
            current_rules.reverse.each do |rule|
                if rule.match(/#{@user_choices[:services_blocking_remove][0]}/i)
                    if rule.include?("Web")
                        @log.info("Services Blocking::Removing #{rule.split(' ').last.downcase} blocking for #{@user_choices[:services_blocking_remove][0]}")
                        @ff.link(:xpath, "/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{current_rules.index(rule)+1}]/td[5]/a").click
                        self.please_wait
                    end if @user_choices[:services_blocking_remove][1].match(/w/i)
                    if rule.include?("FTP")
                        @log.info("Services Blocking::Removing #{rule.split(' ').last.downcase} blocking for #{@user_choices[:services_blocking_remove][0]}")
                        @ff.link(:xpath, "/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{current_rules.index(rule)+1}]/td[5]/a").click
                        self.please_wait
                    end if @user_choices[:services_blocking_remove][1].match(/f/i)
                    if rule.include?("Newsgroups")
                        @log.info("Services Blocking::Removing #{rule.split(' ').last.downcase} blocking for #{@user_choices[:services_blocking_remove][0]}")
                        @ff.link(:xpath, "/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{current_rules.index(rule)+1}]/td[5]/a").click
                        self.please_wait
                    end if @user_choices[:services_blocking_remove][1].match(/n/i)
                    if rule.include?("E-mail")
                        @log.info("Services Blocking::Removing #{rule.split(' ').last.downcase} blocking for #{@user_choices[:services_blocking_remove][0]}")
                        @ff.link(:xpath, "/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{current_rules.index(rule)+1}]/td[5]/a").click
                        self.please_wait
                    end if @user_choices[:services_blocking_remove][1].match(/e/i)
                    if rule.include?("IM")
                        @log.info("Services Blocking::Removing #{rule.split(' ').last.downcase} blocking for #{@user_choices[:services_blocking_remove][0]}")
                        @ff.link(:xpath, "/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{current_rules.index(rule)+1}]/td[5]/a").click
                        self.please_wait
                    end if @user_choices[:services_blocking_remove][1].match(/i/i)
                    if @user_choices[:services_blocking_remove][1].match(/all/i)
                        @log.info("Services Blocking::Removing #{rule.split(' ').last.downcase} blocking for #{@user_choices[:services_blocking_remove][0]}")
                        @ff.link(:xpath, "/html/body/div/div[4]/div[2]/form/table[2]/tbody/tr[#{current_rules.index(rule)+1}]/td[5]/a").click
                        self.please_wait
                    end
                end
            end
        end if @user_choices[:services_blocking_remove]
    end

    def website_blocking
        return unless self.menu(:advanced_setup, :website_blocking)
        # Add
        @user_choices[:website_blocking_add].each do |site|
            @ff.text_field(:id, "BlOcKuRl").set(site)
            @log.info("Website Blocking::Adding #{site}")
            apply_settings("Website Blocking")
        end if @user_choices[:website_blocking_add]

        # Remove
        if @user_choices[:website_blocking_remove][0].downcase == "all"
            # Remove all
            @log.info("Website Blocking::Removing all")
            while @ff.link(:id, /remove_btn/).exists?
                @ff.link(:id, /remove_btn/).click
                self.please_wait
            end
        else
            # Build
            blocked_sites = []
            count = 2
            while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{count}]/td").exists?
                blocked_sites << @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[2]/tbody/tr[#{count}]/td").innerHTML.downcase
                count += 1
            end
            site_removal = []
            @user_choices[:website_blocking_remove].each { |site| site_removal << blocked_sites.index(site) if blocked_sites.index(site) }
            # Remove
            site_removal.sort.reverse.each { |site| @log.info("Website Blocking::Removing site #{blocked_sites[site]}"); @ff.link(:id, "remove_btn#{site}").click }
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
            @ff.text_field(:id, "lan_device").set(@user_choices[:scheduling_access_add][0]) if @ff.select_list(:id, "lan_device").value.match(/manual/i)
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
            @log.info("Scheduling Access::Added #{@ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[1]").innerHTML} (#{@ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[2]").innerHTML}) #{@ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[3]/span").innerHTML}, #{@ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[4]/span").innerHTML}")
            current_rules << @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[2]").innerHTML
        end
        
        # Remove
        if @user_choices[:scheduling_access_remove]
            @log.info("Scheduling Access::Removing rules for #{@user_choices[:scheduling_access_remove]}")
            if @user_choices[:scheduling_access_remove].match(/all/i)
                while @ff.link(:id, /remove_btn/).exists?
                    @ff.link(:id, /remove_btn/).click
                end
            else
                while current_rules.rindex(@user_choices[:scheduling_access_remove])
                    i = current_rules.rindex(@user_choices[:scheduling_access_remove])
                    current_rules.delete_at(i)
                    @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{i+2}]/td[5]/a").click
                end
            end
        end
    end

    def broadband_settings
        return unless self.menu(:advanced_setup, :broadband_settings)
        case @user_choices[:broadband_settings][0]
        when /eth/i
            list_select("encaps", "WAN ETHERNET")
            if @user_choices[:broadband_settings].length > 1
                @ff.radio(:id, "vlan_on").set if @user_choices[:broadband_settings][1].match(/enable|on/i)
                @ff.radio(:id, "vlan_off").set if @user_choices[:broadband_settings][1].match(/disable|off/i)
            end
            apply_settings("Broadband Settings")
            @ff.radio(:id, "vlan_on").checked? ? @log.info("Broadband Settings::Set to use WAN Ethernet with VLAN enabled") : @log.info("Broadband Settings::Set to use WAN Ethernet with VLAN disabled")
        when /hpna/i
            list_select("encaps", "WAN HPNA")
            apply_settings("Broadband Settings")
            @log.info("Broadband Settings::Set to use WAN HPNA")
        when /ptm/i
            list_select("encaps", "WAN DSL PTM")
            @user_choices[:broadband_settings][1..-1].each do |option|
                case option
                when /vlan/i
                    @ff.radio(:id, "vlan_on").set if option.match(/enable|on/i)
                    @ff.radio(:id, "vlan_off").set if option.match(/disable|off/i)
                when /mode/i
                    list_select("mode", option.split(':')[1].gsub('_', ' '))
                end
            end if @user_choices[:broadband_settings].length > 1
            apply_settings("Broadband Settings")
            @ff.radio(:id, "vlan_on").checked? ? @log.info("Broadband Settings::Set to use WAN DSL PTM with VLAN enabled. Line mode: #{@ff.select_list(:id, "mode").value}") : @log.info("Broadband Settings::Set to use WAN DSL PTM with VLAN disabled. Line mode: #{@ff.select_list(:id, "mode").value}")
        when /atm/i
            list_select("encaps", "WAN DSL ATM")
            @user_choices[:broadband_settings][1..-1].each do |option|
                case option
                when /vpi/i
                    @ff.text_field(:id, "vpi").set(option.split(':')[1])
                when /vci/i
                    @ff.text_field(:id, "vci").set(option.split(':')[1])
                when /qos/i
                    list_select("serviceCategory", option.split(':')[1].gsub('_', ' '), :name)
                when /pcr/i
                    @ff.text_field(:id, "pcr").set(option.split(':')[1])
                when /scr/i
                    @ff.text_field(:id, "scr").set(option.split(':')[1])
                when /mbs/i
                    @ff.text_field(:id, "mbs").set(option.split(':')[1])
                when /cdvt/i
                    @ff.text_field(:id, "cdvt").set(option.split(':')[1])
                when /encaps/i
                    @ff.radio(:id, "subrf32").set if option.match(/llc/i)
                    @ff.radio(:id, "subrf34").set if option.match(/vcmux/i)
                when /mode/i
                    list_select("mode", option.split(':')[1].gsub('_', ' '))
                end
            end if @user_choices[:broadband_settings].length > 1
            apply_settings("Broadband Settings")
            @log.info("Broadband Settings::Set to use WAN DSL ATM. Line mode: #{@ff.select_list(:id, "mode").value}")
            @log.info("Broadband Settings::(ATM) VPI/VCI is #{@ff.text_field(:id, "vpi").value}/#{@ff.text_field(:id, "vci").value}")
            @log.info("Broadband Settings::(ATM) PCR/SCR/MBS/CDVT is #{@ff.text_field(:id, "pcr").value}/#{@ff.text_field(:id, "scr").value}/#{@ff.text_field(:id, "mbs").value}/#{@ff.text_field(:id, "cdvt").value}")
            @log.info("Broadband Settings::(ATM) QoS set to #{@ff.select_list(:name, "serviceCategory").value}")
            @ff.radio(:id, "subrf32").checked? ? @log.info("Broadband Settings::(ATM) Using encapsulation mode LLC") : @log.info("Broadband Settings::(ATM) Using encapsulation mode VC-MUX")
        end
    end

    def wan_ethernet_settings
        return unless self.menu(:advanced_setup, :wan_ethernet_settings)
        if @user_choices[:wan_ethernet_settings][0].match(/disable|off/i)
            @ff.radio(:id, "vlan_off").set
            apply_settings("WAN Ethernet Settings")
            @log.info("WAN Ethernet Settings::VLAN Disabled")
        else
            # These rescue statements cover the R1000 changes.
            @ff.radio(:id, "vlan_on").set rescue @ff.radio(:id, "van_on").set
            @ff.text_field(:id, "vlanname").set(@user_choices[:wan_ethernet_settings][0]) rescue @ff.text_field(:id, "vlanMuxId").set(@user_choices[:wan_ethernet_settings][0])
            list_select("vlanMuxPr", @user_choices[:wan_ethernet_settings][1]) if @user_choices[:wan_ethernet_settings][1]
            apply_settings("WAN Ethernet Settings")
            @log.info("WAN Ethernet Settings::VLAN Enabled")
            @log.info("WAN Ethernet Settings::VLAN ID #{@ff.text_field(:id, "vlanMuxId").value}, VLAN Priority #{@ff.select_list(:id, "vlanMuxPr").value}") rescue @log.info("WAN Ethernet Settings::VLAN ID #{@ff.text_field(:id, "vlanname").value}, VLAN Priority #{@ff.select_list(:id, "vlanMuxPr").value}")
        end
    end
    
    def dhcp_settings
        return unless self.menu(:advanced_setup, :dhcp_settings)
        if @user_choices[:dhcp_settings][0].match(/disable|off|no/i)
            @ff.radio(:id, "dhcp_server_off").set
            apply_settings("DHCP Settings", "apply_btn")
            @log.info("DHCP Settings::DHCP disabled")
        else
            @ff.radio(:id, "dhcp_server_on").set
            apply_settings("DHCP Settings", "apply_btn")
            @log.info "DHCP Settings::DHCP enabled"
        end

        if @ff.radio(:id, "dhcp_server_on").checked?
            @ff.text_field(:id, "dhcpEthStart").set(@user_choices[:dhcp_settings][0]) if @user_choices[:dhcp_settings][0]
            @ff.text_field(:id, "dhcpEthEnd").set(@user_choices[:dhcp_settings][1]) if @user_choices[:dhcp_settings][1]
            @ff.text_field(:id, "dhcpSubnetMask").set(@user_choices[:dhcp_settings][2]) if @user_choices[:dhcp_settings][2]
            @log.info "DHCP Settings::DHCP settings set to #{@ff.text_field(:id, "dhcpEthStart").value}-#{@ff.text_field(:id, "dhcpEthEnd").value}/#{@ff.text_field(:id, "dhcpSubnetMask").value}"
            if @user_choices[:dhcp_lease_time]
                @ff.text_field(:id, "day").set(@user_choices[:dhcp_lease_time].split(":")[0])
                @ff.text_field(:id, "hour").set(@user_choices[:dhcp_lease_time].split(":")[1])
                @ff.text_field(:id, "minute").set(@user_choices[:dhcp_lease_time].split(":")[2])
                @log.info "DHCP Settings::DHCP lease time set to #{@user_choices[:dhcp_lease_time].split(":")[0]} days, #{@user_choices[:dhcp_lease_time].split(":")[1]} hours, #{@user_choices[:dhcp_lease_time].split(":")[2]} minutes"
            end
            if @user_choices[:dhcp_dns][0].match(/dynamic/i)
                @ff.radio(:id, "dns_dynamic").set
                @log.info "DHCP Settings::DNS set to dynamic"
            else
                @ff.radio(:id, "dns_static").set
                @ff.text_field(:id, "dnsPrimary").set(@user_choices[:dhcp_dns][0]) if @user_choices[:dhcp_dns][0]
                @ff.text_field(:id, "dnsSecondary").set(@user_choices[:dhcp_dns][1]) if @user_choices[:dhcp_dns][1]
                @log.info "DHCP Settings::Static primary DNS is #{@ff.text_field(:id, "dnsPrimary")}, secondary DNS is #{@ff.text_field(:id, "dnsSecondary")}"
            end if @user_choices[:dhcp_dns]
            apply_settings("DHCP Settings", "apply_btn")
        end
    end

    def lan_ip_address
        return unless self.menu(:advanced_setup, :lan_ip_address)
        @ff.text_field(:id, "ethIpAddress").set(@user_choices[:lan_ip_address][0].ip) if @user_choices[:lan_ip_address][0]
        if @user_choices[:lan_ip_address][0].netmask.empty?
            @ff.text_field(:id, "ethSubnetMask").set(@user_choices[:lan_ip_address][1]) if @user_choices[:lan_ip_address][1]
        else
            @ff.text_field(:id, "ethSubnetMask").set(@user_choices[:lan_ip_address][0].netmask)
        end
        @log.info "LAN IP Address::Set to #{@ff.text_field(:id, "ethIpAddress").value}/#{@ff.text_field(:id, "ethSubnetMask").value}"
        @ff.startClicker("OK")
        apply_settings("LAN IP Address", "applyandreboot_btn")
    end

    def wan_ip_address
        return unless self.menu(:advanced_setup, :wan_ip_address)
        list_select("wanport", @user_choices[:wan_interface].gsub('_', ' ')) if @user_choices[:wan_interface]
        begin
            # Use this code when there are frames
            case @user_choices[:wan_ip_address][0]
            when /pppoe/i
                @ff.frame(:name, "realpage").radio(:id, "PPPoE").set
                @ff.frame(:name, "realpage").checkbox(:id, "g6").click if @user_choices[:wan_ip_address][0].include?("+")
                if @user_choices[:ppp_username] || @user_choices[:ppp_password]
                    @ff.frame(:name, "realpage").text_field(:name, "ppp_username").set(@user_choices[:ppp_username]) if @user_choices[:ppp_username]
                    @log.info("WAN IP Address::Using PPP Username #{@ff.frame(:name, "realpage").text_field(:name, "ppp_username").value}") if @user_choices[:ppp_username]
                    @ff.frame(:name, "realpage").text_field(:name, "ppp_password").set(@user_choices[:ppp_password]) if @user_choices[:ppp_password]
                    @log.info("WAN IP Address::PPP password set to #{@user_choices[:ppp_password]}") if @user_choices[:ppp_password]
                else
                    @log.info "WAN IP Address::No username or password specified, setting to not require one"
                    @ff.frame(:name, "realpage").checkbox(:id, "subrf6").click
                end
                if @user_choices[:wan_ip_address][1]
                    @ff.frame(:name, "realpage").checkbox(:name, "vipmode").clear if @ff.frame(:name, "realpage").radio(:id, "subrf13").checked? # Uncheck in case we change, because of really annoying popup issue
                    @ff.frame(:name, "realpage").radio(:id, "subrf9").set if @user_choices[:wan_ip_address][1].match(/dynamic/i)
                    @ff.frame(:name, "realpage").radio(:id, "subrf11").set unless @user_choices[:wan_ip_address][1].include?("/") unless @user_choices[:wan_ip_address][1].match(/dynamic/i)
                    @ff.frame(:name, "realpage").radio(:id, "subrf13").set if @user_choices[:wan_ip_address][1].include?("/") unless @user_choices[:wan_ip_address][1].match(/dynamic/i)
                    if @ff.frame(:name, "realpage").radio(:id, "subrf11").checked?
                        @ff.frame(:name, "realpage").text_field(:name, "singlestaticip").set(@user_choices[:wan_ip_address][1])
                        @log.info "WAN IP Address::Using single static IP #{@ff.frame(:name, "realpage").text_field(:name, "singlestaticip").value}"
                    elsif @ff.frame(:name, "realpage").radio(:id, "subrf13").checked?
                        @ff.frame(:name, "realpage").checkbox(:name, "vipmode").clear unless @user_choices[:wan_ip_address][0].include?("+")
                        @ff.frame(:name, "realpage").text_field(:name, "gatewayadd").set(@user_choices[:wan_ip_address][1].to_ip.ip)
                        @ff.frame(:name, "realpage").text_field(:name, "subnetmask").set(@user_choices[:wan_ip_address][1].to_ip.netmask)
                        @log.info "WAN IP Address::Using block of static IP addresses. Gateway: #{@ff.frame(:name, "realpage").text_field(:name, "gatewayadd").value}, Subnet Mask: #{@ff.frame(:name, "realpage").text_field(:name, "subnetmask").value}"
                    end
                end
            when /pppoa/i
                @ff.frame(:name, "realpage").radio(:id, "PPPoA").set
                @ff.frame(:name, "realpage").checkbox(:id, "g6").click if @user_choices[:wan_ip_address][0].include?("+")
                if @user_choices[:ppp_username] || @user_choices[:ppp_password]
                    @ff.frame(:name, "realpage").text_field(:name, "ppp_username").set(@user_choices[:ppp_username]) if @user_choices[:ppp_username]
                    @log.info("WAN IP Address::Using PPP Username #{@ff.frame(:name, "realpage").text_field(:name, "ppp_username").value}") if @user_choices[:ppp_username]
                    @ff.frame(:name, "realpage").text_field(:name, "ppp_password").set(@user_choices[:ppp_password]) if @user_choices[:ppp_password]
                    @log.info("WAN IP Address::PPP password set to #{@user_choices[:ppp_password]}") if @user_choices[:ppp_password]
                else
                    @log.info "WAN IP Address::No username or password specified, setting to not require one"
                    @ff.frame(:name, "realpage").checkbox(:id, "subrf6").click
                end
                if @user_choices[:wan_ip_address][1]
                    @ff.frame(:name, "realpage").checkbox(:name, "vipmode").clear if @ff.frame(:name, "realpage").radio(:id, "subrf13").checked? # Uncheck in case we change, because of really annoying popup issue
                    @ff.frame(:name, "realpage").radio(:id, "subrf11").set unless @user_choices[:wan_ip_address][1].include?("/")
                    @ff.frame(:name, "realpage").radio(:id, "subrf13").set if @user_choices[:wan_ip_address][1].include?("/")
                    if @ff.frame(:name, "realpage").radio(:id, "subrf11").checked?
                        @ff.frame(:name, "realpage").text_field(:name, "singlestaticip").set(@user_choices[:wan_ip_address][1])
                        @log.info "WAN IP Address::Using single static IP #{@ff.frame(:name, "realpage").text_field(:name, "singlestaticip").value}"
                    elsif @ff.frame(:name, "realpage").radio(:id, "subrf13").checked?
                        @ff.frame(:name, "realpage").checkbox(:name, "vipmode").clear unless @user_choices[:wan_ip_address][0].include?("+")
                        @ff.frame(:name, "realpage").text_field(:name, "gatewayadd").set(@user_choices[:wan_ip_address][1].to_ip.ip)
                        @ff.frame(:name, "realpage").text_field(:name, "subnetmask").set(@user_choices[:wan_ip_address][1].to_ip.netmask)
                        @log.info "WAN IP Address::Using block of static IP addresses. Gateway: #{@ff.frame(:name, "realpage").text_field(:name, "gatewayadd").value}, Subnet Mask: #{@ff.frame(:name, "realpage").text_field(:name, "subnetmask").value}"
                    end
                end
            when /transparent/i
                @ff.frame(:name, "realpage").radio(:id, "rfc_1483_transparent_bridging").set
                @log.info "WAN IP Address::Setting to transparent bridging"
            when /dhcp/i
                @ff.frame(:name, "realpage").radio(:id, "rfc_1483_dhcp").set
                unless @user_choices[:wan_ip_address][1].include?(":")
                    @ff.frame(:name, "realpage").text_field(:name, "ppp_username").set(@user_choices[:wan_ip_address][1].to_ip.ip)
                    @log.info("WAN IP Address::Using host name #{@ff.frame(:name, "realpage").text_field(:name, "ppp_username").value}")
                    @ff.frame(:name, "realpage").text_field(:name, "domain_name").set(@user_choices[:wan_ip_address][1].to_ip.netmask)
                    @log.info("WAN IP Address::Using domain name #{@ff.frame(:name, "realpage").text_field(:name, "domain_name").value}")
                end if @user_choices[:wan_ip_address][1]
            when /static/i
                @ff.frame(:name, "realpage").radio(:id, "rfc_1483_static_ip").set
                @log.info("WAN IP Address::Using RFC 1483 via Static IP")
                if @user_choices[:wan_ip_address][1].include?(":")
                    @ff.frame(:name, "realpage").text_field(:name, "ipadd").set(@user_choices[:wan_ip_address][1].split(":")[0].to_ip.ip)
                    @log.info("WAN IP Address::Using host name #{@ff.frame(:name, "realpage").text_field(:name, "ipadd").value}")
                    @ff.frame(:name, "realpage").text_field(:name, "submask").set(@user_choices[:wan_ip_address][1].split(":")[0].to_ip.netmask)
                    @log.info("WAN IP Address::Using subnet mask #{@ff.frame(:name, "realpage").text_field(:name, "submask").value}")
                    @ff.frame(:name, "realpage").text_field(:name, "gateadd").set(@user_choices[:wan_ip_address][1].split(":")[1])
                    @log.info("WAN IP Address::Using gateway address #{@ff.frame(:name, "realpage").text_field(:name, "gateadd").value}")
                else
                    @log.info("WAN IP Address::Command line for static IP must be in format of IP/NETMASK:GATEWAY; No changes made")
                end if @user_choices[:wan_ip_address][1]
            end

            if @user_choices[:wan_ip_address_dns][0].match(/dynamic/i)
                @ff.frame(:name, "realpage").radio(:id, "subrf22").set
                @log.info("WAN IP Address::Using dynamic DNS")
            else
                @ff.frame(:name, "realpage").radio(:id, "subrf24").set
                @ff.frame(:name, "realpage").text_field(:name, "primarydns").set(@user_choices[:wan_ip_address_dns][0])
                @ff.frame(:name, "realpage").text_field(:name, "secdns").set(@user_choices[:wan_ip_address_dns][1]) if @user_choices[:wan_ip_address_dns][1]
                @log.info("WAN IP Address::Using DNS servers: #{@ff.frame(:name, "realpage").text_field(:name, "primarydns").value}, #{@ff.frame(:name, "realpage").text_field(:name, "secdns").value}")
            end if @user_choices[:wan_ip_address_dns]
            if @user_choices[:wan_ip_address][2]
                @ff.frame(:name, "realpage").radio(:id, "subrf32").set if @user_choices[:wan_ip_address][2].match(/llc/i)
                @ff.frame(:name, "realpage").radio(:id, "subrf34").set if @user_choices[:wan_ip_address][2].match(/vcmux/i)
            end
        rescue
            # Use this code when there are no frames
            case @user_choices[:wan_ip_address][0]
            when /pppoe/i
                @ff.radio(:id, "PPPoE").set
                @ff.checkbox(:id, "g6").click if @user_choices[:wan_ip_address][0].include?("+")
                if @user_choices[:ppp_username] || @user_choices[:ppp_password]
                    @ff.text_field(:name, "ppp_username").set(@user_choices[:ppp_username]) if @user_choices[:ppp_username]
                    @log.info("WAN IP Address::Using PPP Username #{@ff.text_field(:name, "ppp_username").value}") if @user_choices[:ppp_username]
                    @ff.text_field(:name, "ppp_password").set(@user_choices[:ppp_password]) if @user_choices[:ppp_password]
                    @log.info("WAN IP Address::PPP password set to #{@user_choices[:ppp_password]}") if @user_choices[:ppp_password]
                else
                    @log.info "WAN IP Address::No username or password specified, setting to not require one"
                    @ff.checkbox(:id, "subrf6").click
                end
                if @user_choices[:wan_ip_address][1]
                    @ff.checkbox(:name, "vipmode").clear if @ff.radio(:id, "subrf13").checked? # Uncheck in case we change, because of really annoying popup issue
                    @ff.radio(:id, "subrf9").set if @user_choices[:wan_ip_address][1].match(/dynamic/i)
                    @ff.radio(:id, "subrf11").set unless @user_choices[:wan_ip_address][1].include?("/") unless @user_choices[:wan_ip_address][1].match(/dynamic/i)
                    @ff.radio(:id, "subrf13").set if @user_choices[:wan_ip_address][1].include?("/") unless @user_choices[:wan_ip_address][1].match(/dynamic/i)
                    if @ff.radio(:id, "subrf11").checked?
                        @ff.text_field(:name, "singlestaticip").set(@user_choices[:wan_ip_address][1])
                        @log.info "WAN IP Address::Using single static IP #{@ff.text_field(:name, "singlestaticip").value}"
                    elsif @ff.radio(:id, "subrf13").checked?
                        @ff.checkbox(:name, "vipmode").clear unless @user_choices[:wan_ip_address][0].include?("+")
                        @ff.text_field(:name, "gatewayadd").set(@user_choices[:wan_ip_address][1].to_ip.ip)
                        @ff.text_field(:name, "subnetmask").set(@user_choices[:wan_ip_address][1].to_ip.netmask)
                        @log.info "WAN IP Address::Using block of static IP addresses. Gateway: #{@ff.text_field(:name, "gatewayadd").value}, Subnet Mask: #{@ff.text_field(:name, "subnetmask").value}"
                    end
                end
            when /pppoa/i
                @ff.radio(:id, "PPPoA").set
                @ff.checkbox(:id, "g6").click if @user_choices[:wan_ip_address][0].include?("+")
                if @user_choices[:ppp_username] || @user_choices[:ppp_password]
                    @ff.text_field(:name, "ppp_username").set(@user_choices[:ppp_username]) if @user_choices[:ppp_username]
                    @log.info("WAN IP Address::Using PPP Username #{@ff.text_field(:name, "ppp_username").value}") if @user_choices[:ppp_username]
                    @ff.text_field(:name, "ppp_password").set(@user_choices[:ppp_password]) if @user_choices[:ppp_password]
                    @log.info("WAN IP Address::PPP password set to #{@user_choices[:ppp_password]}") if @user_choices[:ppp_password]
                else
                    @log.info "WAN IP Address::No username or password specified, setting to not require one"
                    @ff.checkbox(:id, "subrf6").click
                end
                if @user_choices[:wan_ip_address][1]
                    @ff.checkbox(:name, "vipmode").clear if @ff.radio(:id, "subrf13").checked? # Uncheck in case we change, because of really annoying popup issue
                    @ff.radio(:id, "subrf11").set unless @user_choices[:wan_ip_address][1].include?("/")
                    @ff.radio(:id, "subrf13").set if @user_choices[:wan_ip_address][1].include?("/")
                    if @ff.radio(:id, "subrf11").checked?
                        @ff.text_field(:name, "singlestaticip").set(@user_choices[:wan_ip_address][1])
                        @log.info "WAN IP Address::Using single static IP #{@ff.text_field(:name, "singlestaticip").value}"
                    elsif @ff.radio(:id, "subrf13").checked?
                        @ff.checkbox(:name, "vipmode").clear unless @user_choices[:wan_ip_address][0].include?("+")
                        @ff.text_field(:name, "gatewayadd").set(@user_choices[:wan_ip_address][1].to_ip.ip)
                        @ff.text_field(:name, "subnetmask").set(@user_choices[:wan_ip_address][1].to_ip.netmask)
                        @log.info "WAN IP Address::Using block of static IP addresses. Gateway: #{@ff.text_field(:name, "gatewayadd").value}, Subnet Mask: #{@ff.text_field(:name, "subnetmask").value}"
                    end
                end
            when /transparent/i
                @ff.radio(:id, "rfc_1483_transparent_bridging").set
                @log.info "WAN IP Address::Setting to transparent bridging"
            when /dhcp/i
                @ff.radio(:id, "rfc_1483_dhcp").set
                unless @user_choices[:wan_ip_address][1].include?(":")
                    @ff.text_field(:name, "ppp_username").set(@user_choices[:wan_ip_address][1].to_ip.ip)
                    @log.info("WAN IP Address::Using host name #{@ff.text_field(:name, "ppp_username").value}")
                    @ff.text_field(:name, "domain_name").set(@user_choices[:wan_ip_address][1].to_ip.netmask)
                    @log.info("WAN IP Address::Using domain name #{@ff.text_field(:name, "domain_name").value}")
                end if @user_choices[:wan_ip_address][1]
            when /static/i
                @ff.radio(:id, "rfc_1483_static_ip").set
                @log.info("WAN IP Address::Using RFC 1483 via Static IP")
                if @user_choices[:wan_ip_address][1].include?(":")
                    @ff.text_field(:name, "ipadd").set(@user_choices[:wan_ip_address][1].split(":")[0].to_ip.ip)
                    @log.info("WAN IP Address::Using host name #{@ff.text_field(:name, "ipadd").value}")
                    @ff.text_field(:name, "submask").set(@user_choices[:wan_ip_address][1].split(":")[0].to_ip.netmask)
                    @log.info("WAN IP Address::Using subnet mask #{@ff.text_field(:name, "submask").value}")
                    @ff.text_field(:name, "gateadd").set(@user_choices[:wan_ip_address][1].split(":")[1])
                    @log.info("WAN IP Address::Using gateway address #{@ff.text_field(:name, "gateadd").value}")
                else
                    @log.info("WAN IP Address::Command line for static IP must be in format of IP/NETMASK:GATEWAY; No changes made")
                end if @user_choices[:wan_ip_address][1]
            end

            if @user_choices[:wan_ip_address_dns][0].match(/dynamic/i)
                @ff.radio(:id, "subrf22").set
                @log.info("WAN IP Address::Using dynamic DNS")
            else
                @ff.radio(:id, "subrf24").set
                @ff.text_field(:name, "primarydns").set(@user_choices[:wan_ip_address_dns][0])
                @ff.text_field(:name, "secdns").set(@user_choices[:wan_ip_address_dns][1]) if @user_choices[:wan_ip_address_dns][1]
                @log.info("WAN IP Address::Using DNS servers: #{@ff.text_field(:name, "primarydns").value}, #{@ff.text_field(:name, "secdns").value}")
            end if @user_choices[:wan_ip_address_dns]
            if @user_choices[:wan_ip_address][2]
                @ff.radio(:id, "subrf32").set if @user_choices[:wan_ip_address][2].match(/llc/i)
                @ff.radio(:id, "subrf34").set if @user_choices[:wan_ip_address][2].match(/vcmux/i)
            end
        end
        apply_settings("WAN IP Address")
    end

    def hpna_lan
        return unless self.menu(:advanced_setup, :hpna_lan)
        @ff.radio(:id, "id_hpna_state_on").set if @user_choices[:hpna_lan]
        @ff.radio(:id, "id_hpna_state_off").set unless @user_choices[:hpna_lan]
        apply_settings("HPNA LAN")
        @ff.radio(:id, "id_hpna_state_on").checked? ? @log.info("HPNA LAN::Enabled") : @log.info("HPNA LAN::Disabled")
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
            @log.info("QoS Upstream::QoS upstream is now enabled for Default QoS")
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
        # Enable/disable
        if @user_choices[:remote_telnet]
            @ff.radio(:id, "remote_management_enabled").set
            @log.info "Remote Telnet::Remote management turned on"
        else
            @ff.radio(:id, "remote_management_disabled").set
            @log.info "Remote Telnet::Remote management turned off"
        end if @user_choices.member?(:remote_telnet)

        # Change username/password
        if @user_choices[:telnet_info]
            @ff.text_field(:id, "admin_user_name").set(@user_choices[:telnet_info][0])
            @ff.text_field(:id, "admin_password").set(@user_choices[:telnet_info][1])
            @log.info("Remote Telnet::telnet Username and password set to: #{@ff.text_field(:id, "admin_user_name").value}/#{@ff.text_field(:id, "admin_password").value}")
        end

        # Timeout setting
        list_select("remote_management_timeout", @user_choices[:remote_telnet_timeout]) if @user_choices[:remote_telnet_timeout]
        apply_settings("Remote Telnet")
    end

    def dynamic_routing
        if @user_choices[:dynamic_routing].match(/disable|off|no/i)
            return unless self.menu(:advanced_setup, :dynamic_routing)
            @ff.radio(:id, "rip_ver_off").set
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
        @ff.radio(:id, "rip_ver_1").set if @user_choices[:dynamic_routing].match(/1/)
        @ff.radio(:id, "rip_ver_2").set if @user_choices[:dynamic_routing].match(/2/)
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
        #/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[2]/td
        while @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td[2]").exists?
            current_rules << "#{@ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/table[4]/tbody/tr[#{last_count}]/td").join("\t")}"
            last_count += 1
        end
        @ff.text_field(:id, "dstAddr").set(@user_choices[:static_routing][0]) if @user_choices[:static_routing][0]
        @ff.text_field(:id, "dstMask").set(@user_choices[:static_routing][1]) if @user_choices[:static_routing][1]
        @ff.text_field(:id, "dstGtwy").set(@user_choices[:static_routing][2]) if @user_choices[:static_routing][2]

        if @ff.text_field(:id, "dstWanIf").exists?
            @ff.text_field(:id, "dstWanIf").set(@user_choices[:static_routing][3])
        else
            list_select("dstWanIf", @user_choices[:static_routing][3], :name)
        end if @user_choices[:static_routing][3]
        
        apply_settings("Static Routing")
        current_rules << @ff.elements_by_xpath("/html/body/div/div[3]/div[2]/form/table[5]/tbody/tr[#{last_count}]/td").join("\t") if @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[5]/tbody/tr[#{last_count}]/td").exists?
        @log.info("Static Routing::Current static routing rules - \nDestination IP\tSubnet Mask\tGateway IP\tDevice\n#{current_rules}")
    end

    def admin_password
        return unless self.menu(:advanced_setup, :admin_password)
        @ff.text_field(:id, "admin_user_name").set(@user_choices[:admin_password][0]) if @user_choices[:admin_password][0]
        @ff.text_field(:id, "admin_password").set(@user_choices[:admin_password][1]) if @user_choices[:admin_password][1]
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
        elsif @user_choices[:port_forwarding][0].match(/random/i)
            protocol = rand(100) > 50 ? "UDP" : "TCP"
            start_port = rand(65534)+1
            end_port = rand(65535-start_port)+start_port
            list_select("lan_port_protocol", protocol)
            @ff.text_field(:id, "lan_starting_port").set(start_port)
            @ff.text_field(:id, "lan_ending_port").set(end_port)
            @ff.text_field(:id, "lan_port_ipaddress").set(@user_choices[:port_forwarding][1])
            @log.info "Port Forwarding::Forwarding #{protocol} port #{start_port}-#{end_port} to #{@user_choices[:port_forwarding][1]}"
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
            self.please_wait
        end if @user_choices[:port_forwarding_remove]
    end

    def applications
        return unless self.menu(:advanced_setup, :applications)
        if @user_choices[:applications]
            @ff.select_list(:id, "lan_device").getAllContents.each { |value| @ff.select_list(:id, "lan_device").select(value) if value.match(/#{@user_choices[:applications][0]}/i) }
            @ff.text_field(:id, "ip_address").set(@user_choices[:applications][0]) if @ff.select_list(:id, "lan_device").value.match(/manually/i)
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
        if @user_choices[:dmz_hosting].match(/off|disable/i)
            if @ff.radio(:id, "off").checked?
                @log.info("DMZ Hosting::Already disabled")
            else
                @ff.radio(:id, "off").set
                apply_settings("DMZ Hosting")
                @log.info("DMZ Hosting::Disabled")
            end
        else
            @ff.radio(:id, "on").set
            @ff.select_list(:id, "lan_device").getAllContents.each { |value| @ff.select_list(:id, "lan_device").select(value) if value.match(/#{@user_choices[:dmz_hosting]}/i) }
            @ff.text_field(:id, "ip_address").set(@user_choices[:dmz_hosting]) if @ff.select_list(:id, "lan_device").value.match(/manually/i)
            apply_settings("DMZ Hosting")
            @log.info("DMZ Hosting::DMZ turned on for device #{@user_choices[:dmz_hosting]}")
        end
    end

    def firewall
        return unless self.menu(:advanced_setup, :firewall)
        case @user_choices[:firewall]
        when /off|nat/i
            @ff.radio(:id, "firewall_security_level_off").set
            apply_settings("Firewall")
            @log.info("Firewall::Firewall set to off/NAT only")
        when /low/i
            @ff.radio(:id, "firewall_security_level_low").set
            apply_settings("Firewall")
            @log.info("Firewall::Firewall set to low security")
        when /med/i
            @ff.radio(:id, "firewall_security_level_medium").set
            apply_settings("Firewall")
            @log.info("Firewall::Firewall set to medium security")
        when /high/i
            @ff.radio(:id, "firewall_security_level_high").set
            apply_settings("Firewall")
            @log.info("Firewall::Firewall set to high security")
        end if @user_choices[:firewall]
  
        if @user_choices[:firewall_services]
            valid_services = ["no entry", "no entry"]
            counter = 2

            # Gather valid elements
            while @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{counter}]/td").exists?
                valid_services << @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{counter}]/td").innerHTML.gsub(' ', '_').downcase
                counter += 1
            end

            # If we're doing an action to all, it goes here
            if @user_choices[:firewall_services][0].match(/all/i)
                valid_index = 2
                while @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td").exists?
                    @user_choices[:firewall_services][0].split(":")[1].match(/on/i) ? @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[4]/input").set : @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[4]/input").clear
                    @user_choices[:firewall_services][0].split(":")[2].match(/on/i) ? @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[5]/input").set : @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[5]/input").clear
                    valid_index += 1
                end
                valid_index = nil
                apply_settings("Firewall")
                @log.info("Firewall::All services inbound turned #{@user_choices[:firewall_services][0].split(":")[1]}, outbound turned #{@user_choices[:firewall_services][0].split(":")[2]}")
            end

            # Individual actions here
            @user_choices[:firewall_services].each do |service|
                if valid_index = valid_services.index(service.split(":")[0].downcase)
                    service.split(":")[1].match(/on/i) ? @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[4]/input").set : @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[4]/input").clear
                    service.split(":")[2].match(/on/i) ? @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[5]/input").set : @ff.element_by_xpath("/html/body/div/div[4]/div[2]/form/div/table/tbody/tr[#{valid_index}]/td[5]/input").clear
                    @log.info("Firewall::Service #{service.split(":")[0]} traffic in turned #{service.split(":")[1]}, traffic out turned #{service.split(":")[2]}")
                else
                    @log.info("Firewall::Unable to find service named #{service.split(":")[0]}")
                end unless service.match(/all/i)
            end

            # Apply settings if we did something other than an "all" action up above
            apply_settings("Firewall") if @user_choices[:firewall_services].length > 1
        end unless @ff.radio(:id, "firewall_security_level_off").checked?
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