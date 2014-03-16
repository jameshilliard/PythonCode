################################################################
#     deletePCRules.rb
#     Author:         RuBingSheng
#     Date:           since 2009.04.15
#     Contact:        Bru@actiontec.com
#     Discription:    delete PC Rules
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

class DeletePCRules
  
  def initialize
    # please add your general initialize code here
  end
  
  def linktoRouterGUI
    # link to Device GUI
    puts 'link to Device GUI...'
    url = 'http://' + $address + ':' + $port + '/'
    @ff = FireWatir::Firefox.new(:waitTime => 7)
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
  
  def deleteRules
    # click the parental control page
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5Fparntl%5Fcntrl/).click
    rescue
      return
    end
    
    # click the 'Rule Summary' link 
    begin
      @ff.link(:text, 'Rule Summary').click
    rescue
      return
    end
    
    # delete Rules
    begin
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: 0..\', 1)').click
      @ff.link(:text, 'OK').click
      puts 'delete one rules successful!'
    rescue
      begin
          @ff.link(:href, 'javascript:mimic_button(\'wf_policy_remove: -2..\', 1)').click
          @ff.link(:text, 'OK').click
      rescue
          puts 'no Parental Control rules exist now!'
          return
      end
    end
    
  end
  
end

begin
  puts 'RUBY SCRIPT START ...'
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait
  sleep 4
  dut = DeletePCRules.new
  dut.login
  dut.deleteRules
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'
end
