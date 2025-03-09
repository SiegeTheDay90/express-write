# frozen_string_literal: true

require 'test_helper'

class BugReportsControllerTest < ActionDispatch::IntegrationTest
  # test 'should get new' do
  #   get bug_report_url
  #   assert_response :success
  #   assert_template 'bug_reports/new'
  #   assert assigns(:bug_report).present?
  #   assert_instance_of BugReport, assigns(:bug_report)
  # end

  # test 'should create bug report' do
  #   assert_difference('BugReport.count') do
  #     post bug_report_url,
  #          params: { bug_report: { body: 'A' * 25, requires_response: true, email: 'test@example.com' } }
  #   end

  #   assert_redirected_to root_url
  #   assert_equal ['Bug Reported Successfully! We will reach out as soon as possible.'], flash['messages']
  # end

  # test 'should render new on failed create' do
  #   post bug_report_url, params: { bug_report: { body: '', requires_response: true, user: 'test@example.com' } }
  #   assert_response :success
  #   assert_template 'bug_reports/new'
  #   # assert_equal ["Body can't be blank"], flash.now["errors"]
  # end
end
