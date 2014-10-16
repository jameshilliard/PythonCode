#!/usr/bin/env ruby
# Builds JSON, XML, and TST files for testing the firewall advanced filtering section

require 'ostruct'
require 'optparse'
require 'rubygems'
require 'json'
require 'builder'

options = OpenStruct.new
options.iterations = 100
options.jsondir = "/home/cborn/automation/platform/1.0/verizon2/testcases/fw_remote_admin/json"
options.xmldir = "/home/cborn/automation/platform/1.0/verizon2/testcases/fw_remote_admin/tcases"
options.tstdir = "/home/cborn/automation/testsuites/1.0/verizon/fwrmt"

tst_file = ["-v G_USER=jnguyen\n",
    "-v G_CONFIG=1.0\n",
    "-v G_TBTYPE=fwrmt\n",
    "-v G_PROD_TYPE=bhr2\n",
    "-v G_HTTP_DIR=test/\n",
    "-v G_FTP_DIR=/log/autotest\n",
    "-v G_TESTBED=tb1\n",
    "-v G_FROMRCPT=qaman\n",
    "-v G_FTPUSR=root\n",
    "-v G_FTPPWD=actiontec\n",
    "-v U_USER=admin\n",
    "-v U_PWD=admin1\n",
    "-v G_LIBVERSION=1.0\n",
    "-v G_LOG=$SQAROOT/automation/logs\n",
    "-v U_COMMONLIB=$SQAROOT/lib/$G_LIBVERSION/common\n",
    "-v U_COMMONBIN=$SQAROOT/bin/$G_LIBVERSION/common\n",
    "-v U_TBCFG=$SQAROOT/config/$G_LIBVERSION/testbed\n",
    "-v U_TBPROF=$SQAROOT/config/$G_LIBVERSION/common\n",
    "-v U_VERIWAVE=$SQAROOT/bin/1.0/veriwave/\n",
    "-v U_MI424=$SQAROOT/bin/1.0/mi424wr/\n",
    "-v U_TESTPATH=$SQAROOT/platform/1.0/verizon2/testcases/fw_advanced_filtering/json\n",
    "-v U_TCPATH=$SQAROOT/platform/1.0/verizon2/testcases/fw_advanced_filtering/tcases\n",
    "-v U_DEBUG=3\n",
    "-v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin\n",
    "-v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin\n",
    "-v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json\n",
    "-v G_TST_TITLE=\"Firewall - Advanced Filtering\"\n",
    "\n", "# Initial test bed setup and DUT config\n",
    "-nc $SQAROOT/config/$G_CONFIG/common/testbedcfg.xml;\n",
    "-tc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/reset_dut_to_default.xml\n",
    "-tc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/fw_upgrage_image.xml\n",
    "-tc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/tc_init_dut.xml;fail=finish\n",
    "\n",
    "# Begin test cases\n",
    "# End test cases",
    "\n", "# Log results\n",
    "-label finish\n",
    "-nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml\n",
    "-nc $SQAROOT/config/$G_CONFIG/common/email.xml\n"]

xmlfn = "tc_advanced_filtering_#.xml"
afjsonfn = "tc_advanced_filtering_#.json"

opts = OptionParser.new do |opts|
    opts.separator ""
    opts.banner = "Firewall advanced filtering builder for new testsuite. Builds XML, TST, and JSON files at once."

    opts.on("--jsondir DIR", "Sets JSON directory to save files to.") { |o| options.jsondir = o }
    opts.on("--xmldir DIR", "Sets XML directory to save files to.") { |o| options.xmldir = o }
    opts.on("--tstdir DIR", "Sets test suite directory to save files to. ") { |o| options.tstdir = o }
    opts.on("-i", "--iterations AMOUNT", "Sets amount of iterations. Defaults to 100.") { |o| options.iterations = o.to_i }
    opts.on_tail("-h", "--help", "Displays these options.") { puts opts; exit }
end

# builds a hash for advance filtering
#{
#	"rulename": {
#		"section": "firewall-advanced filtering-input|output",
#		"device": "network (home/office)",
#		"source": "",
#		"destination": "",
#		"services": "User Defined",
#		"ports": "",
#		"set": "-dscp ##:## -priority # -packet|data_length ##:## -drop|accept_connection|accept_packet|reject -log on",
#		"schedule": {
#
#		},
#		"scanbuild": "on"
#	}
#}

