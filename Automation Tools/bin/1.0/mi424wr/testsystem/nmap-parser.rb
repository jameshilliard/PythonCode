# Ruby library for parsing Nmap's XML output
#
# http://rubynmap.sourceforge.net
#
# Author: Kris Katterjohn <katterjohn@gmail.com>
# Modified by: Chris Born <cborn@actiontec.com> for use with
# Actiontec Electronics specific devices and testing platform. 
#
# Copyright (c) 2007-2009 Kris Katterjohn
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# $Id: parser.rb 129 2009-02-08 17:14:39Z kjak $
# https://rubynmap.svn.sourceforge.net/svnroot/rubynmap

require 'rexml/document'

begin
	require 'open3'
rescue LoadError
	# We'll just use IO.popen()
end

installed = FALSE

begin
    require 'testsystem/alt_sshcli'
    $ALT_SSHCLI = TRUE
    puts "Using alternative SSH system."
rescue
    puts "Giving up. Going to use sshcli.pl."
    $ALT_SSHCLI = FALSE
end

# Just holds the big Parser class.
module Nmap
end

=begin rdoc

== What Is This Library For?

This library provides a Ruby interface to Nmap's scan data.  It can run Nmap
and parse its XML output directly from the scan, parse a file containing the
XML data from a separate scan, parse a String of XML data from a scan, or parse
XML data from an object via its read() method.  This information is presented
in an easy-to-use and intuitive fashion for storage and manipulation.

Keep in mind that this is not just some Ruby port of Anthony Persaud's Perl
Nmap::Parser!  There are more classes, many different methods, and blocks are
extensively available.

The Nmap Security Scanner is an awesome program written and maintained by
Fyodor <fyodor@insecure.org>.  Its main function is port scanning, but it also
has service and operating system detection, its own scripting engine and a
whole lot more.  One of its many available output formats is XML, which allows
machines to handle all of the information instead of us slowly sifting through
tons of output.

== Conventions

Depending on the data type, unavailable information is presented differently:

  - Arrays are empty
  - Non-arrays are nil, unless it's a method that returns the size of one of
    the previously mentioned empty arrays.  In this case they still return the
    size (which would be 0).

All information available as arrays are presented via methods.  These methods
not only return the array, but they also yield each element to a block if one
is given.

== Module Hierarchy

  Nmap::Parser
  |
  + Session           <- Scan session information
  |
  + Host              <- General host information
    |
    + ExtraPorts      <- Ports consolidated in an "ignored" state
    |
    + Port            <- General port information
    | |
    | + Service       <- Port Service information
    |
    + Script          <- NSE Script information (both host and port)
    |
    + Times           <- Timimg information (round-trip time, etc)
    |
    + Traceroute      <- General Traceroute information
    | |
    | + Hop           <- Individual Hop information
    |
    + OS              <- OS Detection information
      |
      + OSClass       <- OS Class information
      |
      + OSMatch       <- OS Match information

== Parsing XML Data Already Available

	require 'nmap/parser'

	parser = Nmap::Parser.parsestring(xml) # String of XML
	parser = Nmap::Parser.new(xml) # Same thing

== Reading and Parsing from a File

	require 'nmap/parser'

	parser = Nmap::Parser.parsefile("log.xml")

== Reading and Parsing from an Object

This method can read from any object that responds to a read() method that
returns a String.

	require 'nmap/parser'

	parser = Nmap::Parser.parseread($stdin)

== Scanning and Parsing

This is the only Parser method that requires Nmap to be available.

	require 'nmap/parser'

	parser = Nmap::Parser.parsescan("sudo nmap", "-sVC 192.168.1.0/24")

== Actually Doing Something

After printing a little session information, this example will cycle
through all of the up hosts, printing state and service information on
the open TCP ports.  See the examples directory that comes with this
library for more examples.

	puts "Nmap args: #{parser.session.scan_args}"
	puts "Runtime: #{parser.session.scan_time} seconds"
	puts

	parser.hosts("up") do |host|
		puts "#{host.addr} is up:"
		puts

		host.tcp_ports("open") do |port|
			srv = port.service

			puts "Port ##{port.num}/tcp is open (#{port.reason})"
			puts "\tService: #{srv.name}" if srv.name
			puts "\tProduct: #{srv.product}" if srv.product
			puts "\tVersion: #{srv.version}" if srv.version
			puts
		end

		puts
	end
