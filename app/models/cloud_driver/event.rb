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
    class Event < CloudObject
        belongs_to  :account,        foreign_key: "cloud_driver_accounts_id"
        belongs_to  :user_creator,   foreign_key: "users_id",        class_name: "::User", optional: true
        belongs_to  :user_main,      foreign_key: "user_main_id",   class_name: "::User", optional: true
        belongs_to  :status,         foreign_key: "cloud_driver_workflow_statuses_id",   class_name: "Workflow::Status", optional: true
        belongs_to  :type,           foreign_key: "cloud_driver_catalog_event_types_id", class_name: "Catalog::EventType", optional: true

        belongs_to  :calendar,       foreign_key: "cloud_driver_calendars_id"
        belongs_to  :model,          polymorphic: true, optional: true

        # In case the main user is deleted
        belongs_to :user_main_including_deleted, foreign_key: "user_main_id",   class_name: "::User", optional: true, with_deleted: true

        has_one     :detail, inverse_of: :event, autosave: true, foreign_key: "cloud_driver_events_id"
        accepts_nested_attributes_for :detail, update_only: true

        has_many :files,        foreign_key: "cloud_driver_events_id"
        has_many :guests,       foreign_key: "cloud_driver_events_id"
        has_many :attendants,   foreign_key: "cloud_driver_events_id"
        has_many :proposals,    foreign_key: "cloud_driver_events_id"
        has_many :activities,   foreign_key: "cloud_driver_events_id"
        has_many :discussions,  foreign_key: "cloud_driver_events_id"
        has_many :subscribers,  foreign_key: "cloud_driver_events_id"

        before_validation :set_workflow, on: :create
        after_create :verify_date

        # @return [Hash] The default calendar events
        def self.index(current_user, query)
            Courier::Driver::Calendar.show(current_user, query)
        end

        def show(current_user = nil)
            {
                id: self.id,
                model_id: self.model_id,
                model_type: self.model_type,
                editable: self.is_editable_by?(current_user),
                is_proposal: self.is_proposal,
                estimated_mins_durations: self.estimated_mins_durations,
                model_global_identifier: self.model ? self.model.global_identifier : nil,
                total_invites_count: self.attendants.count + self.guests.count,
                confirmed_invites_count: self.attendants.where("confirmed_at is not ?", nil).count + self.guests.where("confirmed_at is not ?", nil).count,
                users_id: self.users_id,
                user_main_id: self.user_main_id,
                organizer_name: self.user_main_including_deleted ? self.user_main_including_deleted.full_name : "",
                cloud_driver_catalog_event_types_id: self.cloud_driver_catalog_event_types_id,
                cloud_driver_calendars_id: self.cloud_driver_calendars_id,
                detail_attributes: self.detail.slice(:id, :title, :description, :event_date, :time_start, :time_end, :location, :budget, :url, :public, :real_cost, :signed_up_count, :showed_up_count)
            }
        end

        # @return [Array] of events on my calendar and the ones I am invited to of the same calendar source
        def self.with_deadline(current_user, query, calendar)
            # If filter dates not provided, force use current month
            if query[:filters][:start_date].blank? or query[:filters][:end_date].blank?
                query[:filters][:start_date] = query[:filters][:start_date] || Time.now.beginning_of_month.to_s
                query[:filters][:end_date] = query[:filters][:end_date] || Time.parse(query[:filters][:start_date]).end_of_month.to_s
            end

            # Getting all my events
            my_calendar_events = calendar.events.joins(:detail).left_joins(:type).where(
                "cloud_driver_event_details.event_date >= ?", query[:filters][:start_date]
            ).where(
                "cloud_driver_event_details.event_date <= ? ", query[:filters][:end_date]
            ).select(
                "cloud_driver_events.id",
                :title,
                :description,
                "event_date as date",
                "time_start as start",
                "time_end + interval '1 second' as end", # The calendar will crash if start and end dates are the same
                :location,
                "false as is_attendant",
                "cloud_driver_catalog_event_types.name as event_type",
            )

            # Getting events of the same calendar source of other users where I am an attendant
            my_attendant_events = CloudDriver::Event.joins(:calendar, :detail).left_joins(:type).joins(
                "inner join cloud_driver_event_attendants cdea on cdea.cloud_driver_events_id = cloud_driver_events.id and cdea.users_id = #{current_user.id}"
            ).where(
                "cloud_driver_calendars.source_code = ?", calendar.source_code
            ).where(
                "cloud_driver_event_details.event_date >= ?", query[:filters][:start_date]
            ).where(
                "cloud_driver_event_details.event_date <= ? ", query[:filters][:end_date]
            ).select(
                "cloud_driver_events.id",
                :title,
                :description,
                "event_date as date",
                "time_start as start",
                "time_end + interval '1 second' as end", # The calendar will crash if start and end dates are the same
                :location,
                "true as is_attendant",
                "cloud_driver_catalog_event_types.name as event_type",
            )

            # Union of my events and the ones I am invited to
            driver_events = my_calendar_events.union(my_attendant_events)

            driver_events.order("date")
        end

        def attendant_list
            attendants.joins(:user).select(
                :id,
                :users_id,
                :email,
                :name,
                "'attendant' as type",
                LC::Date2.new.date.db_column(:confirmed_at, "cloud_driver_event_attendants")
            ) + guests.select(
                :id,
                "NULL as users_id",
                :name,
                "'guest' as type",
                :email,
                LC::Date2.new.date.db_column(:confirmed_at)
            )
        end

        def download
            url = "#{Rails.configuration.lesli_settings["env"]["default_url"]}/crm/calendar?event_id=#{id}"
            event_template = IO.binread("#{Rails.root}/storage/keep/mails/event.ics")
            organizer = self.user_main_including_deleted

            event_template = event_template
            .sub("{{organizer_name}}", ( organizer.full_name || "").strip )
            .sub("{{organizer_email}}", ( organizer.email || "").strip )
            .sub("{{dtstamp}}", (self.detail.event_date.strftime("%Y%m%d")))
            .sub("{{description}}",( self.detail.description || "").strip )
            .sub("{{summary}}", ( self.detail.title || "").strip )
            .sub("{{location}}", ( self.detail.location || "").strip )
            .sub("{{dtstart}}", ( (self.detail.time_start || self.detail.event_date).strftime("%Y%m%dT%H%M%S")))
            .sub("{{dtend}}", ( (self.detail.time_end || self.detail.event_date).strftime("%Y%m%dT%H%M%S")))
            .sub("{{uid}}", Time.now.getutc.to_s)
            .sub("{{url}}", URI.escape(url) )

            event_template
        end

        def global_identifier(extended: false)
            return detail.title
        end

        #############################
        # Activities log methods
        #############################

        def self.log_activity_create(current_user, event)
            # Add an activity for the newly created event
            event.activities.create(
                user_creator: current_user,
                category: "action_create"
            )

            # Adding an activity to the parent model if this event (if it exists)
            case event.model_type
                # Adding an activity to the project throught the courier
                when "CloudHouse::Project"
                    activity_params = {
                        category: "action_create_event",
                        description: event.type&.name,
                        users_id: current_user.id,
                        cloud_house_projects_id: event.model_id
                    }
                    ::Courier::House::Project.create_activity(activity_params)
            end
        end

        def self.log_activity_update(current_user, event, old_attributes, new_attributes)

            if old_attributes["user_main_id"] != new_attributes["user_main_id"]
                event.activities.create(
                    user_creator: current_user,
                    category: "action_update",
                    field_name: "user_main_id",
                    value_from: ::User.with_deleted.find(old_attributes["user_main_id"]).full_name,
                    value_to:   ::User.with_deleted.find(new_attributes["user_main_id"]).full_name
                )
            end

            if old_attributes["cloud_driver_workflow_statuses_id"] != new_attributes["cloud_driver_workflow_statuses_id"]
                old_status = Workflow::Status.with_deleted.find(old_attributes["cloud_driver_workflow_statuses_id"]).name
                new_status = Workflow::Status.with_deleted.find(new_attributes["cloud_driver_workflow_statuses_id"]).name
                event.activities.create(
                    user_creator: current_user,
                    description: new_status,
                    category: "action_update",
                    field_name: "cloud_driver_workflow_statuses_id",
                    value_from: old_status,
                    value_to: new_status
                )
            end

            if old_attributes["cloud_driver_catalog_event_types_id"] != new_attributes["cloud_driver_catalog_event_types_id"]
                old_value = nil
                new_value = nil

                if old_attributes["cloud_driver_catalog_event_types_id"]
                    old_value = CloudDriver::Catalog::EventType.with_deleted.find(old_attributes["cloud_driver_catalog_event_types_id"]).name
                end

                if new_attributes["cloud_driver_catalog_event_types_id"]
                    new_value = CloudDriver::Catalog::EventType.with_deleted.find(new_attributes["cloud_driver_catalog_event_types_id"]).name
                end

                event.activities.create(
                    user_creator: current_user,
                    category: "action_update",
                    field_name: "cloud_driver_catalog_event_types_id",
                    value_from: old_value,
                    value_to: new_value
                )
            end

            if old_attributes["cloud_driver_calendars_id"] != new_attributes["cloud_driver_calendars_id"]
                old_calendar = Calendar.with_deleted.find(old_attributes["cloud_driver_calendars_id"]).name
                new_calendar = Calendar.with_deleted.find(new_attributes["cloud_driver_calendars_id"]).name
                event.activities.create(
                    user_creator: current_user,
                    description: new_calendar,
                    category: "action_update",
                    field_name: "cloud_driver_calendars_id",
                    value_from: old_calendar,
                    value_to: new_calendar
                )
            end

            old_attributes = old_attributes.except(
                "id", "created_at", "updated_at", "cloud_driver_workflow_statuses_id",
                 "cloud_driver_catalog_event_types_id", "cloud_driver_calendars_id"
            )
            old_attributes.each do |key, value|
                if value != new_attributes[key]
                    value_from = value
                    value_to = new_attributes[key]
                    value_from = LC::Date.to_string_datetime(value_from) if value_from.is_a?(Time) || value_from.is_a?(Date)
                    value_to = LC::Date.to_string_datetime(value_to) if value_to.is_a?(Time) || value_to.is_a?(Date)

                    event.activities.create(
                        user_creator: current_user,
                        category: "action_update",
                        field_name: key,
                        value_from: value_from,
                        value_to: value_to
                    )
                end
            end

        end


        def self.log_activity_create_attendant(current_user, event, attendant)
            event.activities.create(
                user_creator: current_user,
                category: "action_create_attendant",
                description: attendant.user.full_name,
                value_to: attendant.user.full_name
            )
        end

        #############################
        # Notification methods
        #############################

        # sends an web to the assigned user when the attendant is created
        def self.send_notification_create_attendant(attendant)

            url = "/driver/events/#{attendant.event.id}"

            if defined?(DeutscheLeibrenten)
                url = "/crm/calendar?event_id=#{attendant.event.id}"
            end

            attendant.user.notification("event_attendant_created", body: "", url: url)

        end

        protected

        # @return [void]
        # @description Sets the default event date if the date was not set during creation
        # @example
        #     new_event = CloudDriver::Event.create!(detail_attributes: {title: "Test event", event_type: "kuv_with_kop"})
        #     puts new_event.detail.event_date
        #     # This will display the creation time of the event
        def verify_date
            detail.update(event_date: self.created_at) unless detail.event_date
        end

    end
end
