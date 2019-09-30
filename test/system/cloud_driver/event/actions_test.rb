require "application_system_test_case"

module CloudDriver
  class Event::ActionsTest < ApplicationSystemTestCase
    setup do
      @event_action = cloud_driver_event_actions(:one)
    end

    test "visiting the index" do
      visit event_actions_url
      assert_selector "h1", text: "Event/Actions"
    end

    test "creating a Action" do
      visit event_actions_url
      click_on "New Event/Action"

      click_on "Create Action"

      assert_text "Action was successfully created"
      click_on "Back"
    end

    test "updating a Action" do
      visit event_actions_url
      click_on "Edit", match: :first

      click_on "Update Action"

      assert_text "Action was successfully updated"
      click_on "Back"
    end

    test "destroying a Action" do
      visit event_actions_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Action was successfully destroyed"
    end
  end
end
