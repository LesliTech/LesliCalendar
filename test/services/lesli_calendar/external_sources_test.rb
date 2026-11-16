require "test_helper"

module LesliCalendar
    class ExternalSourcesTest < ActiveSupport::TestCase
        test "missing Support returns an empty source" do
            support = Object.send(:remove_const, :LesliSupport) if Object.const_defined?(:LesliSupport)
            assert_empty EventService.new(nil).external_calendar_entries(start_at: Time.current, end_at: 1.day.from_now)
        ensure
            Object.const_set(:LesliSupport, support) if support
        end

        test "failed optional providers are reported without hiding local entries" do
            account = Lesli::Account.create!(name: "Provider failure", email: "provider-failure@example.test", status: :active)
            user = account.users.new(email: "provider-failure@example.test")
            if user.respond_to?(:password=)
                user.password = "Password123!"
                user.confirmed_at = Time.current
            end
            user.save!
            event = EventService.new(user).create(title: "Local event", start_at: 1.hour.from_now, end_at: 2.hours.from_now).result
            installed = Object.const_defined?(:LesliSupport)
            support = installed ? LesliSupport : Object.const_set(:LesliSupport, Module.new)
            provider = if support.const_defined?(:TicketService, false)
                support.const_get(:TicketService)
            else
                support.const_set(:TicketService, Class.new)
            end
            original_new = provider.method(:new)
            failure = RuntimeError.new("Provider unavailable")
            provider.define_singleton_method(:new) { |*| raise failure }
            reports = []
            subscriber = Object.new
            subscriber.define_singleton_method(:report) { |error, **| reports << error }
            Rails.error.subscribe(subscriber)

            entries = EventService.new(user, start: Time.current.iso8601, end: 1.day.from_now.iso8601).calendar_entries
            assert_equal ["lesli_calendar:event:#{event.id}"], entries.pluck(:id)
            assert_includes reports, failure
        ensure
            provider.define_singleton_method(:new, original_new) if original_new
            Rails.error.unsubscribe(subscriber) if subscriber
            Object.send(:remove_const, :LesliSupport) unless installed
        end
    end
end
