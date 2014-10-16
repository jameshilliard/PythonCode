#!/usr/bin/env ruby
require 'builder'
require 'rubygems'
require 'spreadsheet'
require 'optparse'
require 'ostruct'
require 'fileutils'

options = OpenStruct.new
options.sheet = ""

motive_cmd = "ruby $U_MOTIVEBIN/mainmotive.rb -s $U_SERVER -n $G_HW_SERIAL -u $U_MOTIVE_USER -p $U_MOTIVE_PASSWD -l $G_CURRENTLOG/logname"
ping_cmd = "perl $U_COMMONBIN/ping.pl  -l $G_CURRENTLOG -d $G_PROD_IP_ETH0_0_0"
clean_up_cmd = "perl $SQAROOT/bin/1.0/bin/echo_cli.pl -d $U_SERVER -p $U_SERVER_PORT"
ping_desc = "Make sure DUT is up"
clean_up_desc = "Clean up operation on selenium server side"
console_parser_cmd = "ruby $U_MI424/console_parser.rb --interface `echo ${G_PROD_IP_ETH0_0_0%/*}` --username $U_USER --password $U_PWD"
gui_parser_cmd = "ruby $U_MI424/gui_parser.rb --interface `echo ${G_PROD_IP_ETH0_0_0%/*}` --username $U_USER --password $U_PWD"
compare_cmd = "ruby $U_MI424/compare_results.rb"

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Information gatherer for Telus V1000H devices"
    opts.on("-s SPREADSHEET", "Spreadsheet filename to parse into XML test cases") { |v| options.sheet = v }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

# functions to find the BEGIN and END rows
def find_value(sheet, tag)
    row_index = 0
    sheet.each { |row| return row_index if row[0].include?(tag); row_index+=1 }
end

def find_parent(sheet, parent_of)
    return sheet.row(parent_of)[0] if sheet.row(parent_of)[4].include?("P")
    (parent_of-1).downto(1) { |i| return sheet.row(x)[0] if sheet.row(x)[4].include?("P") }
end

def sub_intervals(parameter, substitutes)

end

opts.parse!(ARGV)
book = Spreadsheet.open(options.sheet)
sheet = book.worksheet(0)
# Find sheets begin and end rows
start_row = find_value(sheet, "BEGIN") + 1
stop_row = find_value(sheet, "END") - 1

