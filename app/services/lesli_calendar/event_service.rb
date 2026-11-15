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

        class InvalidRange < ArgumentError; end

        AGENDA_PAGE_SIZE = 20
        attr_reader :agenda_next_page

        def my_calendar
            response(EventQuery.new(current_user).personal.order(:start_at, :id))
        end

        def pending_invitations
            response(EventQuery.new(current_user).pending)
        end

        def available_events
            response(EventQuery.new(current_user).available)
        end

        def calendar_entries
            # FullCalendar uses an exclusive end. A missing range defaults to this UTC month.
            start_at = range_boundary(:start) || Time.current.utc.beginning_of_month
            end_at = range_boundary(:end) || start_at.next_month
            raise InvalidRange, "Invalid calendar range" unless end_at > start_at

            events = EventQuery.new(current_user).overlapping(start_at, end_at)
            tickets = support_entries(start_at: start_at, end_at: end_at)
            entries = events.map { |event| calendar_entry(event) } + tickets
            entries.sort_by { |entry| [entry[:start], entry[:className], entry[:id]] }
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

        def agenda(page: 1)
            page = [page.to_i, 1].max
            current_time = Time.current.utc

            # Convert FullCalendar's payload into the simpler shape consumed by the agenda view.
            upcoming_events = agenda_entries(page).filter_map do |event|
                start_at = normalize_agenda_time(value_from(event, :start))
                end_at = normalize_agenda_time(value_from(event, :end))
                next if start_at.nil?
                # Deadline entries are points; local events remain visible until their end.
                finished = end_at && end_at > start_at ? end_at <= current_time : start_at < current_time
                next if finished

                extended_props = value_from(event, :extendedProps) || {}

                {
                    id: value_from(event, :id),
                    title: value_from(event, :title),
                    description: agenda_description(value_from(extended_props, :description)),
                    start_at: start_at,
                    end_at: end_at,
                    url: value_from(event, :url),
                    class_name: Array(value_from(event, :className)).join(" ")
                }
            end

            # Sorting first preserves chronological order for both days and their events.
            upcoming_events.sort_by! { |event| [event[:start_at], event[:class_name], event[:id].to_i] }
            offset = (page - 1) * AGENDA_PAGE_SIZE
            @agenda_next_page = upcoming_events.length > offset + AGENDA_PAGE_SIZE ? page + 1 : nil
            upcoming_events.drop(offset).take(AGENDA_PAGE_SIZE).each_with_object({}) do |event, agenda|
                start_at = event[:start_at]
                date_key = start_at.to_date.iso8601
                today = start_at.to_date == current_time.to_date

                agenda[date_key] ||= {
                    day_name: today ? I18n.t("lesli_calendar.agendas.today") : I18n.l(start_at.to_date, format: "%a"),
                    day_number: today ? start_at.strftime("%H:%M") : start_at.strftime("%d"),
                    events: []
                }

                agenda[date_key][:events] << event
            end
        end

        private

        def range_boundary(key)
            value = query[key] || query[key.to_s]
            return if value.blank?

            Time.find_zone!("UTC").iso8601(value.to_s)
        rescue ArgumentError
            raise InvalidRange, "Invalid calendar range"
        end

        def agenda_entries(page)
            # Fetch only enough from each source to merge this page, plus one for "Load more".
            limit = page * AGENDA_PAGE_SIZE + 1
            events = EventQuery.new(current_user).upcoming.limit(limit)
            events.map { |event| calendar_entry(event) } + support_entries(start_at: Time.current, limit: limit)
        end

        def calendar_entry(event)
            {
                id: event.id,
                title: event.title,
                start: event.start_at.utc.iso8601(6),
                end: event.end_at.utc.iso8601(6),
                url: event.url,
                className: "lesli-calendar",
                extendedProps: {
                    description: event.description, location: event.location,
                    status: event.status, public: event.public
                }
            }
        end

        def support_entries(start_at:, end_at: nil, limit: nil)
            tickets = Lesli::Courier.new(:lesli_support, [])
                .from(:ticket_service, current_user, { start: start_at.iso8601(6), end: end_at&.iso8601(6) })
                .call(:with_deadline)
            # The provider returns an ordered relation; absent engines return an empty array.
            tickets = tickets.limit(limit) if limit && tickets.respond_to?(:limit)
            tickets.map do |ticket|
                {
                    id: ticket.id, title: ticket.subject,
                    start: ticket.deadline_at.utc.iso8601(6), end: ticket.deadline_at.utc.iso8601(6),
                    className: "lesli-support",
                    extendedProps: { description: ticket.description, public: true }
                }
            end
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

        def value_from(hash, key)
            return unless hash.respond_to?(:[])

            hash[key] || hash[key.to_s]
        end

        # FullCalendar sources may provide dates as Rails objects or ISO 8601 strings.
        def normalize_agenda_time(value)
            case value
            when ActiveSupport::TimeWithZone
                value.utc
            when Time, DateTime, Date
                value.in_time_zone("UTC")
            when String
                Time.find_zone!("UTC").iso8601(value)
            end
        rescue ArgumentError, TypeError
            nil
        end

        def agenda_description(description)
            return if description.blank?

            text = ActionController::Base.helpers.strip_tags(description.to_s).squish
            ActionController::Base.helpers.truncate(text, length: 88)
        end
    end
end
