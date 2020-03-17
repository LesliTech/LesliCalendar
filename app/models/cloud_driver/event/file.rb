module CloudDriver
    class Event::File < CloudObject::File
        belongs_to :cloud_object, class_name: "CloudDriver::Event", foreign_key: "cloud_driver_events_id"
    end
end
