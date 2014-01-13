#!/usr/bin/env ruby
# Test with iperf - separated from the other testing script so that it doesn't break legacy items
# Eventually this all needs to be integrated fully and other items needs to be ported to this format
$: << File.dirname(__FILE__)
$: << "#{File.dirname(__FILE__)}/../"

require 'common/ipcheck'
require 'iperf_parser2'
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'json'
require 'log4r'

options = OpenStruct.new
options.logfile = false
options.debug = 3
options.verbose = true
options.json_file = false
options.rsi = { 'ip'=> "10.0.0.1", 'user' => "root", 'pass' => "actiontec" }
options.available_bandwidth = "1000Mb".to_bits

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Enables telnet, gets DUT config, and disables telnet in one shot."

    opts.on("-f JSONFILE", "JSON file to read from for testing purposes") { |v| options.json_file = v }
    opts.on("--remote IP,USER,PASS", "Sets remote system settings in order with defaults set to root/actiontec for user/pass") { |v| options.rsi['ip'] = v.split(',')[0]; options.rsi['user'] = v.split(',')[1]; options.rsi['pass'] = v.split(',')[2]; }
    opts.on("-a", "--available-bandwidth SIZE", "Sets the maximum available bandwidth to check against while sorting priorities.") { |v| options.available_bandwidth = v.to_bits }
    opts.on("-o LOG", "Sets log file to record information to") { |v| options.logfile = v }
    opts.on("--[no-]verbose", "Turns verbose(console) output off. Defaults to on") { |v| options.verbose = v }
    opts.on("-d", "--debug LEVEL", "Sets debug level 1-3, default is 3") { |v| options.debug = v.to_i }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

class Log
    def initialize(options, stream_name=false, silencer=TRUE)
        @stream_name = stream_name
        logs(options.logfile, 4 - options.debug, options.verbose, silencer)
    end
    def logs(filename=FALSE, level=4, console=TRUE, silenced=TRUE)
        # Create log object
        @out = Log4r::Logger.new("logging")

        # Console output
        if console
            Log4r::StdoutOutputter.new('console')
            Log4r::Outputter['console'].level = level
            Log4r::Outputter['console'].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] :: %m")
            @out.add('console')
            @out.info('Console output started.') unless silenced
        end

        # File output
        if filename
            Log4r::FileOutputter.new('logfile', :filename => filename, :trunc => false)
            Log4r::Outputter['logfile'].level = level
            Log4r::Outputter['logfile'].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m", :date_pattern => "%m/%d/%Y %H:%M %Z")
            @out.add('logfile')
            @out.info('Log file output started.') unless silenced
        end
	end

    def log(message, level=:debug)
        case level
        when :debug
            @out.debug("IPerf::#{@stream_name || "General"}::#{message}")
        when :info
            @out.info("IPerf::#{@stream_name || "General"}::#{message}")
        when :warn
            @out.warn("IPerf::#{@stream_name || "General"}::#{message}")
        when :error
            @out.error("IPerf::#{@stream_name || "General"}::#{message}")
        when :fatal
            @out.fatal("IPerf::#{@stream_name || "General"}::#{message}")
        end
    end
end

def parse_json(filename)
    begin
        json = JSON.parse!(File.open(filename).read)
    rescue JSON::ParserError => ex
        puts "Error: Cannot parse " + filename
        puts "#{ex.message}"
        exit -1
    end
    return json
end

def parse_options(o)
    bind_ip = false
    local = false
    if o.match(/-bind \d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/i)
        ip = o.split("-")[0]
        ip.delete!('^[0-9.]')
        bind_ip = ip if ip.valid_ip?
    end
    local = true if o.match(/local/i)
    return bind_ip, local
end

def bandwidth_check(expected, actual)
    # "bandwidth": "priority #|size - 100Mb 100MB etc or 10Mb-20Mb - specify min-max", "priority 7; 10Mb-20Mb", "priority 3", "10Mb-20Mb"
    #stream_info[stream]['bandwidth'], stream_results[stream]
    min_bandwidth = max_bandwidth = 0
    priority = -1
    minimum_passed = maximum_passed = true
    result = "BP|"
    items = expected.split(";")
    items.each do |item|
        item.strip!
        case item
        when /priority/i
            priority = item.delete('^[0-9]').to_i
        when /^[0-9]*\.?[0-9]+\s*[MKGbB]*?$/
            min_bandwidth = item.to_bits
        when /^[0-9]*\.?[0-9]+\s*[MKGbB]*?\s*-\s*[0-9]*\.?[0-9]+\s*[MKGbB]*?$/
            min_bandwidth = item.split('-')[0].to_bits
            max_bandwidth = item.split('-')[1].to_bits
        end
    end
    minimum_passed = false if actual < min_bandwidth if min_bandwidth > 0
    maximum_passed = false if actual > max_bandwidth if max_bandwidth > 0
    result = "BF|" if !maximum_passed || !minimum_passed
    min_bandwidth <= 0 ? result.insert(0, "NM") : result.insert(0, "YM")
    max_bandwidth <= 0 ? result.insert(0, "NX") : maximum_passed ? result.insert(0, "YP") : result.insert(0, "YN")
    return "#{sprintf("%04d",priority)}#{result}Expected bandwidth: #{min_bandwidth > 0 ? min_bandwidth.to_s.to_bps : "no minimum"} to #{max_bandwidth > 0 ? max_bandwidth.to_s.to_bps : "no maximum"}. Actual: #{actual.to_s.to_bps}."
