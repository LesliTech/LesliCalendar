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
const date = inject("date")


// · Import components
import componentCalendar from "LesliCalendar/vue/components/calendar.vue"
import componentPanelEvent from "LesliCalendar/vue/components/event-panel.vue"


// · 
onMounted(() => {
    storeCalendar.getCalendar()
})
</script>
<template>
    <lesli-application-container>
        <lesli-header :title="date.dateWords()">
            <div class="field has-addons m-0">
                <div class="control">
                    <lesli-button icon="arrow_back_ios">
                        prev
                    </lesli-button>
                </div>
                <div class="control">
                    <lesli-button>
                        today
                    </lesli-button>
                </div>
                <div class="control">
                    <button class="button is-primary is-light is-outlined">
                        <span>next</span>
                        <span class="icon">
                            <span class="material-icons">
                                arrow_forward_ios
                            </span>
                        </span>
                    </button>
                </div>
            </div>
            <lesli-button solid icon="add">
                Add event
            </lesli-button>
        </lesli-header>

        <component-calendar class="mt-4">
        </component-calendar>

        <component-panel-event></component-panel-event>
    </lesli-application-container>
</template>
