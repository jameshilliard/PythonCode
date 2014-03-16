require 'socket'

$port = '77777'

class PeerA
    def initialize(target, command)
        begin
            puts 'Attempting a session to Peer B ...'
            session = TCPSocket.new(target, $port)
            session.puts command
            puts session.gets
            session.close
        rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
            $stderr.print "Error: Connection to Peer B failed\n"
        end
    end
end
