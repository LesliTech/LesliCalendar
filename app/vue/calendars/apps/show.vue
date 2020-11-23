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
import dayGridPlugin from "@fullcalendar/daygrid"
import interactionPlugin from "@fullcalendar/interaction"

import componentAgenda from "../../components/agenda.vue"
import componentEvent from "../../components/event-sidebar.vue"



// · 
export default {
    components: {
        "component-agenda": componentAgenda,
        "component-event": componentEvent,
    },
    data(){
        return {
            main_route: "/driver/calendars",
            translations: {
            },
            calendarPlugins: [ dayGridPlugin, interactionPlugin ],
            calendar: {},
        }
    },

    mounted(){
        this.calendar_id = this.$route.params.id
        this.initCalendar()
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

        getCalendarEvents() {

            let query = `month=${ this.calendar.getDate().getMonth() }`
            this.http.get(`/driver/calendars/default.json?${query}`).then(result => {
                console.log(result)

            }).catch(error => {
                console.log(error)
            })
        },

        loadPrevMonth() {
            this.calendar.prev()
        },

        loadNextMonth() {
            this.calendar.next()
        },

        loadCurrentMonth() {
            this.calendar.today()
        },

        showEvent() {
            this.data.event.show = true
        }

    },
    computed: {
        title() {
            if (!this.calendar.getDate) {
                return ""
            }
            return `${this.date.getMonthName(this.calendar.getDate())} ${this.calendar.getDate().getFullYear()}`
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
                            <button class="button" @click="loadPrevMonth()">
                                <span class="icon">
                                    <i class="fas fa-chevron-left"></i>
                                </span>
                                <span>prev</span>
                            </button>
                        </div>
                        <div class="control">
                            <button class="button" @click="loadNextMonth">
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
                        <button class="button" @click="loadCurrentMonth">
                            <span class="icon">
                                <i class="fas fa-calendar-day"></i>
                            </span>
                            <span>today</span>
                        </button>
                        <button class="button" @click="showEvent()">
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
                    <div id="calendar"></div>
                </div>
            </div>
        </div>

        <component-event></component-event>

    </section>
</template>
