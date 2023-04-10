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


// · import vue tools
import { ref, reactive, onMounted, watch, computed, inject } from "vue"
import { useRouter, useRoute } from 'vue-router'


// · Import components
import componentCalendar from './components/calendar.vue'
import componentEvent from './components/event.vue'
import componentAgenda from './components/agenda.vue'


// · import lesli stores
import { useCalendar } from 'CloudDriver/stores/calendar'
import { useEvent } from 'CloudDriver/stores/event'
import { useGuests } from 'CloudDriver/stores/guests'
import { useUser } from "LesliVue/stores/user"


// · initialize/inject plugins
const router = useRouter()
const msg = inject("msg")
const url = inject("url")


// · implement stores
const storeCalendar = useCalendar()
const storeEvent = useEvent()
const storeGuests = useGuests()
const storeUser = useUser()


const newEvent = () => {
    storeCalendar.reset()
    storeEvent.showModal = !storeEvent.showModal
}


const translations = {
    calendars: I18n.t('driver.calendars'),
    events: I18n.t('driver.events')
}


onMounted(() => {
    storeUser.fetch()
})

</script>
<template>
    <section class="application-component">
        <lesli-header :title="storeCalendar.title">

            <lesli-button icon="navigate_before" @click="storeCalendar.prevMonth()">previous</lesli-button>

            <lesli-button icon="today" @click="storeCalendar.todayMonth()">Today</lesli-button>

            <button class="button is-primary is-outlined" @click="storeCalendar.nextMonth()">
                <span>next</span>
                <span class="icon">
                    <span class="material-icons">navigate_next</span>
                </span>
            </button>

            <lesli-select placeholder="All events">
            </lesli-select>

            <lesli-button icon="add" solid @click="newEvent()">
                {{ translations.events.view_btn_new }}
            </lesli-button>
        </lesli-header>


        <div class="columns">
            <div class="column is-one-quarter">
                <component-agenda>
                </component-agenda>
            </div>
            <div class="column">
                <component-calendar>
                </component-calendar>
            </div>
        </div>

        <component-event>
        </component-event>
    </section>
</template>
