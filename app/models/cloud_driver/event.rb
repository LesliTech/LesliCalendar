module CloudDriver
    class Event < CloudObject::Base
        belongs_to  :account,        foreign_key: "cloud_driver_accounts_id"
        belongs_to  :user_creator,   foreign_key: "users_id",        class_name: "::User", optional: true
        belongs_to  :user_main,      foreign_key: "users_main_id",   class_name: "::User"
        belongs_to  :status,         foreign_key: "cloud_driver_workflow_statuses_id", class_name: "Workflow::Status", optional: true

        belongs_to  :calendar,       foreign_key: "cloud_driver_calendars_id"
        belongs_to  :model,          polymorphic: true, optional: true

        has_one     :detail, inverse_of: :event, autosave: true, foreign_key: "cloud_driver_events_id"
        accepts_nested_attributes_for :detail, update_only: true

        has_many :attendants, foreign_key: "cloud_driver_events_id"
        has_many :files, foreign_key: "cloud_driver_events_id"
        has_many :activities, foreign_key: "cloud_driver_events_id"
        has_many :discussions, foreign_key: "cloud_driver_events_id"

        enum event_type: {
            kuv_with_kop: "kuv_with_kop",
            kuv_dlgag: "kuv_dlgag", 
            fair_with_kop: "fair_with_kop", 
            fair_dlgag: "fair_dlgag",
            digital_sales_support: "digital_sales_support",
            internal_event: "internal_event",
            kop_acquisition: "kop_acquisition",
            kop_visit: "kop_visit",
            kop_qualification: "kop_qualification",
            kop_customer_appointment: "kop_customer_appointment",
            kop_phone_appointment: "kop_phone_appointment",
            kop_roundtable: "kop_roundtable",
            marketing_measures: "marketing_measures",
            sales_jf: "sales_jf",
            phone_jf: "phone_jf",
            meeting_intern: "meeting_intern",
            intern_telephone_conference: "intern_telephone_conference",
            notary_appointment: "notary_appointment"
        }

        # @return [Array] An array of users, the relevant user for a task
        # @description Returns the relevant users for the task. In this case, the creator and the
        #   assigned users. This list is ordered, the first one is always the most important and will be
        #   the only one used for object level permission verification based on the role_detail.object_level_permission field value
        # @example
        #   creator_user = User.find(1)
        #   assigned_user = User.find(2)
        #   account = Account.find(1)
        #   task = account.focus.tasks.create!(creator: creator_user, user: assigned_user, detail_attributes(....))
        #   task.relevant_users    # Will return an array with both users as the relevant users
        def relevant_users
            return [organizer, user]
        end

        def show(current_user = nil)
            data = Event
            .joins(:detail)
            .select(:title, :description, :event_date, :time_start, :time_end, :location, :url, :event_type, :public)
            .where("cloud_driver_events.id = ?", id)
            .first

            model_global_identifier = nil
            model_global_identifier = model.global_identifier if model

            {
                id: id,
                model_id: model_id,
                model_type: model_type,
                editable: self.is_editable_by?(current_user),
                model_global_identifier: model_global_identifier, # If the model is projects, this will be used in the url
                users_id: users_id,
                organizer_id: organizer_id,
                organizer_name: organizer.full_name,
                detail_attributes: data   
            }
        end

        # @todo Add role once CloudLock is working
        def attendant_list
            attendants.map do |attendant|
                user = attendant.user
                {
                    name: user.full_name,
                    role: user.role.detail.name,
                    email: user.email,
                    users_id: user.id,
                    id: attendant.id
                }
            end
        end

        def download()
            url = "#{Rails.configuration.default_url}/crm/calendar?event_id=#{id}"
            event_template = IO.binread("#{Rails.root}/storage/keep/mails/event.ics")

            event_template = event_template
            .sub("{{organizer_name}}", ( self.organizer.full_name || "").strip )
            .sub("{{organizer_email}}", ( self.organizer.email || "").strip )
            .sub("{{dtstamp}}", ( self.detail.event_date.strftime("%Y%m%d") ).strip )
            .sub("{{description}}",( self.detail.description || "").strip )
            .sub("{{summary}}", ( self.detail.title || "").strip )
            .sub("{{location}}", ( self.detail.location || "").strip )
            .sub("{{dtstart}}", ( self.detail.time_start.strftime("%Y%m%dT%H%M%S") || self.detail.event_date.strftime("%Y%m%d") ).strip )
            .sub("{{dtend}}", ( self.detail.time_end.strftime("%Y%m%dT%H%M%S") || "").strip )
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
                user: current_user,
                category: "action_create"
            )

            # Adding an activity to the parent model if this event (if it exists)
            case event.model_type
                # Adding an activity to the project throught the courier
                when "CloudHouse::Project"
                    activity_params = {
                        category: "action_create_event",
                        description: event.detail.event_type,
                        users_id: current_user.id,
                        cloud_house_projects_id: event.model_id
                    }
                    ::Courier::House::Project.create_activity(activity_params)
            end
        end
        

        def self.log_activity_create_attendant(current_user, event, attendant)
            event.activities.create(
                user: current_user,
                category: "action_create_attendant",
                description: attendant.user.full_name,
                value_to: attendant.user.full_name
            )
        end

        #############################
        # Email methods
        #############################

        # sends an email to the assigned user when the attendant is created
        def self.send_email_create_attendant(attendant)
            receipt = attendant.user.email
            event = attendant.event
            organizer = event.organizer
            event_detail = event.detail

            data = {
                name: attendant.user.full_name,
                organizer_name: organizer.full_name,
                organizer_email: organizer.email,
                event_date: event_detail.event_date,
                time_start: event_detail.time_start || event_detail.event_date,
                time_end: event_detail.time_end || event_detail.event_date + 1.days,
                title: event_detail.title,
                location: event_detail.location,
                description: event_detail.description,
                href: "/crm/calendar?event_id=#{attendant.event.id}"
            }

            ::DriverMailer.event_attendant_new(receipt, I18n.t("driver.events.email_new_attendant_subject"), data).deliver_now
        end

        #############################
        # Notification methods
        #############################

        # sends an web to the assigned user when the attendant is created
        def self.send_notification_create_attendant(attendant)
            receipt = attendant.user.email
            event = attendant.event

            data = {
                name: attendant.user.full_name,
                title: event.detail.title,
                href: "/crm/calendar?event_id=#{attendant.event.id}"
            }

            ::Courier::Bell::Notification::Web.new(
                attendant.user,
                "event_attendant_created",
                {
                    href: "/crm/calendar?event_id=#{attendant.event.id}"
                }
            )
        end


    end
end
