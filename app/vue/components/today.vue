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


// · Import framework libraries and tools
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import dayjs from "dayjs"


// · 
export default {
    props: {
        date: {
            default: ()=>{
                return new Date()
            }
        },
        driverEvents: {
            default() {
                return []
            },
            required: true
        },
        focusTasks: {
            default() {
                return []
            },
            required: false
        }
    },
    data() {
        return {
            today: new Date(),
            events: [],
            translations: {
                core: I18n.t('deutscheleibrenten.shared')
            }
        }
    },
    mounted() {
        this.validateEvents()
    },
    methods: {
        isToday(date) {
            return (
                date.getDate() == this.today.getDate() &&
                date.getMonth() == this.today.getMonth() &&
                date.getFullYear() == this.today.getFullYear()
            )
        },
        validateEvents() {
            this.events = []
            this.driverEvents.forEach(event => {
                const start = event.start ? new Date(event.start) : null
                this.events.push({
                    id: event.id,
                    title: event.title,
                    start: start,
                    classNames: event.classNames
                })
            })

            this.focusTasks.forEach(task => {
                const start = event.start ? new Date(event.start) : null
                this.events.push({
                    id: task.id,
                    title: task.title,
                    start: start,
                    classNames: task.classNames
                })
            })
        },
        emitShowEvent(event){
            this.data.calendar.selected_event = event
        },
        getDateTitle(date) {
            return this.translations.core[`text_month_${dayjs(this.date).format('MMMM').toLowerCase()}`]
        },
    },
    watch: {
        driverEvents() {
            this.validateEvents()
        }
    }
}
</script>
<template>
    <section class="component-driver-calendar-today">
        <article class="panel">
            <p class="panel-heading">
                <span v-if="isToday(date)">
                    {{ translations.core.text_today }}
                </span>
                <span v-else>
                    {{ getDateTitle(date) + " - " + date.getDate() }}
                </span>
            </p>
            <div v-if="events.length > 0">
            <a  class="panel-block" v-for="(event, index) in events" :key="index" role="button" @click="emitShowEvent(event)">
                
                <span class="icon">
                    <!--
                    <span :class="event.classNames"></span>
                    -->
                    <i class="fas fa-phone-alt"></i>
                </span>

                <b>
                    {{ event.start && ('0' + event.start.getHours()).slice(-2) + ':' + ('0' + event.start.getMinutes()).slice(-2) }}
                </b>
                {{ event.title }}
            </a>
            </div>
            <div  v-else class="panel-block">
                <i class="fa fa-calendar" aria-hidden="true"></i>
                No events
            </div>
        </article>
    </section>
</template>
<style>
    section.component-driver-calendar-today {
        background-color: white;
    }
</style>
