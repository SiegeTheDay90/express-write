require "test_helper"

class BugReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get bug_reports_create_url
    assert_response :success
  end
end
