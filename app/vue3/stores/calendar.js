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
import { usePanelEvent } from 'CloudDriver/stores/panel-event'

// · 
export const useCalendar = defineStore("driver.calendar", {
    state: () => {
        return {
            calendarPlugins: [
                dayGridPlugin,
                interactionPlugin,
                timeGridPlugin,
                listPlugin,
            ],
            calendar: {},
            currentEvents: JSON.parse(localStorage.getItem("currentEvents")),
            calendarData: {
                driver_events: [],
                focus_tasks: [],
                help_tickets: [],
            },
            translations: {
                core: {
                    shared: I18n.t('core.shared')
                }
            },
            eventGuid: 0,
        }
    },

    actions: {

        initCalendar() {
            this.calendar = new Calendar(document.getElementById("driver_calendar"), {
                plugins: this.calendarPlugins,
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
                },
                firstDay: 1,
                locale: I18n.currentLocale(),
                eventClick: this.onEventClick,
                initialView: 'dayGridMonth',
                initialEvents: JSON.parse(localStorage.getItem("currentEvents")),
                showNonCurrentDates: false,
                editable: false,
                selectable: true,
                eventContent: function(args) {

                    let title = document.createElement('span')
                    let time = document.createElement('span')

                    title.innerHTML = args.event.title
                    time.innerHTML = args.timeText

                    title.classList.add('event-title')
                    time.classList.add('event-time')

                    return { domNodes: [ title, time ] }

                }
            })
            this.calendar.render()
        },

        onEventClick: function(arg) {
            const storePanelEvent = usePanelEvent()
            storePanelEvent.event.id = arg.event.id
            storePanelEvent.event.title = arg.event.title
            storePanelEvent.showModal = !storePanelEvent.showModal
        },

        createEventId() {
            return String(this.eventGuid++)
        }
    }
})