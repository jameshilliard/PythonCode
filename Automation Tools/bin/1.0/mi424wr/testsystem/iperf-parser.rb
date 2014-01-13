# Class that holds the access to iperf

module IPerf
    private
    def create_iperf_cmd(location, flags)

    end
    module_function :create_iperf_cmd
    def run_iperf(cmd)

    end
    module_function :run_iperf
end

# Library to parse IPERF results, in comma format, from a string.

class IPerf_Data
    attr_reader :date, :local_ip, :local_port, :remote_ip, :remote_port, :id, :timer, :data_size, :bandwidth, :timespan

    def initialize
        @date = ""
        @local_ip = ""
        @local_port = 0
        @remote_ip = ""
        @remote_port = 0
        @id = 0
        @timespan
        @timer = ""
        @data_size = ""
        @bandwidth = ""
    end

    def format_date(d)
        f = d.unpack("A4A2A2A2A2A2")
        formatted_date = "#{f[1]}/#{f[2]}/#{f[0]} #{f[3]}:#{f[4]}:#{f[5]}"
        return formatted_date
    end

    def format_bandwidth(b)
        # Bandwidth comes back in bits, change to Mbps format
        mbits = (b / 1000) / 1000
        return "#{mbits} Mbps"
    end

    def format_data_size(d)
        # Amount of data transmitted comes back in bytes
        datasize = "#{d} Bytes" if d < 1024
        datasize = sprintf("%.02f KB", d/1024.to_f) if d > 1023
        datasize = sprintf("%.02f MB", (d/1024)/1024.to_f) if d > 1048575
        datasize = sprintf("%.02f GB", ((d/1024)/1024)/1024.to_f) if d > 1073741823
        return datasize
    end

    def format_timer(t)
        # Timer comes back in format of 0.0-10.0.. space and round to nearest integer
        end_timer = t.split('-')[1].to_f
        return "#{end_timer.round} seconds"
    end

    def format_timespan(t)
        # Timer comes back in format of 0.0-10.0.. space and round to nearest integer
        start_timer = t.split('-')[0].to_f
        end_timer = t.split('-')[1].to_f
        return "#{start_timer.round} - #{end_timer.round} seconds"
    end

    def parse(iperf_string, suppress = false)
        puts "(IPerf Parser) Received #{iperf_string}" unless suppress
        @date = format_date(iperf_string.split(',')[0])
        @local_ip = iperf_string.split(',')[1]
        @local_port = iperf_string.split(',')[2].to_i
        @remote_ip = iperf_string.split(',')[3]
        @remote_port = iperf_string.split(',')[4].to_i
        @id = iperf_string.split(',')[5].to_i
        @timer = format_timer(iperf_string.split(',')[6])
        @timespan = format_timespan(iperf_string.split(',')[6])
        @data_size = format_data_size(iperf_string.split(',')[7].to_i)
        @bandwidth = format_bandwidth(iperf_string.split(',')[8].to_i)
    end
end
