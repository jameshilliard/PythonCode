require 'English'
require 'rubygems'
require 'firewatir'
require 'logger'

class Essentialdut
    def waitUntil
      until yield
          sleep 1
      end
    end

    def linktoRouterGUI
      # link to Device GUI
      puts 'link to Device GUI...'
      url = 'http://' + @address + ':' + @port + '/'
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
      @ff.text_field(:name, 'user_name').value=(@username)
      @ff.text_field(:name, 'passwd1').set(@password)
      @ff.link(:text, 'OK').click
      if @ff.contains_text('Login failed')
        $stderr.print "Login failed\n"
        exit
      end
      puts 'Login OK'
    end
    
    def logout
      puts 'Logout ...'
      @ff.link(:name, 'logout').click
      if ! @ff.contains_text('User has logged out')
        $stderr.print "Logout failed\n"
      end
    end

    def init_msgout(locationfile)
      @screenlogger = Logger.new(STDOUT)
      @screenlogger.datetime_format = "%Y-%m-%d %H:%M:%S"
      begin
         @file = File.open(locationfile, File::WRONLY | File::APPEND | File::CREAT)
      rescue
         @screenlogger.error("failed to open log file - #{locationfile}")
      end
      @filelogger = Logger.new(@file)
      @filelogger.datetime_format = "%Y-%m-%d %H:%M:%S"

    end

    def msgout(information, outhandler)
      if outhandler == 'file'
	@filelogger.info(information)
      elsif outhandler == 'screen'
	@screenlogger.info(information)
      else
	@screenlogger.info(information)
      	@filelogger.info(information)
      end
    end

    def destory
      @file.close
    end

end
