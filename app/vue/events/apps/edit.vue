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


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


export default {
    props: {

    },

    components: {
        'component-form': componentForm
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable event [Object] An object representing a Event, with
    //      the same params as the associated rails model
    // @data_variable event_id [String|Integer] The id of the Event, as
    //      obtained from the route using the *Vue-router* *params* 
    data(){
        return {
            translations: {
                main: I18n.t('driver.events'),
                core: I18n.t('core.shared')
            },
            event: null,
            event_id: null
        }
    },

    // @return [void]
    // @description Executes the necessary methods needed to initialize this component
    mounted(){
        this.seteventId()
        this.getEvent()
    },

    methods: {

        // @return [void]
        // @description Retrieves the id of the Event and stores it in the data variable event_id
        // @example
        //      console.log(this.event_id) // will display null
        //      this.seteventId()
        //      console.log(this.event_id) // will display a number, like 5
        seteventId(){
            this.event_id = this.$route.params.id
        },

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves the Event associated to
        //      the variable *Event_id*. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.event) // will display null
        //      this.getEvent()
        //      console.log(this.event) // will display an object representation of the Event
        getEvent(){
            let url = this.url.driver(`events/${this.event_id}`)

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.event = this.parseEvent(result.data)
                    this.data.event = this.event
                }else{
                    this.msg.error(result.error.message)
                }
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
            
            return event
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="`${translations.main.view_title_edit}: ${data.event.detail_attributes.title || ''}`">
            <div class="buttons">
                <router-link class="button" to="/">
                    <b-icon icon="list" size="is-small" />
                    <span>{{ translations.core.view_btn_list }}</span>
                </router-link>
                <router-link class="button" :to="`/${event_id}`">
                    <b-icon icon="eye" size="is-small" />
                    <span>{{ translations.core.view_btn_show }}</span>
                </router-link>
            </div>
        </component-header>
        <component-form v-if="event" :event-id="event_id" view-type="edit" ></component-form>
        <component-data-loading v-else></component-data-loading>
    </section>
</template>
