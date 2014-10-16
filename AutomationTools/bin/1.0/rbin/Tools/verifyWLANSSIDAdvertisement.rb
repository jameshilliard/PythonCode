#######################################################
#
#   VerifyWLANSSIDAdvertisementEnabled.rb
#   Author: Aleon
#   Date:   2010.8.14
#   Discription:    verify whether the setting of wlan SSID advertisement is consistent with GUI.
#   		   	
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
            @ff.link(:href,'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fwireless..\', 1)').click
            puts "log into 'Wireless Settings'"
        rescue
            $stderr.puts "ERROR, 'Can not reach 'Wireless Settings' page'."
            return
        end

        begin
            @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9119..\', 1)').click
            puts "log into 'Wireless Status'"
        rescue
            $stderr.puts "ERROR,'Can not reach 'Wireless Status' page'."
            return
        end

        statusOfBroadcast=@ff.element_by_xpath('/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr[8]/td[2]')

        puts "#=> The SSID broadcast in GUI is: #{statusOfBroadcast} --------#"
        puts "#=> Expect SSID broadcast is :#{$expect} -----------#"
        if "#{statusOfBroadcast}".strip == "#{$expect}".strip then
                puts "------------------------------------------------------\n"
                puts "PASS: The configuration of SSID broadcast is consistent with GUI."
                puts "------------------------------------------------------\n"
                return true
        else
                puts "------------------------------------------------------\n"
                puts "FAIL: The configuration of SSID broadcast is not consistent with GUI.\n"
                puts "------------------------------------------------------\n"
                return false
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
		puts "Usage: verifyLANInterfaceDuplexMode.rb -d <=ipAddress> -u <=username> -p <=password> -e <=expectValue}> -h "
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
