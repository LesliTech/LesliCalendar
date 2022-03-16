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
import componentEventPanel from "../../components/event-panel.vue"



// · 
export default {
    components: {
        "component-calendar": componentCalendar,
        "component-agenda": componentAgenda,
        "component-event-panel": componentEventPanel,
    },
    data(){
        return {
            filters_ready: false,
            main_route: "/driver/calendars",
            translations: {
                calendars: I18n.t('driver.calendars'),
                events: I18n.t('driver.events')
            },
            calendar_id: null,
            filters: {
                event_category: "all",
                query: ""
            },
            options: {
                event_categories: []
            },
            loading: true,
            events_day: [],
            loading_agenda: true,
        }
    },

    mounted(){
        this.calendar_id = this.$route.params.id
        this.getEventsType()
        this.getEvents()
        this.setSessionStorageFilters()
    },

    methods: {
        getEventsType() {
            this.http.get('/driver/calendars/options.json').then(result => {
                if (result.successful) {
                    this.options.event_categories = result.data.event_categories
                } else {
                    this.msg.error(result.error.message)
                }
                this.loading = false
            }).catch(error => {
                console.log(error)
                this.loading = false
            })
        },

        getEvents() {
            this.loading_agenda = true

            let filters = {
                include: {
                    help_tickets:  (this.filters.event_category === "all" || this.filters.event_category === "help_tickets" ) ? true : false,
                    focus_tasks: (this.filters.event_category === "all" || this.filters.event_category === "focus_tasks" ) ? true : false,
                    driver_events: (this.filters.event_category === "all" || this.filters.event_category === "driver_events" ) ? true : false,
                    external_events: (this.filters.event_category === "all" || this.filters.event_category === "external_events" ) ? true : false,
                },
                query: this.filters.query
            }
            let url = this.url.driver('calendars/default').filters(filters).dayTimestamp(this.data.agenda_day)

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.events_day = result.data
                } else {
                    this.msg.error(result.error.message)
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

        onToday($event) {
            this.data.agenda_day = new Date()
            this.bus.publish("action:/driver/calendars/components/calendar#current_month", $event)
        },

        showEvent() {
            this.data.event.show = true
        },

        showPanelNew() {
            this.data.event.id = null
            this.data.event.show = true
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
        "filters.event_category"() {
            this.getEvents()
        },

        "filters.query"(){
            this.getEvents()
        },

        "data.agenda_day"(){
            this.getEvents()
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="data.calendar.title" :buttons="false">
            <div class="navbar-end">
                <div class="navbar-item">
                    <div class="field has-addons">
                        <div class="control">
                            <button class="button" @click="onPrevMonth($event)">
                                <span class="icon">
                                    <i class="fas fa-chevron-left"></i>
                                </span>
                                <span>{{translations.calendars.view_btn_previous_month}}</span>
                            </button>
                        </div>
                        <div class="control">
                            <button class="button" @click="onNextMonth($event)">
                                <span>{{translations.calendars.view_btn_next_month}}</span>
                                <span class="icon">
                                    <i class="fas fa-chevron-right"></i>
                                </span>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="navbar-item">
                    <div class="buttons">
                        <button class="button" @click="onToday($event)">
                            <span class="icon">
                                <i class="fas fa-calendar-day"></i>
                            </span>
                            <span>{{translations.calendars.view_btn_today}}</span>
                        </button>
                        <button class="button" @click="showPanelNew()">
                            <span class="icon">
                                <i class="fas fa-plus"></i>
                            </span>
                            <span>{{translations.events.view_btn_new}}</span>
                        </button>
                    </div>
                </div>
            </div>
        </component-header>

        <component-toolbar
            v-if="filters_ready"
            :initialValue="filters.text"
            :search-text="translations.calendars.view_placeholder_filter_text"
            @search="searchEvents">
            <b-select
                v-model="filters.event_category"
                :loading="loading">
                <option
                    v-for="(key, value) in this.options.event_categories"
                    :value="key"
                    :key="key">
                    {{ object_utils.translateEnum(translations.calendars, 'view_toolbar_filter_event_categories', value) }}
                </option>
            </b-select>
        </component-toolbar>

        <div class="columns">
            <div class="column is-one-quarter">
            <div class="box">
                <component-agenda
                    :events="events_day"
                    :loading="loading_agenda"
                    :agenda_day="this.data.agenda_day">
                </component-agenda>
            </div>
            </div>
            <div class="column">
                <div class="box">
                <component-calendar
                    :calendar_id="calendar_id"
                    :filter-query="filters.query"
                    :filter-event-source="filters.event_category"
                    :key="calendar_id"
                    :events="events_day">
                </component-calendar>
                </div>
            </div>
        </div>

        <component-event-panel>
        </component-event-panel>

    </section>
</template>
