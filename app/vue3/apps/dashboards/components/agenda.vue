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
// · 
*/

// · Import components, libraries and tools
import dayjs from 'dayjs'

// · import lesli stores
import { useCalendar } from 'CloudDriver/stores/dashboard/calendar'

// · implement stores
const storeCalendar = useCalendar()

</script>

<template>
    <h2>All Events ({{ storeCalendar.currentEvents.length }})</h2>
    <ul>
        <li v-for='event in storeCalendar.currentEvents.sort((a, b) => new Date(a.start) - new Date(b.start))' :key='event.id'>
            <b class="fc-event-date">{{ dayjs(event.start).format('MMMM DD') }}:</b>
            <i class="fc-event-title">{{ event.title }}</i>
        </li>
    </ul>
</template>