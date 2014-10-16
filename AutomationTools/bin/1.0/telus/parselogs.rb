#!/usr/bin/env ruby
# == Copyright
# (c) 2010 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# Parses log files from the Telus V1000H monitor

require 'optparse'
require 'ostruct'
require 'time'
require 'common/ip_utils'
@options = OpenStruct.new
@options.logs = []
@options.output = ""
@options.hour_threshold = 86400
@options.memory_threshold = 28000
@options.cpu_threshold = 0.7

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Telus V1000H monitor parser"
    opts.on("-l LOGS", "--logs", "Log files to parse separated by commas. Will accept wildcards, i.e. *.log") { |v| @options.logs = v.split(",") }
    opts.on("-o OUTFILE", "--output", "Copy parser results to specified output file. Log file details will be sectioned within the single file") { |v| @options.output = v }
    opts.on("-h HOURS", "Sets the hour threshold for grouping. Default is 24 hours.") { |v| @options.hour_threshold = v.to_i * 2600 }
    opts.on("-c CPU", "Sets CPU threshold. Defaults to 0.7.") { |v| @options.cpu_threshold = v.to_f }
    opts.on("-m MEMORY", "Sets memory threshold (in KB). Defaults to 28000 KB") { |v| @options.memory_threshold = v.to_i }
    opts.on_tail("-h", "--help", "Shows these help @options.") { puts opts; exit }
end

def parse_uptime(t)
    # Device Uptime: 2 days,  1:42
    # return (t.delete('^[0-9]').to_i)*60 if t.match(/min/i)
    days = 0
    hours = 0
    minutes = 0
    hours = t.slice(/\d+:/).delete('^[0-9]').to_i * 3600 if t.match(/\d+:/)
    minutes = t.slice(/:\d+/).delete('^[0-9]').to_i * 60 if t.match(/:\d+/)
    minutes = t.slice(/\d+ min/).delete('^[0-9]').to_i * 60 if t.match(/min/i)
    days = t.slice(/\d+ day/).delete('^[0-9]').to_i * 86400 if t.match(/day/i)
    return hours+minutes+days
end

