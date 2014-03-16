# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
require File.dirname(__FILE__)+"/config/initializers/sc_constants"
unless SC_TESTING
  every WAIT_TIME_BEFORE_TEST_SUITE_CREATION do
    runner "TestSuite.delay.build_suites"
  end

  every WAIT_TIME_TEST_CASE_UPDATE do
    runner "TestlinkUser.all.each {|tluser| TestCase.delay.update_testcases(tluser)}"
  end

  every WAIT_TIME_BEFORE_TEST_RESULT_PUSH do
    runner "TestlinkUser.all.each {|tlu| tlu.delay.report_testlink_results}"
    runner "TestSuite.all.each {|ts| ts.delay.clean_up}"
  end if TESTCASE_AUTOMATIC_RESULT_PUSHING

  every WAIT_TIME_BEFORE_SUITES_ASSIGNED_TO_SERVER do
    runner "TestSuite.delay.test_suites_to_servers"
  end
else
  every 1.minute do
    runner "TestlinkUser.all.each {|tluser| TestCase.delay.update_testcases(tluser)}; TestSuite.delay.build_suites; TestSuite.delay.test_suites_to_servers; TestlinkUser.all.each {|tlu| tlu.delay.report_testlink_results}; TestSuite.all.each {|ts| ts.delay.clean_up}; Server.delay.server_state_update;"
  end
end
