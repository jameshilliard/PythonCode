require 'pathname'
d = Pathname.new(File.dirname(__FILE__)).realpath

if ARGV[0]
    PORT = ARGV[0]
else 
    PORT = '5031'
end

Dir.chdir(d)
while 1 do
    system "ruby tr69server.rb -i 0.0.0.0:#{PORT} -r -u lchu -p 760nmary -x 5 | ruby tee.rb mylog "
    sleep 5
end
