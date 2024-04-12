# frozen_string_literal: true

class ChangeBugReport < ActiveRecord::Migration[7.0]
  def change
    change_column_default :bug_reports, :user, nil
    rename_column :bug_reports, :user, :email
    add_column :bug_reports, :name, :string
    add_column :bug_reports, :user_agent, :text
  end
end
