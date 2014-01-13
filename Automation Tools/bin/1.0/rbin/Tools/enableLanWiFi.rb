################################################################
#     EnableLanWiFi
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

$username = 'admin'
$password = 'admin1'
$address = '192.168.1.1'
$port='80'

def waitUntil
  until yield
    sleep 0.5
  end
end

class EnableLanWiFi
  
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
  
  def enable_lan_wifi
    puts 'enable_lan_wifi ...'
		begin
    	@ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
		rescue
			puts 'Fail to click My network'
			return
		end
		begin
    	@ff.link(:href, 'javascript:mimic_button(\'btn_tab_goto: 860..\', 1)').click
		rescue
			puts 'Fail to click Network Connections'
			return
		end
		begin
			@ff.link(:text, 'Wireless Access Point').click
		rescue
			puts 'Fail to click Wireless Access Point'
		end
		if @ff.contains_text('Enable')
			@ff.link(:text, 'Enable').click
			puts 'Click Enable LAN WiFi'
		else
			puts 'No need to Re-enable LAN WiFi'
		end
		sleep 1
  end
  
end

begin
  puts 'RUBY SCRIPT START ...'
  dut = EnableLanWiFi.new
  dut.login
  dut.enable_lan_wifi
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'
end
