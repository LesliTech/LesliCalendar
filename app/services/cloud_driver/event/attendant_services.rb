=begin

Copyright (c) 2023, all rights reserved.

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
    class Event::AttendantServices

        def self.create(current_user, events_id, event_attendant_params)
            # Looking for the event
            event = Courier::Driver::Event.find(current_user, events_id)

            return LC::Response.service(false) unless event

            return LC::Response.service(false) unless event.is_editable_by?(current_user)

            # Creating the event attendant
            attendant = event.attendants.new(event_attendant_params)

            if attendant.save
                LC::Response.service(true, attendant)

                Event.log_activity_create_attendant(current_user, event, attendant)
                Event.send_notification_create_attendant(attendant)
                EventMailer.with({ user: attendant.user, event: event }).attendant.deliver_later
            else
                LC::Response.service(false, attendant)
            end
        end

    end
end
