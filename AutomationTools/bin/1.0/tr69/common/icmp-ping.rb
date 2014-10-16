# Quick and dirty ICMP ping method for Ruby. Returns true if passed, false if not.
require 'socket'
require 'timeout'

module ICMP
    private
    def self.checksum(string)
        length    = string.length
        num_short = length / 2
        check     = 0

        string.unpack("n#{num_short}").each do |short|
        check += short
        end

        if length % 2 > 0
        check += string[length-1, 1].unpack('C').first << 8
        end

        check = (check >> 16) + (check & 0xffff)
        return (~((check >> 16) + check) & 0xffff)
    end

    def ping(host)
        data_string = ""
        sequence = 0
        checksum = 0
        result = false
        timeout = 5
        pack_string = 'C2 n3 A56'

        0.upto(56){|n| data_string << (n%256).chr}
        pid  = Process.pid & 0xffff
        sequence = (sequence + 1) % 65536

        icmp_sock = Socket.new(
            Socket::PF_INET,
            Socket::SOCK_RAW,
            Socket::IPPROTO_ICMP
        )

        packet = [8, 0, checksum, pid, sequence, data_string].pack(pack_string)
        checksum =self.checksum(packet)
        packet = [8, 0, checksum, pid, sequence, data_string].pack(pack_string)

        begin
            saddr = Socket.pack_sockaddr_in(0, host)
        rescue Exception
            icmp_sock.close unless icmp_sock.closed?
            return result
        end

        icmp_sock.send(packet, 0, saddr)

        begin
            Timeout.timeout(timeout) do
                io_array = select([icmp_sock], nil, nil, timeout)
                return false if io_array.nil? || io_array[0].empty?

                pidt = nil
                seq = nil

                data, sender  = icmp_sock.recvfrom(1500)
                port, host    = Socket.unpack_sockaddr_in(sender)
                type, subcode = data[20, 2].unpack('C2')

                case type
                when 0
                    if data.length >= 28
                        pidt, seq = data[24, 4].unpack('n3')
                    end
                else
                    if data.length > 56
                        pidt, seq = data[52, 4].unpack('n3')
                    end
                end
                result = true if pidt == pid && seq == sequence && type == 0
            end
        rescue Exception => err
            puts err
            return false
        ensure
            icmp_sock.close if icmp_sock
        end

        return result
    end
    module_function :ping
end