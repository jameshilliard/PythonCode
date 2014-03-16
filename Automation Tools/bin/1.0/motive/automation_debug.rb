=begin
Filename: automation_debug.rb
Description: Main entry of the test suite for TR-069 testing
Author: Kurt Liu
Date: 03/20/09
=end


require 'timer'

class AutomationDebug
	attr_accessor :debugLevel

	#def initialize(debugLevel='debug')
	def initialize(logFilepath, debugLevel='debug')
		@timer = Timer.new
		case debugLevel
			when "debug"
				@debugLevelNum = 1
			when "info"
				@debugLevelNum = 2
			when "warning"
				@debugLevelNum = 3
			when "error"
				@debugLevelNum = 4
			when "fatal"
				@debugLevelNum = 5
		end

		# if the log directory does not exist, raise an exception
		begin
			#if ! File.directory?("log")
			#	Dir.mkdir("log")
			#end

      # Added by Wayne, 2009-5-6
      # For log file path specifying
      make_dir(logFilepath)
		rescue
			puts "Cannot create log directory!"
			raise "Cannot create log directory!"
		end
		
		# Write to file log\2009-03-26_17-51-12.log
		# The path separator "/" seems to work on Windows as well as Linux
		begin
			#@file = File.new("log/" + Time.now.strftime("%Y-%m-%d_%H-%M-%S") + ".log", "w")
			@file = File.new(logFilepath, "w")
		rescue
			puts "Cannot create log file!"
			raise "Cannot create log file!"
		end
	end

	def log(debugLevel='debug', debugMessage='')
		case debugLevel
			when "debug"
				d = 1
			when "info"
				d = 2
			when "warning"
				d = 3
			when "error"
				d = 4
			when "fatal"
				d = 5
			else
				puts "Debug level is not recognized! Default to debug."
				d = 1
		end
		if d >= @debugLevelNum
			print @timer.now, " "
			@file.write @timer.now + " "
			case d
				when 1
					print "DEBUG: "
					@file.write "DEBUG: "
				when 2
					print "INFO: "
					@file.write "INFO: "
				when 3
					print "WARNING: "
					@file.write "WARNING: "
				when 4
					print "ERROR: "
					@file.write "ERROR: "
				when 5
					print "FATAL: "
					@file.write "FATAL: "
			end
			# Output to console
			print debugMessage, "\n"

			@file.write debugMessage
			@file.write "\n"
		end
	end
	
	def finalize
		@file.close
	end

  def make_dir(filepath)
    fileName = File.basename(filepath)
    dirName = File.dirname(File.expand_path(filepath))
    dirList = dirName.split('/')
    fullDir = ""
    dirList.each  do |dir|
      if dir.length == 0
        next
      end
      fullDir += "/" + dir
      if ! File.directory?(fullDir)
        Dir.mkdir(fullDir)
      end
    end
  end
end