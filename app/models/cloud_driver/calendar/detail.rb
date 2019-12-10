module CloudDriver
    class Calendar::Detail < ApplicationRecord
        belongs_to :calendar, foreign_key: "cloud_driver_calendars_id"
    end
end
