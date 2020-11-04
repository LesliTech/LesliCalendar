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

export default {
    props: {
        eventId: {
            required: true
        }
    },

    data() {
        return {
            main_route: '/driver/events',
            event: {
                detail_attributes: {
                    title: '',
                    description: '',
                    event_date: '',
                    time_start: '',
                    time_end: '',
                    location: ''
                }
            },
            event_id: null
        }
    },

    mounted(){
        this.seteventId()
        this.getevent()
    },

    methods: {

        // @return [void]
        // @description Retrieves the id of the event and stores it in the data variable event_id
        // @example
        //      console.log(this.event_id) // will display null
        //      this.seteventId()
        //      console.log(this.event_id) // will display a number, like 5
        seteventId(){            
            this.event_id = this.eventId
        },

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves the event associated to
        //      the variable *event_id*. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.event) // will display null
        //      this.getevent()
        //      console.log(this.event) // will display an object representation of the event
        getevent(){
            let url = `${this.main_route}/${this.event_id}.json`
            this.http.get(url).then(result => {
                if (result.successful) {
                    this.event = result.data
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
    <div class="card">
            <div class="card-content">
                <div class="media">
                    <div class="media-content">
                        <p class="title is-4">{{event.detail_attributes.title}}</p>
                        <p class="subtitle is-6">
                            {{event.detail_attributes.event_date}}
                        </p>
                    </div>
                </div>
                <div class="content">
                    <p class="subtitle is-6">
                        <i class="fa fa-map-marker" aria-hidden="true"></i>
                        {{event.detail_attributes.location}}
                    </p>
                    <p class="subtitle is-6">
                        {{event.detail_attributes.description}}
                    </p>
                </div>
            </div>
        </div>
</template>
