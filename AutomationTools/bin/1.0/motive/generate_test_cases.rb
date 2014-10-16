#!/usr/bin/env ruby

# == Synopsis
#
# parseSheet.rb - Parses TR-69 inputs from Excel spreadsheet into XML format. 
#                 An individual XML will be created for each test case
#                 XML's are created under test_result\test_result_xxxxx.xml
#
# == Usage
#
# parseSheet.rb [OPTIONS] ... [FILENAME]
#
#
# --output, -o [FILENAME]:
#    Specify output file for XML. By default, XML output will be 
#    to the console, and not a file. Using --output without a filename
#    will default to using the file "default.xml"
# --startrow, -s [ROW]: 
#    The row to begin at, by default 1. 
# --lastrow, -l [ROW]:
#    Row to stop at. Note that this is inclusive, and will output
#    data from the specified row before stopping. 
# --version, -v:
#    Outputs the current script system version and exits
# --help, -h:
#    Displays this help text, and exits
#
# == Version
# Build: 1.0  ; Distributed on: 03-24-2009
# Build: 1.1  ; Distributed on: 03-26-2009
#
# == Copyright
# (c) 2009 Actiontec Electronics, Inc. 
# Confidential. All rights reserved.
# == Author
# Chris Born
# Modified by Kurt Liu
	
# - Using current format for output: 
#
# 	<case>
# 		<id>3</id>
# 		<keyword>InternetGatewayDevice</keyword>
# 		<description>InternetGatewayDevice</description>
# 		<test_type>get parameter value</test_type>
# 		<parameter_name>InternetGatewayDevice.</parameter_name>
# 	</case>

require 'rubygems'
require 'spreadsheet'
require 'English'
require 'getoptlong'
require 'rdoc/usage'
require 'fileutils'
firstRow = 41
lastRow = 419
xmlfile = ""
# Yes. There are TWO "S"'s in the work sheet name. Who knew? 
procSheet = "BHR TR-069 Committmentss"
excelfile = FALSE
id = 1
GPV = "get parameter value"
SPV = "set parameter value"

opts = GetoptLong.new( 
	['--startrow', '-s', GetoptLong::OPTIONAL_ARGUMENT],
	['--lastrow', '-l', GetoptLong::OPTIONAL_ARGUMENT],
#	['--output', '-o',        GetoptLong::OPTIONAL_ARGUMENT],
	['--version', '-v', GetoptLong::NO_ARGUMENT],
	['--help', '-h',       GetoptLong::NO_ARGUMENT]
)

begin
	
	opts.each do |opt, arg|
		case opt
		when '--lastrow'
			if arg == nil || arg == ""
				puts "Missing argument for --lastrow."
				puts "Maybe you should check out the --help."
				exit 0
			else
				lastRow = arg.to_i
			end
		when '--startrow'
			if arg == nil || arg == ""
				puts "Missing argument for --startrow."
				puts "You might be looking for --help."
				exit 0
			else
				firstRow = arg.to_i
			end
#		when '--output'
#			arg == "" ? xmlfile = "default.xml" : xmlfile = arg
		when '--sheet'
			arg == "" ? procSheet = "BHR TR-069 Committmentss" : procSheet = arg
		when '--help'
			RDoc::usage('Synopsis','Usage','Copyright')
		when '--version'
			RDoc::usage('Version', 'Author')
		end
	end
	
	if ARGV.length != 1
		puts "Missing input file."
		puts "Perhaps you need --help?"
		exit 0
	end

	excelfile = ARGV.shift

rescue => ex
	puts "Error: #{ex.class}: #{ex.message}"
end

# method to check for valid file saving directory and filename
def fileCheck(filetest="")
	directory = ""
