# == Schema Information
# Schema version: 20110203190610
#
# Table name: testing_environments
#
#  id                       :integer(4)      not null, primary key
#  environment_name         :string(255)
#  environment_description  :text
#  before_testing           :string(255)
#  after_testing            :string(255)
#  force_stop_command       :string(255)
#  retrieve_results_command :string(255)
#  wait_for_test_completion :boolean(1)
#  start_command            :string(255)
#  stop_command             :string(255)
#  testsuite_build_command  :string(255)
#  remote_working_directory :string(255)
#  environment_variables    :text
#  created_at               :datetime
#  updated_at               :datetime
#

class TestingEnvironment < ActiveRecord::Base
  has_many :test_suites
  has_and_belongs_to_many :devices, :join_table => :dte
  has_and_belongs_to_many :connection_types, :join_table => :cte
end
