class AddEmailTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_token, :string
    add_column :users, :unconfirmed_email, :string
    add_column :users, :email_token_sent_at, :datetime
    add_index :users, :email_token
  end
end
