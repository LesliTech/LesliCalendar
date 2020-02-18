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



// · Import components, libraries and tools
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import componentList from '../components/list.vue'



// · 
export default {
    components: {
        'component-list': componentList
    },
    data() {
        return {
            calendarPlugins: [ dayGridPlugin ],
            calendarData: {},
            calendar: {},
        }
    },
    mounted() {
        this.initCalendar()
        this.getDefaultCalendar()
        
    },
    methods: {

        initCalendar() {
            this.calendar = new Calendar(document.getElementById("calendar"), {
                plugins: this.calendarPlugins,
                header: false
            })
            this.calendar.render()
        },

        resetEvents() {

            this.calendar.batchRendering(() => {

                // get rendered events in calendar
                let events = this.calendar.getEvents()

                // remove events from calendar
                events.forEach(event => event.remove() )

                // events from my calendar
                this.calendarData.events.forEach(event => this.calendar.addEvent(event))

                // events from CloudFocus tasks
                this.calendarData.focus_tasks.forEach(event => this.calendar.addEvent(event))
                
            })

        },
        
        getDefaultCalendar() {
            this.http.get("/driver/calendars/default.json").then(result => {
                this.calendarData = result.data
                this.resetEvents()
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="section">
        <div class="columns">
            <div class="column is-3">
                <component-list />
            </div>
            <div class="column is-9">
                <div class="card">
                    <div class="card-content is-paddingless">
                        <div id="calendar"></div>
                    </div>
                </div>        
            </div>
        </div>
    </section>
</template>
<style>
    
</style>
