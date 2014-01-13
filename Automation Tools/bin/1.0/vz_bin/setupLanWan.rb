################################################################

################################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'

$userInput = { 
  'username'=> 'admin',
  'password'=> 'abc123',
  'address' => '192.168.1.1',
  'port'=>'80',
  'wanip' => '0.0.0.0',
  'wangw' => '0.0.0.0',
  'wandns' => '0.0.0.0',
  'wannetmask' => '0.0.0.0',

};

# handle any command line arguments 
opts = GetoptLong.new( 
     ['-f',  GetoptLong::REQUIRED_ARGUMENT], 
     ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-d',  GetoptLong::OPTIONAL_ARGUMENT],

     ['-wip',  GetoptLong::REQUIRED_ARGUMENT],
     ['-wgw',  GetoptLong::REQUIRED_ARGUMENT],
     ['-wnm',  GetoptLong::REQUIRED_ARGUMENT],
     ['-wds',  GetoptLong::REQUIRED_ARGUMENT],

     ['-h',  GetoptLong::NO_ARGUMENT]
)


def waitUntil
  until yield
    sleep 0.5
  end
end

class Initialize_BHR2_WAN  
  def initialize
    # please add your general initialize code here
  end
  
  def linktoRouterGUI
    # link to Device GUI
    puts 'link to Device GUI...'
    url = 'http://' + $address + ':' + $port + '/'
    @ff = FireWatir::Firefox.new
    sleep 1
    @ff.goto(url)
    waitUntil { @ff.span(:text, 'Login').exists? }
  end
  
  def close
    #close Firefox windows
    @ff.close
  end
  
  def login
    linktoRouterGUI
    puts 'Attempting to login ...'
    @ff.text_field(:name, 'user_name').value=($username)
    @ff.text_field(:name, 'passwd1').set($password)
    @ff.link(:text, 'OK').click
    if @ff.contains_text('Login failed')
      $stderr.print "Login failed\n"
      exit
    end
    puts 'Logging OK'
  end
  
  def logout
    puts 'Logging out ...'
    @ff.link(:name, 'logout').click
    if ! @ff.contains_text('User has logged out')
      $stderr.print "Logout failed\n"
    end
  end
  
  def initialize_WAN_port
    puts 'initialize_WAN_port ...'
    
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
      if @ff.text.include? 'Advanced >>'
        @ff.link(:text,'Advanced >>').click
      end
    rescue
      self.msg(rule_name,:error,'initialize BHR2','Wrong with\'Advanced >>\'')
    end
    
    # click the Network Connections link
    # click the 'Broadband Connection(Ethernet)' link 
    begin
      @ff.link(:href, 'javascript:mimic_button(\'edit: eth1..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'WanEthhernet', 'Did not reach Broadband Connection(Ethernet) page')
      return
    end
    # and then click 'Settings' link
    begin
      @ff.link(:text, 'Settings').click
    rescue
      self.msg(rule_name, :error, 'WanEthhernet', 'Did not Broadband Connection(Ethernet) Properties page')
      return
    end
    
    # do setup    
    # Internet Protocol = use the following address
    @ff.select_list(:name, 'ip_settings').select_value('1')
    # IP Address
    @ff.text_field(:name, 'static_ip0').set('10')
    @ff.text_field(:name, 'static_ip1').set('10')
    @ff.text_field(:name, 'static_ip2').set('10')
    @ff.text_field(:name, 'static_ip3').set('254')
    # Subnet Mask
    @ff.text_field(:name, 'static_netmask0').set('255')
    @ff.text_field(:name, 'static_netmask1').set('255')
    @ff.text_field(:name, 'static_netmask2').set('255')
    @ff.text_field(:name, 'static_netmask3').set('0')
    # Default Gateway
    @ff.text_field(:name, 'static_gateway0').set('10')
    @ff.text_field(:name, 'static_gateway1').set('10')
    @ff.text_field(:name, 'static_gateway2').set('10')
    @ff.text_field(:name, 'static_gateway3').set('235')
    # Primary DNS Server
    @ff.text_field(:name, 'primary_dns0').set('10')
    @ff.text_field(:name, 'primary_dns1').set('10')
    @ff.text_field(:name, 'primary_dns2').set('10')
    @ff.text_field(:name, 'primary_dns3').set('254')
    @ff.link(:text, 'Apply').click
  end
  
end

#--------------------------------
# Main:
# Parse Input
#--------------------------------
begin
  
# parse the input
  opts.each do |opt, arg|
    case opt
    	 when '-f'
    	      puts " filename = #{arg} "
    	      $firmware = arg
	 
    when '-u'
      puts " user = #{arg} "
      $userInput['username'] = arg
    when '-p'
       puts " password = #{arg} "
      $userInput['password'] = arg

    when '-h'

#     puts "Usage:fw-upgrade.rb -f <firm=#{$firmware}> -d <dut #{$address}>  -u <user=#{$username}> -p <password=#{$password}> "
    exit 1

    when '-wip' 
    when '-wgw'
    when '-wnm'
    when '-wds'

    when '-d'
      $userInput['address'] = arg
      puts " address = #{$address}"
    end
  end

  rescue => ex
  	 puts "Error: #{ex.class}: #{ex.message}"
  end


begin
  puts 'RUBY SCRIPT START ...'
  dut = Initialize_BHR2_WAN.new
  dut.login
  dut.initialize_WAN_port
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'
end
