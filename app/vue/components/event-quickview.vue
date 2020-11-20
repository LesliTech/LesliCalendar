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
import DatePicker from 'v-calendar/lib/components/date-picker.umd'


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
        'component-attendants': componentAttendants,
        'vc-date-picker': DatePicker
    },
    props: {
        discussionsTranslationsPath: {
            type: String,
            default : 'deutscheleibrenten.shared'
        },

        filesTranslationsPath: {
            type: String,
            default: 'deutscheleibrenten.shared'
        }
    },

    data() {
        return {
            show: false,
            event_id:null,
            active_tab: 0,
            translations: {
                main: I18n.t('deutscheleibrenten.events'),
                core: I18n.t('deutscheleibrenten.shared')
            },
            submitting_form: false,
            event: {
                detail_attributes: {
                    title: null,
                    description: '',
                    event_date: null,
                    time_start: null,
                    time_end: null,
                    location: '',
                    url: ''
                }
            },
            options: {
                event_types: []
            }
        }
    },
    mounted() {
        this.addListeners();
        this.getOptions();
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
                        event_date: this.newDate(),
                        time_start: null,
                        time_end: null,
                        location: '',
                        url: ''
                    }
                }
                this.active_tab = 0
                // this.syncEventDateTime()
            }
            this.show = !this.show
        },
        getEvent() {
            this.http.get(`/driver/events/${this.event_id}.json`).then(result => {
                result.data.detail_attributes.event_date = new Date(result.data.detail_attributes.event_date)
                if(result.data.detail_attributes.time_start){
                    result.data.detail_attributes.time_start = new Date(result.data.detail_attributes.time_start)
                }
                if(result.data.detail_attributes.time_end){
                    result.data.detail_attributes.time_end = new Date(result.data.detail_attributes.time_end)
                }
                this.event = result.data
            }).catch(error => {
                console.log(error)
            })
        },
        postEvent(e) {
            if (e) { e.preventDefault() }
            this.submitting_form = true

            this.http.post('/driver/events', {event: this.event}).then(result => {
                this.submitting_form = false
                this.event_id = result.data.id
                this.$set(this.event, 'id', result.data.id)
                this.$set(this.event, 'editable', true)
                this.organizer_name = result.data.organizer_name
                this.active_tab = 1
                this.$emit('post-event', result.data)
                this.bus.publish("post:/driver/event")
                this.alert(this.translations.main.notification_event_created, 'success')
            }).catch(error => {
                console.log(error)
            })
        },
        putEvent(e) {
            if (e) { e.preventDefault() }
            this.submitting_form = true

            this.http.put(`/driver/events/${this.event_id}.json`, {event: this.event}).then(result => {
                this.submitting_form = false
                if (result.successful) {
                    this.bus.publish("put:/driver/event")
                    this.alert(this.translations.main.notification_event_updated, 'success')
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        submitEvent(e) {
            this.syncEventDateTime()
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
            let url = `/driver/events/${this.event_id}.json`

            this.http.delete(url).then(result => {
                if (result.successful) {
                this.show = false
                this.$emit('delete-event', this.event)
                this.alert(this.translations.main.notification_event_deleted, 'success')
                } else {
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        getOptions() {
            this.http.get(`/driver/events/options.json`).then(result => {
                if (result.successful) {
                    for(let key in result.data){
                        this.$set(this.options, key, result.data[key])
                    }
                }
            }).catch(error => {
                console.log(error)
            }) 
        },
        parseDate(time) {
            const date = new Date(this.event.detail_attributes.event_date);
            date.setHours(time.getHours());
            date.setMinutes(time.getMinutes());
            return date;
        },
        isDefaultPublic() {
            switch (this.event.detail_attributes.event_type) {
                case 'notary_appointment':
                case 'fair_with_kop':
                case 'fair_dlgag':
                    return true;
                default:
                    return false;
            }
        },
        syncEventDateTime(){
            const event = { ...this.event, ...this.event.detail_attributes }
            if (event.time_start) {
                this.event.detail_attributes.time_start = this.parseDate(event.time_start);
                this.event.detail_attributes.time_end = this.parseDate(event.time_end || event.time_start);
            }
        },
        newDate() {
            return new Date(new Date().setHours(0,0,0,0))
        }
    },

    watch: {
        'event.detail_attributes.event_type'(event_type) {
            switch (event_type) {
                case 'notary_appointment':
                case 'fair_with_kop':
                case 'fair_dlgag':
                    this.event.detail_attributes.public = true;
                    break;
                default:
                    this.event.detail_attributes.public = false;
                    break;
            }
        },
        'event.detail_attributes.event_date'(event_date) {
            this.syncEventDateTime()
        },
    },

    computed: {
        eventEditable(){
            return (! this.event_id) || this.event.editable
        }
    }

}
</script>
<template>
    <div :class="[{ 'is-active': show }, 'quickview', 'is-size-large']">
        <header class="quickview-header">
            <h4 class="title" name="event-title">{{ (this.event.detail_attributes.title ? this.event.detail_attributes.title : this.translations.main.form_title_new) }}</h4>
            <span class="delete" @click="show = false"></span>
        </header>
        <div class="quickview-body">
            <b-tabs expanded v-model="active_tab">
                <b-tab-item :label="translations.core.text_information">
                    <form @submit.prevent="submitEvent()">
                        <fieldset :disabled="submitting_form">
                            <div class="field" v-if="event_id">
                                <label class="label">{{translations.core.text_organizer}}</label>
                                <div class="control">
                                    <input class="input" type="text" name="organizer_name" v-model="event.organizer_name" placeholder="Organizer" disabled="true">
                                </div>
                            </div>
                            <div class="field">
                                <label class="label">{{translations.core.text_title}}<sup class="has-text-danger">*</sup></label>
                                <div class="control">
                                    <input class="input" type="text" name="title" v-model="event.detail_attributes.title" required :readonly="!eventEditable">
                                </div>
                            </div>
                            <div class="field">
                                <label class="label">{{translations.core.text_description}}</label>
                                <div class="control">
                                    <textarea class="textarea" name="description" :readonly="!eventEditable"></textarea>
                                </div>
                            </div>
                            <div class="field">
                                <label class="label">{{translations.core.text_address}}</label>
                                <div class="control">
                                    <input class="input" type="text" name="address" v-model="event.detail_attributes.location" :readonly="!eventEditable">
                                </div>
                            </div>
                            <div class="field">
                                <label class="label">
                                    {{ translations.main.form_label_type_of_event }}
                                    <sup class="has-text-danger">*</sup>
                                </label>
                                <b-select
                                    name="event_type"
                                    v-model="event.detail_attributes.event_type"
                                    :disabled="! eventEditable"
                                    expanded
                                    :placeholder="translations.core.text_select_option"
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
                            </div> 
                            <div class="field">
                                <label class="checkbox">
                                    <input type="checkbox" name="public" v-model="event.detail_attributes.public" :disabled='isDefaultPublic() || !eventEditable'>
                                    {{ translations.main.form_input_mark_event_as_public_title }}
                                </label>
                            </div>
                            <div class="field">
                                <label class="label">
                                    {{ translations.main.form_label_date }}
                                    <sup class="has-text-danger">*</sup>
                                </label>
                                <div class="control">
                                    <vc-date-picker
                                        v-model="event.detail_attributes.event_date"
                                        :locale="date.vcDatepickerConfig()"
                                        :popover="{ visibility: 'focus' }"
                                        :input-props="{
                                            name: `event_date`,
                                            disabled: ! eventEditable,
                                            placeholder: translations.core.text_select_date,
                                            required: true
                                        }"
                                    >
                                    </vc-date-picker>
                                </div>
                            </div>
                            <b-field :label="translations.core.text_start_at">
                                <b-timepicker
                                    name="time_start"
                                    v-if="eventEditable"
                                    editable
                                    :placeholder="translations.core.text_select_time"
                                    icon="clock"
                                    v-model="event.detail_attributes.time_start">
                                </b-timepicker>
                                <div v-else class="control has-icons-left is-clearfix">
                                    <input type="text" autocomplete="off" class="input" readonly :value="date.toStringTime(event.detail_attributes.time_start)">
                                    <span class="icon is-left"><i class="fas fa-clock fa-lg"></i></span>
                                </div>
                            </b-field>
                            <b-field :label="translations.core.text_end_at">
                                <b-timepicker
                                    name="time_end"
                                    v-if="eventEditable"
                                    editable
                                    :placeholder="translations.core.text_select_time"
                                    icon="clock"
                                    v-model="event.detail_attributes.time_end">
                                </b-timepicker>
                                <div v-else class="control has-icons-left is-clearfix">
                                    <input type="text" autocomplete="off" class="input" readonly :value="date.toStringTime(event.detail_attributes.time_start)">
                                    <span class="icon is-left"><i class="fas fa-clock fa-lg"></i></span>
                                </div>
                            </b-field>
                            <div class="columns">
                                <div class="column">
                                    <div class="buttons">
                                        <button v-if="event_id && event.editable" class="button is-danger" type="button" @click="deleteEvent">
                                            <span class="icon">
                                                <i class="fas fa-trash"></i>
                                            </span>
                                            <span>{{translations.main.form_btn_delete}}</span>
                                        </button>
                                    </div>
                                </div>
                                <div class="column">
                                    <div class="buttons is-right">
                                        <a class="button is-outlined" v-if="event.model_type == 'CloudHouse::Project'" :href="`/crm/projects/${event.model_global_identifier}`">
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
                                        <a class="button is-outlined" :href="`/driver/events/${event.id}.ics`" v-if="event_id">
                                            <span class="icon">
                                                <i class="fas fa-download"></i>
                                            </span>
                                            <span>{{ translations.core.btn_download }}</span>
                                        </a>
                                        <button v-if="eventEditable" name="btn-save" class="button is-primary" type="submit">
                                            <span v-if="submitting_form">
                                                <b-icon icon="circle-notch" custom-class="fa-spin" size="is-small" />
                                                &nbsp;
                                                {{translations.core.btn_saving}}
                                            </span>
                                            <span v-else>
                                                <b-icon icon="save" size="is-small" />
                                                &nbsp;
                                                {{translations.core.btn_save}}
                                            </span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </fieldset>
                    </form>
                </b-tab-item>
                <b-tab-item :label="translations.core.text_employees">
                    <component-attendants v-if="event_id" :event-id="event_id" :event-editable="event.editable" />
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
                        translations-file-types-path="driver.event/files"
                    />
                </b-tab-item>
                <slot name="extra-tab-item" :event_id="event_id">
                </slot>
            </b-tabs>

            <div class="quickview-block">
                
            </div>
        </div>
        <footer class="quickview-footer">

        </footer>
    </div>
</template>
