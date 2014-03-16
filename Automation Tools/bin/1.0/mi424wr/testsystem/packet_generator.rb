#!/usr/bin/env ruby

# Generates packets. Obviously.
require 'socket'
require 'optparse'
require 'ostruct'
require 'timeout'

options = OpenStruct.new
options.ip = false
options.port = "5001"
options.server = FALSE
options.dscp = FALSE
options.bandwidth = FALSE
options.protocol = "TCP"
options.port_list = []
options.repeat_timer = false
options.repeat = false
options.repeat_times = false

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "This grabs some simple DUT information and returns it using the protocol, ports, and user/pass/ip passed to it."

    opts.on("-i IP", "IP/URL to bind or connect to for testing") { |v| options.ip = v }
    opts.on("-p PORT", "Sets the port number to listen on or send data to. This can be a single number, or a series of numbers separated by commas (no spaces!)") { |v| options.port_list = v.split(',') }
    opts.on("--server", "Sets to be a server instead of a client.") { |v| options.server = TRUE }
    opts.on("--dscp VALUE", "Sets DSCP value") { |v| options.dscp = v }
    opts.on("--bandwidth VALUE", "Sets bandwidth value.") { |v| options.bandwidth = v }
    opts.on("--udp", "Sets protocol to UDP, instead of the default TCP.") { options.protocol = "UDP" }
    opts.on("--packet-size SIZE", "Sets packet size to use. Defaults to 85.3KB.") { |v| options.packet_size = v }
    opts.on("--repeat [TIMER]", "Repeats the test infinitely. If a time value is specified it will repeat after passing that amount of time.") { |x| options.repeat = TRUE; options.repeat_timer = x.to_i unless x.nil?; options.repeat_times = false }
    opts.on("--times NUM", "Repeats test NUM amount of times. This overrides --repeat if also passed.") { |x| options.repeat_times = x.to_i; options.repeat_timer = false; options.repeat = false }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end
class Time
    def self.elapsed
        if block_given?
            t0 = Time.now.to_f
            yield
            Time.now.to_f - t0
        else
            0.0
        end
    end
end
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
        when /^([0-9]*\.?[0-9]+)\s*b/
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
    def to_seconds
        case self
        when /^([0-9]*)\s*s/
            $1.to_i
        when /^([0-9]*)\s*m/
            $1.to_i * 60
        when /^([0-9]*)\s*h/
            $1.to_i * 3600
        end
    end
    def to_bytes_format
        d = to_bits
        datasize = "#{d} b" if d < 1000
        datasize = sprintf("%.02f Kb", (d/1000).to_f) if d >= 1_000
        datasize = sprintf("%.02f Mb", (d/1_000_000).to_f) if d >= 1_000_000
        datasize = sprintf("%.02f Gb", (d/1_000_000_000).to_f) if d >= 1_000_000_000
        return datasize
    end
end
class Float
    def to_bytes_format
        # From bits to bytes
        datasize = "#{self/8} Bytes" if self < 1000
        datasize = sprintf("%.02f KB", (self/8)/1000.to_f) if self >= 1000
        datasize = sprintf("%.02f MB", (self/8)/1000000.to_f) if self >= 1000000
        datasize = sprintf("%.02f GB", (self/8)/1000000000.to_f) if self >= 1000000000
        return datasize
    end
    def to_bps
        datasize = "#{self/8} bps" if (self/8) < 1000
        datasize = sprintf("%.02f Kbps", ((self/8)/1000).to_f) if (self/8) >= 1_000
        datasize = sprintf("%.02f Mbps", ((self/8)/1_000_000).to_f) if (self/8) >= 1_000_000
        datasize = sprintf("%.02f Gbps", ((self/8)/1_000_000_000).to_f) if (self/8) >= 1_000_000_000
        return datasize
    end
end
class Integer
    def to_bytes_format
        # From bits to bytes
        datasize = "#{self/8} Bytes" if self < 1000
        datasize = sprintf("%.02f KB", (self/8)/1000.to_f) if self >= 1000
        datasize = sprintf("%.02f MB", (self/8)/1000000.to_f) if self >= 1000000
        datasize = sprintf("%.02f GB", (self/8)/1000000000.to_f) if self >= 1000000000
        return datasize
    end
    def to_bytes
        # From bits to bytes, no formatting just the raw number
        (self / 8).to_i
    end
    def to_bps
        "#{self / 1000000 } Mbps"
    end
