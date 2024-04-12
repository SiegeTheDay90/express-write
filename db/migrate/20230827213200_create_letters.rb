# frozen_string_literal: true

class CreateLetters < ActiveRecord::Migration[7.0]
  def change
    create_table :letters do |t|
      t.text :body, null: false
      t.text :config, default: ''
      t.timestamps
    end
  end
end
