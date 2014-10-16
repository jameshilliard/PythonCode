#!/usr/bin/env ruby
# Build Json Files
$: << File.dirname(__FILE__)

require 'optparse'
require 'ostruct'
require 'rubygems'
require 'json'

CB_VERSION = "0.5"
SUPPORTS = "Firewall: Port Forwarding, Access Control, DMZ Hosting, Port Triggering, Static NAT, Advanced Filtering, Remote Administration"
helpArray = []
helpArray[0] = "-h"
$debug = 0

class Debug
	def self.out(message)
		if $debug == 3
			puts "(III) #{message}"
		end
	end
end
class Error
	def self.out(message)
		puts "(!!!) Exiting builder - #{message}"
		exit
	end
end
class SavePort
	def initialize
		@savedValues = {}
		@savedValues["noMoreAnyAny"] = FALSE
	end
	def value(section, port)
		if section == "noMoreAnyAny"
			@savedValues[section] = port
		else
			@savedValues[section] << "#{port},"
		end
	end
	def values(section="")
		if section == ""
			return @savedValues
		else
			if @savedValues[section] == nil
				@savedValues[section] = ""
			end
			return @savedValues[section]
		end
	end
end
# Options holder and default values..

options = OpenStruct.new
options.amount = 1
options.ip = "192.168.1.2"
options.debug = 0
options.filePrefix = "tc_"
options.fileExtension = ".json"
options.directory = "."
options.sequential = FALSE
options.useRanges = TRUE
options.useRanges1= TRUE
options.scanbuild = TRUE
options.imax = 10
options.imax1= 10
options.action = "block"
options.object = "ip address"
options.endip = ""
options.minport = 1
options.maxport = 65535
options.firewall = ""
options.fwfrags = ""
options.section = ""
options.pf = FALSE
options.wt = ""
options.anyany = FALSE
options.dmzrange = FALSE
options.portlistdir = "portlist"
options.protocol_choice = nil
options.excludes = FALSE

# Options for advanced filtering
options.afn = ""
options.afdir = "input"
options.afsourceObject = ""
options.afsourceStart = ""
options.afsourceEnd = ""
options.afdestinationObject = ""
options.afdestinationStart = ""
options.afdestinationEnd = ""
options.afdscp = ""
options.afpriority = ""
options.aflength = ""
options.afoperation = ""
options.aflog = "off"

# Holder for used ports so we don't use them multiple times
usedValues = []