=end
class Nmap::Parser
	# Holds the raw XML output from Nmap
	attr_reader :rawxml
	# Session object for this scan
	attr_reader :session

	# Read and parse XML from the +obj+.  +obj+ can be any object type
	# that responds to a read() method that returns a String.  IO and
	# File are just a couple of examples.
	#
	# Returns a new Nmap::Parser object, and passes it to a block if
	# one is given
	def self.parseread(obj) # :yields: parser
		if not obj.respond_to?("read")
			raise "Passed object must respond to read()"
		end

		r = obj.read

		if not r.is_a?(String)
			raise "Passed object's read() must return a String (got #{r.class})"
		end

		new(r) { |p| yield p if block_given? }
	end

	# Read and parse the contents of the Nmap XML file +filename+
	#
	# Returns a new Nmap::Parser object, and passes it to a block if
	# one is given
	def self.parsefile(filename) # :yields: parser
		begin
			File.open(filename) { |f|
				parseread(f) { |p| yield p if block_given? }
			}
		rescue
			raise "Error parsing \"#{filename}\": #{$!}"
		end
	end

	# Read and parse the String of XML.  Currently an alias for new().
	#
	# Returns a new Nmap::Parser object, and passes it to a block if
	# one is given
	def self.parsestring(str) # :yields: parser
		new(str) { |p| yield p if block_given? }
	end

	# Runs "+nmap+ -d +args+ +targets+"; returns a new Nmap::Parser object,
	# and passes it to a block if one is given.
	#
	# +nmap+ is here to allow you to do things like:
	#
	# parser = Nmap::Parser.parsescan("sudo ./nmap", ....)
	#
	# and still make it easy for me to inject the options for XML
	# output and debugging.
	#
	# +args+ can't contain arguments like -oA, -oX, etc. as these can
	# interfere with Parser's processing.  If you need that other output,
	# just run Nmap yourself and pass -oX output to Parser via new.  Or,
	# you can use rawxml to grab the whole XML (as a String) and save it
	# to a different file.
	#
	# +targets+ is an array of targets which will be split and appended to
	# the command.  It's optional and only for convenience because you can
	# put any targets you want scanned in +args+.
	def self.parsescan(nmap, args, targets = []) # :yields: parser
		
        raise "Output option (-o*) passed to parsescan()" if args =~ /[^-]-o|^-o/

		# Enable debugging, give us our XML output, pass args
        if nmap.match(/ssh/i)
            if $ALT_SSHCLI
                rf = SSHCLI_Tools::parse_sshcli(nmap)
                rs = RemoteSystem.new(rf['host'], rf['user'], rf['pass'])
                rs_data = rs.command("nmap -d -oX - #{args.strip}")
                rs.close
                p = nil
                p = parsestring(rs_data)
                raise "Unable to parse XML string from remote system data." if p.nil?
                yield p if block_given?
                return p
            end
            command = "#{nmap} \"nmap -d -oX - #{args.strip}\""
        else
            command = "#{nmap} -d -oX - #{args.strip}"
        end
        command += targets.join(" ") if targets.any?
        p = nil

        begin
            # First try popen3() if it loaded successfully..
            Open3.popen3(command) do |sin, sout, serr|
                p = parseread(sout)
            end
        rescue NameError
            # ..but fall back to popen() if not
            IO.popen(command) do |io|
                p = parseread(io)
            end
        end
        yield p if block_given?
        return p
	end

	# Returns an array of Host objects, and passes them each to a block if
	# one is given
	#
	# If an argument is given, only hosts matching +status+ are given
	def hosts(status = "") # :yields: host
		shosts = []

		@hosts.each do |host|
			if status.empty? or host.status == status
				shosts << host
				yield host if block_given?
			end
		end

		shosts
	end

	# Returns a Host object for the host with the specified IP address
	# or hostname +hostip+
	def host(hostip)
		@hosts.find do |host|
			host.addr == hostip or host.hostname == hostip
		end
	end

	alias get_host host

	# Deletes host with the specified IP address or hostname +hostip+
	#
	# Note: From inside of a block given to a method like hosts() or
	# get_ips(), calling this method on a host passed to the block may
	# lead to adverse effects:
	#
	# parser.hosts { |h| puts h.addr; parser.del_host(h) } # Don't do this!
	def del_host(hostip)
		@hosts.delete_if do |host|
			host.addr == hostip or host.hostname == hostip
		end
	end

	alias delete_host del_host

	# Returns an array of IPs scanned, and passes them each to a
	# block if one is given
	#
	# If an argument is given, only hosts matching +status+ are given
	def get_ips(status = "") # :yields: host.addr
		ips = hosts(status).map { |h| h.addr }

		ips.each { |ip| yield host.addr } if block_given?

		ips
	end

	# This operator compares the rawxml members
	def ==(parser)
		@rawxml == parser.rawxml
	end

	private

	def initialize(xml) # :yields: parser
		if not xml.is_a?(String)
			raise "Must be passed a String (got #{xml.class})"
		end

		parse(xml)

		yield self if block_given?
	end

	def parse(xml)
		@rawxml = xml

		begin
			root = REXML::Document.new(xml).root
		rescue
			raise "Error parsing XML: #{$!}"
		end
        
		raise "Error in XML data" if root.nil?

		@session = Session.new(root)

		@hosts = root.elements.collect('host') do |host|
			Host.new(host)
		end
	end
