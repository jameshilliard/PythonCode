require 'rubygems'
require 'daemons'

Daemons.run('tr69server.rb', :monitor => true, :backtrace => true, :log_output => true, :ARGV => ["start", "--", "-i", "-u", "-p", "-d"], :ontop=>true, :app_name => "tr69_server")
