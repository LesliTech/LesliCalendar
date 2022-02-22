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
    class EventServices

        def self.create(current_user, event_params)
            event = current_user.account.driver.calendars.default.events.new(event_params)
            event.account = current_user.account
            event.user_creator = current_user
            event.set_workflow

            unless event_params[:user_main_id]
                event.user_main = current_user
            end

            if event.save
                Event.log_activity_create(current_user, event)
                event.attendants.create(users_id: event.user_main.id)

                return LC::Response.service(true, event)
            end

            return LC::Response.service(false, event)
        end

        def self.destroy(current_user, event)
            return LC::Response.service(false) unless event
            return LC::Response.service(false, event) unless event.is_editable_by?(current_user)

            if event.destroy
                Event.log_activity_destroy(current_user, event)
                return LC::Response.service(true)
            end

            return LC::Response.service(false, event)
        end

    end
end
