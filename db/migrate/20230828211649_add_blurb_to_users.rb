class AddBlurbToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :aboutme, :text, default: ""
    add_column :users, :projects, :string, array: true, default: []
    rename_column :users, :job_history, :experience
    rename_column :users, :industry_of_interest, :industry
  end
end
