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
import { useCalendar } from 'CloudDriver/stores/calendar'
// · import vue tools
import { inject } from "vue"


// · 
export const useGuests = defineStore("driver.guests", {
    state: () => {
        return {
            users_route: '/administration/users/list.json?role=kop,callcenter,api,support&type=exclude',
            main_route: `/driver/events`,
            attendant_options: {
                users: []
            },
            loading: {
                attendants: false,
                options: false
            },
            lists_synched: false,
            loaded: {
                attendants: false,
                attendant_options: false
            },
            attendants: [],

            translations: {
                main: I18n.t('driver.events'),
                core: I18n.t('core.shared'),
                core_users: I18n.t('core.users'),
                users: I18n.t('deutscheleibrenten.users'),
                attendants: I18n.t('driver.event/attendants')
            }
        }
    },

    actions: {
        getUsers() {
            this.http.get(this.users_route).then(result => {
                this.loading.attendants = false
                this.attendant_options.users = [...result].map(user => {
                    const checked = this.attendants.findIndex(attendant => attendant.email === user.email) !== -1;
                    return { ...user, checked }
                })
                this.loaded.attendant_options = true
            }).catch(error => {
                console.log(error)
            })
        },

        getAttendants() {
            const storeCalendar = useCalendar()
            let url = `${this.main_route}/${storeCalendar.event.id}/attendants.json`
            this.loading.attendants = true
            this.http.get(url).then(result => {
                this.loading.attendants = false
                const filteredGuests = result.filter((guest, index, self) =>
                    self.findIndex(record => record.email === guest.email) === index
                )
                this.attendants = filteredGuests
                this.loaded.attendants = true
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        postAttendant(user) {
            const storeCalendar = useCalendar()
            let url = this.url.driver("events/:event_id/attendants", { event_id: storeCalendar.event.id })
            let data = {
                event_attendant: {
                    users_id: user.id
                }
            }
            this.http.post(url, data).then(result => {
                this.attendants.push({
                    id: result.id,
                    type: 'attendant',
                    name: user.name || user.email,
                    email: user.email,
                    users_id: user.id,
                    confirmed_at_string: null
                })
                this.msg.success(this.translations.main.messages_success_attendant_created)

            }).catch(error => {
                this.msg.danger(this.translations.core.shared.messages_danger_internal_error);
            })
        },

        deleteInvite(guest) {
            const storeCalendar = useCalendar()
            let attendant = this.attendants.find(attendant => {
                return attendant.email === guest.email
            })
            let url = `${this.main_route}/${storeCalendar.event.id}/attendants/${attendant.id}.json`

            // If this is a guest, we have a different endpoint
            if (guest.type == 'guest') {
                url = `${this.main_route}/${storeCalendar.event.id}/guests/${attendant.id}.json`
            }

            this.http.delete(url).then(result => {
                this.attendants = this.attendants.filter((attendant) => {
                    return attendant.email !== guest.email
                })
                this.msg.success(this.translations.main.messages_success_attendant_deleted)
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        confirmAttendance(guest, today) {
            const storeCalendar = useCalendar()
            let newAttendants = this.attendants.map(attendant => {
                if (attendant.email === guest.email) attendant.confirmed_at_string = today
                return attendant
            })
            let url, data;

            this.loading.attendants = true
            // working with attendants
            if (guest.users_id) {
                url = this.url.driver("events/:event_id/attendants/:attendant_id", {
                    event_id: storeCalendar.event.id,
                    attendant_id: guest.id
                })
                data = { event_attendant: guest }
            }

            // working with guests
            if (!guest.users_id) {
                url = this.url.driver("events/:event_id/guests/:attendant_id", {
                    event_id: storeCalendar.event.id,
                    attendant_id: guest.id
                })
                data = { event_guest: guest }
            }

            this.http.put(url, data).then(result => {
                this.$patch({ attendants: newAttendants })
                this.msg.success(this.translations.core.users.messages_success_operation)
            }).catch(error => {
                console.log(error)
                this.msg.danger(this.translations.core.shared.messages_danger_internal_error);
            }).finally(() => {
                this.loading.attendants = false
            })
        }



    }
})