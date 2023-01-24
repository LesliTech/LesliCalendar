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

// · 
export const useCalendar = defineStore("driver.calendar", {
    state: () => {
        return {
            calendarOptions: {
                plugins: [
                    dayGridPlugin,
                    interactionPlugin,
                    timeGridPlugin
                ],
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                },
                initialView: 'dayGridMonth',
                firstDay: 1,
                editable: true,
                selectable: true,
                showNonCurrentDates: false,
                locale: I18n.currentLocale(),
                select: null,
                eventClick: null,
                eventsSet: null
            },

            currentEvents: [],

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
        }
    },

    actions: {
    }
})