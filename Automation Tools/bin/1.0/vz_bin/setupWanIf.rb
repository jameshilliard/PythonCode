################################################################
#     Base on initialize_BHR2.rb
# adding user's option and Coax support
################################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'

$username = 'admin'
$password = 'admin1'
$address = '192.168.1.1'
$port='80'
$media ='ether';
#enable = 1, disable = 0 
$enable='enable'; 
$disable='disable'; 
# handle any command line arguments 
opts = GetoptLong.new( 
     ['-c',  GetoptLong::OPTIONAL_ARGUMENT], 
     ['-u',  GetoptLong::REQUIRED_ARGUMENT],
     ['-p',  GetoptLong::REQUIRED_ARGUMENT],
     ['-d',  GetoptLong::REQUIRED_ARGUMENT],
     ['-h',  GetoptLong::NO_ARGUMENT]
)

def waitUntil
  until yield
    sleep 0.5
  end
end

class Initialize_BHR2_WAN
  def initialize
  end
  def mainlink
    puts 'link to Device GUI...'
    url = 'http://' + $address + ':' + $port + '/'
    sleep 1
    @ff.goto(url)
    waitUntil { @ff.span(:text, 'Login').exists? }

  end

  def linkdut
    # link to Device GUI
    puts 'link to Device GUI...'
    url = 'http://' + $address + ':' + $port + '/'
    @ff = FireWatir::Firefox.new(:waitTime => 5)
    sleep 1
    @ff.goto(url)
    waitUntil { @ff.span(:text, 'Login').exists? }
  end
  
  def close
    #close Firefox windows
    @ff.close
  end
  def logout
    puts 'Logging out ...'
    if @ff.contains_text('Logout')
      print "Logout Process\n" 
      @ff.link(:name, 'logout').click
      if ! @ff.contains_text('User has logged out')
        $stderr.print "Logout failed\n"
      end
    end
  end 
  def login
    mainlink
      #check if this screen reset to default 
    if @ff.contains_text('Login Setup')
      puts 'Login Setup\n' 
      # Set up Page 
      @ff.text_field(:index, 1).value=($username )
      @ff.text_field(:index, 2).set($password )
      @ff.text_field(:index, 3).set($password )
      @ff.link(:text, 'OK').click
      if @ff.contains_text('Login failed')
        $stderr.print "First Login failed\n"
        self.close
        exit
      end
    else 
      puts 'Normal  Login' 
      url = 'http://' + $address + ':' + $port + '/'
      @ff.goto(url)
      @ff.text_field(:name, 'user_name').value=($username)
      @ff.text_field(:name, 'passwd1').set($password)
      @ff.link(:text, 'OK').click
      if @ff.contains_text('Login failed')
        $stderr.print "Login failed\n"
        exit
      end
      puts 'Logging OK'
    end
  end
  #----------------------------------------------
  #   Routine to enable/disable Wan Ethernet port
  #----------------------------------------------
  def setting_WAN_port(media,setting)
    # click the my network page
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
    rescue
      self.msg(rule_name, :error, 'My Network', 'did not reach page')
      return
    end
      # click the Network Connections link
    begin
      @ff.link(:text, 'Network Connections').click
    rescue
      self.msg(rule_name, :error, 'NetworkConnections', 'Did not reach Network Connections page')
      return
      end
    
    begin
      if (@ff.text.include? 'Advanced >>')
        @ff.link(:text,'Advanced >>').click
      end
    rescue
      self.msg(rule_name,:error,'initialize BHR2','Wrong with\'Advanced >>\'')
    end

    case media 
	when 'ether'  
	    # click the 'Broadband Connection(Ethernet)' link 
	    @ff.link(:href, 'javascript:mimic_button(\'edit: eth1..\', 1)').click
	when 'coax' 
	    # click the 'Broadband Connection(Coax)' link 
	    @ff.link(:href, 'javascript:mimic_button(\'edit: clink1..\', 1)').click
	when 'pppoe'
	    # click the 'WAN pppoe' link
	    @ff.link(:href,'javascript:mimic_button(\'edit: ppp0..\', 1)').click
	when 'pppoe2'
	    # click the 'WAN pppoe2' link
	    @ff.link(:href,'javascript:mimic_button(\'edit: ppp1..\', 1)').click
	else
	    puts "Error: Can NOT enter media interface"
	    return
    end
    puts setting+' WAN ' + media+"...."
    if ( setting =~ /enable/)
      if @ff.contains_text('Enable')
        puts "==>Process: Enable  WAN "+ media
        @ff.link(:text, 'Enable').click
        sleep 1
        @ff.link(:text, 'Apply').click
        sleep 2
      else       
        puts " Warning: WAN "+media+" is already enabled"
      end 
    else      
      if @ff.contains_text('Enable')
        puts " Warning: WAN "+media+" is already disabled"
      else
        puts "==>Process: Disable  WAN "+ media
        @ff.link(:text, 'Disable').click
        sleep 1
        @ff.link(:text, 'Apply').click
        sleep 2
      end  
    end 
    if @ff.contains_text('Please wait, system is now rebooting')
      sleep 80
    end

    
  end
  #----------------------------------------------
  #   Routine to Initialize Wan Ethernet port
  #----------------------------------------------
  def initialize_WAN_port(media,ipaddress,netmask,gateway)
    @ip = ipaddress.split('.')
    @nm = netmask.split('.')
    @gw = gateway.split('.')
    # click the my network page
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
      @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
    rescue
      self.msg(rule_name, :error, 'My Network', 'did not reach page')
      return
    end

    # click the Network Connections link
    begin
      @ff.link(:text, 'Network Connections').click
    rescue
      self.msg(rule_name, :error, 'NetworkConnections', 'Did not reach Network Connections page')
      return
    end
    
    begin
      if (@ff.text.include? 'Advanced >>')
        @ff.link(:text,'Advanced >>').click
      end
    rescue
      self.msg(rule_name,:error,'initialize BHR2','Wrong with\'Advanced >>\'')
    end
    puts ' Initialize WAN ' +media+ ": ip="+ipaddress+" -- netmask="+netmask+" --gw="+gateway    
    
    #if ( media =~ /ether/)
    case media 

	when 'ether'
	    # click the Network Connections link
	    # click the 'Broadband Connection(Ethernet)' link 
	    begin
		@ff.link(:href, 'javascript:mimic_button(\'edit: eth1..\', 1)').click
	    rescue
		self.msg(rule_name, :error, 'WanEthhernet', 'Did not Broadband Connection(Ethernet) Properties page')
		return
	    end
	    # and then click 'Settings' link
	    begin
		@ff.link(:text, 'Settings').click
	    rescue
		self.msg(rule_name, :error, 'WanEthhernet', 'Did not Broadband Connection(Ethernet) Properties page')
		return
	    end

	when 'coax' 
	    # click the Network Connections link
	    # click the 'Broadband Connection(Coax)' link
	    begin
		@ff.link(:href, 'javascript:mimic_button(\'edit: clink1..\', 1)').click
	    rescue
		self.msg(rule_name, :error, 'WanCoax', 'Did not reach Broadband Connection(Coax) page')
		return
	    end
	    # and then click 'Settings' link
	    begin
		@ff.link(:text, 'Settings').click
	    rescue
		self.msg(rule_name, :error, 'WanCoax', 'Did not Broadband Connection(Coax) Properties page')
		return
	    end

	when 'pppoe'
	    # click the Network Connections link
	    # click the 'WAN pppoe' link
	    begin
		@ff.link(:href, 'javascript:mimic_button(\'edit: ppp0..\', 1)').click
	    rescue
		self.msg(rule_name, :error, 'PPPoE', 'Did not reach WAN pppoe page')
		return
	    end
	    if @ff.contains_text('Enable')
		puts "==>Process: Enable  WAN "+ media
		@ff.link(:text, 'Enable').click
		sleep 1
		@ff.link(:text, 'Apply').click
		sleep 2
		@ff.link(:href, 'javascript:mimic_button(\'edit: ppp0..\', 1)').click
	    else       
		puts " Warning: WAN "+media+" is already enabled"
	    end 
	    # and then click 'Settings' link
	    begin
		@ff.link(:text, 'Settings').click
	    rescue
		self.msg(rule_name, :error, 'PPPoE', 'Did not WAN pppoe Properties page')
		return
	    end

	when 'pppoe2' 
	    # click the Network Connections link
	    # click the 'WAN pppoe 2' link
	    begin
		@ff.link(:href, 'javascript:mimic_button(\'edit: ppp1..\', 1)').click
	    rescue
		self.msg(rule_name, :error, 'PPPoE 2', 'Did not reach WAN pppoe 2 page')
		return
	    end
	    if @ff.contains_text('Enable')
		puts "==>Process: Enable  WAN "+ media
		@ff.link(:text, 'Enable').click
		sleep 1
		@ff.link(:text, 'Apply').click
		sleep 2
		@ff.link(:href, 'javascript:mimic_button(\'edit: ppp1..\', 1)').click
	    else       
		puts " Warning: WAN "+media+" is already enabled"
	    end 
	    # and then click 'Settings' link
	    begin
		@ff.link(:text, 'Settings').click
	    rescue
		self.msg(rule_name, :error, 'PPPoE 2', 'Did not reach WAN pppoe 2 Properties page')
		return
	    end
	else
	    self.msg(rule_name, :error, 'Broadband Connection', 'Did not reach WAN interface page')

    end # End of case
    
    # do setup    
    if @ff.contains_text('Login User Name')
	@ff.text_field(:name,'ppp_username').value=('shqa')
	#self.msg(rule_name,:info,'Login User Name','Set \'Login User Name\' to \'shqa\'')
    end
    if @ff.contains_text('Login Password')
	if @ff.contains_text('Idle Time Before Hanging Up')
	    @ff.text_field(:index,5).set('shqa')
	else
	    @ff.text_field(:index,4).set('shqa')
	end	
	#self.msg(rule_name,:info,'Login Password','Set \'Login Password\' to \'shqa\'')
    end
    if @ff.contains_text('Retype Password')
	if @ff.contains_text('Idle Time Before Hanging Up')
	    @ff.text_field(:index,6).set('shqa')
	else
	    @ff.text_field(:index,5).set('shqa')
	end	
	#self.msg(rule_name,:info,'Retype Password','Set \'Retype Password\' to \'shqa\'')
    end
    
    # Internet Protocol = use the following address
    @ff.select_list(:name, 'ip_settings').select_value('1')
    # IP Address
    if @ff.contains_text('IP Address') 
	@ff.text_field(:name, 'static_ip0').value=(@ip[0])
	@ff.text_field(:name, 'static_ip1').value=(@ip[1])
	@ff.text_field(:name, 'static_ip2').value=(@ip[2])
	@ff.text_field(:name, 'static_ip3').value=(@ip[3])
    end
    # Subnet Mask
    if @ff.text.include?('Subnet Mask') && (not @ff.contains_text('Override Subnet Mask')) 
	@ff.text_field(:name, 'static_netmask0').value=(@nm[0])
	@ff.text_field(:name, 'static_netmask1').value=(@nm[1])
	@ff.text_field(:name, 'static_netmask2').value=(@nm[2])
	@ff.text_field(:name, 'static_netmask3').value=(@nm[3])
    end
    # Subnet Mask for PPPoE
    if @ff.contains_text('Override Subnet Mask') 
	@ff.checkbox(:name,'override_subnet_mask').set
	@ff.text_field(:name, 'static_netmask_override0').value=(@nm[0])
	@ff.text_field(:name, 'static_netmask_override1').value=(@nm[1])
	@ff.text_field(:name, 'static_netmask_override2').value=(@nm[2])
	@ff.text_field(:name, 'static_netmask_override3').value=(@nm[3])
    end
    # Default Gateway
    if @ff.contains_text('Default Gateway') 
	@ff.text_field(:name, 'static_gateway0').value=(@gw[0])
	@ff.text_field(:name, 'static_gateway1').value=(@gw[1])
	@ff.text_field(:name, 'static_gateway2').value=(@gw[2])
	@ff.text_field(:name, 'static_gateway3').value=(@gw[3])
    end
    # Primary DNS Server
    if @ff.contains_text('DNS Server') 
	@ff.select_list(:id, 'dns_option').select_value('0')
	@ff.text_field(:name, 'primary_dns0').value=('8')
	@ff.text_field(:name, 'primary_dns1').value=('8')
	@ff.text_field(:name, 'primary_dns2').value=('8')
	@ff.text_field(:name, 'primary_dns3').value=('8')
    end
    @ff.link(:text, 'Apply').click
    @ff.link(:text, 'Apply').click
  end
  