end

# This holds session information, such as runtime, Nmap's arguments,
# and verbosity/debugging
class Nmap::Parser::Session
	# Holds the command run to initiate the scan
	attr_reader :scan_args
	# The Nmap version number used to scan
	attr_reader :nmap_version
	# XML version of Nmap's output
	attr_reader :xml_version
	# Starting time
	attr_reader :start_str, :start_time
	# Ending time
	attr_reader :stop_str, :stop_time
	# Total scan time in seconds (can differ from stop_time - start_time)
	attr_reader :scan_time
	# Amount of verbosity (-v) used while scanning
	attr_reader :verbose
	# Amount of debugging (-d) used while scanning
	attr_reader :debug

	alias verbosity verbose
	alias debugging debug

	# Returns the total number of services that were scanned or, if an
	# argument is given, returns the number of services scanned for +type+
	# (e.g. "syn")
	def numservices(type = "")
		total = 0

		@scaninfo.each do |info|
			if type.empty?
				total += info.numservices
			elsif info.type == type
				return info.numservices
			end
		end

		total
	end

	# Returns the protocol associated with the specified scan +type+
	# (e.g. "tcp" for type "syn")
	def scan_type_proto(type)
		@scaninfo.each do |info|
			return info.proto if info.type == type
		end

		nil
	end

	# Returns an array of all the scan types performed, and passes them
	# each to a block if one if given
	def scan_types() # :yields: scantype
		types = []

		@scaninfo.each do |info|
			types << info.type
			yield info.type if block_given?
		end

		types
	end

	# Returns the scanflags associated with the specified scan +type+
	# (e.g. "PSHACK" for type "ack")
	def scanflags(type)
		@scaninfo.each do |info|
			return info.scanflags if info.type == type
		end

		nil
	end

	private

	def initialize(root)
		parse(root)
	end

	def parse(root)
		@scan_args = root.attributes['args']

		@nmap_version = root.attributes['version']

		@xml_version = root.attributes['xmloutputversion'].to_f

		@start_str = root.attributes['startstr']
		@start_time = root.attributes['start'].to_i

		@stop_str = root.elements['runstats/finished'].attributes['timestr']
		@stop_time = root.elements['runstats/finished'].attributes['time'].to_i

		@scan_time = root.elements['runstats/finished'].attributes['elapsed'].to_f

		@verbose = root.elements['verbose'].attributes['level'].to_i
		@debug = root.elements['debugging'].attributes['level'].to_i

		@scaninfo = root.elements.collect('scaninfo') do |info|
			ScanInfo.new(info)
		end
	end
end

class Nmap::Parser::Session::ScanInfo # :nodoc: all
	attr_reader :type, :scanflags, :proto, :numservices

	private

	def initialize(info)
		parse(info)
	end

	def parse(info)
		@type = info.attributes['type']
		@scanflags = info.attributes['scanflags']
		@proto = info.attributes['protocol']
		@numservices = info.attributes['numservices'].to_i
	end
end

