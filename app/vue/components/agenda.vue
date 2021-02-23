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


// · 
export default {
    props: {
        events: {
            default() {
                return {
                    driver_events: [],
                    focus_tasks: [],
                    help_tickets: []
                }
            }
        },
        loading: {
            required: false,
            default: true,
        }
    }
}
</script>
<template>
    <div>
        <component-data-loading v-if="loading" />
        <component-data-empty
            v-if="!loading && events.driver_events.length == 0 && events.focus_tasks.length == 0 && events.help_tickets.length == 0" />
        <div v-if="events.driver_events && events.driver_events.length > 0 && !loading">
            <div class="mb-5" v-for="event in events.driver_events" :key="event.id">
                <div class="media">
                    <div class="media-left">
                        <span class="icon">
                            <i class="far fa-lg fa-calendar-alt"></i>
                        </span>
                    </div>
                    <div class="media-content">
                        <div class="content">
                            <p class="mb-0">{{ event.title }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div v-if="events.focus_tasks && events.focus_tasks.length > 0 && !loading">
            <div class="mb-5" v-for="event in events.focus_tasks" :key="event.id">
                <div class="media">
                    <div class="media-left">
                        <span class="icon">
                            <i class="far fa-lg fa-calendar-alt"></i>
                        </span>
                    </div>
                    <div class="media-content">
                        <div class="content">
                            <p class="mb-0">{{ event.title }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div v-if="events.help_tickets && events.help_tickets.length > 0 && !loading">
            <div class="mb-5" v-for="event in events.help_tickets" :key="event.id">
                <div class="media">
                    <div class="media-left">
                        <span class="icon">
                            <i class="far fa-lg fa-calendar-alt"></i>
                        </span>
                    </div>
                    <div class="media-content">
                        <div class="content">
                            <p class="mb-0">{{ event.title }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
