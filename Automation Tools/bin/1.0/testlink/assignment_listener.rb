#!/usr/bin/env ruby
#
# Listens for assignments from TestLink and sends the information to the system controller
#
# 0.1.0
# Last changed on Friday, September 24th, 2010
#
# Copyright:: (c) 2010 Actiontec Electronics Inc., Confidential. All rights reserved.
# Author::  Chris Born (cborn@actiontec.com)

require 'xmlrpc/client'

class APIClient
    SERVER_URL = "http://localhost/testlink/lib/api/xmlrpc.php"
    def initialize(dev_key)
        @server = XMLRPC::Client.new2(SERVER_URL)
        @dev_key = dev_key
    end

    def report(internal_tc_id, plan_id, status)
        args = {"devKey" => @dev_key, "testcaseid" => internal_tc_id, "testplanid" =>  plan_id, "status" => status, "guess" => true }
        @server.call("tl.reportTCResult", args)
    end

    def find_project_ids(name)
        # This returns an array of hashes with the project information
        ids = {}
        projects = @server.call("tl.getProjects", "devKey" => @dev_key)
        projects.each do |proj|
            ids[proj["name"]] = proj["id"].to_i if proj["name"].match(/#{name}/i)
        end
        return ids
    end
    
    def get_test_plans(project_id)
        # This returns an array of hashes with the plans
        plans = @server.call("tl.getProjectTestPlans", "devKey" => @dev_key, "testprojectid" => project_id)
        testplans = {}
        plans.each do |plan|
            testplans[plan["name"]] = plan["id"].to_i
        end
        return testplans
    end
    
    def get_test_cases(plan_id, assignment_name)
        # Find all test cases from the project that have not been executed yet
        testcases = @server.call("tl.getTestCasesForTestPlan", "devKey" => @dev_key, "testplanid" => plan_id,  "$assignedto"=>"#{assignment_name}")
        tcases = []
        testcases.each_pair { |test, info| tcases << info["name"] if info["exec_status"] == "n" } unless testcases.empty?
        return tcases
    end

    def get_test_suites(plan_id)
        # Returns a list of test suites under the current test plan
        suites = @server.call("tl.getTestSuitesForTestPlan", "devKey" => @dev_key, "testplanid" => plan_id)
        testsuites = {}
        suites.each_pair { |suitename, suiteid| testsuites[suitename] << suiteid["id"] } unless testcases.empty?
        return testsuites
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

    def get_latest_build(plan_id)
        build = @server.call("tl.getLatestBuildForTestPlan", "devKey" => @dev_key, "testplanid" => plan_id)
        return build["name"]
    end
end

# This is the dev key for the "automation" user name
client = APIClient.new("3cba54358693b316d90501c068728d00")
lockfile = "/var/lock/.testing"

system_idle = true
first_run = true
begin
    while(TRUE)
        system_idle = File.exists?(lockfile) ? false : true
        if system_idle
            tests = {}
            builds = {}
            suites = {}
            sleep_time = 600
            slept = 0
            # Sleep for awhile between assignment checks
            while(slept < sleep_time)
                sleep 30
                slept += 30
                puts "Checking for assignments in #{(sleep_time-slept)/60} minutes #{(sleep_time-slept)%60} seconds"
            end unless first_run
            first_run = false
            puts "Checking for assignments now."

            # Find the test cases assigned to the "automation" user name
            # We want to barrel down pretty deep here
            # So we follow that the project name will be the device with "automation" in the name (like "BHR2 Automation")
            # The test plan will be the parent section we are testing (like "Firewall")
            # And the test suite is the section within the parent section we are testing (like "Port Forwarding")
            project_ids = client.find_project_ids("Automation")
            project_ids.each_pair do |project_name, project_id|
                puts "Checking project \"#{project_name}\" (TestLink ID: #{project_id})"
                # Find the test plans
                testplans = client.get_test_plans(project_id)
                testplans.each_pair do |plan_name, plan_id|
                    puts "Getting information for test plan \"#{name}\" (TestLink ID: #{plan id})"
                    # Find the test suites from the test plans
                    temp_tests = client.get_test_cases(id, "automation")
                    unless temp_tests.empty?
                        puts "Found tests to be executed"
                        tests[name] = temp_tests
                        builds[name] = client.get_latest_build(id)
                        File.new(lockfile, "w+")
                    else
                        puts "No tests for that test plan assigned"
                    end
                end
            end

            # If we got new assignments then do something here and set the lock file
            unless tests.empty?
                # Lock file
                File.new(lockfile, "w+")
                # Show what we're running and send to the automation administrator process which will start testing for us
                tests.each_pair do |plan, testcases|
                    # Run test system
                    puts "Found test plan \"#{plan}\" that should run on build #{builds[plan]}"
                    puts "The following test cases will run (#{testcases.length} total test cases): #{testcases.join ","}"
                end
            else
                puts "No new assignments at this time"
            end
            # Create our lock file if we're supposed to activate the system
        else
            # Else check if the system isn't busy any longer and set the system_idle var back to true
            # We use a file lock here, it's safer. This should be removed by the update process once finished
            # To avoid spam we'll check every 5 minutes
            system_idle = true unless File.exists?(lockfile)
            puts system_idle ? "Automation system idle again" : "Testing in progress..."
            sleep 30
            # Since we've been waiting this entire time for testing to be done, set the first run var to true so it checks for new assignments right away
            first_run = true
        end
    end
ensure
    File.delete(lockfile)
end
