module CloudDriver
    class Event::Attendant < ApplicationRecord
        belongs_to :event, foreign_key: "cloud_driver_events_id"
        belongs_to :user, foreign_key: "users_id"

        def self.attendant_options(current_user)
            {
                users: current_user.account.users.all
            }
        end
    end
end
