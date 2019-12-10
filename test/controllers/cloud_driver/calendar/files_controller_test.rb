require 'test_helper'

module CloudDriver
  class Calendar::FilesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_file = cloud_driver_calendar_files(:one)
    end

    test "should get index" do
      get calendar_files_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_file_url
      assert_response :success
    end

    test "should create calendar_file" do
      assert_difference('Calendar::File.count') do
        post calendar_files_url, params: { calendar_file: {  } }
      end

      assert_redirected_to calendar_file_url(Calendar::File.last)
    end

    test "should show calendar_file" do
      get calendar_file_url(@calendar_file)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_file_url(@calendar_file)
      assert_response :success
    end

    test "should update calendar_file" do
      patch calendar_file_url(@calendar_file), params: { calendar_file: {  } }
      assert_redirected_to calendar_file_url(@calendar_file)
    end

    test "should destroy calendar_file" do
      assert_difference('Calendar::File.count', -1) do
        delete calendar_file_url(@calendar_file)
      end

      assert_redirected_to calendar_files_url
    end
  end
end
