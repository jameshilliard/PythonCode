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

    opts = GetoptLong.new(
       ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
       ['-d',  GetoptLong::OPTIONAL_ARGUMENT],
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
       when '-s'
         @compare_str = arg
         puts " contain_text = #{@compare_str}"
       end
      end

  end
  
   
  def is_contain_text
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

    sTable = false
    @ff.tables.each do |t|
	if ( t.text =~ /#{@compare_str}$/ )
	    sTable = true
	    break
	end
    end

    return sTable
  end
  
end


begin
  dut = AcquireText.new
  dut.login
  ret_index = dut.is_contain_text
  if ret_index == true
    puts "Success : There is #{@compare_str} string in page"
    dut.logout
    dut.close
    puts 'RUBY SCRIPT END'
    exit 0
  else 
    puts "Fail : There is no #{@compare_str} string in page"
    dut.logout
    dut.close
    puts 'RUBY SCRIPT END'
    exit 1
  end

end
