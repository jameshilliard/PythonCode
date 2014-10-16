#!/usr/bin/env ruby
require 'rubygems'
require 'httparty'
require 'json'

class SCUpdate
  attr_reader :response
  include HTTParty
  headers 'content-type' => 'application/json'

  def initialize(server_uri)
    @response = nil
    @server_uri = server_uri
  end
  def server_state(servid, state)
    @response = self.class.put("#{@server_uri}/servers/#{servid}.json", :body => "{'server':#{JSON.generate({:state => state})}}")
  end
  def tc_update(tcid, result)
    @response = self.class.put("#{@server_uri}/test_cases/#{tcid}.json", :body => "{'test_case':#{JSON.generate({:result => result})}}")
  end
end

execution = "xhost + && perl $SQAROOT/bin/1.0/common/gflaunch.pl -v G_BUILD=$SQAROOT/download/MI424WR-GEN2.rmt -v G_USER=$MY_EMAIL -v G_HTTP_DIR=test -v G_TESTBED=$MY_TB -v G_PROD_TYPE=MC524WR -v G_TBTYPE=pf -v G_CC=$MY_DIST -f /root/testing_assignment.tst"
puts "Waiting for testing assignments ..."
while(true)
  if File.exists?("/root/testing_assignment.tst") && File.exists?("/root/test_case.ids")
    tc_ids = {}
    test_cases = File.open("/root/test_case.ids").readlines
    test_cases.each { |ids| tc_ids[ids.split("==")[0]] = ids.split("==")[1].chomp }
    testing = SCUpdate.new("http://10.1.10.210")
    testing.server_state(tc_ids["server_id"], "Busy")
    system(execution)
    results = File.open("#{`echo $SQAROOT`.chomp}/logs/current/result.txt").read
    
    passed_tests = results.scan(/\.Testcase Passed: (tc.*xml)$/).inject([]) { |values, x| values << x[0] }
    failed_tests = results.scan(/\.Testcase FAILED: (tc.*xml)$/).inject([]) { |values, x| values << x[0] }

    passed_tests.each do |test_name|
      testing.tc_update(tc_ids[test_name], "Passed")
    end

    failed_tests.each do |test_name|
      testing.tc_update(tc_ids[test_name], "Failed")
    end
    system("rm -f /root/testing_assignment.tst && rm -f /root/test_case.ids")
    sleep 10
    testing.server_state(tc_ids["server_id"], "Pending")
    puts "Waiting for testing assignments ..."
  end
  sleep 20
end
