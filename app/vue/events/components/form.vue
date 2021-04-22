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
            translations: {
                main: I18n.t('driver.events'),
                core: {
                    shared: I18n.t('core.shared')
                }
            },
            main_route: '/driver/events',
            submit: {
                event: false
            },
            event: {
                detail_attributes: {
                    title: '',
                    description: '',
                    event_date: new Date(),
                    time_start: new Date(),
                    time_end: new Date(),
                    event_type: null,
                    public: false,
                },
                organizer_name: '',
                editable: true,
            },
            config: {
                dateFormat: ""
            },
            view_type: 'new',
            options: {
                event_types: []
            }
        }
    },

    beforeMount() {
        if(this.view_type !== 'new') return true;

        let time_end = this.event.detail_attributes.time_end;
        time_end.setHours(time_end.getHours() + 1)
        this.event.detail_attributes.time_end = time_end
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
            this.submit.event = true

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
            }).finally(()=>{
                this.submit.event = false
            })
        },

        putEvent() {
            this.syncEventDate()
            let form_data = {
                event: this.event
            }
            let url = `${this.main_route}/${this.eventId}.json`
            this.submit.event = true

            this.http.put(url, form_data).then(result => {
                if (result.successful) {
                    this.alert('Event updated successfully', 'success')
                }else{
                    this.alert(result.error.message, 'danger')
                }
            }).catch(error => {
                console.log(error)
            }).finally(()=>{
                this.submit.event = false
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
                    <fieldset :disabled="submit.event">
                        <div class="field" v-if="eventId">
                            <label class="label">Organizer</label>
                            <div class="control">
                                <input class="input" type="text" v-model="event.organizer_name" placeholder="Organizer" disabled="true">
                            </div>
                        </div>
                        <b-field>
                            <template v-slot:label>
                                {{translations.main.column_title}}
                                <sup class="has-text-danger">*</sup>
                            </template>
                            <b-input type="text" :placeholder="translations.main.view_placeholder_title" v-model="event.detail_attributes.title" required>
                            </b-input>
                        </b-field>
                        <div class="columns is-multiline">
                            <div class="column is-3">
                                <b-field>
                                    <template v-slot:label>
                                        {{translations.main.column_time_start}}
                                        <sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-datetimepicker
                                        v-model="event.detail_attributes.time_start"
                                        rounded
                                        required
                                        :placeholder="translations.core.shared.view_placeholder_select_date"
                                        icon="fa fa-calendar"
                                        :datetime-formatter="date.toStringDatetime"
                                        :datepicker="{ showWeekNumber: false }"
                                        :timepicker="{ enableSeconds: false, hourFormat: '24' }"
                                        horizontal-time-picker
                                    >
                                    </b-datetimepicker>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field>
                                    <template v-slot:label>
                                        {{translations.main.column_time_end}}
                                        <sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-datetimepicker
                                        v-model="event.detail_attributes.time_end"
                                        rounded
                                        required
                                        :placeholder="translations.core.shared.view_placeholder_select_date"
                                        icon="fa fa-calendar"
                                        :datetime-formatter="date.toStringDatetime"
                                        :datepicker="{ showWeekNumber: false }"
                                        :timepicker="{ enableSeconds: false, hourFormat: '24' }"
                                        horizontal-time-picker
                                    >
                                    </b-datetimepicker>
                                </b-field>
                            </div>
                            <div class="column is-6">
                                <b-field :label="translations.main.column_location">
                                    <b-input v-model="event.detail_attributes.location" :placeholder="translations.main.view_placeholder_location">
                                    </b-input>
                                </b-field>
                            </div>
                            <div class="column is-4">
                                <b-field>
                                    <template v-slot:label>
                                        {{translations.main.column_event_type}}
                                        <sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-select
                                        v-model="event.detail_attributes.event_type"
                                        expanded
                                        :placeholder="translations.core.shared.view_placeholder_select_option"
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
                            <div class="column is-4">
                                <b-field :label="translations.main.column_public">
                                    <b-checkbox v-model="event.detail_attributes.public" :true-value="true" :false-value="false">
                                        <span v-if="event.detail_attributes.public">
                                            {{translations.core.shared.view_text_yes}}
                                        </span>
                                        <span v-else>
                                            {{translations.core.shared.view_text_no}}
                                        </span>
                                    </b-checkbox>
                                </b-field>
                            </div>
                            <div class="column is-12">
                                <b-field :label="translations.main.column_description">
                                    <b-input 
                                        type="textarea"
                                        :placeholder="translations.main.view_placeholder_description"
                                        rows="7"
                                        v-model="event.detail_attributes.description"
                                    >
                                    </b-input>
                                </b-field>
                            </div>
                            <div class="column is-12">
                                <b-button type="is-primary" native-type="submit" expanded>
                                    <span v-if="submit.event">
                                        <b-icon icon="circle-notch" custom-class="fa-spin"></b-icon>
                                        <span>{{translations.core.shared.view_btn_saving}}</span>
                                    </span>
                                    <span v-else>
                                        <b-icon icon="save"></b-icon>
                                        <span>{{translations.core.shared.view_btn_save}}</span>
                                    </span>
                                </b-button>
                            </div>
                        </div>

                        <!---------------------------------- START SUBMIT BUTTON ---------------------------------->
                        <!----------------------------------  END SUBMIT BUTTON  ---------------------------------->
                        
                        <!---------------------------------- START DELETE BUTTON ---------------------------------->
                        <b-field v-if="viewType == 'show'">
                            <b-button type="is-danger" @click="deleteEvent">
                                Delete Event
                            </b-button>
                        </b-field>
                        <!----------------------------------  END DELETE BUTTON  ---------------------------------->
                    </fieldset>
                </form>
            </section>
        </div>
        <!---------------------------------------  END CARD CONTENT --------------------------------------->
    </div>
</template>
