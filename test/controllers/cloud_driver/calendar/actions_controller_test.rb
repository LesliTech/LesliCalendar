require 'test_helper'

module CloudDriver
  class Calendar::ActionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_action = cloud_driver_calendar_actions(:one)
    end

    test "should get index" do
      get calendar_actions_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_action_url
      assert_response :success
    end

    test "should create calendar_action" do
      assert_difference('Calendar::Action.count') do
        post calendar_actions_url, params: { calendar_action: {  } }
      end

      assert_redirected_to calendar_action_url(Calendar::Action.last)
    end

    test "should show calendar_action" do
      get calendar_action_url(@calendar_action)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_action_url(@calendar_action)
      assert_response :success
    end

    test "should update calendar_action" do
      patch calendar_action_url(@calendar_action), params: { calendar_action: {  } }
      assert_redirected_to calendar_action_url(@calendar_action)
    end

    test "should destroy calendar_action" do
      assert_difference('Calendar::Action.count', -1) do
        delete calendar_action_url(@calendar_action)
      end

      assert_redirected_to calendar_actions_url
    end
  end
end