# Option parser
opts = OptionParser.new do |opts|
	opts.separator ""
	opts.banner = "JSON File Builder #{CB_VERSION} - Currently supporting: #{SUPPORTS}"
	
	opts.on("--fwremote-admin", "Build a configuration for the firewall remote administration section.") { options.section = "firewall_remote admin" }
	opts.on("--port-forwarding IP", "Build a configuration for port forwarding.") { |ip| options.section = "Port Forwarding"; options.ip = ip }
	opts.on("--firewall", "Creates a randomized ruleset for the firewall.") { options.section = "firewall" }
	opts.on("--port-triggering", "Build a port triggering rule.") { options.section = "Port Triggering" }
	opts.on("--dmz IP", "Create DMZ host configuration. Set ip to \'off\' to create a config to turn DMZ hosting off.") { |dmz| options.section = "DMZ Host"; options.ip = dmz }
	opts.on("--dmz-testrange [RANGE]", "Create a DMZ testsystem file based off the range given (1-1000) or single value # for a randomized range.") { |dr| options.dmzrange = dr; options.section = "DMZ Test Build" }
	opts.on("--sn-testrange [RANGE]", "Create a Static NAT testsystem file based off the range given (1-1000) or single value # for a randomized range.") { |dr| options.dmzrange = dr; options.section = "SN Test Build" }
	opts.on("--access-control action,object,start,end", "Build a JSON configuration file for access controls.",
	        "Action = Block or Allow.",
	        "Object = Type of network object to create when adding the rule, or the name of an object already created.",
	        "Start = Start IP or object address, or MAC ID to use, or DHCP option to select.",
	        "End = End IP or object address/subnet mask, or DHCP option value.") do |items|
		options.section = "Access Control"
		options.action = items.split(',')[0]
		options.object = items.split(',')[1]
		options.ip = items.split(',')[2]
		options.endip = items.split(',')[3] if items.split(',')[3]
	end
	
	opts.on("--static-nat publicIP,localIP,wanTYPE", "Build a Static NAT rule.",
	        "Public IP = IP to use for WAN side.",
	        "Local IP = Internal/local IP address to map to.",
	        "WAN Type = WAN Device, defaults to All Broadband Devices.",
	        "Use --pf to enable port forwarding and generate ports for the static NAT rule.") do |items|
		options.section = "Static NAT"
		options.ip = items.split(',')[0]
		options.endip = items.split(',')[1]
		options.wt = items.split(',')[2] if items.split(',')[2]
	end
	opts.separator ""
	opts.separator "Advanced Filtering options:"
	
	opts.on("--advanced-filtering", "Creates a rule for advanced filtering. Use --pf to add port filters to the rule.")
	opts.on("--afnetwork NETWORK", "Specifies the network to create the Advanced Filtering rule on. Following are valid options:",
	        "homenetwork, ethernet, broadbandEthernet, coax, broadbandCoax, wireless, pppoe1, pppoe2") { |afn| options.afn = afn if afn.match(/homenetwork|ethernet|broadbandEthernet|broadbandCoax|coax|wireless|pppoe1|pppoe2/) }
	opts.on("--direction DIR", "Valid options: input, output. Sets rule traffic direction. Default: input.") { |dir| options.afdir = dir if dir.match(/output|input/i) }
	opts.on("--source object,start,end", "Create source device of type object, with start and end addresses or options.") do |items|
		options.afsourceObject = items.split(',')[0]
		options.afsourceStart = items.split(',')[1]
		options.afsourceEnd = items.split(',')[2]
	end
	opts.on("--destination object,start,end", "Create destination device of type object, with start and end addresses or options.") do |items|
		options.afdestinationObject = items.split(',')[0]
		options.afdestinationStart = items.split(',')[1]
		options.afdestinationEnd = items.split(',')[2]
	end
	opts.on("--dscp HEX,MASK", "Turn on DSCP for the filtering rule, and set to HEX and MASK values.") { |h| options.afdscp = "#{h.split(',')[0]} #{h.split(',')[1]}" }
	opts.on("--priority LEVEL", "Turn on priority level. 0-7.") { |p| options.afpriority = "#{p}" }
	opts.on("--length type,bytes", "Turn on length checking. Valid types: packet, data. Bytes should be in form of #-#, e.g.80-1280") { |l| options.aflength = "#{l.split(',')[0]}: #{l.split(',')[1]}" }
	opts.on("--operation OP", "Sets operation to OP. Valid types: Drop, Reject, Accept Connection, Accept Packet") { |o| options.afoperation = "#{o}" if o.match(/drop|reject|accept con|accept pa/i) }
	opts.on("--log", "Turns the logging function on for the advanced filtering rule.") { options.aflog = "on" }
	
	opts.separator ""
	opts.separator "Options that apply to every configuration rule:"
	
	opts.on("--pf", "Turns on port forwarding for Static NAT or Advanced Filtering rules. Default is off.") { options.pf = TRUE }
	opts.on("--amount AMOUNT", "Sets the number of complete configuration rules to create. Default 1.") { |amount| options.amount = amount.to_i }
	opts.on("--iteration-max MAX", "Sets the *possible* max number of ports to create for all rules involving port creation. Default 10.") { |max| options.imax = max.to_i }
	opts.on("--imax-out MAX", "Sets the *possible* max number of ports to create for port triggering rule ports - outbound. Default 10.") { |max| options.imax1 = max.to_i }
	opts.on("--[no-]ranges", "Use or don't use ranges in port values created (useful for high amounts of rule creation. Default is to use ranges.") { |r| options.useRanges = r }
	opts.on("--[no-]ranges-out", "Use or don't use ranges in port triggering outbound port creation. Default is to use ranges.") { |r| options.useRanges1 = r }
	opts.on("--[no-]scanbuild", "Use or don't use the scanbuild parameter. Default is on.") { |r| options.scanbuild = r }
	opts.on("--[no-]sequential", "Sequential creates one big file. Defaults to multiple smaller files.") { |r| options.sequential = r }
	opts.on("--max-port PORT", "Specifies max port to use to limit port creation randomness.") { |mp| options.maxport=mp.to_i }
	opts.on("--min-port PORT", "Specifies minimum port to use to limit port creation randomness.") { |mp| options.minport=mp.to_i }
	opts.on("--allow-anyany", "Used to allow a rule of Any,Any to exist. By default is off.") { options.anyany = TRUE }
	opts.on("--prefix PREFIX", "File prefix.") { |prefix| options.filePrefix = prefix }
	opts.on("--save-dir DIRECTORY", "Directory to save output to if not current directory.") { |dir| options.directory = dir }
	opts.on("--portlists DIRECTOY", "Directory of where to get port list files from.") { |dir| options.portlistdir = dir }
    opts.on("--[no-]excludes", "Turns the option of using exclude to on or off. Default is off.") { |o| options.excludes = o }
    opts.on("--protocol_choice PROT", "Set to 0 for TCP, 1 for UDP") { |o| options.protocol_choice = o }
	opts.on("-d", "--debug DEBUGLEVEL", "Sets debug level.") { |debuglevel| options.debug = debuglevel.to_i }
	opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
	options
