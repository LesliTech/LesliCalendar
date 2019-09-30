require 'test_helper'

module CloudDriver
  class Event::ActionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @event_action = cloud_driver_event_actions(:one)
    end

    test "should get index" do
      get event_actions_url
      assert_response :success
    end

    test "should get new" do
      get new_event_action_url
      assert_response :success
    end

    test "should create event_action" do
      assert_difference('Event::Action.count') do
        post event_actions_url, params: { event_action: {  } }
      end

      assert_redirected_to event_action_url(Event::Action.last)
    end

    test "should show event_action" do
      get event_action_url(@event_action)
      assert_response :success
    end

    test "should get edit" do
      get edit_event_action_url(@event_action)
      assert_response :success
    end

    test "should update event_action" do
      patch event_action_url(@event_action), params: { event_action: {  } }
      assert_redirected_to event_action_url(@event_action)
    end

    test "should destroy event_action" do
      assert_difference('Event::Action.count', -1) do
        delete event_action_url(@event_action)
      end

      assert_redirected_to event_actions_url
    end
  end
end
