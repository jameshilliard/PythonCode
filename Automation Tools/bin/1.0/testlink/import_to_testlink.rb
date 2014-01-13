#!/usr/bin/env ruby

# Converts STAF (ATLAS internally) XML testcases to an XML version built for TestLink importing
# 
# 0.1.0
# Last changed on Wednesday, September 22nd, 2010
#
# Copyright:: (c) 2010 Actiontec Electronics Inc., Confidential. All rights reserved.
# Author::  Chris Born (cborn@actiontec.com)

require 'rexml/document'
require 'optparse'
require 'ostruct'
require 'xmlrpc/client'

options = OpenStruct.new
options.testcase_files = ""
options.testlink_url = "http://10.206.1.21/testlink"
options.testlinkapi = "/lib/api/xmlrpc.php"
options.automation_project_name = "Test Automation"
options.apikey = ""
options.testsuitename = []
options.author = ""
options.testcase_prefix = "tc_"

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Converts STAF(ATLAS) XML testcases and imports into TestLink automatically. Please note, that for each test plan or test suite, if it does not exist you will be asked to enter a description!"
    opts.on("-i INPUTDIRECTORY", "Directory of testcases to import") { |v| options.testcase_files = v }
    opts.on("--prefix FILEPREFIX", "Specify a file prefix. Defaults to tc_") { |v| options.testcase_prefix = v }
    opts.on("--project NAME", "Name of the TestLink project. Defaults to Test Automation") { |v| options.automation_project_name = v }
    opts.on("--suite SUITENAMES", "Name of the suite to create or add to. Use comma separated values to extend into child suites: --suite BHR2,Firewall,\"Port Forwarding\" would put all imported test cases for this run under BHR2->Firewall->Port Forwarding") { |v| options.testsuitename = v.split(',') }
    opts.on("-t TESTLINKURL", "Defaults to http://10.206.1.21/testlink") { |v| options.testlink_url = v.sub(/\/\z/, '') }
    opts.on("--apikey APIKEY", "Sets the API key to use to communicate with TestLink") { |v| options.apikey = v }
    opts.on("--username NAME", "Sets the author name. This is your USER NAME for TESTLINK. This is required for test case creation") { |v| options.author = v }

    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

# Returns a REXML document object
def read_test(filename)
    REXML::Document.new(File.open(filename).read)
end

# Creates step array of hashes from XML
def create_steps(value)
    temp = []
    st_count = 0
    value.each do |x|
        temp[st_count] = {}
        temp[st_count][:step_number] = "#{st_count+1}"
        temp[st_count][:actions] = "<p>#{x}</p>"
        temp[st_count][:expected_results] = "<p>Should pass</p>"
        temp[st_count][:execution_type] = "2"
        temp[st_count][:active] = "1"
        st_count += 1
    end
    return temp
end

# Finds an ID by a name from a given array of hashes from TestLink
def find_id_by_name(obj, name)
    return false if obj.nil?
    return false if obj.empty?
    id = false

    if obj["name"].match(/#{name}/i)
        return obj["id"]
    else
        return false
    end if obj.has_key?("id") if obj.is_a?(Hash)
    
    obj.each do |object|
        id = object["id"] if object["name"].match(/#{name}/i) if object.is_a?(Hash)
        id = object.last["id"] if object.last["name"].match(/#{name}/i) if object.is_a?(Array)
    end
    return id
end

# Creates a suite and asks for a description
def create_suite(name, proj, parent=false)
    puts "Creating new test suite named #{name}. Please provide a description for this suite"
    desc = gets.chomp
    response = parent ? @server.call("tl.createTestSuite", @key.merge("testsuitename" => name, "details" => desc, "testprojectid" => proj, "parentid"=>parent))[0] : @server.call("tl.createTestSuite", @key.merge("testsuitename" => name, "details" => desc, "testprojectid" => proj))[0]
    return response["id"] if response["message"].match(/ok/i)
    raise "Error: Unable to create test suite. Check your permissions and the name, then try again."
end

opts.parse!(ARGV)
raise "No testcase files specified" if options.testcase_files.empty?
raise "No automation project name specified" if options.automation_project_name.empty?
raise "No API key specified" if options.apikey.empty?
raise "No test suite names specified" if options.testsuitename.empty?
raise "No author/username specified" if options.author.empty?

# Import to testlink
@server = XMLRPC::Client.new2(options.testlink_url+options.testlinkapi)
@key = { "devKey" => options.apikey }

parent_id = ""
project_id = ""

# Get the project ID
project_id = find_id_by_name(@server.call("tl.getProjects", @key), options.automation_project_name)
raise "No project by the name of \"#{options.automation_project_name}\" found" unless project_id
# finding the last level suite id
options.testsuitename.each do |suitename|
    if parent_id.empty?
        # Create first level suite name if it's missing
        parent_id = find_id_by_name(@server.call("tl.getFirstLevelTestSuitesForTestProject", @key.merge("testprojectid" => project_id)), suitename)
        parent_id = create_suite(suitename, project_id) unless parent_id
    else
        # Create sub levels if missing
        last_parent = parent_id.dup
        parent_id = find_id_by_name(@server.call("tl.getTestSuitesForTestSuite", @key.merge("testsuiteid" => parent_id)), suitename)
        parent_id = create_suite(suitename, project_id, last_parent) unless parent_id
    end
end

# Read files from XML and start importing
Dir.glob("#{options.testcase_files}/#{options.testcase_prefix}*.xml".squeeze("/")).each do |testxml|
    xml = read_test(testxml)
    tc = {}
    steps = []
 
    name = xml.elements["testcase/name"].text
    tc[:summary] = "<p>#{xml.elements["testcase/description"].text}</p>"
    tc[:preconditions] = "<p>DUT must be connected and turned on</p>"
    xml.elements.each("testcase/stage/step/desc") { |x| steps << x.text }
    tc[:steps] = create_steps(steps)
    tc[:execution_type] = "2"
    
    puts "Creating test case #{name}"
    @server.call("tl.createTestCase", @key.merge("testsuiteid" => parent_id, "testprojectid" => project_id, "authorlogin" => options.author, "summary"=>tc[:summary], "testcasename"=>name, "steps"=>tc[:steps], "executiontype"=>tc[:execution_type], "preconditions"=>tc[:preconditions], "checkduplicatedname"=>"1", "actiononduplicatedname"=>"create_new_version"))
end