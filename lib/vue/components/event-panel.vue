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
import { onMounted } from 'vue'


// · 
import { useEvents } from "LesliCalendar/vue/stores/events"


// · 
const storeEvents = useEvents()


// · 
const translations = {
    events: i18n.t("lesli_calendar.events")
}


// import ComponentDiscussions from "LesliVue/cloud-objects/discussion.vue"
// import ComponentFiles from "LesliVue/cloud-objects/file.vue"
// import ComponentGuests from './guests.vue'
import ComponentEventForm from "./event-form.vue"

</script>

<template>
    <lesli-panel v-model:open="storeEvents.showPanel">
        <template #header>
            {{ translations.events.view_add_new_event }}
        </template>
        <template #default>
            <component-event-form></component-event-form>
        </template>
    </lesli-panel>
</template>
