################################################################
#     checkDynamicDNSStatus.rb
#     Author:         Aleon
#     Date:           since 2009.06.22
#     Contact:        hpeng@actiontec.com
#     Discription:    Check the status of Dynamic DNS after configure
#     Input:          it depends
#     Output:         the  result of operation
#     Revised by Hugo 06-23-2009
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
$status="Updated"
$doname="none"
# handle any command line arguments 
opts = GetoptLong.new(
                      ['-a',  GetoptLong::REQUIRED_ARGUMENT],
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
    @ff = FireWatir::Firefox.new(:waitTime=>10)
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

  def status
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

	if @ff.text.include? "#{$doname}" then
     		#puts "get: #{$doname}"
       		
		# To click update
       		begin
          		str_href = @ff.link(:text,"#{$doname}").href
 	  
	  		# puts str_href
          		str_href.gsub!('edit','update')
          		# puts str_href
	  		@ff.link(:href,str_href).click

       		rescue
           		puts "ERRORSUMMY: Failed to click update link"
           		return
       		end 
     
       		# Waiting for update
       		sleep 30

       		# To Click Refresh to see if the status has been changed
       		begin
          		@ff.link(:text, "Refresh").click
       		rescue
          		puts "ERRORSUMMY: Failed to click Refresh button"
          		return
       		end
	
		# Read the status of hostname;
		sTable = false
		@ff.tables.each do |t|
		if ( t.text.include? 'Host Name') and ( not t.text.include? 'Domain Name Server' ) and
			( t.row_count > 1 ) then
			sTable = t
			break
		    end
        	end	
		
		if sTable == false
			# Wrong here
			puts "Did NOT find the target table."
		else
		     sTable.each do |row|
			    if ((not row.text.include? 'Host Name') and (not row.text.include? 'New Dynamic DNS Entry')) then
		         	
				if "#{row[1].to_s.gsub(':','')}" == "#{$doname}" then
			    
		    	            puts "\nGet status of '#{row[1].to_s.gsub(':','')}' is :#{row[2].to_s} \n"
				    
				    if "#{row[2].to_s}" == "Updated" then
					puts "#-------------------------------------#"
				    	puts "# PASSED: The status is '#{row[2].to_s}'"
					puts "#-------------------------------------#"
				    else 
					puts "#-------------------------------------#"
			    	 	puts "# FAILED: The status is '#{row[2].to_s}'"
					puts "#-------------------------------------#"
				        #  exit 1
				    end
				end # End of if
			  
			    end 
	
	    	    end # End of table

		end # End of if sTable

     	else 
       		puts "FAILED: Can't find the #{$doname}"
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
        
    	when '-a'
          puts "user = #{arg} "
      	  $doname = arg
          puts "The Parameter is #{$doname}"
	when '-h'
	        puts "Usage:checkDynamicDNSStatus.rb -a <$doname=#{$doname}> -h <help=#{$help}> "
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
  dut.status
  
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'

end
