#!/usr/bin/ruby
################################################################
#     enableLocalTelnet.rb
#     Author: Joe Nguyen
#          
#     Description:    Enable Telnet Port Access for LAN only
################################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'


$userInput = { 
  'username'=> 'admin',
  'disable'=>'0',
  'password'=> 'abc123',
  'dutip' => '192.168.1.1',
  'port'=>'80',
};

# handle any command line arguments 
opts = GetoptLong.new( 
     ['-n',  GetoptLong::NO_ARGUMENT],
     ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-i',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-h',  GetoptLong::NO_ARGUMENT]
)


def waitUntil
  until yield
    sleep 1 
  end
end

class EnableTelnetAccess
  
  def initialize
    @ff = FireWatir::Firefox.new
    # please add your general initialize code here
  end
  
  def linktoRouterGUI(dutip,port)
    # link to Device GUI
    puts 'link to Device GUI...'
    if ( ( port == '8443')  ||  ( port == '443') ) 
      url = 'https://' + dutip + ':' + port + '/'
    else
      url = 'http://' + dutip + ':' + port + '/'
    end
    @ff.goto(url)
    sleep 5
    if ! @ff.contains_text('Login')
      $stderr.print "Logout failed\n"
    end
    #@ff.span(:text, 'Login').exists? 
  end
  
  def close
    #close Firefox windows
    @ff.close
  end
  
  def login(usr,pwd,dutip,port)
    linktoRouterGUI(dutip,port)
    linktoRouterGUI(dutip,port)
    linktoRouterGUI(dutip,port)
    puts 'Attempting to login ...'
    @ff.text_field(:name, 'user_name').value=(usr)
    @ff.text_field(:name, 'passwd1').set(pwd)
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
  
  def enable_telnet_port
    puts 'enable_telnet_port ...'
    @ff.link(:href, /actiontec%5Ftopbar%5Fadv%5Fsetup/).click
    @ff.span(:text, 'Yes').click
    @ff.link(:text, 'Local Administration').click
    @ff.checkbox(:index,1).set
    @ff.span(:text, 'Apply').click
#    @ff.link(:text, 'Remote Administration').click
#    @ff.checkbox(:index,1).set
#    @ff.span(:text, 'Apply').click
    sleep 1
  end
  def disable_telnet_port
    puts 'disable_telnet_port ...'
    @ff.link(:href, /actiontec%5Ftopbar%5Fadv%5Fsetup/).click
    @ff.span(:text, 'Yes').click
    @ff.link(:text, 'Local Administration').click
    @ff.checkbox(:index,1).clear
    @ff.span(:text, 'Apply').click
#    @ff.link(:text, 'Remote Administration').click
#    @ff.checkbox(:index,1).set
#    @ff.span(:text, 'Apply').click
    sleep 1
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
    when '-n'
      puts " Telnet Disable is set"
      $userInput['disable'] = '1';
    when '-i'
      puts " port = #{arg} "
      $userInput['port'] = arg
    when '-u'
      puts " user = #{arg} "
      $userInput['username'] = arg
    when '-d'
      ip=arg.split('/')
      puts " destination = #{arg} --"+ip[0]
      $userInput['dutip'] = ip[0]
    when '-p'
       puts " password = #{arg} "
      $userInput['password'] = arg
      
    when '-h'
     puts "Usage:ruby enableLocalTel.rb -i <port="+$userInput['port']+"> -d <dutip="+$userInput['dutip']+">  -u <user="+$userInput['username']+"> -p <password="+$userInput['password']+">"
    exit 1
    end
  end
rescue => ex
  	 puts "Error: #{ex.class}: #{ex.message}"
end




begin
  puts 'RUBY SCRIPT START ...'
  cmd='killall firefox;killall firefox-bin;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork {exec(cmd)}
  Process.wait
  dut = EnableTelnetAccess.new
  dut.login($userInput['username'],$userInput['password'],$userInput['dutip'],$userInput['port'])
  if ( $userInput['disable'] == '0' )
    dut.enable_telnet_port
  else
    dut.disable_telnet_port
  end
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'
end