end

# FixMe: Manual test plan doesn't call for priority testing quite yet, but leaving this in as a thought in progress
def priority_sort(result_list, free_bandwidth)
    priority_list = result_list.sort
    new_results = []
    priority_index = 0
    priority_list.each_index do |i|
        result = "PASSED"
        priority_index = priority_list[i].slice!(/^\d+/).to_i
        bc = priority_list[i].split("|")[0].unpack("a2a2a2")
        if bc[2] == "BF"
            # fails if minimum failed and it's the top priority stream
            result = "FAILED" if bc[0] == "YM" && i == 0
            # fails if minimum failed and there was free bandwidth
            result = "FAILED" if bc[0] == "YM" && free_bandwidth > 0
            # fails if the bandwidth is over maximum specified
            result = "FAILED" if bc[1] == "YN"
        end
        new_results << priority_list[i].split("|")[1].insert(0, "[#{priority_index >= 0 ? sprintf("%d", priority_index) : "NONE"}] [#{result}] ")
    end
    return new_results
end

# Testing begins here:
used_bandwidth = 0
bandwidth_results = []
threads = []
stream_container = {}
stream_results = {}
# This is our default port. Each stream iteration adds 1, regardless if it's used or not. This is in case a port is not specified in the config file
base_port = 6000

opts.parse!(ARGV)
raise "No JSON file containing settings specified. Aborting testing" unless options.json_file
stream_info = parse_json(options.json_file)

# Start global logging
logger = Log.new(options, false, false)

# Sift through each parent key in the json file, and sort them into their own hashes with options as an openstruct
logger.log("Setting up streams")
stream_info.each_key do |stream|
    raise "Missing server side options" unless stream_info[stream].has_key?("server_options")
    raise "Missing server connection address for client" unless stream_info[stream].has_key?("server_ip")
    raise "Missing client side options" unless stream_info[stream].has_key?("client_options")
    stream_container[stream] = {}
    stream_container[stream]['options'] = OpenStruct.new
    stream_container[stream]['options'].dscp = stream_info[stream]['dscp'] if stream_info[stream].has_key?('dscp')
    stream_info[stream].has_key?("udp") ? stream_container[stream]['options'].udp = stream_info[stream]['udp'] : stream_container[stream]['options'].udp = false
    stream_container[stream]['options'].server_ip = stream_info[stream]['server_ip']
    stream_info[stream].has_key?("port") ? stream_container[stream]['options'].port = stream_info[stream]['port'] : stream_container[stream]['options'].port = base_port
    stream_container[stream]['options'].client_bind, stream_container[stream]['options'].local_client = parse_options(stream_info[stream]['client_options'])
    stream_container[stream]['options'].server_bind, stream_container[stream]['options'].local_server = parse_options(stream_info[stream]['server_options'])
    stream_container[stream]['options'].logfile = options.logfile
    stream_container[stream]['options'].verbose = options.verbose
    stream_container[stream]['options'].debug = options.debug
    stream_container[stream]['options'].stream_name = stream
    stream_container[stream]['options'].rsi = options.rsi
    stream_container[stream]['iperf'] = IPerf.new(stream_container[stream]['options'])
    base_port += 1
end

logger.log("Running streams")
# Now run each stream container
stream_container.each_key do |stream|
    threads << Thread.new { stream_container[stream]['iperf'].iperf_test; stream_results[stream] = IPerf_Data.new(stream_container[stream]['iperf'].iperf_results) }
end
logger.log("Waiting for stream threads to finish")
# Wait for processes to finish
threads.each { |x| x.join }
logger.log("Parsing results and cleaning up")
# Push results out to the log or console as needed
stream_results.each_key do |stream|
    bandwidth_results << bandwidth_check(stream_info[stream]['bandwidth'], stream_results[stream].bandwidth)
    used_bandwidth += stream_results[stream].bandwidth
end

final_results = priority_sort(bandwidth_results, (options.available_bandwidth - used_bandwidth))

final_results.each do |br|
    logger.log(br, :info)
end

# "stream_#": {
#   "bandwidth": "priority #|size - 100Mb 100MB etc or 10Mb-20Mb - specify min-max", "priority 7; 10Mb-20Mb", "priority 3", "10Mb-20Mb"
#   "dscp": "value",
#   "udp": true|false,
#   "port": value,
#   "server_ip": "10.0.0.249",
#   "server_options": "-bind IP -local|remote",
#   "client_options": "-bind IP -local|remote"
# }
