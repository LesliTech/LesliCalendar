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

import dayjs from 'dayjs'

// · 
export default {
    props: {
        events: {
            default() {
                return {
                    driver_events: [],
                    focus_tasks: [],
                    help_tickets: [],
                    integration_events: [],
                }
            }
        },
        loading: {
            required: false,
            default: true,
        },
        agenda_day: null,
    },
    data() {
        return {
            translations: {
                calendars: I18n.t('driver.calendars'),
                core: {
                    shared: I18n.t('core.shared')
                }
            },
            today: [],
            dayjs: null
        }
    },
    mounted() {
        this.dayjs = dayjs
    },
    methods: {
        prepareEvents() {
            this.today = []
            this.events.driver_events.forEach(event => {
                event['module'] = 'driver'
                if (event.description) { event['description'] = event.description.substring(0, 25) }
                if (event.start) { event['start'] = dayjs(event.start).format('HH:mm') }
                if (event.end) { event['end'] = dayjs(event.end).format('HH:mm') }
                this.today.push(event)
            })

            this.events.help_tickets.forEach(event => {
                event['module'] = 'help'
                if (event.description) { event['description'] = event.description.substring(0, 25) }
                if (event.start) { event['start'] = dayjs(event.start).format('HH:mm') }
                if (event.end) { event['end'] = dayjs(event.end).format('HH:mm') }
                this.today.push(event)
            })

            this.events.focus_tasks.forEach(event => {
                event['module'] = 'focus'
                if (event.description) { event['description'] = event.description.substring(0, 40) + '...' }
                if (event.start) { event['start'] = dayjs(event.start).format('HH:mm') }
                if (event.end) { event['end'] = dayjs(event.end).format('HH:mm') }
                this.today.push(event)
            })

            this.events.integration_events.forEach(event => {
                event['module'] = 'integration'
                if (event.description) { event['description'] = event.description.substring(0, 40) + '...' }
                if (event.start) { event['start'] = dayjs(event.start).format('HH:mm') }
                if (event.end) { event['end'] = dayjs(event.end).format('HH:mm') }
                this.today.push(event)
            })
            this.today = this.today.sort(function(a,b){
                return new Date(b.start) - new Date(a.start);
            });
        },

        showEvent(event) {
            if(event.module == 'focus'){
                this.url.go(`/focus/tasks/${event.id}`)
            }else if(event.module == 'help'){
                this.url.go(`/help/tickets/${event.id}`)
            }else{
                this.data.event.id = event.id
                this.data.event.show = true
            }
        }
    },
    watch: {
        events() {
            this.prepareEvents()
        }
    }
}
</script>
<template>
    <section>
        <component-data-loading v-if="loading"></component-data-loading>

        <h3 class="agenda-title is-size-5 mb-5">{{translations.calendars.view_title_upcoming_events}}</h3>
        <h3 class="agenda-title is-size-5 mb-5">{{this.dayjs(this.agenda_day).format('ddd, MMM D YYYY')}}</h3>

        <component-data-empty class="my-6" v-if="!today.length" :text="translations.calendars.view_title_no_activity">
        </component-data-empty>

        <a  @click="showEvent(event)"
            class="media"
            v-for="(event, index) in today"
            :key="index">
            <div class="media-left">
                <span class="icon">
                    <i v-if="event.module == 'driver'" class="driver-color far fa-lg fa-calendar-alt"></i>
                    <i v-if="event.module == 'focus'" class="focus-color far fa-lg fa-check-square"></i>
                    <i v-if="event.module == 'help'" class="help-color far fa-lg fa-life-ring"></i>
                    <i v-if="event.module == 'integration'" class="driver-color far fa-lg fa-calendar-alt"></i>
                </span>
            </div>
            <div class="media-content">
                <div class="content">
                    <p class="m-0">{{ event.title }}</p>
                    <p class="description m-0" v-if="event.description">
                        {{ event.description }}
                    </p>
                    <p class="m-0" v-show="false">
                        <span v-if="event.start">{{ event.start }}</span>
                        <span v-if="event.end">- {{ event.end }}</span>
                    </p>
                </div>
            </div>
        </a>
    </section>
</template>
<style lang="css">

    .driver-color { color: #3689e6; }
    .focus-color { color: #28bca3; }
    .help-color { color: #a56de2; }

    .agenda-title {
        padding-top: 12px;
    }

    .media .media-content p.description {
        font-size: .9rem;
        color: rgb(60,60,60);
    }
</style>
