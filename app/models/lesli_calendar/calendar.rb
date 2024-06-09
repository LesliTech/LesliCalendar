module LesliCalendar
    class Calendar < ApplicationRecord
        belongs_to :account
        has_many :events, foreign_key: "calendar_id"
    end
end