# This holds all of the information about a target host.
#
# Status, IP/MAC addresses, hostnames, all that.  Port information is
# available in this class; either accessed through here or directly
# from a Port object.
class Nmap::Parser::Host
	# The status of the host, typically "up" or "down"
	attr_reader :status
	# The reason for the status
	attr_reader :reason
	# The IPv4 address
	attr_reader :ip4_addr
	# The IPv6 address
	attr_reader :ip6_addr
	# The MAC address
	attr_reader :mac_addr
	# The MAC vendor
	attr_reader :mac_vendor
	# OS object holding Operating System information
	attr_reader :os
	# The number of "weird responses"
	attr_reader :smurf
	# TCP Sequence Number information
	attr_reader :tcpsequence_index, :tcpsequence_class
	# TCP Sequence Number information
	attr_reader :tcpsequence_values, :tcpsequence_difficulty
	# IPID Sequence Number information
	attr_reader :ipidsequence_class, :ipidsequence_values
	# TCP Timestamp Sequence Number information
	attr_reader :tcptssequence_class, :tcptssequence_values
	# Uptime information
	attr_reader :uptime_seconds, :uptime_lastboot
	# Traceroute object
	attr_reader :traceroute
	# Network distance (not necessarily the same as from traceroute)
	attr_reader :distance
	# Times object holding timing information
	attr_reader :times
	# Host start and end times
	attr_reader :starttime, :endtime

	alias ipv4_addr ip4_addr
	alias ipv6_addr ip6_addr

	# Returns the IPv4 or IPv6 address of host
	def addr
		@ip4_addr or @ip6_addr
	end

	# Returns an array containing all of the hostnames for this host,
	# and passes them each to a block if one is given
	def all_hostnames
		@hostnames.each { |hostname| yield hostname } if block_given?

		@hostnames
	end

	alias hostnames all_hostnames

	# Returns the first hostname, or nil if unavailable
	def hostname
		@hostnames[0]
	end

	# Returns an array of ExtraPorts objects, and passes them each to a
	# block if one if given
	def extraports # :yields: extraports
		@extraports.each { |e| yield e } if block_given?

		@extraports
	end

	# Returns the Port object for the TCP port +portnum+, and passes it to
	# a block if one is given
	def tcp_port(portnum) # :yields: port
		port = @tcpPorts[portnum.to_i]
		yield port if block_given?
		port
	end

	# Returns an array of Port objects for each TCP port, and passes them
	# each to a block if one is given
	#
	# If an argument is given, only ports matching +state+ are given.  Note
	# that combinations like "open|filtered" will get matched by "open" and
	# "filtered"
	def tcp_ports(state = "")
		list = @tcpPorts.values.find_all { |port|
			state.empty? or
			port.state == state or
			port.state.split(/\|/).include?(state)
		}.sort

		list.each { |port| yield port } if block_given?

		list
	end

	# Returns an array of TCP port numbers, and passes them each to a block
	# if one given
	#
	# If an argument is given, only ports matching +state+ are given.
	def tcp_port_list(state = "")
		list = tcp_ports(state).map { |p| p.num }
		list.each { |port| yield port } if block_given?
		list
	end

	# Returns the state reason of TCP port +portnum+
	def tcp_reason(portnum)
		port = tcp_port(portnum)
		return nil if port.nil?
		port.reason
	end

	# Returns the Script object for the script +name+ run against the
	# TCP port +portnum+
	def tcp_script(portnum, name)
		port = tcp_port(portnum)
		return nil if port.nil?
		port.script(name)
	end

	# Returns an array of Script objects for each script run on the
	# TCP port +portnum+, and passes them each to a block if given
	def tcp_scripts(portnum) # :yields: script
		port = tcp_port(portnum)
		return nil if port.nil?
		port.scripts { |s| yield s } if block_given?
		port.scripts
	end

	# Returns the output of the script +name+ on the TCP port +portnum+
	def tcp_script_output(portnum, name)
		port = tcp_port(portnum)
		return nil if port.nil?
		port.script_output(name)
	end

	# Returns a Port::Service object for TCP port +portnum+
	def tcp_service(portnum)
		port = tcp_port(portnum)
		return nil if port.nil?
		port.service
	end

	# Returns the state of TCP port +portnum+
	def tcp_state(portnum)
		port = tcp_port(portnum)
		return nil if port.nil?
		port.state
	end

	# Returns the Port object for the UDP port +portnum+, and passes it to
	# a block if one is given
	def udp_port(portnum) # :yields: port
		port = @udpPorts[portnum.to_i]
		yield port if block_given?
		port
	end

	# Returns an array of Port objects for each UDP port, and passes them
	# each to a block if one is given
	#
	# If an argument is given, only ports matching +state+ are given.  Note
	# that combinations like "open|filtered" will get matched by "open" and
	# "filtered"
	def udp_ports(state = "")
		list = @udpPorts.values.find_all { |port|
			state.empty? or
			port.state == state or
			port.state.split(/\|/).include?(state)
		}.sort

		list.each { |port| yield port } if block_given?

		list
	end

	# Returns an array of UDP port numbers, and passes them each to a block
	# if one is given
	#
	# If an argument is given, only ports matching +state+ are given.
	def udp_port_list(state = "")
		list = udp_ports(state).map { |p| p.num }
		list.each { |port| yield port } if block_given?
		list
	end

	# Returns the state reason of UDP port +portnum+
	def udp_reason(portnum)
		port = udp_port(portnum)
		return nil if port.nil?
		port.reason
	end

	# Returns the Script object for the script +name+ run against the
	# UDP port +portnum+
	def udp_script(portnum, name)
		port = udp_port(portnum)
		return nil if port.nil?
		port.script(name)
	end

	# Returns an array of Script objects for each script run on the
	# UDP port +portnum+, and passes them each to a block if given
	def udp_scripts(portnum) # :yields: script
		port = udp_port(portnum)
		return nil if port.nil?
		port.scripts { |s| yield s } if block_given?
		port.scripts
	end

	# Returns the output of the script +name+ on the UDP port +portnum+
	def udp_script_output(portnum, name)
		port = udp_port(portnum)
		return nil if port.nil?
		port.script_output(name)
	end

	# Returns a Port::Service object for UDP port +portnum+
	def udp_service(portnum)
		port = udp_port(portnum)
		return nil if port.nil?
		port.service
	end

	# Returns the state of UDP port +portnum+
	def udp_state(portnum)
		port = udp_port(portnum)
		return nil if port.nil?
		port.state
	end

	# Returns the Port object for the IP protocol +protonum+, and passes it
	# to a block if one is given
	def ip_proto(protonum) # :yields: proto
		proto = @ipProtos[protonum.to_i]
		yield proto if block_given?
		proto
	end

	# Returns an array of Port objects for each IP protocol, and passes
	# them each to a block if one is given
	#
	# If an argument is given, only protocols matching +state+ are given.
	# Note that combinations like "open|filtered" will get matched by
	# "open" and "filtered"
	def ip_protos(state = "")
		list = @ipProtos.values.find_all { |proto|
			state.empty? or
			proto.state == state or
			proto.state.split(/\|/).include?(state)
		}.sort

		list.each { |proto| yield proto } if block_given?

		list
	end

	# Returns an array of IP protocol numbers, and passes them each to a
	# block if one given
	#
	# If an argument is given, only protocols matching +state+ are given.
	def ip_proto_list(state = "")
		list = ip_protos(state).map { |p| p.num }
		list.each { |proto| yield proto } if block_given?
		list
	end

	# Returns the state reason of IP protocol +protonum+
	def ip_reason(protonum)
		proto = ip_proto(protonum)
		return nil if proto.nil?
		proto.reason
	end

	# Returns a Port::Service object for IP protocol +protonum+
	def ip_service(protonum)
		proto = ip_proto(protonum)
		return nil if proto.nil?
		proto.service
	end

	# Returns the state of IP protocol +protonum+
	def ip_state(protonum)
		proto = ip_proto(protonum)
		return nil if proto.nil?
		proto.state
	end

	# Returns the Script object for the specified host script +name+
	def script(name)
		@scripts.find { |script| script.id == name }
	end

	# Returns an array of Script objects for each host script run, and
	# passes them each to a block if given
	def scripts
		@scripts.each { |script| yield script } if block_given?

		@scripts
	end

	# Returns the output of the specified host script +name+
	def script_output(name)
		@scripts.each do |script|
			return script.output if script.id == name
		end

		nil
	end

	private

	def initialize(hostinfo)
		parse(hostinfo)
	end

	def parseAddr(elem)
		case elem.attributes['addrtype']
		when "mac"
			@mac_addr = elem.attributes['addr']
			@mac_vendor = elem.attributes['vendor']
		when "ipv4"
			@ip4_addr = elem.attributes['addr']
		when "ipv6"
			@ip6_addr = elem.attributes['addr']
		end
	end

	def parseHostnames(elem)
		@hostnames = []

		return nil if elem.nil?

		@hostnames = elem.elements.collect('hostname') do |name|
			name.attributes['name']
		end
	end

	def parsePorts(ports)
		@tcpPorts = {}
		@udpPorts = {}
		@ipProtos = {}

		return nil if ports.nil?

		ports.each_element('port') do |port|
			num = port.attributes['portid'].to_i
			proto = port.attributes['protocol']

			if proto == "tcp"
				@tcpPorts[num] = Port.new(port)
			elsif proto == "udp"
				@udpPorts[num] = Port.new(port)
			elsif proto == "ip"
				@ipProtos[num] = Port.new(port)
			end
		end
	end

	def parseExtraPorts(ports)
		@extraports = []

		return nil if ports.nil?

		@extraports = ports.elements.collect('extraports') do |e|
			ExtraPorts.new(e)
		end

		@extraports.sort!
	end

	def parseScripts(scriptlist)
		@scripts = []

		return nil if scriptlist.nil?

		@scripts = scriptlist.elements.collect('script') do |script|
			Script.new(script)
		end
	end

	def tcpseq(seq)
		return nil if seq.nil?

		@tcpsequence_index = seq.attributes['index']
		@tcpsequence_class = seq.attributes['class']
		@tcpsequence_values = seq.attributes['values']
		@tcpsequence_difficulty = seq.attributes['difficulty']
	end

	def ipidseq(seq)
		return nil if seq.nil?

		@ipidsequence_class = seq.attributes['class']
		@ipidsequence_values = seq.attributes['values']
	end

	def tcptsseq(seq)
		return nil if seq.nil?

		@tcptssequence_class = seq.attributes['class']
		@tcptssequence_values = seq.attributes['values']
	end

	def uptime(time)
		return nil if time.nil?

		@uptime_seconds = time.attributes['seconds'].to_i
		@uptime_lastboot = time.attributes['lastboot']
	end

	def parse(host)
		status = host.elements['status']

		@status = status.attributes['state']

		@reason = status.attributes['reason']

		@os = OS.new(host.elements['os'])

		host.each_element('address') do |elem|
			parseAddr(elem)
		end

		parseHostnames(host.elements['hostnames'])

		smurf = host.elements['smurf']
		@smurf = smurf.attributes['responses'] if smurf

		ports = host.elements['ports']

		parsePorts(ports)

		parseExtraPorts(ports)

		parseScripts(host.elements['hostscript'])

		if trace = host.elements['trace']
			@traceroute = Traceroute.new(trace)
		end

		tcpseq(host.elements['tcpsequence'])

		ipidseq(host.elements['ipidsequence'])

		tcptsseq(host.elements['tcptssequence'])

		uptime(host.elements['uptime'])

		distance = host.elements['distance']
		@distance = distance.attributes['value'].to_i if distance

		@times = Times.new(host.elements['times'])

		stime = host.attributes['starttime']
		@starttime = stime.to_i if stime

		etime = host.attributes['endtime']
		@endtime = etime.to_i if etime
	end
