class ChangeTestSectionToText < ActiveRecord::Migration
  def self.up
    change_column(:test_cases, :test_section, :text)
  end

  def self.down
    change_column(:test_cases, :test_section, :string)
  end
end
