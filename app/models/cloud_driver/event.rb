module CloudDriver
    class Event < ApplicationRecord

        acts_as_paranoid

        belongs_to :account,    foreign_key: "cloud_driver_accounts_id"
        belongs_to :calendar,   foreign_key: "cloud_driver_calendars_id"
        belongs_to :user,       foreign_key: "users_id", class_name: '::User', optional: true
        belongs_to :model,      polymorphic: true, optional: true
        belongs_to :organizer,  class_name: '::User'

        has_one :detail, inverse_of: :event, autosave: true, foreign_key: "cloud_driver_events_id"
        accepts_nested_attributes_for :detail, update_only: true

        has_many :attendants, foreign_key: "cloud_driver_events_id"
        has_many :files, foreign_key: "cloud_driver_events_id"
        has_many :activities, foreign_key: "cloud_driver_events_id"

        enum event_type: {
            kuv_with_kop: 'kuv_with_kop',
            kuv_dlgag: 'kuv_dlgag', 
            fair_with_kop: 'fair_with_kop', 
            fair_dlgag: 'fair_dlgag',
            digital_sales_support: 'digital_sales_support',
            internal_event: 'internal_event',
            kop_acquisition: 'kop_acquisition',
            kop_visit: 'kop_visit',
            kop_qualification: 'kop_qualification',
            kop_customer_appointment: 'kop_customer_appointment',
            kop_phone_appointment: 'kop_phone_appointment',
            kop_roundtable: 'kop_roundtable',
            marketing_measures: 'marketing_measures',
            sales_jf: 'sales_jf',
            phone_jf: 'phone_jf',
            meeting_intern: 'meeting_intern',
            intern_telephone_conference: 'meeting_intern',
            notary_appointment: 'notary_appointment'
        }

        def show
            data = Event
            .joins(:detail)
            .select(:title, :description, :time_start, :time_end, :location, :url, :event_type, :public)
            .where("cloud_driver_events.id = ?", id)
            .first

            {
                id: id,
                model_id: model_id,
                model_type: model_type,
                users_id: users_id,
                organizer_name: organizer.name,
                detail_attributes: data   
            }
        end

        # @todo Add role once CloudLock is working
        def attendant_list
            attendants.map do |attendant|
                user = attendant.user
                {
                    name: user.name,
                    email: user.email,
                    users_id: user.id,
                    id: attendant.id
                }
            end
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
                description: attendant.user.name,
                value_to: attendant.user.name
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
                name: attendant.user.name,
                title: event.detail.title,
                organizer_name: organizer.name,
                organizer_email: organizer.email,
                time_start: event_detail.time_start,
                time_end: event_detail.time_end,
                title: event_detail.title,
                location: event_detail.location,
                description: event_detail.description,
                href: "/crm/calendar?event_id=#{attendant.event.id}"
            }

            ::DriverMailer.event_attendant_new(receipt, "You have been invited a an event", data).deliver_now
        end

        #############################
        # Notification methods
        #############################

        # sends an web to the assigned user when the attendant is created
        def self.send_notification_create_attendant(attendant)
            receipt = attendant.user.email
            event = attendant.event

            data = {
                name: attendant.user.name,
                title: event.detail.title,
                href: "/crm/calendar?event_id=#{attendant.event.id}"
            }

            ::Courier::Bell::Notification::Web.new(
                attendant.user,
                "event_attendant_created",
                {
                    body: attendant.event.detail.description,
                    href: "/crm/calendar?event_id=#{attendant.event.id}"
                }
            )
        end


    end
end
