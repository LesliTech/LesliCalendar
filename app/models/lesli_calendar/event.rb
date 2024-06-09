module LesliCalendar
    class Event < ApplicationRecord
        belongs_to :calendar
    end
end