end


begin
# parse the input
  opts.each do |opt, arg|
    case opt
    when '-d'
      rawadd = arg.split('/');
      $address = rawadd[0]
     puts " address = #{$address}"
    when '-c'
      puts " media = #{arg} "
      if ( arg !~ /^\s*$/)

	case arg
	    
	    when '0'
		puts "Media = ether"
		$media = 'ether'
	    
	    when '1'
		puts "Media = coax"
		$media = 'coax'

	    when '2'
		puts "Media = pppoe"
		$media = 'pppoe'

	    when '3'
		puts "Media = pppoe2"
		$media = 'pppoe2'
	    else 
		self.msg(rule_name,:error,'WAN interface','Did NOT get right Properties of wan Connection')
		return
	    end
      end
    when '-u'
      puts " user = #{arg} "
      $user = arg
    when '-p'
      puts " password = #{arg} "
      $password = arg
    when '-h'
      puts "Usage:setupWanIf.rb  -d <dut #{$address}>  -u <user=#{$username}> -p <password=#{$password}> -c <coax=1,ether=0,pppoe=2,pppoe2=3 default=#{$media}>"
      exit 1
    end
  end
end

begin
  # Ruby start
  puts 'RUBY SCRIPT START ...'
  dut = Initialize_BHR2_WAN.new
  cmd= 'killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait
  sleep 2
  dut.linkdut
  dut.logout
  puts 'Login ...'
  dut.login
  puts 'Enable WAN '+$media
  dut.setting_WAN_port($media,$enable)
  dut.logout
  dut.login
  case $media
    when 'ether'
	#if ( $media =~ /ether/)   
	puts 'Disable WAN coax'   
	dut.setting_WAN_port('coax',$disable)
    when 'coax'
	puts 'Disable WAN ethernet'   
	dut.setting_WAN_port('ether',$disable)
	dut.setting_WAN_port('ether',$disable)
	dut.setting_WAN_port('pppoe2',$disable)
    when 'pppoe'
	puts 'Disable WAN coax'
	dut.setting_WAN_port('coax',$disable)
	dut.login
	dut.setting_WAN_port('pppoe',$enable)
    when 'pppoe2'
	puts 'Disable WAN ethernet'   
	dut.setting_WAN_port('ether',$disable)
	dut.setting_WAN_port('ether',$disable)
	dut.setting_WAN_port('pppoe2',$enable)
    else
	puts "Error: Can not operate any media interface"
	return
    end
  dut.logout
  dut.login
  case $media

    when 'ether'   
	
	puts 'Start initialize WAN '+$media   
	dut.initialize_WAN_port('coax','12.10.10.20','255.255.0.0','12.10.10.254')
	dut.initialize_WAN_port('ether','10.10.10.254','255.255.255.0','10.10.10.47')
    when 'coax'
	puts 'Start initialize WAN '+$media   
	dut.initialize_WAN_port('ether','13.10.10.20','255.255.0.0','13.10.10.254')
	dut.initialize_WAN_port('coax','10.10.10.254','255.255.255.0','10.10.10.47')
	puts " Since bringing up WANMOCA takes time, it is worthwhile to wait for 60 seconds"
	sleep 60
    when 'pppoe'
	puts 'Start initialize WAN '+$media
	dut.initialize_WAN_port('coax','12.10.10.20','255.255.0.0','12.10.10.254')
	dut.initialize_WAN_port('pppoe','10.10.10.254','255.255.255.0','10.10.10.47')
    when 'pppoe2'
	puts 'Start initialize WAN '+$media   
	dut.initialize_WAN_port('ether','13.10.10.20','255.255.0.0','13.10.10.254')
	dut.initialize_WAN_port('pppoe2','10.10.10.254','255.255.255.0','10.10.10.47')
	puts " Since bringing up WANMOCA takes time, it is worthwhile to wait for 60 seconds"
	sleep 20
    else 
	puts "Error: Can not setting up any media interface"
  end
  dut.logout
  dut.login
  case $media
    when 'ether'
	#if ( $media =~ /ether/)   
	puts 'Enable WAN Ethernet'   
	dut.setting_WAN_port('pppoe',$disable)
	dut.setting_WAN_port('pppoe2',$disable)
    when 'coax'
	puts 'Enable WAN Coax'   
	dut.setting_WAN_port('pppoe',$disable)
	dut.setting_WAN_port('pppoe2',$disable)
    when 'pppoe'
	puts 'Enable WAN PPPoE'
	dut.setting_WAN_port('pppoe',$enable)
    when 'pppoe2'
	puts 'Enable WAN PPPoE 2'   
	dut.setting_WAN_port('pppoe2',$enable)
    else
	puts "Error: Can not operate any media interface"
	return
    end
  dut.logout

  dut.close
  puts 'RUBY SCRIPT END'
end
