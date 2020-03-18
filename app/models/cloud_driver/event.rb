module CloudDriver
    class Event < ApplicationRecord
        belongs_to :calendar, foreign_key: "cloud_driver_calendars_id"

        has_one :detail, inverse_of: :event, autosave: true, foreign_key: "cloud_driver_events_id", dependent: :destroy
        accepts_nested_attributes_for :detail, update_only: true

        has_many :files, foreign_key: "cloud_driver_events_id"
        has_many :activities, foreign_key: "cloud_driver_events_id"

    end
end
