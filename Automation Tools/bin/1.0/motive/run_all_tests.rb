numTestCases = 560

1.upto(numTestCases) do |x|
	command = "ruby launch_tests.rb -t config/config_"
	paddedNumString = sprintf("%05d", x)
	command = "#{command}#{paddedNumString}.xml"
	#puts command
	system(command)
end