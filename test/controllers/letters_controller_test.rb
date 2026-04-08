# frozen_string_literal: true

require 'test_helper'

class LettersControllerTest < ActionDispatch::IntegrationTest
  # test 'valid_url? with response 200' do
  #   get '/url-check', params: { url: 'https://httpstat.us/200' }

  #   assert_response :success
  #   assert @response.content_type.include?('application/json')
  #   response_body = JSON.parse(@response.body)
  #   assert_equal response_body['ok'], true
  # end
  test 'delete existing temp letter' do
    letter = TempLetter.create!(secure_id: 'test123', profile: 'Test Profile', body: 'Test Letter Content', listing: 'Test Listing')
    delete "/letters/#{letter.secure_id}"
    assert_response :success
    letter = TempLetter.find_by(secure_id: 'test123')
    assert_nil letter
  end
  test 'delete non-existing temp letter' do
    delete "/letters/test123"
    assert_response :not_found
  end
end
