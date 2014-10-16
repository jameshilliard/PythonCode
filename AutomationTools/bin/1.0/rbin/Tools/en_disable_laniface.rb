################################################################
#     en_disable_waniface.rb
#     Author:         Hugo
#     Date:           since 2010.11.4
#     Discription:    
#     Input:          it depends
#     Output:         the  result of operation
################################################################

require 'getoptlong'
$dir=File.dirname(__FILE__) + "/"
require $dir + 'Essentialdut'

class En_disable_interface < Essentialdut
  
  def initialize
    @username = 'admin'
    @password = 'admin1'
    @address = '192.168.1.1'
    @port = '80'
    @if_mode = nil
    @if_status = nil
    @pc4_ip = '10.10.10.47'
    @def_setting = false
    opts = GetoptLong.new(
       ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-m',  GetoptLong::REQUIRED_ARGUMENT],
       ['-s',  GetoptLong::REQUIRED_ARGUMENT],
       ['-t',  GetoptLong::OPTIONAL_ARGUMENT],
       ['--default', GetoptLong::NO_ARGUMENT],
       ['--help', '-h', GetoptLong::NO_ARGUMENT]
    )

    begin
        
        opts.each do |opt, arg|
          case opt
	     when '-d'
               @address = arg
               puts " address = #{@address}"
             when '-u'
               @username = arg
               puts " username = #{@username}"
             when '-p'
               @password = arg
               puts " password = #{@password}"
             when '-m'
               @if_mode = arg
               puts " operation on #{@if_mode}"
             when '-s'
               @if_status = arg
               puts " change status to #{@if_status}"
	     when '-t'
	       @pc4_ip = arg
	       arr_ip = @pc4_ip.split('/')
	       @pc4_ip = arr_ip[0]
	       puts " pc4 tport ip #{@pc4_ip}"
	     when '--default'
	       @def_setting = true
	     when '--help'
	       puts "Example:"
	       puts "\truby en_disable_laniface.rb -d 192.168.1.1 -u admin -p admin1 -m moca/ether -s Enable/Disable -t $defaultGW --default\n"
	       exit
             end
	     
          end
    end
   
    if @if_status !~ /Enable/ and @if_status !~ /Disable/
	puts "Error : please input Enable or Disable"
	exit 1
    end

    if @if_mode != 'moca' and @if_mode != 'ether'
	puts "Error : please input moca or ether"
	exit 1
    end

    puts 'RUBY SCRIPT START ...'
    cmd='killall firefox; killall firefox-bin; rm -f ~/.mozilla/firefox/*/compreg.dat'
    result = fork{exec(cmd)}
    Process.wait
    puts "KILL FIREFOX= #{cmd} "
    sleep 2

  end
  
  def do_interface
    self.login
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
    rescue
      puts 'Error : My Network did not reach page'
      return
    end

    begin
      @ff.link(:text, 'Network Connections').click
    rescue
      puts 'Error : Did not reach Network Connections page'
      return
    end

    case @if_mode
	when 'moca'
            if @ff.contains_text('Advanced >>')
                @ff.link(:text, 'Advanced >>').click
            end

            begin
              @ff.link(:href, 'javascript:mimic_button(\'edit: clink0..\', 1)').click
            rescue
              puts "Error: Did not reach Coax page"
              return
            end

	    if @if_status == 'Enable'
		status_onpage = @ff.text_field(:xpath, '//center/table/tbody/tr/td/span/table/tbody/tr/td')
		if status_onpage.to_s == 'Enable'
		    @ff.link(:text, 'Enable').click
		    @ff.link(:text, 'Apply').click
		    self.waitUntil { @ff.text_field(:name, 'user_name').exists? }
		    puts "Change interface to Enable"
		    puts 'Attempting to login ...'
		    @ff.text_field(:name, 'user_name').value=(@username)
		    @ff.text_field(:name, 'passwd1').set(@password)
		    @ff.link(:text, 'OK').click
		    begin
		            @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
		    rescue
		            puts 'Error : My Network did not reach page'
		            return
		    end
		    
		    begin
		            @ff.link(:text, 'Network Connections').click
		    rescue
		            puts 'Error : Did not reach Network Connections page'
		            return
		    end

                    if @ff.contains_text('Advanced >>')
                        @ff.link(:text, 'Advanced >>').click
                    end
                    
                    begin
                      @ff.link(:href, 'javascript:mimic_button(\'edit: clink0..\', 1)').click
                    rescue
                      puts "Error: Did not reach Coax page"
                      return
                    end

		else
		    puts "Hope to change to 'Enable', DUT is already 'Enable'"
		end

		if @def_setting == true
		    set_default_tb
		end
		self.logout
		self.close
		exit 0
	
	    elsif @if_status == 'Disable'
		status_onpage = @ff.text_field(:xpath, '//center/table/tbody/tr/td/span/table/tbody/tr/td')
		if status_onpage.to_s == 'Disable'
		    @ff.link(:text, 'Disable').click
		    @ff.link(:text, 'Apply').click
                    self.waitUntil { @ff.text_field(:name, 'user_name').exists? }
		    puts "Change interface to Disable"
		    self.close
		    exit 0
		else
		    puts "Hope to change to 'Disable', DUT is already 'Disable'"
		end
	    end
 
	when 'ether'
		puts "WoW!!! Nothing to do....."
    end
    self.logout
    self.close

  end

  def set_default_tb
    begin
      @ff.link(:text, 'Settings').click
      puts "Go into Settings"
    rescue
      puts "Error: Did not reach Coax Properties page"
      return
    end

    @ff.select_list(:id, 'clink_channel').select_value('-1')
    puts "Set Channel to Automatic"

    @ff.link(:text, 'Apply').click

  end

end

obj_IF = En_disable_interface.new
obj_IF.do_interface

