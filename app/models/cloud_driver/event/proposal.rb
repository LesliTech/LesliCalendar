=begin
Copyright (c) 2022, all rights reserved.

All the information provided by this platform is protected by international laws related  to
industrial property, intellectual property, copyright and relative international laws.
All intellectual or industrial property rights of the code, texts, trade mark, design,
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·

=end
module CloudDriver
    class Event::Proposal < ApplicationRecord
        belongs_to :event, class_name: "CloudDriver::Event", foreign_key: "cloud_driver_events_id"
        belongs_to :user, class_name: "::User", foreign_key: "users_id"

        validate :required_creation_attributes
        after_create :initialize_event_proposal

        def self.index(current_user, query)
            []
        end

        def show(current_user, query)
            self
        end

        protected

        # @return [void] adds an error if the event is not valid
        def required_creation_attributes
            # Event date is required
            errors.add(:date, "cannot be empty") unless self.event_date.present?

            # Event proposal is only valid if the event is a proposal
            errors.add(:event, "is not a proposal anymore") unless self.event.is_proposal?
        end

        # @return [void] set default values for the event proposal
        def initialize_event_proposal
            self.update(time_start: self.event_date) if self.time_start.blank?

            self.update(time_end: self.time_start + self.event.estimated_mins_durations.minutes) if self.time_end.blank?
        end

    end
end
