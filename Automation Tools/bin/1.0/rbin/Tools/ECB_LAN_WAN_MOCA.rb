################################################################
#     ECB_LAN_WAN_MOCA.rb
#     Author:         RuBingSheng
#     Date:           since 2009.02.12
#     Contact:        Bru@actiontec.com
#     Discription:    Setup LAN or WAN MoCA for ECB Device
#     Input:          it depends
#     Output:         the  result of operation
################################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'

$password = 'entropic'
$address = '192.168.144.20'
$port='80'

$mode=nil   

opts = GetoptLong.new( 
                      ['--mode', '-m', '-M',  GetoptLong::REQUIRED_ARGUMENT],
['--help','-h','-H',    GetoptLong::NO_ARGUMENT]
)

begin
  opts.each do |opt, arg|
    case opt
    when '--mode'
      if arg=='l' or arg=='L' or arg=='lan' or arg=='LAN' or arg=='Lan'
        $mode='LAN'
      else if arg=='w' or arg=='W' or arg=='wan' or arg=='WAN' or arg=='Wan'
        $mode='WAN'
      end
    end
  when '--help'
    puts('Usage Information:')
    puts('  ruby ECB_LAN_WAN_MOCA -h: show help infomation ')
    puts('  ruby ECB_LAN_WAN_MOCA -m l: ECB Device switch to LAN MoCA (15 1150MHz) ')
    puts('  ruby ECB_LAN_WAN_MOCA -m w: ECB Device switch to WAN MoCA (9 1000MHz) ')
    exit
  end
end
rescue => ex
puts "Error: #{ex.class}: #{ex.message}"
end

class ECB_LAN_WAN_MOCA

def initialize
  # please add your general initialize code here
end

def linktoRouterGUI
  # link to Device GUI
  puts 'link to ECB Device GUI...'
  url = 'http://' + $address + ':' + $port + '/'
  @ff = FireWatir::Firefox.new
  sleep 1
  @ff.goto(url)
end

def close
  #close Firefox windows
  @ff.close
end

def login
  linktoRouterGUI
  puts 'Attempting to login ...'
  @ff.text_field(:name, 'AdminPswd').set($password)
  @ff.button(:value, 'Login').click
  if @ff.contains_text('Login failed')
    $stderr.print "Login failed\n"
    exit
  end
  puts 'Logging OK'
end

def device_initialize_LAN       
  # 15 is 1150MHz for BHR2 LAN MoCA
  @ff.select_list(:name, 'fs_channel').select_value('15') 
  @ff.button(:value, 'Apply').click  
  puts 'ECB is working in LAN MoCA (1150MHz)'
  sleep 1
end

def device_initialize_WAN     
  # 9 is 1000MHz for BHR2 LAN MoCA
  @ff.select_list(:name, 'fs_channel').select_value('9') 
  @ff.button(:value, 'Apply').click   
  puts 'ECB is working in WAN MoCA (1000MHz)'
  sleep 1
end

end

begin
  puts 'RUBY SCRIPT START ...'
  dut = ECB_LAN_WAN_MOCA.new
  dut.login
  sleep 1
  if $mode=='LAN'
    dut.device_initialize_LAN
  else if $mode=='WAN'
    dut.device_initialize_WAN
  end
  end
  puts 'RUBY SCRIPT END'
end
