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

export default {
    props: {
        eventId: {
            required: true
        }
    },

    data() {
        return {
            event: {
                detail_attributes: {}
            },
            translations: {
                main: I18n.t('driver.events')
            }
        }
    },

    mounted(){
        this.setEvent()
    },

    methods: {
        setEvent(){
            this.event = this.data.event
        }
    }

}
</script>
<template>
    <div class="card">
            <div class="card-content">
                <div class="media">
                    <div class="media-content">
                        <p class="title is-4">{{event.detail_attributes.title}}</p>
                    </div>
                </div>
                <div class="content">
                    <p class="subtitle is-6">
                        <i class="fas fa-calendar" aria-hidden="true"></i>
                        <b>{{translations.main.column_event_date}}</b>:
                        {{date.toStringDatetime(event.detail_attributes.time_start)}} - 
                        {{date.toStringTime(event.detail_attributes.time_end)}}
                    </p>
                    <p class="subtitle is-6">
                        <i class="fa fa-map-marker" aria-hidden="true"></i>
                        <b>{{translations.main.column_location}}</b>: {{event.detail_attributes.location}}
                    </p>
                    <p class="subtitle is-6">
                        <i class="fas fa-info-circle" aria-hidden="true"></i>
                        <b>{{translations.main.column_description}}</b>: {{event.detail_attributes.description}}
                    </p>
                </div>
            </div>
        </div>
</template>
