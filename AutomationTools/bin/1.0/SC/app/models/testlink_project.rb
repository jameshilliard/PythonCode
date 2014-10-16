# == Schema Information
# Schema version: 20101116201816
#
# Table name: testlink_projects
#
#  id               :integer(4)      not null, primary key
#  project_name     :string(255)     not null
#  project_id       :string(255)     not null
#  testlink_user_id :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'testlink'
class TestlinkProject < ActiveRecord::Base
  belongs_to :testlink_user

  validates_presence_of :project_name
  validates_presence_of :testlink_user_id
  validates :project_id, :numericality=>{:greater_than => 0, :allow_nil => false, :message => "Invalid project name"}, :uniqueness => { :message => "Project already added for this user" }

  before_validation :get_project_id
  scope :assigned_to, lambda { |uid| where(:testlink_user_id => uid) }
  
  private
  def get_project_id
    # open RPC
    tl_info = TestlinkUser.find(self.testlink_user_id)
    tl = TestLink.new(:server => tl_info.server_address, :apikey => tl_info.apikey, :username => tl_info.username)

    # get project ID
    valid_projects = tl.getProjects
    v = tl.id_of(self.project_name, valid_projects)
    if v
      self.project_id = v.to_i
      self.project_name = tl.name_of(v, valid_projects)
    end
  end
end
