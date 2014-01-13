#######################################################
#
#   verifyWLANConfigurationMaxBitRate.rb
#   Author: Aleon
#   Date:   2010.8.9
#   Discription:    verify whether the status of wlan interface is correctly by SPV.
#   		   	 with GUI.
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
	['-b', GetoptLong::REQUIRED_ARGUMENT],
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
#@ff.link(:name,'actiontec_topbar_wireless').click
	    puts "log into 'Wireless Settings'"
	rescue      
	    $stderr.puts "ERROR, 'Can not reach 'Wireless Settings' page'."
	    return
	end
	
	begin
	    @ff.link(:text,'Advanced Security Settings').click
	    puts "log into 'Advanced Security Settings'"
	rescue
	    $stderr.puts "ERROR,'Can not reach 'Advanced Security Settings'."
	    return
	end
	begin
	    @ff.link(:text,'Other Advanced Wireless Options').click
	    puts "log into 'Other Advanced Wireless Options'"
	rescue
	    $stderr.puts "ERROR,'Can not reach 'Other Advanced Wireless Options'."
	    return
	end

	begin
	    @ff.link(:text,'Yes').click
	rescue
	    $stderr.puts "ERROR,'Can not process."
	    return
	end
	
	if ($board == "F") then
	    sTable=@ff.table(:xpath,'/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table').locate()
	
	    sTable.each do |row| 
	        if (row.text.include? 'Transmission Rate') then
	            puts "\n---------\n"
	            print row[1];print row[2]; puts "\n---------\n"
	            realRate=row[2]
	            puts "#=> The wlan status in GUI is: #{row[2]} --------#"
	            puts "#=> Expect wlan status is :#{$expect} -----------#"
		
		    if "#{row[2]}".strip == "#{$expect}".strip then
		        puts "------------------------------------------------------\n"
		        puts "PASS: Getting the transmission rate of WLAN interface do match with GUI."
		        puts "------------------------------------------------------\n"
		        return true
		    else
		        puts "------------------------------------------------------\n"
		        puts "FAIL: Getting the transmission rate of WLAN interface do not match with GUI.\n"
		        puts "------------------------------------------------------\n"
		        return false
		    end
	        end # End of if
	    end # End of table
	else
	    realRate=@ff.select_list(:xpath,'/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[4]/td[2]/select/option').selected_options()
	    puts "Mac address in GUI is #{realRate}"
	    puts "Expect MAC address is #{$expect}"
	    if "#{realRate}".strip == "#{$expect}".strip then
		        puts "------------------------------------------------------\n"
		        puts "PASS: Getting the transmission rate of WLAN interface do match with GUI."
		        puts "------------------------------------------------------\n"
			return true
            else
		        puts "------------------------------------------------------\n"
		        puts "PASS: Getting the transmission rate of WLAN interface do not match with GUI."
		        puts "------------------------------------------------------\n"
                return false
            end
	
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
	    when '-b'
		puts "board = #{arg}"
		$board = arg
		puts "The board is #{$board}"
	    when '-e'
		puts "expect = #{arg}"
		$expect = arg
		puts "The expect value is #{$expect}"
	    when '-h'
		puts "Usage: verifyWLANConfigurationMaxBitRate.rb -d <=ipAddress> -u <=username> -p <=password> -b <=board> -e <=expectValue}> -h "
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
