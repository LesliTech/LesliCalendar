<script>
/*
Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

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
    // @data_variable events [Object] An object representing a Events, with
    //      the same params as the associated rails model
    // @data_variable events_id [String|Integer] The id of the Events, as
    //      obtained from the route using the *Vue-router* *params* 
    data(){
        return {
            main_route: '/driver/events',
            events: null,
            events_id: null
        }
    },

    // @return [void]
    // @description Executes the necessary methods needed to initialize this component
    mounted(){
        this.seteventsId()
        this.getevents()
    },

    methods: {

        // @return [void]
        // @description Retrieves the id of the Events and stores it in the data variable events_id
        // @example
        //      console.log(this.events_id) // will display null
        //      this.seteventsId()
        //      console.log(this.events_id) // will display a number, like 5
        seteventsId(){
            this.events_id = this.$route.params.id
        },

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves the Events associated to
        //      the variable *Events_id*. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.events) // will display null
        //      this.getevents()
        //      console.log(this.events) // will display an object representation of the Events
        getevents(){
            this.http.get(`${this.main_route}/${this.events_id}.json`).then(result => {
                if (result.successful) {
                    this.events = result.data
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header title="Edit Event">
            <div class="is-grouped">
                <router-link class="button" :to="`/${events_id}`">
                    <span class="icon">
                        <i class="fas fa-eye"></i>
                    </span>
                    <span>Show Event</span>
                </router-link>
                <router-link class="button" to="/">
                    <span class="icon">
                        <i class="fas fa-undo"></i>
                    </span>
                    <span>Return</span>
                </router-link>
            </div>
        </component-header>
        <component-form v-if="events" :event-id="events_id" view-type="edit"/>
    </section>
</template>
