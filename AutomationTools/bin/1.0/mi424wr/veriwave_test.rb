#!/usr/bin/env ruby
# Makes my life miserable by creating more work.

$: << File.dirname(__FILE__)
require 'optparse'
require 'ostruct'
require 'rubygems'
require 'hpricot'

# Set default values
options = OpenStruct.new
options.veriwave_results = "/root/vwautomation/MasterTestPlan/BHR2_nwk10/results/Benchmarks/Performance"
options.veriwave_base = "/root/vwautomation/MasterTestPlan/BHR2_nwk10"
options.working_dir = `pwd`.chomp
options.archive = "#{options.working_dir}/archive"
options.summary_file = "veriwave_summary_results.pdf"
options.username = "admin"
options.password = "admin1"
options.url = "http://192.168.10.1"
options.ip = "192.168.10.1"
options.noarchive = false
options.bhr_version = "2"
options.silent = false
options.fullfail = false
options.single_pass = false
# Array to hold tag data as it gets built from the directory structure
d_output = []

# Option parser to change the above directories needed
opts = OptionParser.new do |opts|
	opts.separator ""
    opts.banner = "Consolidates original files from Veriwave testing for archiving, then rebuilds a summary PDF of all the consolidated materials."
    opts.on("-o FILENAME", "Output file to use for summary PDF.") { |o| options.summary_file = o }
    opts.on("-a DIRECTORY", "Output directory for the archive. Defaults to the [working dir]/archive directory.") { |o| options.archive = o }
    opts.on("-r DIRECTORY", "Directory of the Veriwave benchmark performance results base is. i.e. - /vw/results/Benchmarks/Performance") { |r| options.veriwave_results = r }
    opts.on("-b DIRECTORY", "Directory of the master test plan.") { |b| options.veriwave_base = b }
    opts.on("--bhr VERSION", "Sets BHR version for getting information (1 or 2)") { |v| options.bhr_version = v }
    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("--no-archive", "Produces summary results and does not archive the data.") { options.noarchive = true }
    opts.on("--singlepass", "Quick, single pass.") { options.single_pass = true }
    opts.on("--fullfail", "Stop everything if failure occurs.") { options.fullfail = true }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
    options
end

begin
    test_count = 0
    test_fail = 0
    # parse options - not like we need them right now
    opts.parse!(ARGV)
    done = false
    while not done
        test_count = 0
        test_fail = 0
        # Grab the directory list
        dirlist = `ls -R1 #{options.veriwave_results}|grep NumClients| grep :`.to_a

        # Begin grabbing contents and making a summary
        dirlist.each do |entry|
            test_count += 1
            entry.delete!(":.")
            entry.chomp!
            entry.strip!
            test_completed = FALSE
            html_file = ""
            Dir.entries("#{entry}").each { |x|
                test_completed = TRUE if x.match(/pdf/i)
                html_file = "#{entry}/#{x}" if x.match(/html/i)
            }

            # Get errors in case the test didn't complete. This is where we will stop the test and mail out results when needed
            unless test_completed
                unless html_file.empty?
                    doc = Hpricot.parse(open("#{html_file}"))
                    possible_fail = doc.search("//span[@class='MSG_ERROR']").innerHTML
                    test_fail += 1
                    if possible_fail.match(/error/im) && options.fullfail
                        puts "Found a valid failure. Breaking system and mailing out."
                        # Kill the system
                        system('pkill -9 -f "/bin/bash ./veriwave_test.sh"')
                        system('pkill -9 -f "masterscript"')
                        system('pkill -9 -f "python masterplan.py"')
                        system('pkill -9 -f "expect /root/vwautomation"')
                        system('pkill -9 -f "python /root/vwautomation"')
                        # Mail me
                        system("echo \"Parsed through #{test_count}. Last test failed. #{possible_fail}\" > tmp_output")
                        system('mutt -s "Veriwave failure notice" cborn@actiontec.com < tmp_output')
                        system('rm -f tmp_output')
                        # End this loop
                        done = TRUE
                    elsif possible_fail.match(/error/im) && !options.fullfail
                        puts "Parsed through #{test_count}. #{test_fail} failed with #{possible_fail}"
                    end
                end
            end
        end
        if options.single_pass
            puts "Parsed through #{test_count}. #{test_fail} failed"
            done = TRUE
        else
            puts "Status update: Parsed through #{test_count}. #{test_fail} failed and was non-conclusive (no error log, possible Ctrl-C attempt on console.)"
            # wait 30 seconds
            sleep 30
        end
    end
end
