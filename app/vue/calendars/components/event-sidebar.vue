<script>
/*
Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/

import eventComponent from '../../events/components/event.vue'

export default {
    components: {
        'event-component': eventComponent,
    },

    props: {
        eventId: {
            type: String,
            required: true
        },
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
        }
    },

    methods: {
        onSidebarClosed() {
            this.data.state.event_sidebar.open = false            
        }
    },

    watch: {
        'data.state.event_sidebar.open'() {
            this.open = this.data.state.event_sidebar.open;
        },
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
                <event-component v-if="eventId" :event-id="eventId"></event-component>
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
