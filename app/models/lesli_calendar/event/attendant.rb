module LesliCalendar
    # One current response per user. Declining updates it rather than soft-deleting it.
    class Event::Attendant < ActiveRecord::Base
        belongs_to :event, class_name: "LesliCalendar::Event", inverse_of: :attendants
        belongs_to :user, class_name: "Lesli::User"

        validates :user_id, uniqueness: { scope: :event_id }
        validates :responded_at, presence: true, if: -> { response_accepted? || response_declined? }
        validates :responded_at, absence: true, if: :response_pending?
        validate :user_belongs_to_event_account
        validate :response_date_is_valid

        enum :response, { 
            pending: "pending", 
            accepted: "accepted", 
            declined: "declined" 
        }, default: :pending, prefix: true, validate: true

        private

        def user_belongs_to_event_account
            return unless event && user

            errors.add(:user, :invalid) unless user.account_id == event.account.account_id
        end

        def response_date_is_valid
            errors.add(:responded_at, :invalid) if responded_at_before_type_cast.present? && responded_at.nil?
        end
    end
end
