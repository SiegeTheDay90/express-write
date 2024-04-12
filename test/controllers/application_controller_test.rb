require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "valid_url? with response 200" do
    get "/url-check", params: {url: "https://httpstat.us/200" }

    assert_response :success
    assert @response.content_type.include?("application/json")
    response_body = JSON.parse(@response.body)
    assert_equal response_body["ok"], true
    
  end

  test "valid_url? with response 404" do
    get "/url-check", params: {url: "https://httpstat.us/404" }

    assert_response :success
    assert @response.content_type.include?("application/json")
    response_body = JSON.parse(@response.body)
    assert_equal false, response_body["ok"]
    assert_equal "404 Not Found", response_body["status"]
  end

  test "valid_url? with response 400" do
    get "/url-check", params: {url: "https://httpstat.us/400" }

    assert_response :success
    assert @response.content_type.include?("application/json")
    response_body = JSON.parse(@response.body)
    assert_equal false, response_body["ok"]
    assert_equal "400 Bad Request", response_body["status"]
  end

  # test "valid_url? with response 301" do
  #   get "/url-check", params: {url: "https://mail.com" }

  #   assert_response :success
  #   assert @response.content_type.include?("application/json")
  #   response_body = JSON.parse(@response.body)
  #   puts response_body
  #   assert_equal true, response_body["ok"]
  #   assert_equal "301 Found", response_body["status"]
  # end
end
