# == Schema Information
#
# Table name: temp_letters
#
#  id         :bigint           not null, primary key
#  profile    :string           not null
#  listing    :string           not null
#  body       :string           not null
#  secure_id  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class TempLetterTest < ActiveSupport::TestCase
  test "cannot create without body" do
    assert_not TempLetter.create(profile: "Resume", listing: "Job").persisted?
  end

  test "body is saved as plain and rich content" do
    t = TempLetter.create(profile: "Resume", listing: "Job", body: "This is the body in plain text. \n This is on a new line.")
    assert t.persisted?
    assert t.content.to_s.include?(t.body.gsub("\n", "<br>"))
  end
end
