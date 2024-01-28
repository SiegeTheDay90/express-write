class RemoveBioFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :skills
    remove_column :users, :education
    remove_column :users, :experience
    remove_column :users, :completion
    remove_column :users, :industry
    remove_column :users, :aboutme
    remove_column :users, :projects
  end
end
