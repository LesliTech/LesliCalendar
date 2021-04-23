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
            filters_ready: false,
            main_route: "/driver/calendars",
            translations: {
                calendars: I18n.t('driver.calendars')
            },
            calendar_id: null,
            filters: {
                module_event: "all",
                query: ""
            },
            options: {
                types_module_events: []
            },
            loading: true,
            events_today: [],
            loading_agenda: true,
        }
    },

    mounted(){
        this.calendar_id = this.$route.params.id
        this.getEventsType()
        this.getEventsToday()
        this.setSessionStorageFilters()
    },

    methods: {
        getEventsType() {
            this.http.get('/driver/calendars/options.json').then(result => {
                if (result.successful) {
                    this.options.types_module_events = result.data.types_module_events
                }else{
                    this.alert(result.error.message,'danger')
                }
                this.loading = false
            }).catch(error => {
                console.log(error)
                this.loading = false
            })
        },

        getEventsToday() {
            this.loading_agenda = true
            let today = new Date()
            let filters = {
                include: {
                    help_tickets:  (this.filters.module_event === "all" || this.filters.module_event === "help_tickets" ) ? true : false,
                    focus_tasks: (this.filters.module_event === "all" || this.filters.module_event === "focus_tasks" ) ? true : false,
                    driver_events: (this.filters.module_event === "all" || this.filters.module_event === "driver_events" ) ? true : false,
                },
                query: this.filters.query,
                day: today.getDate(),
                month: today.getMonth()+1,
                year: today.getFullYear(),
            }

            let url = this.url.driver('events').filters(filters)

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.events_today = result.data
                } else {
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.loading_agenda = false
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

        setSessionStorageFilters(){
            let stored_filters = this.storage.local("filters")

            if(stored_filters){
                for(let key in stored_filters){
                    this.$set(this.filters, key, stored_filters[key])
                }
            }

            this.filters_ready = true
        },

        searchEvents(text_to_search){
            this.filters.query = text_to_search
        }
    },
    watch: {
        "filters.module_event"() {
            this.getEventsToday()
        },

        "filters.query"(){
            this.getEventsToday()
        }
    },
    computed: {
        title() {
            return this.data.calendar.title
        },

        event_filter_options() {
            let options = [
                {
                    value: "all",
                    label: "All events type"
                },
                {
                    value: "driver_events",
                    label: "Calendar Events"
                }
            ]

            if ("focus_tasks" in this.options.types_module_events) options.push({value: this.options.types_module_events.focus_tasks, label: "Tasks"})
            if ("help_tickets" in this.options.types_module_events) options.push({value: this.options.types_module_events.help_tickets, label: "Tickets"})


            return options
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

        <component-toolbar
            v-if="filters_ready"
            :initialValue="filters.text"
            :search-text="translations.calendars.view_placeholder_filter_text"
            @search="searchEvents"
        >
            <b-select
                placeholder="Select a event type"
                v-model="filters.module_event"
                :loading="loading">
                <option
                    v-for="option in this.event_filter_options"
                    :value="option.value"
                    :key="option.value">
                    {{ option.label }}
                </option>
            </b-select>
        </component-toolbar>

        <div class="columns">
            <div class="column is-one-quarter">
                <component-agenda
                    :events="events_today"
                    :loading="loading_agenda"
                ></component-agenda>
            </div>
            <div class="column">
                <component-calendar
                    :calendar_id="calendar_id"
                    :filter-query="filters.query"
                    :filter-event-source="filters.module_event"
                    :key="calendar_id">
                </component-calendar>
            </div>
        </div>

        <component-event></component-event>

    </section>
</template>
