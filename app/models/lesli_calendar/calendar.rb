module LesliCalendar
    class Calendar < ApplicationRecord
        belongs_to :account, class_name: "LesliCalendar::Account"
        has_many :events, foreign_key: "calendar_id"
    end
end
