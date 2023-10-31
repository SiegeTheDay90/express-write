class ChangeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string
    add_column :users, :session_token, :string
    add_index :users, :session_token
    add_index :users, :username
  end
end