def advanced_filtering_rule
    general = %w(-dscp -priority -log)
    data = %w(-packet -data_length)
    actions = %w(-drop -accept_connection -accept_packet -reject)
    values = tags.inject("") { |x, d| x << "#{d} #{rand(100) > 50 ? "on" : "off"} " }.strip

    dscp_value = "%02x" % rand(64)
    dscp_mask = "%02x" % rand(64)
    condition = values.scan(/-.*? \b\w+\b/).inject("") { |x, d| x << d.delete("-").capitalize.sub('_', ' ').sub('https', 'HTTPS').sub('http', 'HTTP').sub('telnet', 'Telnet').sub('secure', 'Secure').sub(/(\bon\b|\boff\b)/, 'turned \1')+"\n" }.strip
    return { "fw_adv_filtering" => { "section" => "firewall-advanced filtering", "set" => values, "scanbuild" => "on" }}, condition
end

def build_xml_test(xmlfilename, condition_1, af_jsonfile, xmldir)
    xmloutput = []
    xmldoc = Builder::XmlMarkup.new(:target => xmloutput, :indent => 1)
    xmldoc.testcase {
        xmldoc.name xmlfilename
        xmldoc.emaildesc "Firewall - Advanced Filtering"
        xmldoc.description "#{condition_1}"
        xmldoc.id {
            xmldoc.manual "1234"
            xmldoc.auto "1234"
            xmldoc.code ""
        }
        xmldoc.stage {
            xmldoc.step {
                xmldoc.name "1"
                xmldoc.desc condition_1
                xmldoc.script "ruby $U_MI424/configDevice.rb -o $G_CURRENTLOG/config_system_settings.log -f $U_TESTPATH/#{af_jsonfile} -d $U_DEBUG -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0"
                xmldoc.passed ""
                xmldoc.failed ""
            }
            xmldoc.step {
                xmldoc.name "3"
                xmldoc.desc "Test advanced filtering."
                xmldoc.script "ruby $U_MI424/testSystem.rb -o $G_CURRENTLOG/test_advanced_filtering.log -f $G_CURRENTLOG/advanced_filtering_test.json --use-sshcli 'perl $U_COMMONBIN/sshcli.pl -l $G_CURRENTLOG -d $G_HOST_IP1 -u $G_HOST_USR1 -p $G_HOST_PWD1 -n -v' -d $U_DEBUG --dut_user $U_USER --dut_pass $U_PWD --dut_ip $G_PROD_IP_ETH0_0_0"
                xmldoc.passed ""
                xmldoc.failed ""
            }
            xmldoc.step {
                xmldoc.name "4"
                xmldoc.desc "Turn on telnet access. Get current configuration. Turn off telnet access."
                xmldoc.script "ruby $U_MI424/get_dut_config.rb -o $G_CURRENTLOG/dut_config.cfg -u $U_USER -p $U_PWD -i $G_PROD_IP_ETH0_0_0"
                xmldoc.passed ""
                xmldoc.failed ""
            }
        }
    }
    output = File.open("#{xmldir}/#{xmlfilename}", "w+")
    xmloutput.each do |line|
        output.write(line)
    end
    output.close
end

def save_json(jsoninfo, jsonfile)
    output = JSON.pretty_generate(jsoninfo)
    begin
        f = File.open(jsonfile, 'w+')
        output.each do |line|
            f.write(line)
        end
        f.close
    rescue
        puts "Could not write JSON output file #{jsonfile}"
        exit
    end
end

begin
    opts.parse!(ARGV)
    srand
    for i in 1..options.iterations
        afjson, afcondition = advanced_filtering
        build_xml_test(xmlfn.sub('#', "#{i}"), sscondition, racondition, ssjsonfn.sub('#', "#{i}"), rajsonfn.sub('#', "#{i}"), options.xmldir)
        save_json(rajson, "#{options.jsondir}/#{afjsonfn.sub('#', "#{i}")}")
        tst_file.insert(tst_file.index("# End test cases"), "-tc $SQAROOT/platform/1.0/verizon2/testcases/fw_advanced_filtering/tcases/#{xmlfn.sub('#', "#{i}")}\n")
    end
    tstout = File.open("#{options.tstdir}/tsuite_fwrmt.tst", "w+")
    tst_file.each { |line| tstout.write(line) }
    tstout.close
end