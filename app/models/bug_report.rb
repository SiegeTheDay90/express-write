# frozen_string_literal: true

# == Schema Information
#
# Table name: bug_reports
#
#  id                :bigint           not null, primary key
#  body              :text             not null
#  email             :text
#  replied           :boolean          default(FALSE)
#  requires_response :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  user_agent        :text
#
class BugReport < ApplicationRecord
  validates :body, length: { minimum: 25 }
end
