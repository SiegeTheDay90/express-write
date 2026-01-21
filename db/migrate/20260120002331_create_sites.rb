class CreateSites < ActiveRecord::Migration[7.2]
  create_table :sites do |t|
    t.string  :name, null: false
    t.string  :url, null: false
    t.text    :description, default: ""
    t.string  :category, null: false, default: "General"
    t.integer :likes, null: false, default: 0
    t.boolean :active, default: true, null: false
    t.integer :position, default: 0, null: false
    t.integer :clicks, default: 0, null: false
    t.string :slug, null: false
    t.timestamps
  end
  add_index :sites, :active
  add_index :sites, :category
  add_index :sites, :url, unique: true
  add_index :sites, [:category, :position]
end
