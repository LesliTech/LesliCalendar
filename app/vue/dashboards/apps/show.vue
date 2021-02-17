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



// · List of Imported Components
import componentCalendar from "../../components/calendar.vue"
import componentAgenda from "../../components/agenda.vue"
import componentEvent from "../../components/event-sidebar.vue"



// · 
export default {
    components: {
        "component-calendar": componentCalendar,
        "component-agenda": componentAgenda,
        "component-event": componentEvent,
    },
    data(){
        return {
            main_route: "/driver/calendars",
            translations: {
            },
            calendar_id: null,
            filters: {
                status: "all"
            },
            options: {
                events_type: []
            },
            loading: true,
        }
    },

    mounted(){
        this.calendar_id = this.$route.params.id
        this.getEventsType();
    },

    methods: {
        getEventsType() {
            this.loading = true;
            this.http.get('/driver/calendars/options.json').then(result => {
                if (result.successful) {
                    this.options.events_type = result.data.events_type
                }else{
                    this.alert(result.error.message,'danger')
                }
                this.loading = false
            }).catch(error => {
                console.log(error)
                this.loading = false
            })
        },

        onPrevMonth($event) {
            this.bus.publish("action:/driver/calendars/components/calendar#prev_month", $event)
        },

        onNextMonth($event) {
            this.bus.publish("action:/driver/calendars/components/calendar#next_month", $event)
        },

        onCurrentMonth($event) {
            this.bus.publish("action:/driver/calendars/components/calendar#current_month", $event)
        },

        showEvent() {
            this.data.event.show = true
        },

        createEvent() {
            this.url.go("/driver/events/new")
        },
    },
    computed: {
        title() {
            return this.data.calendar.title
        }
    },
}
</script>
<template>
    <section class="application-component">
        <component-header :title="title" :buttons="false">
            <div class="navbar-end">
                <div class="navbar-item">
                    <div class="field has-addons">
                        <div class="control">
                            <button class="button" @click="onPrevMonth($event)">
                                <span class="icon">
                                    <i class="fas fa-chevron-left"></i>
                                </span>
                                <span>prev</span>
                            </button>
                        </div>
                        <div class="control">
                            <button class="button" @click="onNextMonth($event)">
                                <span>next</span>
                                <span class="icon">
                                    <i class="fas fa-chevron-right"></i>
                                </span>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="navbar-item">
                    <div class="buttons">
                        <button class="button" @click="onCurrentMonth($event)">
                            <span class="icon">
                                <i class="fas fa-calendar-day"></i>
                            </span>
                            <span>today</span>
                        </button>
                        <button class="button" @click="createEvent()">
                            <span class="icon">
                                <i class="fas fa-plus"></i>
                            </span>
                            <span>create event</span>
                        </button>
                    </div>
                </div>
            </div>
        </component-header>

        <component-toolbar>
            <b-select
                placeholder="Select a event type"
                v-model="filters.status"
                :loading="loading">
                <option
                    v-for="option in options.events_type"
                    :value="option.value"
                    :key="option.value">
                    {{ option.name }}
                </option>
            </b-select>
        </component-toolbar>

        <div class="columns">
            <div class="column is-one-quarter">
                <component-agenda></component-agenda>
            </div>
            <div class="column">
                <div class="card">
                    <component-calendar
                        :calendar_id="calendar_id"
                        :filter_event="filters.status"
                        :key="calendar_id">
                    </component-calendar>
                </div>
            </div>
        </div>

        <component-event></component-event>

    </section>
</template>
