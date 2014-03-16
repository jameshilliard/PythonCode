#!/usr/bin/env ruby

# Valid list
valid_failure_list = []
count = 0
count2 = 0

# Create the directory list, minus . and ..
dirlist = Dir.entries("./").delete_if { |x| x.match(/\A\./) }
templist = []
# Open the log file for output
output = File.open("valid_list.log", 'w')

dirlist.each do |check|
	if File.directory?(check)
		if File.exists?("#{check}/testsystem.log")
			logcheck = File.open("#{check}/testsystem.log").read
			if logcheck.match(/fail/i)
				valid_failure_list[count] = "#{check}"
				count += 1
			end
		else
			templist[count2]="#{check} was marked as a failure but missing a log file from the test system. This is generally an indication that the test timed out during processing (it took far too long,) or the configuration never went through."
			count2 += 1
		end
	end
end

output.write("Total tests that failed (possible bugs): #{count+1}\n\n")
output.write("Notes: Pcap log format is not yet supported.\n~ is an exclude for ports, and ! is an exclude for protocols. These should come back as filtered ports. Otherwise, it is assumed that all other ports will go through successfully.")
#templist.each do |line|
#	output.write("\n#{line}\n")
#end

valid_failure_list.each do |line|
	output.write("\n\n\n## Failure indicated in test #{line} ##")
	output.write("\t\nFailed ports as follows - \n")
	File.open("#{line}/testsystem.log").readlines.each do |checkLine|
		if checkLine.match(/fail/i)
			output.write("\t#{checkLine}")
		end
	end
	jsonfile = line.sub(/.xml_\d+/,'').strip
	ports = File.open("/root/actiontec/automation/platform/1.0/verizon2/testcases/port_forwarding/json/#{jsonfile}.json").read.slice(/ports.*;/)
	ports.strip!
	ports.sub!(/ports": "/,'')
	ports.delete!('"')
	ports.sub!(/:/, ' - ')
	output.write("\t\nPorts passed for configuration as follows:")
	ports.split(';').each do |port|
		output.write("\n\t\t#{port.strip}")
	end
end

output.close
