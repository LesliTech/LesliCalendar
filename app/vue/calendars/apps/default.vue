<script>
/*
Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

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

@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/



// · Import components, libraries and tools
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import FullCalendar from '@fullcalendar/vue'
import dayGridPlugin from '@fullcalendar/daygrid'
import componentList from '../components/list.vue'



// · 
export default {
    components: {
        'full-calendar': FullCalendar,
        'component-list': componentList
    },
    data() {
        return {
            calendarPlugins: [ dayGridPlugin ],
            calendar: {}
        }
    },
    mounted() {
        this.getCalendar()
    },
    methods: {
        
        getCalendar() {
            this.http.get('/driver/calendar.json').then(result => {
                //console.log(JSON.parse(JSON.stringify(result.data)))
                this.calendar = result.data
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
                    <div class="card-content">
                        <full-calendar defaultView="dayGridMonth" :plugins="calendarPlugins" :events="calendar.events" />
                    </div>
                </div>        
            </div>
        </div>
    </section>
</template>
