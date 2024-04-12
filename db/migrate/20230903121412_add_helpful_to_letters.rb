# frozen_string_literal: true

class AddHelpfulToLetters < ActiveRecord::Migration[7.0]
  def change
    add_column :letters, :helpful, :boolean, default: nil
  end
end
