module LesliCalendar
    class Calendar < ApplicationRecord
        belongs_to :account
    end
end
