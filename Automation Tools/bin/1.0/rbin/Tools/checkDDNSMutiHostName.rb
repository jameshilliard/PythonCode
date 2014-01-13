################################################################
#     checkDynamicDNSStatus.rb
#     Author:         Aleon
#     Date:           since 2009.06.26
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
	File.open("#{$jsonfile}",'r') do |f1|

	    while line = f1.gets
	   
		if (line =~ /"Loop Number":"*"/) != nil then

		    value = line.split"\""
		    get_num = value[3].to_i
		    puts "Get the number is : #{get_num}"
		end
        
		if (line =~ /"Host Name":"*"/) != nil then

		    value = line.split"\""
		    get_hostname = value[3].to_s
		    puts "Get the hostname is : #{get_hostname}"
		end
	    end

	for i in 1..get_num

		$expectvalue = get_hostname + i.to_s
		puts $expectvalue		
	

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
        	 	@ff.link(:text,'Dynamic DNS').click
     		rescue
         		$stderr.print "ERRORSUMMY: get into DDNS"
         		return
     		end
		
		# delete it if get the hostname which find,and return success;
     		if @ff.text.match "#{$expectvalue}" then
      			puts "#{$expectvalue}"
			get_href = @ff.link(:text,"#{$expectvalue}").href
			get_href.gsub!('edit','remove')
			@ff.link(:href,get_href).click

		 	puts "The #{$expectvalue} can be added to success"
       	
     		else 
      			puts "ERRORSUMMY: Can't add the #{$expectvalue}"
     	
		end #end of if

    	end # end of for
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
	        puts "Usage:checkDynamicDNSStatus.rb -f <$jsonfile=#{$jsonfile}> -p <password=#{$password}> "
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

