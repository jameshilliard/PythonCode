################################################################
#     Main.rb
#     Author:          RuBingSheng
#     Date:            since 2009.02.16
#     Contact:         Bru@actiontec.com
#     Discription:     Main function of using Ruby in Web application test
#     Input:           it depends
#     Output:          the result of operation
################################################################
# require 'importenv'
# require 'pathname'
require 'English'
require 'rubygems'
require 'firewatir'
require 'json'
require 'getoptlong'
require 'terminator'
require 'net/telnet'
require 'thread'
$log =  Dir.getwd() + "/"+"result_js.log"
$dir=File.dirname(__FILE__)+"/"
# $dir = ENV['U_RUBYBIN']
puts " Path1 #{$dir}"
$temp=$dir
require $dir + 'MainPage/MainPage'
$dir=$temp
puts " Path2 #{$dir}"
$dir=$temp
require $dir + 'Wireless/Wireless'
$dir=$temp
require $dir + 'Wireless/Wireless_G'
$dir=$temp
require $dir + 'MyNetwork/MyNetwork'
$dir=$temp
require $dir + 'Firewall/Firewall'
$dir=$temp
require $dir + 'ParentalControl/ParentalControl'
$dir=$temp
require $dir + 'Advanced/Advanced'
$dir=$temp
require $dir + 'Sysmon/Sysmon'

$user="none";
$passwd="none"
$address="none"



if RUBY_PLATFORM =~ /darwin/
  require 'appscript'
end

#
# simple function to read in the passed in file name
# and attempt to convert the contects from JSON to
# a Ruby hash
#
def parse_json(filename)
  p 'parse_json ' + filename if $debug >98
  begin
    json = JSON.parse!(File.open(filename).read)
  rescue JSON::ParserError => ex
    puts "Error: Cannot parse " + filename
    puts "#{ex.message}"
    exit -1
  end
  return json
end

def bhr2_tel(dev_ip, dev_user, dev_passwd)
  if dev_ip == nil
    dev_ip = '192.168.1.1'
  else
    arr_ip_bhr2 = dev_ip.split('/')
    dev_ip = arr_ip_bhr2[0]
  end

  if dev_user == nil
    dev_user = 'admin'
  end

  if dev_passwd == nil
    dev_passwd = 'admin1'
  end

  client = Net::Telnet::new("Host" => dev_ip,
                          "Port" => '23',
                          "Timeout" => 20
  ) {|c| print c}
  str1 = nil
  client.waitfor({}) { |c| print c; break if c.include? "Username" }
  client.puts(dev_user)
  client.waitfor({}) { |c| print c; break if c.include? "Password" }
  client.puts(dev_passwd)
  
  client.waitfor({}) { |c| print c; break if c.include? "Wireless Broadband Router" }
  client.puts("conf print manufacturer/hardware/serial_num")
  client.waitfor({}) { |c| print c; str1 = c; break if c.include? "Wireless Broadband Router" }
  client.puts("exit") { |c| print c; }
  STDOUT.flush
  client.close
 
  arr_str_rst = str1.split
  arr_str_sec = arr_str_rst[3]
  case arr_str_sec
    when /CSJE/
       return 'E'
    when /CSJG/
       return 'G'
    when /CSJF/
       return 'F'
    when /CSJI/
       return 'I'
  end

end

#
# some default values
#
$debug = 0
$part=nil
$resultjsonfile_path_name=nil
input = FALSE

#
# the base class that knows how to configure the device
#

# handle any command line arguments 
opts = GetoptLong.new( 
                      ['--json', '-j', '-f',  GetoptLong::REQUIRED_ARGUMENT], 
                      ['--debug', '-d',        GetoptLong::REQUIRED_ARGUMENT],
                      ['--part', '-p',        GetoptLong::REQUIRED_ARGUMENT],
                      ['--dump',                  GetoptLong::NO_ARGUMENT],
                      ['-u',  GetoptLong::REQUIRED_ARGUMENT],
                      ['-a',  GetoptLong::REQUIRED_ARGUMENT],
                      ['-t',  GetoptLong::REQUIRED_ARGUMENT],
                      ['-h',  GetoptLong::NO_ARGUMENT],
                      ['-l',  GetoptLong::REQUIRED_ARGUMENT]

)

begin
  puts 'RUBY SCRIPT START ...'
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait
  print " KILL FIREFOX= #{cmd} "
  $address = nil
  $password = nil
  $user = nil
  opts.each do |opt, arg|
    case opt
    when '--json'
      input = parse_json(arg)
#      part=arg.split("json_conf")
#      $resultjsonfile_path_name= part[1].split('.')[0]+'_result.'+part[1].split('.')[1]
    when '--debug'
      $debug = arg.to_i
    when '--part'
      $part = arg
    when '-l'
      puts " LOGDIR = #{arg} "
      $log = arg

    when '-u'
      puts " user = #{arg} "
      $user = arg
    when '-a'
       puts " password = #{arg} "
      $password = arg
    when '-h'
    $address = arg
     puts "Usage:Main.rb -f <jason file >  -t <dut #{$address}>  -u <user=#{$username}> -p <password=#{$password}> -d <debug> "
    exit 1
    when '-t'
    $address = arg
     puts " address = #{$address}"
    end
  end
