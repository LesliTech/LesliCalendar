require 'test_helper'

module CloudDriver
  class Calendar::DiscussionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_discussion = cloud_driver_calendar_discussions(:one)
    end

    test "should get index" do
      get calendar_discussions_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_discussion_url
      assert_response :success
    end

    test "should create calendar_discussion" do
      assert_difference('Calendar::Discussion.count') do
        post calendar_discussions_url, params: { calendar_discussion: {  } }
      end

      assert_redirected_to calendar_discussion_url(Calendar::Discussion.last)
    end

    test "should show calendar_discussion" do
      get calendar_discussion_url(@calendar_discussion)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_discussion_url(@calendar_discussion)
      assert_response :success
    end

    test "should update calendar_discussion" do
      patch calendar_discussion_url(@calendar_discussion), params: { calendar_discussion: {  } }
      assert_redirected_to calendar_discussion_url(@calendar_discussion)
    end

    test "should destroy calendar_discussion" do
      assert_difference('Calendar::Discussion.count', -1) do
        delete calendar_discussion_url(@calendar_discussion)
      end

      assert_redirected_to calendar_discussions_url
    end
  end
end
