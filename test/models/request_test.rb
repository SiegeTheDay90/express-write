# == Schema Information
#
# Table name: requests
#
#  id            :bigint           not null, primary key
#  complete      :boolean          default(FALSE)
#  ok            :boolean
#  messages      :string           default("")
#  resource_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :string
#
require "test_helper"

class RequestTest < ActiveSupport::TestCase
  test "cannot be created without resource_type" do
    assert_not Request.create().persisted?
  end

  test "cannot be created with invalid resource_type" do
    assert_not Request.create({resource_type: "foo"}).persisted?
  end

  test "can be created with valid resource_type" do
    assert Request.create({resource_type: "temp_letter"}).persisted?
  end

  test "can be completed" do
    req = Request.create({resource_type: "temp_letter"})

    assert_not req.complete
    req.complete!(true, "id")
    assert req.complete
  end
end
