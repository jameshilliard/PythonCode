#######################################################
#
#   displayStatusOfClient.rb
#   Author: Aleon
#   Date:   2010.12.14
#   Discription:    Out put the status of client connection on 
#   		   	  GUI.
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
	    @ff.link(:text,'Main').click
	    puts "log into 'Main' page."
	rescue
	    $stderr.puts "ERROR, 'Can not reach 'Main' page'."
	    return
	end
	

	
        sTable = false
        @ff.tables.each do |t|
                        if ( t.text.include? '192.168.1.200' and
                                t.row_count >= 1 )then
                                        sTable = t
                                break
                        end
        end
        if sTable == false
        # Wrong here
              print 'Did NOT find the target table.'
              return
        end

        sTable.each do |row|

	    print "--------\n#{row}---------\n"

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
