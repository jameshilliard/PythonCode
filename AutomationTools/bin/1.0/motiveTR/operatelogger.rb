#--------------------------------------------------------------------------------------
#	File: mainmotive.rb
#	Name: shqa
#	Contact: shqa@actiontec.com
#
#
#	Copyright @ Actiontec Ltd.
#--------------------------------------------------------------------------------------
require 'logger'

class MessageOut
  def initialize(locationfile)
    @haslogfile = true
    if locationfile == nil
        @haslogfile = false
    end
    @screenlogger = Logger.new(STDOUT)
    @screenlogger.datetime_format = "%Y-%m-%d %H:%M:%S"
    if @haslogfile == true
        begin
           @file = File.open(locationfile, File::WRONLY | File::APPEND | File::CREAT)
        rescue 
           @screenlogger.error("failed to open log file - #{locationfile}")
        end
        @filelogger = Logger.new(@file)
        @filelogger.datetime_format = "%Y-%m-%d %H:%M:%S"
    end
  end 

  def msg(level, information)
    case level 
      when :info
         self.msgInfo(information)
      when :error
         self.msgError(information)
      when :warn
         self.msgWarn(information)
    end
  end

  def msgInfo(getinfo)
    @screenlogger.info(getinfo)
    if @haslogfile == true
        @filelogger.info(getinfo)
    end
  end

  def msgError(geterror)
    @screenlogger.error(geterror)
    if @haslogfile == true
        @filelogger.error(geterror)
    end
  end

  def msgWarn(getwarn)
    @screenlogger.warn(getwarn)
    if @haslogfile == true
        @filelogger.warn(getwarn)
    end
  end

  def destory
    if @haslogfile == true
        @file.close
    end
  end
end
