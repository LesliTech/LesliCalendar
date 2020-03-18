module CloudDriver
  class Event::Activity < ApplicationRecord
    belongs_to :event, class_name: "Event", foreign_key: "cloud_driver_events_id"
  end
end
