module CloudDriver
    class Event < ApplicationRecord
        belongs_to :account,    foreign_key: "cloud_driver_accounts_id"
        belongs_to :calendar,   foreign_key: "cloud_driver_calendars_id"
        belongs_to :user,       foreign_key: "users_id", class_name: '::User', optional: true
        belongs_to :model,      polymorphic: true
        belongs_to :organizer,  class_name: '::User'

        has_one :detail, inverse_of: :event, autosave: true, foreign_key: "cloud_driver_events_id", dependent: :destroy
        accepts_nested_attributes_for :detail, update_only: true

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
            .where("cloud_driver_events.id = #{id}")
            .first

            {
                id: id,
                model_id: model_id,
                model_type: model_type,
                users_id: users_id,
                detail_attributes: data   
            }
        end

        def self.log_activities_after_creation(current_user, event)
            # Add an activity for the newly created event
            event.activities.create(
                users_id: current_user.id,
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
    end
end
