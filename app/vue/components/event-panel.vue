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
import DatePicker from 'v-calendar/lib/components/date-picker.umd'

import componentCloudObjectDiscussionSimple from 'LesliCoreVue/cloud_objects/discussion-simple.vue'
import componentCloudObjectFile from 'LesliCoreVue/cloud_objects/file.vue'
import componentSidebarView from 'LesliVue/components/views/sidebar-view.vue'
import componentAttendants from './attendants.vue'


export default {
    components: {
        'component-cloud-object-discussion-simple': componentCloudObjectDiscussionSimple,
        'component-cloud-object-file': componentCloudObjectFile,
        "component-sidebar-view": componentSidebarView,
        'component-attendants': componentAttendants,
        'vc-date-picker': DatePicker
    },

    data(){
        return {
            active_tab: 0,
            translations: {
                events: I18n.t('driver.events'),
                core: I18n.t('core.shared')
            },
            submit: {
                event: false,
                delete: false
            },
            event: {
                detail_attributes: {
                    title: null,
                    description: '',
                    event_type: null,
                    event_date: null,
                    time_start: null,
                    time_end: null,
                    location: '',
                    url: ''
                }
            },
            options: {
                event_types: []
            },
            loading: {
                event: false
            }
        }
    },

    mounted(){
        this.getOptions()
    },

    methods: {
        getOptions(){
            let url = this.url.driver('events/options')
            this.http.get(url).then(result => {
                if (result.successful) {
                    for(let key in result.data){
                        this.$set(this.options, key, result.data[key])
                    }
                }
            }).catch(error => {
                console.log(error)
            }) 
        },

        setEvent(){
            if(this.data.event.id){
                this.getEvent()
            }else{
                this.setEmptyEvent()
            }
        },

        submitEvent(event){
            if(event){
                event.preventDefault()
            }

            this.syncEventDateTime()
            if(this.event.id){
                this.putEvent()
            }else{
                this.postEvent()
            }
            this.bus.publish("action:/driver/calendars/components/calendar#reload_events", event)
        },

        postEvent(){
            this.submit.event = true
            let url = this.url.driver('events')
            let data = {
                event: this.event
            }

            this.http.post(url, data).then(result => {
                if(result.successful){
                    this.data.event.id = result.data.id

                    this.$set(this.event, 'id', result.data.id)
                    this.$set(this.event, 'editable', true)
                    this.$set(this.event, 'organizer_name', result.data.organizer_name)
                    this.active_tab = 1

                    this.$emit('post-event', result.data)
                    this.bus.publish("post:/driver/event")
                    this.msg.success(this.translations.events.messages_success_event_created)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(()=>{
                this.submit.event = false
            })
        },

        putEvent(){
            this.submit.event = true
            let url = this.url.driver(`events/${this.event.id}`)
            let data = {
                event: this.event
            }

            this.http.put(url, data).then(result => {
                if (result.successful) {
                    this.bus.publish("put:/driver/event")
                    this.msg.success(this.translations.events.messages_success_event_updated)
                } else {
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(()=>{
                this.submit.event = false
            })
        },

        setEmptyEvent(){
            this.event = {
                detail_attributes: {
                    event_type: null,
                    title: null,
                    description: '',
                    event_date: null,
                    time_start: null,
                    time_end: null,
                    location: '',
                    url: ''
                }
            }
        },

        getEvent(){
            this.loading.event = true

            let url = this.url.driver(`events/${this.data.event.id}`)
            this.http.get(url).then(result => {
                if(result.successful){
                    this.event = this.parseEvent(result.data)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(()=>{
                this.loading.event = false
            })
        },

        parseEvent(event){
            ['event_date', 'time_start', 'time_end'].forEach((attribute)=>{
                if(event.detail_attributes[attribute]){
                    event.detail_attributes[attribute] = new Date(event.detail_attributes[attribute])
                }
            })
            
            return event
        },

        deleteEvent(){
            let url = this.url.driver(`events/${this.event.id}`)
            this.submit.delete = true

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.data.event.show = false
                    this.$emit('delete-event', this.event)
                    this.msg.success(this.translations.events.messages_success_event_destroyed)
                    this.bus.publish("action:/driver/calendars/components/calendar#reload_events")
                } else {
                    this.msg.error(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        syncEventDateTime(){
            const event = { ...this.event, ...this.event.detail_attributes }
            if (event.time_start) {
                this.event.detail_attributes.time_start = this.parseDate(event.time_start);
                this.event.detail_attributes.time_end = this.parseDate(event.time_end || event.time_start);
            }
        },

        parseDate(time) {
            const date = new Date(this.event.detail_attributes.event_date);
            date.setHours(time.getHours());
            date.setMinutes(time.getMinutes());
            return date;
        }
    },

    watch: {
        "data.event.id"(){
            this.setEvent()
        },

        'event.detail_attributes.event_date'(event_date) {
            this.syncEventDateTime()
        }
    },

    computed: {
        eventEditable(){
            return (! this.event_id) || this.event.editable
        }
    }
}
</script>
<template>
    <component-sidebar-view :open.sync="data.event.show" size="medium" :can-cancel="['escape']">
        <div class="box is-shadowless has-background-primary">
            <div class="columns">
                <div class="column is-11">
                    <h4 class="title is-4 has-text-white">
                        <span v-if="data.event.id">
                            {{event.detail_attributes.title}}
                        </span>
                        <span v-else>
                            {{translations.events.view_title_new}}
                        </span>
                    </h4>
                </div>
                <div class="column is-1">
                    <span class="delete is-pulled-right" @click="() => data.event.show = false">
                    </span>
                </div>
            </div>
        </div>
        <component-data-loading v-if="loading.event">
        </component-data-loading>
        <b-tabs v-else expanded v-model="active_tab">
            <b-tab-item :label="translations.core.view_tab_title_general_information">
                <form @submit.prevent="submitEvent()">
                    <fieldset :disabled="submit.event">
                        <b-field v-if="data.event.id" :label="translations.events.column_user_main_id">
                            <b-input type="text" name="organizer_name" v-model="event.organizer_name" readonly>
                            </b-input>
                        </b-field>
                        <b-field>
                            <template v-slot:label>
                                {{ translations.events.column_title }}
                                <sup class="has-text-danger">*</sup>
                            </template>
                            <b-input type="text" name="title" v-model="event.detail_attributes.title" required :readonly="!eventEditable">
                            </b-input>
                        </b-field>
                        <div class="columns">
                            <div class="column is-4">
                                <b-field>
                                    <template v-slot:label>
                                        {{ translations.events.column_event_date }}
                                        <sup class="has-text-danger">*</sup>
                                    </template>
                                    <vc-date-picker
                                        v-model="event.detail_attributes.event_date"
                                        :locale="date.vcDatepickerConfig()"
                                        :popover="{ visibility: 'focus' }"
                                    >
                                        <template v-slot="{ inputValue, inputEvents }">
                                            <input
                                                name="`event_date`"
                                                class="input is-default"
                                                v-on="inputEvents"
                                                :value="inputValue"
                                                :placeholder="translations.core.view_placeholder_select_date"
                                                :disabled="!eventEditable"
                                                required
                                            />
                                        </template>
                                    </vc-date-picker>
                                </b-field>
                            </div>
                            <div class="column is-4">
                                <b-field :label="translations.events.column_time_start">
                                    <b-timepicker
                                        name="time_start"
                                        v-if="eventEditable"
                                        editable
                                        :placeholder="translations.core.view_placeholder_select_date"
                                        icon="clock"
                                        default-minutes="0"
                                        v-model="event.detail_attributes.time_start">
                                    </b-timepicker>
                                    <div v-else class="control has-icons-left is-clearfix">
                                        <input type="text" autocomplete="off" class="input" readonly :value="date.toStringTime(event.detail_attributes.time_start)">
                                        <span class="icon is-left"><i class="fas fa-clock fa-lg"></i></span>
                                    </div>
                                </b-field>
                            </div>
                            <div class="column is-4">
                                <b-field :label="translations.events.column_time_end">
                                    <b-timepicker
                                        name="time_end"
                                        v-if="eventEditable"
                                        editable
                                        :placeholder="translations.core.view_placeholder_select_date"
                                        icon="clock"
                                        default-minutes="0"
                                        v-model="event.detail_attributes.time_end">
                                    </b-timepicker>
                                    <div v-else class="control has-icons-left is-clearfix">
                                        <input type="text" autocomplete="off" class="input" readonly :value="date.toStringTime(event.detail_attributes.time_start)">
                                        <span class="icon is-left"><i class="fas fa-clock fa-lg"></i></span>
                                    </div>
                                </b-field>
                            </div>
                        </div>
                        <div class="columns">
                            <div class="column is-7">
                                <b-field :label="translations.events.column_location">
                                    <b-input type="text" name="address" v-model="event.detail_attributes.location" :readonly="!eventEditable">
                                    </b-input>
                                </b-field>
                            </div>
                            <div class="column is-5">
                                <b-field>
                                    <template v-slot:label>
                                        {{ translations.events.column_event_type }}
                                        <sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-select
                                        name="event_type"
                                        v-model="event.detail_attributes.event_type"
                                        :disabled="! eventEditable"
                                        expanded
                                        :placeholder="translations.core.view_placeholder_select_option"
                                        required
                                    >
                                        <option
                                            v-for="event_type in options.event_types"
                                            :value="event_type.value"
                                            :key="event_type.value"
                                        >
                                            {{ event_type.text }}
                                        </option>
                                    </b-select> 
                                </b-field>
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">{{translations.events.column_description}}</label>
                            <div class="control">
                                <textarea v-model="event.detail_attributes.description" class="textarea" name="description" :readonly="!eventEditable"></textarea>
                            </div>
                        </div>
                        <div class="columns">
                            <div class="column is-6">
                                <div class="field">
                                    <label class="checkbox">
                                        <input type="checkbox" name="public" v-model="event.detail_attributes.public" :disabled="!eventEditable">
                                        {{ translations.events.view_text_mark_as_public }}
                                    </label>
                                </div>
                            </div>
                            <div class="column is-6 has-text-right">
                                <a v-if="data.event.id" class="button is-outlined" :href="`/driver/events/${event.id}.ics`">
                                    <span class="icon">
                                        <i class="fas fa-download"></i>
                                    </span>
                                    <span>{{ translations.events.view_btn_download }}</span>
                                </a>
                            </div>
                        </div>
                        <div class="buttons">
                            <button v-if="eventEditable" name="btn-save" class="button is-primary is-fullwidth" type="submit">
                                <span v-if="submit.event">
                                    <b-icon icon="circle-notch" custom-class="fa-spin" size="is-small" />
                                    &nbsp;
                                    {{translations.core.view_btn_saving}}
                                </span>
                                <span v-else>
                                    <b-icon icon="save" size="is-small" />
                                    &nbsp;
                                    {{translations.core.view_btn_save}}
                                </span>
                            </button>
                        </div>
                    </fieldset>
                </form>
            </b-tab-item>
            <b-tab-item v-if="data.event.id" :label="translations.events.view_tab_title_attendants">
                <component-attendants :event-id="data.event.id" :event-editable="event.editable" custom-table-class="box" />
            </b-tab-item>
            <b-tab-item :label="translations.core.view_text_discussions" v-if="data.event.id">
                <div class="box">
                    <component-cloud-object-discussion-simple
                        cloud-module="driver/event"
                        :cloud-id="data.event.id"
                        translations-path="driver.event/discussions"
                    >
                    </component-cloud-object-discussion-simple>
                </div>
            </b-tab-item>
            <b-tab-item :label="translations.core.view_text_files" v-if="data.event.id">
                <component-cloud-object-file
                    cloud-module="driver/event"
                    :cloud-id="data.event.id"
                    translations-path="driver.event/files"
                    translations-file-types-path="driver.event/files"
                />
            </b-tab-item>
            <b-tab-item :label="translations.core.view_tab_title_delete_section" v-if="data.event.id">
                    <span class="has-text-danger">
                        {{translations.events.view_text_delete_confirmation}}
                    </span>
                    <br>
                    <br>
                    <b-field v-if="data.event.id">
                        <b-button type="is-danger" @click="deleteEvent" expanded class="submit-button" :disabled="submit.delete">
                            <span v-if="submit.delete">
                                <i class="fas fa-spin fa-circle-notch"></i> {{translations.core.view_btn_deleting}}
                            </span>
                            <span v-else>
                                <i class="fas fa-trash-alt"></i> {{translations.core.view_btn_delete}}
                            </span>
                        </b-button>
                    </b-field>
                </b-tab-item>
        </b-tabs>
    </component-sidebar-view>
</template>
