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

        def as_json(options = {})
            {
                id: id,
                title: title,
                start: start_at.iso8601, # FullCalendar expects ISO8601
                end: end_at.present? ? end_at.iso8601 : nil, # Handle optional end_at
                url: url, # Optional: if you want a link on the event
                classNames: ["lesli-calendar"],
                # All other custom fields go into extendedProps
                extendedProps: {
                    description: description,
                    location: location,
                    status: status,
                    public: public
                }
            }
        end
    end
end