end

# This holds information on the time statistics for this host
class Nmap::Parser::Host::Times
	# Smoothed round-trip time
	attr_reader :srtt
	# Round-trip time variance / deviation
	attr_reader :rttvar
	# How long before giving up on a probe (timeout)
	attr_reader :to

	private

	def initialize(times)
		parse(times)
	end

	def parse(times)
		return nil if times.nil?

		@srtt = times.attributes['srtt'].to_i
		@rttvar = times.attributes['rttvar'].to_i
		@to = times.attributes['to'].to_i
	end
end

# This holds the information about an NSE script run against a host or port
class Nmap::Parser::Host::Script
	# NSE Script name
	attr_reader :id
	# NSE Script output
	attr_reader :output

	alias name id

	private

	def initialize(script)
		parse(script)
	end

	def parse(script)
		return nil if script.nil?

		@id = script.attributes['id']
		@output = script.attributes['output']
	end
end

# This holds the information about an individual port or protocol
class Nmap::Parser::Host::Port
	# Port number
	attr_reader :num
	# Service object for this port
	attr_reader :service
	# Port state ("open", "closed", "filtered", etc)
	attr_reader :state
	# Why the port is in the state
	attr_reader :reason
	# The host that responded, if different than the target
	attr_reader :reason_ip
	# TTL from the responding host
	attr_reader :reason_ttl

	# Returns the Script object with the specified +name+
	def script(name)
		@scripts.find { |script| script.id == name }
	end

	# Returns an array of Script objects associated with this port, and
	# passes them each to a block if one is given
	def scripts
		@scripts.each { |script| yield script } if block_given?

		@scripts
	end

	# Returns the output of the script +name+
	def script_output(name)
		@scripts.each do |script|
			return script.output if script.id == name
		end

		nil
	end

	# Compares port numbers
	def <=>(port)
		@num <=> port.num
	end

	private

	def initialize(portinfo)
		parse(portinfo)
	end

	def parse(port)
		@num = port.attributes['portid'].to_i

		state = port.elements['state']
		@state = state.attributes['state']
		@reason = state.attributes['reason']
		@reason_ttl = state.attributes['reason_ttl'].to_i
		@reason_ip = state.attributes['reason_ip']

		@service = Service.new(port)

		@scripts = port.elements.collect('script') do |script|
			Nmap::Parser::Host::Script.new(script)
		end
	end
