#!/usr/bin/env ruby

require 'ostruct'
require 'optparse'

step_count = 0

options = OpenStruct.new

options.outputfile = nil
options.description = nil
options.tname = nil
options.edescription = nil
options.add = nil
options.json = "./"
options.pt = FALSE

optionlist = OptionParser.new do |opts|
    opts.separator ""
    opts.banner = "\nBuild an XML test case."
    opts.separator "\nUsage: xmlbuild.rb [OPTIONS] step-1 step-2 step-3 ... Where \"step\" is considered a file with a description in the second line. The .json extension is automatically added to each step unless an extension is specified."
    opts.separator "\nOptions: "
    opts.on("-j DIR", "Directory to grab the JSON files from during XML creation.") { |j| options.json = j }
    opts.on("-o FILE", "File to save to.") { |f| options.outputfile = f }
    opts.on("-d DESC", "Sets the description field for the test case.") { |t| options.description = t }
    opts.on("-t NAME", "Sets the name for the test case.") { |t| options.tname = t }
    opts.on("-e DESC", "Sets the email description field for the test case.") { |t| options.edescription = t }
    opts.on("--add DATA", "Adds DATA to the end of the command line for the test system options.") { |a| options.add = a }
    opts.on("--pt", "Specifically build XML scripts for Port Triggering.") { |o| options.pt = TRUE }
    opts.on_tail("-h", "--help", "Displays this help menu.") { puts optionlist; exit }
end