end

class PacketGenerator
    @@id_count = 0
    def initialize(options)
        @bandwidth = options.bandwidth || "1 Gb".to_bits
        @packet_size = options.packet_size || "42.3 KB"
        @packet_size = @packet_size.to_bytes
        @duration = options.duration || 10
        @dscp = options.dscp || 0x00
        @ip = options.ip
        @protocol = options.protocol
        @port = options.port || 5001 # setting a default port, just in case.
        # Container for packet flows
        @packet_flows = []
        @id = @@id_count
        @@id_count += 1
        @name = @id.to_s
        
        puts "Using #{@bandwidth.to_bytes_format} of bandwidth over #{@duration} seconds. #{@protocol} #{@ip}:#{@port}. #{@packet_size} packet size."
    end
    class Packet < String
        MAX_PACKET_SIZE = 87348
        MIN_PACKET_SIZE = 64
        HEADER_SIZE = 18
        EMPTY_PACKET = 0
        MESSAGE_PACKET = 1
        NOTIFICATION_PACKET = 2
        GENERIC_CONTENT = ('a'..'z').to_a.to_s * (((MAX_PACKET_SIZE/26)+1).to_i)
        def initialize(flow_id = 1, packet_info = 0, size = HEADER_SIZE, flags = EMPTY_PACKET)
            self << [size].pack("n")
            self << [flags, flow_id, packet_info, Time.now.to_f].pack("nnNG")
            #puts self.inspect
        end
        def packet_size
            self.unpack("nnnNG")[0]
        end
        def flow_id
            self.unpack("nnnNG")[2]
        end
        def packet_info
            self.unpack("nnnNG")[3]
        end
        def emission_timestamp
            self.unpack("nnnNG")[4]
        end
        def flags
            self.unpack("nnnNG")[1]
        end
    end
    class MessagePacket < Packet
        def initialize(flow_id = 1, packet_id = 0, size = MAX_PACKET_SIZE)
            super(flow_id, packet_id, size, Packet::MESSAGE_PACKET)
            self << GENERIC_CONTENT[0, size - HEADER_SIZE] if size > HEADER_SIZE
        end
    end
    class NotificationPacket < Packet
        def initialize(flow_id = 1, flow_name = flow_id.to_s, packets_count = 0)
            puts "Creating notification packet"
            super(flow_id, packets_count, Packet::HEADER_SIZE + flow_name.size, Packet::NOTIFICATION_PACKET)
            self << flow_name
        end
        def flow_name
            payload_size = Packet::HEADER_SIZE - self.packet_size
            self.unpack("nnnNGA*")[5]
        end
    end

    def packet_stats(sent_count, receive_count)
        lost_count = sent_count - receive_count
        received_data_size = (@packet_size+68)*receive_count
        # log - :STATS, :sent => sent_count, :received => receive_count
        puts "Sent #{sent_count}, received #{receive_count}, lost #{lost_count}. Transfered data: #{received_data_size}, #{(received_data_size*8).to_bps}"
    end

    def server
        BasicSocket.do_not_reverse_lookup = true
        done = false
        case @protocol
        when /tcp/i
            server = TCPServer.open(@ip || Socket::INADDR_ANY, @port)
            # timeout can go here
            while(sock = server.accept)
                packet_size = 0
                content_size = 0
                buffer = ""
                rcvd_packet_count = 0
                loop do
                    data, sender = sock.recvfrom(Packet::MAX_PACKET_SIZE+68)
                    buffer << data
                    if packet_size == 0
                        packet_size = buffer.unpack("n")[0]
                        buffer = buffer[2..-1]
                        content_size = packet_size - 2
                    end
                    while buffer.size >= content_size
                        flags, flow_id, packet_id, emission_timestamp = buffer.unpack("nnNG")
                        unless flags == Packet::NOTIFICATION_PACKET
                            buffer = buffer[content_size..-1]
                            # log - :RECV, :flow => flow_id, :id => packet_id, :size => packet_size, :sent_at => emission_timestamp, :src => sock.peeraddr[3]
                            rcvd_packet_count += 1
                        else
                            notification_name = buffer[(Packet::HEADER_SIZE-2)...content_size].unpack("A*")
                            puts "#{notification_name} From #{sender} #{flags} #{flow_id}, #{emission_timestamp}, #{sock.peeraddr[3]}, #{packet_size}"
                            # log - :NAME, :flow => flow_id, :src => sock.peeraddr[3], :name => notification_name
                            packet_stats(packet_id, rcvd_packet_count)
                            server.close
                            return
                        end
                        if buffer.empty?
                            packet_size = 0
                        else
                            # Get the packet size from the buffer and remove it.
                            packet_size = buffer.unpack("n")[0]
                            buffer = buffer[2..-1]
                            content_size = packet_size - 2
                        end
                    end
                end
            end
        when /udp/i
            server = UDPSocket.open
            server.bind(@ip || Socket::INADDR_ANY, @port)
            
            while not done
                message, sender = server.recvfrom(Packet::MAX_PACKET_SIZE)
                packet_size, flags, flow_id, packet_id, emission_timestamp = message.unpack("nnnNG")
                unless flags == Packet::NOTIFICATION_PACKET
                    # log - :RECV, :flow => flow_id, :id => packet_id, :size => packet_size, :sent_at => emission_timestamp, :src => sender[3]
                    rcvd_packet_count += 1
                else
                    notification_name = message[Packet::HEADER_SIZE..-1].unpack("A*")
                    # log - :NAME, :flow => flow_id, :src => sender[3], :name => notification_name
                    packet_stats(packet_id, rcvd_packet_count)
                    done = true
                end
            end
        end
    end

    def send(msg_opt = 0)
        time_elapsed = 0.0
        packets_count = 0
        send_wait = 0.0
        sock = yield
        sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_TOS, @dscp << 2)
        # log - :SEND, :dest => @ip:@port

        packets_to_send = ((@bandwidth * @duration) / (@packet_size * 8)).to_i
        puts "Sending #{packets_to_send} packets"
        send_interval_time = @duration / packets_to_send
        next_send_time = send_interval_time
        puts "Beginning send"
        #time_set = Time.now.to_i
        while time_elapsed < @duration do
            time_elapsed += Time.elapsed {
                packets_count += 1
                sock.send(MessagePacket.new(@id, packets_count, @packet_size), msg_opt)
                send_wait = next_send_time - time_elapsed
                next_send_time += send_interval_time
                sleep(send_wait > 0 ? send_wait : 0.0)
            }
        end
        
        sleep(rand(3)/10.0)
        sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_TOS, @dscp << 2)
        sock.send(NotificationPacket.new(@id, @name, packets_count),0)
        sock.close
        # log - :STOP, :dest => @ip:@port
    end

    def client
        Thread.abort_on_exception = true
        BasicSocket.do_not_reverse_lookup = true
        begin
            case @protocol
            when /tcp/i
                send { TCPSocket.open(@ip || "127.0.0.1", @port) }
            when /udp/i
                send { sock = UDPSocket.open; sock.connect(@ip || "127.0.0.1", @port); sock }
            end
        rescue
            sleep 10
            retry
        end
    end
end

begin
    opts.parse!(ARGV)

    options.repeat_times.times do
        puts "Repeating #{options.repeat_times} times"
        packet_flows = []
        options.port_list.each do |port|
            options.port = port.to_i
            packet_flows << Thread.new {
                flow = PacketGenerator.new(options)
                options.server ? flow.server : flow.client
            }
        end
        packet_flows.each { |x| x.join }
    end if options.repeat_times
    
    loop do
        puts "Repeating infinitely"
        packet_flows = []
        options.port_list.each do |port|
            options.port = port.to_i
            packet_flows << Thread.new {
                flow = PacketGenerator.new(options)
                options.server ? flow.server : flow.client
            }
        end
        packet_flows.each { |x| x.join }
        sleep options.repeat_timer.to_seconds if options.repeat_timer
    end if options.repeat

    unless options.repeat && options.repeat_times
        puts "Running once"
        packet_flows = []
        options.port_list.each do |port|
            options.port = port.to_i
            packet_flows << Thread.new {
                flow = PacketGenerator.new(options)
                options.server ? flow.server : flow.client
            }
        end
        packet_flows.each { |x| x.join }
    end
end