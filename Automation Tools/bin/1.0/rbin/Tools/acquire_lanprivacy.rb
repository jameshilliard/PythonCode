################################################################
#     acquire_contents_networkconnections.rb
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
    @value_pwd = nil

    opts = GetoptLong.new(
       ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-v',  GetoptLong::OPTIONAL_ARGUMENT],
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
       when '-v'
         @value_pwd = arg
         puts " coax password = #{@value_pwd}"
       when '-s'
         @compare_str = arg
         puts " contain_text = #{@compare_str}"
       end
    end

  end

  def privacy_status
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

    if @ff.contains_text('Advanced >>')
         @ff.link(:text, 'Advanced >>').click
    end
    
    begin
        @ff.link(:href, 'javascript:mimic_button(\'edit: clink0..\', 1)').click
    rescue
        puts "Error: Did not reach Coax page"
        return
    end

    begin
      @ff.link(:text, 'Settings').click
      rescue
      puts 'Error : Did not reach settings page'
      return
    end

    if @value_pwd == nil
	ret_value = @ff.text_field(:name, 'clink_password').value.to_s
    	
    	if ret_value == @compare_str
    	    puts "PASS Password value is #{ret_value} in GUI"
    	else 
    	    puts "FAIL Password value is #{ret_value} in GUI"
    	end
    else
	self.set_passwd
    end
  end
 
  def set_passwd
	@ff.text_field(:name, 'clink_password').value=@value_pwd
	puts "Set password #{@value_pwd}"
	@ff.link(:text, 'Apply').click
  end

end


begin
  dut = AcquireText.new
  dut.login
  dut.privacy_status
  dut.logout
  dut.close
  puts 'RUBY SCRIPT END'

end
