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


// · 
export default {
    props: {
        events: {
            default() {
                return {
                    driver_events: [],
                    focus_tasks: [],
                    help_tickets: []
                }
            }
        },

        loading: {
            required: false,
            default: true,
        }
    },
    data() {
        return {
            translations: {
                calendars: I18n.t('driver.calendars'),
                core: {
                    shared: I18n.t('core.shared')
                }
            },
            today_events: []
        }
    },
    methods: {
        prepareEvents() {
            this.today_events = [
                ...this.events.driver_events.map(event => { event['module'] = 'driver'; return event }), 
                ...this.events.focus_tasks.map(event => { event['module'] = 'focus'; return event }), 
                ...this.events.help_tickets.map(event => { event['module'] = 'help'; return event })
            ]
            this.today_events = this.today_events.sort(function(a,b){
                return new Date(b.start) - new Date(a.start);
            });
        },
        showEvent(event) {
            this.data.event.details = event;
            this.data.event.show = true;
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
        <div v-else class="card">
            <div class="card-header">
                <div class="card-header-title">
                    {{object_utils.translateEnum(translations.core.shared, 'view_text_month', date.getMonthName(data.agenda_day))}}
                    -
                    {{data.agenda_day.getDate()}}
                </div>
            </div>
            <div class="card-content">
                <component-data-empty
                    v-if="events.driver_events.length == 0 && events.focus_tasks.length == 0 && events.help_tickets.length == 0"
                    :text="translations.calendars.view_title_no_activity"
                >
                </component-data-empty>
                <div v-else>
                    <a 
                        class="media"
                        v-on:click.prevent.stop="showEvent(event)" 
                        v-for="(event, index) in today_events" 
                        :key="index">
                        <div class="media-left">
                            <span class="icon">
                                <i v-if="event.module == 'driver'" class="driver-color far fa-lg fa-calendar-alt"></i>
                                <i v-if="event.module == 'focus'" class="focus-color far fa-lg fa-check-square"></i>
                                <i v-if="event.module == 'help'" class="help-color far fa-lg fa-life-ring"></i>
                            </span>
                        </div>
                        <div class="media-content">
                            <div class="content">
                                <p class="mb-0">
                                    <span>{{ event.title }}</span>
                                    <small>{{ event.event_date_string }}</small>
                                </p>
                            </div>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </section>
</template>
<style lang="css">

    .driver-color { color: #3689e6; }
    .focus-color { color: #28bca3; }
    .help-color { color: #a56de2; }

    div.box .media .media-left {
        align-self: center;   
    }
    div.box .media .media-content p span {
        font-size: 1.1rem;
        line-height: 1.2;
        display: block;
        color: rgb(60,60,60);
    }
    div.box .media .media-content p small {
        font-size: .8rem;
        color: rgb(100,100,100);
    }
</style>
