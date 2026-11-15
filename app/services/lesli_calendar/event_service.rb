=begin 

Lesli

Copyright (c) 2025, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliCalendar
    class EventService < Lesli::ApplicationLesliService

        EDITABLE_ATTRIBUTES = %i[title description location start_at end_at public url].freeze

        def index
            response(Event.visible_to(current_user).order(:start_at, :id))
        end

        def show(id)
            response(Event.visible_to(current_user).find(id))
        end

        alias_method :find, :show

        def my_calendar
            response(personal_events.order(:start_at, :id))
        end

        def pending_invitations
            visible = visible_events
            direct = Event::UserInvitation.where(user_id: current_user.id).select(:event_id)
            invited = visible.where(id: direct)
            if defined?(LesliShield)
                roles = current_user.roles.where(account_id: current_user.account_id).select(:id)
                role_events = Event::RoleInvitation.where(role_id: roles).select(:event_id)
                invited = invited.or(visible.where(id: role_events))
            end

            # Pending responses also include public participants asked to reconfirm a new time.
            events = invited.or(visible.where(id: response_event_ids(:pending)))
                .where.not(user_id: current_user.id)
                .where.not(id: response_event_ids([:accepted, :declined]))
                .where("end_at > ?", Time.current).order(:start_at, :id)
            response(events)
        end

        def available_events
            events = visible_events.where(public: true).where.not(user_id: current_user.id)
                .where.not(id: response_event_ids(:accepted))
                .where("end_at > ?", Time.current).order(:start_at, :id)
            response(events)
        end

        def create(attributes)
            event = current_user.account.calendar.events.build(
                calendar: current_user.account.calendar.default_calendar, user: current_user
            )
            persist(event, attributes)
        end

        def update(attributes)
            # Use a fresh account/organizer-scoped lookup, not a caller-supplied record.
            persist(owned_events.find(resource.id), attributes)
        end

        def destroy
            event = owned_events.find(resource.id)
            event.with_lock do
                owned_events.find(event.id)
                event.destroy!
            end
            response(event)
        end

        def calendar_entries
            if query[:start].present? || query[:end].present?
                # FullCalendar includes adjacent days and uses an exclusive end boundary.
                start_at = Time.iso8601(query[:start].to_s).utc
                end_at = Time.iso8601(query[:end].to_s).utc
            else
                start_at = query[:month].present? ? Time.zone.iso8601("#{query[:month]}-01") : Time.current.beginning_of_month
                end_at = start_at.next_month
            end

            events = personal_events.where("start_at < ? AND end_at > ?", end_at, start_at)
                .order(:start_at, :id).map { |event| calendar_entry(event) }

            tickets = Lesli::Courier.new(:lesli_support, [], fallback_on_error: true)
                .from(:ticket_service, current_user, { start: start_at, end: end_at })
                .call(:calendar_entries)

            events + tickets
        end

        def agenda(view: "upcoming", from: nil, to: nil)
            now = Time.current
            records = case view
                when "mine" then my_calendar.result
                when "pending" then pending_invitations.result
                when "available" then available_events.result
            end
            if view == "mine"
                # Include events overlapping the selected dates, in the user's local timezone.
                records = records.where("end_at > ?", Date.iso8601(from).in_time_zone) if from.present?
                records = records.where("start_at < ?", Date.iso8601(to).next_day.in_time_zone) if to.present?
            end
            entries = records ? records.map { |event| calendar_entry(event) } : calendar_entries
            events = entries.filter_map do |entry|
                start_at = entry[:start].in_time_zone
                end_at = entry[:end]&.in_time_zone || start_at
                next if view == "upcoming" && end_at <= now

                {
                    title: entry[:title], url: entry[:url], start_at: start_at, end_at: end_at,
                    source: entry.dig(:extendedProps, :source), status: entry.dig(:extendedProps, :status),
                    record_id: entry.dig(:extendedProps, :record_id), class_name: entry[:className],
                    description: ActionController::Base.helpers.strip_tags(entry.dig(:extendedProps, :description).to_s).truncate(88)
                }
            end

            events.sort_by { |event| event[:start_at] }.group_by { |event| event[:start_at].to_date }.transform_values do |day_events|
                date = day_events.first[:start_at]
                {
                    day_name: date.to_date == now.to_date ? I18n.t("lesli_calendar.agendas.today") : I18n.l(date.to_date, format: "%a"),
                    day_number: date.strftime("%d"),
                    events: day_events
                }
            end
        end

        private

        def calendar_entry(event)
            {
                id: "lesli_calendar:event:#{event.id}", title: event.title,
                start: event.start_at.utc, end: event.end_at.utc,
                url: event.url, className: "lesli-calendar",
                extendedProps: { record_id: event.id, description: event.description, source: "calendar", status: event.status }
            }.compact
        end

        def visible_events
            Event.visible_to(current_user).where(status: :scheduled)
        end

        def personal_events
            visible = visible_events
            visible.where(user_id: current_user.id).or(visible.where(id: response_event_ids(:accepted)))
        end

        def response_event_ids(value)
            Event::Attendant.where(user_id: current_user.id, response: value).select(:event_id)
        end

        def owned_events
            current_user.account.calendar.events.where(user_id: current_user.id)
        end

        def persist(event, attributes)
            attributes = attributes.to_h.symbolize_keys
            Event.transaction do
                if event.persisted?
                    event.lock!
                    # A deletion may have committed while this request waited for the lock.
                    owned_events.find(event.id)
                end
                event.assign_attributes(attributes.slice(*EDITABLE_ATTRIBUTES))
                assign_invitations(event, attributes)
                event.valid?
                validate_invitations(event, attributes)
                if event.cancelled?
                    event.errors.add(:base, I18n.t("lesli_calendar.events.errors.cancelled"))
                end
                raise ActiveRecord::RecordInvalid.new(event) if event.errors.any?

                rescheduled = event.persisted? && (event.start_at_changed? || event.end_at_changed?)
                event.save!
                replace_invitations(event.user_invitations, :user_id, event.user_ids)
                replace_invitations(event.role_invitations, :role_id, event.role_ids)
                if rescheduled
                    # Preserve declined responses. Former public participants also become pending.
                    event.attendants.where(response: :accepted).each do |attendant|
                        attendant.update!(response: :pending, responded_at: nil)
                    end
                end
                event.clear_invitation_selection
            end
            response(event)
        rescue ActiveRecord::RecordInvalid => exception
            event.errors.add(:base, exception.record.errors.full_messages.to_sentence) unless exception.record == event
            error(event.errors.full_messages.to_sentence)
            response(event)
        end

        def assign_invitations(event, attributes)
            [:user_ids, :role_ids].each do |key|
                next unless attributes.key?(key)

                event.public_send("#{key}=", Array(attributes[key]).reject(&:blank?).map(&:to_s).uniq)
            end
        end

        def validate_invitations(event, attributes)
            valid_users = current_user.account.users.where(id: event.user_ids).pluck(:id).map(&:to_s)
            valid_roles = current_user.account.roles.where(id: event.role_ids).pluck(:id).map(&:to_s)
            if (event.user_ids.map(&:to_s) - valid_users).any?
                event.errors.add(:base, I18n.t("lesli_calendar.events.errors.invalid_users"))
            end
            if (event.role_ids.map(&:to_s) - valid_roles).any? ||
                (attributes.key?(:role_ids) && event.role_ids.any? && !defined?(LesliShield))
                event.errors.add(:base, I18n.t("lesli_calendar.events.errors.invalid_roles"))
            end
        end

        def replace_invitations(association, foreign_key, ids)
            existing_ids = association.pluck(foreign_key).map(&:to_s)
            (ids.map(&:to_s) - existing_ids).each { |id| association.create!(foreign_key => id) }
            association.where.not(foreign_key => ids).each(&:destroy!)
        end

    end
end