def parse(file)
    hpna_sent_packets = 0
    hpna_recv_packets = 0
    hpna_active = FALSE
    results = ""
    resets = 0
    retrains = 0
    day = 1
    ts = 0
    day_start = 0
    prior_uptime = 0
    days = []

    connection_type = :dsl
    log = File.open(file).read

    timestamps = log.scan(/(?:\[Timestamp).*\]/)
    return "" if timestamps.empty? # if we're trying to parse an invalid file then stop here
    timelogs = log.split("="*80).delete_if {|x| x.strip.empty? }

    # find the connection type
    timelogs.each do |v|
        next if v.match(/Failed: Unable to successfully login to GUI even after trying default username and password/)
        connection_type = :ethernet unless v.match(/Connection Status:/)
        break
    end

    # Setup header
    header = sprintf("%-20s: %s\n%-20s: %s\n%-20s: %s %s", "SOAK TEST START TIME", Time.parse(timestamps[0]).ctime, "SOAK TEST END TIME", Time.parse(timestamps.last).ctime, "DUT", log.slice(/\d+\.\d+\.\d+\.\d+/), log.slice(/(\w{2}:){5}\w{2}/))

    timestamps.each_index do |x|
        if Time.parse(timestamps[x]).to_i > day_start+86400
            day_start = Time.parse(timestamps[x]).to_i
            days << []
        end
        days.last << x
    end

    days.each do |daily|
        header << "\n\n#{sprintf("%-24s", "Day "+day.to_s)}\tUPTIME\tCPU\tMEMORY\tWAN\tLAN\tRETRAIN\tGUI\tHPNA\n#{'-'*92}\n"
        daily.each do |cycle|
            ctype = (timelogs[cycle].match(/Connection Status/) ? :dsl : :ethernet)
            results = "#{Time.parse(timestamps[ts]).ctime}"
            current_resets = 0
            # 0 = uptime, 1 = cpu, 2 = memory, 3 = wan, 4 = lan, 5 = retrain, 6 = gui, 7 = xdsl, 8 = hpna
            vals = [TRUE] * 8

            # uptime
            if timelogs[cycle].slice(/Device Uptime:.*/).nil?
                current_uptime = 0
            else
                current_uptime = parse_uptime(timelogs[cycle].slice(/Device Uptime:.*/).split("Uptime:")[1])
            end
            vals[0] = FALSE if ((Time.parse(timestamps[ts]).to_i) - (Time.parse(timestamps[ts-1]).to_i) + prior_uptime - 300) > current_uptime if ts > 0
            prior_uptime = current_uptime

            # cpu
            if timelogs[cycle].slice(/Load average:.*/).nil?
                vals[1] = FALSE
            else
                cpu_loads = timelogs[cycle].slice(/Load average:.*/).split(":")[1].delete(' ').split(",")
                cpu_loads.each { |x| vals[1] = FALSE if @options.cpu_threshold < x.to_f }
            end

            # Memory
            unless timelogs[cycle].slice(/MemFree:.*/).nil?
                memory = timelogs[cycle].slice(/MemFree:.*/).delete('^[0-9]').to_i
                vals[2] = FALSE if @options.memory_threshold > memory
            else
                vals[2] = FALSE
            end

            # WAN
            # if we use ping results we'd use this .scan(/\d packets transmitted.*/)[1] .. but we can't because the routes are not setup properly
            vals[3] = FALSE if timelogs[cycle].slice(/IP Address:.*/).ip.empty? unless timelogs[cycle].slice(/IP Address:.*/).nil?
            vals[3] = FALSE if timelogs[cycle].slice(/IP Address:.*/).nil?
            vals[3] = FALSE unless ctype == connection_type

            # LAN
            vals[4] = FALSE if timelogs[cycle].scan(/\d packets transmitted.*/)[0].split(",")[2].delete('^[0-9]').to_i == 100

            # Retrain
            if timelogs[cycle].slice(/Retrains:.*/).delete('^[0-6]').to_i > retrains
                retrains = timelogs[cycle].slice(/Retrains:.*/).delete('^[0-6]').to_i
                vals[5] = FALSE
            end unless timelogs[cycle].slice(/Retrains:.*/).nil?
            vals[5] = FALSE if timelogs[cycle].slice(/Retrains:.*/).nil?

            # GUI Failed: Unable to successfully login to GUI even after trying default username and password
            vals[6] = FALSE if timelogs[cycle].match(/Failed: Unable to successfully login to GUI even after trying default username and password/)

            # HPNA
            unless timelogs[cycle].scan(/rst=\d+/).empty?
                hpna_active = TRUE
                # Check resets
                timelogs[cycle].scan(/rst=\d+/).each { |x| current_resets += x.delete('^[0-9]').to_i }
                if current_resets > resets
                    resets += current_resets
                    vals[7] = FALSE
                end
                # Check packets
                unless timelogs[cycle].match(/Failed: Unable to successfully login to GUI even after trying default username and password/)
                    rcv = timelogs[cycle].slice(/^- Packets Received: \d+/).delete('^[0-9]').to_i
                    snt = timelogs[cycle].slice(/^- Packets Sent: \d+/).delete('^[0-9]').to_i
                    vals[7] = FALSE if rcv < hpna_recv_packets
                    vals[7] = FALSE if snt < hpna_sent_packets
                    hpna_recv_packets = rcv
                    hpna_sent_packets = snt
                end
            else
                if hpna_active
                    vals[7] = FALSE
                else
                    vals[7] = :na
                end
            end

            # XDSL - not in use
            # vals[8] = FALSE if we had something to do here

            # Set PASS/FAIL values
            vals.each { |x| results << (x ? (x==:na ? "\tN/A" : "\tPASS") : "\tFAIL") }
            ts += 1
            header << results+"\n"
        end
        day += 1
    end
    header
end

# Fix the wildcard expansion so optparse will see the option correctly
o = ""
arguments = ARGV
files = []
start_index = arguments.index("-l") + 1
o = arguments[arguments.index("-o")+1] unless arguments.index("-o").nil?

arguments[start_index..-1].each do |f|
    break if f.match(/\A-/)
    unless f == o
        files << f
        arguments.delete(f)
    end
end

arguments.insert(start_index, files.join(','))
opts.parse!(arguments.compact)

# Just in case this is used on a shell that does not automatically expand wild cards
unless (expand=@options.logs.select {|x| x.match(/\*/) }).empty?
    expand.each do |ex|
        @options.logs.delete(ex)
        @options.logs << Dir.glob(ex).delete(o)
    end
end

results = []

@options.logs.each do |current|
    results << parse(current)
end

if @options.output.empty?
    results.each {|x| puts x; puts "\n" }
else
    File.new(@options.output, "w+")
    out = File.open(@options.output, "a")
    results.each {|x| out.puts x; out.puts "\n"; puts x; puts "\n" }
    out.close
end