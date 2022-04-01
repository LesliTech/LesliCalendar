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
require 'google/apis/calendar_v3'
module CloudDriver
    class EventServices

        def self.create(current_user, event_params)

            # Validate event includes minimum required data
            if (
                event_params.dig(:detail_attributes, :title).blank? || 
                event_params.dig(:detail_attributes, :event_date).blank?)
                return LC::Response.service(false, "Missing event data")
            end

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

        def self.create_external_event(current_user, event_params)

            user_auth_provider = Courier::Lesli::Users::AuthProviders.get_user_provider(current_user.id, 'Google')

            if (user_auth_provider)
                 #Google calendar event creation
                google_event = Google::Apis::CalendarV3::Event.new(
                    summary: event_params[:detail_attributes][:title],
                    location: event_params[:detail_attributes][:location],
                    description: event_params[:detail_attributes][:description],
                    start: Google::Apis::CalendarV3::EventDateTime.new(
                        date_time: event_params[:detail_attributes][:time_start]
                    ),
                    end: Google::Apis::CalendarV3::EventDateTime.new(
                        date_time: event_params[:detail_attributes][:time_end]
                    ) 
                )
                # Initialize Google Calendar API
                service = Google::Apis::CalendarV3::CalendarService.new
                # Use google keys to authorize
                service.authorization = Google::APIClient::ClientSecrets.new(
                    { "web" =>
                        { "access_token" => user_auth_provider.access_token,
                        "refresh_token" => user_auth_provider.refresh_token,
                        "client_id" => Rails.application.credentials.dig(:providers, :google, :client_id),
                        "client_secret" => Rails.application.credentials.dig(:providers, :google, :client_secret),
                        }
                    }
                ).to_authorization
                # Request for a new aceess token just incase it expired
                service.authorization.refresh!
                # Get a list of calendars
                service.insert_event("primary", google_event)

                return LC::Response.service(true, google_event)
            end
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
