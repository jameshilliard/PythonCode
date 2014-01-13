require 'testsystem/iperf-parser'

class FlagException < RuntimeError
    attr :msg
    def initialize(message)
        @msg = message
    end
end

# Module for testing with iperf - needs work but should be okay for port triggering
module Iperf_system

    def create_iperf_flags(flag_options)
        raise ArgumentError, "Options needs to be a hash" unless flag_options.is_a?(Hash)
        raise ArgumentError, "Iperf flags must either be a server or a client with an IP address. Cannot be a client without an IP provided." unless flag_options[:ip] if flag_options[:client]
        raise ArgumentError, "Can't use bidirectional and tradeoff flags in the same test." if flag_options[:tradeoff] && flag_options[:bidirectional]

        flags = ""

        # Server or client based on client flag - true or false
        flag_options[:client] ? flags << "-y C -c #{flag_options[:ip]}" : flags << "-s"
        flags << " -d -L #{flag_options[:bidirectional]}" if flag_options[:bidirectional]
        flags << " -r -L #{flag_options[:tradeoff]}" if flag_options[:tradeoff]
        flags << " -S #{flag_options[:dscp]}" if flag_options[:dscp]
        flags << " -B #{flag_options[:bind_ip]}" if flag_options[:bind_ip]
        flags << " -u" if flag_options[:udp] unless flag_options[:client]
        flags << " -u -b 100M" if flag_options[:udp] if flag_options[:client]
        if flag_options[:client]
            flags << " -p #{flag_options[:port]}" if flag_options[:port]
        else
            flags << " -p #{flag_options[:port]}" unless flag_options[:ltp]
            flags << " -p #{flag_options[:ltp]}" if flag_options[:ltp]
        end
        return flags
    end

    # Method to take care of everything related to the remote client/server of iperf
    def remote_iperf(sshcli, flags, kill = false)
        if kill
            Debug.out("Killing remote iperf process.")
            remote_pid = `#{sshcli} \"ps aux\" | awk '/iperf #{flags}/ && !/awk/ {print $2}'`
            system("#{sshcli} \"kill #{remote_pid.delete('^[0-9]')}\"")
            return
        end
        Debug.out("Running remotely: #{sshcli} \"iperf #{flags}\"")
        unless flags.match(/-c/)
            iperf_system = Open3.popen3("#{sshcli} \"iperf #{flags}\"")
            done_waiting = false
            output = ""
            while not done_waiting
                output << iperf_system[1].readpartial(1)
                done_waiting = TRUE if output.match(/server listening/im)
            end
            Debug.out("Remote server should be up... ")
        else
            iperf_results = IO.popen("#{sshcli} \"iperf #{flags} 2>&1\"").read
            # SSHCli work arounds for iperf results.
            if iperf_results.match(/sshcli/im)
                iperf_results.sub!(/.*password:/im, '')
                iperf_results.sub!(/inf.*/im, '')
            end
            return iperf_results
        end
    end

    # Method to take care of everything related to the local client/server of iperf
    def local_iperf(flags, kill = false)
        if kill
            Debug.out("Killing local iperf process")
            system("kill `ps aux | awk '/iperf #{flags}/ && !/awk/ {print $2}'`")
            return
        end
        Debug.out("Running locally: iperf #{flags}")
        unless flags.match(/-c/)
            iperf_system = Open3.popen3("iperf #{flags}")
            done_waiting = false
            output = ""
            while not done_waiting
                output << iperf_system[1].readpartial(1)
                done_waiting = TRUE if output.match(/server listening/im)
            end
            Debug.out("Local server should be up... ")
        else
            return IO.popen("iperf #{flags} 2>&1").read
        end
    end

    # Method to format data outside of the controller
    def results_format(iperf_results, udp, bdr)
        # Parse and format the data, then log it.
        if iperf_results.length > 10 && iperf_results.match(/failed/i) == nil
            if bdr
                r_data = IPerf_Data.new
                s_data = IPerf_Data.new
                if udp
                    # IPerf UDP has an issue in that it sends back an unfinished test result string for the first line. Workaround:
                    if iperf_results.split("\n")[0].count(',') > 7
                        r_data.parse(iperf_results.split("\n")[0])
                        s_data.parse(iperf_results.split("\n")[1])
                    else
                        r_data.parse(iperf_results.split("\n")[1])
                        s_data.parse(iperf_results.split("\n")[2])
                    end
                else
                    r_data.parse(iperf_results.split("\n")[0])
                    s_data.parse(iperf_results.split("\n")[1])
                end
                iperf_results = "(#{r_data.id}) #{r_data.date} - #{r_data.local_ip}:#{r_data.local_port} to #{r_data.remote_ip}:#{r_data.remote_port} sent #{r_data.data_size} in #{r_data.timer} (#{r_data.bandwidth})"
                iperf_results << "\nBidirectional/Tradeoff: (#{s_data.id}) - #{s_data.date} #{s_data.remote_ip}:#{s_data.remote_port} to #{s_data.local_ip}:#{s_data.local_port} sent #{s_data.data_size} in #{s_data.timer} (#{s_data.bandwidth})"
            else
                r_data = IPerf_Data.new
                if udp
                    if iperf_results.split("\n")[0].count(',') > 7
                        r_data.parse(iperf_results.split("\n")[0])
                    else
                        r_data.parse(iperf_results.split("\n")[1])
                    end
                else
                    r_data.parse(iperf_results.delete('^[0-9,.\-]'))
                end
                iperf_results = "(#{r_data.id}) #{r_data.date} - #{r_data.local_ip}:#{r_data.local_port} to #{r_data.remote_ip}:#{r_data.remote_port} sent #{r_data.data_size} in #{r_data.timer} (#{r_data.bandwidth})"
            end
        end
        return iperf_results
    end

    # Main method to control all other tasks
    def iperf_controller(rule_name, info)
        Debug.out("LAN IP: #{info['lanip']} WAN IP: #{info['wanip']} Outbound IP: #{info['outbound_ip']} Inbound IP: #{info['inbound_ip']}")       
        # parse through the information sent
        case info['type']
        # random from list will do a bidirectional or tradeoff test if there's both inbound and outbound specified
        when /-rfl/i
            if info.has_key?('outbound') && info.has_key?('inbound')
                info['outbound'] = get_random_port(info['outbound'])
                info['inbound'] = get_random_port(info['inbound'])
                # Having both bidirectional and tradeoff with RFL will cancel each other out, and it will run 2 stand alone tests instead. Will also cancel if inbound and outbound are different protocols
            elsif info.has_key?('outbound')
                info['outbound'] = get_random_port(info['outbound'])
            elsif info.has_key?('inbound')
                info['inbound'] = get_random_port(info['inbound'])
            else
                raise FlagException.new("No ports to select from list using the -RFL flag")
            end
        # Following two options are generally for inbound connections only
        when /-random/i
            info['inbound'] = get_random_port(info['type'].match(/-random \d+-\d+/i).to_s.delete('^[0-9\-]'))
        when /-port/i
            info['inbound'] = info['type'].match(/-port \d+/i).to_s.delete('^[0-9]')
        when /-all/i
            # Expand the lists with randomly chosen ports from all ranges, if any exist
            new_inbound_list = ""
            new_outbound_list = ""
            info['inbound'].split(',').each do |p|
                new_inbound_list << "#{get_random_port(p)}," if p.include?('-')
                new_inbound_list << "#{p}," unless p.include?('-')
            end if info.has_key?('inbound')
            info['inbound'] = new_inbound_list.sub(/,\z/, '')
            info['outbound'].split(',').each do |p|
                new_outbound_list << "#{get_random_port(p)}," if p.include?('-')
                new_outbound_list << "#{p}," unless p.include?('-')
            end if info.has_key?('outbound')
            info['outbound'] = new_outbound_list.sub(/,\z/, '')
        when /-complete/i
            # Expand the lists fully with all ports in each.
            new_inbound_list = ""
            new_outbound_list = ""
            info['inbound'].split(',').each do |p|
                new_inbound_list << "#{expand(p)}," if p.include?('-')
                new_inbound_list << "#{p}," unless p.include?('-')
            end if info.has_key?('inbound')
            info['inbound'] = new_inbound_list.sub(/,\z/, '')
            info['outbound'].split(',').each do |p|
                new_outbound_list << "#{expand(p)}," if p.include?('-')
                new_outbound_list << "#{p}," unless p.include?('-')
            end if info.has_key?('outbound')
            info['outbound'] = new_outbound_list.sub(/,\z/, '')
        end
        
        Debug.out("Going to use inbound list: #{info['inbound']} and outbound list: #{info['outbound']}")
        Debug.out("Using sschli command: #{info['sshcli']}")

        unless info['bidirectional'] || info['tradeoff']
            iperf_threads = { :outbound => [], :inbound => [] }
            iperf_results_matrix = { :outbound => [], :inbound => [] }

            Debug.out("Starting outbound port testing with iperf.")
            outbound_thread = Thread.new do
                otc = 0
                info['outbound'].split(',').each do |c|
                    if otc == info['max_root_threads'].to_i
                        iperf_threads[:outbound].each { |t| t.join }
                        otc = 0
                    end
                    otc += 1
                    iperf_threads[:outbound] << Thread.new do
                        client_options = { :client => TRUE, :dscp => false, :udp => false, :bind_ip => false, :tradeoff => false, :bidirectional => false, :ip => info['outbound_ip'], :port => c.delete('^[0-9]') }
                        client_options[:dscp] = info['dscp'] if info.has_key?('dscp')
                        server_options = { :client => false, :dscp => false, :udp => false, :bind_ip => false, :tradeoff => false, :bidirectional => false, :ip => false, :port => c.delete('^[0-9]'), :ltp => false }
                        server_options[:ltp] = info['ltp'] if info['ltp']
                        
                        # default to tcp for client/server
                        if c.match(/udp/i)
                            client_options[:udp] = TRUE
                            server_options[:udp] = TRUE
                        end
                        rt_count = 0
                        begin
                            if info['iperf_server'].match(/remote/i)
                                client_options[:bind_ip] = info['local_ip'] if info['local_ip']
                                server_options[:bind_ip] = info['remote_ip'] if info['remote_ip']
                                remote_iperf(info['sshcli'], create_iperf_flags(server_options))
                                iperf_results = local_iperf(create_iperf_flags(client_options))
                                remote_iperf(info['sshcli'], create_iperf_flags(server_options), true)
                            else
                                client_options[:bind_ip] = info['remote_ip'] if info['remote_ip']
                                server_options[:bind_ip] = info['local_ip'] if info['local_ip']
                                local_iperf(create_iperf_flags(server_options))
                                iperf_results = remote_iperf(info['sshcli'], create_iperf_flags(client_options))
                                local_iperf(create_iperf_flags(server_options), true)
                            end
                            # If we get a broken pipe error then throw out an exception so we can retry the test.
                            # outbound tests get 3 retries
                            if info['should_fail']
                                self.msg("IPerf Passed #{rule_name} - Outbound test #{c}", :info, 'Passed - Test System - IPerf', "No data received")
                            else
                                raise FlagException.new("Test issues - retrying...") if iperf_results.match(/failed/i)
                                iperf_results_matrix[:outbound] << results_format(iperf_results, client_options[:udp], client_options[:bidirectional] || client_options[:tradeoff])
                                self.msg("IPerf Passed #{rule_name} - Outbound test #{c}", :info, 'Passed - Test System - IPerf', "#{results_format(iperf_results, client_options[:udp], client_options[:bidirectional] || client_options[:tradeoff])}")
                            end
                        rescue ArgumentError => err
                            puts err.message
                            exit
                        rescue FlagException => f
                            if info['should_fail']
                                Debug.out("Should not pass was set, marking test as passed")
                                self.msg("IPerf Passed #{rule_name} - Inbound test #{c}", :info, 'Passed - Test System - IPerf', "No data received")
                            else
                                if rt_count < 3
                                    Debug.out("#{f.msg} #{rt_count}")
                                    # Sleep for 5 seconds, then kill the local iperf process
                                    sleep 5
                                    # kill process
                                    info['iperf_server'].match(/remote/i) ? remote_iperf(info['sshcli'], create_iperf_flags(server_options), true) : local_iperf(create_iperf_flags(server_options), true)
                                    rt_count += 1
                                    retry
                                else
                                    Debug.out("Tried three times, but unable to get successful results. Moving on...")
                                    self.msg("IPerf Failed #{rule_name} - Outbound test #{c}", :info, 'Failed - Test System - IPerf', "Result string from iperf client was: #{iperf_results.chomp} (If empty, check sshcli logs.)")
                                end
                            end
                        end
                    end
                end if info['outbound'].length > 0
                iperf_threads[:outbound].each { |t| t.join } if otc > 0
            end

            # Give outbound threads time to start first, before we step into the inbound threads - for port triggering
            sleep 3 if info['from'].match(/port.?trigger/i)
            Debug.out("Starting inbound port testing with iperf.")
            inbound_thread = Thread.new do
                otc = 0

                info['inbound'].split(',').each do |c|
                    if otc == info['max_root_threads'].to_i
                        iperf_threads[:inbound].each { |t| t.join }
                        otc = 0
                    end
                    otc += 1
                    iperf_threads[:inbound] << Thread.new do
                        # default to tcp for client/server
                        client_options = { :client => TRUE, :dscp => false, :udp => false, :bind_ip => false, :tradeoff => false, :bidirectional => false, :ip => info['inbound_ip'], :port => c.delete('^[0-9]') }
                        client_options[:dscp] = info['dscp'] if info.has_key?('dscp')
                        server_options = { :client => false, :dscp => false, :udp => false, :bind_ip => false, :tradeoff => false, :bidirectional => false, :ip => false, :port => c.delete('^[0-9]'), :ltp => false }
                        server_options[:ltp] = info['ltp'] if info['ltp']

                        # default to tcp for client/server
                        if c.match(/udp/i)
                            client_options[:udp] = TRUE
                            server_options[:udp] = TRUE
                        end
                        rt_count = 0
                        begin

                            # For inbound tests we simply swap here with port triggering tests
                            if info['iperf_server'].match(/local/i)
                                client_options[:bind_ip] = info['local_ip'] if info['local_ip']
                                server_options[:bind_ip] = info['remote_ip'] if info['remote_ip']
                                remote_iperf(info['sshcli'], create_iperf_flags(server_options))
                                iperf_results = local_iperf(create_iperf_flags(client_options))
                                remote_iperf(info['sshcli'], create_iperf_flags(server_options), true)
                            else
                                client_options[:bind_ip] = info['remote_ip'] if info['remote_ip']
                                server_options[:bind_ip] = info['local_ip'] if info['local_ip']
                                local_iperf(create_iperf_flags(server_options))
                                iperf_results = remote_iperf(info['sshcli'], create_iperf_flags(client_options))
                                local_iperf(create_iperf_flags(server_options), true)
                            end if info['from'].match(/port.?trigger/i)

                            if info['iperf_server'].match(/remote/i)
                                client_options[:bind_ip] = info['local_ip'] if info['local_ip']
                                server_options[:bind_ip] = info['remote_ip'] if info['remote_ip']
                                remote_iperf(info['sshcli'], create_iperf_flags(server_options))
                                iperf_results = local_iperf(create_iperf_flags(client_options))
                                remote_iperf(info['sshcli'], create_iperf_flags(server_options), true)
                            else
                                client_options[:bind_ip] = info['remote_ip'] unless info['remote_ip'].empty? if info['remote_ip']
                                server_options[:bind_ip] = info['local_ip'] if info['local_ip']
                                local_iperf(create_iperf_flags(server_options))
                                iperf_results = remote_iperf(info['sshcli'], create_iperf_flags(client_options))
                                local_iperf(create_iperf_flags(server_options), true)
                            end unless info['from'].match(/port.?trigger/i)

                            # If we get a broken pipe error then throw out an exception so we can retry the test.
                            # inbound tests will only get 1 retry
                            if info['should_fail']
                                self.msg("IPerf Passed #{rule_name} - Inbound test #{c}", :info, 'Passed - Test System - IPerf', "No data received")
                            else
                                raise FlagException.new("Test issues - retrying...") if iperf_results.match(/failed/i)
                                iperf_results_matrix[:outbound] << results_format(iperf_results, client_options[:udp], client_options[:bidirectional] || client_options[:tradeoff])
                                self.msg("IPerf Passed #{rule_name} - Inbound test #{c}", :info, 'Passed - Test System - IPerf', "#{results_format(iperf_results, client_options[:udp], client_options[:bidirectional] || client_options[:tradeoff])}")
                            end
                        rescue ArgumentError => err
                            puts err.message
                            exit
                        rescue FlagException => f
                            if info['should_fail']
                                Debug.out("Should not pass was set, marking test as passed")
                                self.msg("IPerf Passed #{rule_name} - Inbound test #{c}", :info, 'Passed - Test System - IPerf', "No data received")
                            else
                                if rt_count < 1
                                    Debug.out("#{f.msg} #{rt_count}")
                                    rt_count += 1
                                    # Sleep for 5, kill processes, then retry
                                    sleep 5
                                    if info['iperf_server'].match(/local/i)
                                        remote_iperf(info['sshcli'], create_iperf_flags(server_options), true)
                                    else
                                        local_iperf(create_iperf_flags(server_options), true)
                                    end if info['from'].match(/port.?trigger/i)

                                    if info['iperf_server'].match(/remote/i)
                                        remote_iperf(info['sshcli'], create_iperf_flags(server_options), true)
                                    else
                                        local_iperf(create_iperf_flags(server_options), true)
                                    end unless info['from'].match(/port.?trigger/i)

                                    retry
                                else
                                    Debug.out("Tried three times, but unable to get successful results. Moving on...")
                                    self.msg("IPerf Failed #{rule_name} - #{c}", :info, 'Failed - Test System - IPerf', "Result string from iperf client was: #{iperf_results.chomp} (If empty, check sshcli logs.)")
                                end
                            end
                        end
                    end
                end if info['inbound'].length > 0
                iperf_threads[:inbound].each { |t| t.join } if otc > 0
            end
            inbound_thread.join
            outbound_thread.join
        end
    end
end