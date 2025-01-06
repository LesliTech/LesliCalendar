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

// · 
export const useEvents = defineStore("driver.events", {
    state: () => {
        return {
            showPanel: false,
            event: {
                id: null,
                title: "",
                description: "",
                location: "",
                status: "",
                public: 0,
                start: null,
                end: null,
                url: ""
            },
            options: {
                event_types: []
            }
        }
    },

    actions: {

        getOptions() {
            let url = this.url.driver('events/options')
            this.http.get(url).then(result => {
                if (result) {
                    this.options.event_types = result.event_types.map(option => {
                        return { label: option.text, value: option.value };
                    });
                }
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        reset() {
            this.event = {
                id: null,
                title: "",
                description: "",
                location: "",
                status: "",
                public: 0,
                start_at: null,
                end_at: null,
                url: ""
            }
        },

        get() {
            this.http.get(this.url.calendar("events/:id", this.event.id)).then(result => {
                this.event = result
            }).catch(error => {
                console.log(error)
            })
        },

        post() {
            this.http.post(this.url.calendar('events'), {
                event: this.event
            }).then(event => {
                // let newEvent = {
                //     ...event,
                //     date: event.event_date,
                //     start: event.time_start,
                //     end: event.time_end
                // }
                // this.calendarData.driver_events.push(newEvent);
                // this.calendarData.events.push(newEvent);
                // this.calendar.addEvent(newEvent)
                this.reset()
                this.msg.success(I18n.t("core.users.messages_success_operation"));
            }).catch(error => {
                this.msg.danger(I18n.t("core.users.messages_error_operation"));
                console.log(error)
            });
            
        },

        put(url = this.url.driver(`events/${this.event.id}`)) {
            const storeEvent = useEvent()
            let data = { event: this.event }
            this.submit.event = true
            try {
                const result = this.http.put(url, data)
                let oldEvent = this.calendar.getEventById(this.event_id)
                let updatedEvent = {
                    ...this.event,
                    date: this.event.event_date,
                    start: this.event.time_start,
                    end: this.event.time_end,
                }
                oldEvent.remove()
                this.calendar.addEvent(updatedEvent)
                this.msg.success(I18n.t("core.users.messages_success_operation"))
                storeEvent.showModal = !storeEvent.showModal
            } catch (error) {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            } finally {
                this.submit.event = false
            }
        },

        delete() {
            const storeEvent = useEvent()
            const { isConfirmed } = this.dialog.confirmation({
                title: "Delete event",
                text: "driver.events.view_text_delete_confirmation",
                confirmText: I18n.t("core.shared.view_text_yes"),
                cancelText: I18n.t("core.shared.view_text_no")
            })

            if (isConfirmed) {
                try {
                    storeEvent.submit.delete = true
                    const result = this.http.delete(this.url.driver(`events/${this.event_id}`))
                    let deletedEvent = this.calendar.getEventById(this.event_id)
                    deletedEvent.remove()
                    this.msg.success(I18n.t("core.users.messages_success_operation"))
                    storeEvent.showModal = !storeEvent.showModal
                } catch (error) {
                    this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
                }
            }
            storeEvent.submit.delete = false
            return { isConfirmed }
        }
    }
})
