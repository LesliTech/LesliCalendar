require 'test_helper'

module CloudDriver
  class Calendar::DetailsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_detail = cloud_driver_calendar_details(:one)
    end

    test "should get index" do
      get calendar_details_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_detail_url
      assert_response :success
    end

    test "should create calendar_detail" do
      assert_difference('Calendar::Detail.count') do
        post calendar_details_url, params: { calendar_detail: {  } }
      end

      assert_redirected_to calendar_detail_url(Calendar::Detail.last)
    end

    test "should show calendar_detail" do
      get calendar_detail_url(@calendar_detail)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_detail_url(@calendar_detail)
      assert_response :success
    end

    test "should update calendar_detail" do
      patch calendar_detail_url(@calendar_detail), params: { calendar_detail: {  } }
      assert_redirected_to calendar_detail_url(@calendar_detail)
    end

    test "should destroy calendar_detail" do
      assert_difference('Calendar::Detail.count', -1) do
        delete calendar_detail_url(@calendar_detail)
      end

      assert_redirected_to calendar_details_url
    end
  end
end
