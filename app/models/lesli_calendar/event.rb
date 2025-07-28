module LesliCalendar
    class Event < ApplicationRecord
        belongs_to :calendar
        belongs_to :account
        belongs_to :user, class_name: "Lesli::User"

        enum :status, {
            :draft => 'draft', 
            :proposal => 'proposal', 
            :approved => 'approved'
        }
    end
end
