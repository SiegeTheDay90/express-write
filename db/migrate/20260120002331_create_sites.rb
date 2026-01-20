class CreateSites < ActiveRecord::Migration[7.2]
  def change
    create_table :sites do |t|
      t.timestamps
      t.string :name, null: false
      t.integer :likes, default: 0
      t.string :url, null: false
      t.text :description, default: ""
      t.string :category, default: "General"
    end
  end
end
