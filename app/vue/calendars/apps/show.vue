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
import { Calendar } from "@fullcalendar/core"

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
        }
    },

    mounted(){
        this.calendar_id = this.$route.params.id
    },

    methods: {

        initCalendar() {
            this.calendar = new Calendar(document.getElementById("calendar"), {
                plugins: this.calendarPlugins,
                header: false,
                firstDay: this.date.firstDayOfWeek(),
                locale: I18n.currentLocale(),
                eventClick: info => {
                    info.jsEvent.preventDefault();
                    this.$router.replace({
                        query: {event_id: info.event.id}
                    }).then(()=>{
                        this.bus.publish("show:/driver/component/event-quickview", info.event.id)
                    }).catch((error)=>{})
                },
                dateClick: info => {
                    this.selected_day = info.date
                    this.emptyEventsToday()
                    this.getCalendarEventsDay()
                }
            })
            this.calendar.render()
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
        }

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

        <component-toolbar></component-toolbar>

        <div class="columns">
            <div class="column is-one-quarter">
                <component-agenda></component-agenda>
            </div>
            <div class="column">
                <div class="card">
                    <component-calendar :calendar_id="calendar_id" :key="calendar_id"> </component-calendar>
                </div>
            </div>
        </div>

        <component-event></component-event>

    </section>
</template>
