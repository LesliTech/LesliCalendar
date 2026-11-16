require "test_helper"

module LesliCalendar
    class DevelopmentSeedsTest < LesliTesting::ModelTester
        test "demo scenarios cover visibility responses dates and repeat safely" do
            account = Lesli::Account.create!(name: "Seed demo", email: "seed-demo@example.test", status: :active)
            owner, colleague = %w[owner colleague].map do |name|
                user = account.users.new(email: "#{name}-seed@example.test")
                user.password = "Password123!" if user.respond_to?(:password=)
                user.confirmed_at = Time.current if user.respond_to?(:confirmed_at=)
                user.save!
                user
            end
            if defined?(LesliShield)
                role = account.roles.first!
                LesliShield::User::Role.create!(user: owner, role: role)
            end
            seed_file = Engine.root.join("db/seed/development.rb")
            load seed_file
            events = account.calendar.events
            assert events.find_by!(title: "Demo: In progress").end_at > Time.current
            assert events.find_by!(title: "Demo: Completed meeting").end_at < Time.current
            assert events.find_by!(title: "Demo: Cancelled accepted invitation").cancelled?
            public_cancelled = events.find_by!(title: "Demo: Cancelled public meeting")
            assert public_cancelled.public?
            assert public_cancelled.cancelled?
            assert_equal 0, events.find_by!(title: "Demo: UTC date boundary").start_at.utc.hour
            assert_equal "accepted", events.find_by!(title: "Demo: Private invitation accepted").attendants.find_by!(user: owner).response
            assert_equal "declined", events.find_by!(title: "Demo: Private invitation declined").attendants.find_by!(user: owner).response
            assert_equal "pending", events.find_by!(title: "Demo: Rescheduled invitation").attendants.find_by!(user: owner).response
            hidden = events.find_by!(title: "Demo: Private event without access")
            refute_includes EventService.new(owner).index.result, hidden
            assert_equal colleague.id, hidden.user_id
            assert events.all? { |event| event.url == "/calendar/events/#{event.id}" }
            if defined?(LesliShield)
                assert_includes EventService.new(owner).pending_invitations.result, events.find_by!(title: "Demo: Role invitation pending")
            end
            count = events.count
            deleted = events.find_by!(title: "Demo: Personal focus time")
            deleted.destroy!
            load seed_file
            assert_equal count - 1, events.count
            assert_equal 1, events.with_deleted.where(title: "Demo: Personal focus time").count
        end
    end
end
