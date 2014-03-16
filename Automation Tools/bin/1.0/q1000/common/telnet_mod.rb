# Telnet modification to allow OpenSSL::SSL::SSLSocket classes in telnet
require "net/telnet"
require "openssl"
module Net
    class Telnet
        
        alias initialize_org initialize

        def initialize(options) # :yield: mesg
          @options = options
          @options["Host"]       = "localhost"   unless @options.has_key?("Host")
          @options["Port"]       = 23            unless @options.has_key?("Port")
          @options["Prompt"]     = /[$%#>] \z/n  unless @options.has_key?("Prompt")
          @options["Timeout"]    = 10            unless @options.has_key?("Timeout")
          @options["Waittime"]   = 0             unless @options.has_key?("Waittime")
          unless @options.has_key?("Binmode")
            @options["Binmode"]    = false
          else
            unless (true == @options["Binmode"] or false == @options["Binmode"])
              raise ArgumentError, "Binmode option must be true or false"
            end
          end

          unless @options.has_key?("Telnetmode")
            @options["Telnetmode"] = true
          else
            unless (true == @options["Telnetmode"] or false == @options["Telnetmode"])
              raise ArgumentError, "Telnetmode option must be true or false"
            end
          end

          @telnet_option = { "SGA" => false, "BINARY" => false }

          if @options.has_key?("Output_log")
            @log = File.open(@options["Output_log"], 'a+')
            @log.sync = true
            @log.binmode
          end

          if @options.has_key?("Dump_log")
            @dumplog = File.open(@options["Dump_log"], 'a+')
            @dumplog.sync = true
            @dumplog.binmode
            def @dumplog.log_dump(dir, x)  # :nodoc:
              len = x.length
              addr = 0
              offset = 0
              while 0 < len
                if len < 16
                  line = x[offset, len]
                else
                  line = x[offset, 16]
                end
                hexvals = line.unpack('H*')[0]
                hexvals += ' ' * (32 - hexvals.length)
                hexvals = format("%s %s %s %s  " * 4, *hexvals.unpack('a2' * 16))
                line = line.gsub(/[\000-\037\177-\377]/n, '.')
                printf "%s 0x%5.5x: %s%s\n", dir, addr, hexvals, line
                addr += 16
                offset += 16
                len -= 16
              end
              print "\n"
            end
          end

          if @options.has_key?("Proxy")
            if @options["Proxy"].kind_of?(Net::Telnet)
              @sock = @options["Proxy"].sock
            elsif @options["Proxy"].kind_of?(IO)
              @sock = @options["Proxy"]
            elsif @options["Proxy"].kind_of?(OpenSSL::SSL::SSLSocket)
              @sock = @options["Proxy"]
            else
              raise "Error: Proxy must be an instance of Net::Telnet or IO."
            end
          else
            message = "Trying " + @options["Host"] + "...\n"
            yield(message) if block_given?
            @log.write(message) if @options.has_key?("Output_log")
            @dumplog.log_dump('#', message) if @options.has_key?("Dump_log")

            begin
              if @options["Timeout"] == false
                @sock = TCPSocket.open(@options["Host"], @options["Port"])
              else
                timeout(@options["Timeout"]) do
                  @sock = TCPSocket.open(@options["Host"], @options["Port"])
                end
              end
            rescue TimeoutError
              raise TimeoutError, "timed out while opening a connection to the host"
            rescue
              @log.write($ERROR_INFO.to_s + "\n") if @options.has_key?("Output_log")
              @dumplog.log_dump('#', $ERROR_INFO.to_s + "\n") if @options.has_key?("Dump_log")
              raise
            end
            @sock.sync = true
            @sock.binmode

            message = "Connected to " + @options["Host"] + ".\n"
            yield(message) if block_given?
            @log.write(message) if @options.has_key?("Output_log")
            @dumplog.log_dump('#', message) if @options.has_key?("Dump_log")
          end

          super(@sock)
        end # initialize
    end
end