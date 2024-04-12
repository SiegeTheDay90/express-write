# frozen_string_literal: true

require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  test 'should check valid id' do
    id = Request.create!(resource_type: 'temp_letter').id
    get "/check/#{id}"
    assert_response :success
    assert @response.content_type.include?('application/json')
    response_body = JSON.parse(@response.body)

    assert_equal 'temp_letter', response_body['resource_type']
    assert_equal false, !response_body['complete'].nil?
    assert_equal true, !response_body['ok'].nil?
  end

  test 'should respond to invalid id with errors' do
    id = -1
    get "/check/#{id}"
    assert_response :success
    response_body = JSON.parse(@response.body)
    assert_equal ({ 'errors' => 'Resource not found' }), response_body
  end
end
