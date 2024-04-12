# frozen_string_literal: true

class RemoveForeignKeyLetters < ActiveRecord::Migration[7.0]
  def change
    remove_column :letters, :listing_id
  end
end
