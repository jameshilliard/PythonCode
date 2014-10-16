#!/usr/bin/env ruby
# Consolidates original files from Veriwave testing for archiving,
# then rebuilds a summary PDF of all the consolidated materials.
$: << File.dirname(__FILE__)
require 'fileutils'
require 'optparse'
require 'ostruct'
require 'csv'
require 'rubygems'
require 'spreadsheet'
require 'prawn/core'
require 'prawn/layout'
require 'mechanize'
require 'hpricot'
require 'spreadsheet'
require 'common/ipcheck'

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
options.excel_file = false

# Option parser to change the above directories needed
opts = OptionParser.new do |opts|
	opts.separator ""
    opts.banner = "Consolidates original files from Veriwave testing for archiving, then rebuilds a summary PDF of all the consolidated materials."
    opts.on("-o FILENAME", "Output file to use for summary PDF.") { |o| options.summary_file = o }
    opts.on("--excel FILENAME", "Create Excel spreadsheet of summary data.") { |o| options.excel_file = o }
    opts.on("-a DIRECTORY", "Output directory for the archive. Defaults to the [working dir]/archive directory.") { |o| options.archive = o }
    opts.on("-r DIRECTORY", "Directory of the Veriwave benchmark performance results base is. i.e. - /vw/results/Benchmarks/Performance") { |r| options.veriwave_results = r }
    opts.on("-b DIRECTORY", "Directory of the master test plan.") { |b| options.veriwave_base = b }
    opts.on("--bhr VERSION", "Sets BHR version for getting information (1 or 2)") { |v| options.bhr_version = v }
    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("--no-archive", "Produces summary results and does not archive the data.") { options.noarchive = true }
    opts.on("--silent", "Suppresses output.") { options.silent = true }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
    options
end

def get_dut_info(options)
    # Set ID tags - makes it easier to understand
    id = { :firmware => 0, :model => 1, :hardware => 2, :serial => 3, :physical => 4, :broadband_type => 5, :broadband_stat => 6,
           :broadband_ip => 7, :subnet => 8, :mac => 9, :gateway => 10, :dns => 11, :uptime => 12 }

    browser_agent = WWW::Mechanize.new
    dut = IP.new(options.ip)
    raise "Invalid IP given" unless dut.is_valid?
    login_page = browser_agent.get(dut.url)

    # Set login information and create the MD5 hash
    login_page.forms[0].user_name = options.username
    pwmask, auth_key = "", ""
    login_page.forms[0].fields.each { |t| pwmask = t.name if t.name.match(/passwordmask_\d+/); auth_key = t.value if t.name.match(/auth_key/) }
    login_page.forms[0]["#{pwmask}"] = options.password
    login_page.forms[0].md5_pass = Digest::MD5.hexdigest("#{options.password}#{auth_key}")
    login_page.forms[0].mimic_button_field = "submit_button_login_submit%3a+.."
    browser_agent.submit(login_page.forms[0])

    # Success check - make sure we have a logout option
    raise "Didn't successfully login. Check user/pass." unless browser_agent.current_page.parser.text.match(/logout/im)

    # Get to System Information
    browser_agent.current_page.forms[0].mimic_button_field = "sidebar: actiontec_topbar_status.."
    browser_agent.submit(browser_agent.current_page.forms[0])

    # Get all pertinent DUT info for VW system
    info = browser_agent.current_page.parser.xpath('//tr/td[@class="GRID_NO_LEFT"]')

    # Log out
    browser_agent.current_page.forms[0].mimic_button_field = "logout: ..."
    browser_agent.submit(browser_agent.current_page.forms[0])

    return info[id[:model]].content, info[id[:hardware]].content, info[id[:firmware]].content, info[id[:serial]].content
end

# Method to convert a date string in the format of YYYYMMDD-HhMmSs into Hh:Mm MM/DD/YYYY
def format_date(date_string)
    date_unpack = date_string.unpack("A4A2A2xA2A2")
    return "#{date_unpack[3]}:#{date_unpack[4]} #{date_unpack[1]}/#{date_unpack[2]}/#{date_unpack[0]}"
