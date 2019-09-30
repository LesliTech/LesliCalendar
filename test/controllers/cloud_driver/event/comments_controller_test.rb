require 'test_helper'

module CloudDriver
  class Event::CommentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @event_comment = cloud_driver_event_comments(:one)
    end

    test "should get index" do
      get event_comments_url
      assert_response :success
    end

    test "should get new" do
      get new_event_comment_url
      assert_response :success
    end

    test "should create event_comment" do
      assert_difference('Event::Comment.count') do
        post event_comments_url, params: { event_comment: {  } }
      end

      assert_redirected_to event_comment_url(Event::Comment.last)
    end

    test "should show event_comment" do
      get event_comment_url(@event_comment)
      assert_response :success
    end

    test "should get edit" do
      get edit_event_comment_url(@event_comment)
      assert_response :success
    end

    test "should update event_comment" do
      patch event_comment_url(@event_comment), params: { event_comment: {  } }
      assert_redirected_to event_comment_url(@event_comment)
    end

    test "should destroy event_comment" do
      assert_difference('Event::Comment.count', -1) do
        delete event_comment_url(@event_comment)
      end

      assert_redirected_to event_comments_url
    end
  end
end
