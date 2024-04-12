# frozen_string_literal: true

class CreateBugReports < ActiveRecord::Migration[7.0]
  def change
    create_table :bug_reports do |t|
      t.text :body, null: false
      t.text :user, default: '{}'
      t.boolean :replied, default: false
      t.boolean :requires_response, default: false

      t.timestamps
    end
  end
end
