#! /usr/bin/ruby

require 'socket'

$port = '77777'

class PeerB
    def initialize
        service = TCPServer.new('0.0.0.0', $port)
        while (session = service.accept)
            command = session.gets.chomp
            puts "#{session.peeraddr[3]} request: #{command}"
            case command
            when /http:/
                session.puts 'OK'
            else
                session.puts 'OK'
            end
            session.close
            break if command == 'exit'
        end
    end
end

PeerB.new
