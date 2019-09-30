require 'test_helper'

module CloudDriver
  class Event::DetailsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @event_detail = cloud_driver_event_details(:one)
    end

    test "should get index" do
      get event_details_url
      assert_response :success
    end

    test "should get new" do
      get new_event_detail_url
      assert_response :success
    end

    test "should create event_detail" do
      assert_difference('Event::Detail.count') do
        post event_details_url, params: { event_detail: {  } }
      end

      assert_redirected_to event_detail_url(Event::Detail.last)
    end

    test "should show event_detail" do
      get event_detail_url(@event_detail)
      assert_response :success
    end

    test "should get edit" do
      get edit_event_detail_url(@event_detail)
      assert_response :success
    end

    test "should update event_detail" do
      patch event_detail_url(@event_detail), params: { event_detail: {  } }
      assert_redirected_to event_detail_url(@event_detail)
    end

    test "should destroy event_detail" do
      assert_difference('Event::Detail.count', -1) do
        delete event_detail_url(@event_detail)
      end

      assert_redirected_to event_details_url
    end
  end
end
