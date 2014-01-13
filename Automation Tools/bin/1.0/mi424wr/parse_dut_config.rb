#!/usr/bin/env ruby
# Script to parse the config file into a path-based form

output = []
parents = []

input_config = open(ARGV[0]).readlines

input_config.each do |line|
    pop_count = 0
    line.strip!
    line.chomp!
    line.split("(").each do |l|
        parents.push l.strip unless l.strip.length == 0
        pop_count += 1 if l.strip == ")"
    end

    t_line = "/" + parents.join("/")
    pop_count += t_line.count(")")
    t_line.gsub!(")", "")
    output << t_line + "\n" unless t_line.match(/\/\z/)
    pop_count.times { parents.pop }
end

puts output