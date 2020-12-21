<script>
/*

Copyright (c) 2020, all rights reserved.

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

import eventComponent from '../../events/components/event.vue'

export default {
    components: {
        'event-component': eventComponent,
    },

    props: {
        size: {
            type: String,
            required: false,
            validator: (val) => ['small', 'medium', 'large'].includes(val),
            default: 'small',
        }
    },

    data() {
        return {
            open: false,
            event_id: null,
        }
    },

    methods: {
        onSidebarClosed() {
            this.open = false
        }
    },

    watch: {
        'data.calendar.selected_event': function() {
            this.open = true
            this.event_id = this.data.calendar.selected_event.id
        }
    },
}
</script>
<template>
    <b-sidebar
        type="is-light"
        :class="[size]"
        :fullheight="true"
        :fullwidth="false"
        :overlay="false"
        :right="true"
        :open.sync="open"
        :on-cancel="onSidebarClosed"
    >
        <section class="section">
            <div class="container">
                <event-component v-if="event_id" :event-id="event_id" :key="event_id"></event-component>
            </div>
        </section>
    </b-sidebar>
</template>

<style>
.small .sidebar-content {
    width: 40%;
    max-width: 40%;
}

.medium .sidebar-content {
    width: 60%;
    max-width: 60%;
}

.large .sidebar-content {
    width: 70%;
    max-width: 70%;
}
</style>
