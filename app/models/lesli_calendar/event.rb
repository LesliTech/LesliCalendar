require "uri"

module LesliCalendar
    class Event < ApplicationRecord
        belongs_to :calendar, class_name: "LesliCalendar::Calendar", inverse_of: :events
        belongs_to :account, class_name: "LesliCalendar::Account", inverse_of: :events
        # The author is the organizer; invitations and responses are separate records.
        belongs_to :user, class_name: "Lesli::User"
        has_many :user_invitations, class_name: "LesliCalendar::Event::UserInvitation", inverse_of: :event
        has_many :role_invitations, class_name: "LesliCalendar::Event::RoleInvitation", inverse_of: :event
        has_many :invited_users, through: :user_invitations, source: :user
        has_many :invited_roles, through: :role_invitations, source: :role
        has_many :attendants, class_name: "LesliCalendar::Event::Attendant", inverse_of: :event

        # Cancellation and soft deletion retain invitations and response history.
        # No dependent destruction: these rows are not copies of event visibility.
        enum :status, { scheduled: "scheduled", cancelled: "cancelled" }, default: :scheduled, validate: true
        attribute :public, :boolean, default: false

        normalizes :title, with: ->(value) { value.strip }
        normalizes :url, with: ->(value) { value.strip.presence }
        validates :title, :start_at, :end_at, presence: true
        validates :public, inclusion: { in: [true, false] }
        validates :end_at, comparison: { greater_than: :start_at }, if: -> { start_at.present? && end_at.present? }
        validate :dates_are_valid
        validate :relations_belong_to_account
        validate :url_is_supported

        # Visibility is independent from acceptance. Every branch keeps the account boundary.
        def self.visible_to(user)
            records = where(account_id: user.account.calendar.id)
            direct = Event::UserInvitation.where(user_id: user.id).select(:event_id)
            visible = records.where(user_id: user.id).or(records.where(public: true))
                .or(records.where(id: direct))
            if defined?(LesliShield)
                roles = user.roles.where(account_id: user.account_id).select(:id)
                invited = Event::RoleInvitation.where(role_id: roles).select(:event_id)
                visible = visible.or(records.where(id: invited))
            end
            visible
        end

        # Submitted selections stay on the record when a transaction fails.
        attr_writer :user_ids, :role_ids

        def user_ids
            @user_ids || user_invitations.pluck(:user_id)
        end

        def role_ids
            @role_ids || role_invitations.pluck(:role_id)
        end

        def clear_invitation_selection
            @user_ids = @role_ids = nil
        end

        private

        # Rails casts malformed datetimes to nil; do not silently accept that input.
        def dates_are_valid
            [:start_at, :end_at].each do |attribute|
                if public_send("#{attribute}_before_type_cast").present? && public_send(attribute).nil?
                    errors.add(attribute, :invalid)
                end
            end
        end

        def relations_belong_to_account
            return unless account

            errors.add(:calendar, :invalid) if calendar && calendar.account_id != account.id
            errors.add(:user, :invalid) if user && user.account_id != account.account_id
        end

        def url_is_supported
            return if url.nil?

            destination = URI.parse(url)
            internal = destination.relative? && url.start_with?("/") && !url.start_with?("//")
            web = destination.is_a?(URI::HTTP) && destination.host.present?
            errors.add(:url, :invalid) unless internal || web
        rescue URI::InvalidURIError
            errors.add(:url, :invalid)
        end
    end
end
