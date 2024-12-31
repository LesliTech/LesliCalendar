module LesliCalendar
    class Event < ApplicationRecord
        belongs_to :calendar
        belongs_to :account
        belongs_to :user, class_name: "Lesli::User"
        #belongs_to :creator, class_name: "Lesli::User"
    end
end
