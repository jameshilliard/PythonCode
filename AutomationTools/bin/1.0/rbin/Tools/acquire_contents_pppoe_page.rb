################################################################
#     acquire_contents_pppoe_page.rb
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
    @port = '80'
    @compare_str = nil
    @media = 'ether'
    @key = 'routingmode'

    opts = GetoptLong.new(
       ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-m',  GetoptLong::REQUIRED_ARGUMENT],
       ['-k',  GetoptLong::REQUIRED_ARGUMENT],
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
       when '-k'
         @key = arg
         puts " check item = #{@key}"
       end
      end

  end
   
  def get_text
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
    	  @ff.link(:href, 'javascript:mimic_button(\'edit: ppp0..\', 1)').click
    	rescue
    	  puts 'Error : Did not reach wan PPPoE page'
    	  return
    	end

	begin
	  @ff.link(:text, 'Settings').click
	rescue
	  puts 'Error : Did not WAN PPPoE Properties page'
	  return
	end

	case @key
	when 'routingmode'
	    ret = @ff.select_list(:id, 'route_level').selected_options().to_s
	    if ret == @compare_str
	        puts "PASS: The selected option is #{ret}"
	    else
	        puts "FAIL: The selected option is #{ret}"
	    end
	when 'psdnsserver'
	    pridns = nil
	    for i in 0..3
		pridns_temp = @ff.text_field(:name, "primary_dns#{i}").value()
		if i == 3
		    pridns = "#{pridns}"+"#{pridns_temp}"
		else
		    pridns = "#{pridns}"+"#{pridns_temp}"+'.'
		end
	    end

	    secdns = nil
	    for i in 0..3
		secdns_temp = @ff.text_field(:name, "secondary_dns#{i}").value()
		if i == 3
		    secdns = "#{secdns}"+"#{secdns_temp}"
		else
		    secdns = "#{secdns}"+"#{secdns_temp}"+'.'
		end
	    end

	    ret_dnsip = "#{pridns}"+","+"#{secdns}"
	    if ret_dnsip == @compare_str
		puts "PASS: The dns server ip is #{ret_dnsip}"
	    else
		puts "FAIL: The dns server ip is #{ret_dnsip}"
	    end
	else 
	    puts "Error: What are you going to check in GUI"
	    self.lougout
	    self.close
	    exit 1
	end
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
    	  @ff.link(:href, 'javascript:mimic_button(\'edit: ppp1..\', 1)').click
    	rescue
    	  puts 'Error : Did not reach wan PPPoE page'
    	  return
    	end

	begin
	  @ff.link(:text, 'Settings').click
	rescue
	  puts 'Error : Did not WAN PPPoE Properties page'
	  return
	end

	case @key
	when 'routingmode'
	    ret = @ff.select_list(:id, 'route_level').selected_options().to_s
	    if ret == @compare_str
	        puts "PASS: The selected option is #{ret}"
	    else
	        puts "FAIL: The selected option is #{ret}"
	    end
	when 'psdnsserver'
	    pridns = nil
	    for i in 0..3
		pridns_temp = @ff.text_field(:name, "primary_dns#{i}").value()
		if i == 3
		    pridns = "#{pridns}"+"#{pridns_temp}"
		else
		    pridns = "#{pridns}"+"#{pridns_temp}"+'.'
		end
	    end

	    secdns = nil
	    for i in 0..3
		secdns_temp = @ff.text_field(:name, "secondary_dns#{i}").value()
		if i == 3
		    secdns = "#{secdns}"+"#{secdns_temp}"
		else
		    secdns = "#{secdns}"+"#{secdns_temp}"+'.'
		end
	    end

	    ret_dnsip = "#{pridns}"+","+"#{secdns}"
	    if ret_dnsip == @compare_str
		puts "PASS: The dns server ip is #{ret_dnsip}"
	    else
		puts "FAIL: The dns server ip is #{ret_dnsip}"
	    end
	else 
	    puts "Error: What are you going to check in GUI"
	    self.lougout
	    self.close
	    exit 1
	end

    end
  end
end

begin
  dut = AcquireText.new
  dut.login
  ret_index = dut.get_text
  dut.logout
  dut.close
end
