module LesliCalendar
    class Event::RoleInvitation < ActiveRecord::Base
        belongs_to :event, class_name: "LesliCalendar::Event", inverse_of: :role_invitations
        belongs_to :role, class_name: "Lesli::Role"
        validates :role_id, uniqueness: { scope: :event_id }
        validate :recipient_belongs_to_event_account

        private

        def recipient_belongs_to_event_account
            return unless event && role

            errors.add(:role, :invalid) unless role.account_id == event.account.account_id
        end
    end
end
