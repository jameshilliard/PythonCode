require 'log4r'

module Log
    attr_accessor :out
	def logs(filename=FALSE, level=4, console=TRUE)
	        # Create log object
        	@out = Log4r::Logger.new("logging")

	        # Console output
	        if console
        	    Log4r::StdoutOutputter.new('console')
	            Log4r::Outputter['console'].level = level
	            Log4r::Outputter['console'].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] :: %m")
        	    @out.add('console')
	            @out.info('Console output started.')
	        end
	
	        # File output
	        if filename
	            Log4r::FileOutputter.new('logfile', :filename => filename, :trunc => false)
	            Log4r::Outputter['logfile'].level = level
        	    Log4r::Outputter['logfile'].formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m", :date_pattern => "%m/%d/%Y %H:%M %Z")
	            @out.add('logfile')
	            @out.info('Log file output started.')
	        end
	end

    # Legacy method, so a bunch of lines don't need to be rewritten in some cases
    def msg(rule, level, section, msg)
        case level
        when :debug
            @out.debug("#{rule} - #{section}::#{msg}")
        when :info
            @out.info("#{rule} - #{section}::#{msg}")
        when :warn
            @out.warn("#{rule} - #{section}::#{msg}")
        when :error
            @out.error("#{rule} - #{section}::#{msg}")
        when :fatal
            @out.fatal("#{rule} - #{section}::#{msg}")
        end
    end

    # For unrecoverable errors
    def err(message)
        @out.fatal(message)
        exit
    end
end
