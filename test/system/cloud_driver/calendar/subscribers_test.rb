require "application_system_test_case"

module CloudDriver
  class Calendar::SubscribersTest < ApplicationSystemTestCase
    setup do
      @calendar_subscriber = cloud_driver_calendar_subscribers(:one)
    end

    test "visiting the index" do
      visit calendar_subscribers_url
      assert_selector "h1", text: "Calendar/Subscribers"
    end

    test "creating a Subscriber" do
      visit calendar_subscribers_url
      click_on "New Calendar/Subscriber"

      click_on "Create Subscriber"

      assert_text "Subscriber was successfully created"
      click_on "Back"
    end

    test "updating a Subscriber" do
      visit calendar_subscribers_url
      click_on "Edit", match: :first

      click_on "Update Subscriber"

      assert_text "Subscriber was successfully updated"
      click_on "Back"
    end

    test "destroying a Subscriber" do
      visit calendar_subscribers_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Subscriber was successfully destroyed"
    end
  end
end
