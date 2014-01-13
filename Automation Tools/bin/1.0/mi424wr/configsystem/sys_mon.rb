# This was already done, but much like the system log, it's still unclear as to why it needs to be
# in existence. I suppose the future may have something specific for it. 

module SysMon
	def system_information(rule_name, info)

		# need the system monitoring page
		self.sysmonpage(rule_name, info)

		out = {'action' => 'get', 'section' => 'info'}
		
		# find the innermost table
		found = false
		@ff.tables.each do |t|
			if t.text.include? 'Firmware Version'
				found = t
			end
		end
		if found != false
			if info =='all'
				out['firmware_version'] = found[1][2].text
				out['model_name'] = found[2][2].text
				out['hardware_version'] = found[3][2].text
				out['serial_number'] = found[4][2].text
				out['phys_conn_type'] = found[5][2].text
				out['bband_conn_type'] = found[6][2].text
				out['bband_conn_status'] = found[7][2].text
				out['bband_ip'] = found[8][2].text
				out['bband_subnet'] = found[9][2].text
				out['bband_mac'] = found[10][2].text
				out['bband_gw'] = found[11][2].text
				out['bband_dns'] = found[12][2].text
				out['uptime'] = found[13][2].text
				@out[rule_name] = out
				@ff.back
			elsif info.match(/current.ip|broadband.ip|broadbandip|currentip|ipaddress|ip.address/i)
				return found[8][2].text
            elsif info.match(/gateway/i)
                return found[11][2].text
			end
		else
			self.msg(rule_name, :error, 'info', 'did not find valid sysmon info')
		end
	end
    
    def get_system_info(rule_name, id=nil)
        # xpath /html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td[2]
        return unless self.sysmonpage(rule_name)
        values = @ff.elements_by_xpath("/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td")
        for i in (0..values.length-1).step(2) do
            @dut_information[values[i].text.delete(":")] = values[i+1].text
        end
    end
end
