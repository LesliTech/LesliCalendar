module CloudDriver
    class Event::Activity < ApplicationRecord
        belongs_to :event, class_name: "Event", foreign_key: "cloud_driver_events_id"
        belongs_to :user, class_name: "::User", foreign_key: "users_id", optional: true

        # This enum overrides the one from CloudObject::Activity
        enum category: {
            action_list:                "action_list",
            action_create:              "action_create",
            action_show:                "action_show",
            action_update:              "action_update",
            action_destroy:             "action_destroy",
            action_status:              "action_status",
            action_create_attendant:    "action_create_attendant",
            action_create_file:         "action_create_file",
            action_destroy_file:        "action_destroy_file",
            action_create_task:         "action_create_task",
            action_done_task:           "action_done_task"
        }

    end
end
