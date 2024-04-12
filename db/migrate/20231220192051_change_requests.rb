# frozen_string_literal: true

class ChangeRequests < ActiveRecord::Migration[7.0]
  def change
    rename_column :requests, :resource_id, :old_resource_id
    add_column :requests, :resource_id, :string
  end
end
