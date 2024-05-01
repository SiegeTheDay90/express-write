class CreateSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :sessions do |t|
      t.string :session_id, null: false, index: {unique: true}
      t.string :ip_address, index: true
      t.integer :hits, default: 0
      t.integer :tokens, default: 5
      t.string :user_agent
      t.integer :last_request_id
      t.timestamps
    end
    
    add_column :requests, :session_id, :string
    add_foreign_key :requests, :sessions, column: :session_id, primary_key: :session_id
    add_foreign_key :sessions, :requests, column: :last_request_id
  end
end
