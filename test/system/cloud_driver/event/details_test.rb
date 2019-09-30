require "application_system_test_case"

module CloudDriver
  class Event::DetailsTest < ApplicationSystemTestCase
    setup do
      @event_detail = cloud_driver_event_details(:one)
    end

    test "visiting the index" do
      visit event_details_url
      assert_selector "h1", text: "Event/Details"
    end

    test "creating a Detail" do
      visit event_details_url
      click_on "New Event/Detail"

      click_on "Create Detail"

      assert_text "Detail was successfully created"
      click_on "Back"
    end

    test "updating a Detail" do
      visit event_details_url
      click_on "Edit", match: :first

      click_on "Update Detail"

      assert_text "Detail was successfully updated"
      click_on "Back"
    end

    test "destroying a Detail" do
      visit event_details_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Detail was successfully destroyed"
    end
  end
end
