module CloudDriver
    class Event < CloudObject
        belongs_to  :account,        foreign_key: "cloud_driver_accounts_id"
        belongs_to  :user_creator,   foreign_key: "users_id",        class_name: "::User", optional: true
        belongs_to  :user_main,      foreign_key: "user_main_id",   class_name: "::User"
        belongs_to  :status,         foreign_key: "cloud_driver_workflow_statuses_id",   class_name: "Workflow::Status", optional: true
        belongs_to  :type,           foreign_key: "cloud_driver_catalog_event_types_id", class_name: "Catalog::EventType", optional: true

        belongs_to  :calendar,       foreign_key: "cloud_driver_calendars_id"
        belongs_to  :model,          polymorphic: true, optional: true

        has_one     :detail, inverse_of: :event, autosave: true, foreign_key: "cloud_driver_events_id"
        accepts_nested_attributes_for :detail, update_only: true

        has_many :attendants,   foreign_key: "cloud_driver_events_id"
        has_many :files,        foreign_key: "cloud_driver_events_id"
        has_many :activities,   foreign_key: "cloud_driver_events_id"
        has_many :discussions,  foreign_key: "cloud_driver_events_id"
        has_many :subscribers,  foreign_key: "cloud_driver_events_id"

        after_create :verify_date

        def self.index(current_user, query)
            Calendar.show(current_user, query)
        end

        def show(current_user = nil)
            data = Event
            .joins(:detail)
            .select(:title, :description, :event_date, :time_start, :time_end, :location, :budget, :url, :public)
            .where("cloud_driver_events.id = ?", id)
            .first

            model_global_identifier = nil
            model_global_identifier = model.global_identifier if model

            {
                id: id,
                model_id: model_id,
                model_type: model_type,
                editable: self.is_editable_by?(current_user),
                model_global_identifier: model_global_identifier,
                users_id: users_id,
                user_main_id: user_main_id,
                organizer_name: user_main.full_name,
                cloud_driver_catalog_event_types_id: cloud_driver_catalog_event_types_id,
                detail_attributes: data
            }
        end

        def attendant_list
            attendants.joins(:user).select(
                :id, 
                :users_id,
                :email, 
                :name, 
                LC::Date2.new.date.db_column(:confirmed_at, "cloud_driver_event_attendants")
            )
        end

        def download
            url = "#{Rails.configuration.default_url}/crm/calendar?event_id=#{id}"
            event_template = IO.binread("#{Rails.root}/storage/keep/mails/event.ics")
            organizer = self.user_main

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


        def self.log_activity_create_attendant(current_user, event, attendant)
            event.activities.create(
                user_creator: current_user,
                category: "action_create_attendant",
                description: attendant.user.full_name,
                value_to: attendant.user.full_name
            )
        end

        def self.with_deadline(current_user, query, calendar)
            driver_events = calendar.events.joins(:detail)
            .joins("left join cloud_driver_event_attendants cdea on cdea.cloud_driver_events_id = cloud_driver_events.id and cdea.users_id = #{current_user.id}")
            .left_joins(:type)
            .select(
                :id,
                :title,
                :description,
                :event_date,
                :time_start,
                :time_end,
                "(cdea.users_id = #{current_user.id}) as is_attendant",
                "cloud_driver_catalog_event_types.name as event_type"
            )
            .where("
                cloud_driver_events.user_main_id = :user
                or cloud_driver_events.users_id = :user
                or cloud_driver_event_details.public = true", { user: current_user.id }
            )

            driver_events.order("event_date")
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
