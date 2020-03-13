module CloudDriver
    #class Event::File < CloudObject::File
    class Event::File < ApplicationRecord
        belongs_to :cloud_object, class_name: "CloudDriver::Event", foreign_key: "cloud_driver_events_id"
        #belongs_to :event, class_name: "CloudDriver::Event", foreign_key: "cloud_driver_events_id"
        has_one_attached :file
    end
end
