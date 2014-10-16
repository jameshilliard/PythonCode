#!/usr/bin/env ruby
# Updates the specified test plan test cases within TestLink with the test results from STAF (ATLAS)
#
# 0.1.0
# Last changed on Friday, September 24th, 2010
#
# Copyright:: (c) 2010 Actiontec Electronics Inc., Confidential. All rights reserved.
# Author::  Chris Born (cborn@actiontec.com)

require 'xmlrpc/client'

class APIClient
    SERVER_URL = "http://10.206.1.21/testlink/lib/api/xmlrpc.php"
    def initialize(dev_key)
        @server = XMLRPC::Client.new2(SERVER_URL)
        @dev_key = dev_key
    end

    def report(internal_tc_id, plan_id, status)
        args = {"devKey" => @dev_key, "testcaseid" => internal_tc_id, "testplanid" =>  plan_id, "status" => status, "guess" => true }
        @server.call("tl.reportTCResult", args)
    end

    def find_project_id(name)
        # This returns an array of hashes with the project information
        projects = @server.call("tl.getProjects", "devKey" => @dev_key)
        projects.each do |proj|
            return proj["id"].to_i if proj["name"].match(/#{name}/i)
        end
    end

    def find_test_plan(project_id, name)
        # This returns an array of hashes with the plans
        plans = @server.call("tl.getProjectTestPlans", "devKey" => @dev_key, "testprojectid" => project_id)
        plans.each do |plan|
            return plan["id"].to_i if plan["name"].match(/#{name}/i)
        end
    end

    def find_test_build(plan_id, name)
        # This returns an array of hashes with the builds associated to the test plan ID
        builds = @server.call("tl.getBuildsForTestPlan", "devKey" => @dev_key, "testprojectid" => project_id)
        builds.each do |build|
            return build["id"].to_i if build["name"].match(/#{name}/i)
        end
    end

    def get_testcase_id(name)
        @server.call("tl.getTestCaseIDByName", "devKey" => @dev_key, "testcasename" => name)[0]["id"].to_i
    end
end

exit if ARGV[0].nil?

status_updates = {}
client = APIClient.new("8499431de840d7b56194132964e97709")
plan_id = client.find_test_plan(client.find_project_id("Test Automation"), "BHR2 Automation")
results = File.open(ARGV[0]).read
passed_tests = results.scan(/\.Testcase Passed: (tc.*xml)$/).inject([]) { |values, x| values << x[0] }
failed_tests = results.scan(/\.Testcase FAILED: (tc.*xml)$/).inject([]) { |values, x| values << x[0] }
failed_updates = []

passed_tests.each do |test_name|
    status_updates[test_name] = client.report(client.get_testcase_id(test_name), plan_id, "p")[0]
end

failed_tests.each do |test_name|
    status_updates[test_name] = client.report(client.get_testcase_id(test_name), plan_id, "f")[0]
end

status_updates.each_pair do |tcase, status|
    unless status["message"].match(/success/i)
        failed_updates << "#{tcase} status update unsuccessful - #{status["message"]}"
    end
end

puts failed_updates.empty? ? "All updates were successful" : failed_updates