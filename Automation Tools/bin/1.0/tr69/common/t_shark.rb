# Class to control t-shark interaction - start, stop, save

class T_Shark
    attr_accessor :tshark_results, :tshark_interface, :tshark_command, :save_file, :tshark_flags, :sshcli, :kill_command
    # Main controller 
    def initialize(options, bind_ip)
        @tshark_results = ""
        unless options.is_a?(Hash)
            raise ArgumentError, "Missing T-Shark command or hash options." unless @tshark_command = options
        else
            @save_file = options[:file] || nil
            @tshark_common_flags = options[:flags] || "-q -x -w -"
            @tshark_other_flags = options[:other_flags] || ""
            @tshark_interface = options[:interface] || false
            @sshcli = options[:sshcli] || false
        end
        if @sshcli
            @kill_command = "#{@sshcli} \"killall tshark\""
            @tshark_interface = "-i " + `#{@sshcli} ifconfig |grep -B 2 -e \"#{bind_ip} \" | awk '/Link encap/ {split ($0,A," "); print A[1]}'`.chomp unless @tshark_interface if bind_ip
            @tshark_command = "#{@sshcli} \"tshark #{@tshark_common_flags} #{@tshark_other_flags} #{@tshark_interface || ""}\""
        else
            @kill_command = "killall tshark"
            @tshark_interface = "-i " + `ifconfig |grep -B 2 -e \"#{bind_ip} \" | awk '/Link encap/ {split ($0,A," "); print A[1]}'`.chomp unless @tshark_interface if bind_ip
            @tshark_command = "tshark #{@tshark_common_flags} #{@tshark_other_flags} #{@tshark_interface || ""}"
        end
        @shark_thread = Thread.new { @tshark_results = `#{@tshark_command}` }
    end

    # Save output from t-shark
    def save(save_to_other=false)
        unless save_to_other
            raise ArgumentError, "Missing save file paremeter." if @save_file == nil
            File.new(@save_file, "w").write(@tshark_results)
        else
            File.new(save_to_other, "w").write(@tshark_results)
        end
    end
    
    # Stop t-shark
    def stop
        kill = `#{@kill_command}`
        @shark_thread.join
    end

    # Stops and saves
    def killsave(file=nil)
        kill = `#{@kill_command}`
        @shark_thread.join
        if file == nil
            File.new(@save_file, "w").write(@tshark_results)
        else
            File.new(file, "w").write(@tshark_results)
        end
    end
end
