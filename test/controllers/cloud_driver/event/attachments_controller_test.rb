require 'test_helper'

module CloudDriver
  class Event::AttachmentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @event_attachment = cloud_driver_event_attachments(:one)
    end

    test "should get index" do
      get event_attachments_url
      assert_response :success
    end

    test "should get new" do
      get new_event_attachment_url
      assert_response :success
    end

    test "should create event_attachment" do
      assert_difference('Event::Attachment.count') do
        post event_attachments_url, params: { event_attachment: {  } }
      end

      assert_redirected_to event_attachment_url(Event::Attachment.last)
    end

    test "should show event_attachment" do
      get event_attachment_url(@event_attachment)
      assert_response :success
    end

    test "should get edit" do
      get edit_event_attachment_url(@event_attachment)
      assert_response :success
    end

    test "should update event_attachment" do
      patch event_attachment_url(@event_attachment), params: { event_attachment: {  } }
      assert_redirected_to event_attachment_url(@event_attachment)
    end

    test "should destroy event_attachment" do
      assert_difference('Event::Attachment.count', -1) do
        delete event_attachment_url(@event_attachment)
      end

      assert_redirected_to event_attachments_url
    end
  end
end
