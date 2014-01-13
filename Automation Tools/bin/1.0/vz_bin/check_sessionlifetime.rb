#! /usr/bin/ruby 
$NOTDEFINED='notdefined'
$username = 'admin'
$password = 'admin1'
$address = '192.168.1.1'
$firmware = $NOTDEFINED
$sessiontime = 60
test="hello world "
require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'


# handle any command line arguments 
opts = GetoptLong.new( 
     ['-f',  GetoptLong::REQUIRED_ARGUMENT], 
     ['-u',  GetoptLong::REQUIRED_ARGUMENT],
     ['-p',  GetoptLong::REQUIRED_ARGUMENT],
     ['-d',  GetoptLong::REQUIRED_ARGUMENT],
     ['-h',  GetoptLong::NO_ARGUMENT],
     ['-t',  GetoptLong::REQUIRED_ARGUMENT]
)

def waitUntil
    until yield
        sleep 0.5
    end
end

class Br02

    def start
      @ff = FireWatir::Firefox.new      
    end

    def linkdut
      port = '80'
      url = 'http://' + $address + ':' + port + '/'
      sleep 1
      @ff.goto(url)
    end

    def close
        @ff.close
    end

    def trysession
       @ff.link(:text, 'Change Login User Name / Password').click 
       if @ff.contains_text('Connection has expired, please login again')
         puts "Succ:Session life time effects"
       else
         puts "ERRORSUMM:Session life time doesn't effects"
       end
       @ff.tables.each do |t| 
          puts t.text
       end
    end

    def login
      linkdut
        puts 'Attempting to login user='+$username+' with pwd='+$password
        @ff.text_field(:index, 1).value=($username )
        @ff.text_field(:index, 2).set($password )
        @ff.link(:text, 'OK').click
        if @ff.contains_text('Login failed')
          $stderr.print "First Login failed\n"
          self.close
          exit
        else
          puts 'Logging OK'
        end
    end

    def logout
       puts 'Logging out ...'
       if @ff.contains_text('Logout')
        print "Logout Process\n" 
        @ff.link(:name, 'logout').click
       end
    end
                            
end


begin
# parse the input
  opts.each do |opt, arg|
    case opt
    when '-u'
      puts " user = #{arg} "
      $user = arg
    when '-p'
      puts " password = #{arg} "
      $password = arg

    when '-h'
      $address = arg
      puts 'Usage:login.rb  -d <dut '+$address+'>  -u <user='+$username+'> -p <password='+$password+'> -t <session life time>'
      exit 1

    when '-d'
      $address = arg
      puts " address = "+ $address

    when '-t'
      $sessiontime = Integer(arg)
      puts "Wait $sessiontime secs for session life time"
    end
end
rescue => ex
  	 puts "Error: #{ex.class}: #{ex.message}"
end

begin
  puts 'Login  -d <dut '+$address+'>  -u <user='+$username+'> -p <password='+$password+'> -t <sessiontime= '+String($sessiontime)+'>'
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  result = fork{exec(cmd)}
  Process.wait
  sleep 10
  
  dut = Br02.new
  dut.start
  puts "LOGIN...." 
  dut.login
  puts 'Start to wait till session life time '+String($sessiontime)+'Secs expired.....'
  sleep ($sessiontime)
  puts "#{$sessiontime} passed....."
  puts "click a linker on Main page...."
  dut.trysession
  puts "LOGOUT...."
  dut.logout 
  dut.close
end

