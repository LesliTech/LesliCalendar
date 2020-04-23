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
    props: {
        discussionsTranslationsPath: {
            type: String,
            default : 'core.shared'
        },

        filesTranslationsPath: {
            type: String,
            default: 'core.shared'
        }
    },

    data() {
        return {
            show: false,
            event_id:null,
            active_tab: 0,
            translations: {
                main: I18n.t('driver.events'),
                core: I18n.t('core.shared')
            },
            event: {
                detail_attributes: {
                    title: null,
                    description: '',
                    time_start: new Date(),
                    time_end: new Date(),
                    location: '',
                    url: ''
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
                        description: '',
                        time_start: new Date(),
                        time_end: new Date(),
                        location: '',
                        url: ''
                    }
                }
                this.active_tab = 0
            }
            this.show = !this.show
        },
        getEvent() {
            this.http.get(`/driver/events/${this.event_id}.json`).then(result => {
                if(result.data.detail_attributes.time_start){
                    result.data.detail_attributes.time_start = new Date(result.data.detail_attributes.time_start)
                }
                if(result.data.detail_attributes.time_start){
                    result.data.detail_attributes.time_end = new Date(result.data.detail_attributes.time_end)
                }
                this.event = result.data
            }).catch(error => {
                console.log(error)
            })
        },
        postEvent(e) {
            if (e) { e.preventDefault() }
            this.http.post('/driver/events', {event: this.event}).then(result => {
                this.event.id = result.data.id
                this.event_id = result.data.id
                this.organizer_name = result.data.organizer_name
                this.active_tab = 1
                this.$emit('post-event', result.data)
                this.notification.alert(this.translations.main.notification_event_created, 'success')
            }).catch(error => {
                console.log(error)
            })
        },
        putEvent(e) {
            if (e) { e.preventDefault() }
            this.http.put(`/driver/events/${this.event_id}.json`, {event: this.event}).then(result => {
                this.notification.alert(this.translations.main.notification_event_updated, 'success')
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
        },
        deleteEvent(e){
            if (e) { e.preventDefault() }
            let url = `/driver/events/${this.event_id}`

            this.http.delete(url).then(result => {
                this.show = false
                this.$emit('delete-event', this.event)
                this.notification.alert(this.translations.main.notification_event_deleted, 'success')
            }).catch(error => {
                console.log(error)
            })
        }
    }

}
</script>
<template>
    <div :class="[{ 'is-active': show }, 'quickview', 'is-size-large']">
        <header class="quickview-header">
            <h4 class="title">{{ (this.event.detail_attributes.title ? this.event.detail_attributes.title : this.translations.main.form_title_new) }}</h4>
            <span class="delete" @click="show = false"></span>
        </header>
        <div class="quickview-body">
            <b-tabs expanded v-model="active_tab">
                <b-tab-item :label="translations.core.text_information">
                    <form @submit.prevent="submitEvent()">
                        <div class="field" v-if="event_id">
                            <label class="label">{{translations.core.text_organizer}}</label>
                                <div class="control">
                                <input class="input" type="text" v-model="event.organizer_name" placeholder="Organizer" disabled="true">
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">{{translations.core.text_title}}<sup class="has-text-danger">*</sup></label>
                            <div class="control">
                                <input class="input" type="text" v-model="event.detail_attributes.title" required>
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">{{translations.core.text_description}}</label>
                            <div class="control">
                                <textarea class="textarea" v-model="event.detail_attributes.description"></textarea>
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">{{translations.core.text_address}}</label>
                            <div class="control">
                                <input class="input" type="text" v-model="event.detail_attributes.location">
                            </div>
                        </div>
                        <div class="field">
                            <label class="checkbox">
                                <input type="checkbox" v-model="event.detail_attributes.public">
                                {{translations.main.form_input_mark_event_as_public_title}}
                            </label>
                        </div>
                        <b-field :label="translations.core.text_start_at">
                            <b-timepicker
                                :placeholder="translations.core.text_select_time"
                                icon="clock"
                                v-model="event.detail_attributes.time_start">
                            </b-timepicker>
                        </b-field>
                        <b-field :label="translations.core.text_end_at">
                            <b-timepicker
                                :placeholder="translations.core.text_select_time"
                                icon="clock"
                                v-model="event.detail_attributes.time_end">
                            </b-timepicker>
                        </b-field>
                        <div class="columns">
                            <div class="column">
                                <div class="buttons">
                                    <button v-if="event_id" class="button is-danger" type="button" @click="deleteEvent">
                                        <span class="icon">
                                            <i class="fas fa-trash"></i>
                                        </span>
                                        <span>{{translations.main.form_btn_delete}}</span>
                                    </button>
                                </div>
                            </div>
                            <div class="column">
                                <div class="buttons is-right">
                                    <a class="button is-outlined" v-if="event.model_type == 'CloudHouse::Project'" :href="`/crm/projects/${event.model_id}`">
                                        <span class="icon">
                                            <i class="fas fa-link"></i>
                                        </span>
                                        <span>{{translations.main.form_anchor_go_to_project}}</span>
                                    </a>
                                    <a class="button is-outlined" v-if="event.model_type == 'CloudHouse::Company'" :href="`/crm/companies/${event.model_id}`">
                                        <span class="icon">
                                            <i class="fas fa-link"></i>
                                        </span>
                                        <span>{{translations.main.form_anchor_go_to_company}}</span>
                                    </a>
                                    <a class="button is-outlined" :href="`/driver/events/${event.model_id}.ics`">
                                        <span class="icon">
                                            <i class="fas fa-download"></i>
                                        </span>
                                        <span>{{ translations.core.btn_download }}</span>
                                    </a>
                                    <button class="button is-primary">
                                        <span class="icon">
                                            <i class="far fa-save"></i>
                                        </span>
                                        <span>{{translations.core.btn_save}}</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                    </form>
                </b-tab-item>
                <b-tab-item :label="translations.core.text_employees">
                    <component-attendants v-if="event_id" :event-id="event_id" />
                </b-tab-item>
                <b-tab-item :label="translations.core.text_comments">
                    <component-cloud-object-discussion-simple v-if="event_id" cloud-module="driver/event" :cloud-id="event_id" :translations-path="discussionsTranslationsPath" />
                </b-tab-item>
                <b-tab-item :label="translations.core.text_files">
                    <component-cloud-object-file
                        v-if="event_id"
                        cloud-module="driver/event"
                        :cloud-id="event_id"
                        :translations-path="filesTranslationsPath"
                        translations-file-types-path="driver.events"
                    />
                </b-tab-item>
            </b-tabs>

            <div class="quickview-block">
                
            </div>
        </div>
        <footer class="quickview-footer">

        </footer>
    </div>
</template>
