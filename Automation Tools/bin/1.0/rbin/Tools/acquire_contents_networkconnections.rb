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
$compare_str = nil

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
  
  def is_contain_text
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

    sTable = false
    @ff.tables.each do |t|
        if ( t.text =~ /#{$compare_str}$/ )
            sTable = true
            break
        end
    end

    return sTable
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
  cmd='killall firefox; killall firefox-bin; rm -f ~/.mozilla/firefox/*/compreg.dat'
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
       $compare_str = arg
       puts " contain_text = #{$compare_str}"
     end
    end
  dut = AcquireText.new
  dut.login
  ret_index = dut.is_contain_text

  if ret_index == false
    puts "Fail : There is no #{$compare_str} string in page"
    dut.logout
    dut.close
    puts 'RUBY SCRIPT END'
    exit 1
  else
    puts "Success : There is #{$compare_str} string in page"
    dut.logout
    dut.close
    puts 'RUBY SCRIPT END'
    exit 0
  end

end
