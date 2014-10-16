# This will eventually take the place of the current iperf parser as it will be expanded and easier to work with than the original hack.

require 'common/ipcheck'
require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'open3'
require 'ostruct'
require 'timeout'

class FlagException < RuntimeError
    attr :msg
    def initialize(message)
        @msg = message
    end
end

class RemoteProcess
    attr_accessor :results, :open
    def initialize(host, remote_user="root", remote_pass="actiontec")
        @rs_data = { :host => host, :user => remote_user, :pass => remote_pass }
        @rs = Net::SSH.start(host, remote_user, :password => remote_pass)
        @open = TRUE
    end

    def command(cmd, wait_string="", timeout=60)
        @command = cmd
        wait_test = Queue.new
        if wait_string.empty?
            @results = @rs.exec!("#{@command} 2>&1")
        else
            end_timer = Time.now.to_i + 30
            @results = ""
            wait_test.push(:dummy)
            @cmd_thread = Thread.new do
                @rs.exec("#{@command} 2>&1") { |o,s,d| @results << d }
                @rs.loop
            end
            while wait_test.length > 0
                if @results.match(/bind failed/i)
                    raise FlagException.new("Test issues - retrying...")
                elsif @results.match(/#{wait_string}/i)
                    wait_test.pop
                elsif Time.now.to_i > end_timer
                    raise FlagException.new "Remote process timed out while waiting for string: #{wait_string}."
                end
            end
        end
    end
    
    def scp(from, to)
        Net::SCP.start(@rs_data[:host], @rs_data[:user], :password => @rs_data[:pass]) { |scp| scp.upload!(from, to) }
    end

    def close
        if @open
            Timeout::timeout(20) { @rs.exec!("kill -9 `ps aux | awk '/#{@command}/ && !/awk/ {print $2}'`") }
            @open = FALSE
        end
    end
end

# Class for running, stopping and getting data from IPerf - locally or remotely.
class IPerf
    attr_accessor :iperf_results
    def initialize(options)
        @client_flags = flag_parse(:client => TRUE, :dscp => options.dscp, :udp => options.udp, :tradeoff => false, :bidirectional => false, :ip => options.server_ip, :port => options.port, :bind_ip => options.client_bind)
        @server_flags = flag_parse(:client => false, :dscp => false, :udp => options.udp, :tradeoff => false, :bidirectional => false, :ip => false, :port => options.port, :bind_ip => options.server_bind)
        @local_client = options.local_client
        @local_server = options.local_server
        @rsi = options.rsi
        @stream_name = options.stream_name
        @logger = Log.new(options, @stream_name)
        @iperf_results = "No data"
    end

    def flag_parse(flag_options)
        flags = ""

        # Server or client based on client flag - true or false
        flag_options[:client] ? flags << "-y C -c #{flag_options[:ip]}" : flags << "-s"
        flags << " -d -L #{flag_options[:bidirectional]}" if flag_options[:bidirectional]
        flags << " -r -L #{flag_options[:tradeoff]}" if flag_options[:tradeoff]
        flags << " -S #{flag_options[:dscp]}" if flag_options[:dscp]
        flags << " -B #{flag_options[:bind_ip]}" if flag_options[:bind_ip]
        flags << " -u" if flag_options[:udp] unless flag_options[:client]
        flags << " -u -b 1000M" if flag_options[:udp] if flag_options[:client]
        flags << " -p #{flag_options[:port]}" if flag_options[:port]
        return flags
    end

    # Method to take care of everything related to the remote client/server of iperf
    # (host, remote_user="root", remote_pass="actiontec")
    def remote_iperf
        @rs_iperf = RemoteProcess.new(@rsi['ip'], @rsi['user'], @rsi['pass'])
        unless @local_server
            @rs_iperf.command("iperf #{@server_flags}", "server listening")
            @logger.log("Remote server listening")
        end
        unless @local_client
            @logger.log("Running remote client")
            @rs_iperf.command("iperf #{@client_flags}")
            results = @rs_iperf.results.split("\n")
            if results.length > 1
                @iperf_results = results[1].dup
            else
                @iperf_results = results[0].dup
            end
        end
    end

    # Method to take care of everything related to the local client/server of iperf
    def local_iperf
        if @local_server
            iperf_system = Open3.popen3("iperf #{@server_flags}")
            done_waiting = FALSE
            output = ""
            while not done_waiting
                output << iperf_system[1].readpartial(1)
                done_waiting = TRUE if output.match(/server listening/im)
            end
            @logger.log("Local server listening")
        end
        if @local_client
            @logger.log("Running local client")
            results = IO.popen("iperf #{@client_flags} 2>&1").read.split("\n")
            if results.length > 1
                @iperf_results = results[1]
            else
                @iperf_results = results[0]
            end
        end
    end

    def stop_iperf
        pid = ""
        @rs_iperf.close if defined?(@rs_iperf)
        if @local_client
            pid = `ps aux | awk '/iperf #{@client_flags}/ && !/awk/ {print $2}'`.chomp
            `kill -9 #{pid}` unless pid.empty?
        end
        if @local_server
            pid = `ps aux | awk '/iperf #{@server_flags}/ && !/awk/ {print $2}'`.chomp
            `kill -9 #{pid}` unless pid.empty?
        end
    end

    def iperf_test
        rt_count = 0
        begin
            if @local_client
                if @local_server
                    local_iperf
                else
                    remote_iperf
                    local_iperf
                end
            else
                if @local_server
                    local_iperf
                    remote_iperf
                else
                    remote_iperf
                end
            end
            puts "#{@stream_name}:#{@iperf_results.inspect}"
            
            stop_iperf
            puts "#{@stream_name}:#{@iperf_results.inspect}"
            raise FlagException.new("Test issues - retrying...") if @iperf_results.match(/failed/i)
            raise "Received nothing back from iperf test" if @iperf_results.nil?
        rescue FlagException => f
            if rt_count < 3
                stop_iperf
                @logger.log("#{f.msg} #{rt_count}")
                rt_count += 1
                retry
            else
                @logger.log("Tried three times, but unable to get successful results. Moving on...", :warn)
                @logger.log("IPerf failed. Result string from iperf client was: #{@iperf_results.chomp}", :error)
            end
        rescue Timeout::Error
                # Do nothing. It doesn't matter. 
        rescue => f
            if defined?(@rs_iperf)
                rt_count += 1
                if rt_count < 3
                    @logger.log("Encountered a small problem (#{f.message}.) Rerunning the test now.")
                    stop_iperf
                    retry
                else
                    @logger.log(f.message)
                    @logger.log("Unable to rerun test. Exiting.", :fatal)
                    puts f.backtrace
                end
            else
                @logger.log f.message
                puts f.backtrace
                exit
            end
        end
    end
end

# Addendums to the String class for data size/rate printing.
class String
    def to_bits
        case self
        when /^([0-9]*\.?[0-9]+)\s*MB$/
            $1.to_f * 8_388_608
        when /^([0-9]*\.?[0-9]+)\s*KB$/
            $1.to_f * 8_192
        when /^([0-9]*\.?[0-9]+)\s*B$/
            $1.to_f * 8
        when /^([0-9]*\.?[0-9]+)\s*Gb/
            $1.to_f * 1000_000_000
        when /^([0-9]*\.?[0-9]+)\s*Mb/
            $1.to_f * 1000_000
        when /^([0-9]*\.?[0-9]+)\s*Kb/
            $1.to_f * 1000
        when /^([0-9]*\.?[0-9]+)\s*b?/
            $1.to_i
        else
            raise "Unrecognized format #{self}"
        end
    end
    def to_bytes
        to_bits / 8
    end
    def to_bps
        d = to_bits
        datasize = "#{d} bps" if d < 1000
        datasize = sprintf("%.02f Kbps", (d/1000).to_f) if d >= 1_000
        datasize = sprintf("%.02f Mbps", (d/1_000_000).to_f) if d >= 1_000_000
        datasize = sprintf("%.02f Gbps", (d/1_000_000_000).to_f) if d >= 1_000_000_000
        return datasize
    end
end

# Container class for iperf data. Separates and stores, includes formatters if wanted
class IPerf_Data
    attr_reader :date, :local_ip, :local_port, :remote_ip, :remote_port, :id, :timer, :data_size, :bandwidth, :timespan

    def initialize(iperf_string = "")
        @date = ""
        @local_ip = ""
        @local_port = 0
        @remote_ip = ""
        @remote_port = 0
        @id = 0
        @timespan = ""
        @timer = ""
        @data_size = 0
        @bandwidth = 0
        unless iperf_string.empty?
            @date = iperf_string.split(',')[0]
            @local_ip = iperf_string.split(',')[1]
            @local_port = iperf_string.split(',')[2].to_i
            @remote_ip = iperf_string.split(',')[3]
            @remote_port = iperf_string.split(',')[4].to_i
            @id = iperf_string.split(',')[5].to_i
            @timer = iperf_string.split(',')[6]
            @timespan = iperf_string.split(',')[6]
            @data_size = iperf_string.split(',')[7].to_i
            @bandwidth = iperf_string.split(',')[8].to_i
        end
    end

    def format_date
        f = @date.unpack("A4A2A2A2A2A2")
        "#{f[1]}/#{f[2]}/#{f[0]} #{f[3]}:#{f[4]}:#{f[5]}"
    end

    def format_bandwidth
        "#{@bandwidth} b".to_bps
    end

    def format_data_size
        "#{@data_size} b".to_bytes
    end

    def format_timer
        "#{@timer.split('-')[1].to_f.round} seconds"
    end

    def format_timespan
        "#{@timespan.split('-')[0].to_f.round} - #{@timespan.split('-')[1].to_f.round} seconds"
    end

    def parse(iperf_string)
        @date = iperf_string.split(',')[0]
        @local_ip = iperf_string.split(',')[1]
        @local_port = iperf_string.split(',')[2].to_i
        @remote_ip = iperf_string.split(',')[3]
        @remote_port = iperf_string.split(',')[4].to_i
        @id = iperf_string.split(',')[5].to_i
        @timer = iperf_string.split(',')[6]
        @timespan = iperf_string.split(',')[6]
        @data_size = iperf_string.split(',')[7].to_i
        @bandwidth = iperf_string.split(',')[8].to_i
    end
end