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
import interactionPlugin from '@fullcalendar/interaction'


// · 
export default {
    props: {
        calendarData: {
            required: true
        },
        main_route: {
            required: false,
            type: String,
            default: '/driver/events',
        }
    },
    data() {
        return {
            calendarPlugins: [ dayGridPlugin, interactionPlugin ],
            calendar: {},
        }
    },
    mounted() {
        this.initCalendar()
        this.resetEvents()
    },
    methods: {
        initCalendar() {
            this.calendar = new Calendar(document.getElementById("driver_calendar_"+this._uid), {
                plugins: this.calendarPlugins,
                header: false,
                dateClick: this.onDateSelect,
                eventClick: this.onEventClick,
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
                this.calendarData.driver_events.forEach(
                    (event) => {
                        event.url = `${this.main_route}/${event.id}`
                        this.calendar.addEvent(event)
                    }
                );

                // events from CloudFocus tasks
                this.calendarData.focus_tasks.forEach(
                    (event) => {
                        event.url = `${this.main_route}/${event.id}`
                        this.calendar.addEvent(event)
                    }
                );
                
            })

        },
        onDateSelect: function(arg) {
            this.bus.publish('index:/driver/components/calendar', arg.date)
        },

        onEventClick: function(arg) {
            arg.jsEvent.preventDefault()
            this.bus.publish('show:/driver/components/calendar/event', arg.event)
        },
    },

    watch: {
        calendarData: function(){
            this.resetEvents()
        }
    }
}
</script>
<template>
    <div :id="'driver_calendar_'+_uid"></div>
</template>
