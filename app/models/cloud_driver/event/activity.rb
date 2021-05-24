=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
module CloudDriver
    class Event::Activity < CloudObject::Activity
        belongs_to :event, class_name: "Event", foreign_key: "cloud_driver_events_id"

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
            action_done_task:           "action_done_task",
            action_clone_task:          "action_clone_task"
        }

    end
end