end


def save(filename, contents)
	if filename == nil
		Debug.out("No filename passed to save function.")
		return FALSE
	end
	Debug.out("Saving configuration file - #{filename}.") 
	genContents = JSON.pretty_generate(contents)
	begin
		f = File.open(filename, 'w')
		genContents.each do |writeline|
			f.write(writeline)
		end
		f.close
		Debug.out("#{filename} saved successfully")
	rescue
		return FALSE
	end
	return TRUE
end

def buildFlags(percentages)
	flags = ""
	percentages.split(',').each do |percentage|
		percentile = rand(100)
		(100-percentage.to_i..100) === percentile  ? flags << "1" : flags << "0"
	end
	return flags
end

def portCreation(usedValues,amount,useRanges,maxport,minport,anyany=FALSE, excludes=FALSE, protocol_choice=nil)
	ports = ""
	protExclude = 5 # Chance of excluding the protocol
	protChoice = 50 # Chance of TCP vs UDP .. FixMe: We need to expand this option. 
	sourceExclude = 5 # Chance of using Exclude on source pot
	sourceAny = 100 # Chance of source being "Any" - set to 100 for port triggering
	sourceRanged = 10 # Chance of source port being a range
	destExclude = 5 # Chance of using Exclude on Destination port
	destAny = 1 # Chance of destination being "Any"
	destRanged = 30 # Chance of destination being a range
	if useRanges == FALSE
		sourceRanged = -1
		destRanged = -1
	end
	flagPercentages = "#{protExclude},#{protChoice},#{sourceExclude},#{sourceAny},#{sourceRanged},#{destExclude},#{destAny},#{destRanged}"
	Debug.out("Building flag list.")
	for i in 1..rand(amount)+1
		currentPort = ""
		flagCheck = OpenStruct.new
		carrier = buildFlags(flagPercentages)
		flagCheck.protExclude = carrier.split('')[0].to_i
		flagCheck.protChoice = carrier.split('')[1].to_i
		flagCheck.sourceExclude = carrier.split('')[2].to_i
		flagCheck.sourceAny = carrier.split('')[3].to_i
		flagCheck.sourceRanged = carrier.split('')[4].to_i
		flagCheck.destExclude = carrier.split('')[5].to_i
		flagCheck.destAny = carrier.split('')[6].to_i
		flagCheck.destRanged = carrier.split('')[7].to_i
		# FixMe: Finish this check 
		if flagCheck.sourceAny+flagCheck.destAny == 2
			if usedValues.values("noMoreAnyAny") || anyany == FALSE
				puts "Removing any,any value." if $debug == 2
				rand(100)+1 > 60 ? flagCheck.sourceAny = 0 : flagCheck.destAny = 0
			else
				puts "Found the first rule of any,any. Marking as done." if $debug == 2
				usedValues.value("noMoreAnyAny", TRUE)
			end
		end
		# Variable for saving things
		vsection = ""
		cPort = ""
		Debug.out("Received build flags: #{carrier}")
		# Protocol exclude
		currentPort << "~" if flagCheck.protExclude == 1 if excludes
		# Protocol
        if protocol_choice == nil
            if flagCheck.protChoice == 1
                currentPort << "TCP:"
                vsection = "TCP"
            else
                currentPort << "UDP:"
                vsection = "UDP"
            end
        else
            vsection = "TCP" if protocol_choice == 0
            vsection = "UDP" if protocol_choice == 1
        end

		# Source Port
		if flagCheck.sourceAny == 0
			# Source port exclude - can't exclude if any, so we put here if we aren't doing "any"
			currentPort << "~" if flagCheck.sourceExclude if excludes
			# If it's a range
			if flagCheck.sourceRanged == 1
				done = FALSE
				while not done
					if usedValues.values(vsection+"Source") == ""
						done = TRUE
					end
					r_gap = (rand(10)+1)*100
					startRange = rand((maxport-minport)-r_gap) + minport
					endRange = (startRange+rand(r_gap))
					Debug.out("Checking against range: #{startRange}-#{endRange}. Current virtual section: #{vsection+"Source"}")
					usedValues.values(vsection+"Source").split(',').each do |checkValue|
						Debug.out("Current check value: #{checkValue}")
						if (startRange..endRange) === checkValue.to_i
							done = FALSE
						else
							done = TRUE
						end
					end
				end
				cPort = "#{startRange}-#{endRange}"
				Debug.out("Adding #{cPort} to current build virtual section: #{vsection+"Source"}")
				for i in startRange..endRange
					usedValues.value(vsection+"Source", i)
				end
				currentPort << "#{cPort},"
			else
				# If it's not a range.. we need to check against other ranges. 
				done = FALSE
				while not done
					cPort = "#{rand((maxport-minport))+minport}"
					if not usedValues.values(vsection+"Source").include?("#{cPort}")
						done = TRUE
					end
				end
				Debug.out("Adding #{cPort} to current build virtual section: #{vsection+"Source"}")
				usedValues.value(vsection+"Source", cPort)
				currentPort << "#{cPort},"
			end
		else
			currentPort << "any,"
		end

		# Destination port
		if flagCheck.destAny == 0
			# destination port exclude - can't exclude if any, so we put here if we aren't doing "any"
			currentPort << "~" if flagCheck.destExclude == 1 if excludes
			# Destination if range
			if flagCheck.destRanged == 1
				# Build a range if true
				done = FALSE
				while not done
					if usedValues.values(vsection+"Destination") == ""
						done = TRUE
					end
					r_gap = (rand(10)+1)*100
					startRange = rand((maxport-minport)-r_gap) + minport
					endRange = (startRange+rand(r_gap))
					Debug.out("Checking against range: #{startRange}-#{endRange}")
					usedValues.values(vsection+"Destination").split(',').each do |checkValue|
						if (startRange..endRange) === checkValue.to_i
							done = FALSE
							break
						else
							done = TRUE
						end
					end
				end
				cPort = "#{startRange}-#{endRange}"
				Debug.out("Adding #{cPort} to current build virtual section: #{vsection+"Destination"}")
				for i in startRange..endRange
					usedValues.value(vsection+"Destination", i)
				end
				currentPort << "#{cPort};"
			else
				# Destination if single
				done = FALSE
				while not done
					cPort = "#{rand((maxport-minport))+minport}"
					if not usedValues.values(vsection+"Destination").include?("#{cPort}")
						done = TRUE
					end
				end
				Debug.out("Adding #{cPort} to current build virtual section: #{vsection+"Destination"}")
				usedValues.value(vsection+"Destination", cPort)
				currentPort << "#{cPort};"
			end
		else
			currentPort << "any;"
		end
		ports << currentPort
	end

	# Return what we have
	return ports
