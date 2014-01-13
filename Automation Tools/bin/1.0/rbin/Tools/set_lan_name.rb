################################################################
#     acquire_contents_networkconnections.rb
#     Author:         Hugo
#     Date:           since 2010.11.4
#     Discription:    
#     Input:          it depends
#     Output:         the  result of operation
################################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'

$username = 'admin'
$password = 'admin1'
$address = '192.168.1.1'
$port = '80'
$str = nil

def waitUntil
  until yield
    sleep 0.5
  end
end

class AcquireText
  
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
    puts 'Login OK'
  end
  
  def logout
    puts 'Logout ...'
    @ff.link(:name, 'logout').click
    if ! @ff.contains_text('User has logged out')
      $stderr.print "Logout failed\n"
    end
  end
  
  def set_text
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
      @ff.link(:href, 'javascript:mimic_button(\'edit: br0..\', 1)').click
   rescue
      puts 'Error : Did not reach Network(Home/Office) page'
      return
   end

   begin
      @ff.text_field(:name, 'description').value = $str
      @ff.link(:text, 'Apply').click
      waitUntil { @ff.link(:name, 'logout').exists? }
   rescue
      puts 'Error : Cannot set Lan name'
   end

  end
  
end

opts = GetoptLong.new(
   ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
   ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
   ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
   ['-s',  GetoptLong::REQUIRED_ARGUMENT]
)

begin
  puts 'RUBY SCRIPT START ...'
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait
  puts "KILL FIREFOX= #{cmd} "
  sleep 2

  opts.each do |opt, arg|
    case opt
     when '-d'
       $address = arg
       puts " address = #{$address}"
     when '-u'
       $username = arg
       puts " username = #{$username}"
     when '-p'
       $password = arg
       puts " password = #{$password}"
     when '-s'
       $str = arg
       puts " set name = #{$str}"
     end
    end
  dut = AcquireText.new
  dut.login
  dut.set_text

  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'

end
