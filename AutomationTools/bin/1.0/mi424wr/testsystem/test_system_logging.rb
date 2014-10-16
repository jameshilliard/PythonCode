class Debug
	def self.out(message)
		if $debug == 3
			puts "(III) #{message}"
		end
        if $debug == 2 && message.length < 41
            puts "(II) #{message}"
        end
	end

    def err(message)
        puts "(!!!) #{message}"
        exit
    end
end

module Log

    # remember where to store any logs.  allow timestamps
    # and create the directory if necessary
	def logs(filename)
		# Strip the filename from the actual directory


		# the directory string we are passed may have timestamp info in it.
		t = Time.now
		filename = t.strftime(filename)

		# does it already exists?  otherwise create the directory tree
		if File.exist?(filename)
			directory = filename.slice!(/.*\//)
			# make sure it is a directory
			s = File.stat(directory)
			unless s.directory?
				puts "Error: logs set to #{directory} which is not a directory"
				exit
			end
		else
			begin
				directory = filename.slice!(/.*\//)
				FileUtils.mkdir_p(directory)
			rescue
				puts 'Error: could not create logs directory ' + directory.to_s
				exit
			end
		end
	end

    def msg(rule, level, section, msg)
		level_s = level
		level_s = '(II) Info' if level == :info
		level_s = '(WW) Warning' if level == :warning
		level_s = '(!!) Error' if level == :error
        if $debug > 1
            puts "#{level_s}::#{section} - #{msg}"
		end

        unless @out.has_key?(rule)
            Debug.out("Adding #{rule} section to log.")
            @out[rule] = {level_s => {section => msg}}
        else
            unless @out[rule].has_key?(level_s)
                @out[rule][level_s] = {section => msg}
            else
                @out[rule][level_s][section] = msg
            end
        end
    end

    def output
        return @out
    end

	def errorout
		line = ""
		for rule in @out.sort
			line << "\"#{rule[0]}\" {\n"
			rule[1].each do |level|
				line << "    #{level[0]}::"
				level[1].each do |section|
					line << "\n         #{section[0]} - #{section[1]}"
				end
			end
			line << "\n}\n\n"
			puts line
			line = ""
		end
	end

	def saveoutput(filename=nil)
		if filename == nil || filename == FALSE
			oname = @logs
		else
			oname = filename
		end
 		line = []
        Debug.out("Formatting output for log ...")
        for rule in @out.sort
            if rule[0].match(/iperf/im)
                line << "#{rule[0]}\n"
                rule[1].each do |level|
                    level[1].each do |section|
                        line << "#{section[1]}"
                    end
                end
            else
                line << "Test case: #{rule[0]}"
                rule[1].each do |level|
                    level[1].each do |section|
                        if section[1].match(/\Ap/i)
                            section[1].sub!(/\AP/,'')
                            line << "\n-- Result: Passed\n"+section[1]
                        else
                            section[1].sub!(/\AF/,'')
                            line << "\n-- Result: Failed\n"+section[1]
                        end
                    end
                end
            end
            line << "\n\n"
        end

        Debug.out("Saving log file - #{oname}.")
        rt_count = 0
        begin
            f = File.new(oname, 'w+')
            line.each do |l|
                f.write(l)
            end
            f.close
		rescue
            if rt_count < 6
                Debug.out("Issues saving log file. Trying again (try no. #{rt_count}) ...")
                rt_count += 1
                retry
            else
                unless rt_count == 7
                    Debug.out("We seem to be unable to save the log file. #{$!}")

                    oname.sub!(/\..*\z/, '') if oname.include?('.')
                    oname.concat("-retry.log")

                    Debug.out("Retrying one more time with a different file name - #{oname}")
                    rt_count += 1
                    retry
                else
                    Debug.out("Giving up. Can't save the log file.")
                    exit
                end
            end
		end
	end
end