end

# Method to convert decimal string into microseconds, milliseconds, or seconds
def seconds(t)
    return "#{t.to_f * 1000000}us" if t.to_f < 1e-4
    return "#{t.to_f * 1000}ms" if t.to_f < 1
    return "#{t.to_f}s"
end

######################################################################################################
# Methods to build a summary from the result list - note that each test needs its own summary method.#
######################################################################################################

# Method to average the RSSI data
def rssi_average(csv_file)
    csv = CSV.read(csv_file)
    results = {}
    results['data_info'] = []
    average = 0
    acount = 0
    min = 1000
    max = 0
    csv.each do |t|
        case t[1]
        when /port name/i
            results['header_info'] = t[1..4]
            results['header_info'][4] = "Min RSSI"
            results['header_info'][5] = "Max RSSI"
            results['header_info'][6] = "Avg RSSI"
        else
            results['data_info'][0] = t[1..5]
            average += t[5].to_f
            acount += 1
            min = t[5].to_f if t[5].to_f < min
            max = t[5].to_f if t[5].to_f > max
        end
    end
    results['data_info'][0][4] = "#{min} dBm"
    results['data_info'][0][5] = "#{max} dBm"
    results['data_info'][0][6] = "#{sprintf("%.1f", (average / acount))} dBm"
    return results
end

