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
import { useEvents } from "LesliCalendar/vue/stores/events.js"
import { useCalendar } from "LesliCalendar/vue/stores/calendar.js"


// · 
const date = inject("date")
const storeEvents = useEvents()
const storeCalendar = useCalendar()


// · 
const translations = {
    calendar: i18n.t("lesli_calendar.calendars")
}


// · Import components
import componentAgenda from "LesliCalendar/vue/components/agenda.vue"
import componentCalendar from "LesliCalendar/vue/components/calendar.vue"
import componentPanelEvent from "LesliCalendar/vue/components/event-panel.vue"


// · 
onMounted(() => {
    storeCalendar.getCalendar()
})
</script>
<template>
    <lesli-application-container dashboard>
        <lesli-header :title="storeCalendar.title">
            <div class="field has-addons m-0">
                <div class="control">
                    <lesli-button @click="storeCalendar.prevMonth()" icon="arrow_back_ios">
                        {{ translations.calendar.toolbar_prev }}
                    </lesli-button>
                </div>
                <div class="control">
                    <lesli-button @click="storeCalendar.todayMonth()">
                        {{ translations.calendar.toolbar_today }}
                    </lesli-button>
                </div>
                <div class="control">
                    <button @click="storeCalendar.nextMonth()" class="button is-primary is-light is-outlined">
                        <span>{{ translations.calendar.toolbar_next }}</span>
                        <span class="icon">
                            <span class="material-icons">
                                arrow_forward_ios
                            </span>
                        </span>
                    </button>
                </div>
            </div>
            <lesli-button solid icon="add" @click="storeEvents.showModal = true">
                {{ translations.calendar.toolbar_add_event }}
            </lesli-button>
        </lesli-header>

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
