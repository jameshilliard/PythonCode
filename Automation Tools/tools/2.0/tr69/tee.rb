require 'shell'
Shell.new.tee(ARGV[0]) < STDIN > STDOUT
