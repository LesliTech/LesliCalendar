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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~

import Calendar from '../components/calendar.vue'
import Today from '../../components/today.vue'

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


export default {
    props: {

    },
    
    components: {
        'calendar': Calendar,
        'today': Today,
    },

    data(){
        return {
            main_route: '/driver/calendars',
            calendar_data: {
                driver_events: [],
                focus_tasks: []
            },
            today_data: {
                driver_events: [],
            },
            calendar_id: null,
        }
    },

    mounted(){
        this.setCalendarId()
        this.addListeners()
        this.getCalendar()
    },

    methods: {
        addListeners() {
            this.bus.subscribe("index:/driver/components/calendar", (date) => {
                this.setEventsForTodayComponent(date)
            })
        },

        setCalendarId(){
            this.calendar_id = this.$route.params.id
        },

        getCalendar(){
            let url = `${this.main_route}/${this.calendar_id}.json`
            this.http.get(url).then(result => {
                if (result.successful) {
                    this.calendar_data = result.data
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        setEventsForTodayComponent(date){
            let params = {
                day: date.getDate(),
                month: date.getMonth()+1,
            }
            let url = '/driver/events.json/'
            this.http.get(url, {params}).then(result => {
                if (result.successful) {
                    this.today_data = result.data
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header title='Calendar'></component-header>

        <div class="columns">
            <div class="column">
                <div class="card">
                    <div class="card-content">
                        <today
                            :driverEvents="today_data.driver_events"
                            :focusTasks="[]"
                        ></today>
                    </div>
                </div>
            </div>
            <div class="column is-four-fifths">
                <div class="card">
                    <div class="card-content">
                        <calendar :calendarData="calendar_data" :key="calendar_id"> </calendar>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>

