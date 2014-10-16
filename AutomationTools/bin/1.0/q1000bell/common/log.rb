require 'log4r'

module Log
    attr_accessor :out
  	def logs(filename=FALSE, level=4, console=TRUE)
        # Create log object
        @log = Log4r::Logger.new("logging")

        # Console output
        if console
            Log4r::StdoutOutputter.new('console')
            Log4r::Outputter['console'].level = level
            Log4r::Outputter['console'].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] :: %m")
            @log.add('console')
            @log.info('Console output started.')
        end

        # File output
        if filename
            Log4r::FileOutputter.new('logfile', :filename => filename, :trunc => false)
            Log4r::Outputter['logfile'].level = level
            Log4r::Outputter['logfile'].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m", :date_pattern => "%m/%d/%Y %H:%M %Z")
            @log.add('logfile')
            @log.info('Log file output started.')
        end
	end
end
