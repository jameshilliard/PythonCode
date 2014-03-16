# Module for wireless settings on Q1000

module WirelessSetup
    def basic_settings
        return unless self.menu(:wireless_setup)
        # Turn wireless on or off
        if @user_choices[:wireless]
            @ff.radio(:id, "id_wl_on").set if @user_choices[:wireless].match(/on|yes|enable/i)
            @ff.radio(:id, "id_wl_off").set if @user_choices[:wireless].match(/off|no|disable/i)
            @ff.radio(:id, "id_wl_on").checked? ? @log.info("Basic Wireless::Wireless selected to on") : @log.info("Basic Wireless::Wireless selected to off")
        end
        # Change ssid
        if @ff.radio(:id, "id_wl_on").checked?
            @ff.text_field(:id, "id_ssid").set(@user_choices[:wireless_ssid])
            @log.info("Basic Wireless::Changed SSID to #{@ff.text_field(:id, "id_ssid").value}")
        end if @user_choices[:wireless_ssid]
        self.apply_settings("Basic Wireless")
    end

    def multiple_ssid
        return unless self.menu(:wireless_setup, :multiple_ssid)
        return unless self.list_select(:id_ssid, @user_choices[:wireless_ssid])
        if @user_choices[:mssid_name].match(/\Aoff\z|\Adisable\z/i)
            @ff.radio(:id, "id_ssid_disable").set
            self.apply_settings("Multiple SSID")
            @log.info("Multiple SSID::#{@user_choices[:wireless_name]} changed to #{@user_choices[:mssid_name]}")
            return
        else
            @ff.radio(:id, "id_ssid_enable").set
            @log.info("Multiple SSID::#{@user_choices[:wireless_name]} changed to #{@user_choices[:mssid_name]}")
        end
        @ff.text_field(:id, "id_ssid_name").set(@user_choices[:mssid_name])
        @log.info("Multiple SSID::#{@user_choices[:wireless_name]} changed to #{@user_choices[:mssid_name]}")
        if @user_choices[:mssid_settings]
            if @user_choices[:mssid_settings][0].match(/\Aoff\z|\Adisable\z/i)
                @ff.radio(:id, "id_ssid_subnet_disable").set
                @log.info("Multiple SSID::Disabled separate subnet settings")
                self.apply_settings("Multiple SSID")
                return
            end
            @ff.radio(:id, "id_ssid_subnet_enable").set
            @log.info("Multiple SSID::Enabled separate subnet settings")
            if @user_choices[:mssid_settings][0]
                @ff.text_field(:id, "id_dhcp_start_address").set(@user_choices[:mssid_settings][0])
                @log.info("Multiple SSID::Using DHCP start of #{@user_choices[:mssid_settings][0]}")
            end
            if @user_choices[:mssid_settings][1]
                @ff.text_field(:id, "id_dhcp_end_address").set(@user_choices[:mssid_settings][1])
                @log.info("Multiple SSID::Using DHCP end #{@user_choices[:mssid_settings][1]}")
            end
            if @user_choices[:mssid_settings][2]
                @ff.text_field(:id, "id_ssid_gateway").set(@user_choices[:mssid_settings][2])
                @log.info("Multiple SSID::Using gateway #{@user_choices[:mssid_settings][2]}")
            end
            if @user_choices[:mssid_settings][3]
                @ff.text_field(:id, "id_ssid_subnetmask").set(@user_choices[:mssid_settings][3])
                @log.info("Multiple SSID::Using subnet mask #{@user_choices[:mssid_settings][3]}")
            end
        end
        self.apply_settings("Multiple SSID")
    end

    def wep
        return unless self.menu(:wireless_setup, :wep)
        list_select("id_ssid", @user_choices[:wireless_ssid])
        # Enable/disable WEP
        if @user_choices[:wep].match(/disable|off|no/i)
            @ff.radio(:name => "WEPEnable", :index => 2).set
            @log.info("WEP::Disabled")
        else
            @ff.radio(:name => "WEPEnable", :index => 1).set
            @log.info("WEP::Enabled")
        end if @user_choices[:wep]

        if @ff.radio(:name => "WEPEnable", :index => 1).checked?
            # WEP Authentication type
            if @user_choices[:wep_authentication_type]
                list_select("id_auth_type", @user_choices[:wep_authentication_type])
                @log.info("WEP::Authentication type set to #{@user_choices[:wep_authentication_type]}")
            end
            # WEP Key set
            if @user_choices[:wep_key][0].match(/\Adefault\z/i)
                @ff.radio(:id, "wsa9").set
                @log.info("WEP::Using default key/passphrase")
            else
                @ff.radio(:id, "wsa11").set
                if @user_choices[:wep_key].length > 1
                    @ff.radio(:id, "id_key#{@user_choices[:wep_key][0]}_number").set
                    @log.info("WEP::Using custom key/passphrase")
                    if @user_choices[:wep_key][1]
                        list_select("id_key#{@user_choices[:wep_key][0]}_bits", "64 Bits") if @user_choices[:wep_key][1].length == 10
                        list_select("id_key#{@user_choices[:wep_key][0]}_bits", "128 Bits") if @user_choices[:wep_key][1].length == 26
                        @ff.text_field(:id, "id_key#{@user_choices[:wep_key]}_value").set(@user_choices[:wep_key][1])
                        @log.info("WEP::Key #{@user_choices[:wep_key][0]} set to #{@user_choices[:wep_key][1]}")
                    end
                end
            end if @user_choices[:wep_key][0]
        end
        self.apply_settings("WEP")
    end
    
    def wep_8021x
        return unless self.menu(:wireless_setup, :wep_8021x)
        list_select("id_ssid", @user_choices[:wireless_ssid])
        if @user_choices[:wep_8021x][0].match(/disable|off|no/i)
            @ff.radio(:id, "id_wepAuth_disable").set
            @log.info("WEP+802.1x::Disabled")
        else
            @ff.radio(:id, "id_wepAuth_enable").set
            @log.info("WEP+802.1x::Enabled")
            if @user_choices[:wep_8021x][0]
                @ff.text_field(:id, "id_server_ip_address").set(@user_choices[:wep_8021x][0])
                @log.info("WEP+802.1x::Using server IP address of #{@user_choices[:wep_8021x][0]}")
            end
            if @user_choices[:wep_8021x][1]
                @ff.text_field(:id, "id_port").set(@user_choices[:wep_8021x][1])
                @log.info("WEP+802.1x::Using port #{@user_choices[:wep_8021x][1]}")
            end
            if @user_choices[:wep_8021x][2]
                @ff.text_field(:id, "id_secret").set(@user_choices[:wep_8021x][2])
                @log.info("WEP+802.1x::Using secret #{@user_choices[:wep_8021x][2]}")
            end
            if @user_choices[:wep_8021x][3]
                @ff.text_field(:id, "id_group_key_interval").set(@user_choices[:wep_8021x][3])
                @log.info("WEP+802.1x::Using group key interval #{@user_choices[:wep_8021x][3]}")
            end
        end if @user_choices[:wep_8021x][0]
        self.apply_settings("WEP+802.1x")
    end

    def wpa
        return unless self.menu(:wireless_setup, :wpa)
        list_select("id_ssid", @user_choices[:wireless_ssid])
        # Turn on and off
        if @user_choices[:wpa].match(/disable|off|no/i)
            @ff.radio(:name => "WPAEnable", :index => 2).set
            @log.info("WPA::Disabled")
        else
            @ff.radio(:name => "WPAEnable", :index => 1).set
            @log.info("WPA::Enabled")
        end if @user_choices[:wpa]

        if @ff.radio(:name => "WPAEnable", :index => 1).checked?
            # WPA type
            if @user_choices[:wpa_type]
                list_select("id_select_wpa", "#{@user_choices[:wpa_type]}-Personal") unless @user_choices[:wpa_type].match(/both/i)
                list_select("id_select_wpa", "WPA or WPA2") if @user_choices[:wpa_type].match(/both/i)
                @log.info("WPA::Type set to #{@ff.select_list(:id, "id_select_wpa").value}")
            end

            # WPA encryption
            if @user_choices[:wpa_cipher]
                list_select("id_wpa_cipher", @user_choices[:wpa_cipher])
                @log.info("WPA::Encryption type set to #{@user_choices[:wpa_cipher]}")
            end

            # WPA key
            if @user_choices[:wpa_key].match(/\Adefault\z/i)
                @ff.radio(:id, "id_default_options").set
                @log.info("WPA::Using default key/passphrase")
            else
                @ff.radio(:id, "id_home_network_options").set
                @ff.text_field(:id, "id_pre_shared_key").set(@user_choices[:wpa_key])
                @log.info("WPA::Key/passphrase set to #{@user_choices[:wpa_key]}")
            end if @user_choices[:wpa_key]

            # Enterprise settings
            if @user_choices[:wpa_enterprise][0].match(/disable|off|no/i)
                @ff.radio(:id, "id_wepAuth_disable").set
                @log.info("WPA Enterprise::Disabled")
            else
                @ff.radio(:id, "id_wepAuth_enable").set
                @log.info("WPA Enterprise::Enabled")
                if @user_choices[:wpa_enterprise][1]
                    @ff.text_field(:id, "id_server_ip_address").set(@user_choices[:wpa_enterprise][1])
                    @log.info("WPA Enterprise::Using server IP address of #{@user_choices[:wpa_enterprise][1]}")
                end
                if @user_choices[:wpa_enterprise][2]
                    @ff.text_field(:id, "id_port").set(@user_choices[:wpa_enterprise][2])
                    @log.info("WPA Enterprise::Using port #{@user_choices[:wpa_enterprise][2]}")
                end
                if @user_choices[:wpa_enterprise][3]
                    @ff.text_field(:id, "id_secret").set(@user_choices[:wpa_enterprise][3])
                    @log.info("WPA Enterprise::Using secret #{@user_choices[:wpa_enterprise][3]}")
                end
                if @user_choices[:wpa_enterprise][0]
                    @ff.text_field(:id, "id_group_key_interval").set(@user_choices[:wpa_enterprise][0])
                    @log.info("WPA Enterprise::Using group key interval #{@user_choices[:wpa_enterprise][0]}")
                end
            end if @user_choices[:wpa_enterprise]
        end
        self.apply_settings("WPA")
    end

    def wmm
        return unless self.menu(:wireless_setup, :wmm)
        @ff.radio(:id, "id_wmm_on").set if @user_choices[:wmm] == true
        @ff.radio(:id, "id_wmm_off").set if @user_choices[:wmm] == false
        @ff.radio(:id, "id_wmm_on").checked? ? @log.info("WMM::Enabled") : @log.info("WMM::Disabled")
        @ff.radio(:id, "id_wmm_powersave_enable").set if @user_choices[:wmm_powersave] == true
        @ff.radio(:id, "id_wmm_powersave_disable").set if @user_choices[:wmm_powersave] == false
        @ff.radio(:id, "id_wmm_powersave_enable").checked? ? @log.info("WMM::Powersave enabled") : @log.info("WMM::Powersave disabled")
        self.apply_settings("Wireless Settings")
    end

    def wps
        return unless self.menu(:wireless_setup, :wps)
        # Enable/disable WPS
        unless @user_choices[:wps].nil?
            @ff.radio(:id, "id_state_enable").set if @user_choices[:wps]
            @ff.radio(:id, "id_state_disable").set unless @user_choices[:wps]
            self.apply_settings("WPS")
            @ff.radio(:id, "id_state_enable").checked? ? @log.info("WPS::Enabled") : @log.info("WPS::Disabled")
        end
        if @ff.radio(:id, "id_state_enable").checked?
            # Generate WPS pin
            if @user_choices[:wps_generate_pin]
                @log.info("WPS::Generating a new pin")
                @ff.link(:id, "generatepin_btn").click
                self.please_wait
                @log.info "WPS::Generated pin #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/div/table/tbody/tr/td/p[2]/span/strong").innerHTML}"
            end
            # Restore default pin
            if @user_choices[:wps_restore_pin]
                @ff.link(:id, "restoredefaultpin_btn").click
                self.please_wait
                @log.info "WPS::Generated pin #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/div/table/tbody/tr/td/p[2]/span/strong").innerHTML}"
            end

            @ff.radio(:id, "id_pbc_radio").set if @user_choices[:wps_pbc]
            unless @user_choices[:wps_edp].empty?
                @ff.radio(:id, "id_pin_radio").set
                @ff.text_field(:id, "id_input_pin").set(@user_choices[:wps_edp])
            end
            self.apply_settings("WPS")

            # Connect
            if @user_choices[:wps_connect]
                @ff.link(:id, "connect_btn").click
                @log.info("WPS::120 second connect wait started")
                self.please_wait
                @log.info("WPS::120 second connect wait ended")
            end
        end
    end

    def ssid_broadcast
        return unless self.menu(:wireless_setup, :ssid_broadcast)
        return unless self.list_select(:id_ssid, @user_choices[:wireless_ssid])
        @ff.radio(:id, "id_mode_bcast").set if @user_choices[:ssid_broadcast]
        @ff.radio(:id, "id_mode_hide").set unless @user_choices[:ssid_broadcast]
        self.apply_settings("Wireless SSID Broadcast")
    end

    def mac_authentication
        return unless self.menu(:wireless_setup, :wirelessmacauthentication)
        list_select("id_ssid", @user_choices[:wireless_ssid])

        # Turn MAC authentication on or off
        if @user_choices[:wireless_mac_authentication][0].match(/\Adisable\z|\Aoff\z/i)
            @ff.radio(:id, "id_mac_authentication_disable").set
            @log.info("Wireless MAC Authentication::Disabled")
            self.apply_settings("Wireless MAC Authentication")
        elsif @user_choices[:wireless_mac_authentication][0].match(/\Aenable\z|\Aon\z/i)
            @ff.radio(:id, "id_mac_authentication_enable").set
            @log.info("Wireless MAC Authentication::Enabled")
            self.apply_settings("Wireless MAC Authentication")
        end if @user_choices[:wireless_mac_authentication][0]
        if @ff.radio(:id, "id_mac_authentication_enable").checked?
            # Set to allow or deny list
            if @user_choices[:wireless_mac_authentication][1].match(/allow/i)
                @ff.radio(:id, "id_allow_devices_allow").set
                @log.info("Wireless MAC Authentication::")
            elsif @user_choices[:wireless_mac_authentication][1].match(/deny/i)
                @ff.radio(:id, "id_allow_devices_deny").set
                @log.info("Wireless MAC Authentication::")
            end if @user_choices[:wireless_mac_authentication][1]
            # Add a MAC
            if @user_choices[:wireless_mac_authentication_add]
                @ff.select_list(:id, "id_mac_address_0").getAllContents.each { |value| @ff.select_list(:id, "id_mac_address_0").select(value) if value.match(/#{@user_choices[:wireless_mac_authentication_add]}/i) }
                @ff.text_field(:id, "id_manual_mac_address_0").set(@user_choices[:wireless_mac_authentication_add]) if @ff.select_list(:id, "id_mac_address_0").value == "Manually Enter MAC"
            end
            self.apply_settings("Wireless MAC Authentication")
        end
        if @user_choices[:wireless_mac_authentication_remove]
            if @user_choices[:wireless_mac_authentication_remove].is_a?(String)
                mac_index_list = []
                mac_counter = 2
                while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[6]/tbody/tr[#{mac_counter}]/td[4]/a").exists?
                    mac_index_list << @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[6]/tbody/tr[#{mac_counter}]/td[4]/a").innerHTML.downcase
                    mac_counter += 1
                end
                remove_id = mac_index_list.index(@user_choices[:wireless_mac_authentication_remove])
                @ff.link(:xpath, "/html/body/div/div[3]/div[2]/form/table[6]/tbody/tr[#{remove_id+2}]/td[6]/a").click unless remove_id.nil?
                self.please_wait
            else
                mac_counter = 2
                while @ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[6]/tbody/tr[#{mac_counter}]/td[4]/a").exists?
                    @log.info("Wireless MAC Authentication::Removing MAC ID #{@ff.element_by_xpath("/html/body/div/div[3]/div[2]/form/table[6]/tbody/tr[#{mac_counter}]/td[4]").innerHTML}")
                    @ff.link(:xpath, "/html/body/div/div[3]/div[2]/form/table[6]/tbody/tr[#{mac_counter}]/td[6]/a").click
                    mac_counter += 1
                    self.please_wait
                end
            end
        end
    end

    def wireless_mode
        return unless self.menu(:wireless_setup, :wireless_mode)
        @log.info("802.11b/g/n Mode::This section currently has no logging. Please be advised.")
        list_select("id_80211bg_mode", @user_choices[:wireless_mode_options][0]) unless @user_choices[:wireless_mode_options][0].empty? if @user_choices[:wireless_mode_options][0]
        list_select("id_spatial_streams", @user_choices[:wireless_mode_options][1]) unless @user_choices[:wireless_mode_options][1].empty? if @user_choices[:wireless_mode_options][1]
        list_select("id_channel_width", @user_choices[:wireless_mode_options][2]) unless @user_choices[:wireless_mode_options][2].empty? if @user_choices[:wireless_mode_options][2]
        list_select("id_control_channel", @user_choices[:wireless_mode_options][3]) unless @user_choices[:wireless_mode_options][3].empty? if @user_choices[:wireless_mode_options][3]
        list_select("id_msdu_agg", @user_choices[:wireless_mode_options][4]) unless @user_choices[:wireless_mode_options][4].empty? if @user_choices[:wireless_mode_options][4]
        list_select("id_mpdu_agg", @user_choices[:wireless_mode_options][5]) unless @user_choices[:wireless_mode_options][5].empty? if @user_choices[:wireless_mode_options][5]
        list_select("id_power_save", @user_choices[:wireless_mode_options][6]) unless @user_choices[:wireless_mode_options][6].empty? if @user_choices[:wireless_mode_options][6]
        self.apply_settings("802.11b/g/n Mode")
    end

    def channel
        return unless self.menu(:wireless_setup, :channel)
        @log.info("Wireless Channel::This section currently has no logging. Please be advised.")
        list_select("id_channel", @user_choices[:wireless_channel_options][0]) unless @user_choices[:wireless_channel_options][0].empty? if @user_choices[:wireless_channel_options][0]
        list_select("id_power_level", @user_choices[:wireless_channel_options][1]) unless @user_choices[:wireless_channel_options][1].empty? if @user_choices[:wireless_channel_options][1]
        self.apply_settings("Wireless Channel")
    end
end