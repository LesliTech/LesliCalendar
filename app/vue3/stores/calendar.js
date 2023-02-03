/*

Copyright (c) 2023, all rights reserved.

All the information provided by this platform is protected by international laws related  to
industrial property, intellectual property, copyright and relative international laws.
All intellectual or industrial property rights of the code, texts, trade mark, design,
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·

*/

// · 
import { defineStore } from "pinia"

// · Import components, libraries and tools
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
import listPlugin from '@fullcalendar/list';

// · import lesli stores
import { useEvent } from 'CloudDriver/stores/event'
import { useGuests } from 'CloudDriver/stores/guests'

// · 
export const useCalendar = defineStore("driver.calendar", {
    state: () => {
        return {
            calendar: {},
            calendarData: {
                driver_events: [],
                focus_tasks: [],
                help_tickets: [],
            },
            event_id: '',
            event: {
                cloud_driver_catalog_event_types_id: null,
                title: null,
                description: '',
                event_date: new Date(),
                time_start: null,
                time_end: null,
                location: '',
                url: ''
            },
            lesli: {
                settings: {
                    currency: {
                        symbol: null
                    }
                }
            }
        }
    },

    actions: {

        reset() {
            this.event = {
                cloud_driver_catalog_event_types_id: null,
                title: null,
                description: '',
                event_date: new Date(),
                time_start: null,
                time_end: null,
                location: '',
                url: ''
            }
        },

        async getCalendarEvents() {
            let url = this.url.driver('calendars/default')
            try {
                let result = await this.http.get(url);
                this.calendarData = result;
                this.calendarData.events.forEach(event => this.calendar.addEvent(event))
            } catch (error) {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"));
            }
        },

        onDateClick: function (selectInfo) {
            const storeEvent = useEvent()
            this.reset()
            storeEvent.showModal = !storeEvent.showModal
        },

        onEventClick: function (arg) {
            const storeEvent = useEvent()
            const storeGuests = useGuests()
            arg.jsEvent.preventDefault()
            this.event_id = parseInt(arg.event.id)
            this.http.get(this.url.driver(`events/${this.event_id}`))
                .then(result => {
                    this.event = result
                    storeEvent.showModal = !storeEvent.showModal
                    storeGuests.getAttendants()
                    storeGuests.getUsers()
                })


        },

        async postEvent(url = this.url.driver('events')) {
            const storeEvent = useEvent();
            let data = {
                event: this.event
            };
            try {
                const result = await this.http.post(url, data).then(event => {
                    this.event_id = event.id
                    let newEvent = {
                        ...event,
                        date: event.event_date,
                        start: event.time_start,
                        end: event.time_end
                    }
                    this.calendarData.driver_events.push(newEvent);
                    this.calendarData.events.push(newEvent);
                    this.calendar.addEvent(newEvent)
                });
                storeEvent.showModal = !storeEvent.showModal;
                this.msg.success(I18n.t("core.users.messages_success_operation"));
            } catch (error) {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"));
            }
        },


        async putEvent(url = this.url.driver(`events/${this.event.id}`)) {
            const storeEvent = useEvent()
            let data = { event: this.event }
            try {
                const result = await this.http.put(url, data)
                let oldEvent = this.calendar.getEventById(this.event_id)
                let updatedEvent = {
                    ...this.event,
                    date: this.event.event_date,
                    start: this.event.time_start,
                    end: this.event.time_end,
                }
                oldEvent.remove()
                this.calendar.addEvent(updatedEvent)
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                storeEvent.showModal = !storeEvent.showModal
            } catch (error) {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            }
        },

        async deleteEvent() {
            const storeEvent = useEvent()
            const { isConfirmed } = await this.dialog.confirmation({
                title: "Delete event",
                text: "driver.events.view_text_delete_confirmation",
                confirmText: I18n.t("core.shared.view_text_yes"),
                cancelText: I18n.t("core.shared.view_text_no")
            })

            if (isConfirmed) {
                try {
                    storeEvent.submit.delete = true
                    const result = await this.http.delete(this.url.driver(`events/${this.event_id}`))
                    let deletedEvent = this.calendar.getEventById(this.event_id)
                    deletedEvent.remove()
                    this.msg.success(I18n.t("core.users.messages_success_operation"))
                    storeEvent.showModal = !storeEvent.showModal
                } catch (error) {
                    this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
                }
            }
            storeEvent.submit.delete = false
            return { isConfirmed }
        }
    }
})