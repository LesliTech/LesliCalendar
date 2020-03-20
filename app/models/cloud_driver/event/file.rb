module CloudDriver
    #class Event::File < ApplicationRecord
    class Event::File < CloudObject::File
        belongs_to :cloud_object, class_name: "CloudDriver::Event", foreign_key: "cloud_driver_events_id"
        #mount_uploader :attachment, FileUploader
    end
end
