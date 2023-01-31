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
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
import listPlugin from '@fullcalendar/list';

// · import lesli stores
import { useEvent } from 'CloudDriver/stores/event'

// · 
export const useCalendar = defineStore("driver.calendar", {
    state: () => {
        return {
            calendar: {},

            calendarPlugins: [
                dayGridPlugin,
                interactionPlugin,
                timeGridPlugin,
                listPlugin,
            ],

            calendarToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
            },

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

        initCalendar() {
            this.calendar = new Calendar(document.getElementById("driver_calendar"), {
                plugins: this.calendarPlugins,
                headerToolbar: this.calendarToolbar,
                firstDay: 1,
                locale: I18n.currentLocale(),
                initialView: 'dayGridMonth',
                showNonCurrentDates: false,
                events: [
                    this.calendarData.driver_events,
                    this.calendarData.focus_tasks,
                    this.calendarData.help_tickets,
                ],
                eventClick: this.onEventClick,
                dateClick: this.onDateClick,
                eventContent: function (args) {
                    let title = document.createElement('span')
                    let time = document.createElement('span')
                    title.innerHTML = args.event.title
                    time.innerHTML = args.timeText
                    title.classList.add('event-title')
                    time.classList.add('event-time')
                    return { domNodes: [title, time] }
                }
            })
            this.calendar.render()
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
            arg.jsEvent.preventDefault()
            this.event_id = parseInt(arg.event.id)
            this.http.get(this.url.driver(`events/${this.event_id}`))
                .then(result => {
                    this.event = result
                })
            storeEvent.showModal = !storeEvent.showModal
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
                    this.calendarData.driver_events.push(event);
                    this.calendarData.events.push(event);
                    this.calendar.addEvent(event)
                });
                storeEvent.showModal = !storeEvent.showModal;
                this.msg.success(I18n.t("core.users.messages_success_operation"));
            } catch (error) {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"));
            }
        },


        putEvent(url = this.url.driver(`events/${this.event.id}`)) {
            const storeEvent = useEvent()
            let data = { event: this.event }
            this.http.put(url, data).then(result => {
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                storeEvent.showModal = !storeEvent.showModal
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"));
            })
        },

        deleteEvent() {
            const storeEvent = useEvent()
            return this.dialog
                .confirmation({
                    title: "Delete event",
                    text: "Are you sure you want to delete this event?",
                    confirmText: "yes",
                    cancelText: "no"
                })
                .then(({ isConfirmed }) => {
                    if (isConfirmed) {
                        this.http
                            .delete(this.url.driver(`events/${this.event_id}`))
                            .then((result) => {
                                this.calendar.removeEvent(this.event)
                                this.msg.success(I18n.t("core.users.messages_success_operation"));
                                storeEvent.showModal = !storeEvent.showModal
                            })
                            .catch((error) => {
                                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"));
                            });
                    }
                    return { isConfirmed }
                });
        }
    }
})