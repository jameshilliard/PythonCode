class CreateTestlinkProjects < ActiveRecord::Migration
  def self.up
    create_table :testlink_projects do |t|
      t.string :project_name, :null => false
      t.string :project_id, :null => false
      t.integer :testlink_user_id
      
      t.timestamps
    end
    remove_column(:testlink_users, :project_id)
    remove_column(:testlink_users, :project_name)
  end

  def self.down
    drop_table :testlink_projects
    add_column(:testlink_users, :project_id, :integer)
    add_column(:testlink_users, :project_name, :string)
  end
end
