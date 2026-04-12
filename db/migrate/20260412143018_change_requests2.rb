class ChangeRequests2 < ActiveRecord::Migration[7.2]
  def change
    add_column :requests, :count, :integer, default: 0, null: false
    add_column :temp_letters, :tone, :string, default: '', null: false
  end
end
