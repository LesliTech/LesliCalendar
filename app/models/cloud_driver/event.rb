module CloudDriver
    class Event < ApplicationRecord
        belongs_to :calendar, foreign_key: "cloud_driver_calendars_id"

        has_one :detail, foreign_key: "cloud_driver_events_id", dependent: :delete, inverse_of: :event, autosave: true
        accepts_nested_attributes_for :detail

    end
end
