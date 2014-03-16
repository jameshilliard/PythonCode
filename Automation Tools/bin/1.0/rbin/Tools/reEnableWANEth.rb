################################################################
#     checkDynamicDNSStatus.rb
#     Author:         Aleon
#     Date:           since 2009.08.22
#     Contact:        hpeng@actiontec.com
#     Discription:    Re-enable the interface of WAN ethernet;
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
#$address = '192.168.1.1'
$port='80'
$status="Updated"
# handle any command line arguments 
opts = GetoptLong.new(
                      ['-d',  GetoptLong::REQUIRED_ARGUMENT],
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
    url = 'http://' + $ipAddr + ':' + $port + '/'
    @ff = FireWatir::Firefox.new(:waitTime=>5)
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

  def reenableInterface
    # Get to the "Dynamic DNS" page.
	begin
      		@ff.link(:text, 'My Network').click
    	rescue
      		$stderr.print "ERRORSUMMY, 'Goto My Network', 'Did not reach My Network page'"
      		return
    	end

    	# Look for the confirmation page's text   
   	if not @ff.text.include? 'Network Connections'
	      	$stderr.print "ERRORSUMMY, 'Goto Advanced', 'Did not reach are you sure page'"
        	return
    	end

     	# Sure?
     	begin
         	@ff.link(:text, 'Network Connections').click
     	rescue
         	$stderr.print "ERRORSUMMY: The key 'Network Connections' NOT found"
         	return
     	end
     
     	begin
		@ff.link(:href,'javascript:mimic_button(\'edit: eth1..\', 1)').click

     	rescue
         	$stderr.print "ERRORSUMMY: Can NOT get into edit 'broadband connection(Ethernet)' page"
         	return
     	end
	
        # Read the status of interface;
	sTable = false
	@ff.tables.each do |t|
	    if (t.text.include? 'Name') and (t.text.include? 'Status') and (not t.text.include?'NOTE') and
		(not t.text.include? 'Apply') then
		puts "########### table 001 ###############"
		puts t.to_s
		puts "########### table 002 ###############"
		sTable = t
	    end
	end
	if sTable == false
	    puts "Can't find table"
	else
	    status = sTable[3][2]
	    puts status.to_s
	    if status.to_s == "Connected"

		puts "The status is Enable"
		# Disable the interface of Ethernet;
		begin 
		    @ff.link(:text, "Disable").click
		rescue
		    $stderr.print "ERRORSUMMY: Can NOT Disable the status"
		    return
		end
		begin 
		    @ff.link(:text, "Apply").click
		rescue
		    $stderr.print "ERRORSUMMY: Can NOT Apply the disable status"
		    return
		end

		# Waiting for update
		sleep 10
		begin
			if @ff.link(:href,'javascript:mimic_button(\'edit: eth1..\', 1)').exist? 
				@ff.link(:href,'javascript:mimic_button(\'edit: eth1..\', 1)').click	
				@ff.link(:text,"Enable").click
		# Enable the interface of PPPoE
		#begin 
		    	else 
				@ff.link(:text, "Enable").click
			end
		rescue
		    @stderr.print "ERRORSUMMY: Can NOT Enable the status"
		end
		begin
		    @ff.link(:text,"Apply").click
		rescue
		    @stderr.print "ERRORSUMMY: Can NOT Apply the enable status"
		end
		sleep 10
	    else
		puts "The status is disable"
		# Disable the interface of Ethernet;
		begin 
		    @ff.link(:text, "Enable").click
		rescue
		    $stderr.print "ERRORSUMMY: Can NOT Disable the status"
		    return
		end
		begin 
		    @ff.link(:text, "Apply").click
		rescue
		    $stderr.print "ERRORSUMMY: Can NOT Apply the disable status"
		    return
		end

		# Waiting for update
		sleep 10
	
		@ff.link(:href,'javascript:mimic_button(\'edit: eth1..\', 1)').click
	
		# Enable the interface of PPPoE
		begin 
		    @ff.link(:text, "Disable").click
		rescue
		    @stderr.print "ERRORSUMMY: Can NOT Enable the status"
		end
		begin
		    @ff.link(:text,"Apply").click
		rescue
		    @stderr.print "ERRORSUMMY: Can NOT Apply the enable status"
		end
		sleep 10


	    end
	end

  end

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
 	when '-d'
		puts "host = #{arg}" 
		$ipAddr=arg      
	when '-h'
	        puts "Usage:reEnableWANEth.rb -h <help=#{$help}> "
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
  dut.reenableInterface
  
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'

end
