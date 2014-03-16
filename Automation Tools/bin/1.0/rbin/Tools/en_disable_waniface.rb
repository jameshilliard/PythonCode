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
    @def_setting = true
    @log_location = nil
    opts = GetoptLong.new(
       ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-m',  GetoptLong::REQUIRED_ARGUMENT],
       ['-s',  GetoptLong::REQUIRED_ARGUMENT],
       ['-t',  GetoptLong::REQUIRED_ARGUMENT],
       ['--ndefault', GetoptLong::NO_ARGUMENT],
       ['-l',  GetoptLong::OPTIONAL_ARGUMENT],
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
	     when '--ndefault'
	       @def_setting = false
	     when '-l'
	       @log_location = arg
	     when '--help'
	       puts "Example:"
	       puts "\truby en_disable_waniface.rb -d 192.168.1.1 -u admin -p admin1 -m moca/ether -s Enable/Disable -t $defaultGW --ndefault\n"
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

    if @log_location != nil
	self.init_msgout(@log_location)
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
	    begin
		@ff.link(:href, 'javascript:mimic_button(\'edit: clink1..\', 1)').click
	    rescue
		puts 'Error : Did not reach Broadband Connection(Coax) page'
	    end
	    if @if_status == 'Enable'
		status_onpage = @ff.text_field(:xpath, '//center/table/tbody/tr/td/span/table/tbody/tr/td')
		if status_onpage.to_s == 'Enable'
		    @ff.link(:text, 'Enable').click
		    puts "Refresh page in case cannot locate Apply element well"
		    @ff.refresh
                    @ff.wait
		    sleep 2
		    if @log_location == nil
			puts ""
		    else
			dumpinfo = @ff.html
			self.msgout("#{dumpinfo}", 'file')
		    end
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
		    begin
		        @ff.link(:href, 'javascript:mimic_button(\'edit: clink1..\', 1)').click
		    rescue
		        puts 'Error : Did not reach Broadband Connection(Coax) page'
		    end
		else
		    if @log_location == nil
			puts "Hope to change to 'Enable', DUT is already 'Enable'"
		    else
			self.msgout("Hope to change to 'Enable', DUT is already 'Enable'")
		    end
		end

		if @def_setting == true 
		    set_default_tb
		end
		self.logout
		self.close
		if @log_location != nil
    		    self.destory
    		end
		exit 0
	
	    elsif @if_status == 'Disable'
		status_onpage = @ff.text_field(:xpath, '//center/table/tbody/tr/td/span/table/tbody/tr/td')
		if status_onpage.to_s == 'Disable'
		    @ff.link(:text, 'Disable').click
                    @ff.wait
		    @ff.link(:text, 'Apply').click
                    self.waitUntil { @ff.text_field(:name, 'user_name').exists? }
		    puts "Change interface to Disable"
		    self.close
		    if @log_location != nil
    		        self.destory
    		    end
		    exit 0
		else
		    if @log_location == nil
			puts "Hope to change to 'Disable', DUT is already 'Disable'"
		    else
			self.msgout("Hope to change to 'Disable', DUT is already 'Disable'")
		    end
		end
	    end
 
	when 'ether'
	    begin
		@ff.link(:href, 'javascript:mimic_button(\'edit: eth1..\', 1)').click
	    rescue
		puts 'Error : Did not reach Broadband Connection(Ethernet) page'
	    end

	    if @if_status == 'Enable'
		if_enable
	    elsif @if_status == 'Disable'
		if_disable
	    end
    end
    self.logout
    self.close
    if @log_location != nil
	self.destory
    end

  end

  def if_disable 
	status_onpage = @ff.text_field(:xpath, '//center/table/tbody/tr/td/span/table/tbody/tr/td')
	if status_onpage.to_s == 'Disable'
	    @ff.link(:text, 'Disable').click
            @ff.wait
            @ff.link(:text, 'Apply').click
	    puts "Change interface to Disable"
	else
	    if @log_location == nil
		puts "Hope to change to 'Disable', DUT is already 'Disable'"
	    else
		self.msgout("Hope to change to 'Disable', DUT is already 'Disable'")
	    end
	end
  end

  def if_enable
	status_onpage = @ff.text_field(:xpath, '//center/table/tbody/tr/td/span/table/tbody/tr/td')
	if status_onpage.to_s == 'Enable'
	    @ff.link(:text, 'Enable').click
	    puts "Change interface to Enable"
	else
	    if @log_location == nil
		puts "Hope to change to 'Enable', DUT is already 'Enable'"
	    else
		self.msgout("Hope to change to 'Enable', DUT is already 'Enable'")
	    end
	end
	if @def_setting == true
	    set_default_tb
	end
  end

  def set_default_tb
	@ff.link(:text, 'Settings').click
	@ff.select_list(:id, 'ip_settings').select_value('1')
        @ff.text_field(:name, 'static_ip0').value='10'
        @ff.text_field(:name, 'static_ip1').value='10'
        @ff.text_field(:name, 'static_ip2').value='10'
        @ff.text_field(:name, 'static_ip3').value='254'
	puts "Set ip 10.10.10.254 to wan interface"

        @ff.text_field(:name, 'static_netmask0').value='255'
        @ff.text_field(:name, 'static_netmask1').value='255'
        @ff.text_field(:name, 'static_netmask2').value='255'
        @ff.text_field(:name, 'static_netmask3').value='0'
        puts "Set netmask 255.255.255.0 to wan interface"

        octets=@pc4_ip.split('.')
        @ff.text_field(:name, 'static_gateway0').value=(octets[0])
        @ff.text_field(:name, 'static_gateway1').value=(octets[1])
        @ff.text_field(:name, 'static_gateway2').value=(octets[2])
        @ff.text_field(:name, 'static_gateway3').value=(octets[3])
	puts "Set default gw #{@pc4_ip}"

	@ff.select_list(:id, 'dns_option').select_value('0')
        @ff.text_field(:name, 'primary_dns0').value='4'
        @ff.text_field(:name, 'primary_dns1').value='2'
        @ff.text_field(:name, 'primary_dns2').value='2'
        @ff.text_field(:name, 'primary_dns3').value='2'
	puts "Set Primary DNS 4.2.2.2"

	@ff.link(:text,'Apply').click
  end

end

obj_IF = En_disable_interface.new
obj_IF.do_interface

