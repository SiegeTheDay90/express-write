# == Schema Information
#
# Table name: resumes
#
#  id         :bigint           not null, primary key
#  title      :string           default("My Resume")
#  header     :text             default("")
#  personal   :text             default("{}")
#  work       :text             default("[]")
#  education  :text             default("[]")
#  links      :text             default("[]")
#  skills     :text             default("[]")
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class ResumeTest < ActiveSupport::TestCase
  test "No Tests Here Yet" do
    assert true
  end
end
