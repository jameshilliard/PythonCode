# == Schema Information
# Schema version: 20101116201816
#
# Table name: testlink_users
#
#  id               :integer(4)      not null, primary key
#  username         :string(255)     not null
#  apikey           :string(255)     not null
#  server_address   :string(255)     not null
#  default          :boolean(1)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  testlink_user_id :integer(4)
#

require 'testlink'
class TestlinkUser < ActiveRecord::Base
  has_many :testlink_projects
  has_many :test_cases
  validates :apikey, :presence=>true, :length=>{:is => 32, :message => "API keys should be 32 characters in length."}
  validates_presence_of :username
  validates_presence_of :server_address
  validates_presence_of :testlink_user_id
  scope :default_user, where(:default => true)

  before_validation :check_testlink_server

  def report_testlink_results
    tl = TestLink.new(:server => self.server_address, :apikey => self.apikey)
    if tl.sayHello
      self.test_cases.not_reported.each do |tc|
        next if tc.result.nil?
        next if tc.reported == TRUE
        status = TEST_STATES[tc.result]
        next unless status.match(/failed|passed/i)
        response = tl.reportTCResult("testcaseid" => tc.testlink_testcase_id, "testplanid" => tc.testlink_testplan_id, "status" => (status.match(/passed/i) ? "p" : "f"), "guess" => true, "platformname" => tc.device_type)
        tc.update_attribute(:testlink_report_response, response)
        tc.update_attribute(:reported, true)
      end
    end
  end

  private
  def check_testlink_server
    uri_test = URI::regexp(%w(http https))
    if self.server_address.match(uri_test)
      tl = TestLink.new(:server => self.server_address, :apikey => self.apikey)
      if tl.sayHello
        unless tl.checkDevKey.is_a?(TrueClass)
          self.apikey = nil
        else
          userinfo = tl.getUserInfo
          self.testlink_user_id = userinfo['user_id']
          self.username = userinfo['username']
        end
      else
        self.server_address = nil
      end
    end
  end
end
