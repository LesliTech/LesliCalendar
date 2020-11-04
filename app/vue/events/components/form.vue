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
import DatePicker from 'v-calendar/lib/components/date-picker.umd'

// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~

export default {
    components: {
        'vc-date-picker': DatePicker
    },

    props: {
        viewType: {
            type: String,
            required: true
        },
        eventId: {
            type: String,
            required: false
        },
    },

    data() {
        return {
            main_route: '/driver/events',
            event: {
                detail_attributes: {
                    title: '',
                    description: '',
                    event_date: new Date(),
                    time_start: new Date(),
                    time_end: new Date(),
                    event_type: '',
                    public: false,
                },
                organizer_name: '',
                editable: true,
            },
            isDescriptionShown: false,
            config: {
                dateFormat: ""
            },
            view_type: 'new',
            options: {
                event_types: []
            }
        }
    },

    mounted() {
        this.getOptions()
        if(!this.eventId) return true;

        this.view_type = 'edit'
        this.getEvent()
    },

    methods: {
        getEvent(){
            this.http.get(`/driver/events/${this.eventId}.json`).then(result => {
                if(result.data.detail_attributes.time_start){
                    result.data.detail_attributes.time_start = new Date(result.data.detail_attributes.time_start)
                }
                if(result.data.detail_attributes.time_end){
                    result.data.detail_attributes.time_end = new Date(result.data.detail_attributes.time_end)
                }
                this.event = result.data
                this.syncEventDate()

                if(this.event.detail_attributes.description) {
                    this.isDescriptionShown = true
                }
            }).catch(error => {
                console.log(error)
            })
        },

        submitEvent(event){
            if (event) { event.preventDefault() }

            if(this.viewType == 'new'){
                this.postEvent()
            }else if(this.viewType == 'edit'){
                this.putEvent()
            }
        },

        postEvent() {
            this.syncEventDate()
            let form_data = {
                event: this.event
            }
            let url = `${this.main_route}.json`

            this.http.post(url, form_data).then(result => {
                if (result.successful) {
                    this.eventId = result.data.id
                    this.$set(this.event, 'id', result.data.id)
                    this.$set(this.event, 'editable', true)
                    this.alert('Event created successfully', 'success')
                    this.$router.push(`/${result.data.id}`)
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putEvent() {
            this.syncEventDate()
            let form_data = {
                event: this.event
            }
            let url = `${this.main_route}/${this.eventId}.json`

            this.http.put(url, form_data).then(result => {
                if (result.successful) {
                    this.alert('Event updated successfully', 'success')
                    this.$router.push(`/${this.event.id}`)
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })

        },

        deleteEvent() {
            let url = `${this.main_route}/${this.event_id}`

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.alert('Event deleted successfully', 'success')
                    this.$router.push('/')
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        showDescriptionField(event) {
            if (event) { event.preventDefault() }
            this.isDescriptionShown = !this.isDescriptionShown
        },

        isDefaultPublic() {
            switch (this.event.detail_attributes.event_type) {
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

        syncEventDate(){
            this.event.detail_attributes.event_date = this.event.detail_attributes.time_start
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
    },
    computed: {
        eventEditable(){
            return (! this.eventId) || this.event.editable
        }
    }
}
</script>
<template>
    <div class="card" v-if="event">
        <!--------------------------------------- START CARD CONTENT--------------------------------------->
        <div class="card-content">
            <section v-if="viewType == 'new' || viewType == 'edit'">
            <form @submit="submitEvent">
                <div class="field" v-if="eventId">
                    <label class="label">Organizer</label>
                    <div class="control">
                        <input class="input" type="text" v-model="event.organizer_name" placeholder="Organizer" disabled="true">
                    </div>
                </div>
                <div class="field">
                    <div class="field-body">
                        <div class="field">
                            <label class="label">Title</label>
                            <p class="control">
                                <input class="input" type="text" placeholder="Add a title for the event" v-model="event.detail_attributes.title" :readonly="!eventEditable">
                            </p>
                        </div>
                    </div>
                </div>
                <div class="field is-horizontal">
                    <div class="field-body">
                        <div class="field">
                            <label class="label">
                                Time Start
                                <sup class="has-text-danger">*</sup>
                            </label>
                            <div class="control">
                                <vc-date-picker
                                    v-model="event.detail_attributes.time_start"
                                    mode="date"
                                    required: true
                                    :input-props="{
                                        disabled: ! eventEditable,
                                        placeholder: 'Time Start',
                                        required: true
                                    }"
                                >
                                </vc-date-picker>
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">
                                Time End
                                <sup class="has-text-danger">*</sup>
                            </label>
                            <div class="control">
                                <vc-date-picker
                                    v-model="event.detail_attributes.time_end"
                                    mode="date"
                                    required: true
                                    :input-props="{
                                        disabled: ! eventEditable,
                                        placeholder: 'Time End',
                                        required: true
                                    }"
                                >
                                </vc-date-picker>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="field is-horizontal">
                    <div class="field-body">
                        <p class="control has-icons-left has-icons-right">
                            <input class="input" placeholder="Location" v-model="event.detail_attributes.location" :readonly="!eventEditable">
                            <span class="icon is-small is-left">
                                <i class="fa fa-map-marker"></i>
                            </span>
                        </p>
                        <div class="field">
                            <div class="control">
                            <label class="checkbox">
                                <input type="checkbox" v-model="event.detail_attributes.public" :disabled='isDefaultPublic() || !eventEditable'>
                                    Public
                            </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="field is-horizontal">
                    <div class="field-body">
                        <div class="field">
                            <label class="label">
                                Type of event
                                <sup class="has-text-danger">*</sup>
                            </label>
                            <b-select
                                v-model="event.detail_attributes.event_type"
                                :disabled="! eventEditable"
                                expanded
                                placeholder="Event Type"
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
                    </div>
                </div>
                <div class="field is-horizontal">
                    <button class="button" v-bind:class="{ 'is-hidden': isDescriptionShown }" @click="showDescriptionField">
                        <span class="icon">
                            <i class="fa fa-align-left"></i>
                        </span>
                        <span>Add a description</span>
                    </button>
                    <div class="field-body">
                        <textarea 
                            class="textarea"
                            v-bind:class="{ 'is-hidden': !isDescriptionShown }"
                            placeholder="Description for event"
                            rows="10"
                            v-model="event.detail_attributes.description"
                            :readonly="!eventEditable">
                        </textarea>
                    </div>
                </div>

                <!---------------------------------- START SUBMIT BUTTON ---------------------------------->
                <b-field v-if="viewType == 'new' || viewType == 'edit'">
                    <b-button type="is-primary" native-type="submit" expended>
                        <span v-if="viewType == 'new'">
                            Create Event
                        </span>
                        <span v-else>
                            Update Event
                        </span>
                    </b-button>
                </b-field>
                <!----------------------------------  END SUBMIT BUTTON  ---------------------------------->
                
                <!---------------------------------- START DELETE BUTTON ---------------------------------->
                <b-field v-if="viewType == 'show'">
                    <b-button type="is-danger" @click="deleteEvent">
                        Delete Event
                    </b-button>
                </b-field>
                <!----------------------------------  END DELETE BUTTON  ---------------------------------->
            </form>
            </section>
        </div>
        <!---------------------------------------  END CARD CONTENT --------------------------------------->
    </div>
</template>
