class TcInformation < ActiveRecord::Migration
  def self.up
    add_column(:test_cases, :step_count, :integer)
    add_column(:test_cases, :documentation, :text)
    remove_column(:test_cases, :tested)
  end

  def self.down
    remove_column(:test_cases, :documentation)
    remove_column(:test_cases, :step_count)
    add_column(:test_cases, :tested, :boolean)
  end
end
