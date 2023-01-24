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

// · Import components, libraries and tools

// · 
export const useShow = defineStore("driver.show", {
    state: () => {
        return {
            filters_ready: false,
            main_route: "/driver/calendars",
            translations: {
                calendars: I18n.t('driver.calendars'),
                events: I18n.t('driver.events')
            },
            calendar_id: null,
            filters: {
                event_category: "all",
                query: ""
            },
            options: {
                event_categories: []
            },
            loading: true,
            events_day: [],
            loading_agenda: true,
            synchronized_google: null,
        }
    },

    actions: {

        setSessionStorageFilters(){
            let stored_filters = this.storage.local("filters")

            if(stored_filters){
                for(let key in stored_filters){
                    this.$set(this.filters, key, stored_filters[key])
                }
            }

            this.filters_ready = true
        },

        setTitle() {
            return this.date.dateWords()
        }  
    }
})