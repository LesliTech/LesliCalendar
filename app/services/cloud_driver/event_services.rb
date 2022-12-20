=begin

Copyright (c) 2022, all rights reserved.

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

        def self.create(current_user, event_params, calendar=nil)
            # Setting the default calendar if not provided
            calendar = current_user.account.driver.calendars.default(current_user) if calendar.blank?

            # Creating the event
            event = calendar.events.new(event_params)
            event.account = current_user.account
            event.user_creator = current_user

            unless event_params[:user_main_id]
                event.user_main = current_user
            end

            if event.save
                Event.log_activity_create(current_user, event)

                # Adding the main user as an attendant too
                event.attendants.create(users_id: event.user_main.id)

                return LC::Response.service(true, event)
            end

            return LC::Response.service(false, event)
        end

        def self.find(current_user, events_id)
            # This method is not going to return the event if is not accessible by the current user.
            # That means that the user is not the owner or attendant of the event.

            # Not accesing from current_user to avoid ignoring events where user is attendant
            events = CloudDriver::Event

            # Getting events from the calendars where the user is the owner
            my_events = events.joins(:calendar).where("cloud_driver_calendars.user_main_id = ?", current_user.id)

            # Getting events where the user is invited
            invited_events = events.joins("inner join cloud_driver_event_attendants cdea on cdea.cloud_driver_events_id = cloud_driver_events.id and cdea.users_id = #{current_user.id}")

            # Looking for the event with the id provided
            event = my_events.union(invited_events).find_by_id(events_id)

            # Returning the event
            return LC::Response.service(false) unless event
            return LC::Response.service(true, event)
        end

        def self.update(current_user, events_id, event_params)
            # Looking for the event
            event_response = self.find(current_user, events_id)

            event = event_response.payload if event_response.successful?
            return LC::Response.service(false) unless event

            # Checking permissions for the current_user
            return LC::Response.service(false) unless event.is_editable_by?(current_user)

            old_attributes = event.attributes

            if event.update(event_params)
                new_attributes = event.attributes
                Event.log_activity_update(current_user, event, old_attributes, new_attributes)
                Workflow::Action.execute_actions(current_user, event, old_attributes, new_attributes)

                return LC::Response.service(true, event)
            end

            return LC::Response.service(false, event)
        end

        def self.destroy(current_user, events_id)
            # Looking for the event
            event_response = self.find(current_user, events_id)

            event = event_response.payload if event_response.successful?
            return LC::Response.service(false) unless event

            # Checking permissions for the current_user
            return LC::Response.service(false) unless event.is_editable_by?(current_user)

            # Destroying event
            if event.destroy
                Event.log_activity_destroy(current_user, event)
                return LC::Response.service(true)
            end

            return LC::Response.service(false, event)
        end

    end
end
