<script setup>
/*
Lesli

Copyright (c) 2024, Lesli Technologies, S. A.

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
import { useCalendar } from "LesliCalendar/vue/stores/calendar.js"
import { useEvents } from "LesliCalendar/vue/stores/events.js"


// · 
const storeEvents = useEvents()
const storeCalendar = useCalendar()


// · 
const translations = {
    calendar: i18n.t("lesli_calendar.calendars")
}

</script>
<template>
    <lesli-header :title="storeCalendar.title">
        <div class="field has-addons m-0">
            <div class="control">
                <lesli-button @click="storeCalendar.prevMonth()" icon="arrow_back_ios">
                    {{ translations.calendar.button_prev }}
                </lesli-button>
            </div>
            <div class="control">
                <lesli-button @click="storeCalendar.todayMonth()">
                    {{ translations.calendar.button_today }}
                </lesli-button>
            </div>
            <div class="control">
                <button @click="storeCalendar.nextMonth()" class="button is-primary is-light is-outlined">
                    <span>{{ translations.calendar.button_next }}</span>
                    <span class="icon">
                        <span class="material-icons">
                            arrow_forward_ios
                        </span>
                    </span>
                </button>
            </div>
        </div>
        <lesli-button solid icon="add" @click="storeEvents.showPanel = true">
            {{ translations.calendar.button_add_event }}
        </lesli-button>
    </lesli-header>
</template>
