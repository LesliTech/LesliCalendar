require 'test_helper'

module CloudDriver
  class Calendar::CommentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_comment = cloud_driver_calendar_comments(:one)
    end

    test "should get index" do
      get calendar_comments_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_comment_url
      assert_response :success
    end

    test "should create calendar_comment" do
      assert_difference('Calendar::Comment.count') do
        post calendar_comments_url, params: { calendar_comment: {  } }
      end

      assert_redirected_to calendar_comment_url(Calendar::Comment.last)
    end

    test "should show calendar_comment" do
      get calendar_comment_url(@calendar_comment)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_comment_url(@calendar_comment)
      assert_response :success
    end

    test "should update calendar_comment" do
      patch calendar_comment_url(@calendar_comment), params: { calendar_comment: {  } }
      assert_redirected_to calendar_comment_url(@calendar_comment)
    end

    test "should destroy calendar_comment" do
      assert_difference('Calendar::Comment.count', -1) do
        delete calendar_comment_url(@calendar_comment)
      end

      assert_redirected_to calendar_comments_url
    end
  end
end
