/*

Copyright (c) 2023, all rights reserved.

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
import { defineStore } from "pinia"
import dayjs from 'dayjs'


// · import lesli stores
import { useEvents } from 'LesliCalendar/vue/stores/events'
//import { useGuests } from 'lesli_calendar/stores/guests'
//import { useUser } from "LesliVue/stores/user"


// · 
export const useCalendar = defineStore("calendar.calendar", {
    state: () => {

        return {
            title: "",
            calendar: { events: [], events_support: [] },
            calendarObject: null
        }
    },

    actions: {

        setTitle() {

            // if current month show the full date
            if (this.calendarObject.getDate().getMonth() == (new Date()).getMonth()) {
                this.title = this.date().dateWords().toString()
            } else {
                this.title = dayjs(this.calendarObject.getDate()).locale(I18n.locale).format("MMMM, YYYY")
            }
        },

        todayMonth() {
            this.calendarObject.today()
            this.setTitle()
        },

        prevMonth() {
            this.calendarObject.prev()
            this.setTitle()
        },

        nextMonth() {
            this.calendarObject.next()
            this.setTitle()
        },

        getCalendar() {
            this.http.get(this.url.calendar("calendar")).then(result => {
                this.calendar = result
            }).catch(error => {
                console.log(error)
            })
        }
    }
})
