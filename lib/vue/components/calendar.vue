<script setup>
/*
Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

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

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · Import components, libraries and tools
import { onMounted, watch, inject, ref } from "vue"

import { Calendar } from "@fullcalendar/core";
import listPlugin from "@fullcalendar/list";
import dayGridPlugin from "@fullcalendar/daygrid";
import timeGridPlugin from "@fullcalendar/timegrid";
import interactionPlugin from "@fullcalendar/interaction";


// · import lesli stores
import { useCalendar } from 'LesliCalendar/vue/stores/calendar'


// · implement stores
const storeCalendar = useCalendar()


// · 
const date = inject("date")
const calendar = ref(false)


function onDateClick() {
    // const storeEvent = useEvent()
    // this.reset()
    // storeEvent.showModal = !storeEvent.showModal
}


function onEventClick(args) {

    if (args.event?._def?.extendedProps?.engine == "lesli-support") {
        window.open(
            "http://localhost:3000/support/tickets/" + args.event?._def?.extendedProps?.ticket, 
            "_blank", 
            "noreferrer"
        );
        return 
    }
    
    // const storeEvent = useEvent()
    // const storeGuests = useGuests()
    // arg.jsEvent.preventDefault()
    // this.event_id = parseInt(arg.event.id)
    // this.http.get(this.url.driver(`events/${this.event_id}`))
    // .then(result => {
    //     this.event = result
    //     storeEvent.showModal = !storeEvent.showModal
    //     storeGuests.getAttendants()
    //     storeGuests.getUsers()
    // })
}


function onEventContent(args) {

    console.log(args.event._def.extendedProps.engine)

    let title = document.createElement("span")
    let time = document.createElement("span")
    title.innerHTML = args.event.title
    time.innerHTML = date.time(args.event._def.extendedProps.dateStart)

    if (args.event._def.extendedProps.dateEnd) {
        time.innerHTML += (" - " + date.time(args.event._def.extendedProps.dateEnd))
    }
    
    title.classList.add("event-title")
    time.classList.add("event-time")
    return { domNodes: [title, time] }

}


function loadEvents() {

    // Add calendar events 
    storeCalendar.calendar.events.forEach(event => {
        storeCalendar.calendarObject.addEvent({
            title: event.title,
            start: event.start,
            description: event.description,
            classNames: event.classnames
        })
    })

    // Add calendar events 
    storeCalendar.calendar.events_support.forEach(event => {
        storeCalendar.calendarObject.addEvent({
            title: event.title,
            start: event.date,
            description: event.description,
            classNames: event.classnames
        })
    })

}



// · 
onMounted(() => {

    storeCalendar.calendarObject = new Calendar(document.getElementById("lesli-calendar"), {
        plugins: [
            dayGridPlugin,
            interactionPlugin,
            timeGridPlugin,
            listPlugin
        ],
        firstDay: 1,
        headerToolbar: false,
        initialView: "dayGridMonth",
        showNonCurrentDates: true,
        dayMaxEvents: true, // allow "more" link when too many events
        editable: true,
        events: [],
        eventClick: onEventClick,
        dateClick: onDateClick,
        //eventContent: onEventContent
    });

    loadEvents()
    storeCalendar.setTitle()

    setTimeout(() => { storeCalendar.calendarObject.render(); }, 200)
})


// · 
watch(() => storeCalendar.calendar.id, (a,b) => {
    loadEvents()
})
</script>
<template>
    <div id="lesli-calendar" class="box"></div>
</template>
