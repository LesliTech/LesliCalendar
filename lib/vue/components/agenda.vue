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


// · 
import { onMounted, watch, ref, inject } from "vue"

import dayjs from "dayjs"
import isSameOrAfter from "dayjs/plugin/isSameOrAfter"
dayjs.extend(isSameOrAfter)

// · 



// · import lesli stores
import { useCalendar } from "LesliCalendar/vue/stores/calendar"


const date = inject("date")


// · implement stores
const storeCalendar = useCalendar()


// · 
const agenda = ref([])
const today = dayjs()


// · 
function merge() {

    let events = [
        ...storeCalendar.calendarData.events, 
        ...storeCalendar.calendarData.events_support
    ]
    
    let count = 0

    events = events.filter(event => {

        // limit the number of events to show in the agenda
        if (count >= 6) {
            return 
        }

        let eventDate = dayjs(event.start)
        
        // Do not process past events
        if (eventDate.isBefore(today, "day")) {
            return 
        } 

        // show today event description by default
        event.dayName = "Today"
        event.dayNumber = eventDate.format("HH:mm")

        // If the event is NOT today, show only the time
        if (!eventDate.isSame(today, "day")) {
            event.dayName = eventDate.format("ddd")
            event.dayNumber = eventDate.format("DD")
        }


        if (event.description) { 
            event.description = event.description
            .replace(/<[^>]*>?/gm, '') // remove html tags from string
            .substring(0, 40) + '...'  // get a excerpt of the description
        }

        event.classNames = event.classNames

        count++

        return event

    })
    
    events = events.sort((a,b) => a.time > b.time)

    agenda.value = events
}


// · 
watch(() => storeCalendar.calendarData.events_support, () => merge())

</script>
<template>
    <div class="lesli-calendar-agenda">
        <h3>Upcoming events</h3>
        <div 
            class="is-flex is-align-items-center event" 
            v-for="(event, index) in agenda"
            :key="index">
            <div class="date">
                <p class="day-name">{{ event.dayName }}</p>
                <p class="day-number">{{ event.dayNumber }}</p>
            </div>
            <div :class="['description', event.classNames]">
                <p>{{ event.title }}</p>
                <p>{{ event.description }}</p>
            </div>
        </div>
    </div>
</template>
