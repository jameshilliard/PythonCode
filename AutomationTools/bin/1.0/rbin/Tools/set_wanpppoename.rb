################################################################
#     set_wanpppoename.rb
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

    opts = GetoptLong.new(
       ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-m',  GetoptLong::REQUIRED_ARGUMENT],
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
       end
      end

  end
   
  def set_text
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

    	@ff.text_field(:name, 'description').value=@compare_str
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

    	@ff.text_field(:name, 'description').value=@compare_str
    end
    @ff.link(:text, 'Apply').click
  end
end


begin
  dut = AcquireText.new
  dut.login
  ret_index = dut.set_text
  dut.logout
  dut.close
end
