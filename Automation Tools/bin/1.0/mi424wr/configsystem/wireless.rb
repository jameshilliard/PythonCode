# Wireless is taken care of by the Veriwave system, at least for now. We would be better off including it in this
# set of Ruby scripts to bring it all under one platform. That would make our lives easier in the future. 

module Wireless
	
	def wireless_jumper(rule_name, info)
		case info['section']
		when /basic/i
			self.wireless_basic(rule_name, info)
		when /advanced/i
			self.wireless_advanced(rule_name, info)
		when /status/i
			if info.has_key?("items")
				self.wireless_status(rule_name, info['items'])
			else
				self.wireless_status(rule_name, 'all')
			end
        when /wps/i
            self.wireless_wps(rule_name, info)
        when /wmm/i
            self.wireless_wmm(rule_name, info)
		end
	end
	
	# Status page. Used to get information from the device.
	def wireless_status(rule_name, items)
		if self.wirelesspage(rule_name, 'status') == false
			return
		end

		found = false
		@ff.tables.each do |t|
			if t.text.include?('Radio Enabled')
				found = t
			end
		end
		if found != false
			if items.match(/all/i)
				for i in 1..12
					self.msg(rule_name, :info, "Wireless Status - #{found[i][1].text}", "#{found[i][2].text}\n")
				end
			else
				values = ""
				(items.split(',')).each do |item|
					item.downcase!
					item.strip!
					for i in 1..12
						if found[i][1].text.downcase.match(Regexp.new(item))
							values << "#{found[i][1].text}  #{found[i][2].text}\n"
						end
					end
				end
				self.msg(rule_name, :info, "Wireless Status", values)
			end
		else
			self.msg(rule_name, :error, 'info', "Unable to find any valid Wireless statistics")
		end
	end
	
	# Basic Security Settings
	# Configuration format: 
	# "set" : "on -ssid ssidname here -channel 9 +keep -wep keyhere +hex/ascii"
	def wireless_basic(rule_name, info)
		return if self.wirelesspage(rule_name, 'basic') == false
		if info.has_key?('set')
			# Turn wireless on or off
			if info['set'].match(/-off/i)
				@ff.radio(:id, 'ws_off').set
                self.msg(rule_name, :info, "Wireless", "Turning wireless off")
			else
				@ff.radio(:id, 'ws_on').set
                self.msg(rule_name, :info, "Wireless", "Turning wireless on")
			end
			# Set SSID
			if info['set'].match(/-ssid/i)
				ssid = info['set'].slice(/-ssid\s(.+?)(\s|\z)/).strip.split(" ")[1]
				@ff.text_field(:id, 'ssid').set(ssid)
                self.msg(rule_name, :info, "Wireless", "SSID set to #{ssid}")
			end
			# Set channel
			if info['set'].match(/-channel/i)
				chan = info['set'].slice(/-channel\s(.+?)(\s|\z)/).strip.split(" ")[1]
				if chan.match(/auto/i)
					@ff.select_list(:id, 'ws_channel').select('Automatic')
                    self.msg(rule_name, :info, "Wireless", "Changed channel to Automatic")
				else
					@ff.select_list(:id, 'ws_channel').select(chan)
                    self.msg(rule_name, :info, "Wireless", "Changed channel to #{chan}")
				end
            end
            if info['set'].match(/-keep/i)
                @ff.checkbox(:id, 'keep_channel_').set if info['set'].match(/\-keep\s(on|yes|enable)/i)
                @ff.checkbox(:id, 'keep_channel_').clear if info['set'].match(/\-keep\s(off|no|disable)/i)
                @ff.checkbox(:id, 'keep_channel_').checked? ? self.msg(rule_name, :info, "Wireless", "Keeping channel on reset") : self.msg(rule_name, :info, "Wireless", "Not keeping channel on reset")
			end

            if info['set'].match(/ascii/i)
                @ff.select_list(:id, 'wep_key_code').select('ASCII')
                self.msg(rule_name, :info, "Wireless", "Setting key to ASCII")
            elsif info['set'].match(/hex/i)
                @ff.select_list(:id, 'wep_key_code').select('Hex')
                self.msg(rule_name, :info, "Wireless", "Setting key to HEX")
            end if info['set'].match(/hex|ascii/i)

			# Set WEP on or off and WEP key values
			if info['set'].match(/-wep/i)
				wep = info['set'].slice(/-wep\s(.+?)(\s|\z)/).strip.split(" ")[1]
				if wep.upcase == "OFF" 
					@ff.radio(:id, 'wep_off').set
                    self.msg(rule_name, :info, "Wireless", "Turning WEP off")
				else
					@ff.radio(:id, 'wep_on').set
                    self.msg(rule_name, :info, "Wireless", "Turning WEP on")
					# And set WEP key if it's valid for either modes/lengths
					if wep.length == 5
                        @ff.select_list(:id, 'wep_key_len').select('64/40 bit')
                        @ff.text_field(:id, 'wep_key_ascii64').set(wep)
                        self.msg(rule_name, :info, "Wireless", "WEP Key set to #{wep} - 64 bit ASCII - 5 characters")
                    elsif wep.length == 13
                        @ff.select_list(:id, 'wep_key_len').select('128/104 bit')
                        @ff.text_field(:id, 'wep_key_ascii128').set(wep)
                        self.msg(rule_name, :info, "Wireless", "WEP Key set to #{wep} - 128 bit ASCII - 13 characters")
                    else
                        self.msg(rule_name, :error, 'Wireless Basic Settings', "WEP Key value #{wep} is not 5 or 13 characters long for ASCII mode")
                        return
                    end if @ff.select_list(:id, 'wep_key_code').value == "1"

					if wep.match(/[a-f0-9]{10}/i)
                        @ff.select_list(:id, 'wep_key_len').select('64/40 bit')
                        @ff.text_field(:id, 'wep_key_hex64').set(wep)
                        self.msg(rule_name, :info, "Wireless", "WEP Key set to #{wep} - 64 bit HEX - 10 digits")
                    elsif wep.match(/[a-f0-9]{26}/i)
                        @ff.select_list(:id, 'wep_key_len').select('128/104 bit')
                        @ff.text_field(:id, 'wep_key_hex128').set(wep)
                        self.msg(rule_name, :info, "Wireless", "WEP Key set to #{wep} - 128 bit HEX - 26 digits")
                    else
                        self.msg(rule_name, :error, 'Wireless Basic Settings', "WEP Key value #{wep} is not a valid WEP key for Hex mode")
                        return
                    end if @ff.select_list(:id, 'wep_key_code').value == "0"
				end
			end
		else
			self.msg(rule_name, :error, 'Wireless Basic Settings', 'No \"set\" key found for basic settings. Use status page for getting info.')
			return
		end
        self.apply_settings(rule_name, "Wireless")
	end
	
	# Advanced Security Settings
	# Configuration format: 
	# 	"security" : "wpa2"
	# 	"authtype" : "open"
	# 	"key 1" : "keyhere +hex/ascii"
	# 	"key 2" : "keyhere +hex/ascii"
	# 	"key 3" : "active keyhere +hex/ascii"
	# 	"key 4" : "keyhere +hex/ascii"
	# 	"psk" : "keyhere +hex/ascii +both +interval 900"
	# 	"802.1x" : "-server 192.168.1.15 -port 1812 -secret secrethere"
	# 	"options" : "+broadcast -schedule -network -mtu auto/dhcp/# -tx auto/# -power # -ctsmode none -ctstype cts-only -fbmax # -fbtime # -beacon # -dtim # -frag # -rts 
	# 	"access list" : "off/deny/accept mac:id mac:id mac:id mac:id"
	def wireless_advanced(rule_name, info)
		return if self.wirelesspage(rule_name, 'advanced') == false
		if info.has_key?('security')
			case info['security']
			# Set to WEP only
			when /wep\z/i
				@ff.radio(:id, 'wep0').click
				if info['authtype'].match(/open/i)
                    @ff.select_list(:id, "wl_auth").select_value("0")
                    self.msg(rule_name, :info, "Wireless", "Set WEP authentication type to open")
                elsif info['authtype'].match(/share/i)
                    @ff.select_list(:id, "wl_auth").select_value("1")
                    self.msg(rule_name, :info, "Wireless", "Set WEP authentication type to shared")
                elsif info['authtype'].match(/both/i)
                    @ff.select_list(:id, "wl_auth").select_value("2")
                    self.msg(rule_name, :info, "Wireless", "Set WEP authentication type to both")
                end if info.has_key?("authtype")
				keycount = 0
				done = FALSE
				while not done
					keyset = "key #{keycount+1}"
					if info.has_key?(keyset)
						if info[keyset].match(/\Aactive/i)
							@ff.radio(:id, "wep_active_#{keycount}").set
							info[keyset].sub!(/\Aactive/i, '')
							info[keyset].strip!
                            self.msg(rule_name, :info, "Wireless", "Activating WEP #{keyset}")
						end
						wep = info[keyset].split('+')
						wep[0].strip!
						if wep[1].match(/ascii/i)
                            @ff.select_list(:id, "wep_key_method_#{keycount}").select('ASCII')
                            self.msg(rule_name, :info, "Wireless", "Setting #{keyset} to ASCII")
                        elsif wep[1].match(/hex/i)
                            @ff.select_list(:id, "wep_key_method_#{keycount}").select('Hex')
                            self.msg(rule_name, :info, "Wireless", "Setting #{keyset} to HEX")
                        end if wep.length > 1
						# Get current hex/ascii selection
						currentCode = "Hex" if @ff.select_list(:id, "wep_key_method_#{keycount}").value == "0"
						currentCode = "ASCII" if @ff.select_list(:id, "wep_key_method_#{keycount}").value == "1"
						# And set WEP key if it's valid for either modes/lengths
						if currentCode == 'ASCII'
							if wep[0].length == 5
								@ff.select_list(:id, "wep_key_length_#{keycount}").select('64/40 bit')
								@ff.text_field(:id, "wep_key_#{keycount}").set(wep[0])
                                self.msg(rule_name, :info, "Wireless", "Setting #{keyset} to #{wep[0]} - 64 bit ASCII - 5 characters")
							elsif wep[0].length == 13
								@ff.select_list(:id, "wep_key_length_#{keycount}").select('128/104 bit')
								@ff.text_field(:id, "wep_key_#{keycount}").set(wep[0])
                                self.msg(rule_name, :info, "Wireless", "Setting #{keyset} to #{wep[0]} - 128 bit ASCII - 13 characters")
							else
								self.msg(rule_name, :error, 'Wireless Basic Settings', "WEP Key value #{wep[0]} is not 5 or 13 characters long for ASCII mode")
								return
							end
						elsif currentCode == 'Hex'
							if wep[0].match(/[a-f0-9]{10}/i)
								@ff.select_list(:id, "wep_key_length_#{keycount}").select('64/40 bit')
								@ff.text_field(:id, "wep_key_#{keycount}").set(wep[0])
                                self.msg(rule_name, :info, "Wireless", "Setting #{keyset} to #{wep[0]} - 64 bit HEX - 10 digits")
							elsif wep[0].match(/[a-f0-9]{26}/i)
								@ff.select_list(:id, "wep_key_length_#{keycount}").select('128/104 bit')
								@ff.text_field(:id, "wep_key_#{keycount}").set(wep[0])
                                self.msg(rule_name, :info, "Wireless", "Setting #{keyset} to #{wep[0]} - 128 bit HEX - 26 digits")
							else
								self.msg(rule_name, :error, 'Wireless Basic Settings', "WEP Key value #{wep[0]} is not a valid WEP key for Hex mode")
								return
							end
						end
						keycount += 1
					else
						done = TRUE
						# Apply since we are done
						self.apply_settings(rule_name, "Wireless")
					end
				end
			when /wpa\z/i
				@ff.radio(:id, 'wpa').click
				# "psk" : "keyhere -hex/ascii -both -interval 900",
				if info.has_key?('psk')
					@ff.select_list(:id, 'wpa_sta_auth_type').select_value('1')
					key = info['psk'].split('-')
					for i in 1..key.length
						# find out what we are dealing with
						case key[i-1]
						when /hex|ascii/i
                            if key[i-1].match(/hex/i)
                                @ff.select_list(:id, 'psk_representation').select_value('0')
                                self.msg(rule_name, :info, "Wireless", "PSK type set to HEX")
                            elsif key[i-1].match(/ascii/i)
                                @ff.select_list(:id, 'psk_representation').select_value('1')
                                self.msg(rule_name, :info, "Wireless", "PSK type set to ASCII")
                            end
						when /both|aes|tkip/i
                            if key[i-1].match(/tkip/i)
                                @ff.select_list(:id, 'wpa_cipher').select_value('1')
                                self.msg(rule_name, :info, "Wireless", "Setting encryption to TKIP")
                            elsif key[i-1].match(/aes/i)
                                @ff.select_list(:id, 'wpa_cipher').select_value('2')
                                self.msg(rule_name, :info, "Wireless", "Setting encryption to AES")
                            elsif key[i-1].match(/both/i)
                                @ff.select_list(:id, 'wpa_cipher').select_value('3')
                                self.msg(rule_name, :info, "Wireless", "Setting encryption to TKIP and AES")
                            end
						when /interval/i
							if key[i-1].match(/off/i)
								@ff.checkbox(:id, 'is_grp_key_update_').clear
                                self.msg(rule_name, :info, "Wireless", "Group key interval turned off")
							else
								@ff.checkbox(:id, 'is_grp_key_update_').set
								seconds= key[i-1].delete('[a-zA-Z]').strip
								@ff.text_field(:name, '8021x_rekeying_interval').set(seconds)
                                self.msg(rule_name, :info, "Wireless", "Group key interval turned on and set to #{seconds} seconds")
							end
						# If they aren't the above then it must be the key
						else 
							if @ff.select_list(:id, 'psk_representation').value == "0"
								key[i-1].strip!
								if key[i-1].length > 63
									if key[i-1].match(/[a-f0-9]*/i)
										@ff.text_field(:name, 'wpa_sta_auth_shared_key').set(key[i-1])
                                        self.msg(rule_name, :info, "Wireless", "Setting PSK to #{key[i-1]}")
									else
										self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid Hex value.")
										return
									end
								else
									self.msg(rule_name, :error, "Wireless Advanced Settings", "WPA Hex keys need to be at least 64 hex characters.")
									return
								end
							else
								if key[i-1].strip.length > 7
									@ff.text_field(:name, 'wpa_sta_auth_shared_key').set(key[i-1].strip)
                                    self.msg(rule_name, :info, "Wireless", "Setting PSK to #{key[i-1].strip}")
								else
									self.msg(rule_name, :error, "Wireless Advanced Settings", "WPA PSK Strings need to be at least 8 characters long.")
									return
								end
							end
						end
					end
					self.apply_settings(rule_name, "Wireless")
				elsif info.has_key?('802.1x')
					# "802.1x" : "-aes -interval 900 -server 192.168.1.15 -port 1812 -secret secrethere",
					@ff.select_list(:id, 'wpa_sta_auth_type').select_value('2')
					key = info['802.1x'].split('-')
					for i in 1..key.length
						# find out what we are dealing with
						case key[i-1]
						when /both|aes|tkip/i
							@ff.select_list(:id, 'wpa_cipher').select_value('1') if key[i-1].match(/tkip/i)
							@ff.select_list(:id, 'wpa_cipher').select_value('2') if key[i-1].match(/aes/i)
							@ff.select_list(:id, 'wpa_cipher').select_value('3') if key[i-1].match(/both/i)
						when /interval/i
							if key[i-1].match(/off/i)
								@ff.checkbox(:id, 'is_grp_key_update_').clear
							else
								@ff.checkbox(:id, 'is_grp_key_update_').set
								seconds= key[i-1].delete('[a-zA-Z]').strip
								@ff.text_field(:name, '8021x_rekeying_interval').set(seconds)
							end
						when /server/i
							key[i-1].delete!('[a-zA-Z]').strip!
							# check if it's a real ip
							if (key[i-1] =~/\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/) != nil
								serverip = key[i-1].split('.')
								for count in 0..3
									@ff.text_field(:name, "radius_client_server_ip#{count}").set(serverip[count])
								end
							else
								self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid IP Address for Server IP field")
								return
							end
						when /port/i
							key[i-1].delete!('[a-zA-Z]').strip!
							# check if it's a real port number
							if (key[i-1] =~ /\A(?:6[0-5][0-5][0-3][0-5]|\d{1,4})\z/) != nil
								@ff.text_field(:name, 'radius_client_server_port').set(key[i-1])
							else
								self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid port for Server Port field")
								return
							end
						when /secret/i
							secret = key[i-1].split(' ')
							secret[1].strip!
							@ff.text_field(:name, /radius_client_secret/).set(secret[1])
						end
					end
					self.apply_settings(rule_name, "Wireless")
				end
			when /wpa2/i
				@ff.radio(:id, 'wpa2').click
				# "psk" : "keyhere -hex/ascii -both -interval 900",
				if info.has_key?('psk')
					@ff.select_list(:id, 'wpa_sta_auth_type').select_value('1')
					key = info['psk'].split('-')
					for i in 1..key.length
						# find out what we are dealing with
						case key[i-1]
						when /hex|ascii/i
                            if key[i-1].match(/hex/i)
                                @ff.select_list(:id, 'psk_representation').select_value('0')
                                self.msg(rule_name, :info, "Wireless", "PSK type set to HEX")
                            elsif key[i-1].match(/ascii/i)
                                @ff.select_list(:id, 'psk_representation').select_value('1')
                                self.msg(rule_name, :info, "Wireless", "PSK type set to ASCII")
                            end
						when /both|aes|tkip/i
                            if key[i-1].match(/aes/i)
                                @ff.select_list(:id, 'wpa_cipher').select_value('2')
                                self.msg(rule_name, :info, "Wireless", "Setting encryption to AES")
                            elsif key[i-1].match(/both|tkip/i)
                                @ff.select_list(:id, 'wpa_cipher').select_value('3')
                                self.msg(rule_name, :info, "Wireless", "Setting encryption to TKIP and AES")
                            end
						when /interval/i
							if key[i-1].match(/off/i)
								@ff.checkbox(:id, 'is_grp_key_update_').clear
                                self.msg(rule_name, :info, "Wireless", "Group key interval turned off")
							else
								@ff.checkbox(:id, 'is_grp_key_update_').set
								seconds= key[i-1].delete('[a-zA-Z]').strip
								@ff.text_field(:name, '8021x_rekeying_interval').set(seconds)
                                self.msg(rule_name, :info, "Wireless", "Group key interval turned on and set to #{seconds} seconds")
							end
						# If they aren't the above then it must be the key
						else
							if @ff.select_list(:id, 'psk_representation').value == "0"
								key[i-1].strip!
								if key[i-1].length > 63
									if key[i-1].match(/[a-f0-9]*/i)
										@ff.text_field(:name, 'wpa_sta_auth_shared_key').set(key[i-1])
                                        self.msg(rule_name, :info, "Wireless", "Setting PSK to #{key[i-1]}")
									else
										self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid Hex value.")
										return
									end
								else
									self.msg(rule_name, :error, "Wireless Advanced Settings", "WPA Hex keys need to be at least 64 hex characters.")
									return
								end
							else
								if key[i-1].strip.length > 7
									@ff.text_field(:name, 'wpa_sta_auth_shared_key').set(key[i-1].strip)
                                    self.msg(rule_name, :info, "Wireless", "Setting PSK to #{key[i-1].strip}")
								else
									self.msg(rule_name, :error, "Wireless Advanced Settings", "WPA PSK Strings need to be at least 8 characters long.")
									return
								end
							end
						end
					end
					self.apply_settings(rule_name, "Wireless")
				elsif info.has_key?('802.1x')
					# "802.1x" : "-aes -interval 900 -server 192.168.1.15 -port 1812 -secret secrethere",
					@ff.select_list(:id, 'wpa_sta_auth_type').select_value('2')
					key = info['802.1x'].split('-')
					for i in 1..key.length
						# find out what we are dealing with
						case key[i-1]
						when /both|aes|tkip/i
							@ff.select_list(:id, 'wpa_cipher').select_value('0') if key[i-1].match(/tkip/i)
							@ff.select_list(:id, 'wpa_cipher').select_value('1') if key[i-1].match(/aes/i)
							@ff.select_list(:id, 'wpa_cipher').select_value('2') if key[i-1].match(/both/i)
						when /interval/i
							if key[i-1].match(/off/i)
								@ff.checkbox(:id, 'is_grp_key_update_').clear
							else
								@ff.checkbox(:id, 'is_grp_key_update_').set
								seconds= key[i-1].delete('[a-zA-Z]').strip
								@ff.text_field(:name, '8021x_rekeying_interval').set(seconds)
							end
						when /server/i
							key[i-1].delete!('[a-zA-Z]').strip!
							# check if it's a real ip
							if (key[i-1] =~/\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/) != nil
								serverip = key[i-1].split('.')
								for count in 0..3
									@ff.text_field(:name, "radius_client_server_ip#{count}").set(serverip[count])
								end
							else
								self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid IP Address for Server IP field")
								return
							end
						when /port/i
							key[i-1].delete!('[a-zA-Z]').strip!
							# check if it's a real port number
							if (key[i-1] =~ /\A(?:6[0-5][0-5][0-3][0-5]|\d{1,4})\z/) != nil
								@ff.text_field(:name, 'radius_client_server_port').set(key[i-1])
							else
								self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid port for Server Port field")
								return
							end
						when /secret/i
							secret = key[i-1].split(' ')
							secret[1].strip!
							@ff.text_field(:name, /radius_client_secret/).set(secret[1])
						end
					end
					@ff.link(:text, 'Apply').click
					# Needed due to the "please wait" page... they break the script. 
					sleep 7
					@ff.refresh
				end
			when /wep.*02.1x/i
				@ff.radio(:id, 'wep1').click
				if info.has_key?('802.1x')
					# "802.1x" : "-server 192.168.1.15 -port 1812 -secret secrethere",
					key = info['802.1x'].split('-')
					for i in 1..key.length
						# find out what we are dealing with
						case key[i-1]
						when /server/i
							key[i-1].delete!('[a-zA-Z]').strip!
							# check if it's a real ip
							if (key[i-1] =~/\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/) != nil
								serverip = key[i-1].split('.')
								for count in 0..3
									@ff.text_field(:name, "radius_client_server_ip#{count}").set(serverip[count])
								end
							else
								self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid IP Address for Server IP field")
								return
							end
						when /port/i
							key[i-1].delete!('[a-zA-Z]').strip!
							# check if it's a real port number
							if (key[i-1] =~ /\A(?:6[0-5][0-5][0-3][0-5]|\d{1,4})\z/) != nil
								@ff.text_field(:name, 'radius_client_server_port').set(key[i-1])
							else
								self.msg(rule_name, :error, "Wireless Advanced Settings", "#{key[i-1]} is not a valid port for Server Port field")
								return
							end
						when /secret/i
							secret = key[i-1].split(' ')
							secret[1].strip!
							@ff.text_field(:name, /radius_client_secret/).set(secret[1])
						end
					end
					self.apply_settings(rule_name, "Wireless")
				end
			end
		end
		# Misc options: "options" : "-broadcast off -schedule name -network -mtu dhcp -tx auto -power 50 -ctsmode none -ctstype cts-only -fbmax 4 -fbtime 1 -beacon 150 -dtim 4 -frag 2346 -rts 2346", 
		if info.has_key?('options')
			# SSID Broadcast
			if info['options'].match(/-broadcast/i)
				@ff.link(:href, "javascript:mimic_button('wireless_ssid_option: ...', 1)").click
				@ff.radio(:id, 'ssid_enable_type_1').click if info['options'].match(/broadcast on/i)
				@ff.radio(:id, 'ssid_enable_type_0').click if info['options'].match(/broadcast off/i)
				@ff.link(:text, "Apply").click
				sleep 7
				@ff.refresh
			end
			# 802.11b/g/n mode
			if info['options'].match(/-mode/i)
				@ff.link(:href, "javascript:mimic_button('wireless_80211_option: ...', 1)").click
				@ff.select_list(:id, 'wl_dot11_mode').select_value("1") if info['options'].match(/-mode comp/i)
				@ff.select_list(:id, 'wl_dot11_mode').select_value("3") if info['options'].match(/-mode leg/i)
				@ff.select_list(:id, 'wl_dot11_mode').select_value("2") if info['options'].match(/-mode perf/i)
				@ff.link(:text, "Apply").click
				sleep 7
				@ff.refresh
			end
			# Every other option
			@ff.link(:href, "javascript:mimic_button('wireless_advanced_option: ...', 1)").click
			@ff.link(:text, "Yes").click
			options = info['options'].split('-')
			options.each do |option|
				case option
				when /schedule/i
					selection = ""
					(@ff.select_list(:id, "schdlr_rule_id").getAllContents).each do |validate|
						if validate.match(Regexp.new(option.sub(/\Aschedule/, '').strip, /i/)) != nil
							selection = validate
						end
					end
					if selection == ""
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "Unable to find #{option}")
						return
					else
						@ff.select_list(:id, "schdlr_rule_id").select(selection)
					end
				when /network/i
					selection = ""
					(@ff.select_list(:id, "network").getAllContents).each do |validate|
						if validate.match(Regexp.new(option.sub(/\Anetwork/, '').strip, /i/)) != nil
							selection = validate
						end
					end
					if selection == ""
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "Unable to find #{option}")
						return
					else
						@ff.select_list(:id, "network").select(selection)
					end
				when /mtu/i
					@ff.select_list(:id, "mtu_mode").select_value("1") if option.match(/auto/i)
					@ff.select_list(:id, "mtu_mode").select_value("2") if option.match(/dhcp/i)
					if option.match(/\d/)
						option.gsub!(/\D/,'')
						if option.to_i > 67 and option.to_i < 1501
							@ff.select_list(:id, "mtu_mode").select_value("0")
							@ff.text_field(:name, "mtu").set(option)
						else
							self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "MTU Value must be between 68 and 1500")
							return
						end
					end
				when /tx/i
					selection = ""
					(@ff.select_list(:id, "transmission_rate").getAllContents).each do |validate|
						if validate.match(Regexp.new(option.sub(/\Atx/, '').strip, /i/)) != nil
							selection = validate
						end
					end
					if selection == ""
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "Unable to find #{option}")
						return
					else
						@ff.select_list(:id, "transmission_rate").select(selection)
					end
				when /power/i
					option.gsub!(/\D/,'')
					if option == "" || option.to_i < 1 || option.to_i > 100
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "-power option specified, but no valid percentage given.")
						return
					else
						@ff.text_field(:name, "tx_power").set(option)
					end
				when /ctsmode/i
					selection = ""
					(@ff.select_list(:id, "cts_protection_mode").getAllContents).each do |validate|
						if validate.match(Regexp.new(option.sub(/\Actsmode/, '').strip, /i/)) != nil
							selection = validate
						end
					end
					if selection == ""
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "Unable to find #{option}")
						return
					else
						@ff.select_list(:id, "cts_protection_mode").select(selection)
					end
				when /ctstype/i
					selection = ""
					(@ff.select_list(:id, "cts_protection_type").getAllContents).each do |validate|
						if validate.match(Regexp.new(option.sub(/\Actstype/, '').strip, /i/)) != nil
							selection = validate
						end
					end
					if selection == ""
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "Unable to find #{option}")
						return
					else
						@ff.select_list(:id, "cts_protection_type").select(selection)
					end
				when /fbmax/i
					option.gsub!(/\D/,'')
					if option == "" || option.to_i < 2 || option.to_i > 255
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "-fbmax option specified, but no valid value given (2-255).")
						return
					else
						@ff.text_field(:name, "frame_burst_max_number").set(option)
					end
				when /fbtime/i
					option.gsub!(/\D/,'')
					if option == "" || option.to_i < 0 || option.to_i > 1023
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "-fbtime option specified, but no valid value given (0-1023).")
						return
					else
						@ff.text_field(:name, "frame_burst_burst_time").set(option)
					end
				when /beacon/i
					option.gsub!(/\D/,'')
					if option == "" || option.to_i < 20 || option.to_i > 1000
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "-beacon option specified, but no valid value given (20-1000).")
						return
					else
						@ff.text_field(:name, "bcn_interval").set(option)
					end
				when /dtim/i
					option.gsub!(/\D/,'')
					if option == "" || option.to_i < 1 || option.to_i > 255
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "-beacon option specified, but no valid value given (1-255).")
						return
					else
						@ff.text_field(:name, "dtim_interval").set(option)
					end
				when /frag/i
					option.gsub!(/\D/,'')
					if option == "" || option.to_i < 256 || option.to_i > 2346
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "-beacon option specified, but no valid value given (256-2346).")
						return
					else
						@ff.text_field(:name, "fragmentation_threshold").set(option)
					end
				when /rts/i
					option.gsub!(/\D/,'')
					if option == "" || option.to_i < 0 || option.to_i > 2347
						self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "-beacon option specified, but no valid value given (0-2347).")
						return
					else
						@ff.text_field(:name, "rts_threshold").set(option)
					end
                when /msdu/i
                    @ff.radio(:id, "msdu_on").click if option.match(/on|enable|yes/i)
                    @ff.radio(:id, "msdu_off").click if option.match(/off|disable|no/i)
                when /mpdu/i
                    @ff.radio(:id, "mpdu_on").click if option.match(/on|enable|yes/i)
                    @ff.radio(:id, "mpdu_off").click if option.match(/off|disable|no/i)
				end
			end
			@ff.link(:text, "Apply").click
			sleep 7
			@ff.refresh
		end
		
		# Wireless MAC authentication
		if info.has_key?('access_list')
			@ff.link(:href, "javascript:mimic_button('wireless_mac_option: ...', 1)").click
			if info['access_list'].match(/off/i)
				@ff.checkbox(:id, "mac0").clear
				@ff.link(:text, "Apply").click
				sleep 7
				@ff.refresh
			elsif info['access_list'].match(/remove/i)
				list = info['access_list'].split(' ')
				list.each do |setValue|
					setValue.strip!
					if setValue =~ /\A([0-9a-fA-F][0-9a-fA-F]){6}\z/
						until counter == 6
							setValue.insert(placer,':')
							counter += 1
							placer += 3
						end
					end
					if setValue =~ /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F]{2}\z/
						selection = ""
						(@ff.select_list(:id, "mac7").getAllContents).each do |validate|
							if validate.match(Regexp.new(setValue, /i/)) != nil
								selection = validate
							end
						end
						if selection == ""
							self.msg(rule_name, :error, "Advanced Wireless Setup - Options", "Unable to find #{setValue} in MAC List.")
							return
						else
							@ff.select_list(:id, "mac7").select(selection)
							@ff.button(:id, "mac8").click
						end
					end
				end
			else
				counter = 1
				placer = 2
				@ff.checkbox(:id, "mac0").set if info['access_list'].match(/accept/i) or info['access_list'].match(/deny/i)
				@ff.radio(:id, "mac1").click if info['access_list'].match(/accept/i)
				@ff.radio(:id, "mac3").click if info['access_list'].match(/deny/i)
				list = info['access_list'].split(' ')
				list.each do |setValue|
					setValue.strip!
					if setValue =~ /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F]{2}\z/
						@ff.text_field(:id, "mac5").set(setValue)
						@ff.button(:id, "mac6").click
					elsif setValue =~ /\A([0-9a-fA-F][0-9a-fA-F]){6}\z/
						until counter == 6
							setValue.insert(placer,':')
							counter += 1
							placer += 3
						end
						@ff.text_field(:id, "mac5").set(setValue)
						@ff.button(:id, "mac6").click
					end
				end
			end
			@ff.link(:text, "Apply").click
			sleep 7
			@ff.refresh
		end
	end

    # WPS for RevF, quick and simple, but complete
    # "rule_name": {
    #     "section": "wireless-wps",
    #     "set": "-enable -pin # -connect"  or  "set": "-disable"   or "set": "-connect"  or "set": "-enable -push_button -connect"
    # }
    def wireless_wps(rule_name, info)
        return if self.wirelesspage(rule_name, 'advanced') == false
        @ff.link(:text, "Other Advanced Wireless Options").click
        @ff.link(:text, "Yes").click
        @ff.link(:text, "WPS Settings").click
        if info['set'].match(/enable|on|yes/i)
            if @ff.checkbox(:id, "wps_enabled_").checked?
                self.msg(rule_name, :info, "WPS", "WPS already enabled")
            else
                self.msg(rule_name, :info, "WPS", "Enabling WPS")
                @ff.checkbox(:id, "wps_enabled_").set
                self.apply_settings(rule_name, "WPS")
                self.msg(rule_name, :info, "WPS", "WPS is now enabled - waiting for initialization.")
                while @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[2]/td[2]/font")[0].text.match(/intiating/i)
                    sleep(5)
                    @ff.refresh
                end
            end
        else
            if @ff.checkbox(:id, "wps_enabled_").checked?
                self.msg(rule_name, :info, "WPS", "Disabling WPS")
                @ff.checkbox(:id, "wps_enabled_").clear
                self.apply_settings(rule_name, "WPS")
                self.msg(rule_name, :info, "WPS", "WPS is now disabled")
            else
                self.msg(rule_name, :info, "WPS", "WPS is already disabled")
                return
            end
        end

        if info['set'].match(/pin|push_button/i)
            wps_method = "Pin Code" if info['set'].match(/pin/i)
            wps_method = "Push Button" if info['set'].match(/push_button/i)
            if @ff.select_list(:id, "wps_method").text == wps_method
                self.msg(rule_name, :info, "WPS", "#{wps_method} already selected.")
            else
                return unless validate("wps_method", wps_method)
                # Apply settings if it's push button...
                self.apply_settings(rule_name, "WPS") if wps_method == "Push Button"
                # ... or apply settings if it's a pin code and we are not setting a pin further down
                self.apply_settings(rule_name, "WPS") unless info['set'].match(/pin \d+/i) if wps_method == "Pin Code"
                self.msg(rule_name, :info, "WPS", "Protected Setup Method now set to #{wps_method}")
            end
        end

        if info['set'].match(/pin \d+/i)
            pin = info['set'].slice(/pin \d+/i).delete('^[0-9]')
            unless pin.length == 8
                self.msg(rule_name, :error, "WPS", "WPS Pin must be 8 digits long")
                return
            end
            @ff.text_field(:name, "pin_code").set(pin)
            self.apply_settings(rule_name, "WPS")
            self.msg(rule_name, :info, "WPS", "WPS Pin Code now set to #{pin}")
        end
        
        if info['set'].match(/connect/i)
            @ff.link(:text, "Connect").click
            while @ff.contains_text("Waiting for enrollee registration")
                sleep(10)
                @ff.refresh
            end
            self.msg(rule_name, :info, "WPS", "Status is now #{@ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[2]/td[2]/font")[0].text}")
        end
    end

    # "rulename": {
    #   "section": "wireless-wmm-enabled|disabled",
    #   "add": "-dscp # -access #|phrase",
    #   "move": "value id|up|down*#",
    #   "powersave": "on|off",
    #   "priority": "#|voice|video|besteffort -acm no|yes -quota #",
    #   "remove": "id#|value_string"
    # }
    def wireless_wmm(rule_name, info)        
        move_up = "javascript:mimic_button('arr_up: ?..', 1)"
        move_down = "javascript:mimic_button('arr_down: ?..', 1)"
        id_edit = "javascript:mimic_button('edit: ?..', 1)"
        id_remove = "javascript:mimic_button('remove: ?..', 1)"

        return if self.wirelesspage(rule_name, 'advanced') == false
        @ff.link(:text, "Other Advanced Wireless Options").click
        @ff.link(:text, "Yes").click
        @ff.link(:text, "WMM Settings").click

        # Enable Wireless QoS (WMM)
        # Disabled WMM presents no other options but enabling - set to enabled then apply to get other settings when disabled
        unless @ff.checkbox(:id, "is_wmm_enabled_").checked?
            @ff.checkbox(:id, "is_wmm_enabled_").set
            self.msg(rule_name, :info, "WMM", "Enabling WMM")
            apply_settings(rule_name, "WMM")
            self.msg(rule_name, :info, "WMM", "WMM is now enabled")
        else
            self.msg(rule_name, :info, "WMM", "WMM is already enabled")
        end if info['section'].match(/on|enable|yes/i)

        if @ff.checkbox(:id, "is_wmm_enabled_").checked?
            # Disable/enable power save
            if info['powersave'].match(/on|enable|yes/i)
                # Enable WMM PowerSave
                @ff.checkbox(:id, "power_save_").set
            elsif info['powersave'].match(/off|disable|no/i)
                # Disable WMM PowerSave
                @ff.checkbox(:id, "power_save_").clear
            end if info.has_key?("powersave")

            # Add a new defined qos rule
            if info.has_key?("add")
                @ff.link(:text, "Add").click
                info['add'].split("-").each do |value|
                    # check for hex values
                    if value.match(/dscp/i)
                        value.split(" ")[1].include?("0x") ? dscp_value = "#{value.split(" ")[1].to_i(16)}" : dscp_value = value.split(" ")[1]
                        unless defined? dscp_value
                            self.msg(rule_name, :error, "WMM", "No valid DSCP value in hex or decimal given to add a rule")
                            return
                        end
                        @ff.text_field(:name, "dscp_user").set(dscp_value)
                    elsif value.match(/access/i)
                        unless validate("wmm_combo", value.sub(/access/i, "").strip)
                            self.msg(rule_name, :error, "WMM", "No Access value of #{value.split(" ")[1]}")
                            return
                        end
                    end
                end
                self.msg(rule_name, :info, "WMM", "Added")
                self.apply_settings(rule_name, "WMM")
                if @ff.contains_text("maximum number of rule")
                    @ff.link(:text, "Cancel").click
                    @ff.link(:text, "Back").click
                    self.msg(rule_name, :info, "WMM", "Unable to add more rules. Reached the maximum of 30.")
                end
            end

            # Move items up or down or to a target id
            if info.has_key?("move")
                id_tag = info['move'].split(' ')[0]
                id = nil
                value_temp = info['move'].split(' ')[1]
                to_value = 0
                if id_tag.match(/\A\d+\z/)
                    id = id_tag.to_i
                else
                    (valid_tags = get_id_set).each_index { |v| id = v if valid_tags[v].match(/#{id_tag}/i) }
                end
                to_value = 1 if value_temp.match(/up/i)
                to_value = -1 if value_temp.match(/down/i)
                to_value = value_temp.delete('^[0-9]').to_i if value_temp.match(/up\*/i)
                to_value = "-#{value_temp.delete('^[0-9]')}".to_i if value_temp.match(/down\*/i)
                if value_temp.match(/to/i)
                    to_value = value_temp.delete('^[0-9]').to_i - id if id < value_temp.delete('^[0-9]').to_i
                    to_value = "-#{value_temp.delete('^[0-9]')}".to_i + id if id > value_temp.delete('^[0-9]').to_i
                end
                unless to_value == 0
                    to_value.abs.times do
                        @ff.link(:href, move_down.sub("?", id.to_s)).click if @ff.link(:href, move_down.sub("?", id.to_s)).exists?
                        self.msg(rule_name, :info, "WMM", "Moving #{id_tag} (ID #{id}) down")
                        id += 1 # Each move down increases the ID tag
                    end if to_value < 0
                    to_value.abs.times do
                        @ff.link(:href, move_up.sub("?", id.to_s)).click if @ff.link(:href, move_up.sub("?", id.to_s)).exists?
                        self.msg(rule_name, :info, "WMM", "Moving #{id_tag} (ID #{id}) up")
                        id -= 1 # Each move up reduces the ID tag
                    end if to_value > 0
                end
            end

            # Remove items
            if info.has_key?("remove")
                remove_items = info['remove'].strip.split(" ").inject([]) { |x, d| x << sprintf("%04d", d) }.sort
                while remove_items.length > 0
                    id_tag = "#{remove_items.pop.to_i}"
                    id = nil
                    valid_tags = get_id_set
                    if id_tag.match(/^\d+$/)
                        id = id_tag.to_i
                    else
                        valid_tags.each_index { |v| id = v if valid_tags[v].match(/#{id_tag}/i) }
                    end

                    unless id.nil?
                        @ff.link(:href, id_remove.sub("?", id.to_s)).click
                        self.msg(rule_name, :info, "WMM", "Removed #{id_tag} (ID #{id}, #{valid_tags[id]})")
                        @ff.refresh
                    else
                        self.msg(rule_name, :info, "WMM", "Could not find ID #{id_tag} to remove. Skipping... ")
                    end
                end
            end
            
            #"priority": "#|voice|video|besteffort -acm no|yes -quota #",
            if info.has_key?("priority")
                tag_values = %w(combo_vo combo_vi combo_be)
                quota_values = %w(edit_vo edit_vi edit_be)
                info['priority'].split(';').each do |id_set|
                    puts "Working on #{id_set}"
                    id_tag = id_set.slice!(id_set.split(" ")[0])
                    id = nil
                    settings = id_set.strip.split("-")
                    if id_tag.match(/voice|video|besteffort/i)
                        id = 0 if id_tag.match(/voice/i)
                        id = 1 if id_tag.match(/video/i)
                        id = 2 if id_tag.match(/besteffort/i)
                    else
                        (valid_tags = get_priority_set).each_index { |v| id = v if valid_tags[v].match(/#{id_tag}/i) }
                    end
                    settings.each do |setting|
                        # Set Admission Control Mandatory to yes or no
                        if setting.match(/yes|on|enable/i)
                            @ff.select_list(:id, tag_values[id]).select("Yes")
                        elsif setting.match(/no|off|disable/i)
                            @ff.select_list(:id, tag_values[id]).select("No")
                        end if setting.match(/acm/i)

                        # Set quota
                        if setting.match(/quota/i)
                            quota_value = setting.split(" ")[1].to_i
                            if quota_value < 0 || quota_value > 12; self.msg(rule_name, :error, "WMM", "Quota value must be between 0-12 for Voice"); return; end if id == 0
                            if quota_value < 0 || quota_value > 25; self.msg(rule_name, :error, "WMM", "Quota value must be between 0-25 for Video"); return; end if id == 1
                            if quota_value < 0 || quota_value > 50; self.msg(rule_name, :error, "WMM", "Quota value must be between 0-50 for Best Effort"); return; end if id == 2
                            @ff.text_field(:name, quota_values[id]).set("#{quota_value}")
                            self.msg(rule_name, :info, "WMM", "Changed #{id_tag} (ID #{id}) quota to #{quota_value}")
                        end
                    end unless id.nil?
                end
            end
            self.apply_settings(rule_name, "WMM")
        end
        # Disable WMM
        # Once disabled and settings applied, no other settings matter because you can't do anything with them. Disabling will be last in the list.
        if @ff.checkbox(:id, "is_wmm_enabled_").checked?
            @ff.checkbox(:id, "is_wmm_enabled_").clear
            self.msg(rule_name, :info, "WMM", "Disabling WMM")
            apply_settings(rule_name, "WMM")
            self.msg(rule_name, :info, "WMM", "WMM is now disabled")
        else
            self.msg(rule_name, :info, "WMM", "WMM is already disabled")
        end if info['section'].match(/off|disable|no/i)
    end
end