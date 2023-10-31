class AddFkToLetters < ActiveRecord::Migration[7.0]
  def change
    add_reference :letters, :listing
    add_reference :letters, :user, index: true, foreign_key: true
  end
end
