class Timer
#	attr_reader :time
	def initialize
		@time = @startTime = Time.now
	end
	def time
		@time.strftime("%H:%M:%S ") + (@time.usec/10000).to_s + "ms"
	end
	def startTime
		@startTime.strftime("%H:%M:%S ") + (@startTime.usec/10000).to_s + "ms"
	end
	def now
		Time.now.strftime("%H:%M:%S ") + (@startTime.usec/10000).to_s + "ms"
	end	
	# If for some reason you want to restart the timer, you can call this
	# function
	def start
		@startTime = Time.now
	end
	def elapsedTime
		return (Time.now - @startTime).to_s
	end
end