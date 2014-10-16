################################################################
#     enableWPS.rb
#     Author:         Aleon
#     Date:           since 2009.09.25
#     Contact:        hpeng@actiontec.com
#     Discription:    Repeat to configure WPS with enable and disable
#     Input:          it depends
#     Output:         the  result of operation
#     
################################################################
require 'English'
require 'rubygems'
require 'firewatir'
require 'json'
require 'getoptlong'
require 'terminator'

$username = 'admin'
$password = 'admin1'
$address = '192.168.1.1'
$port='80'
# handle any command line arguments 
opts = GetoptLong.new(
                      ['-i',  GetoptLong::REQUIRED_ARGUMENT],
                      ['-h',  GetoptLong::NO_ARGUMENT]
)

def waitUntil
  until yield
  sleep 0.5
  end
end

class CheckDynamicDNSStatus
  
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
    @ff.text_field(:name, 'user_name').value=$username
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

  def enableWPS
    # Get to the "Dynamic DNS" page.
	begin
      		@ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fwireless..\', 1)').click
    	rescue
      		$stderr.print "ERRORSUMMY, 'Goto Wireless Settings', 'Did not reach Wireless Settings'"
      		return
    	end

    	# Look for the confirmation page's text   
   	if not @ff.text.include? 'Advanced Security Settings'
	      	$stderr.print "ERRORSUMMY, 'Goto wireless setting', 'Did not reach are you sure page'"
        	return
    	end

     	# enter "Advanced Security Setting"
     	begin
         	@ff.link(:text, 'Advanced Security Settings').click
     	rescue
         	$stderr.print "ERRORSUMMY: The key 'Advanced Security Settings' NOT found"
         	return
     	end

     	# enter "Other Advanced Wireless Options"
     	begin
         	@ff.link(:text, 'Other Advanced Wireless Options').click
     	rescue
         	$stderr.print "ERRORSUMMY: The key 'Other Advanced Wireless Options' NOT found"
         	return
	end
	# Do you want to proceed?
     	begin 
	 	@ff.link(:text, "Yes").click
     	rescue
		$stderr.print "ERRORSUMMY: Can NOT enter to proceed"
		return
	end
	
	# WPS Settings
	if @ff.link(:text,"WPS Settings").exists? then
	    begin 
		@ff.link(:text, "WPS Settings").click
	    rescue
		puts "ERRORSUMMY: Can NOT enter 'WPS Settings'"
	    end
	else
	    puts "Can NOT find 'WPS Settings', pls enable WPA function"
	end

	# Repeat to Enable WPS and disable WPS
	i = 0
	puts $num
	while i <= $num.to_i
	    
	    # Enable WPS
	    begin
		@ff.checkbox(:name, "wps_enabled").set(true)
	    rescue
		puts "ERRORSUMMY: Can NOT Apply the enable status"
	    end
	    begin
		@ff.link(:text, "Apply").click
	    rescue
		puts "ERRORSUMMY: Can NOT Apply the enable status"
	    end
	    
	    sleep 10
	   
	    @ff.refresh
	    # Disable WPS
	    begin
		@ff.checkbox(:name, "wps_enabled").set(false)
	    rescue
	     puts "ERRORSUMMY: Can NOT Apply the disable status"
	    end
	    begin
		@ff.link(:text, "Apply").click
	    rescue
		puts "ERRORSUMMY: Can NOT Apply the disable status"
	    end
	    sleep 10
	    @ff.refresh

	    i += 1
	    puts "Repeat to the No. #{i}"
	end # end of while
    end # end of def

end # End of class
######################
#
# Main
#
# ###################  
begin
  # parse the input
  opts.each do |opt, arg|
    case opt
        
    	when '-i'
          puts "num = #{arg} "
      	  $num = arg
          puts "Set repeat times to: #{$num}"
	when '-h'
	        puts "Usage:checkDynamicDNSStatus.rb -i <$num=#{$num}> -h <help=#{$help}> "
    	    exit 1
   	end # End of case;
     end
end

begin
  puts 'RUBY SCRIPT START ...'
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait

  dut = CheckDynamicDNSStatus.new
  dut.login
  dut.enableWPS
  
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'

end
