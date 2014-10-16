#!/usr/bin/env ruby
# This grabs some simple DUT information and returns it using the protocol, ports, and user/pass/ip passed to it.
# Useful for checking remote administration or local administration login methods.
# Returns a simple line back including: PROTOCOL://IP:PORT - Model Revision, Firmware, Serial, or will return - "Failed: Login Failed" if the login failed
# Note: This contains all the common libraries and modifications so it can be copied to another machine and ran, so it's larger than it should be. The included
# common files are telnet_mod, ipcheck, and icmp-ping

$: << File.dirname(__FILE__)

require 'ostruct'
require 'optparse'
require 'rubygems'
begin
    require 'mechanize'
rescue LoadError
    system("gem install mechanize")
    require 'rubygems'
    require 'mechanize'
end
require 'net/telnet'
require 'socket'
require 'timeout'
require "openssl"

$debug = 0
options = OpenStruct.new
options.bhr = 2
options.dut_ip = "192.168.1.1"
options.username = "admin"
options.password = "admin1"
options.http = FALSE
options.https = FALSE
options.telnet = FALSE
options.stelnet = FALSE
options.telnets = FALSE
options.shttp = FALSE
options.shttps = FALSE
options.icmp = FALSE
options.udptrace = FALSE
options.all = FALSE
options.short = FALSE

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "This grabs some simple DUT information and returns it using the protocol, ports, and user/pass/ip passed to it."

    opts.on("-o FILE", "Sets Veriwave output file") { |v| options.vw_hardware_file = v }
    opts.on("--bhr VERSION", "Sets BHR version for getting information (1 or 2)") { |v| options.bhr = v.to_i }
    opts.on("-i IP", "IP/URL for accessing DUT. Defaults to 192.168.1.1.") { |v| options.dut_ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("--http PORT", "Sets port for primary HTTP.") { |v| options.http = v.to_i }
    opts.on("--https PORT", "Sets port for primary HTTPS.") { |v| options.https = v.to_i }
    opts.on("--shttp PORT", "Sets port for secondary HTTP.") { |v| options.shttp = v.to_i }
    opts.on("--shttps PORT", "Sets port for secondary HTTPS.") { |v| options.shttps = v.to_i }
    opts.on("--telnet PORT", "Sets port for primary telnet.") { |v| options.telnet = v.to_i }
    opts.on("--stelnet PORT" "Sets port for secondary telnet.") { |v| options.stelnet = v.to_i }
    opts.on("--telnets PORT", "Sets port for secure telnet over SSL.") { |v| options.telnets = v.to_i }
    
    opts.on("--icmp", "Does an ICMP check") { options.icmp = TRUE }
    opts.on("--udptrace", "Does a UDP traceroute query") { options.udptrace = TRUE }
    opts.on("--all PORTS", "Checks everything on specified ports in order listed above (comma separated.)") { |o| options.all = o }
    opts.on("-s", "--short", "Short list results.") { options.short = TRUE }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

class Debug
	def out(message)
		if $debug == 3
			puts "(III) #{message}"
		end
        if $debug == 2 && message.length < 41
            puts "(II) #{message}"
        end
	end

    def err(message)
        puts "(!!!) #{message}"
        exit
    end
end

# Quick and dirty ICMP ping method for Ruby. Returns true if passed, false if not.
module ICMP
    private
    def self.checksum(string)
        length    = string.length
        num_short = length / 2
        check     = 0

        string.unpack("n#{num_short}").each do |short|
        check += short
        end

        if length % 2 > 0
        check += string[length-1, 1].unpack('C').first << 8
        end

        check = (check >> 16) + (check & 0xffff)
        return (~((check >> 16) + check) & 0xffff)
    end

    def ping(host)
        data_string = ""
        sequence = 0
        checksum = 0
        result = false
        timeout = 5
        pack_string = 'C2 n3 A56'

        0.upto(56){|n| data_string << (n%256).chr}
        pid  = Process.pid & 0xffff
        sequence = (sequence + 1) % 65536

        icmp_sock = Socket.new(
            Socket::PF_INET,
            Socket::SOCK_RAW,
            Socket::IPPROTO_ICMP
        )
        
        packet = [8, 0, checksum, pid, sequence, data_string].pack(pack_string)
        checksum =self.checksum(packet)
        packet = [8, 0, checksum, pid, sequence, data_string].pack(pack_string)

        begin
            saddr = Socket.pack_sockaddr_in(0, host)
        rescue Exception
            icmp_sock.close unless icmp_sock.closed?
            return result
        end

        icmp_sock.send(packet, 0, saddr)

        begin
            Timeout.timeout(timeout) do
                io_array = select([icmp_sock], nil, nil, timeout)
                return false if io_array.nil? || io_array[0].empty?

                pidt = nil
                seq = nil

                data, sender  = icmp_sock.recvfrom(1500)
                port, host    = Socket.unpack_sockaddr_in(sender)
                type, subcode = data[20, 2].unpack('C2')

                case type
                when 0
                    if data.length >= 28
                        pidt, seq = data[24, 4].unpack('n3')
                    end
                else
                    if data.length > 56
                        pidt, seq = data[52, 4].unpack('n3')
                    end
                end
                result = true if pidt == pid && seq == sequence && type == 0
            end
        rescue Exception => err
            puts err
            return false
        ensure
            icmp_sock.close if icmp_sock
        end

        return result
    end
    module_function :ping
end
# Module support functions
module IPCommon
	private
    # gets an ip address from a linux interface and returns it
    def ip_by_interface(int)
        ip = `ifconfig #{int} | awk '/inet addr/ {split ($2,A,":"); print A[2]}'`.chomp
        return ip
    end
    module_function :ip_by_interface

    # Gets an interface by ip address from a linux system
    def interface_by_ip(ip)
        int = `ifconfig |grep -B 2 -e \"#{ip} \" | awk '/Link encap/ {split ($0,A," "); print A[1]}'`.chomp
        return int
    end
    module_function :interface_by_ip

	# Converts CIDR formatted bitmask to integer
	def bits_to_mask(nm)
		return(0) if (nm == 0)
		m = 2**32-1
		return( m ^ (m >> nm) )
	end
	module_function :bits_to_mask

	# Converts integer to CIDR (short)formatted netmask (bitmask)
	def mask_to_bits(nm)
		mask = 32
		mask.times do
            if ( (nm & 1) == 1)
                break
            end
			nm = nm >> 1
			mask = mask - 1
		end
		return(mask)
	end
	module_function :mask_to_bits

	# Returns the integer of the IP address
	def ip_int(ip=nil)
		if ip==nil
			return FALSE
		end
		ip_int = 0
		octets = ip.split('.')
		(0..3).each do |x|
			octet = octets.pop.to_i
			octet = octet << 8*x
			ip_int = ip_int | octet
		end
		return ip_int
	end
	module_function :ip_int

	# Returns an IP in a.b.c.d format from an integer value
	def ip_string(ipint)
        octets = []
        4.times do
            octet = ipint & 0xFF
            octets.unshift(octet.to_s)
            ipint = ipint >> 8
        end
        ip = octets.join('.')
		return ip
	end
	module_function :ip_string

	# Returns the ip class (A, B, C, D, E)
	def ip_class(ip)
		ipclass = ''
		ipclass = 'A' if (ip_int("10.0.0.0")..ip_int("127.255.255.255")) === ip_int(ip)
		ipclass = 'B' if (ip_int("128.0.0.0")..ip_int("191.255.255.255")) === ip_int(ip)
		ipclass = 'C' if (ip_int("192.0.0.0")..ip_int("223.255.255.255")) === ip_int(ip)
		ipclass = 'D' if (ip_int("224.0.0.0")..ip_int("239.255.255.255")) === ip_int(ip)
		ipclass = 'E' if (ip_int("240.0.0.0")..ip_int("255.255.255.255")) === ip_int(ip)
		return ipclass
	end
	module_function :ip_class

	# Returns TRUE if IP is a private address
	def is_private(ip)
		priv = FALSE
		if (ip_int("10.0.0.0")..ip_int("10.255.255.255")) === ip_int(ip)
			priv = TRUE
		elsif (ip_int("172.16.0.0")..ip_int("172.31.255.255")) === ip_int(ip)
			priv = TRUE
		elsif (ip_int("192.168.0.0")..ip_int("192.168.255.255")) === ip_int(ip)
			priv = TRUE
		end
		return priv
	end
	module_function :is_private

    # Returns TRUE if the IP is valid
    def is_valid(ip)
		return FALSE if ip == ""
		if ip_int(ip) > 2**32-1 || ip_int(ip) < 0
			return FALSE
		else
			return TRUE
		end
	end
    module_function :is_valid
end


# Class to check the format of an ip address and return the value specified.
# Input is "protocol://" (optional) followed by
# IP address, :PORT, ,./bitmask - 0-32, or netmask in a.b.c.d format - 255.255.255.0
# Example - dut = IP.new("https://192.168.1.1:8080/24")
# This gives dut.ip = 192.168.1.1, dut.netmask = 255.255.255.0, dut.bitmask = 24, dut.protocol = https, and dut.url = https://192.168.1.1:8080
# Example - dut = IP.new("192.168.50.1:8000/32")
# This gives dut.ip = 192.168.50.1, dut.netmask = 255.255.255.255, dut.bitmask = 32, dut.protocol = "", dut.url = http://192.168.50.1:8000
# Notice that it will build a URL as a default of http://192.168.1.1:80 if nothing is given for those specified portions (protocol, ip, port)
#
# Note: Because this class contains regular expresions when splitting the items apart, it acts as a checker as well. If something comes back
# as an empty string, then it should be known said string wasn't valid.
class IP

	attr_accessor :ip, :port, :protocol, :netmask, :bitmask, :url

	def initialize(ip=nil)
		@ip = ""
		@port = ""
		@protocol = ""
		@netmask = ""
		@bitmask = 0
        @url = ""
		holder = ""
		unless ip == nil
			# parse a string if one got passed into sections
			@ip = ip.slice!(/\b(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\b/) if ip.match(/\b(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\b/)

			@protocol = ip.slice!(/\w+?:\/\//) if ip.match(/\w+?:\/\//)

            if ip.match(/[\/|,|\.](?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}/)
                @netmask = ip.slice!(/[\/|,|\.](?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}/).gsub(/[^0-9\.]|\A\./, '')
                @bitmask = IPCommon::mask_to_bits(IPCommon::ip_int(@netmask)) unless @netmask.empty?
            elsif ip.match(/[\/|,|\.](?:[0-2][0-9]|3[0-2]|[0-9])/)
				holder = ip.slice!(/[\/|,|\.](?:[0-2][0-9]|3[0-2]|[0-9])/).delete('^[0-9]')
				@bitmask = holder.to_i if holder.to_i > 0
				# Convert the mask to a string here
				@netmask = IPCommon::ip_string(IPCommon::bits_to_mask(@bitmask)) if @bitmask > 0
            end

			@port = ip.slice!(/:(?:6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|\d{1,4})\z/) if ip.match(/:(?:6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|\d{1,4})\z/)

			# Clean Up
			@port.delete!(':') unless @port.empty?
			@protocol.delete!('://') unless @protocol.empty?

            # Build URL
            @protocol == "" ? @url << "http://" : @url << "#{@protocol}://"
            @ip == "" ? @url << "192.168.1.1" : @url << "#{@ip}"
            @port == "" ? @url << ":80" : @url << ":#{@port}"
		end
	end

	def is_valid
		return FALSE if @ip == ""
		if IPCommon::ip_int(@ip) > 2**32-1 || IPCommon::ip_int(@ip) < 0
			return FALSE
		else
			return TRUE
		end
	end
end

# Telnet modification to allow OpenSSL::SSL::SSLSocket classes in telnet
module Net
    class Telnet

        alias initialize_org initialize

        def initialize(options) # :yield: mesg
          @options = options
          @options["Host"]       = "localhost"   unless @options.has_key?("Host")
          @options["Port"]       = 23            unless @options.has_key?("Port")
          @options["Prompt"]     = /[$%#>] \z/n  unless @options.has_key?("Prompt")
          @options["Timeout"]    = 10            unless @options.has_key?("Timeout")
          @options["Waittime"]   = 0             unless @options.has_key?("Waittime")
          unless @options.has_key?("Binmode")
            @options["Binmode"]    = false
          else
            unless (true == @options["Binmode"] or false == @options["Binmode"])
              raise ArgumentError, "Binmode option must be true or false"
            end
          end

          unless @options.has_key?("Telnetmode")
            @options["Telnetmode"] = true
          else
            unless (true == @options["Telnetmode"] or false == @options["Telnetmode"])
              raise ArgumentError, "Telnetmode option must be true or false"
            end
          end

          @telnet_option = { "SGA" => false, "BINARY" => false }

          if @options.has_key?("Output_log")
            @log = File.open(@options["Output_log"], 'a+')
            @log.sync = true
            @log.binmode
          end

          if @options.has_key?("Dump_log")
            @dumplog = File.open(@options["Dump_log"], 'a+')
            @dumplog.sync = true
            @dumplog.binmode
            def @dumplog.log_dump(dir, x)  # :nodoc:
              len = x.length
              addr = 0
              offset = 0
              while 0 < len
                if len < 16
                  line = x[offset, len]
                else
                  line = x[offset, 16]
                end
                hexvals = line.unpack('H*')[0]
                hexvals += ' ' * (32 - hexvals.length)
                hexvals = format("%s %s %s %s  " * 4, *hexvals.unpack('a2' * 16))
                line = line.gsub(/[\000-\037\177-\377]/n, '.')
                printf "%s 0x%5.5x: %s%s\n", dir, addr, hexvals, line
                addr += 16
                offset += 16
                len -= 16
              end
              print "\n"
            end
          end

          if @options.has_key?("Proxy")
            if @options["Proxy"].kind_of?(Net::Telnet)
              @sock = @options["Proxy"].sock
            elsif @options["Proxy"].kind_of?(IO)
              @sock = @options["Proxy"]
            elsif @options["Proxy"].kind_of?(OpenSSL::SSL::SSLSocket)
              @sock = @options["Proxy"]
            else
              raise "Error: Proxy must be an instance of Net::Telnet or IO."
            end
          else
            message = "Trying " + @options["Host"] + "...\n"
            yield(message) if block_given?
            @log.write(message) if @options.has_key?("Output_log")
            @dumplog.log_dump('#', message) if @options.has_key?("Dump_log")

            begin
              if @options["Timeout"] == false
                @sock = TCPSocket.open(@options["Host"], @options["Port"])
              else
                timeout(@options["Timeout"]) do
                  @sock = TCPSocket.open(@options["Host"], @options["Port"])
                end
              end
            rescue TimeoutError
              raise TimeoutError, "timed out while opening a connection to the host"
            rescue
              @log.write($ERROR_INFO.to_s + "\n") if @options.has_key?("Output_log")
              @dumplog.log_dump('#', $ERROR_INFO.to_s + "\n") if @options.has_key?("Dump_log")
              raise
            end
            @sock.sync = true
            @sock.binmode

            message = "Connected to " + @options["Host"] + ".\n"
            yield(message) if block_given?
            @log.write(message) if @options.has_key?("Output_log")
            @dumplog.log_dump('#', message) if @options.has_key?("Dump_log")
          end

          super(@sock)
        end # initialize
    end
end

def telnet_check(options, port)
    begin
        # Set the command hash to print the configuration
        command_1 = { "String" => "system ver", "Match" => /returned/im }
        command_2 = { "String" => "conf print //", "Match" => /returned/im }
        # Open session and login
        session = Net::Telnet::new("Host" => options.ip, "Port" => port)

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
        return "Passed: #{model} #{hardware_rev}, #{firmware}, #{serial}"
    rescue SystemCallError => sce
        if sce.message.match(/connection refused/im)
            return "Failed: Connection Refused"
        else
            return sce.message
        end
    rescue Timeout::Error
        return "Failed: Connection Timeout"
    end
end

def sec_telnet(options)
    begin
        command_1 = { "String" => "system ver", "Match" => /returned/im }
        command_2 = { "String" => "conf print //", "Match" => /returned/im }
        socket = nil
        timeout(5) { socket = TCPSocket.new(options.ip, options.telnets) }
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
            return "Failed: Connection Refused"
        else
            return sce.message
        end
    rescue Timeout::Error
        return "Failed: Connection Timeout"
    end
end

def web_check(options, url)
    begin
        # ID tags so we can call by name and not by row number further down.
        id = { :firmware => 0, :model => 1, :hardware => 2, :serial => 3, :physical => 4, :broadband_type => 5, :broadband_stat => 6,
               :broadband_ip => 7, :subnet => 8, :mac => 9, :gateway => 10, :dns => 11, :uptime => 12 }

        agent = WWW::Mechanize.new
        agent.open_timeout = 10
        login_page = agent.get(url)

        # Set login information and Failed: Connection Refusedeate the MD5 hash
        login_page.forms[0].user_name = options.username
        pwmask, auth_key = "", ""
        login_page.forms[0].fields.each { |t| pwmask = t.name if t.name.match(/passwordmask_\d+/); auth_key = t.value if t.name.match(/auth_key/) }
        login_page.forms[0]["#{pwmask}"] = options.password
        login_page.forms[0].md5_pass = Digest::MD5.hexdigest("#{options.password}#{auth_key}")
        login_page.forms[0].mimic_button_field = "submit_button_login_submit%3a+.."
        agent.submit(login_page.forms[0])

        # Success check - make sure we have a logout option
        return "Failed: Login Failed" unless agent.current_page.parser.text.match(/logout/im)

        # Get to System Information
        agent.current_page.forms[0].mimic_button_field = "sidebar: actiontec_topbar_status.."
        agent.submit(agent.current_page.forms[0])
        # Get System Information data
        info = agent.current_page.parser.xpath('//tr/td[@class="GRID_NO_LEFT"]')

        # Log out
        agent.current_page.forms[0].mimic_button_field = "logout: ..."
        agent.submit(agent.current_page.forms[0])

        return "#{info[id[:model]].content} #{info[id[:hardware]].content}, #{info[id[:firmware]].content}, #{info[id[:serial]].content}"
    rescue Timeout::Error
        return "Failed: Connection Timeout"
    rescue SystemCallError => sce
        if sce.message.match(/connection refused/im)
            return "Failed: Connection Refused"
        else
            return sce.message
        end
    end
end

def udp_trace(options)
    tracer = `traceroute -n -U #{options.ip}`.split("\n")
    return "Failed: Connection Refused" if tracer.last.include?("* * *")
    return "Passed"
end

def buildurl(protocol, ip, port)
    return "#{protocol}://#{ip}:#{port}"
end

begin
    threads = []
    tags = {}
    results = {}
    opts.parse!(ARGV)
    dut = IP.new(options.dut_ip)
    if options.short
        tags['primary_http'] = "-primary_http"
        tags['secondary_http'] = "-secondary_http"
        tags['primary_https'] = "-primary_https"
        tags['secondary_https'] = "-secondary_https"
        tags['telnet'] = "-telnet"
        tags['secondary_telnet'] = "-secondary_telnet"
        tags['secure_telnet'] = "-secure_telnet"
        tags['icmp'] = "-wan_icmp"
        tags['trace'] = "-wan_udp_traceroute"
    else
        tags['primary_http'] = "Primary HTTP:"
        tags['secondary_http'] = "Secondary HTTP:"
        tags['primary_https'] = "Primary HTTPS:"
        tags['secondary_https'] = "Secondary HTTPS:"
        tags['telnet'] = "Primary Telnet:"
        tags['secondary_telnet'] = "Secondary Telnet:"
        tags['secure_telnet'] = "Secure Telnet (SSL):"
        tags['icmp'] = "WAN ICMP:"
        tags['trace'] = "WAN UDP Traceroute:"
    end

    raise "Invalid IP address given" unless dut.is_valid
    options.ip = dut.ip
    if options.all
        options.http = options.all.split(',')[0]
        options.https = options.all.split(',')[1]
        options.shttp = options.all.split(',')[2]
        options.shttps = options.all.split(',')[3]
        options.telnet = options.all.split(',')[4]
        options.stelnet = options.all.split(',')[5]
        options.telnets = options.all.split(',')[6]
    end

    # Primary HTTP thread
    threads << Thread.new do
        results['primary_http'] = "#{tags['primary_http']} #{web_check(options, buildurl("http", options.ip, options.http))}" if options.http
        results['primary_https'] = "#{tags['primary_https']} #{web_check(options, buildurl("https", options.ip, options.https))}" if options.https
    end
    # Secondary HTTP thread
    threads << Thread.new do
        results['secondary_http'] = "#{tags['secondary_http']} #{web_check(options, buildurl("http", options.ip, options.shttp))}" if options.shttp
        results['secondary_https'] = "#{tags['secondary_https']} #{web_check(options, buildurl("https", options.ip, options.shttps))}" if options.shttps
    end
    # Normal telnet thread
    threads << Thread.new do
        results['telnet'] = "#{tags['telnet']} #{telnet_check(options, options.telnet)}" if options.telnet
        results['secondary_telnet'] = "#{tags['secondary_telnet']} #{telnet_check(options, options.stelnet)}" if options.stelnet
    end
    # Secure telnet thread
    threads << Thread.new do
        results['secure_telnet'] = "#{tags['secure_telnet']} #{sec_telnet(options)}" if options.telnets
    end
    # Traceroute/Ping thread
    threads << Thread.new do
        if options.icmp
            results['trace'] = "#{tags['trace']} #{udp_trace(options)}" if options.udptrace
            ICMP::ping(options.ip) ? results['icmp'] = "#{tags['icmp']} Passed" : results['icmp'] = "#{tags['icmp']} Failed"
        end
    end
    threads.each {|t| t.join}
    # Since testing is order specific, we have to do this part the long way
    puts results['primary_http']
    puts results['secondary_http']
    puts results['primary_https']
    puts results['secondary_https']
    puts results['telnet']
    puts results['secondary_telnet']
    puts results['secure_telnet']
    puts results['icmp']
    puts results['trace']
end