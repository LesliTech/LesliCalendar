require 'test_helper'

module CloudDriver
  class Calendar::AttachmentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @calendar_attachment = cloud_driver_calendar_attachments(:one)
    end

    test "should get index" do
      get calendar_attachments_url
      assert_response :success
    end

    test "should get new" do
      get new_calendar_attachment_url
      assert_response :success
    end

    test "should create calendar_attachment" do
      assert_difference('Calendar::Attachment.count') do
        post calendar_attachments_url, params: { calendar_attachment: {  } }
      end

      assert_redirected_to calendar_attachment_url(Calendar::Attachment.last)
    end

    test "should show calendar_attachment" do
      get calendar_attachment_url(@calendar_attachment)
      assert_response :success
    end

    test "should get edit" do
      get edit_calendar_attachment_url(@calendar_attachment)
      assert_response :success
    end

    test "should update calendar_attachment" do
      patch calendar_attachment_url(@calendar_attachment), params: { calendar_attachment: {  } }
      assert_redirected_to calendar_attachment_url(@calendar_attachment)
    end

    test "should destroy calendar_attachment" do
      assert_difference('Calendar::Attachment.count', -1) do
        delete calendar_attachment_url(@calendar_attachment)
      end

      assert_redirected_to calendar_attachments_url
    end
  end
end
