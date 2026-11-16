module LesliCalendar
    class Dashboard < Lesli::Shared::Dashboard
        COMPONENTS = [:upcoming_events, :pending_invitations, :upcoming_deadlines].freeze
    end
end