end

# This holds the information about "extra ports": groups of ports which have
# the same state.
class Nmap::Parser::Host::ExtraPorts
	# Total number of ports in this state
	attr_reader :count
	# What state the ports are in
	attr_reader :state

	# Returns an array of arrays, each of which are in the form of:
	#
	# [ <port count>, reason ]
	#
	# for each set of reasons, and passes them each to a block if one is
	# given
	def reasons
		@reasons.each { |reason| yield reason } if block_given?

		@reasons
	end

	# Compares the port counts
	def <=>(extraports)
		@count <=> extraports.count
	end

	private

	def initialize(extraports)
		parse(extraports)
	end

	def parse(extraports)
		@count = extraports.attributes['count'].to_i
		@state = extraports.attributes['state']

		@reasons = []

		extraports.each_element('extrareasons') do |extra|
			ecount = extra.attributes['count'].to_i
			ereason = extra.attributes['reason']
			@reasons << [ ecount, ereason ]
		end
	end
end

# This holds information on a traceroute, such as the port and protocol used
# and an array of responsive hops
class Nmap::Parser::Host::Traceroute
	# The port used during traceroute
	attr_reader :port
	# The protocol used during traceroute
	attr_reader :proto

	# Returns the Hop object for the given TTL
	def hop(ttl)
		@hops.find { |hop| hop.ttl == ttl.to_i }
	end

	# Returns an array of Hop objects, which are each a responsive hop,
	# and passes them each to a block if one if given.
	def hops
		@hops.each { |hop| yield hop } if block_given?

		@hops
	end

	private

	def initialize(trace)
		parse(trace)
	end

	def parse(trace)
		@port = trace.attributes['port'].to_i
		@proto = trace.attributes['proto']

		@hops = trace.each_element('hop') do |hop|
			Hop.new(hop)
		end
	end
