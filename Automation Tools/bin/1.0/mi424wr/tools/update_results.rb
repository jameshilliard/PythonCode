#!/usr/bin/env ruby

# If step 7 fails, check if step 8 passes. Change step 7 to a pass if step 8 passed
# If step 12 fails, check if step 13 passes. Change step 12 to a pass if step 13 passed

require 'ostruct'
require 'optparse'

options = OpenStruct.new
options.dir = ""
nmap_1_index = 0
nmap_2_index = 0
iperf_1_index = 0
iperf_2_index = 0

opts = OptionParser.new do |opts|
	opts.separator("")
	opts.banner = "Get the configuration from the BHR2 via serial port console or telnet."

    opts.on("-d", "--directory DIR", "Log directory to check") { |dir| options.dir = dir }
	options
end

opts.parse!(ARGV)
results = File.open("#{options.dir}/result.txt").readlines

# Doing this messy, but it'll get the job done so who cares
results.each_index do |x|
    case results[x]
    when /step_7/
        nmap_1_index = x
    when /step_8/
        iperf_1_index = x
    when /step_12/
        nmap_2_index = x
    when /step_13/
        iperf_2_index = x
    end
end

results[nmap_1_index].sub!(/failed/i, "Passed") if results[iperf_1_index].match(/passed/i) if iperf_1_index > 0 && nmap_1_index > 0
results[nmap_2_index].sub!(/failed/i, "Passed") if results[iperf_2_index].match(/passed/i) if iperf_2_index > 0 && nmap_2_index > 0

output = File.open("#{options.dir}/result.txt", "w+")
output.write(results)