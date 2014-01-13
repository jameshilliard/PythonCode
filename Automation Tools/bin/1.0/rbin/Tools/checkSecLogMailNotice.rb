################################################################
#     checkSyslogSetting.rb
#     Author:         Aleon
#     Date:           since 2009.08.22
#     Contact:        hpeng@actiontec.com
#     Discription:    Check the record of configuration
#     Input:          it depends
#     Output:         the result of operation
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
$jsonfile="none"
$get_num='0'
$get_hostname="none"
$value="none"

# handle any command line arguments 
opts = GetoptLong.new(
		      ['-f',  GetoptLong::REQUIRED_ARGUMENT],
                      ['-h',  GetoptLong::NO_ARGUMENT]
)

def waitUntil
	until yield
 	sleep 0.5
	end
end

class CheckHostnameNumb
  
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

    def checkresult

	get_expect="none"
        File.open("#{$jsonfile}",'r') do |f1|

            while line = f1.gets

                if (line =~ /"Security Allowed Capacity Before Email Notification":"*"/) != nil then

                    value = line.split"\""
                    get_expect = value[3].to_s
                    puts "Get the setting of mail notice is : #{get_expect}"
                end
            end # end of loop;

	end # end of open 	  	
		# Get to the "Dynamic DNS" page.
   	 	begin
    			@ff.link(:href, /actiontec%5Ftopbar%5Fadv%5Fsetup../).click
   		rescue
      			$stderr.print "ERRORSUMMY, 'Goto Advanced', 'Did not reach Advanced page'"
      			return
    		end

    		# Look for the confirmation page's text   
   		if not @ff.text.include? 'Any changes made in this section'
	 	     	$stderr.print "ERRORSUMMY, 'Goto Advanced', 'Did not reach are you sure page'"
       	  	    	return
   		end

    		# Sure?
    		begin
       	 		@ff.link(:text, 'Yes').click
     		rescue
        		 $stderr.print "ERRORSUMMY: Dynamic DNS Some key NOT found"
        		 return
    		end
     
     		begin
        	 	@ff.link(:text,'System Settings').click
     		rescue
         		$stderr.print "ERRORSUMMY: Can NOT get into 'System Setting'"
         		return
     		end
		
		# Check the real value and compare with get_expect;
      		value = @ff.text_field(:name,'fw_notify_limit').value()
		puts "Get the real value is : #{value}"
		
		if value == get_expect then
			
			puts "PASSED: The setting is right."
		else 
			puts "ERRORSUMMY: The setting is not right;"
		end


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
        
	when '-f'
	  puts "jsonfile = #{arg} "
	  $jsonfile = arg
	  puts "The jsonfile is #{$jsonfile}"
	when '-h'
	        puts "Usage:checkDynamicDNSStatus.rb -f <$jsonfile=#{$jsonfile}> -h <help=#{$help}> "
    	    exit 1
    end # End of case;
   end
end


begin
  puts 'RUBY SCRIPT START ...'
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait

  dut = CheckHostnameNumb.new
  dut.login
  dut.checkresult
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'

end
