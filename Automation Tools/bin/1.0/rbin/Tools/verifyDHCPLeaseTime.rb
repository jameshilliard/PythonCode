#######################################################
#
#   verifyDHCPLeaseTime.rb
#   Author: Aleon
#   Date:   2010.7.28
#   Discription:    verify if the dhcp lease time is set correctly by motive.
#   Input:  it depends
#   Output: the result of operation
#
#######################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'

$username='admin'
$password='admin1'
$address='192.168.1.1'
$port='80'

# handle any command line arguments
opts=GetoptLong.new(
	['-u', GetoptLong::REQUIRED_ARGUMENT],
	['-p', GetoptLong::REQUIRED_ARGUMENT],
	['-d', GetoptLong::REQUIRED_ARGUMENT],
	['-e', GetoptLong::REQUIRED_ARGUMENT],
	['-h', GetoptLong::NO_ARGUMENT]
    )

def waitUntil
    until yield
	sleep 1
    end
end

class Initialize_BHR2

    def initialize
    end
    
    def linkdut
	 # link to Device GUI
	puts 'link to Device GUI...'
	url = 'http://' + $address + ':' + $port + '/'
	@ff = FireWatir::Firefox.new(:waitTime=>2)
	sleep 1
	@ff.goto(url)
	waitUntil { @ff.span(:text, 'Login').exists? }

    end

    def login
	linkdut
	puts "Attempting to login ..."
	@ff.text_field(:name,'user_name').value=$username
	@ff.text_field(:name,'passwd1').set($password)
	@ff.link(:text,'OK').click
	if @ff.contains_text('Login failed')
	    $stderr.print "Login failed\n"
	    exit
	end
	puts "Logging ok"
    end

    def close
	@ff.close
    end

    def logout
	puts "Logging out ..."
	@ff.link(:name,'logout').click
	if !@ff.contains_text('User has logged out')
	    $stderr.print "Logout failed\n"
	end
    end

    def status
	# goto the 'network' page.
	begin
	    @ff.link(:text,'My Network').click
	    puts "log into 'My Network'"
	rescue
	    $stderr.puts "ERROR, 'Can not reach 'My Network' page'."
	    return
	end
	
	begin
	    @ff.link(:text,'Network Connections').click
	    puts "log into 'Network Connections'"
	rescue
	    $stderr.puts "ERROR,'Can not reach 'Network Connections' page'."
	    return
	end

	begin
	    @ff.link(:href, 'javascript:mimic_button(\'edit: br0..\', 1)').click
	rescue 
	    $stderr.puts "ERROR,'Can not reach 'Network (Home/Office)' page'."
	    return
	end
	
	begin
	    @ff.link(:text,'Settings').click
	rescue
	    $stderr.puts "ERROR,'Can not reach 'Setting' page'"
	    return
	end

	if !@ff.text_field(:xpath,'//*[@id="dhcp_mode"]').disabled()
	    
	    opt = @ff.text_field(:name,'lease_time').value()
	    puts "----------------\n"
	    puts opt
	    puts "----------------\n"

	    if opt == $expect then
		puts "------------------------------------------------------\n"
		puts "PASS: The configuration of DHCP Server is '#{$expect}'\n"
		puts "------------------------------------------------------\n"
	    else
		puts "------------------------------------------------------\n"
		puts "FAIL: The configuration of DHCP Server is #{$opt}"
		puts "------------------------------------------------------\n"
	    end

	else 
	    puts "ERROR: The status of DHCP is DISABLED"
	    
	end    
    end	

end # End of class

#----------------------------------------
# Main 
# ---------------------------------------
begin
    #parse the input
    opts.each do |opt,arg|
	case opt
	    when '-u'
		puts "username = #{arg}"
		$username = arg
		puts "The username is #{$username}"
	    when '-p'
		puts "password = #{arg}"
		$password = arg
		puts "The password is #{$password}"
	    when '-d'
		puts "address = #{arg}"
		$address = arg
		puts "The address is #{$address}"
	    when '-e'
		puts "expect = #{arg}"
		$expect = arg
		puts "The expect value is #{$expect}"
	    when '-h'
		puts "Usage: displayDHCPServerConfigure.rb -d <=ipAddress> -u <=username> -p <=password> -e <=expectValue}> -h "
		exit 1
	    end
	end
end

begin puts "Ruby START ...."
    cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
    result = fork{exec(cmd)}
    Process.wait

    dut = Initialize_BHR2.new
    dut.login
    dut.status
    dut.logout
    dut.close
    puts "RUBY END"

end