current_parent = sheet.row(start_row)[0].strip.chomp
intervals = ["1"]
lookup_intervals = ["1"]
for x in start_row..stop_row do
    puts sheet.row(x)[0]
    do_gui = false
    do_console = false
    if sheet.row(x)[4].include?("P")
        if sheet.row(x)[0].include?("*")
            current_parent = ""
            next
        end
        intervals = ["1"]
        lookup_intervals = ["1"]
        current_parent = sheet.row(x)[0].strip.chomp
        if sheet.row(x)[0].include?("{i}")
            intervals = sheet.row(x)[1].to_s.strip.split(',') unless sheet.row(x)[1].to_s.strip.empty?
            unless sheet.row(x)[2].nil?
                unless sheet.row(x)[2].to_s.strip.empty?
                    lookup_intervals = sheet.row(x)[2].to_s.strip.split(',')
                else
                    lookup_intervals = sheet.row(x)[1].to_s.strip.split(',')
                end
            else
                lookup_intervals = sheet.row(x)[1].to_s.strip.split(',')
            end
        end
        next
    end
    
    # Start here..
    next if sheet.row(x)[0].include?("*")
    next if current_parent.empty?

    do_console = true if sheet.row(x)[1].strip.match(/\A--/) unless sheet.row(x)[1].nil?
    do_gui = true if sheet.row(x)[2].strip.match(/\A--/) unless sheet.row(x)[2].nil?
    puts x
    unless do_console
        next unless do_gui
    end
    puts sheet.row(x)[0]
    intervals.each do |i|
        filename = "gpv_#{sheet.row(x)[0].strip.chomp}.xml"
        dirpath = current_parent.gsub(/\./, '/').gsub("{i}", i)
        current_parameter = "#{current_parent.gsub("{i}", i)}#{sheet.row(x)[0].strip.chomp}"
        li = lookup_intervals[0]
        li = lookup_intervals.shift if lookup_intervals.length > 1
        FileUtils.mkdir_p(dirpath)
        output = File.new("#{dirpath}#{filename}", "w+")
        xmlfile = Builder::XmlMarkup.new(:target => output, :indent => 4)
        xmlfile.testcase {
            xmlfile.name("#{filename}")
            xmlfile.emaildesc("GPV test for #{current_parameter}")
            xmlfile.description("Check DUT to make sure it's up. Run GPV on #{current_parameter}. Check console and/or GUI, and compare the values from Motive to that from the DUT.")
            xmlfile.id {
                xmlfile.manual("1234")
                xmlfile.auto("5678")
                xmlfile.code("")
            }
            xmlfile.stage {
                xmlfile.step {
                    xmlfile.name "0"
                    xmlfile.desc ping_desc
                    xmlfile.script ping_cmd
                    xmlfile.passed ""
                    xmlfile.failed ""
                }
                xmlfile.step {
                    xmlfile.name "1"
                    xmlfile.desc clean_up_desc
                    xmlfile.script clean_up_cmd
                    xmlfile.passed ""
                    xmlfile.failed ""
                }
                xmlfile.step {
                    xmlfile.name "2"
                    xmlfile.desc "Do GPV"
                    xmlfile.script "#{motive_cmd.sub("logname", "tr69_gpv.log")} --gpv #{current_parameter}"
                    xmlfile.passed ""
                    xmlfile.failed ""
                }
                xmlfile.step {
                    xmlfile.name "3"
                    xmlfile.desc "Get current value from console"
                    xmlfile.script "#{console_parser_cmd} #{sheet.row(x)[1].strip.chomp.gsub("{i}", li)} >> $G_CURRENTLOG/gpv_console_info.log"
                    xmlfile.passed ""
                    xmlfile.failed ""
                } if do_console
                xmlfile.step {
                    xmlfile.name "4"
                    xmlfile.desc "Get current value from GUI"
                    xmlfile.script "#{gui_parser_cmd} #{sheet.row(x)[2].strip.chomp} >> $G_CURRENTLOG/gpv_gui_info.log"
                    xmlfile.passed ""
                    xmlfile.failed ""
                } if do_gui
                xmlfile.step {
                    xmlfile.name "5"
                    xmlfile.desc "Compare values from Motive and Console/GUI"
                    xmlfile.script "#{compare_cmd} --tr69log -l $G_CURRENTLOG/tr69_gpv.log --guilog $G_CURRENTLOG/gpv_gui_info.log --consolelog $G_CURRENTLOG/gpv_console_info.log"
                    xmlfile.passed ""
                    xmlfile.failed ""
                }
            }
        }
        output.close
        # SPV
        if sheet.row(x)[4].include?("W")
            filename = "spv_#{sheet.row(x)[0].strip.chomp}.xml"
            output = File.new("#{dirpath}#{filename}", "w+")
            xmlfile = Builder::XmlMarkup.new(:target => output, :indent => 4)
            xmlfile.testcase {
                xmlfile.name("#{filename}")
                xmlfile.emaildesc("SPV test for #{current_parameter}")
                xmlfile.description("Check DUT to make sure it's up. Run SPV on #{current_parameter}. Check console and/or GUI, and compare the values from Motive to that from the DUT.")
                xmlfile.id {
                    xmlfile.manual("1234")
                    xmlfile.auto("5678")
                    xmlfile.code("")
                }
                xmlfile.stage {
                    xmlfile.step {
                        xmlfile.name "0"
                        xmlfile.desc ping_desc
                        xmlfile.script ping_cmd
                        xmlfile.passed ""
                        xmlfile.failed ""
                    }
                    xmlfile.step {
                        xmlfile.name "1"
                        xmlfile.desc clean_up_desc
                        xmlfile.script clean_up_cmd
                        xmlfile.passed ""
                        xmlfile.failed ""
                    }
                    xmlfile.step {
                        xmlfile.name "2"
                        xmlfile.desc "Do SPV"
                        xmlfile.script "#{motive_cmd.sub("logname", "tr69_gpv.log")} --spv #{current_parameter} --stype #{sheet.row(x)[3].strip.chomp} " #--svalue #{sheet.row(x)[6].strip.chomp}"
                        xmlfile.passed ""
                        xmlfile.failed ""
                    }
                    xmlfile.step {
                        xmlfile.name "3"
                        xmlfile.desc "Get current value from console"
                        xmlfile.script "#{console_parser_cmd} #{sheet.row(x)[1].strip.chomp.gsub("{i}", li)} >> $G_CURRENTLOG/spv_console_info.log"
                        xmlfile.passed ""
                        xmlfile.failed ""
                    } if do_console
                    xmlfile.step {
                        xmlfile.name "4"
                        xmlfile.desc "Get current value from GUI"
                        xmlfile.script "#{gui_parser_cmd} #{sheet.row(x)[2].strip.chomp} >> $G_CURRENTLOG/spv_gui_info.log"
                        xmlfile.passed ""
                        xmlfile.failed ""
                    } if do_gui
                    xmlfile.step {
                        xmlfile.name "5"
                        xmlfile.desc "Compare values from Motive and Console/GUI"
                        xmlfile.script "#{compare_cmd} --tr69log -l $G_CURRENTLOG/tr69_spv.log --guilog $G_CURRENTLOG/spv_gui_info.log --consolelog $G_CURRENTLOG/spv_console_info.log"
                        xmlfile.passed ""
                        xmlfile.failed ""
                    }
                }
            }
            output.close
        end
    end
end