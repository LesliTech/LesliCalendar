module CloudDriver
    class Event::Attendant < ApplicationRecord
        belongs_to :event, foreign_key: "cloud_driver_events_id"
        belongs_to :user, foreign_key: "users_id"

        def self.attendant_options
            {
                users: Courier::Core::Users.list
            }
        end
    end
end
