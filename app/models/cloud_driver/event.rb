module CloudDriver
    class Event < ApplicationRecord
        belongs_to :calendar, foreign_key: "cloud_driver_calendars_id"
        belongs_to :user,       class_name: '::User', foreign_key: "users_id", optional: true
        belongs_to :model,      polymorphic: true
        belongs_to :organizer,    class_name: '::User'

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
    end
end
