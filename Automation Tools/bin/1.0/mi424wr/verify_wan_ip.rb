#!/usr/bin/env ruby
# Very quick and dirty way to check what the IP is from the LAN machine going to the WAN machine
# Only useful for static NAT testing purposes.
# example command line: ./verify_wan_ip.rb 10.10.10.20 192.168.1.2 10.10.10.1 output.log
# Usage: verify_wan_ip.rb expected-WAN-IP local_bind_IP IP_to_ping_to logfile
# Outputs: 10.10.10.1 saw 192.168.1.2 as 10.10.10.20 -> Passed
# Uses SSHCLI command: 'perl $U_COMMONBIN/sshcli.pl -d $U_RMTPC -u $U_PCUSER  -p $U_PCPWD -v'
tcpdump = ""
tstring = ""

raise "Missing necessary command line arguments. Usage: verify_wan_ip.rb expected-WAN-IP local_bind_IP IP_to_ping_to logfile" if ARGV.length < 3

sshcli = "perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -n -v"
remote_interface = `#{sshcli} ifconfig |grep -B 2 -e \"#{ARGV[2]} \" | awk '/Link encap/ {split ($0,A," "); print A[1]}'`.chomp
puts "Found remote interface to be #{remote_interface}"

tdump = Thread.new {
    tcpdump = `#{sshcli} \"tcpdump -i #{remote_interface} -n -t -l\"`
}
sleep 2
pinglog = `ping -I #{ARGV[1]} -c 4 #{ARGV[2]}`
kill = `#{sshcli} \"killall tcpdump\"`
tdump.join
begin
    tstring = tcpdump.slice(/.+?\d+?\.\d+?\.\d+?\.\d+? > #{ARGV[2]}: ICMP echo/).delete('^[0-9>.]')

    if tstring.empty?
        puts "Failed: Didn't receive a valid response from sshcli or tcpdump, got: #{tcpdump}"
        exit
    else
        tstring.include?(ARGV[0]) ? out = "#{ARGV[2]} saw #{ARGV[0]} as #{tstring.split('>')[0].strip} -> Passed\n" : out = "#{ARGV[2]} saw #{ARGV[0]} as #{tstring.split('>')[0].strip} -> Failed\n"
    end
    puts "[RESULTS] :: #{out}"

    output = File.open(ARGV[3], "w")
    output.write("[RESULTS] :: #{out}")
    output.write("\n[PING LOG] -> \n#{pinglog}")
    output.write("\n[TCPDUMP LOG] => \n#{tcpdump}")
    output.close
rescue
    puts "Failed: Didn't receive a valid response from sshcli or tcpdump, got: #{tcpdump}"
    puts "Ping log: #{pinglog}"
    exit
end

