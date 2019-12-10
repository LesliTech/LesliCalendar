module CloudDriver
    class Calendar < ApplicationRecord
        belongs_to :account, foreign_key: "cloud_driver_accounts_id"

        has_many :events, foreign_key: "cloud_driver_calendars_id"

        has_one :detail, foreign_key: "cloud_driver_calendars_id", dependent: :delete, inverse_of: :calendar, autosave: true
        accepts_nested_attributes_for :detail

        scope :default, -> { joins(:detail).where("cloud_driver_calendar_details.default = ?", true).select(:id, :name).first }

    end
end
