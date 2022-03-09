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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentForm from '../components/form.vue'
import eventComponent from '../components/event.vue'


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


export default {  
    components: {
        'component-form': componentForm,
        'event-component': eventComponent
    },
    
    data(){
        return {
            event_id: null,
            event: null,
            translations: {
                main: I18n.t('driver.events'),
                core: I18n.t('core.shared')
            }
        }
    },

    mounted(){
        this.setEventId()
        this.getEvent()
    },

    methods: {
        setEventId(){
            this.event_id = this.$route.params.id
        },

        getEvent(){
            let url = this.url.driver(`events/${this.event_id}`)

            this.http.get(url).then(result => {
                this.$set(this.data, 'event', this.parseEvent(result.data))
                this.event = this.data.event
            }).catch(error => {
                console.log(error)
            })
        },

        parseEvent(event){
            if(event.detail_attributes.time_start){
                event.detail_attributes.time_start = new Date(event.detail_attributes.time_start)
            }
            if(event.detail_attributes.time_end){
                event.detail_attributes.time_end = new Date(event.detail_attributes.time_end)
            }
            event.detail_attributes.event_date = event.detail_attributes.time_start
            
            return event
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="`${translations.main.view_title_show}: ${data.event.detail_attributes.title || ''}`">
            <div class="buttons">
                <router-link class="button" to="/">
                    <b-icon icon="list" size="is-small" />
                    <span>{{ translations.core.view_btn_list }}</span>
                </router-link>
                <router-link class="button" :to="`/${event_id}/edit`">
                    <b-icon icon="edit" size="is-small" />
                    <span>{{ translations.core.view_btn_edit }}</span>
                </router-link>
            </div>
        </component-header>
        <event-component v-if="event" :event-id="event_id"></event-component>
        <component-data-loading v-else></component-data-loading>
    </section>
</template>
