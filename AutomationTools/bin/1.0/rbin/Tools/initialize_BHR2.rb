################################################################
#     initialize_BHR2.rb
#     Author:         RuBingSheng
#     Date:           since 2009.02.12
#     Contact:        Bru@actiontec.com
#     Discription:    initialize BHR2 WAN port 
#     Input:          it depends
#     Output:         the  result of operation
################################################################

require 'English'
require 'rubygems'
require 'firewatir'

$username = 'admin'
$password = 'admin1'
$address = '192.168.1.1'
$port='80'

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
    @ff = FireWatir::Firefox.new(:waitTime => 5)
    sleep 1
    @ff.goto(url)
#    waitUntil { @ff.span(:text, 'Login').exists? }
  end
  
  def close
    #close Firefox windows
    @ff.close
  end
  
  def login
    linktoRouterGUI
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
      puts 'Normal  Login\n' 
      @ff.text_field(:name, 'user_name').set($username)
      @ff.text_field(:name, 'passwd1').set($password)
      @ff.link(:text, 'OK').click
      if @ff.contains_text('Login failed')
        $stderr.print "Login failed\n"
        exit
      end
      puts 'Logging OK'
    end
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
      if (@ff.text.include? 'Advanced >>')
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
    @ff.text_field(:name, 'static_ip0').value=('10')
    @ff.text_field(:name, 'static_ip1').value=('10')
    @ff.text_field(:name, 'static_ip2').value=('10')
    @ff.text_field(:name, 'static_ip3').value=('254')
    # Subnet Mask
    @ff.text_field(:name, 'static_netmask0').value=('255')
    @ff.text_field(:name, 'static_netmask1').value=('255')
    @ff.text_field(:name, 'static_netmask2').value=('255')
    @ff.text_field(:name, 'static_netmask3').value=('0')
    # Default Gateway
    @ff.text_field(:name, 'static_gateway0').value=('10')
    @ff.text_field(:name, 'static_gateway1').value=('10')
    @ff.text_field(:name, 'static_gateway2').value=('10')
    @ff.text_field(:name, 'static_gateway3').value=('235')
    # Primary DNS Server
    @ff.select_list(:id, 'dns_option').select_value('0')
    @ff.text_field(:name, 'primary_dns0').value=('10')
    @ff.text_field(:name, 'primary_dns1').value=('10')
    @ff.text_field(:name, 'primary_dns2').value=('10')
    @ff.text_field(:name, 'primary_dns3').value=('253')
    @ff.link(:text, 'Apply').click
  end

  def initialize_WAN_Coax_port
    puts 'initialize_WAN_Coax_port ...'
    
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
    puts '==>initialize_WAN_Coax_port ...'
    #   
    # Internet Protocol = use the following address
    @ff.select_list(:name, 'ip_settings').select_value('1')
    # IP Address
    @ff.text_field(:name, 'static_ip0').value=('10')
    @ff.text_field(:name, 'static_ip1').value=('10')
    @ff.text_field(:name, 'static_ip2').value=('10')
    @ff.text_field(:name, 'static_ip3').value=('254')
    # Subnet Mask
    @ff.text_field(:name, 'static_netmask0').value=('255')
    @ff.text_field(:name, 'static_netmask1').value=('255')
    @ff.text_field(:name, 'static_netmask2').value=('255')
    @ff.text_field(:name, 'static_netmask3').value=('0')
    # Default Gateway
    @ff.text_field(:name, 'static_gateway0').value=('10')
    @ff.text_field(:name, 'static_gateway1').value=('10')
    @ff.text_field(:name, 'static_gateway2').value=('10')
    @ff.text_field(:name, 'static_gateway3').value=('235')
    # Primary DNS Server
    @ff.select_list(:id, 'dns_option').select_value('0')
    @ff.text_field(:name, 'primary_dns0').value=('10')
    @ff.text_field(:name, 'primary_dns1').value=('10')
    @ff.text_field(:name, 'primary_dns2').value=('10')
    @ff.text_field(:name, 'primary_dns3').value=('253')
    @ff.link(:text, 'Apply').click
  end
  
end

begin
  # Ruby start
  puts 'RUBY SCRIPT START ...'
  cmd= 'killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait
  dut = Initialize_BHR2_WAN.new
  puts 'Login ...'
  dut.login
  sleep 2
  dut.initialize_WAN_port
  sleep 2
#  dut.initialize_WAN_Coax_port
#  sleep 20
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'
end
