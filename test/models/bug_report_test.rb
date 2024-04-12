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
require 'test_helper'

class BugReportTest < ActiveSupport::TestCase
  test 'less than 25 characters' do
    assert_not BugReport.create(name: 'Clarence', body: 'Too Short').persisted?
  end

  test '25 or more characters' do
    assert BugReport.create(name: 'Clarence', body: 'A' * 26)
  end
end
