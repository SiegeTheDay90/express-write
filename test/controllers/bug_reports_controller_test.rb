require "test_helper"

class BugReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get bug_report_url
    assert_response :success
  end
end
