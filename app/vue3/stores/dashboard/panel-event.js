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
export const usePanelEvent = defineStore("driver.panelEvent", {
    state: () => {
        return {
            showModal: false,
            event: {
                cloud_driver_catalog_event_types_id: null,
                id: null,
                organizer_name: '',
                title: null,
                description: '',
                event_date: new Date(),
                time_start: null,
                time_end: null,
                location: '',
                url: ''   
            },
            options: {
                event_types: []
            },
        }
    },

    actions: {
        
        reset() {
            this.event.cloud_driver_catalog_event_types_id = null
            this.event.id = null
            this.event.title = null
            this.event.description = ''
            this.event.event_date = new Date()
            this.event.time_start = null
            this.event.time_end = null
            this.event.location = ''
            this.event.url = ''

        },

        getOptions(){
            let url = this.url.driver('events/options')

            this.http.get(url).then(result => {
                if (result) {
                    this.options.event_types = result.event_types.map(option => {
                        return {label: option.text, value: option.value };
                      });
                }
            }).catch(error => {
                this.msg.danger(I18n.t("core.shared.messages_danger_internal_error"))
            })
        },

        postEvent() {
        }
    }
})