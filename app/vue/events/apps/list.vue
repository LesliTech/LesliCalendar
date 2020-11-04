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


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    props: {

    },
    
    components: {

    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable events [Array] An array of objects, each object represents a 
    //      Events, with the same params as the associated rails model
    data(){
        return {
            main_route: '/driver/events',
            events: [],
            reloading: false,
            columns: [{
                field: "id",
                label: "ID",
                width: "40"
            }, {
                field: "title",
                label: "Title",
            }]
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
       this.getEvents()
    },

    methods: {

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of Events associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.events) // will display null
        //      this.getEvents()
        //      console.log(this.events) // will display an array of objects, each representing a Events.
        getEvents() {
            this.http.get(`${this.main_route}.json`).then(result => {
                this.reloading = false
                if (result.successful) {
                    if(result.data) this.events = result.data;
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        // @return [void]
        // @param events [Object] The object representation of the selected Events
        // @description Redirects the router to show the selected Events
        // @example
        //      this.showevents(this.events[1])
        //      // Asume the id of the Events is 4
        //      // The user will be redirected to the url /driver/events/4
        showEvents(events) {
            this.$router.push(`/${events.id}`)
        },

        reloadevents() {
            this.reloading = true
            this.getEvents()
        }
    },

    computed: {

        // @return [String] The class that is used to give a spinning animation to the icon (if needed)
        // @description When the user clicks the 'reload' button, it changes the value of the *reloading*
        //      data variable. And that is used by this method to change the class of the icon and add it
        //      the spinning animation
        reloadingClass(){
            if(this.reloading){
                return 'fa-spin'
            }

            return ''
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header title="Events">
            <div class="is-grouped">
                <router-link class="button" to="/new">
                    <span class="icon">
                        <i class="fas fa-plus"></i>
                    </span>
                    <span>Add new Event</span>
                </router-link>
            </div>
        </component-header>
        <div class="card mb-3">
            <header class="card-header">
                <p class="card-header-title">
                    Events
                </p>
            </header>
            <div class="card-content">
                <b-table
                    @click="showEvents"
                    :data="events.driver_events" 
                    :columns="columns">
                </b-table>
            </div>
        </div>
        <div class="card mb-3">
            <header class="card-header">
                <p class="card-header-title">
                    Tasks
                </p>
            </header>
            <div class="card-content">
                <b-table
                    @click="showEvents"
                    :data="events.focus_tasks" 
                    :columns="columns">
                </b-table>
            </div>
        </div>
        <div class="card mb-3">
            <header class="card-header">
                <p class="card-header-title">
                    Help Tickets
                </p>
            </header>
            <div class="card-content">
                <b-table
                    @click="showEvents"
                    :data="events.help_tickets" 
                    :columns="columns">
                </b-table>
            </div>
        </div>
    </section>
</template>