end

def buildConfig(usedValues,options,name)
	case options.section
	when /firewall.?remote.?admin/i
		config = { "section" => "firewall-remote_admin" }
		rand(100) < 50 ? config["primaryTelnet"] =  "off" : config["primaryTelnet"] =  "on"
		rand(100) < 50 ? config["secondaryTelnet"] = "off" : config["secondaryTelnet"] = "on"
		rand(100) < 50 ? config["secureTelnet"] =  "off" : config["secureTelnet"] =  "on"
		rand(100) < 50 ? config["primaryHTTP"] =  "off" : config["primaryHTTP"] =  "on"
		rand(100) < 50 ? config["secondaryHTTP"] =  "off" : config["secondaryHTTP"] =  "on"
		rand(100) < 50 ? config["primaryHTTPS"] =  "off" : config["primaryHTTPS"] =  "on"
		rand(100) < 50 ? config["secondaryHTTPS"] = "off" : config["secondaryHTTPS"] = "on"
		rand(100) < 90 ? config["WAN-ICMP"] =  "on" : config["WAN-ICMP"] =  "off"
		rand(100) < 90 ? config["WAN-UDPTrace"] =  "off" : config["WAN-UDPTrace"] =  "on"
		if options.scanbuild == TRUE
			config["scanbuild"] = "on"
		end
		return config
	when /port.?forward/i
		forwardToPort = 5 # Chance of using forward to port
		# { rule => { value => value_settings } }
		config = { "section" => "firewall-port_forwarding",
		           "host" => "specify: #{options.ip.strip}",
		           "services" => "User Defined",
		           "serviceName" => "#{name}" }
		config["scanbuild"] = "on" if options.scanbuild == TRUE
		# Not doing scheduling yet. We'll figure that out later. 
		config["ports"] = portCreation(usedValues, options.imax, options.useRanges, options.maxport, options.minport, options.anyany)
		config["ForwardTo"] =  "#{rand(options.maxport)+1}" if buildFlags("#{forwardToPort}") == "1"
		return config
	when /access.?control/i
		if options.ip.include?("rand")
			bn = options.ip.match(/\d+?-\d+/).to_s
			eip = options.ip.sub(/rand.*/, "#{rand(bn.split('-')[0].to_i)+bn.split('-')[1].to_i}")
		else
			eip = options.ip
		end
		selection = "User Defined" if options.object.match(/ip.?address|ip.?subnet|ip.?range|mac.?address|host.?name|dhcp.?option/i)
		config = { "section" => "firewall-access_control",
		           "action" => "#{options.action.strip}",
		           "device" => { 
		                        "selection" => "#{selection}",
		                        "description" => "Object #{name}",
		                        "type" => "#{options.object.strip}",
		                        "start_address" => "#{eip.strip}",
		                        "end_address" => "#{options.endip.strip}"
		                       },
		           "services" => "User Defined",
		           "serviceName" => "Service #{name}" }
		if options.scanbuild == TRUE
			config["scanbuild"] = "on"
		end
		config["ports"] = portCreation(usedValues, options.imax, options.useRanges, options.maxport, options.minport, options.anyany)
		return config
	when /dmz host/i
		config = { "section" => "firewall-dmz_host" }
		if options.ip.match(/off/i)
			config["action"] = "off"
        elsif options.ip.include?("rand")
			bn = options.ip.match(/\d+?-\d+/).to_s
			eip = options.ip.sub(/rand.*/, "#{rand(bn.split('-')[1].to_i - bn.split('-')[0].to_i)+bn.split('-')[0].to_i}")
            config["action"] = "on"
            config["ip"] = eip
		else
			config["action"] = "on"
			config["ip"] = options.ip
		end
		if options.scanbuild == TRUE
			config["scanbuild"] = "on"
		end
		return config
	when /firewall/i
		config = { "section" => "firewall-general" }
		if options.firewall.match(/random/i)
			fw = buildFlags("25,50,40")
			case fw
			when /1../
				config["set"] = "minimum"
			when /.1./
				config["set"] = "typical"
			when /..1/
				config["set"]= "maximum"
			else
				config["set"] = "typical"
			end
			fw = buildFlags("40")
			config["set"] <<  "+fragments" if fw == '1'
			config["set"] <<  "-fragments" if fw == '0'
		end
		return config
	when /port.?trigger/i
		config = { "section" => "firewall-port_triggering",
		           "servicename" => "#{name}",
		           "services" => "User Defined" }
		config["outgoing"] = portCreation(usedValues, options.imax, options.useRanges, options.maxport, options.minport, options.anyany)
		config["incoming"] = portCreation(usedValues, options.imax1, options.useRanges1, options.maxport, options.minport, options.anyany)
        config["scanbuild"] = "on" if options.scanbuild == TRUE
		return config
	when /static.?nat/i
		eip = ""
		config = { "section" => "firewall-static_nat",
		           "serviceName" => "#{name}" }
		config["WANtype"] = options.wt if not options.wt == ""
		Debug.out("Checking internal ip - #{options.endip}")
		if options.endip.include?("rand")
			bn = options.endip.match(/\d+?-\d+/).to_s
			eip = options.endip.sub(/rand.*/, "#{rand(bn.split('-')[0].to_i)+bn.split('-')[1].to_i}")
		else
			eip = options.endip
		end

		if (eip =~ /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/) != nil
			config["host"] = "specify: #{eip}"
		else
			config["host"] = "#{eip}"
		end
		Debug.out("Checking public ip - #{options.ip}")
		if options.ip.include?("rand")
			bn = options.ip.match(/\d+?-\d+/).to_s
			eip = options.ip.sub(/rand.*/, "#{rand(bn.split('-')[0].to_i)+bn.split('-')[1].to_i}")
		else
			eip = options.ip
		end

		if (eip =~ /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/) != nil
			config["publicIP"] = eip
		else
			Error.out("Invalid Public IP specified for creating a Static NAT rule: #{options.ip}")
		end
		config["ports"] = portCreation(usedValues, options.imax, options.useRanges, options.maxport, options.minport, options.anyany) if options.pf == TRUE
		return config
	when /advanced.?filter/i
