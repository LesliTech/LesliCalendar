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
        filterEventSource: {
            required: false,
            type: String,
            default: 'all',
        },
        filterQuery: {
            required: false,
            type: String,
            default: ''
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
            translations: {
                core: {
                    shared: I18n.t('core.shared')
                }
            }
        }
    },
    mounted() {
        this.initCalendar()
        this.getCalendarEvents(this.calendar_id)
        this.addListeners()
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
            this.setTitle()
        },

        addListeners() {
            this.bus.subscribe("action:/driver/calendars/components/calendar#prev_month", ($event) => {
                this.loadPrevMonth()
            })

            this.bus.subscribe("action:/driver/calendars/components/calendar#next_month", ($event) => {
                this.loadNextMonth()
            })

            this.bus.subscribe("action:/driver/calendars/components/calendar#current_month", ($event) => {
                this.loadCurrentMonth()
            })
        },

        removeListeners(){
            this.bus.$off("action:/driver/calendars/components/calendar#prev_month")
            this.bus.$off("action:/driver/calendars/components/calendar#next_month")
            this.bus.$off("action:/driver/calendars/components/calendar#current_month")
        },

        setTitle() {
            let title = this.object_utils.translateEnum(this.translations.core.shared, 'view_text_month',this.date.getMonthName(this.calendar.getDate()))
            title = `${title} ${this.calendar.getDate().getFullYear()}`
            this.data.calendar.title = title
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
                )

                // events from CloudFocus tasks
                this.calendarData.focus_tasks.forEach(
                    (task) => {
                        task.url = `focus/tasks/${task.id}`
                        this.calendar.addEvent(task)
                    }
                )

                // Tickets from CloudHelp tickets with deadline
                this.calendarData.help_tickets.forEach(
                    (ticket) => {
                        ticket.url = `help/tickets/${ticket.id}`
                        this.calendar.addEvent(ticket)
                    }
                )
            })
        },
        onDateSelect: function(arg) {
            this.data.agenda_day = arg.date
        },

        onEventClick: function(arg) {
            arg.jsEvent.preventDefault()

            let class_names = arg.event.classNames
            if(class_names.includes('cloud_focus_tasks') || class_names.includes('cloud_help_tickets')){
                window.open(arg.event.url, '_blank')
                return
            }


            this.bus.publish("show:/driver/component/event-quickview", arg.event.id)
            this.data.event.show = true
            this.data.event.id = arg.event.id
        },

        getCalendarEvents(calendar_endpoint) {
            calendar_endpoint = calendar_endpoint || "default"

            let filters = {
                include: {
                    focus_tasks: (this.filterEventSource === "all" || this.filterEventSource === "focus_tasks" ) ? true : false,
                    help_tickets:  (this.filterEventSource === "all" || this.filterEventSource === "help_tickets" ) ? true : false,
                    driver_events: (this.filterEventSource === "all" || this.filterEventSource === "driver_events" ) ? true : false,
                },
                query: this.filterQuery
            }

            let url = this.url.driver('calendars/default').filters(filters).monthTimestamp(this.calendar.getDate())

            this.http.get(url).then(result => {
                this.calendarData = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        loadPrevMonth() {
            this.calendar.prev()
            this.setTitle()
            this.getCalendarEvents()
        },

        loadNextMonth() {
            this.calendar.next()
            this.setTitle()
            this.getCalendarEvents()
        },

        loadCurrentMonth() {
            this.calendar.today()
            this.setTitle()
            this.getCalendarEvents()
        },
    },

    beforeDestroy(){
        this.removeListeners()
    },

    watch: {
        calendarData() {
            this.resetEvents()
        },

        filterEventSource(){
            this.getCalendarEvents()
        },

        filterQuery(){
            this.getCalendarEvents()
        }
    }
}
</script>
<template>
    <div :id="'driver_calendar_'+_uid"></div>
</template>
