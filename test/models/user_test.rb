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
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string
#  uid                    :string
#  username               :string
#  session_token          :string
#  active_profile         :integer
#  email_token            :string
#  unconfirmed_email      :string
#  email_token_sent_at    :datetime
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
