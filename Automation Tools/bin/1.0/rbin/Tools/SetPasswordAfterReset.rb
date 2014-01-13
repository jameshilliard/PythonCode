################################################################
#     SetPasswordAfterReset.rb
#     Author:         RuBingSheng
#     Date:           since 2009.02.12
#     Contact:        Bru@actiontec.com
#     Discription:    Set initial password after reset
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

class SetPasswordAfterReset
  
  def initialize
    # please add your general initialize code here
  end
  
  def linktoRouterGUI
    # link to Device GUI
    puts 'link to Device GUI...'
    url = 'http://' + $address + ':' + $port + '/'
    @ff = FireWatir::Firefox.new(:waitTime=>10)
    sleep 1
    @ff.goto(url)
    waitUntil { @ff.span(:text, 'Login').exists? }
  end
  
  def close
    #close Firefox windows
    @ff.close
  end
  
  def first_login
    # link to Device GUI
    puts 'link to Device GUI...'
    url = 'http://' + $address + ':' + $port + '/'
    @ff = FireWatir::Firefox.new(:waitTime => 7)
    sleep 1
    @ff.goto(url)
    #waitUntil { @ff.span(:text, 'Login Setup').exists? }
    puts 'Attempting to first login after reset Device...'
    
    if @ff.contains_text('Login Setup')
      # Firsty Login  in Web page 'Login Setup'
      @ff.text_field(:index, 1).value=($username )
      @ff.text_field(:index, 2).set($password )
      @ff.text_field(:index, 3).set($password )
      @ff.link(:text, 'OK').click
      if @ff.contains_text('Login failed')
        $stderr.print "First Login failed\n"
        self.close
        exit
      end
      puts 'First Logging OK'
    else
      puts('Not first login!')
      self.close
      exit
    end
  end
  
  def login
    linktoRouterGUI
    puts 'Attempting to login ...'
    @ff.text_field(:name, 'user_name').set($username)
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
  
end

begin
  puts 'RUBY SCRIPT START ...'
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait

  dut = SetPasswordAfterReset.new
  dut.first_login
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'
end
