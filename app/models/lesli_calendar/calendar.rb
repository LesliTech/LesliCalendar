module LesliCalendar
    class Calendar < ApplicationRecord
        belongs_to :account, class_name: "LesliCalendar::Account", inverse_of: :calendars
        has_many :events, class_name: "LesliCalendar::Event", inverse_of: :calendar

        attribute :name, :string, default: "default"
        attribute :color, :string, default: "0d52bf"
        normalizes :name, with: ->(value) { value.strip }
        validates :name, presence: true, uniqueness: { scope: :account_id, conditions: -> { where(deleted_at: nil) } }
        validates :color, format: { with: /\A[0-9a-fA-F]{6}\z/ }
    end
end
