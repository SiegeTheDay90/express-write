class CreateListings < ActiveRecord::Migration[7.0]
  def change
    create_table :listings do |t|
      t.string :company, null: false
      t.string :job_title, null: false
      t.text :job_description, default: ''
      t.string :requirements, array: true, default: []
      t.string :benefits, array: true, default: []
      t.references :user, foreign_key: true
      t.timestamps
    end

    add_reference :letters, :listing, index: true
    add_foreign_key :letters, :listings, column: :listing_id
  end
end
