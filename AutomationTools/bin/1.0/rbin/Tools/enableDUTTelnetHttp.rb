################################################################
#     enableTelnetAccess.rb
#     Author:         RuBingSheng
#     Date:           since 2009.02.12
#     Contact:        Bru@actiontec.com
#     Discription:    Enable Telnet Port Access for WAN and LAN
#     Input:          it depends
#     Output:         the  result of operation
################################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'

$username = 'admin'
$password = 'admin1'
$address = 'none'
$port='80'

def waitUntil
  until yield
    sleep 0.5
  end
end

class EnableTelnetAccess
  
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
  
  def enable_telnet_http_port
    puts 'enable_telnet_http_port ...'
    @ff.link(:href, /actiontec%5Ftopbar%5Fadv%5Fsetup/).click
    @ff.span(:text, 'Yes').click
    @ff.link(:text, 'Local Administration').click
    @ff.checkbox(:index,1).set
    @ff.span(:text, 'Apply').click
    @ff.link(:text, 'Remote Administration').click
    @ff.checkbox(:index,1).set
    @ff.checkbox(:name, "is_http_primary").set
    @ff.span(:text, 'Apply').click
    sleep 1
  end
  
end

opts = GetoptLong.new(
   ['-d',  GetoptLong::REQUIRED_ARGUMENT]
)

begin
  puts 'RUBY SCRIPT START ...'
  opts.each do |opt, arg|
    case opt
     when '-d'
       $address = arg
       arr_ip = $address.split('/')
       $address = arr_ip[0]
       puts " address = #{$address}"
     end
    end
  dut = EnableTelnetAccess.new
  dut.login
  dut.enable_telnet_http_port
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'
end
