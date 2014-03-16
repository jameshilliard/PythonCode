################################################################
#     displayWANIP_DNS.rb
#     Author:         Hugo
#     Date:           since 2010.11.4
#     Discription:    
#     Input:          it depends
#     Output:         the  result of operation
################################################################

require 'getoptlong'
$dir=File.dirname(__FILE__) + "/"
require $dir + 'Essentialdut'

class AcquireText < Essentialdut
  
  def initialize
    @username = 'admin'
    @password = 'admin1'
    @address = '192.168.1.1'
    @media = 'ether'
    @port = '80'
    @compare_str = nil
    @is_negative = false

    opts = GetoptLong.new(
       ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-m',  GetoptLong::REQUIRED_ARGUMENT],
       ['-n',  GetoptLong::NO_ARGUMENT],
       ['-s',  GetoptLong::REQUIRED_ARGUMENT]
    )

    puts 'RUBY SCRIPT START ...'
    cmd='killall firefox; killall firefox-bin; rm -f ~/.mozilla/firefox/*/compreg.dat'
    result = fork{exec(cmd)}
    Process.wait
    puts "KILL FIREFOX= #{cmd} "
    sleep 2
    
    opts.each do |opt, arg|
      case opt
       when '-d'
         @address = arg
         puts " address = #{@address}"
       when '-u'
         @username = arg
         puts " username = #{@username}"
       when '-p'
         @password = arg
         puts " password = #{@password}"
       when '-m'
         @media = arg
         puts " media = #{@password}"
       when '-s'
         @compare_str = arg
         puts " contain_text = #{@compare_str}"
       when '-n'
	 @is_negative = true
	 puts "negative testing"
       end
      end

  end
   
  def display_DNS_status
    case @media
    when 'ether'
	begin
    	  @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
    	rescue
    	  puts 'Error : My Network did not reach page'
    	  return
    	end

    	begin
    	  @ff.link(:text, 'Network Connections').click
    	rescue
    	  puts 'Error : Did not reach Network Connections page'
    	  return
    	end

    	begin
    	  @ff.link(:href, 'javascript:mimic_button(\'edit: eth1..\', 1)').click
    	rescue
    	  puts 'Error : Did not reach wan PPPoE page'
    	  return
    	end

	begin
    	  @ff.link(:text, 'Settings').click
    	  puts "Go into Settings"
    	rescue
    	  puts "Error: Did not reach Coax Properties page"
    	  return
    	end

	ret = @ff.select_list(:id, 'dns_option').selected_options().to_s
	if ret == @compare_str and @is_negative == false
	    puts "PASS: The selected option is #{ret}"
	elsif ret == @compare_str and @is_negative == true
	    puts "FAIL: The selected option is #{ret}, it is a negative test"
	elsif ret != @compare_str and @is_negative == true
	    puts "PASS: The selected option is #{ret}, it is a negative test"
	elsif ret != @compare_str and @is_negative == false
	    puts "FAIL: The selected option is #{ret}"
	end
	self.logout
	self.close
    when 'moca'
	begin
    	  @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
    	rescue
    	  puts 'Error : My Network did not reach page'
    	  return
    	end

    	begin
    	  @ff.link(:text, 'Network Connections').click
    	rescue
    	  puts 'Error : Did not reach Network Connections page'
    	  return
    	end

    	begin
    	  @ff.link(:href, 'javascript:mimic_button(\'edit: clink1..\', 1)').click
    	rescue
    	  puts 'Error : Did not reach wan PPPoE page'
    	  return
    	end

	begin
    	  @ff.link(:text, 'Settings').click
    	  puts "Go into Settings"
    	rescue
    	  puts "Error: Did not reach Coax Properties page"
    	  return
    	end

	ret = @ff.select_list(:id, 'dns_option').selected_options().to_s
	if ret == @compare_str and @is_negative == false
	    puts "PASS: The selected option is #{ret}"
	elsif ret == @compare_str and @is_negative == true
	    puts "FAIL: The selected option is #{ret}, it is a negative test"
	elsif ret != @compare_str and @is_negative == true
	    puts "PASS: The selected option is #{ret}, it is a negative test"
	elsif ret != @compare_str and @is_negative == false
	    puts "FAIL: The selected option is #{ret}"
	end
	self.logout
	self.close
    else
	puts 'Please give ether or moca as option'
	self.logout
	self.close
	exit 1
    end
  end
end


begin
  dut = AcquireText.new
  dut.login
  dut.display_DNS_status
end
