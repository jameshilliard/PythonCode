#!/usr/bin/env ruby
#
# Demo to listen for assignments from TestLink, execute them, and report the result back.
# This demo is full of cheats, hacks, and underhanded techniques. It is meant for
# demonstration purposes only, and should not be used as a base guide on how to
# interact with TestLink and the Test System.
#
# 1.0.0
# Last changed on Wednesday, October 27th, 2010
#
# Copyright:: (c) 2010 Actiontec Electronics Inc., Confidential. All rights reserved.
# Author::  Chris Born (cborn@actiontec.com)

require 'testlink'

pf_prefix = "-tc $SQAROOT/platform/1.0/verizon2/testcases/port_forwarding/tcases/"
execution = "xhost + && perl $SQAROOT/bin/1.0/common/gflaunch.pl -v G_BUILD=$SQAROOT/download/MI424WR-GEN2.rmt -v G_USER=$MY_EMAIL -v G_HTTP_DIR=test -v G_TESTBED=$MY_TB -v G_PROD_TYPE=MC524WR -v G_TBTYPE=pf -v G_CC=$MY_DIST -f "
tl = TestLink.new
tlplanid = "13527"

test_cases_ran = []
# assigned_build_id
while(true)
  portforwarding_cases = []
  puts "Checking for new assignments."
  # Assigned variable doesn't work in RC1+ of TestLink, so this will sort through
  # the hashed results and return items that matches the automation user ID (49 currently)
  # For now we're only looking for port forwarding tests
  tl.getTestCasesForTestPlan("testplanid" => tlplanid).each_pair do |key,data|
    if data["user_id"] == tl.user_id
      portforwarding_cases << data["name"] unless test_cases_ran.include?(data["name"]) if data["name"].match(/tc_sect/i)
    end
  end

  unless portforwarding_cases.empty?
    puts "---- Found assignments. Building test suite..."
    format_cases = []
    failed_updates = []
    status_updates = {}
    
    partial = File.open("tsuite_portfw_partial_fast.tst").readlines
    portforwarding_cases.each { |c| format_cases << pf_prefix+c+"\n"; test_cases_ran << c }

    output = File.new("tsuite_portfw_assigned.tst", 'w+')
    tc_index = partial.index("#--TC\n") + 2
    partial.insert(tc_index, format_cases)
    output.write partial.flatten
    output.close
    puts "---- Executing. Please wait."
    system(execution+`pwd`.chomp+"/tsuite_portfw_assigned.tst")

    # report results
    puts "Done. Reporting results."
    results = File.open("#{`echo $SQAROOT`.chomp}/logs/current/result.txt").read
    passed_tests = results.scan(/\.Testcase Passed: (tc.*xml)$/).inject([]) { |values, x| values << x[0] }
    failed_tests = results.scan(/\.Testcase FAILED: (tc.*xml)$/).inject([]) { |values, x| values << x[0] }

    passed_tests.each do |test_name|
      status_updates[test_name] = tl.reportTCResult("testcaseid" => tl.getTestCaseIDByName("testcasename"=>test_name)[0]["id"], "testplanid"=>tlplanid, "status"=>"p", "guess"=>"true")[0]
    end

    failed_tests.each do |test_name|
      status_updates[test_name] = tl.reportTCResult("testcaseid" => tl.getTestCaseIDByName("testcasename"=>test_name)[0]["id"], "testplanid"=>tlplanid, "status"=>"f", "guess"=>"true")[0]
    end

    status_updates.each_pair do |tcase, status|
      unless status["message"].match(/success/i)
        failed_updates << "#{tcase} status update unsuccessful - #{status["message"]}"
      end
    end
    puts "=-"*40
    puts failed_updates.empty? ? "---- All updates were successful" : failed_updates
  end
  puts "Waiting 2 minutes before checking for new assignments."
  sleep 120
end