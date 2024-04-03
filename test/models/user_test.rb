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

  setup do
    @valid_user_params = {
      email: "user@test.io", 
      password: SecureRandom.urlsafe_base64, 
      first_name: "Clarence", 
      last_name: "Smith",
    }
    @valid_user = User.new @valid_user_params

  end

  test "should save valid user" do
    assert @valid_user.save
  end

  # test "should not save User without email" do
  #   user = User.new
  #   assert_not user.save
  # end

  test "should not save User without valid active_profile" do
    @valid_user.active_profile = -1
    assert_not @valid_user.save
  end

end
