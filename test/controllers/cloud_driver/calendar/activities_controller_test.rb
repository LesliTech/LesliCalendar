require 'test_helper'

module CloudDriver
  class Calendar::ActivitiesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_activity = cloud_driver_calendar_activities(:one)
    end

    test "should get index" do
      get calendar_activities_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_activity_url
      assert_response :success
    end

    test "should create calendar_activity" do
      assert_difference('Calendar::Activity.count') do
        post calendar_activities_url, params: { calendar_activity: {  } }
      end

      assert_redirected_to calendar_activity_url(Calendar::Activity.last)
    end

    test "should show calendar_activity" do
      get calendar_activity_url(@calendar_activity)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_activity_url(@calendar_activity)
      assert_response :success
    end

    test "should update calendar_activity" do
      patch calendar_activity_url(@calendar_activity), params: { calendar_activity: {  } }
      assert_redirected_to calendar_activity_url(@calendar_activity)
    end

    test "should destroy calendar_activity" do
      assert_difference('Calendar::Activity.count', -1) do
        delete calendar_activity_url(@calendar_activity)
      end

      assert_redirected_to calendar_activities_url
    end
  end
end
