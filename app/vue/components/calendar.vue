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



// · Import components, libraries and tools
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import interactionPlugin from '@fullcalendar/interaction'


// · 
export default {
    props: {
        calendar_id: {
            required: false,
        },
        main_route: {
            required: false,
            type: String,
            default: '/driver/events',
        },
        filter_event: {
            required: false,
            type: String,
            default: 'all',
        }
    },
    data() {
        return {
            calendarPlugins: [ dayGridPlugin, interactionPlugin ],
            calendar: {},
            calendarData: {
                driver_events: [],
                focus_tasks: [],
                help_tickets: [],
            },
        }
    },
    mounted() {
        this.initCalendar();
        this.getCalendarEvents(this.calendar_id);
        this.addListeners();
    },
    methods: {
        initCalendar() {
            this.calendar = new Calendar(document.getElementById("driver_calendar_"+this._uid), {
                plugins: this.calendarPlugins,
                headerToolbar: false,
                firstDay: this.date.firstDayOfWeek(),
                locale: I18n.currentLocale(),
                dateClick: this.onDateSelect,
                eventClick: this.onEventClick,
                initialView: 'dayGridMonth',
                showNonCurrentDates: false,
                eventContent: function(args) {

                    let title = document.createElement('span')
                    let time = document.createElement('span')

                    title.innerHTML = args.event.title
                    time.innerHTML = args.timeText

                    title.classList.add('event-title')
                    time.classList.add('event-time')

                    return { domNodes: [ title, time ] }

                }
            })
            this.calendar.render()
            this.setTitle();
        },

        addListeners() {
            this.bus.subscribe("action:/driver/calendars/components/calendar#prev_month", ($event) => {
                this.loadPrevMonth();
            });

            this.bus.subscribe("action:/driver/calendars/components/calendar#next_month", ($event) => {
                this.loadNextMonth();
            });

            this.bus.subscribe("action:/driver/calendars/components/calendar#current_month", ($event) => {
                this.loadCurrentMonth();
            });
        },

        setTitle() {
            let title = `${this.date.getMonthName(this.calendar.getDate())} ${this.calendar.getDate().getFullYear()}`
            this.data.calendar.title = title;
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

                // Tickets from CloudHelp tickets with deadline
                this.calendarData.help_tickets.forEach(
                    (event) => {
                        event.url = `${this.main_route}/${event.id}`
                        this.calendar.addEvent(event)
                    }
                );
            })
        },
        onDateSelect: function(arg) {
            this.data.calendar.selected_date = arg.date
        },

        onEventClick: function(arg) {
            arg.jsEvent.preventDefault()
            this.bus.publish("show:/driver/component/event-quickview", arg.event.id)
            const details = {
                "id": arg.event.id,
                "title": arg.event.title,
                "start": arg.event.start,
                "end": arg.event.end,
                "url": arg.event.url,
                "classNames": arg.event.classNames,
                ...arg.event.extendedProps
            }
            this.data.event.details = details;
            this.data.event.show = true;
        },

        getCalendarEvents(calendar_endpoint) {
            calendar_endpoint = calendar_endpoint || "default";

            let filters = {
                include: {
                    focus_tasks: (this.filter_event === "all" || this.filter_event === "focus_tasks" ) ? true : false,
                    help_tickets:  (this.filter_event === "all" || this.filter_event === "help_tickets" ) ? true : false,
                    driver_events: (this.filter_event === "all" || this.filter_event === "driver_events" ) ? true : false,
                },
                month: this.calendar.getDate().getMonth()+1,
                year: this.calendar.getDate().getFullYear(),
            }

            let url = this.url.driver('events').filters(filters)
            this.http.get(url).then(result => {
                this.calendarData = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        loadPrevMonth() {
            this.calendar.prev();
            this.setTitle();
            this.getCalendarEvents();
        },

        loadNextMonth() {
            this.calendar.next();
            this.setTitle();
            this.getCalendarEvents();
        },

        loadCurrentMonth() {
            this.calendar.today();
            this.setTitle();
            this.getCalendarEvents();
        },
    },

    watch: {
        calendarData() {
            this.resetEvents();
        },

        filter_event(){
            this.getCalendarEvents();
        }
    }
}
</script>
<template>
    <div :id="'driver_calendar_'+_uid"></div>
</template>
