module LesliCalendar
    # Relations stay lazy so range filters and limits run in the database.
    class EventQuery
        def initialize(user)
            @user = user
        end

        def personal
            visible.where(user_id: @user.id).or(visible.where(id: responses(:accepted)))
        end

        def pending
            direct = Event::UserInvitation.where(user_id: @user.id).select(:event_id)
            invited = visible.where(id: direct)
            if defined?(LesliShield)
                roles = @user.roles.where(account_id: @user.account_id).select(:id)
                role_events = Event::RoleInvitation.where(role_id: roles).select(:event_id)
                invited = invited.or(visible.where(id: role_events))
            end
            # A pending response also covers public participants asked to reconfirm a new time.
            invited.or(visible.where(id: responses(:pending)))
                .where.not(user_id: @user.id)
                .where.not(id: responses([:accepted, :declined]))
                .where("end_at > ?", Time.current).order(:start_at, :id)
        end

        def available
            visible.where(public: true).where.not(user_id: @user.id)
                .where.not(id: responses(:accepted))
                .where("end_at > ?", Time.current).order(:start_at, :id)
        end

        def overlapping(start_at, end_at)
            personal.where("start_at < ? AND end_at > ?", end_at, start_at).order(:start_at, :id)
        end

        def upcoming
            personal.where("end_at > ?", Time.current).order(:start_at, :id)
        end

        private

        def visible
            Event.visible_to(@user).where(status: :scheduled)
        end

        def responses(value)
            Event::Attendant.where(user_id: @user.id, response: value).select(:event_id)
        end
    end
end
