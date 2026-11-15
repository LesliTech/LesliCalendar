module LesliCalendar
    class Event::UserInvitation < ActiveRecord::Base
        belongs_to :event, class_name: "LesliCalendar::Event", inverse_of: :user_invitations
        belongs_to :user, class_name: "Lesli::User"
        validates :user_id, uniqueness: { scope: :event_id }
        validate :recipient_belongs_to_event_account

        private

        def recipient_belongs_to_event_account
            return unless event && user

            errors.add(:user, :invalid) unless user.account_id == event.account.account_id
        end
    end
end
