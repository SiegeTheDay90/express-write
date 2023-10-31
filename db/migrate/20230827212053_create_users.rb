class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :password_digest, null: false, default: ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.string :first_name, default: ""
      t.string :last_name, default: ""
      t.text :skills, array: true, default: []
      t.text :education, array: true, default: []
      t.text :job_history, array: true, default: []
      t.integer :completion, default: 0
      t.string :industry_of_interest, default: ""

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
