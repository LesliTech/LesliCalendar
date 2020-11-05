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
        seteventId(){            
            this.event_id = this.eventId
        },

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
    },

    computed: {
        event_date() {
            let time_start = new Date(this.event.detail_attributes.time_start)
            return `${time_start.getUTCFullYear()}-${(time_start.getUTCMonth() + 1)}-${time_start.getUTCDate()}`
            return time_start
        },

        time_start_end() {
            let time_start = new Date(this.event.detail_attributes.time_start)
            let time_end = new Date(this.event.detail_attributes.time_end)
            return `${time_start.getUTCHours()}:${time_start.getUTCMinutes()} to ${time_end.getUTCHours()}:${time_end.getUTCMinutes()}`
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
                            {{event_date}} - {{time_start_end}}
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
