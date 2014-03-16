# == Schema Information
# Schema version: 20110203190610
#
# Table name: test_cases
#
#  id                       :integer(4)      not null, primary key
#  testlink_testcase_id     :integer(4)
#  testlink_testplan_id     :integer(4)
#  testlink_project_id      :integer(4)
#  test_results             :string(255)
#  testlink_build_version   :string(255)
#  result                   :integer(4)
#  created_at               :datetime
#  updated_at               :datetime
#  test_suite_id            :integer(4)
#  filename                 :string(255)
#  firmware_version         :string(255)
#  device_type              :string(255)
#  test_section             :text
#  test_log_location        :string(255)
#  step_count               :integer(4)
#  documentation            :text
#  testlink_user_id         :integer(4)
#  reported                 :boolean(1)
#  testlink_report_response :text
#

require 'testlink'
class TestCase < ActiveRecord::Base
  belongs_to :test_suite
  belongs_to :testlink_user

  serialize :test_section, Array
  
  validates :test_results, :presence => true, :if => Proc.new{|tc| OVERRIDE_STATES.include?(TEST_STATES[tc.result]) }, :allow_blank => false
  scope :queued, lambda { where("test_cases.test_suite_id IS NOT NULL") }
  scope :in_suite, lambda { |sid| where(:test_suite_id => sid) }
  scope :from_user, lambda { |u| where(:testlink_user_id => u) }
  scope :not_assigned, lambda { where("test_cases.test_suite_id IS NULL") }
  scope :with_section, lambda { |sect| where(:test_section => sect.to_yaml) }
  scope :similar_section, lambda { |sect| where("test_section like ?", sect.to_yaml+"%") }
  scope :reported, where(:reported => true)
  scope :not_reported, where(:reported => false)
  
  def self.update_testcases(tl_info)
    tl = TestLink.new(:server => tl_info.server_address, :apikey => tl_info.apikey, :username => tl_info.username)
    testlink_projects = TestlinkProject.assigned_to(tl_info.id)
    # Start with each project ID and get test plan IDs
    testlink_projects.each do |proj|
      # Update view to show that we're getting test plans
      testlink_plans = tl.getProjectTestPlans("testprojectid"=>proj.project_id)
      testlink_plans.each do |p|
        # Get all test cases that are assigned to the user, have not been executed, and are supposed to be automated (type 2)
        # Update view to show that we're getting test cases for test plan p['name']
        testlink_testcases = tl.getTestCasesForTestPlan("testplanid" => p["id"], "assignedto"=>tl_info.testlink_user_id, "executestatus"=>"n", "executiontype"=>"2")
        testlink_builds = tl.getBuildsForTestPlan("testplanid"=>p["id"])
        testlink_platforms = tl.getTestPlanPlatforms("testplanid"=>p["id"])
        
        # Iterate through the test cases (if any) and start creating TC objects
        testlink_testcases.each_pair do |suite,info|
          # Crush the information hash (future proofing) 
          info.crush!
          
          # Skip if we already have this TC in the database
          next if TestCase.find_by_testlink_testcase_id(info["tc_id"])
          tc = TestCase.new

          # TestLink specific information
          tc.testlink_project_id = proj.project_id.to_i
          tc.testlink_testplan_id = p['id'].to_i
          tc.testlink_testcase_id = info['tc_id'].to_i
          tc.testlink_build_version = testlink_builds.map { |v| v["id"] if v["id"] == info['assigned_build_id'] }.first

          # Testing platform specific information
          tc.device_type = testlink_platforms.map { |v| v["name"] if v["id"] == info['platform_id'] }.first
          tc.firmware_version = testlink_builds.map { |v| v["name"] if v["id"] == info['assigned_build_id'] }.first
          tc.test_section = tl.getFullPath("nodeid"=>info["testsuite_id"].to_i)[info["testsuite_id"]]
          tc.filename = info['name']

          # Test case documentation provided from TestLink
          tc_steps = tl.getTestCase("testcaseid"=>info['tc_id']).first["steps"]
          tc.documentation = tc_steps.map { |s| "#{s['actions']}"}.join("||")
          tc.step_count = tc_steps.count

          # Associate to the user ID
          tc.testlink_user_id = tl_info.id
          # Set the default result state
          tc.result = TESTCASE_DEFAULT_STATE
          # Save
          tc.save
        end if testlink_testcases.is_a?(Hash)
      end unless testlink_plans.empty?
    end
  end
end