#	directory = filetest.slice(/.*\//).sub(/\/\z/, '') if filetest.include?('\\') or filetest.include?('/')
	if filetest.include?('\\')
		directory = filetest.slice(/.*\\/).sub(/\/\z/, '')
	elsif filetest.include?('/')
		directory = filetest.slice(/.*\//).sub(/\/\z/, '')
	end
#	puts "directory = " + directory
	# Check what we are writing to... 
	if FileTest.exist?(filetest)
		puts "Will attempt to overwrite prior existing file: #{filetest}"
		return true
	else
		if directory != ""
			begin
				FileUtils.mkdir_p(directory)
			rescue
				puts "Fatal - Directory #{directory} doesn't exist, and we can't create it."
				return false
			end
		end
	end
	return true
end

# method to save output to a file
def self.saveXML(xmlout, filename)
	if fileCheck(filename) == false
		puts "Invalid file specified to save output as - #{filename}"
		exit -1
	end
	begin
		f = File.open(filename, 'w')
		for cell in xmlout
			f.write(cell)
		end
		f.close
	rescue
		puts "Fatal - Unable to save #{filename}."
		exit -2
	end
end

def self.buildcase(id, keyword, pn, gors)
	return "\t<case>\n\t\t<id>#{id}</id>\n\t\t<keyword>#{keyword}</keyword>\n\t\t<description>#{pn}</description>\n\t\t<test_type>#{gors}</test_type>\n\t\t<parameter_name>#{pn}</parameter_name>\n\t</case>\n"
end

# pads an integer with "0" in front and return the padded string
def formatToString(i)
	case i
		when 0 .. 9
			return "0000" + i.to_s
		when 10 .. 99
			return "000" + i.to_s
		when 100 .. 999
			return "00" + i.to_s
		when 1000 .. 9999
			return "0" + i.to_s
		when 10000 .. 99999
			return i.to_s
		else
			puts "Integer is not in range of 0 .. 99999. Int = " + i.to_s
	end
end

begin
	Spreadsheet.client_encoding = 'UTF-8'
	book = Spreadsheet.open(excelfile)
	sheet = book.worksheet(procSheet)
	
	parent = ""
	currentRow = ""
	cellToXML = String.new

	sheet.each firstRow-1 do |row|

		if row[1]!=nil && row[1].match(/r|c|o/i)	
			output = []
			output[0] = "<test_cases>\n"
			# Clean current row if necessary
			if row[0]!=nil && row[0].match(/\(.*\)/)
				dataCell = "#{row[0]}"
				dataCell.sub!(/\(.*\)/, '')
				dataCell.delete!(' ')
			else
				dataCell = "#{row[0]}"
			end
			# If it's a parent, create the parent set
			if dataCell.match(/\.\z/)
				parent = String.new(dataCell)
				# Do not create a SPV test case for a branch parameter
				# cellToXML << self.buildcase(id, parent.sub(/\.\z/,''), parent, SPV) if row[1]!=nil && row[1].match(/r|c|o/i)
			else
				cellToXML << self.buildcase(id, "#{parent}#{dataCell.sub(/\.\z/,'')}", "#{parent}#{dataCell}", SPV) if row[1]!=nil && row[1].match(/r|c|o/i)
			end
			output[1] = cellToXML
			cellToXML = ""
		
			output[2] = "</test_cases>"
			if output.to_s != "" && (!dataCell.match(/\.\z/))
					xmlfile = "config\\config_" + formatToString(id) + ".xml"
					puts xmlfile
					self.saveXML(output, xmlfile)
			end
			if ! dataCell.match(/\.\z/)
				id += 1
			end
		end
		if row[2]!=nil && row[2].match(/r|c|o/i)
			output = []
			output[0] = "<test_cases>\n"
			# Clean current row if necessary
			if row[0]!=nil && row[0].match(/\(.*\)/)
				dataCell = "#{row[0]}"
				dataCell.sub!(/\(.*\)/, '')
				dataCell.delete!(' ')
			else
				dataCell = "#{row[0]}"
			end
			# If it's a parent, create the parent set
			if dataCell.match(/\.\z/)
				parent = String.new(dataCell)
				cellToXML << self.buildcase(id, parent.sub(/\.\z/,''), parent, GPV) if row[2]!=nil && row[2].match(/r|c|o/i)
			else
				cellToXML << self.buildcase(id, "#{parent}#{dataCell.sub(/\.\z/,'')}", "#{parent}#{dataCell}", GPV) if row[2]!=nil && row[2].match(/r|c|o/i)
			end
			output[1] = cellToXML
			cellToXML = ""
		
			output[2] = "</test_cases>"
			if output.to_s != ""
					xmlfile = "config\\config_" + formatToString(id) + ".xml"
					puts xmlfile
					self.saveXML(output, xmlfile)
			end
			id += 1
		end
		
		break if (lastRow - firstRow) == 0		
		firstRow += 1

	end
end
