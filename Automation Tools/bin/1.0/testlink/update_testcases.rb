#!/usr/bin/env ruby
require 'xmlrpc/client'
require 'ostruct'

options = OpenStruct.new
options.testlink_url = "http://10.206.1.21/testlink"
options.testlinkapi = "/lib/api/xmlrpc.php"
key = { "devKey" => "c231f78e99d6d1ccd630e142739ccbaf" }

s = XMLRPC::Client.new2(options.testlink_url+options.testlinkapi)
testcases = s.call("tl.getTestCasesForTestSuite", key.merge("testsuiteid" => "13530"))
testcases.each do |tc|
    next if tc["name"].match(/tc_pc_0500/)
    updatetc = s.call("tl.getTestCase", key.merge("testcaseid" => tc["id"]))[0]
    next if updatetc['execution_type'] == '2'
    s.call("tl.createTestCase", key.merge("testsuiteid" => tc['parent_id'], "testprojectid" => "11868", "authorlogin" => updatetc['author_login'], "summary"=>updatetc['summary'], "testcasename"=>tc['name'], "steps"=>updatetc['steps'], "executiontype"=>"2", "preconditions"=>updatetc['preconditions'], "checkduplicatedname"=>"1", "actiononduplicatedname"=>"create_new_version"))
    puts "Updated #{tc["name"]}:#{tc["id"]}"
end
