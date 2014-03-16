#!/usr/bin/env ruby
# Injects a string from a file into another file

require 'optparse'
require 'ostruct'

options = OpenStruct.new

options.outputfile = nil
options.delimiter = nil
options.prefix = FALSE
options.suffix = FALSE
options.inputfile = nil
options.rfile = nil

optionlist = OptionParser.new do |opts|
    opts.separator ""
    opts.banner = "\nInjects a string from a file into another file replacing another string using a specified delimiter option. (An advanced SED for a very specific purpose.)\nWARNING: This is destructive. Use -o to copy to another file, or it will overwrite all data from the input file with the modified strings."
    opts.separator "\nUsage: inject.rb [options] STRING FILE"
    opts.separator "\nOptions: "
    opts.on("-d DELIMITER", "Set delimiter to the specified character or regular expression.") { |d| options.delimiter = Regexp.new(d) }
    opts.on("-o FILE", "File to save to if not the same as the input file.") { |f| options.outputfile = f }
    opts.on("--prefix", "Add before each delimiter instead of replacing.") { options.prefix = TRUE }
    opts.on("--suffix", "Add after each delimiter instead of replacing.") { options.suffix = TRUE }
    opts.on_tail("-h", "--help", "Displays this help menu.") { puts optionlist; exit }
end

# Get the options
optionlist.parse!(ARGV)

# Rest of command line args should be the filenames/strings
options.inputfile = ARGV[1]
options.rfile = ARGV[0]

if options.inputfile == nil
    puts "Missing input file name."
    exit
end
if options.rfile == nil
    puts "Missing file or string containing replacement text."
    exit
end

unless File.exists?(options.inputfile)
    puts "No such file: #{options.inputfile}"
    exit
else
    input_matrix = File.open(options.inputfile).readlines
end

# not a file, so set the replacement string to what was passed
unless File.exists?(options.rfile)
    options.rstring = options.rfile
else
    options.rstring = File.open(options.rfile).read
    options.rstring.chomp!
end

output_matrix = []
options.delimiter = "inject" if options.delimiter == nil

if options.prefix == FALSE && options.suffix == FALSE
    input_matrix.each do |line|
        output_matrix << line.gsub(/#{options.delimiter}/, options.rstring)
    end
elsif options.prefix == TRUE && options.suffix == FALSE
    input_matrix.each do |line|
        output_matrix << line.gsub(/#{options.delimiter}/, options.rstring + '\0')
    end
elsif options.prefix == FALSE && options.suffix == TRUE
    input_matrix.each do |line|
        output_matrix << line.gsub(/#{options.delimiter}/, '\0' + options.rstring)
    end
elsif options.prefix == TRUE && options.suffix == TRUE
    input_matrix.each do |line|
        output_matrix << line.gsub(/#{options.delimiter}/, options.rstring + '\0' + options.rstring)
    end
end

if options.outputfile == nil
    ofile = File.new(options.inputfile, 'w+')
    output_matrix.each do |line|
        ofile.write(line)
    end
else
    ofile = File.new(options.outputfile, 'w+')
    output_matrix.each do |line|
        ofile.write(line)
    end
end
