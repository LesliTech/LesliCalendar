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
                detail_attributes: {
                    title: null,
                    description: '',
                    event_date: new Date(),
                    time_start: null,
                    time_end: null,
                    location: '',
                    url: ''
                }
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
                detail_attributes: {
                    title: null,
                    description: '',
                    event_date: new Date(),
                    time_start: null,
                    time_end: null,
                    location: '',
                    url: ''
                }
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
            this.event.detail_attributes = []
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
                event: {
                    cloud_driver_catalog_event_types_id: this.event.cloud_driver_catalog_event_types_id,
                    detail_attributes: {
                        title: this.event.detail_attributes.title,
                        description: this.event.detail_attributes.description,
                        event_date: this.event.detail_attributes.event_date,
                        time_start: this.event.detail_attributes.time_start,
                        time_end: this.event.detail_attributes.time_end,
                        location: this.event.detail_attributes.location,
                        url: this.event.detail_attributes.url
                    }
                }
            };

            try {
                const result = await this.http.post(url, data).then(event => {
                    this.event_id = event.id
                    let newEvent = {
                        id: event.id,
                        date: event.detail_attributes.event_date,
                        description: event.detail_attributes.description,
                        end: event.detail_attributes.time_end,
                        event_type: event.cloud_driver_catalog_event_types_id,
                        is_proposal: event.is_proposal,
                        location: event.detail_attributes.location,
                        start: event.detail_attributes.time_start,
                        title: event.detail_attributes.title,
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
                let newEvent = {
                    id: this.event.id,
                    date: this.event.detail_attributes.event_date,
                    description: this.event.detail_attributes.description,
                    end: this.event.detail_attributes.time_end,
                    event_type: this.event.cloud_driver_catalog_event_types_id,
                    is_proposal: this.event.is_proposal,
                    location: this.event.detail_attributes.location,
                    start: this.event.detail_attributes.time_start,
                    title: this.event.detail_attributes.title,
                }
                oldEvent.remove()
                this.calendar.addEvent(newEvent)

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
            return { isConfirmed }
        }
    }
})