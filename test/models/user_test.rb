# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  password_digest        :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  first_name             :string           default("")
#  last_name              :string           default("")
#  skills                 :text             default([]), is an Array
#  education              :text             default([]), is an Array
#  experience             :text             default([]), is an Array
#  completion             :integer          default(0)
#  industry               :string           default("")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string
#  uid                    :string
#  username               :string
#  session_token          :string
#  aboutme                :text             default("")
#  projects               :string           default([]), is an Array
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
