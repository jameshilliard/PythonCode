#! /usr/bin/ruby 
$NOTDEFINED='notdefined'
$username = 'admin'
$password = 'abc123'
$address = '192.168.1.1'
#$firmware = '/home/autolab2/mi424wr/20.8.7.rmt'
$firmware = $NOTDEFINED
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
     ['-h',  GetoptLong::NO_ARGUMENT]
)

def waitUntil
    until yield
        sleep 0.5
    end
end

class Br02

    def initialize
#      @ff = FireWatir::Firefox.new
   #     waitUntil { @ff.span(:text, 'Login').exists? }
    end
    def start
      @ff = FireWatir::Firefox.new(:waitTime => 10)
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

    def login
      linkdut
        puts 'Attempting to login user='+$username+' with pwd='+$password
      #check if this screen reset to default 
      if @ff.contains_text('Login Setup')
        puts 'Login Setup\n' 
        # Set up Page 
        @ff.text_field(:index, 1).value=($username )
        @ff.text_field(:index, 2).set($password )
        @ff.text_field(:index, 3).set($password )
        @ff.link(:text, 'OK').click
        if @ff.contains_text('Login failed')
          $stderr.print "First Login failed\n"
          self.close
          exit
        end
       else 
        puts 'Normal  Login\n' 
        @ff.text_field(:name, 'user_name').set($username)
        @ff.text_field(:name, 'passwd1').set($password)
        @ff.link(:text, 'OK').click
        if @ff.contains_text('Login failed')
          $stderr.print "Login failed\n"
          exit
        end
      end
    end

    def logout
        puts 'Logging out ...'
       if @ff.contains_text('Logout')
        print "Logout Process\n" 
        @ff.link(:name, 'logout').click
       end
#        if ! @ff.contains_text('User has logged out')
#            $stderr.print "Logout failed\n"
#        end
    end

    def firmware_upgrade
        puts 'Uploading firmware ...'
        @ff.link(:href, /actiontec%5Ftopbar%5Fadv%5Fsetup/).click
        @ff.span(:text, 'Yes').click
        @ff.link(:text, 'Firmware Upgrade').click
        @ff.link(:text, 'Upgrade Now').click
        @ff.file_field(:type, 'file').set($firmware)
        @ff.span(:text, 'OK').click
        if @ff.contains_text('Input Errors')
            $stderr.print "Error upgrading firmware, upgrade failed\n"
        else
         puts 'Attempting to upgrade firmware ...'
         waitUntil { @ff.span(:text, 'Apply').exists? }
         @ff.span(:text, 'Apply').click
         puts 'Updating firmware ...'
 #       sleep 30
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
     puts 'Usage:login.rb  -d <dut '+$address+'>  -u <user='+$username+'> -p <password='+$password+">"
    exit 1

    when '-d'
    $address = arg
     puts " address = "+ $address
    end
  end

  rescue => ex
  	 puts "Error: #{ex.class}: #{ex.message}"
  end
begin
  puts 'Login  -d <dut '+$address+'>  -u <user='+$username+'> -p <password='+$password+">"
  cmd='killall firefox;rm -f ~/.mozilla/firefox/*/compreg.dat'
  dut = Br02.new

  result = fork{exec(cmd)}
  Process.wait
  sleep 10
  dut.start
  dut.linkdut
  puts " logout"
  dut.logout
  puts "LOGIN"
  dut.login
  puts " logout"
    dut.logout
    dut.close
end

