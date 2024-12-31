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


// · import vue tools
import { ref, reactive, onMounted, watch, computed, inject } from "vue"
import { useRouter, useRoute } from "vue-router"


// · 
import { useCalendar } from "LesliCalendar/vue/stores/calendar.js"


// · 
const storeCalendar = useCalendar()


// · Import components
import componentAgenda from "LesliCalendar/vue/components/agenda.vue"
import componentCalendar from "LesliCalendar/vue/components/calendar.vue"
import componentPanelEvent from "LesliCalendar/vue/components/event-panel.vue"
import componentCalendarHeader from "LesliCalendar/vue/components/calendar-header.vue"


// · 
onMounted(() => {
    storeCalendar.getCalendar()
})
</script>
<template>
    <lesli-application-container dashboard>

        <component-calendar-header></component-calendar-header>

        <div class="columns">
            <div class="column is-3">
                <component-agenda></component-agenda>
            </div>
            <div class="column">
                <component-calendar></component-calendar>
            </div>
        </div>

        <component-panel-event></component-panel-event>
    </lesli-application-container>
</template>
