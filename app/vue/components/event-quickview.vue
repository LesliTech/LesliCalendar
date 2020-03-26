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


// · Import core components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentCloudObjectFile from 'LesliCoreVue/cloud_objects/file.vue'
import componentCloudObjectDiscussionSimple from 'LesliCoreVue/cloud_objects/discussion-simple.vue'
import componentAttendants from './attendants.vue'

// · 
export default {
    components: {
        'component-cloud-object-file': componentCloudObjectFile,
        'component-cloud-object-discussion-simple': componentCloudObjectDiscussionSimple,
        'component-attendants': componentAttendants
    },
    data() {
        return {
            show: false,
            event_id:null,
            active_tab: 0,
            event: {
                detail_attributes: {
                    title: null,
                    description: "",
                    time_start: new Date(),
                    time_end: new Date(),
                    location: "",
                    url: ""
                }
            }
        }
    },
    mounted() {
        this.addListeners()
    },
    methods: {
        addListeners() {
            this.bus.subscribe("show:/driver/component/event-quickview", (event_id) => {
                this.event_id = event_id
                this.getEvent()
                this.show = true
                this.active_tab = 0
            })
        },
        toggleView(new_event) {
            if(new_event){
                this.event_id = null
                this.event =  {
                    detail_attributes: {
                        title: null,
                        description: "",
                        time_start: new Date(),
                        time_end: new Date(),
                        location: "",
                        url: ""
                    }
                }
            }
            this.show = !this.show
        },
        getEvent() {
            this.http.get(`/driver/events/${this.event_id}.json`).then(result => {
                this.event = result.data
            }).catch(error => {
                console.log(error)
            })
        },
        postEvent(e) {
            if (e) { e.preventDefault() }
            this.http.post("/driver/events", {event: this.event}).then(result => {
                this.event_id = event.id
                this.alert("Event succesfully created")
            }).catch(error => {
                console.log(error)
            })
        },
        putEvent(e) {
            if (e) { e.preventDefault() }
            this.http.put(`/driver/events/${this.event_id}.json`, {event: this.event}).then(result => {
                this.alert("Event succesfully updated")
            }).catch(error => {
                console.log(error)
            })
        },
        submitEvent(e) {
            if (e) { e.preventDefault() }
            if (this.event_id) {
                this.putEvent()
                return
            } else {
                this.postEvent()
                return
            }
        }
    }

}
</script>
<template>
    <div :class="[{ 'is-active': show }, 'quickview', 'is-size-large']">
        <header class="quickview-header">
            <h4 class="title">{{ (this.event.detail_attributes.title ? this.event.detail_attributes.title : 'Create new event') }}</h4>
            <span class="delete" @click="show = false"></span>
        </header>
        <div class="quickview-body">
            <b-tabs expanded v-model="active_tab">
                <b-tab-item label="Information">
                    <form @submit.prevent="submitEvent()">
                        <div class="field">
                            <label class="label">Name</label>
                                <div class="control">
                                <input class="input" type="text" v-model="event.detail_attributes.title" placeholder="Title">
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">Description</label>
                                <div class="control">
                                <textarea class="textarea" v-model="event.detail_attributes.description"></textarea>
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">Address</label>
                                <div class="control">
                                <input class="input" type="text" v-model="event.detail_attributes.location" placeholder="Address">
                            </div>
                        </div>
                        <div class="field">
                            <label class="checkbox">
                                <input type="checkbox">
                                Mark to make this event public
                            </label>
                        </div>
                        <b-field label="Start at">
                           <!-- 
                            <b-timepicker
                                placeholder="Select time"
                                icon="clock"
                                v-model="event.detail_attributes.time_start">
                            </b-timepicker>
 -->
                        </b-field>
                        <b-field label="End at">
                            <!-- 
                            <b-timepicker
                                placeholder="Select time"
                                icon="clock"
                                v-model="event.detail_attributes.time_end">
                            </b-timepicker>
 -->
                        </b-field>
                        <div class="buttons is-right">
                            <a class="button is-outlined" v-if="event.model_type == 'CloudHouse::Project'" :href="`/crm/projects/${event.model_id}`">
                                <span class="icon">
                                    <i class="fas fa-link"></i>
                                </span>
                                <span>Go to project</span>
                            </a>
                            <a class="button is-outlined" v-if="event.model_type == 'CloudHouse::Company'" :href="`/crm/companies/${event.model_id}`">
                                <span class="icon">
                                    <i class="fas fa-link"></i>
                                </span>
                                <span>Go to company</span>
                            </a>
                            <button class="button is-primary">
                                <span class="icon">
                                    <i class="far fa-save"></i>
                                </span>
                                <span>Save</span>
                            </button>
                        </div>
                    </form>
                </b-tab-item>
                <b-tab-item label="Employees">
                    <component-attendants v-if="event_id" :event-id="event_id" />
                </b-tab-item>
                <b-tab-item label="Comments">
                    <component-cloud-object-discussion-simple v-if="event_id" cloud-module="driver/event" :cloud-id="event_id" />
                </b-tab-item>
                <b-tab-item label="Documents">
                    <component-cloud-object-file v-if="event_id" cloud-module="driver/event" :cloud-id="event_id" />
                </b-tab-item>
            </b-tabs>

            <div class="quickview-block">
                
            </div>
        </div>
        <footer class="quickview-footer">

        </footer>
    </div>
</template>
