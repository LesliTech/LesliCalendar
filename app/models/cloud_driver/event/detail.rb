module CloudDriver
    class Event::Detail < ApplicationRecord
        belongs_to :event, foreign_key: "cloud_driver_events_id"
    end
end
