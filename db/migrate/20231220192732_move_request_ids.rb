# frozen_string_literal: true

class MoveRequestIds < ActiveRecord::Migration[7.0]
  def change
    Request.all.each do |request|
      request.resource_id = request.old_resource_id
      request.save!
    end
    remove_column :requests, :old_resource_id
  end
end
