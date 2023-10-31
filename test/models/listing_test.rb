# == Schema Information
#
# Table name: listings
#
#  id              :bigint           not null, primary key
#  company         :string           not null
#  job_title       :string           not null
#  job_description :text             default("")
#  requirements    :string           default([]), is an Array
#  benefits        :string           default([]), is an Array
#  user_id         :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

class ListingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
