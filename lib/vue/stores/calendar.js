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
import dayjs from 'dayjs'


// · import lesli stores
import { useEvents } from 'LesliCalendar/vue/stores/events'
//import { useGuests } from 'lesli_calendar/stores/guests'
//import { useUser } from "LesliVue/stores/user"


// · 
export const useCalendar = defineStore("calendar.calendar", {
    state: () => {

        return {
            title: "",
            calendar: {},
            calendarData: {},



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
            submit: {
                event: false,
                delete: false
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

        setTitle() {

            // if current month show the full date
            if (this.calendar.getDate().getMonth() == (new Date()).getMonth()) {
                this.title = this.date2().dateWords().toString()
            } else {
                this.title = dayjs(this.calendar.getDate()).locale(I18n.locale).format("MMMM, YYYY")
            }

        },

        todayMonth() {
            this.calendar.today()
            this.setTitle()
        },

        prevMonth() {
            this.calendar.prev()
            this.setTitle()
        },

        nextMonth() {
            this.calendar.next()
            this.setTitle()
        },

        getCalendar() {
            this.http.get(this.url.calendar("calendar")).then(result => {
                this.calendarData = result

                // Add calendar events 
                this.calendarData.events.forEach(event => {
                    this.calendar.addEvent({
                        title: event.title,
                        start: event.date,
                        description: event.description,
                        classNames: event.classNames
                    })
                })

                // Add calendar events 
                this.calendarData.events_support.forEach(event => {
                    this.calendar.addEvent({
                        title: event.title,
                        start: event.date,
                        description: event.description,
                        classNames: event.classNames
                    })
                })
            }).catch(error => {
                console.log(error)
            })
        },





        

        reset() {
            const storeUser = useUser()
            this.event = {
                organizer_name: storeUser.user.full_name,
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

        async postEvent(url = this.url.driver('events')) {
            const storeEvent = useEvent();
            let data = { event: this.event};
            this.submit.event = true
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
            } finally {
                this.submit.event = false
            }
        },

        async putEvent(url = this.url.driver(`events/${this.event.id}`)) {
            const storeEvent = useEvent()
            let data = { event: this.event }
            this.submit.event = true
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
            } finally {
                this.submit.event = false
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
