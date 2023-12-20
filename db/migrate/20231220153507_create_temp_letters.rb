class CreateTempLetters < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_letters do |t|
      t.string :profile, null: false
      t.string :listing, null: false
      t.string :body, null: false
      t.string :secure_id, null: false

      t.timestamps
    end

    add_index :temp_letters, :secure_id
  end
end