#{
#	"rulename": {
#		"section": "firewall-advanced filtering-input|output",
#		"device": "network (home/office)",
#		"source": "",
#		"destination": "",
#		"services": "User Defined",
#		"ports": "",
#		"set": "-dscp ##:## -priority # -packet|data_length ##:## -drop|accept_connection|accept_packet|reject -log on",
#		"schedule": {
#
#		},
#		"scanbuild": "on"
#	}
#}
		config = { "section" => "firewall-advanced_filtering",
		           "rules" => "#{name}",
		           "#{name}" => {
		                         "section" => "#{options.afn}",
		                         "#{options.dir}" => "1",
		                         }
		         }
		config["#{name}"]["sourceDevice"] = { "description" => "src #{name}", "selection" => "User Defined", "type" => "#{options.afsourceObject}", "start_address" => "#{options.afsourceStart}", "end_address" => "#{options.afsourceEnd}" }
		config["#{name}"]["destDevice"] = { "description" => "dest #{name}", "selection" => "User Defined", "type" => "#{options.afdestinationObject}", "start_address" => "#{options.afdestinationStart}", "end_address" => "#{options.afdestinationEnd}" }
		config["ports"] = portCreation(usedValues, options.imax, options.useRanges, options.maxport, options.minport, options.anyany) if options.pf == TRUE
		config["services"] = "User Defined" if options.pf == TRUE
		config["DSCP"] = "#{options.afdscp}" if options.afdscp != ""
		config["Priority"] = "#{options.afpriority}" if options.afpriority != ""
		config["Length"] = "#{options.aflength}" if options.aflength != ""
		config["Operation"] = "#{options.afoperation}" if options.afoperation != ""
		config["Log"] = "#{options.aflog}"
		return config
	when /dmz test/i
		# Build a DMZ test range for the test system
		config = { "wanip" => "replacewan",
		           "lanip" => "192.168.1.1",
		           "from" => "DMZ Host",
		           "type" => "port scan",
		           "udp_ports" => "",
		           "tcp_ports" => "" }
		if options.dmzrange.match(/\A\d+\z/)
			gap = options.dmzrange.to_i
			sRange = rand((options.maxport-options.minport)-gap) + options.minport
			eRange = sRange+gap
		elsif options.dmzrange.match(/\A\d*-\d*\z/)
			sRange = options.dmzrange.split('-')[0].to_i
			eRange = options.dmzrange.split('-')[1].to_i
		end
		config['udp_ports'] = "any:#{sRange}-#{eRange}"
		config['tcp_ports'] = "any:#{sRange}-#{eRange}"
		return config
	when /sn test/i
		# Build static nat ranges, similar to dmz hosting
		config = { "wanip" => "replacewan",
		           "lanip" => "replacelan",
		           "from" => "Static NAT",
		           "type" => "port scan",
		           "udp_ports" => "",
		           "tcp_ports" => "" }
		if options.dmzrange.match(/\A\d+\z/)
			gap = options.dmzrange.to_i
			sRange = rand((options.maxport-options.minport)-gap) + options.minport
			eRange = sRange+gap
		elsif options.dmzrange.match(/\A\d*-\d*\z/)
			sRange = options.dmzrange.split('-')[0].to_i
			eRange = options.dmzrange.split('-')[1].to_i
		end
		config['udp_ports'] = "any:#{sRange}-#{eRange}"
		config['tcp_ports'] = "any:#{sRange}-#{eRange}"
		return config
	end
