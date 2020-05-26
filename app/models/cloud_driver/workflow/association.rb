module CloudDriver
    class Workflow::Association < CloudObject::Workflow::Association

        belongs_to :workflow, class_name: "Workflow", foreign_key: "cloud_driver_workflows_id"

        enum object_association: {
            calendar: "calendar",
            event: "event",
        }
    end
end
