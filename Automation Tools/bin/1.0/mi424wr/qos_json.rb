#!/usr/bin/env ruby
# Build JSON files for QoS rule

require 'rubygems'
require 'json'
require 'optparse'
require 'ostruct'
require 'common/ipcheck'

options = OpenStruct.new
options.output_file = "qos_test.json"
options.rule_name = "qos_rule_0001"
options.device = "network (home/office)"
options.source = "any"
options.destination = "any"
options.services = "any"
options.set = false
options.operation = false
options.schedule = false
options.scanbuild = "on"
options.section = "advanced-qos-input"
options.ip = false
options.ports = ""
options.type = 1
contents = {}

opts = OptionParser.new do |opts|
    opts.separator ""
    opts.banner = "Creates a QoS JSON file"

    opts.on("-o FILE", "Sets output filename") { |o| options.output_file = o }
    opts.on("-r NAME", "--rulename", "Sets rule name") { |o| options.rule_name = o }
    opts.on("--device DEVICE", "Override default selection for the device \"Network (Home/Office)\"") { |o| options.device = o }
    opts.on("--source SOURCE", "Override default source value of \"Any\"") { |o| options.source = o }
    opts.on("--destination DESTINATION", "Override default destination value of \"Any\"") { |o| options.destination = o }
    opts.on("--set STRING", String, "Change set values") { |o| options.set = o }
    opts.on("--operation STRING", String, "Change operation values") { |o| options.operation = o }
    opts.on("--output", "Sets QoS rule to output chain instead of input") { options.section = "advanced-qos-output" }
    opts.on("--schedule SCHEDULE", "Sets schedule") { |o| options.schedule = o }
    options
end

def create_object(value, type = 1)
    object = {}
    case type
    when 1
        # IP Address
        object['type'] = "IP Address"
        object['start_address'] = value.chomp.strip
        return object
    end
end

#FixMe: Implement
def create_schedule(sched)

end

opts.parse!(ARGV)
contents[options.rule_name] = {}
contents[options.rule_name]['section'] = options.section
contents[options.rule_name]['device'] = options.device
if IPCommon::is_valid(options.source)
    options.ip = options.source
    options.source = false
    options.object = 1
end
contents[options.rule_name]['source'] = options.source || create_object(options.ip, options.object)
if IPCommon::is_valid(options.destination)
    options.ip = options.destination
    options.destination = false
    options.object = 1
end
contents[options.rule_name]['destination'] = options.destination || create_object(options.ip, options.object)
contents[options.rule_name]['services'] = options.services
contents[options.rule_name]['ports'] = options.ports unless options.ports == ""
contents[options.rule_name]['set'] = options.set
contents[options.rule_name]['operation'] = options.operation
#contents[options.rule_name]['schedule'] = create_schedule(options.schedule)
contents[options.rule_name]['scanbuild'] = options.scanbuild

File.new(options.output_file, File::CREAT|File::TRUNC)
output = File.open(options.output_file, 'w')
out = JSON.pretty_generate(contents)
out.sub!("\\","") # Why does the JSON parser think a / is an escapable character!?
out.each { |l| output.write(l) }