def local_value_get(config_array, key)
    value = "global"
    config_array.each do |c|
        value = c.delete('^[0-9.]') if c.match(/#{key}/i)
        value = "global" if c.scan(/#{key}/i).length > 1
    end
    return value
end

# Gets the user specified pass/fail percentages
def get_percents(options)
    throughput, goodput, forwarding_rate, max_latency, loss_tolerance = 0,0,0,0,0
    gc_file = options.veriwave_base+"/global_configs.tcl"
    gc = File.open(gc_file).readlines

    # grabs global values
    gc.each do |l|
        throughput = l.delete('^[0-9.]').to_i if l.match(/acceptablethroughput/i)
        goodput = l.delete('^[0-9.]').to_i if l.match(/acceptablegoodput/i)
        forwarding_rate = l.delete('^[0-9.]').to_i if l.match(/acceptableforwardingrate/i)
        max_latency = l.delete('^[0-9.]').to_i if l.match(/acceptablemaxlatency/i)
        loss_tolerance = l.delete('^[0-9.]').to_i if l.match(/acceptableframelossrate/i)
    end

    # now we can go back and grab individual test values
    # throughput
    t = local_value_get(File.open(options.veriwave_base+"/Benchmarks/Performance/Throughput/Throughput.tcl").readlines, "AcceptableThroughput")
    throughput = t.to_i unless t == "global"

    # goodput
    t = local_value_get(File.open(options.veriwave_base+"/Benchmarks/Performance/TCPGoodput/tcp_goodput.tcl").readlines, "AcceptableGoodput")
    goodput = t.to_i unless t == "global"

    # max forwarding rate
    t = local_value_get(File.open(options.veriwave_base+"/Benchmarks/Performance/MaximumForwardingRate/maximum_forwarding_rate.tcl").readlines, "AcceptableForwardingRate")
    forwarding_rate = t.to_i unless t == "global"

    # max latency
    t = local_value_get(File.open(options.veriwave_base+"/Benchmarks/Performance/Latency/latency.tcl").readlines, "AcceptableMaxLatency")
    max_latency = t.to_i unless t == "global"

    # packet loss
    t = local_value_get(File.open(options.veriwave_base+"/Benchmarks/Performance/PacketLoss/packetloss.tcl").readlines, "AcceptableFrameLossRate")
    loss_tolerance = t.to_i unless t == "global"

    return throughput, goodput, forwarding_rate, max_latency, loss_tolerance
end

# Gets AP and VW information
def apvw_info(csv_file, options)
    csv = CSV.read(csv_file)
    results = {}
    csv.each do |t|
        case t[0]
        when /waveengine/i
            results['veriwave_engine'] = "#{t[0]}#{t[1]},#{t[2]}"
        when /firmware/i
            results['veriwave_firmware'] = "#{t[0]}#{t[1]},#{t[2]}"
        end
    end
    results['dut_model'], results['dut_revision'], results['dut_firmware'], results['dut_serial'] = get_dut_info(options)
    return results
end

# Latency summary
def latency_summary(csv_file)
    csv = CSV.read(csv_file)
    results = {}
    results['data_info'] = []
    csv.each do |t|
        case t[0]
        when /frame size/i
            r_array = []
            t[0..8].each { |x| r_array << x.strip.chomp }
            results['header_info'] = r_array
            results['header_info'][7] = "USC - Average Latency"
            results['header_info'][8] = "USC - Max Latency"
        when /\d+/
            r_array = t[0..8]
            r_array[3] = seconds(t[3])
            r_array[4] = seconds(t[4])
            r_array[5] = seconds(t[5])
            results['data_info'] << r_array
        end
    end
    return results
end

# Throughput summary
def throughput_summary(csv_file)
    csv = CSV.read(csv_file)
    results = {}
    results['data_info'] = []
    csv.each do |t|
        case t[0]
        when /frame size/i
            r_array = []
            t[0..7].each { |x| r_array << x.strip.chomp }
            results['header_info'] = r_array
            results['header_info'][7] = "USC - Acceptable Throughput"
        when /\d+/
            r_array = []
            t[0..7].each do |x|
                if x.to_s.match(/\d+\.\d{3,}/)
                    r_array << sprintf("%.2f",x.to_f)
                else
                    r_array << x
                end
            end
            results['data_info'] << r_array
        end
    end
    return results
end

# Maximum Forwarding Rate summary
def mfr_summary(csv_file)
    csv = CSV.read(csv_file)
    results = {}
    results['data_info'] = []
    csv.each do |t|
        case t[6]
        when /usc:fr/i
            r_array = []
            t[0..6].each { |x| r_array << x.strip.chomp }
            results['header_info'] = r_array
            results['header_info'][6] = "USC - Forwarding Rate"
        when /pass|fail/i
            r_array = []
            t[0..6].each do |x|
                if x.to_s.match(/\d+\.\d{3,}/)
                    r_array << sprintf("%.2f",x.to_f)
                else
                    r_array << x
                end
            end
            results['data_info'] << r_array
        end
    end
    return results
end

# Packet Loss summary
def pl_summary(csv_file)
    csv = CSV.read(csv_file)
    results = {}
    results['data_info'] = []
    csv.each do |t|
        case t[0]
        when /frame size/i
            r_array = []
            t[0..9].each { |x| r_array << x.strip.chomp }
            results['header_info'] = r_array
            results['header_info'][3] = "Ideal pkts/sec"
            results['header_info'][4] = "Ideal bits/sec"
            results['header_info'][6] = "Rate pkts/sec"
            results['header_info'][7] = "Rate bits/sec"
            results['header_info'][8] = "Loss Rate"
            results['header_info'][9] = "USC - Tolerance"
        when /\d+/
            r_array = []
            t[0..9].each do |x|
                if x.to_s.match(/\d+\.\d{3,}/)
                    r_array << sprintf("%.2f",x.to_f)
                else
                    r_array << x
                end
            end
            results['data_info'] << r_array
        end
    end
    return results
end

# TCPGoodput summary
def tcpgoodput_summary(csv_file)
    csv = CSV.read(csv_file)
    results = {}
    results['data_info'] = []
    csv.each do |t|
        case t[0]
        when /trial/i
            r_array = []
            t[0..9].each { |x| r_array << x.strip.chomp }
            results['header_info'] = r_array
            results['header_info'][2] = "TCP Goodput segments/sec"
            results['header_info'][4] = "TCP Goodput Kbps"
            results['header_info'][5] = "TCP payload sent KBps"
            results['header_info'][6] = "Ideal Goodput Kbps"
            results['header_info'][9] = "USC - Goodput"
        when /\d+/
            r_array = []
            t[0..9].each do |x|
                if x.to_s.match(/\d+\.\d{3,}/)
                    r_array << sprintf("%.2f",x.to_f)
                else
                    r_array << x
                end
            end
            results['data_info'] << r_array
        end
    end
    return results
end

# Class to hold the PDF data - and now excel data
class PDF_Build

    def initialize
        @pdf = Prawn::Document.new
        @pdf.font_size 10
        @excel_book = Spreadsheet::Workbook.new
        @excel_sheet = @excel_book.create_worksheet
        @excel_sheet.name = "Veriwave results"
        @current_row = 1
    end
    
    def summary_header(header)
        lp = "\n        "
        header_info = "Device tested:\n#{lp}DUT model: #{header['dut_model']}#{lp}DUT hardware revision: #{header['dut_revision']}#{lp}DUT firmware: #{header['dut_firmware']}#{lp}DUT serial number: #{header['dut_serial']}\n\nTested with:#{lp}Veriwave #{header['veriwave_engine'].downcase.sub(/waveengine/i, 'WaveEngine')}#{lp}Veriwave #{header['veriwave_firmware'].downcase}"
        @pdf.cell [0,@pdf.cursor],
            :font_size => 14,
            :text => header_info,
            :text_color => "000000",
            :padding => 8,
            :background_color => "D4FBAD",
            :border_style => :none,
            :width => 400
        @pdf.move_down 20
        "DUT model: #{header['dut_model']}\nDUT hardware revision: #{header['dut_revision']}\nDUT firmware: #{header['dut_firmware']}\nDUT serial number: #{header['dut_serial']}\nVeriwave #{header['veriwave_engine'].downcase.sub(/waveengine/i, 'WaveEngine')}\nVeriwave #{header['veriwave_firmware'].downcase}".split("\n").each { |x| @excel_sheet.row(@current_row).push(x); @current_row += 1 }
        @current_row += 1
    end

    def summary_failure(text)
        new_text = ""
        text.split("\n").each do |t|
            if t.match(/\/\S+\/\S+\/\S+\//) && t.length > 80
                nt = ""
                string_length = 0
                t.split('/').each do |d|
                    if (d.length+string_length) > 80
                        nt << "\n"+d+"/"
                        string_length = d.length
                    else
                        nt << d+"/"
                        string_length += d.length
                    end
                end
                new_text << nt
            else
                new_text << t+"\n"
            end
        end
        
        @pdf.cell [0,@pdf.cursor],
            :font_size => 10,
            :text => new_text,
            :text_color => "FFFF00",
            :padding => 3,
            :background_color => "6A0013",
            :border_style => :none,
            :width => 500
        @pdf.move_down 10
        new_text.split("\n").each { |x| @excel_sheet.row(@current_row).push(x); @current_row += 1 }
    end

    def summary_table(header, data, rssi_data, title)
        @pdf.cell [0,@pdf.cursor],
            :font_size => 13,
            :text => title,
            :text_color => "000000",
            :padding => 3,
            :background_color => "EDEECD",
            :border_style => :none,
            :width => 400
        @pdf.move_down 5
        @pdf.table rssi_data['data_info'],
            :font_size          => 10,
            :position           => :left,
            :align              => :center,
            :align_headers      => :center,
            :headers            => rssi_data['header_info'],
            :header_color       => "CEE5B7",
            :row_colors         => ["ffffff"],
            :vertical_padding   => 2,
            :horizontal_padding => 5
        @pdf.move_down 5
        @pdf.table data,
            :font_size          => 10,
            :position           => :left,
            :align              => :center,
            :align_headers      => :center,
            :headers            => header,
            :header_color       => "CEE5B7",
            :row_colors         => ["ffffff"],
            :vertical_padding   => 2,
            :horizontal_padding => 1
        @pdf.move_down 10
        #pdf.summary_table(results['header_info'], results['data_info'], rssi, d_tag)
        title.split("\n").each { |x| @excel_sheet.row(@current_row).push(x); @current_row +=1 }
        rssi_data['header_info'].each { |x| @excel_sheet.row(@current_row).push(x) }
        @current_row += 1
        rssi_data['data_info'].each { |x| x.each { |y| @excel_sheet.row(@current_row).push(y) }; @current_row += 1 }
        @current_row += 1
        header.each { |x| @excel_sheet.row(@current_row).push(x) }
        @current_row += 1
        data.each { |x| x.each { |y| @excel_sheet.row(@current_row).push(y) }; @current_row += 1 }
        @current_row += 1
    end

    # Method to save PDF file
    def save(pdf_file, excel_file = false)
        @pdf.render_file pdf_file
        @excel_book.write(excel_file) if excel_file
    end
end

# Begin consolidation
begin
    dut = IP.new(options.ip)
    raise "Invalid IP address given" unless dut.is_valid?
    options.url = dut.url
    options.ip = dut.ip

    created_header_info = FALSE
    # parse options
    opts.parse!(ARGV)

    # Grab the directory list
    dirlist = `ls -R1 #{options.veriwave_results}|grep NumClients| grep :`.to_a
    # Make the archive directory if it doesn't exist.
    FileUtils::mkdir_p(options.archive) unless options.noarchive

    # Make a new PDF holder
    pdf = PDF_Build.new
    throughput, goodput, forwarding_rate, max_latency, loss_tolerance = get_percents(options)
    
    # Begin grabbing contents and making a summary
    dirlist.each do |entry|
        entry.delete!(":.")
        entry.chomp!
        entry.strip!
        optlist = Dir.entries("#{entry}").delete_if { |x| x.match(/\A\./) }
        d_tag = ""
        rename = ""
        test_completed = FALSE
        optlist.each { |x| test_completed = TRUE if x.match(/pdf/i) }
        # This parses out the HTML file to find errors if the test didn't complete or write a PDF.
        unless test_completed
            failure_messages, html_file = "", ""
            optlist.each { |x| html_file = "#{entry}/#{x}" if x.match(/html/i) }
            doc = Hpricot.parse(open(html_file))
            failure_messages = doc.search("//span[@class='MSG_ERROR']").innerHTML
        end
        entry.split('/').each do |header|
            case header
            when /Latency|MaximumForwardingRate|PacketLoss|TCPGoodput|Throughput/
                # Test coverage
                unless header.match(/unicast/i)
                    rename << "#{header}"
                    d_tag << "#{header}"
                end
            when /pbtc/i
                # Test case
                rename << "_test_#{header}"
                d_tag << " test case #{header}"
            when /\d+-\d+/
                # Date
                d_tag << " completed at #{format_date(header)}."
            when /channel/i
                # Channel
                rename << "_Channel-#{header.delete('^[0-9]')}"
                d_tag << "\nUsing channel #{header.delete('^[0-9]')}"
            when /method/i
                # Security method
                if header.match(/none/i)
                    rename << "_No-security"
                    d_tag << " with no security set"
                else
                    rename << "_#{header.sub(/Method=/, '')}"
                    d_tag << " with security on #{header.sub(/Method=/, '')}"
                end
            when /clients/i
                # Number of clients
                rename << "_#{header.delete('^[0-9]')}_clients" if header.delete('^[0-9]').to_i == 10
                rename << "_#{header.delete('^[0-9]')}_client" if header.delete('^[0-9]').to_i == 1
                d_tag << " and #{header.delete('^[0-9]')} clients." if header.delete('^[0-9]').to_i == 10
                d_tag << " and #{header.delete('^[0-9]')} client." if header.delete('^[0-9]').to_i == 1
            end
        end

        FileUtils::mkdir_p("#{options.archive}/#{rename}") unless options.noarchive
        FileUtils::cp_r("#{entry}/.", "#{options.archive}/#{rename}") unless options.noarchive

        # Gather Veriwave and AP information if hadn't already
        unless created_header_info == TRUE
            csv_file = ""
            optlist.each { |x| csv_file = x if x.match(/detail.*csv|result.*csv/i) }
            pdf.summary_header(apvw_info("#{entry}/#{csv_file}", options)) unless csv_file == ""
            created_header_info = TRUE
        end

        # Write the summary results to the PDF matrix based off test ran
        print "\nWorking on #{rename}" unless options.silent
        failed = true
        case rename
        when /latency/i
            if test_completed
                results = latency_summary("#{entry}/Results_unicast_latency.csv")
                rssi = rssi_average("#{entry}/RSSI_unicast_latency.csv")
                d_tag << "\nAcceptable Max Latency is #{max_latency}% of the theoretical value."
                pdf.summary_table(results['header_info'], results['data_info'], rssi, d_tag)
                failed = false
            else
                pdf.summary_failure("#{d_tag}\nThis test did not complete. Details in #{options.noarchive ? "directory:\n"+entry : "archive directory:\n"+rename}.\n#{failure_messages}")
            end
        when /forwarding/i
            if test_completed
                results = mfr_summary("#{entry}/Results_unicast_max_forwarding_rate.csv")
                rssi = rssi_average("#{entry}/RSSI_unicast_max_forwarding_rate.csv")
                d_tag << "\nAcceptable Max Forwarding Rate is #{forwarding_rate}% of the theoretical value."
                pdf.summary_table(results['header_info'], results['data_info'], rssi, d_tag)
                failed = false
            else
                pdf.summary_failure("#{d_tag}\nThis test did not complete. Details in #{options.noarchive ? "directory:\n"+entry : "archive directory:\n"+rename}.\n#{failure_messages}")
            end
        when /packet/i
            if test_completed
                results = pl_summary("#{entry}/Results_unicast_packet_loss.csv")
                rssi = rssi_average("#{entry}/RSSI_unicast_packet_loss.csv")
                d_tag << "\nAcceptable Packet Loss is #{loss_tolerance}% of the theoretical value."
                pdf.summary_table(results['header_info'], results['data_info'], rssi, d_tag)
                failed = false
            else
                pdf.summary_failure("#{d_tag}\nThis test did not complete. Details in #{options.noarchive ? "directory:\n"+entry : "archive directory:\n"+rename}.\n#{failure_messages}")
            end
        when /throughput/i
            if test_completed
                results = throughput_summary("#{entry}/Results_unicast_throughput.csv")
                rssi = rssi_average("#{entry}/RSSI_unicast_unidirectional_throughput.csv")
                d_tag << "\nAcceptable Throughput is #{throughput}% of the theoretical value."
                pdf.summary_table(results['header_info'], results['data_info'], rssi, d_tag)
                failed = false
            else
                pdf.summary_failure("#{d_tag}\nThis test did not complete. Details in #{options.noarchive ? "directory:\n"+entry : "archive directory:\n"+rename}.\n#{failure_messages}")
            end
        when /goodput/i
            if test_completed
                results = tcpgoodput_summary("#{entry}/Results_tcp_goodput.csv")
                rssi = rssi_average("#{entry}/RSSI_tcp_goodput.csv")
                d_tag << "\nAcceptable TCP Goodput is #{goodput}% of the theoretical value."
                pdf.summary_table(results['header_info'], results['data_info'], rssi, d_tag)
                failed = false
            else
                pdf.summary_failure("#{d_tag}\nThis test did not complete. Details in #{options.noarchive ? "directory:\n"+entry : "archive directory:\n"+rename}.\n#{failure_messages}")
            end
        # FixMe: The following need to be implemented still, as they are not yet supported. We don't normally run these, but I'm sure the future will say otherwise. 
        when /rate_vs_range/i
        when /security/i
        when /association/i
        end
        failed ? r_msg = "...test failed." : r_msg = "...test passed."
        print r_msg unless options.silent
    end
    puts "\nSaving summary pdf to #{options.summary_file}" unless options.silent
    puts "\nSaving summary excel sheet to #{options.excel_file}" unless options.silent if options.excel_file
    pdf.save(options.summary_file, options.excel_file)
end