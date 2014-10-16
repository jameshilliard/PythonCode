require 'mechanize'
require 'net/telnet'
require 'common/telnet_mod'

module AdminCheck
    def telnet_check(options)
        begin
            # Set the command hash to print the configuration
            command_1 = { "String" => "system ver", "Match" => /returned/im }
            command_2 = { "String" => "conf print //", "Match" => /returned/im }
            # Open session and login
            session = Net::Telnet::new("Host" => options.ip, "Port" => options.tport)

            session.waitfor("Match" => /username/im, "Timeout" => 3)
            session.puts(options.username)
            session.waitfor("Match" => /password/im, "Timeout" => 2)
            session.puts(options.password)
            session.waitfor("Match" => /Wireless Broadband Router/im, "Timeout" => 2)

            # Deliver configuration print command
            ver_info = session.cmd(command_1)
            conf_info = session.cmd(command_2)

            serial = conf_info.slice(/serial_num\(.+?\)/i).gsub(/\(|\)/, '').sub(/serial_num/i, '')
            model = conf_info.slice(/model_number\(.+?\)/i).gsub(/\(|\)/, '').sub(/model_number/i, '')
            hardware_rev = ver_info.slice(/hardware version: \w+/i).to_s.slice(/: \w+\z/).delete('^[a-zA-Z0-9]')
            firmware = ver_info.slice(/version: .*/i).chomp.slice(/\d+\.\d+\.\d+\z/)

            # Logout and close session
            session.puts "exit"
            session.close
            return "#{model} #{hardware_rev}, #{firmware}, #{serial}"
        rescue SystemCallError => sce
            if sce.message.match(/connection refused/im)
                return "CR"
            else
                return sce.message
            end
        rescue Timeout::Error
            return "LF"
        end
    end

    def sec_telnet(options)
        begin
            command_1 = { "String" => "system ver", "Match" => /returned/im }
            command_2 = { "String" => "conf print //", "Match" => /returned/im }

            socket = TCPSocket.new(options.ip, options.telnets)
            ssl_c = OpenSSL::SSL::SSLContext.new()
            ssl_c.verify_mode = OpenSSL::SSL::VERIFY_NONE

            sslsocket = OpenSSL::SSL::SSLSocket.new(socket, ssl_c)
            sslsocket.sync_close = true
            sslsocket.connect

            session = Net::Telnet::new("Proxy" => sslsocket)

            session.waitfor("Match" => /username/im, "Timeout" => 3)
            session.puts(options.username)
            session.waitfor("Match" => /password/im, "Timeout" => 2)
            session.puts(options.password)
            session.waitfor("Match" => /Wireless Broadband Router/im, "Timeout" => 2)

            # Deliver configuration print command
            ver_info = session.cmd(command_1)
            conf_info = session.cmd(command_2)

            serial = conf_info.slice(/serial_num\(.+?\)/i).gsub(/\(|\)/, '').sub(/serial_num/i, '')
            model = conf_info.slice(/model_number\(.+?\)/i).gsub(/\(|\)/, '').sub(/model_number/i, '')
            hardware_rev = ver_info.slice(/hardware version: \w+/i).to_s.slice(/: \w+\z/).delete('^[a-zA-Z0-9]')
            firmware = ver_info.slice(/version: .*/i).chomp.slice(/\d+\.\d+\.\d+\z/)

            # Logout and close session
            session.puts "exit"
            session.close
            return "#{model} #{hardware_rev}, #{firmware}, #{serial}"
        rescue SystemCallError => sce
            if sce.message.match(/connection refused/im)
                return "CR"
            else
                return sce.message
            end
        rescue Timeout::Error
            return "LF"
        end
    end

    def web_check(options)
        begin
            # ID tags so we can call by name and not by row number further down.
            id = { :firmware => 0, :model => 1, :hardware => 2, :serial => 3, :physical => 4, :broadband_type => 5, :broadband_stat => 6,
                   :broadband_ip => 7, :subnet => 8, :mac => 9, :gateway => 10, :dns => 11, :uptime => 12 }
            browser_agent = WWW::Mechanize.new
            login_page = browser_agent.get(options.url)

            # Set login information and create the MD5 hash
            login_page.forms[0].user_name = options.username
            pwmask, auth_key = "", ""
            login_page.forms[0].fields.each { |t| pwmask = t.name if t.name.match(/passwordmask_\d+/); auth_key = t.value if t.name.match(/auth_key/) }
            login_page.forms[0]["#{pwmask}"] = options.password
            login_page.forms[0].md5_pass = Digest::MD5.hexdigest("#{options.password}#{auth_key}")
            login_page.forms[0].mimic_button_field = "submit_button_login_submit%3a+.."
            browser_agent.submit(login_page.forms[0])

            # Success check - make sure we have a logout option
            return "LF" unless browser_agent.current_page.parser.text.match(/logout/im)

            # Get to System Information
            browser_agent.current_page.forms[0].mimic_button_field = "sidebar: actiontec_topbar_status.."
            browser_agent.submit(browser_agent.current_page.forms[0])

            # Get System Information data
            info = browser_agent.current_page.parser.xpath('//tr/td[@class="GRID_NO_LEFT"]')

            # Log out
            browser_agent.current_page.forms[0].mimic_button_field = "logout: ..."
            browser_agent.submit(browser_agent.current_page.forms[0])

            return "#{info[id[:model]].content} #{info[id[:hardware]].content}, #{info[id[:firmware]].content}, #{info[id[:serial]].content}"
        rescue SystemCallError => sce
            if sce.message.match(/connection refused/im)
                return "CR"
            else
                return sce.message
            end
        end
    end
end