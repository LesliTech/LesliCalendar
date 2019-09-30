require 'test_helper'

module CloudDriver
  class Event::ActivitiesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @event_activity = cloud_driver_event_activities(:one)
    end

    test "should get index" do
      get event_activities_url
      assert_response :success
    end

    test "should get new" do
      get new_event_activity_url
      assert_response :success
    end

    test "should create event_activity" do
      assert_difference('Event::Activity.count') do
        post event_activities_url, params: { event_activity: {  } }
      end

      assert_redirected_to event_activity_url(Event::Activity.last)
    end

    test "should show event_activity" do
      get event_activity_url(@event_activity)
      assert_response :success
    end

    test "should get edit" do
      get edit_event_activity_url(@event_activity)
      assert_response :success
    end

    test "should update event_activity" do
      patch event_activity_url(@event_activity), params: { event_activity: {  } }
      assert_redirected_to event_activity_url(@event_activity)
    end

    test "should destroy event_activity" do
      assert_difference('Event::Activity.count', -1) do
        delete event_activity_url(@event_activity)
      end

      assert_redirected_to event_activities_url
    end
  end
end
