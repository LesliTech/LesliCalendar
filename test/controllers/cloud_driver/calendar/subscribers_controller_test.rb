require 'test_helper'

module CloudDriver
  class Calendar::SubscribersControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_subscriber = cloud_driver_calendar_subscribers(:one)
    end

    test "should get index" do
      get calendar_subscribers_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_subscriber_url
      assert_response :success
    end

    test "should create calendar_subscriber" do
      assert_difference('Calendar::Subscriber.count') do
        post calendar_subscribers_url, params: { calendar_subscriber: {  } }
      end

      assert_redirected_to calendar_subscriber_url(Calendar::Subscriber.last)
    end

    test "should show calendar_subscriber" do
      get calendar_subscriber_url(@calendar_subscriber)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_subscriber_url(@calendar_subscriber)
      assert_response :success
    end

    test "should update calendar_subscriber" do
      patch calendar_subscriber_url(@calendar_subscriber), params: { calendar_subscriber: {  } }
      assert_redirected_to calendar_subscriber_url(@calendar_subscriber)
    end

    test "should destroy calendar_subscriber" do
      assert_difference('Calendar::Subscriber.count', -1) do
        delete calendar_subscriber_url(@calendar_subscriber)
      end

      assert_redirected_to calendar_subscribers_url
    end
  end
end
