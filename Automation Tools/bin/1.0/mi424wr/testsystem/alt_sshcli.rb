# Alternative class for Ruby to SSHCLI
# Why an alternate? sshcli.pl requires a lot of workarounds to be used internally with Ruby code. In some cases
# it's just not worth the effort. Plus it's only useful for single commands. If we want to submit one command,
# interpret the data, and then submit another based on the data, we have to create a new instance of sshcli.pl.
# Doing it this way means we don't, which saves time, which lowers the time it takes to test. 

require 'rubygems'
begin
    require 'net/ssh'
    require 'net/scp'
rescue LoadError
    system("gem install net-ssh")
    system("gem install net-scp")
end

class RemoteSystem
    def initialize(host, remote_user="root", remote_pass="actiontec")
        @remote_system = Net::SSH.start(host, remote_user, :password => remote_pass)
    end

    def command(cmd)
        return @remote_system.exec!(cmd)
    end
    
    def close
        @remote_system.close
    end
end

# This module let's us parse the information from a command line. It serves as backwards compatibility. 

module SSHCLI_Tools
    private
    def parse_sshcli(str)
        flags = {}
        str = `echo #{str}`.chomp if str.include?("$")
        flags['logs'] = str.slice(/-l\s[^-\w][^\s]*/).split(' ')[1] if str.match(/-l\s[^-\w][^\s]*/)
        flags['host'] = str.slice(/-d\s\S*/).split(' ')[1] if str.match(/-d\s\S*/)
        flags['user'] = str.slice(/-u\s[^\W]*/).split(' ')[1] if str.match(/-u\s[^\W]*/)
        flags['pass'] = str.slice(/-p\s[^\W]*/).split(' ')[1] if str.match(/-p\s[^\W]*/)
        return flags
    end
    module_function :parse_sshcli

    def scp(rs_data, from, to)
        Net::SCP.start(rs_data['host'], rs_data['user'], :password => rs_data['pass']) {|scp|
            scp.upload!(from, to)
        }
    end
    module_function :scp
end