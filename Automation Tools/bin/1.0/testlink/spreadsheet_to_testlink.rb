#!/usr/bin/env ruby
require 'rubygems'
require 'roo'
require 'xmlrpc/client'
require 'ostruct'
require 'optparse'

options = OpenStruct.new
options.testlink_url = "http://10.206.1.21/testlink"
options.testlinkapi = "/lib/api/xmlrpc.php"
options.apikey = ""
options.testlink_url_testing = "http://localhost/testlink"
options.testlinkapi_testing = "/lib/api/xmlrpc.php"
options.apikey_testing = "1bdd402c9ab47e1a64349e4750bc2a5f"
options.ss = ""
options.author = ""

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = ""
    opts.on("-i SPREADSHEET", "File name of spreadsheet to parse through. File name determines the test suite/project path") { |v| options.ss = v }
    opts.on("-t TESTLINKURL", "Defaults to http://10.206.1.21/testlink") { |v| options.testlink_url = v.sub(/\/\z/, '') }
    opts.on("--apikey APIKEY", "Sets the API key to use to communicate with TestLink") { |v| options.apikey = v }
    opts.on("--username NAME", "Sets the author name. This is your USER NAME for TESTLINK. This is required for test case creation") { |v| options.author = v }

    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

class TestLink
    attr_accessor :apikey
    def initialize(apikey, testlink_server)
        @apikey = apikey
        @values = { "devKey" => @apikey }
        @server = XMLRPC::Client.new2(testlink_server)
    end

    def method_missing(name, *args)
        return @server.call("tl.#{name}", (args[0] ? @values.merge(args[0]) : @values))
    end

    # Finds an ID by a name from a given array of hashes from TestLink
    def id_of(name, obj)
        return false if obj.nil?
        return false if obj.empty?
        id = false

        if obj["name"].match(/#{name}/i)
            return obj["id"]
        else
            return false
        end if obj.has_key?("id") if obj.is_a?(Hash)

        obj.each do |object|
            # Check exact
            id = object["id"] if object["name"].match(/#{name}/i) if object.is_a?(Hash)
            id = object.last["id"] if object.last["name"].match(/#{name}/i) if object.is_a?(Array)
            # Check with no spaces
            id = object["id"] if object["name"].delete(' ').match(/#{name}/i) if object.is_a?(Hash)
            id = object.last["id"] if object.last["name"].delete(' ').match(/#{name}/i) if object.is_a?(Array)
        end
        return id
    end

    # Create a new test suite
    def create_suite(name, proj, parent=false)
        puts "Creating new test suite named #{name}. Please provide a description for this suite"
        desc = gets.chomp
        response = parent ? @server.call("tl.createTestSuite", @values.merge("testsuitename" => name, "details" => desc, "testprojectid" => proj, "parentid"=>parent))[0] : @server.call("tl.createTestSuite", @values.merge("testsuitename" => name, "details" => desc, "testprojectid" => proj))[0]
        return response["id"] if response["message"].match(/ok/i)
        raise "Error: Unable to create test suite. Check your permissions and the name, then try again."
    end
end

class TestCase
    attr_accessor :name, :summary, :steps, :expected, :priority, :requirements, :comment, :precondition, :testsuite_id, :testproject_id, :author
    def initialize
        @name = 0
        @summary = 0
        @steps = 0
        @expected = 0
        @priority = 0
        @requirements = 0
        @precondition = 0
        @comment = 0
        @testsuite_id = 0
        @testproject_id = 0
        @author = ""
        @importance = { :high => 3, :medium => 2, :low => 1 }
    end

    def build(sheet, row)
        base = { "testsuiteid" => @testsuite_id, "testprojectid" => @testproject_id, "authorlogin" => @author, "checkduplicatedname"=>"1", "actiononduplicatedname"=>"create_new_version" }
        required = { "summary"=>sheet.cell(row, @summary), "testcasename"=>sheet.cell(row, @name) }
        optional = {}
        optional["preconditions"] = sheet.cell(row, @precondition) unless sheet.cell(row, @precondition).nil?
        optional["importance"] = @importance[sheet.cell(row, @priority).downcase.to_sym] unless sheet.cell(row, @priority).nil?
        required["steps"] = create_steps(sheet.cell(row, @steps).gsub(/\d+\./, "::").split("::")[1..-1], sheet.cell(row, @expected))
        return base.merge(required).merge(optional)
    end

    # Creates step array of hashes from XML
    def create_steps(value, expected)
        temp = []
        st_count = 0

        value.each do |x|
            temp[st_count] = {}
            temp[st_count][:step_number] = "#{st_count+1}"
            temp[st_count][:actions] = "<p>#{x.strip}</p>"
            temp[st_count][:expected_results] = expected unless expected.nil?
            temp[st_count][:execution_type] = "1"
            temp[st_count][:active] = "1"
            st_count += 1
        end
        return temp
    end
end

opts.parse!(ARGV)
parent_id = ""
project_id = ""

s = Excelx.new(options.ss) if options.ss.match(/xlsx$/i)
s = Excel.new(options.ss) if options.ss.match(/xls$/i)
testpath = options.ss.sub(/\..*$/, '').split("-")
tc = TestCase.new
tl = TestLink.new(options.apikey_testing, options.testlink_url_testing+options.testlinkapi_testing)

# Get the project ID
project_id = tl.id_of(testpath[0], tl.getProjects)
raise "No project in TestLink by the name of #{testpath[0]}" unless project_id
raise "No spreadsheet specified" if options.ss.empty?
raise "No API key specified" if options.apikey.empty?
raise "No author/username specified" if options.author.empty?

for x in s.first_column..s.last_column do
    case s.cell(1,x)
    when /name/i
        tc.name = x
    when /summary/i
        tc.summary = x
    when /steps/i
        tc.steps = x
    when /expect/i
        tc.expected = x
    when /priority/i
        tc.priority = x
    when /requirement/i
        tc.requirements = x
    when /comment/i
        tc.comment = x
    when /precondition/i
        tc.precondition = x
    end
end

# finding the last level suite id
testpath[1..-1].each do |suitename|
    if parent_id.empty?
        # Create first level suite name if it's missing
        parent_id = tl.id_of(suitename, tl.getFirstLevelTestSuitesForTestProject("testprojectid" => project_id))
        parent_id = tl.create_suite(suitename, project_id) unless parent_id
    else
        # Create sub levels if missing
        last_parent = parent_id.dup
        parent_id = tl.id_of(suitename, tl.getTestSuitesForTestSuite("testsuiteid" => parent_id))
        parent_id = tl.create_suite(suitename, project_id, last_parent) unless parent_id
    end
end

tc.testproject_id = project_id
tc.testsuite_id = parent_id
tc.author = options.author

for x in (s.first_row+1)..s.last_row do
    # Skip this row if requirements are missing
    next if s.cell(x, tc.name).nil? || s.cell(x, tc.summary).nil? || s.cell(x, tc.steps).nil?
    next if s.cell(x, tc.name).empty? || s.cell(x, tc.summary).empty? || s.cell(x, tc.steps).empty?
    current = tc.build(s, x)
    result = tl.createTestCase(current)
    puts "Added #{s.cell(x,tc.name)}:#{result[0]["additionalInfo"]["id"]}"
end