class XMLBuild
    attr :xml_matrix
    
    def initialize
        @xml_matrix = ""
        @step_count = 0
        @space2 = "\n  "
        @space4 = "\n    "
        @space6 = "\n      "
        @space8 = "\n        "
    end

    def xml_addstep(desc, script)
        @xml_matrix << "#{@space4}<step>#{@space6}<name>#{@step_count}</name>#{@space6}<desc>#{desc}</desc>#{@space6}<script>#{script}</script>#{@space6}<passed></passed>#{@space6}<failed></failed>#{@space4}</step>"
        @step_count += 1
    end

    def xml_header(name, emaildesc, desc)
        @xml_matrix << "<testcase>#{@space2}<name>#{name}</name>#{@space2}<emaildesc>#{emaildesc}</emaildesc>#{@space2}<description>#{desc}</description>#{@space2}<id>#{@space4}<manual></manual>#{@space4}<auto></auto>#{@space2}</id>#{@space2}<code></code>#{@space2}<stage>"
    end

    def xml_tail
        @xml_matrix << "#{@space2}</stage>\n</testcase>"
    end

    def get_desc(f)
        if f.match(/getconfig/i)
            return "MTP - Get current DUT configuration"
        else
            temp = File.open(f).readlines
            return temp[1].sub(/\A.../, '').chomp
        end
    end

    def build_script(f, fwlevel = nil, add = nil)
        if f.match(/getconfig/)
            cmd_string = "ruby $U_RUBYBIN/getConfig.rb -o $G_CURRENTLOG/dut_config.cfg -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0"
        else
            temp = File.open(f).read
            cmd_string = ""
            f = f[f.rindex('/')+1..f.length] if f.include?('/')
            if temp.match(/iperf/im)
                cmd_string << "ruby $U_MI424/testSystem.rb $G_DUMMY -o $G_CURRENTLOG/iperflogs_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG --iperf-complete --start-tshark --use-sshcli 'perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -n -v' --local-ip 192.168.1.2 --remote-ip 10.10.10.1 --threads 5" if temp.match(/192.168.1.2/im)
                cmd_string << "ruby $U_MI424/testSystem.rb $G_DUMMY -o $G_CURRENTLOG/iperflogs_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG --iperf-complete --start-tshark --use-sshcli 'perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -n -v' --local-ip 192.168.1.42 --remote-ip 10.10.10.1 --threads 5" if temp.match(/192.168.1.42/im)
                unless temp.match(/server/im)
                    cmd_string << " --iperf-server REMOTE"
                end
                cmd_string << " #{add}" unless add == nil
            elsif temp.match(/port scan.block|port scan.allow/im)
                if fwlevel == TRUE
                    cmd_string << "ruby $U_MI424/testSystem.rb $G_DUMMY -o $G_CURRENTLOG/scanlogs_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG -c nmap --filter-override"
                else
                    cmd_string << "ruby $U_MI424/testSystem.rb $G_DUMMY -o $G_CURRENTLOG/scanlogs_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG -c nmap"
                end
                cmd_string << " #{add}" unless add == nil
            elsif temp.match(/port scan/im)
                cmd_string << "ruby $U_MI424/testSystem.rb $G_DUMMY -o $G_CURRENTLOG/scanlogs_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG --start-tshark --use-sshcli 'perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -n -v' --local-ip 192.168.1.2 --remote-ip 10.10.10.1" if f.match(/pc1/im)
                cmd_string << "ruby $U_MI424/testSystem.rb $G_DUMMY -o $G_CURRENTLOG/scanlogs_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG --start-tshark --use-sshcli 'perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -n -v' --local-ip 192.168.1.42 --remote-ip 10.10.10.1" if f.match(/pc2/im)
                cmd_string << " #{add}" unless add == nil
            elsif temp.match(/telnet/im)
                cmd_string << "ruby $U_MI424/configDevice.rb $G_DUMMY -o $G_CURRENTLOG/config_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0"
            elsif temp.match(/static nat: verify/im)
                cmd_string << temp.match(/\"ruby.*\"/).to_s.delete('"')
            else
                cmd_string << "ruby $U_MI424/configDevice.rb $G_DUMMY -o $G_CURRENTLOG/config_#{f.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{f} -d $U_DEBUG -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0"
            end
            unless add == nil
                if temp.match(/static nat.*pc2/im)
                    cmd_string.sub!(/--local-ip 192.168.1.2/, "--local-ip 192.168.1.42")
                elsif temp.match(/check dut wan ip/im)
                    cmd_string.sub!(/--local-ip 192.168.1.2/, "--local-ip 192.168.1.3")
                end
            end
        end
        return cmd_string
    end
end

optionlist.parse!(ARGV)

if ARGV.length == 0
    puts "No steps added on command line. Exiting."
    exit
end unless options.pt == TRUE

if options.description == nil
    puts "Please add a description with the -d option."
    exit
end unless options.pt == TRUE

options.add = "--start-tshark --use-sshcli 'perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -n -v' --local-ip 192.168.1.2 --remote-ip 10.10.10.1" if options.add == "tshark"

if options.pt
    tc_count = 1
    json_file_list = Dir.entries(options.json).delete_if { |j| j.match(/\A\.|remove_rules/) }
    json_file_list.each do |t|
        desc = ""
        ibound = ""
        obound = ""
        edesc = "Port Triggering testing with iperf"
        outputfile = "tc_ptrigger_#{tc_count}.xml"
        tc_count += 1
        jfile = open("#{options.json}/#{t}").read
        ibound << jfile.match(/outgoing.+?;\",/).to_s.chomp.scan(/\w+?:any,\d+?;/).to_s.sub(/;\z/, '').gsub(/;/, ' and ').gsub(/,/,' -> ').gsub(/any/, ' Any')
        obound << jfile.match(/incoming.+?;\"/).to_s.chomp.scan(/\w+?:any,\d+?;/).to_s.sub(/;\z/, '').gsub(/;/, ' and ').gsub(/,/,' -> ').gsub(/any/, ' Any')
        desc << "Port Triggering using outbound ports #{obound} to trigger inbound ports #{ibound}\nConfigured from #{t.sub(/.*\/tc/, 'tc')}"
        x = XMLBuild.new
        x.xml_header(outputfile, edesc, desc)
        x.xml_addstep("Configure device with port triggering rules", "ruby $U_MI424/configDevice.rb $G_DUMMY -g $G_CURRENTLOG/ -o $G_CURRENTLOG/config_#{t.sub(/\.json\z/,'')}.log -f $U_TESTPATH/#{t} -d $U_DEBUG -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0")
        x.xml_addstep("Test port triggering ports", "ruby $U_MI424/testSystem.rb $G_DUMMY -o $G_CURRENTLOG/iperf_results.log -f $G_CURRENTLOG/iperf_test.json -d $U_DEBUG #{options.add}")
        x.xml_addstep("Remove Port Triggering rules", "ruby $U_MI424/configDevice.rb $G_DUMMY -o $G_CURRENTLOG/config_remove_rules.log -f $U_TESTPATH/tc_remove_rules.json -d $U_DEBUG -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0")
        x.xml_tail
        output = File.new("#{options.outputfile}/#{outputfile}", "w+")
        output.write(x.xml_matrix)
        output.close
    end
    exit
end
x = XMLBuild.new
# options.tname == nil ? options.tname = "#{options.outputfile} - #{options.edescription}" : options.tname = "#{options.outputfile} - #{options.tname}"
x.xml_header(options.outputfile.sub(/.*\/tc/, 'tc'), options.edescription, options.description)
options.description.match(/maximum/im) ? fw = TRUE : fw = FALSE
ARGV.each do |step|
    if step.match(/\..+\z/)
        filename = step
    else
        filename = "#{step}.json"
    end
    x.xml_addstep(x.get_desc("#{options.json}/#{filename}"), x.build_script("#{options.json}/#{filename}", fw, options.add))
end

x.xml_tail

output = File.new(options.outputfile, "w+")
output.write(x.xml_matrix)