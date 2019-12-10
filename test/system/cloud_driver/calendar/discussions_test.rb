require "application_system_test_case"

module CloudDriver
  class Calendar::DiscussionsTest < ApplicationSystemTestCase
    setup do
      @calendar_discussion = cloud_driver_calendar_discussions(:one)
    end

    test "visiting the index" do
      visit calendar_discussions_url
      assert_selector "h1", text: "Calendar/Discussions"
    end

    test "creating a Discussion" do
      visit calendar_discussions_url
      click_on "New Calendar/Discussion"

      click_on "Create Discussion"

      assert_text "Discussion was successfully created"
      click_on "Back"
    end

    test "updating a Discussion" do
      visit calendar_discussions_url
      click_on "Edit", match: :first

      click_on "Update Discussion"

      assert_text "Discussion was successfully updated"
      click_on "Back"
    end

    test "destroying a Discussion" do
      visit calendar_discussions_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Discussion was successfully destroyed"
    end
  end
end
