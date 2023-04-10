<script setup>
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
*/


// · Import components, libraries and tools
import { onMounted, inject } from "vue"
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
import listPlugin from '@fullcalendar/list';


// · 
const date = inject("date")


// · import lesli stores
import { useCalendar } from 'CloudDriver/stores/calendar'


// · implement stores
const storeCalendar = useCalendar()


// · 
function initCalendar() {
    storeCalendar.calendar = new Calendar(document.getElementById("driver-calendar"), {
        plugins: [
            dayGridPlugin,
            interactionPlugin,
            timeGridPlugin,
            listPlugin
        ],
        headerToolbar: false,
        firstDay: 1,
        locale: I18n.currentLocale(),
        initialView: 'dayGridMonth',
        showNonCurrentDates: true,
        events: [],
        eventClick: storeCalendar.onEventClick,
        dateClick: storeCalendar.onDateClick,
        eventContent: function (args) {

            let title = document.createElement('span')
            let time = document.createElement('span')
            title.innerHTML = args.event.title
            time.innerHTML = date.time(args.event._def.extendedProps.dateStart)

            if (args.event._def.extendedProps.dateEnd) {
                time.innerHTML += (" - " + date.time(args.event._def.extendedProps.dateEnd))
            }
            
            title.classList.add('event-title')
            time.classList.add('event-time')
            return { domNodes: [title, time] }
        }
    })
    storeCalendar.calendar.render()
}


// · 
onMounted(() => {
    setTimeout(function () {
        initCalendar()
    }, 1);
    storeCalendar.getCalendarEvents();
});
</script>

<template>
    <div id="driver-calendar"></div>
</template>