end

# This holds information on an individual traceroute hop
class Nmap::Parser::Host::Traceroute::Hop
	# How many hops away the host is
	attr_reader :ttl
	# The round-trip time of the host
	attr_reader :rtt
	# The IP address of the host
	attr_reader :addr
	# The hostname of the host
	attr_reader :hostname

	alias host hostname 
	alias ipaddr addr

	# Compares the TTLs
	def <=>(hop)
		@ttl <=> hop.ttl
	end

	private

	def initialize(hop)
		parse(hop)
	end

	def parse(hop)
		@ttl = hop.attributes['ttl'].to_i
		@rtt = hop.attributes['rtt'].to_f
		@addr = hop.attributes['ipaddr']
		@hostname = hop.attributes['host']
	end
end

# This holds the service information for a port
class Nmap::Parser::Host::Port::Service
	# The name of the service
	attr_reader :name
	# Vendor name
	attr_reader :product
	# Version number
	attr_reader :version
	# How this information was obtained, such as "table" or "probed"
	attr_reader :method
	# Service owner
	attr_reader :owner
	# Any tunnelling used, like "ssl"
	attr_reader :tunnel
	# RPC program number
	attr_reader :rpcnum
	# Range of RPC version numbers
	attr_reader :lowver, :highver
	# How confident the version detection is
	attr_reader :confidence
	# Protocol, such as "rpc"
	attr_reader :proto
	# Extra misc. information about the service
	attr_reader :extra
	# The type of device the service is running on
	attr_reader :devicetype
	# The OS the service is running on
	attr_reader :ostype
	# The service fingerprint
	attr_reader :fingerprint

	alias extrainfo extra

	private

	def initialize(port)
		parse(port)
	end

	def parse(port)
		return nil if port.nil?

		service = port.elements['service']

		return nil if service.nil?

		@name = service.attributes['name']
		@product = service.attributes['product']
		@version = service.attributes['version']
		@method = service.attributes['method']
		owner = port.elements['owner']
		@owner = owner.attributes['name'] if owner
		@tunnel = service.attributes['tunnel']
		rpcnum = service.attributes['rpcnum']
		@rpcnum = rpcnum.to_i if rpcnum
		lowver = service.attributes['lowver']
		@lowver = lowver.to_i if lowver
		highver = service.attributes['highver']
		@highver = highver.to_i if highver
		conf = service.attributes['conf']
		@confidence = conf.to_i if conf
		@proto = service.attributes['proto']
		@extra = service.attributes['extrainfo']
		@devicetype = service.attributes['devicetype']
		@ostype = service.attributes['ostype']
		@fingerprint = service.attributes['servicefp']
	end
end