end

begin
	if ARGV.length < 1
		opts.parse!(helpArray)
	else
		opts.parse!(ARGV)
	end
	$debug = options.debug
	seed = Time.now.to_i
	Debug.out("Using seed #{seed}")
	srand = seed
	configHolder = {}
	usedValues = SavePort.new
    ip_count = 0
	filename = "#{options.filePrefix}#{options.fileExtension}"

    if options.sequential
        if options.ip.match(/\d+?\.\d+?\.\d+?\.\d+?-\d+/)
            ip_temp = options.ip.slice!(/\d+?\.\d+?\.\d+?\.\d+?-/).delete('-')
            ip_prefix = ip_temp.slice!(/\d+?\.\d+?\.\d+?\./)
            ip_start = ip_temp.to_i
            ip_end = options.ip.to_i
            ip_increment = TRUE
        end
    end

	if options.amount.to_i > 0
		for i in 1..options.amount.to_i
			usedValues = SavePort.new if options.sequential == FALSE
			configHolder = {} if options.sequential == FALSE
			filename = "#{options.filePrefix}#{i}#{options.fileExtension}" if options.sequential == FALSE
			rule_name = sprintf("%04d_#{options.section.sub(/ /,'_').strip.downcase}", i)
            options.ip = "#{ip_prefix}#{ip_start}" if ip_increment
            ip_start += 1 if ip_increment
			configHolder[rule_name] = buildConfig(usedValues, options, "#{options.filePrefix}#{i}")
			if options.sequential == FALSE
                Debug.out("Generating #{filename}")
				if save("#{options.directory}/#{filename}", configHolder) == FALSE
					Error.out("Something unexpected happened and a filename was not generated correctly.")
				end
			end
		end
	end
	if options.sequential == TRUE
        Debug.out("Generating #{filename}")
		if save("#{options.directory}/#{filename}", configHolder) == FALSE
			Error.out("Something unexpected happened and a filename was not generated correctly.")
		end
	end
end
