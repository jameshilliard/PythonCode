#!/usr/bin/env ruby
# == Copyright
# (c) 2010 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

require 'socket'
SIOCGIFHWADDR = 0x8927
SIOCGIFADDR = 0x8915

# Module support functions
module IPUtil
	private
    # gets an ip address from a linux interface and returns it
    def ip_by_interface(interface)
        sock = UDPSocket.new
        buf = [interface, ""].pack('a16h16')
        sock.ioctl(SIOCGIFADDR, buf)
        sock.close
        buf[20..24].unpack("CCCC").join(".")
    end
    module_function :ip_by_interface

    # Gets an interface by ip address from a linux system
    def interface_by_ip(ip)
        sock = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM,0)
        buf = [ip, ""].pack('a16h16')
        sock.ioctl(SIOCGIFHWADDR, buf)
        sock.close
        buf[18..24].unpack("H2H2H2H2H2H2").join(":")
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
		return FALSE if ip==nil
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
		if ip_int(ip) > 2**32-1 || ip_int(ip) <= 0
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
        @network = ""
		holder = ""
        ip.match(/eth/i) ? ip = IPUtil::ip_by_interface(ip) : ip
		unless ip == nil
			# parse a string if one got passed into sections
			@ip = ip.slice!(/\b(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\b/) if ip.match(/\b(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\b/)

			@protocol = ip.slice!(/\w+?:\/\//) if ip.match(/\w+?:\/\//)

            if ip.match(/[\/|,|\.](?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}/)
                @netmask = ip.slice!(/[\/|,|\.](?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}/).gsub(/[^0-9\.]|\A\./, '')
                @bitmask = IPUtil::mask_to_bits(IPUtil::ip_int(@netmask)) unless @netmask.empty?
            elsif ip.match(/[\/|,|\.](?:[0-2][0-9]|3[0-2]|[0-9])/)
				holder = ip.slice!(/[\/|,|\.](?:[0-2][0-9]|3[0-2]|[0-9])/).delete('^[0-9]')
				@bitmask = holder.to_i if holder.to_i > 0
				# Convert the mask to a string here
				@netmask = IPUtil::ip_string(IPUtil::bits_to_mask(@bitmask)) if @bitmask > 0
            end

			@port = ip.slice!(/:(?:6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]\d{4}|\d{1,4})\z/) if ip.match(/:(?:6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]\d{4}|\d{1,4})\z/)
			
			# Clean Up
			@port.delete!(':') unless @port.empty?
			@protocol.delete!('://') unless @protocol.empty?
            
            # Build URL
            @protocol == "" ? @url << "http://" : @url << "#{@protocol}://"
            @ip == "" ? @url << "192.168.1.1" : @url << "#{@ip}"
            @port == "" ? @url << ":80" : @url << ":#{@port}"
            @network = "#{IPUtil::ip_string(IPUtil::ip_int(@ip) & IPUtil::ip_int(@netmask))}" unless @netmask.empty? unless @ip.empty?
            @broadcast = "#{IPUtil::ip_string(IPUtil::ip_int(@network) | ~IPUtil::ip_int(@netmask))}" unless @netmask.empty? unless @network.empty?
		end
	end
	
	def is_valid?
		return FALSE if @ip == ""
		if IPUtil::ip_int(@ip) > 2**32-1 || IPUtil::ip_int(@ip) <= 0
			return FALSE
		else
			return TRUE
		end
	end
    alias valid? is_valid?

	def is_private?
		if (IPUtil::ip_int("10.0.0.0")..IPUtil::ip_int("10.255.255.255")) === IPUtil::ip_int(@ip)
			return TRUE
		elsif (IPUtil::ip_int("172.16.0.0")..IPUtil::ip_int("172.31.255.255")) === IPUtil::ip_int(@ip)
			return TRUE
		elsif (IPUtil::ip_int("192.168.0.0")..IPUtil::ip_int("192.168.255.255")) === IPUtil::ip_int(@ip)
			return TRUE
		end
		return FALSE
	end
    alias private? is_private?
    
	def ip_class
		ipclass = ''
		ipclass = 'A' if (IPUtil::ip_int("10.0.0.0")..IPUtil::ip_int("127.255.255.255")) === IPUtil::ip_int(@ip)
		ipclass = 'B' if (IPUtil::ip_int("128.0.0.0")..IPUtil::ip_int("191.255.255.255")) === IPUtil::ip_int(@ip)
		ipclass = 'C' if (IPUtil::ip_int("192.0.0.0")..IPUtil::ip_int("223.255.255.255")) === IPUtil::ip_int(@ip)
		ipclass = 'D' if (IPUtil::ip_int("224.0.0.0")..IPUtil::ip_int("239.255.255.255")) === IPUtil::ip_int(@ip)
		ipclass = 'E' if (IPUtil::ip_int("240.0.0.0")..IPUtil::ip_int("255.255.255.255")) === IPUtil::ip_int(@ip)
		ipclass
	end

	def to_i
		ip_int = 0
		octets = @ip.split('.')
		(0..3).each do |x|
			octet = octets.pop.to_i
			octet = octet << 8*x
			ip_int = ip_int | octet
		end
		ip_int
	end
end

class String
    def valid_ip?
		return FALSE if self.empty?
		if IPUtil::ip_int(self) > 2**32-1 || IPUtil::ip_int(self) <= 0
			return FALSE
		else
			return TRUE
		end
	end

    def to_ip
        IP.new(self)
    end

    def ip
        temp = self.dup
        IP.new(temp).ip
    end

    def netmask
        temp = self.dup
        IP.new(temp).netmask
    end
    def bitmask
        temp = self.dup
        IP.new(temp).bitmask
    end
    def port
        temp = self.dup
        IP.new(temp).port
    end
end