# This holds the OS information from OS Detection
class Nmap::Parser::Host::OS
	# OS fingerprint
	attr_reader :fingerprint

	# Returns an array of OSClass objects, and passes them each to a
	# block if one is given
	def osclasses
		@osclasses.each { |osclass| yield osclass } if block_given?

		@osclasses
	end

	# Returns an array of OSMatch objects, and passes them each to a
	# block if one is given
	def osmatches
		@osmatches.each { |osmatch| yield osmatch } if block_given?

		@osmatches
	end

	# Returns the number of OS class records
	def class_count
		@osclasses.size
	end

	# Returns OS class accuracy of the first OS class record, or Nth record
	# as specified by +index+
	def class_accuracy(index = 0)
		return nil if @osclasses.empty?

		@osclasses[index.to_i].accuracy
	end

	# Returns OS family information of first OS class record, or Nth record
	# as specified by +index+
	def osfamily(index = 0)
		return nil if @osclasses.empty?

		@osclasses[index.to_i].osfamily
	end

	# Returns OS generation information of first OS class record, or Nth
	# record as specified by +index+
	def osgen(index = 0)
		return nil if @osclasses.empty?

		@osclasses[index.to_i].osgen
	end

	# Returns OS type information of the first OS class record, or Nth
	# record as specified by +index+
	def ostype(index = 0)
		return nil if @osclasses.empty?

		@osclasses[index.to_i].ostype
	end

	# Returns OS vendor information of the first OS class record, or Nth
	# record as specified by +index+
	def osvendor(index = 0)
		return nil if @osclasses.empty?

		@osclasses[index.to_i].osvendor
	end

	# Returns the number of OS match records
	def name_count
		@osmatches.size
	end

	# Returns name of first OS match record, or Nth record as specified by
	# +index+
	def name(index = 0)
		return nil if @osmatches.empty?

		@osmatches[index.to_i].name
	end

	# Returns OS name accuracy of the first OS match record, or Nth record
	# as specified by +index+
	def name_accuracy(index = 0)
		return nil if @osmatches.empty?

		@osmatches[index.to_i].accuracy
	end

	# Returns an array of names from all OS records, and passes them each
	# to a block if one is given
	def all_names() # :yields: name
		names = []

		@osmatches.each do |match|
			names << match.name
			yield match.name if block_given?
		end

		names
	end

	alias names all_names

	# Returns the closed TCP port used for this OS Detection run
	def tcpport_closed
		return nil if @portsused.nil?

		@portsused.each do |port|
			if port.proto == "tcp" and port.state == "closed"
				return port.num
			end
		end

		nil
	end

	# Returns the open TCP port used for this OS Detection run
	def tcpport_open
		return nil if @portsused.nil?

		@portsused.each do |port|
			if port.proto == "tcp" and port.state == "open"
				return port.num
			end
		end

		nil
	end

	# Returns the closed UDP port used for this OS Detection run
	def udpport_closed
		return nil if @portsused.nil?

		@portsused.each do |port|
			if port.proto == "udp" and port.state == "closed"
				return port.num
			end
		end

		nil
	end

	private

	def initialize(os)
		parse(os)
	end

	def parse(os)
		@portsused = []
		@osclasses = []
		@osmatches = []

		return nil if os.nil?

		@portsused = os.elements.collect('portused') do |port|
			PortUsed.new(port)
		end

		@osclasses = os.elements.collect('osclass') do |osclass|
			OSClass.new(osclass)
		end

		@osclasses.sort!.reverse!

		@osmatches = os.elements.collect('osmatch') do |match|
			OSMatch.new(match)
		end

		@osmatches.sort!.reverse!

		fp = os.elements['osfingerprint']
		@fingerprint = fp.attributes['fingerprint'] if fp
	end
end

class Nmap::Parser::Host::OS::PortUsed # :nodoc: all
	attr_reader :state, :proto, :num

	private

	def initialize(ports)
		parse(ports)
	end

	def parse(ports)
		@state = ports.attributes['state']
		@proto = ports.attributes['proto']
		@num = ports.attributes['portid'].to_i
	end
end

# Holds information for an individual OS class record
class Nmap::Parser::Host::OS::OSClass
	# Device type, like "router" or "general purpose"
	attr_reader :ostype
	# Company that makes the OS, like "Apple" or "Microsoft"
	attr_reader :osvendor
	# Product name, like "Linux" or "Windows"
	attr_reader :osfamily
	# A more precise description, like "2.6.X" for Linux
	attr_reader :osgen
	# Accuracy of this information
	attr_reader :accuracy

	# Compares accuracy
	def <=>(osclass)
		@accuracy <=> osclass.accuracy
	end

	private

	def initialize(osclass)
		parse(osclass)
	end

	def parse(osclass)
		@ostype = osclass.attributes['type']
		@osvendor = osclass.attributes['vendor']
		@osfamily = osclass.attributes['osfamily']
		@osgen = osclass.attributes['osgen']
		@accuracy = osclass.attributes['accuracy'].to_i
	end
end

# Holds information for an individual OS match record
class Nmap::Parser::Host::OS::OSMatch
	# Operating System name
	attr_reader :name
	# Accuracy of this match
	attr_reader :accuracy

	# Compares accuracy
	def <=>(osmatch)
		@accuracy <=> osmatch.accuracy
	end

	private

	def initialize(os)
		parse(os)
	end

	def parse(os)
		@name = os.attributes['name']
		@accuracy = os.attributes['accuracy'].to_i
	end
end

