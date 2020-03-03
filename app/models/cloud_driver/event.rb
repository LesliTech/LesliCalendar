module CloudDriver
    class Event < ApplicationRecord
        belongs_to :calendar, foreign_key: "cloud_driver_calendars_id"

        has_one :detail, inverse_of: :event, autosave: true, foreign_key: "cloud_driver_events_id", dependent: :destroy
        accepts_nested_attributes_for :detail, update_only: true

    end
end
