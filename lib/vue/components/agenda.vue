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

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · 
import { onMounted, watch, ref, inject } from "vue"


// · 
import dayjs from "dayjs"
import isSameOrAfter from "dayjs/plugin/isSameOrAfter"


// · 
dayjs.extend(isSameOrAfter)


// · import lesli stores
import { useCalendar } from "LesliCalendar/vue/stores/calendar"


// · 
const date = inject("date")


// · implement stores
const storeCalendar = useCalendar()


// · 
const agenda = ref([])
const today = dayjs()


// Function to merge and group events by date
function mergeAndGroupEvents() {

    // Get current date and time
    const currentDate = dayjs();

    // Combine events and support events into one array
    const mergedEvents = [
        ...storeCalendar.calendar.events, 
        ...storeCalendar.calendar.events_support
    ];

    // Filter out past events
    const filteredEvents = mergedEvents.filter(event => {
        return !dayjs(event.start).isBefore(currentDate, "day");
    });

    // Group events by date
    const groupedEvents = filteredEvents.reduce((acc, event) => {

        let eventDate = dayjs(event.start)

        // Extract date key from event start date
        const dateKey = eventDate.format('YYYY-MM-DD');

        // Create array for the date key if it doesn't exist
        if (!acc[dateKey]) {

            let dayName = "Today"
            let dayNumber = eventDate.format("HH:mm")

            if (!eventDate.isSame(currentDate, "day")) {
                dayName = eventDate.format("ddd")
                dayNumber = eventDate.format("DD")
            }

            acc[dateKey] = {
                dayName: dayName,
                dayNumber: dayNumber,
                events: []
            }
        }

        if (event.description) { 
            event.description = event.description
            .replace(/<[^>]*>?/gm, '') // remove html tags from string
            .substring(0, 35) + '...'  // get a excerpt of the description
        }

        // Add event to the array corresponding to its date
        acc[dateKey].events.push(event);

        return acc;
    }, {});

    // Sort the groups by date
    const sortedGroupedEvents = Object.keys(groupedEvents)
        .sort()
        .reduce((acc, key) => {
            acc[key] = groupedEvents[key];
            return acc;
        }, {});

    agenda.value = sortedGroupedEvents;
}

onMounted(() => {
    mergeAndGroupEvents()
})

// · 
watch(() => storeCalendar.calendar.id, (a,b) => {
    mergeAndGroupEvents()
})

</script>
<template>
    <div class="lesli-calendar-agenda box">
        <h3>Upcoming events</h3>
        <template v-for="day in agenda">
            <div class="event is-flex is-align-items-center">
                <div class="date">
                    <p class="day-name">{{ day.dayName }}</p>
                    <p class="day-number">{{ day.dayNumber }}</p>
                </div>
                <div class="description">
                    <div :class="event.classnames" v-for="(event, index) in day.events" :key="index">
                        <p>{{ event.title }}</p>
                        <p>{{ event.description }}</p>
                    </div>
                </div>
            </div>
        </template>
    </div>
</template>