rescue => ex
  puts "Attention: #{ex.class}: #{ex.message}"
end

$resultjsonfile_path_name= $log 

pp input if $debug > 98

# for normal use, make the browser appear in a virtual frame buffer
# so this can be run without a GUI.
if $debug == 0 and RUBY_PLATFORM =~ /linux/
  cmd = sprintf('/usr/X11R6/bin/Xvfb :%d -screen 0 1024x768x16 2>/dev/null', Process.pid)
  disp = sprintf(':%d', Process.pid)
  Xvfb_pid = fork {exec(cmd)}
  old_display = ENV['DISPLAY']
  ENV['DISPLAY'] = disp
end


begin
  hd_VER = nil
  begin
  	thread = Thread.start {hd_VER = bhr2_tel($address, $user, $password)}
	thread.join
  rescue
	puts "Telnet access might not be available, will take DUT as F borad"
	hd_VER = 'F'
  end
  puts "\nnow DUT is #{hd_VER}"
  case $part 
  when 'B'
    dut = MainPage.new
    # the results hash.
    output = {}
    # iterate over the rules in the input file
    for key in input.sort
      if not key[1].key?('section')
        dut.msg(key, 'Error', 'n/a', 'No section key found')
      else
        dut.do(key[0], key[1])
      end
    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  when 'W'
    # --------------------------------------------
    # Add branch due to updated GUI for G and I board.
    # Modify by Aleon 		2011.02.11
    # --------------------------------------------
    if hd_VER == "G" || hd_VER == "I" || hd_VER == "F"
    	dut = Wireless_G.new
    	# the results hash.
    	output = {}
    	# iterate over the rules in the input file
    	for key in input.sort
      	    if not key[1].key?('section')
        	dut.msg(key, 'Error', 'n/a', 'No section key found')
      	    else
        	dut.do(key[0], key[1])
      	    end
    	end
    else
    	dut = Wireless.new
    	# the results hash.
    	output = {}
    	# iterate over the rules in the input file
    	for key in input.sort
      	    if not key[1].key?('section')
        	dut.msg(key, 'Error', 'n/a', 'No section key found')
      	    else
        	dut.do(key[0], key[1])
      	    end
    	end

    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  when 'M'
    dut = MyNetwork.new
    # the results hash.
    output = {}
    # iterate over the rules in the input file
    for key in input.sort
      if not key[1].key?('section')
        dut.msg(key, 'Error', 'n/a', 'No section key found')
      else
        dut.do(key[0], key[1])
      end
    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  when 'F'
    dut = Firewall.new
    # the results hash.
    output = {}
    # iterate over the rules in the input file
    for key in input.sort
      if not key[1].key?('section')
        dut.msg(key, 'Error', 'n/a', 'No section key found')
      else
        dut.do(key[0], key[1])
      end
    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  when 'P'
    dut = ParentalControl.new
    # the results hash.
    output = {}
    # iterate over the rules in the input file
    for key in input.sort
      if not key[1].key?('section')
        dut.msg(key, 'Error', 'n/a', 'No section key found')
      else
        dut.do(key[0], key[1])
      end
    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  when 'A'
    dut = Advanced.new
    # the results hash.
    output = {}
    # iterate over the rules in the input file
    for key in input.sort
      if not key[1].key?('section')
        dut.msg(key, 'Error', 'n/a', 'No section key found')
      else
        dut.do(key[0], key[1])
      end
    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  when 'S'
    dut = Sysmon.new
    # the results hash.
    output = {}
    # iterate over the rules in the input file
    for key in input.sort
      if not key[1].key?('section')
        dut.msg(key, 'Error', 'n/a', 'No section key found')
      else
        dut.do(key[0], key[1])
      end
    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  else
    dut = BasicUtility.new
    # the results hash.
    output = {}
    # iterate over the rules in the input file
    for key in input.sort
      if not key[1].key?('section')
        dut.msg(key, 'Error', 'n/a', 'No section key found')
      else
        dut.do(key[0], key[1])
      end
    end
    # save the output
    dut.saveoutput($resultjsonfile_path_name)
  end
  puts 'RUBY SCRIPT END'
  
ensure
  
  # OSX needs some special handling to close the browser
  if RUBY_PLATFORM =~ /darwin/
    if Appscript.app('System Events').processes['Firefox'].exists() 
      Appscript.app('Firefox').quit 
    end
  else
    begin
      dut.close if defined? dut
    rescue
      puts 'Warning: Problems closing browser window'
    end
  end
  
  # if we're using the virtual frame buffer, stop it
  if $debug == 0 and RUBY_PLATFORM =~ /linux/
    Process.kill("KILL", Xvfb_pid)
    ENV['DISPLAY'] = old_display
  end
end
