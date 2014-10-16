require 'testsystem/nmap-parser'

class PortTest
	def self.scan(info, ipaddress=nil)
        r_header = ""
		results = ""
		specifics = ""
		p_count = 0
		f_count = 0
        thread_count = 0
        threads = []

        r_header << "\n(#) \t Result   \tProtocol \tSource Port:Destination Port\n"
		r_header << "-"*70

		Debug.out("Checking variables passed into test system...")

		# Check which IP we are using
		return "Fatal - IP address to scan - #{ipaddress} - is not valid." unless IPCommon::is_valid(ipaddress)

        # Set Nmap command
        info['sshcli'] ? nmap_command = info['sshcli'] : nmap_command = info['nmap_command']

		# Begin the actual scan and comparing for TCP ports
		if info['tcp_ports'].length > 0
			Debug.out("Checking TCP Ports")
            for tport in info['tcp_ports'].split(',')
                if thread_count == info['max_root_threads']
                    threads.each { |th| th.join }
                    thread_count = 0
                end
                thread_count += 1
                threads << Thread.new(tport) do |currentPort|
                    case info['from']
                    when /port.?forward/i
                        filter = 0
                    when /block/i
                        filter = 1
                    when /allow/i
                        filter = 0
                    when /dmz host/i
                        if info['action'].match(/on/i)
                            filter = 0
                        elsif info['action'].match(/off/i)
                            filter = 1
                        else
                            filter = 0
                        end
                    when /remote.?admin/i
                        filter = 0
                    when /firewall-max|firewall-med|firewall-typ/i
                        filter = 1
                    when /firewall-min/i
                        filter = 0
                    end
                    r_state = ""
                    currentPort.strip!
                    Debug.out("Checking #{currentPort}")

                    nmapTest = "-sS #{ipaddress} -PN"

                    # Check for prot exclude
                    currentPort.match(/!/) ? excludeProtocol = TRUE : excludeProtocol = FALSE
                    currentPort.delete!('!')

                    # Check for source and exclusion
                    sPort = currentPort.split(':')[0]
                    sPort.match(/~/) ? excludeSource = TRUE : excludeSource = FALSE
                    sPort.delete!('~')

                    # Check for destination and exclusion
                    dPort = currentPort.split(':')[1]
                    dPort.match(/~/) ? excludeDestination = TRUE : excludeDestination = FALSE
                    dPort.delete!('~')
                    # Build a small range to scan if it's set to any for destination
                    if dPort.match(/any/i)
                        gap = (rand(10)+1)*10
                        startRange = rand(65535)+1
                        dPort = "#{startRange}-#{startRange+rand(gap)}"
                        Debug.out("Generated destination port of: #{dPort}")
                    end
                    nmapTest << " -p#{dPort}"

                    # Nmap interface bind
                    nmapTest << " -e #{IPCommon::interface_by_ip(info['lanip'])}" unless info['lanip'] == "192.168.1.1"

                    # By now we should know if this should be filtered by way of the called from section, and the excludes
                    if excludeProtocol == TRUE || excludeSource == TRUE || excludeDestination == TRUE
                        filter == 0 ? filter = 1 : filter = 0
                    end
                    # Filter override check
                    filter = 1 if info['fo'] == TRUE
                    filter == 0 ? r_state = "open|closed" : r_state="filtered"

                    excludeProtocol ? rs_protocol = "!" : rs_protocol = ""
                    excludeSource ? rs_source = "!" : rs_source = ""
                    excludeDestination ? rs_dest = "!" : rs_dest = ""
                    nmapTest << " #{info['flags']}" if info.has_key?('flags')
                    # Test the port now
                    if sPort.match(/any/i)
                        # Source port is "any"
                        portScan = Nmap::Parser.parsescan(nmap_command, nmapTest)
                        if portScan.hosts("up").length == 0
                            failed = 1
                        else
                            # Check for filtered ports now
                            failed = FALSE
                            portScan.hosts("up") { |host| host.tcp_port_list do |c|
                                if filter == 0
                                    if host.tcp_state(c).match(/filter/i)
                                        specifics << "\n(#{p_count+f_count+1}) Port #{c} came back with state \"#{host.tcp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.tcp_reason(c)}"
                                        failed = TRUE
                                    end
                                elsif filter == 1
                                    unless host.tcp_state(c).match(/filter/i)
                                        specifics << "\n(#{p_count+f_count+1}) Port #{c} came back with state \"#{host.tcp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.tcp_reason(c)}"
                                        failed = TRUE
                                    end
                                end
                            end }
                        end
                        # Check the actual results and log the information
                        if failed == FALSE
                            p_count += 1
                            results << "\n(#{p_count+f_count}) \t(Passed)\t #{rs_protocol}TCP \t\t#{rs_source}any:#{rs_dest}#{dPort}"
                        elsif failed == 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t Nmap reported that no host was perceived as being \"up\" when testing #{rs_protocol}TCP #{rs_source}any:#{rs_dest}#{dPort}"
                        else
                            if dPort.include?('-')
                                f_count += 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}TCP \t\t#{rs_source}any:#{rs_dest}#{dPort}"
                            else
                                f_count += 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}TCP \t\t#{rs_source}any:#{rs_dest}#{dPort}"
                            end
                        end
                    else
                        # Source port is specified
                        if sPort.include?("-")
                            # Range
                            # Source port ranges take awhile, so we're going to leverage threads here, too.
                            sub_threads = []
                            sub_tcount = 0
                            failed = FALSE
                            for sub_thread_port in (sPort.split('-')[0].to_i)..(sPort.split('-')[1].to_i)
                                sub_threads.each { |st| st.join } if sub_tcount == info['max_subthreads']
                                count_id = p_count + f_count + 1
                                sub_threads << Thread.new(sub_thread_port) do |i|
                                    portScan = Nmap::Parser.parsescan(nmap_command, nmapTest+" -g #{i}")
                                    if portScan.hosts("up").length == 0
                                        failed = 1
                                    else
                                        portScan.hosts("up") { |host| host.tcp_port_list do |c|
                                            if filter == 0
                                                if host.tcp_state(c).match(/filter/i)
                                                    specifics << "\n(#{count_id}) Port #{i}:#{c} came back with state \"#{host.tcp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.tcp_reason(c)}"
                                                    failed = TRUE
                                                end
                                            elsif filter == 1
                                                unless host.tcp_state(c).match(/filter/i)
                                                    specifics << "\n(#{count_id}) Port #{i}:#{c} came back with state \"#{host.tcp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.tcp_reason(c)}"
                                                    failed = TRUE
                                                end
                                            end
                                        end }
                                    end
                                end
                                sub_threads.each { |st| st.join }
                            end
                            # Check the actual results and log the information
                            if failed == FALSE
                                p_count += 1
                                results << "\n(#{count_id}) \t(Passed)\t #{rs_protocol}TCP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            elsif failed == 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t Nmap reported that no host was perceived as being \"up\" when testing #{rs_protocol}TCP #{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            else
                                if dPort.include?('-')
                                    f_count += 1
                                    results << "\n(#{count_id}) \t(Failed)\t #{rs_protocol}TCP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                else
                                    f_count += 1
                                    results << "\n(#{count_id}) \t(Failed)\t #{rs_protocol}TCP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                end
                            end

                        else
                            portScan = Nmap::Parser.parsescan(nmap_command, nmapTest+" -g #{sPort}")
                            if portScan.hosts("up").length == 0
                                failed = 1
                            else
                                failed = FALSE
                                portScan.hosts("up") { |host| host.tcp_port_list do |c|
                                    if filter == 0
                                        if host.tcp_state(c).match(/filter/i)
                                            specifics << "\n(#{p_count+f_count+1}) Port #{sPort}:#{c} came back with state \"#{host.tcp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.tcp_reason(c)}"
                                            failed = TRUE
                                        end
                                    elsif filter == 1
                                        unless host.tcp_state(c).match(/filter/i)
                                            specifics << "\n(#{p_count+f_count+1}) Port #{sPort}:#{c} came back with state \"#{host.tcp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.tcp_reason(c)}"
                                            failed = TRUE
                                        end
                                    end
                                end }
                            end
                            # Check the actual results and log the information
                            if failed == FALSE
                                p_count += 1
                                results << "\n(#{p_count+f_count}) \t(Passed)\t #{rs_protocol}TCP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            elsif failed == 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t Nmap reported that no host was perceived as being \"up\" when testing #{rs_protocol}TCP #{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            else
                                if dPort.include?('-')
                                    f_count += 1
                                    results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}TCP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                else
                                    f_count += 1
                                    results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}TCP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                end
                            end
                        end
                    end
                end
			end
		end

		# Begin the actual scan and comparing for UDP ports
		if info['udp_ports'].length > 0
			Debug.out("Checking UDP Ports")
            for uport in info['udp_ports'].split(',')
                if thread_count == info['max_root_threads']
                    threads.each { |th| th.join }
                    thread_count = 0
                end
                thread_count += 1
                threads << Thread.new(uport) do |currentPort|
                    case info['from']
                    when /port.?forward/i
                        filter = 0
                    when /block/i
                        filter = 1
                    when /allow/i
                        filter = 0
                    when /dmz host/i
                        if info['action'].match(/on/i)
                            filter = 0
                        elsif info['action'].match(/off/i)
                            filter = 1
                        else
                            filter = 0
                        end
                    when /remote.?admin/i
                        filter = 0
                    when /firewall-max|firewall-med|firewall-typ/i
                        filter = 1
                    when /firewall-min/i
                        filter = 0
                    end
                    r_state = ""
                    currentPort.strip!
                    Debug.out("Checking #{currentPort}")

                    nmapTest = "-sU #{ipaddress} -PN"

                    # Check for prot exclude
                    currentPort.match(/!/) ? excludeProtocol = TRUE : excludeProtocol = FALSE
                    currentPort.delete!('!')

                    # Check for source and exclusion
                    sPort = currentPort.split(':')[0]
                    sPort.match(/~/) ? excludeSource = TRUE : excludeSource = FALSE
                    sPort.delete!('~')

                    # Check for destination and exclusion
                    dPort = currentPort.split(':')[1]
                    dPort.match(/~/) ? excludeDestination = TRUE : excludeDestination = FALSE
                    dPort.delete!('~')
                    # Build a small range to scan if it's set to any for destination
                    if dPort.match(/any/i)
                        gap = (rand(10)+1)*10
                        startRange = rand(65535)+1
                        dPort = "#{startRange}-#{startRange+rand(gap)}"
                        Debug.out("Generated destination port of: #{dPort}")
                    end
                    nmapTest << " -p#{dPort}"

                    # Nmap interface bind
                    nmapTest << " -e #{IPCommon::interface_by_ip(info['lanip'])}" unless info['lanip'] == "192.168.1.1"

                    # By now we should know if this should be filtered by way of the called from section, and the excludes
                    if excludeProtocol == TRUE || excludeSource == TRUE || excludeDestination == TRUE
                        filter == 0 ? filter = 1 : filter = 0
                    end
                    # Filter override check
                    filter = 1 if info['fo'] == TRUE
                    filter == 0 ? r_state = "open|closed" : r_state="filtered"

                    excludeProtocol ? rs_protocol = "!" : rs_protocol = ""
                    excludeSource ? rs_source = "!" : rs_source = ""
                    excludeDestination ? rs_dest = "!" : rs_dest = ""
                    nmapTest << " #{info['flags']}" if info.has_key?('flags')
                    # Test the port now
                    if sPort.match(/any/i)
                        # Source port is "any"
                        portScan = Nmap::Parser.parsescan(nmap_command, nmapTest)
                        if portScan.hosts("up").length == 0
                            failed = 1
                        else
                            # Check for filtered ports now
                            failed = FALSE
                            portScan.hosts("up") { |host| host.udp_port_list do |c|
                                if filter == 0
                                    unless host.udp_state(c).match(/open|closed/i)
                                        specifics << "\n(#{p_count+f_count+1}) Port #{c} came back with state \"#{host.udp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.udp_reason(c)}"
                                        failed = TRUE
                                    end
                                elsif filter == 1
                                    unless host.udp_state(c).match(/filter/i)
                                        specifics << "\n(#{p_count+f_count+1}) Port #{c} came back with state \"#{host.udp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.udp_reason(c)}"
                                        failed = TRUE
                                    end
                                end
                            end }
                        end
                        # Check the actual results and log the information
                        if failed == FALSE
                            p_count += 1
                            results << "\n(#{p_count+f_count}) \t(Passed)\t #{rs_protocol}UDP \t\t#{rs_source}any:#{rs_dest}#{dPort}"
                        elsif failed == 1
                            results << "\n(#{p_count+f_count}) \t(Failed)\t Nmap reported that no host was perceived as being \"up\" when testing #{rs_protocol}UDP #{rs_source}any:#{rs_dest}#{dPort}"
                        else
                            if dPort.include?('-')
                                f_count += 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}UDP \t\t#{rs_source}any:#{rs_dest}#{dPort}"
                            else
                                f_count += 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}UDP \t\t#{rs_source}any:#{rs_dest}#{dPort}"
                            end
                        end
                    else
                        # Source port is specified
                        if sPort.include?("-")
                            # Range
                            # Source port ranges take awhile, so we're going to leverage threads here, too.
                            sub_threads = []
                            sub_tcount = 0
                            failed = FALSE
                            for sub_thread_port in (sPort.split('-')[0].to_i)..(sPort.split('-')[1].to_i)
                                sub_threads.each { |st| st.join } if sub_tcount == info['max_subthreads']
                                count_id = p_count + f_count + 1
                                sub_threads << Thread.new(sub_thread_port) do |i|
                                    portScan = Nmap::Parser.parsescan(nmap_command, nmapTest+" -g #{i}")
                                    if portScan.hosts("up").length == 0
                                        failed = 1
                                    else
                                        portScan.hosts("up") { |host| host.udp_port_list do |c|
                                            if filter == 0
                                                # UDP ports can come back as open|filtered when the result is no-response from nmap. So we'll check for open or closed when they should not be filtered to work around it
                                                # Warning: This may be inaccurate.
                                                unless host.udp_state(c).match(/open|closed/i)
                                                    specifics << "\n(#{count_id}) Port #{i}:#{c} came back with state \"#{host.udp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.udp_reason(c)}"
                                                    failed = TRUE
                                                end
                                            elsif filter == 1
                                                unless host.udp_state(c).match(/filter/i)
                                                    specifics << "\n(#{count_id}) Port #{i}:#{c} came back with state \"#{host.udp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.udp_reason(c)}"
                                                    failed = TRUE
                                                end
                                            end
                                        end }
                                    end
                                end
                                sub_threads.each { |st| st.join }
                            end
                            # Check the actual results and log the information
                            if failed == FALSE
                                p_count += 1
                                results << "\n(#{count_id}) \t(Passed)\t #{rs_protocol}UDP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            elsif failed == 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t Nmap reported that no host was perceived as being \"up\" when testing #{rs_protocol}UDP #{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            else
                                if dPort.include?('-')
                                    f_count += 1
                                    results << "\n(#{count_id}) \t(Failed)\t #{rs_protocol}UDP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                else
                                    f_count += 1
                                    results << "\n(#{count_id}) \t(Failed)\t #{rs_protocol}UDP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                end
                            end
                        else
                            portScan = Nmap::Parser.parsescan(nmap_command, nmapTest+" -g #{sPort}")
                            if portScan.hosts("up").length == 0
                                failed = 1
                            else
                                failed = FALSE
                                portScan.hosts("up") { |host| host.udp_port_list do |c|
                                    if filter == 0
                                        unless host.udp_state(c).match(/open|closed/i)
                                            specifics << "\n(#{p_count+f_count+1}) Port #{sPort}:#{c} came back with state \"#{host.udp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.udp_reason(c)}"
                                            failed = TRUE
                                        end
                                    elsif filter == 1
                                        unless host.udp_state(c).match(/filter/i)
                                            specifics << "\n(#{p_count+f_count+1}) Port #{sPort}:#{c} came back with state \"#{host.udp_state(c)}\". Expected \"#{r_state}\"\n\tReason reported by Nmap: #{host.udp_reason(c)}"
                                            failed = TRUE
                                        end
                                    end
                                end }
                            end
                            # Check the actual results and log the information
                            if failed == FALSE
                                p_count += 1
                                results << "\n(#{p_count+f_count}) \t(Passed)\t #{rs_protocol}UDP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            elsif failed == 1
                                results << "\n(#{p_count+f_count}) \t(Failed)\t Nmap reported that no host was perceived as being \"up\" when testing #{rs_protocol}UDP #{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                            else
                                if dPort.include?('-')
                                    f_count += 1
                                    results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}UDP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                else
                                    f_count += 1
                                    results << "\n(#{p_count+f_count}) \t(Failed)\t #{rs_protocol}UDP \t\t#{rs_source}#{sPort}:#{rs_dest}#{dPort}"
                                end
                            end
                        end
                    end
                end
			end
		end
		threads.each { |th| th.join }
		Debug.out("Finished comparing.")
		results << "\n"
		results << "-"*70
		results << "\n\n" + specifics
		if f_count > 0
			return "F\nTotal: #{p_count} passed of #{p_count+f_count} possible.\n" + r_header + results
		else
			return "P\nTotal: #{p_count} passed of #{p_count+f_count} possible.\n" + r_header + results
		end
	end
end